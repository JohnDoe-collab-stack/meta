"""Learned encoders and typed sequential decision heads."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Mapping

import torch
from torch import Tensor, nn

from .baselines import SYSTEMS, SystemSpec


@dataclass(frozen=True)
class SizeSpec:
    d_model: int
    layers: int
    heads: int
    d_ff: int


SIZES: Mapping[str, SizeSpec] = {
    "small": SizeSpec(64, 2, 4, 256),
    "base": SizeSpec(128, 4, 8, 512),
    "large": SizeSpec(256, 8, 8, 1024),
}


CATALOG_SIZES = {
    "gap": 16,
    "use": 16,
    "transport": 16,
    "query": 32,
    "repair": 64,
    "continue": 32,
}


def masked_argmax(logits: Tensor, allowed_mask: Tensor) -> Tensor:
    if logits.shape != allowed_mask.shape:
        raise ValueError("mask and logits must have the same shape")
    if allowed_mask.dtype is not torch.bool:
        raise ValueError("typed mask must be boolean")
    if not bool(torch.all(torch.any(allowed_mask, dim=-1))):
        raise ValueError("every batch item needs at least one typed value")
    masked = logits.masked_fill(~allowed_mask, torch.finfo(logits.dtype).min)
    return torch.argmax(masked, dim=-1)


class PerceptualEncoder(nn.Module):
    def __init__(self, d_model: int) -> None:
        super().__init__()
        self.network = nn.Sequential(
            nn.Conv2d(3, 32, 3, stride=2, padding=1),
            nn.ReLU(),
            nn.Conv2d(32, 64, 3, stride=2, padding=1),
            nn.ReLU(),
            nn.Conv2d(64, 128, 3, stride=2, padding=1),
            nn.ReLU(),
            nn.Conv2d(128, d_model, 3, stride=1, padding=1),
        )

    def forward(self, frames: Tensor) -> Tensor:
        if frames.ndim != 5 or frames.shape[2:] != (3, 64, 64):
            raise ValueError("frames must have shape [batch, frames, 3, 64, 64]")
        batch, count = frames.shape[:2]
        encoded = self.network(frames.reshape(batch * count, 3, 64, 64))
        encoded = encoded.flatten(2).transpose(1, 2)
        return encoded.reshape(batch, count * encoded.shape[1], encoded.shape[2])


class TokenEncoder(nn.Module):
    def __init__(self, vocab_size: int, d_model: int, maximum_length: int = 512) -> None:
        super().__init__()
        self.maximum_length = maximum_length
        self.token = nn.Embedding(vocab_size, d_model)
        self.position = nn.Embedding(maximum_length, d_model)
        self.provenance = nn.Embedding(8, d_model)

    def forward(self, tokens: Tensor, provenance: Tensor | None = None) -> Tensor:
        if tokens.ndim != 2 or tokens.shape[1] > self.maximum_length:
            raise ValueError("token batch violates the length contract")
        positions = torch.arange(tokens.shape[1], device=tokens.device)[None, :]
        if provenance is None:
            provenance = torch.zeros_like(tokens)
        return self.token(tokens) + self.position(positions) + self.provenance(provenance)


class TypedHead(nn.Module):
    def __init__(self, d_model: int, catalog_size: int) -> None:
        super().__init__()
        self.network = nn.Sequential(
            nn.Linear(d_model, d_model), nn.ReLU(), nn.Linear(d_model, catalog_size)
        )

    def forward(self, context: Tensor, mask: Tensor) -> tuple[Tensor, Tensor]:
        logits = self.network(context)
        return logits, masked_argmax(logits, mask)


class CausalAgent(nn.Module):
    """B13 architecture. Deliberately contains no direct next-state head."""

    def __init__(
        self,
        size: str = "base",
        vocab_size: int = 4096,
        dropout: float = 0.1,
        system_id: str = "B13",
    ) -> None:
        super().__init__()
        if size not in SIZES:
            raise ValueError(f"unknown model size {size}")
        if system_id not in SYSTEMS:
            raise ValueError(f"unknown system {system_id}")
        self.size_name = size
        self.system: SystemSpec = SYSTEMS[system_id]
        self.repair_reads_raw_context = system_id in {"B5", "B6", "B8", "B12"}
        spec = SIZES[size]
        self.perceptual_encoder = PerceptualEncoder(spec.d_model)
        self.symbolic_encoder = TokenEncoder(vocab_size, spec.d_model)
        self.candidate_encoder = TokenEncoder(vocab_size, spec.d_model)
        self.history_encoder = TokenEncoder(vocab_size, spec.d_model)
        self.response_encoder = TokenEncoder(vocab_size, spec.d_model)
        self.type_embedding = nn.Embedding(5, spec.d_model)
        self.aggregate_position = nn.Embedding(4096, spec.d_model)
        layer = nn.TransformerEncoderLayer(
            d_model=spec.d_model,
            nhead=spec.heads,
            dim_feedforward=spec.d_ff,
            dropout=dropout,
            activation="relu",
            batch_first=True,
            norm_first=True,
        )
        self.aggregator = nn.TransformerEncoder(
            layer, num_layers=spec.layers, enable_nested_tensor=False
        )
        self.final_norm = nn.LayerNorm(spec.d_model)
        self.decision_embedding = nn.ModuleDict(
            {
                key: nn.Embedding(size_value, spec.d_model)
                for key, size_value in CATALOG_SIZES.items()
            }
        )
        self.heads = nn.ModuleDict(
            {
                key: TypedHead(spec.d_model, size_value)
                for key, size_value in CATALOG_SIZES.items()
            }
        )
        if self.system.direct_next_head:
            self.direct_next_head: TypedHead | None = TypedHead(
                spec.d_model, CATALOG_SIZES["continue"]
            )
        else:
            self.direct_next_head = None

    def _aggregate(self, streams: list[tuple[int, Tensor]]) -> Tensor:
        tagged = [
            stream + self.type_embedding.weight[tag][None, None, :]
            for tag, stream in streams
        ]
        tokens = torch.cat(tagged, dim=1)
        length = tokens.shape[1]
        if length > self.aggregate_position.num_embeddings:
            raise ValueError("aggregated context exceeds the 4096-token contract")
        positions = torch.arange(length, device=tokens.device)[None, :]
        tokens = tokens + self.aggregate_position(positions)
        causal_mask = torch.triu(
            torch.ones(length, length, dtype=torch.bool, device=tokens.device),
            diagonal=1,
        )
        encoded = self.aggregator(tokens, mask=causal_mask)
        return self.final_norm(encoded[:, -1])

    def encode_public(
        self,
        observation: Tensor,
        candidate_tokens: Tensor,
        history_tokens: Tensor,
        symbolic: bool,
    ) -> Tensor:
        allowed = set(self.system.allowed_inputs)
        streams: list[tuple[int, Tensor]] = []
        if "observation" in allowed:
            if symbolic:
                observation_stream = self.symbolic_encoder(observation)
            else:
                observation_stream = self.perceptual_encoder(observation)
            streams.append((0, observation_stream))
        if "candidate" in allowed:
            candidate = self.candidate_encoder(candidate_tokens)
            streams.append((1, candidate))
        if "history" in allowed:
            history = self.history_encoder(history_tokens)
            streams.append((2, history))
        if not streams:
            raise RuntimeError("system has no authorized public input")
        return self._aggregate(streams)

    def _typed_decision(
        self, name: str, context: Tensor, mask: Tensor
    ) -> tuple[Tensor, Tensor, Tensor]:
        logits, selected = self.heads[name](context, mask)
        discrete = self.decision_embedding[name](selected)
        return logits, selected, discrete

    def decide_pre_response(
        self,
        context: Tensor,
        masks: Mapping[str, Tensor],
        intervention_id: str | None = None,
        intervention_seed: int = 0,
    ) -> dict[str, tuple[Tensor, Tensor]]:
        outputs: dict[str, tuple[Tensor, Tensor]] = {}
        current = torch.zeros_like(context) if intervention_id == "I_projection" else context
        for name in ("gap", "use", "transport", "query"):
            authorized_head = name in self.system.allowed_actions
            if not authorized_head:
                selected = torch.zeros(
                    context.shape[0], dtype=torch.long, device=context.device
                )
                logits = torch.zeros(
                    context.shape[0], CATALOG_SIZES[name], device=context.device
                )
                discrete = torch.zeros_like(context)
            elif name == "gap" and self.system.random_gap:
                selected = torch.randint(
                    0, CATALOG_SIZES[name], (context.shape[0],), device=context.device
                )
                logits = torch.zeros(
                    context.shape[0], CATALOG_SIZES[name], device=context.device
                )
                discrete = self.decision_embedding[name](selected)
            else:
                source = current
                if name in {"use", "transport", "query"} and not self.system.gap_reaches_downstream:
                    source = context
                logits, selected, discrete = self._typed_decision(
                    name, source, masks[name]
                )
            selected = self._apply_discrete_intervention(
                name, selected, masks[name], intervention_id, intervention_seed
            )
            if authorized_head:
                discrete = self.decision_embedding[name](selected)
            else:
                discrete = torch.zeros_like(context)
            outputs[name] = (logits, selected)
            current = current + discrete
        return outputs

    @staticmethod
    def _apply_discrete_intervention(
        name: str,
        selected: Tensor,
        mask: Tensor,
        intervention_id: str | None,
        intervention_seed: int,
    ) -> Tensor:
        suppress = {
            "gap": "I_gap_suppress",
            "use": "I_use_suppress",
            "transport": "I_transport_suppress",
            "repair": "I_repair_neutral",
        }
        permute = {
            "gap": {"I_gap_permute"},
            "use": {"I_use_permute"},
            "transport": {"I_transport_permute", "I_order_swap"},
            "query": {"I_query_alternate"},
            "repair": {"I_repair_permute"},
        }
        if intervention_id is not None and suppress.get(name) == intervention_id:
            return torch.zeros_like(selected)
        if name == "query" and intervention_id == "I_query_neutral":
            return mask.to(torch.int64).sum(dim=1) - 1
        if intervention_id in permute.get(name, set()):
            result = selected.clone()
            for row in range(selected.shape[0]):
                allowed = torch.nonzero(mask[row], as_tuple=False).flatten()
                position = int(torch.nonzero(allowed == selected[row], as_tuple=False)[0])
                result[row] = allowed[(position + 1) % len(allowed)]
            return result
        if name == "gap" and intervention_id == "I_random_gap":
            generator = torch.Generator(device=selected.device)
            generator.manual_seed(intervention_seed)
            result = selected.clone()
            for row in range(selected.shape[0]):
                allowed = torch.nonzero(mask[row], as_tuple=False).flatten()
                choice = int(torch.randint(len(allowed), (1,), generator=generator, device=selected.device))
                result[row] = allowed[choice]
            return result
        return selected

    def decide_post_response(
        self,
        context: Tensor,
        selected_pre: Mapping[str, Tensor],
        response_tokens: Tensor,
        masks: Mapping[str, Tensor],
        intervention_id: str | None = None,
        intervention_seed: int = 0,
    ) -> dict[str, tuple[Tensor, Tensor]]:
        response = self.response_encoder(response_tokens).mean(dim=1)
        # B13 is intentionally separated from the raw context here. Its repair
        # input consists only of decoded causal decisions and the response.
        if self.repair_reads_raw_context:
            current = context + response
        else:
            current = response
        for name in ("gap", "use", "transport", "query"):
            if name in selected_pre and (
                name != "gap" or self.system.gap_reaches_downstream
            ) and not (name == "gap" and intervention_id == "I_unused_gap"):
                current = current + self.decision_embedding[name](selected_pre[name])
        if self.system.oracle_patch:
            repair = masks["repair"].to(torch.int64).sum(dim=1) - 1
            repair_logits = torch.zeros(
                current.shape[0], CATALOG_SIZES["repair"], device=current.device
            )
            repair_embedding = self.decision_embedding["repair"](repair)
        elif "repair" in self.system.allowed_actions:
            repair_logits, repair, repair_embedding = self._typed_decision(
                "repair", current, masks["repair"]
            )
        else:
            repair = torch.zeros(
                current.shape[0], dtype=torch.long, device=current.device
            )
            repair_logits = torch.zeros(
                current.shape[0], CATALOG_SIZES["repair"], device=current.device
            )
            repair_embedding = torch.zeros_like(current)
        repair = self._apply_discrete_intervention(
            "repair", repair, masks["repair"], intervention_id, intervention_seed
        )
        repair_embedding = self.decision_embedding["repair"](repair)
        # The transition is the execution of the decoded repair embedding.
        repaired_state = current + repair_embedding
        if intervention_id == "I_next_bypass":
            continue_logits = torch.zeros(
                current.shape[0], CATALOG_SIZES["continue"], device=current.device
            )
            continuation = torch.zeros(
                current.shape[0], dtype=torch.long, device=current.device
            )
            typed_refusal = torch.ones(
                current.shape[0], dtype=torch.bool, device=current.device
            )
        elif self.direct_next_head is not None:
            continue_logits, continuation = self.direct_next_head(
                current, masks["continue"]
            )
        else:
            continue_logits, continuation, _ = self._typed_decision(
                "continue", repaired_state, masks["continue"]
            )
            typed_refusal = torch.zeros(
                current.shape[0], dtype=torch.bool, device=current.device
            )
        if intervention_id != "I_next_bypass" and self.direct_next_head is not None:
            typed_refusal = torch.zeros(
                current.shape[0], dtype=torch.bool, device=current.device
            )
        return {
            "repair": (repair_logits, repair),
            "continue": (continue_logits, continuation),
            "repaired_state": (repaired_state, repair),
            "typed_refusal": (typed_refusal, continuation),
        }

    def decide_passive(
        self, context: Tensor, continue_mask: Tensor
    ) -> tuple[Tensor, Tensor]:
        return self.heads["continue"](context, continue_mask)

    def forbidden_bypass_audit(self) -> tuple[str, ...]:
        violations: list[str] = []
        names = tuple(name.lower() for name, _ in self.named_modules())
        if self.system.system_id == "B13":
            if self.direct_next_head is not None or any(
                name.startswith("direct_next") for name in names
            ):
                violations.append("B13 exposes a NextHead-like module")
            if self.system.oracle_patch:
                violations.append("B13 is configured with an oracle patch")
            if self.repair_reads_raw_context:
                violations.append("B13 repair reads raw context")
        if self.system.system_id == "B11" and self.system.gap_reaches_downstream:
            violations.append("B11 allows gap information downstream")
        return tuple(violations)


def trainable_parameter_count(model: nn.Module) -> int:
    return sum(parameter.numel() for parameter in model.parameters() if parameter.requires_grad)
