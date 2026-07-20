"""One-run trainer with frozen regimes and causal discrete estimator."""

from __future__ import annotations

import dataclasses
import math
import platform
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import torch
from torch import Tensor, nn
from torch.distributions import Categorical

from .baselines import SYSTEMS
from .canonical import content_sha256, sha256_file, write_new_json
from .contracts import ActiveDomain, Episode
from .encoding import BYTE_VOCAB_SIZE, byte_tokens, encode_episode_batch, pad_token_rows
from .models import CATALOG_SIZES, CausalAgent, trainable_parameter_count
from .reference_agent import ExactActiveAgent
from .seeds import derive_seed, torch_seed


Regime = Literal["R_supervised", "R_intermediate", "R_causal"]
RunKind = Literal["tuning", "final", "replication", "smoke"]


@dataclass(frozen=True)
class TrainConfig:
    domain: str
    system: str
    size: str
    regime: Regime
    training_seed: int
    output_directory: str
    data_manifest: str
    maximum_updates: int = 120_000
    batch_size: int = 64
    learning_rate_micros: int = 300
    weight_decay_micros: int = 10_000
    dropout_micros: int = 100_000
    warmup_updates: int = 5_000
    checkpoint_interval: int = 5_000
    device: str = "cuda"
    run_kind: RunKind = "final"

    def validate(self) -> None:
        if self.system not in SYSTEMS:
            raise ValueError("unknown system")
        if self.size not in {"small", "base", "large"}:
            raise ValueError("unknown size")
        if self.regime not in {"R_supervised", "R_intermediate", "R_causal"}:
            raise ValueError("unknown regime")
        if self.maximum_updates <= 0 or self.batch_size <= 0:
            raise ValueError("updates and batch size must be positive")
        if self.learning_rate_micros <= 0:
            raise ValueError("learning rate must be positive")
        if Path(self.output_directory).exists():
            raise FileExistsError("output directory must not already exist")
        if self.run_kind == "tuning":
            if self.training_seed not in {100, 101, 102} or self.maximum_updates != 30_000:
                raise ValueError("tuning runs require seeds 100–102 and 30000 updates")
        elif self.run_kind == "final":
            if self.training_seed not in range(10) or self.maximum_updates != 120_000:
                raise ValueError("final runs require seeds 0–9 and 120000 updates")
            if self.batch_size != 64 or self.device != "cuda":
                raise ValueError("final runs require batch_size=64 and CUDA")
        elif self.run_kind == "replication":
            if self.training_seed not in range(10, 20) or self.maximum_updates != 120_000:
                raise ValueError("replication requires seeds 10–19 and 120000 updates")
            if self.batch_size != 64 or self.device != "cuda":
                raise ValueError("replication runs require batch_size=64 and CUDA")
        elif self.run_kind != "smoke":
            raise ValueError("unknown run kind")
        if self.run_kind != "smoke":
            manifest_path = Path(self.data_manifest)
            if not manifest_path.is_file():
                raise FileNotFoundError("scientific training requires a data manifest file")
            import json

            payload = json.loads(manifest_path.read_text(encoding="utf-8"))
            if payload.get("contains_ood") is not False:
                raise ValueError("training manifest must explicitly exclude OOD records")
            if payload.get("sealed_ood_key_access") is not False:
                raise ValueError("training manifest must explicitly deny OOD-key access")
            if payload.get("structural_disjointness", {}).get("ok") is not True:
                raise ValueError("training manifest lacks a passing disjointness audit")
            expected_counts = {
                "iid_validation": 4096,
                "structural_validation": 4096,
                "iid_test": 8192,
            }
            for domain_name in ("symbolic", "perceptual"):
                domain_splits = payload.get("splits", {}).get(domain_name, {})
                for split_name, expected_count in expected_counts.items():
                    split = domain_splits.get(split_name, {})
                    if split.get("count") != expected_count or split.get("materialized") is not True:
                        raise ValueError(
                            f"training manifest has incomplete {domain_name}/{split_name} commitments"
                        )
                    if len(split.get("episode_commitments", ())) != expected_count:
                        raise ValueError(
                            f"training manifest commitment count mismatch for {domain_name}/{split_name}"
                        )


def leave_one_out_reinforce_loss(log_probs: Tensor, rewards: Tensor) -> Tensor:
    """Unbiased leave-one-out score-function estimator over K samples."""
    if log_probs.shape != rewards.shape or log_probs.ndim != 2:
        raise ValueError("log_probs and rewards must have shape [batch, samples]")
    samples = rewards.shape[1]
    if samples < 2:
        raise ValueError("leave-one-out estimator needs at least two samples")
    baseline = (rewards.sum(dim=1, keepdim=True) - rewards) / (samples - 1)
    advantages = (rewards - baseline).detach()
    return -(advantages * log_probs).mean()


def _masked_logits(logits: Tensor, mask: Tensor) -> Tensor:
    return logits.masked_fill(~mask, torch.finfo(logits.dtype).min)


def _typed_masks(episodes: list[Episode], device: torch.device) -> dict[str, Tensor]:
    batch = len(episodes)
    masks = {
        name: torch.zeros(batch, size, dtype=torch.bool, device=device)
        for name, size in CATALOG_SIZES.items()
    }
    for row, episode in enumerate(episodes):
        masks["gap"][row, :2] = True
        masks["use"][row, :2] = True
        masks["transport"][row, :2] = True
        masks["query"][row, : len(episode.query_catalog)] = True
        masks["repair"][row, : len(episode.repair_catalog)] = True
        masks["continue"][row, : len(episode.action_catalog) + 1] = True
    return masks


def _oracle_targets(
    domain: ActiveDomain, episodes: list[Episode], device: torch.device
) -> tuple[dict[str, Tensor], Tensor]:
    exact = ExactActiveAgent()
    query_targets: list[int] = []
    repair_targets: list[int] = []
    continue_targets: list[int] = []
    response_rows: list[tuple[int, ...]] = []
    for episode in episodes:
        fiber = domain.initial_fiber(episode)
        query, _ = exact.choose_query(domain, episode, fiber)
        query_targets.append(episode.query_catalog.index(query))
        response = domain.answer(episode, episode.actual_world_id, query)
        response_rows.append(byte_tokens({"query": query, "response": response}))
        required = episode.actual_world().required_action
        repair_targets.append(episode.repair_catalog.index(required))
        continue_targets.append(1 + episode.action_catalog.index(required))
    targets = {
        "gap": torch.ones(len(episodes), dtype=torch.long, device=device),
        "use": torch.ones(len(episodes), dtype=torch.long, device=device),
        "transport": torch.ones(len(episodes), dtype=torch.long, device=device),
        "query": torch.tensor(query_targets, dtype=torch.long, device=device),
        "repair": torch.tensor(repair_targets, dtype=torch.long, device=device),
        "continue": torch.tensor(continue_targets, dtype=torch.long, device=device),
    }
    return targets, pad_token_rows(response_rows).to(device)


def _supervised_step(
    model: CausalAgent,
    domain: ActiveDomain,
    episodes: list[Episode],
    regime: Regime,
    device: torch.device,
) -> tuple[Tensor, dict[str, int]]:
    encoded = encode_episode_batch(domain, episodes)
    observation = encoded.observation.to(device)
    candidate = encoded.candidate.to(device)
    history = encoded.history.to(device)
    context = model.encode_public(
        observation, candidate, history, symbolic=encoded.symbolic
    )
    masks = _typed_masks(episodes, device)
    targets, responses = _oracle_targets(domain, episodes, device)
    if "query" not in model.system.allowed_actions:
        passive_logits, passive_selected = model.decide_passive(
            context, masks["continue"]
        )
        if regime == "R_supervised":
            loss = nn.functional.cross_entropy(
                _masked_logits(passive_logits, masks["continue"]),
                targets["continue"],
            )
        else:
            distribution = Categorical(
                logits=_masked_logits(passive_logits, masks["continue"])
            )
            samples = distribution.sample((4,)).transpose(0, 1)
            rewards = (samples == targets["continue"][:, None]).to(torch.float32)
            log_probs = distribution.log_prob(samples.transpose(0, 1)).transpose(0, 1)
            loss = leave_one_out_reinforce_loss(log_probs, rewards)
        return loss, {
            "query_correct": 0,
            "repair_correct": int(
                (passive_selected == targets["continue"]).sum().item()
            ),
            "batch": len(episodes),
        }
    pre = model.decide_pre_response(context, masks)
    selected_pre = {name: value[1] for name, value in pre.items()}
    post = model.decide_post_response(context, selected_pre, responses, masks)
    losses: list[Tensor] = []
    if regime == "R_supervised":
        for name in ("gap", "use", "transport", "query"):
            if name in model.system.allowed_actions:
                losses.append(
                    nn.functional.cross_entropy(
                        _masked_logits(pre[name][0], masks[name]), targets[name]
                    )
                )
        if "repair" in model.system.allowed_actions and not model.system.oracle_patch:
            losses.append(
                nn.functional.cross_entropy(
                    _masked_logits(post["repair"][0], masks["repair"]),
                    targets["repair"],
                )
            )
        losses.append(
            0.5
            * nn.functional.cross_entropy(
                _masked_logits(post["continue"][0], masks["continue"]),
                targets["continue"],
            )
        )
    elif regime == "R_intermediate":
        for name in ("gap", "use", "transport"):
            if name in model.system.allowed_actions:
                losses.append(
                    nn.functional.cross_entropy(
                        _masked_logits(pre[name][0], masks[name]), targets[name]
                    )
                )
        losses.append(
            _causal_discrete_loss(model, domain, episodes, context, pre, masks, targets)
        )
    else:
        losses.append(
            _causal_discrete_loss(model, domain, episodes, context, pre, masks, targets)
        )
    loss = torch.stack(losses).sum()
    correct = {
        "query_correct": int((pre["query"][1] == targets["query"]).sum().item()),
        "repair_correct": int((post["repair"][1] == targets["repair"]).sum().item()),
        "batch": len(episodes),
    }
    return loss, correct


def _causal_discrete_loss(
    model: CausalAgent,
    domain: ActiveDomain,
    episodes: list[Episode],
    context: Tensor,
    pre: dict[str, tuple[Tensor, Tensor]],
    masks: dict[str, Tensor],
    targets: dict[str, Tensor],
    samples: int = 4,
) -> Tensor:
    """Sample the actual query-response-repair path without oracle labels."""
    query_distribution = Categorical(
        logits=_masked_logits(pre["query"][0], masks["query"])
    )
    sampled_queries = query_distribution.sample((samples,))
    expanded_context = context.repeat(samples, 1)
    expanded_masks = {
        name: mask.repeat(samples, 1) for name, mask in masks.items()
    }
    selected_pre = {
        name: selected.repeat(samples)
        for name, (_, selected) in pre.items()
        if name != "query"
    }
    selected_pre["query"] = sampled_queries.reshape(-1)
    response_rows: list[tuple[int, ...]] = []
    for sample_index in range(samples):
        for episode_index, episode in enumerate(episodes):
            query_index = int(sampled_queries[sample_index, episode_index])
            query_id = episode.query_catalog[query_index]
            response = domain.answer(episode, episode.actual_world_id, query_id)
            response_rows.append(byte_tokens({"query": query_id, "response": response}))
    responses = pad_token_rows(response_rows).to(context.device)
    post = model.decide_post_response(
        expanded_context, selected_pre, responses, expanded_masks
    )
    repair_distribution = Categorical(
        logits=_masked_logits(post["repair"][0], expanded_masks["repair"])
    )
    continue_distribution = Categorical(
        logits=_masked_logits(post["continue"][0], expanded_masks["continue"])
    )
    sampled_repairs = repair_distribution.sample()
    sampled_continuations = continue_distribution.sample()
    repair_targets = targets["repair"].repeat(samples)
    continue_targets = targets["continue"].repeat(samples)
    if model.system.oracle_patch:
        repair_success = torch.ones_like(sampled_repairs, dtype=torch.bool)
    elif model.system.direct_next_head:
        repair_success = torch.ones_like(sampled_repairs, dtype=torch.bool)
    else:
        repair_success = sampled_repairs == repair_targets
    closed = (repair_success & (sampled_continuations == continue_targets)).to(torch.float32)
    query_cost = torch.full_like(closed, 1_000 / 16_000)
    rewards = (closed - 0.5 * query_cost).reshape(samples, len(episodes)).transpose(0, 1)
    query_log_prob = query_distribution.log_prob(sampled_queries)
    path_log_prob = query_log_prob
    if not model.system.oracle_patch and not model.system.direct_next_head:
        path_log_prob += repair_distribution.log_prob(sampled_repairs).reshape(
            samples, len(episodes)
        )
    path_log_prob += continue_distribution.log_prob(sampled_continuations).reshape(
        samples, len(episodes)
    )
    return leave_one_out_reinforce_loss(path_log_prob.transpose(0, 1), rewards)


def _learning_rate(config: TrainConfig, update: int) -> float:
    peak = config.learning_rate_micros / 1_000_000
    if update < config.warmup_updates:
        return peak * (update + 1) / max(1, config.warmup_updates)
    progress = (update - config.warmup_updates) / max(
        1, config.maximum_updates - config.warmup_updates
    )
    return peak * (0.1 + 0.9 * 0.5 * (1 + math.cos(math.pi * progress)))


def train_one_run(config: TrainConfig, domain: ActiveDomain) -> dict[str, object]:
    config.validate()
    output = Path(config.output_directory)
    output.mkdir(parents=True, exist_ok=False)
    device = torch.device(config.device)
    if device.type == "cuda" and not torch.cuda.is_available():
        raise RuntimeError("CUDA requested by the run contract but unavailable")
    seed = torch_seed(config.training_seed, "model-init")
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)
    torch.use_deterministic_algorithms(True)
    model = CausalAgent(
        size=config.size,
        vocab_size=BYTE_VOCAB_SIZE,
        dropout=config.dropout_micros / 1_000_000,
        system_id=config.system,
    ).to(device)
    optimizer = torch.optim.AdamW(
        model.parameters(),
        lr=config.learning_rate_micros / 1_000_000,
        betas=(0.9, 0.95),
        weight_decay=config.weight_decay_micros / 1_000_000,
    )
    metrics: list[dict[str, int]] = []
    for update in range(config.maximum_updates):
        episodes = [
            domain.generate_episode(
                derive_seed(config.training_seed, "training-episode", update * config.batch_size + item),
                actual_index=(update * config.batch_size + item) % 32,
            )
            for item in range(config.batch_size)
        ]
        optimizer.param_groups[0]["lr"] = _learning_rate(config, update)
        optimizer.zero_grad(set_to_none=True)
        loss, counts = _supervised_step(
            model, domain, episodes, config.regime, device
        )
        loss.backward()
        nn.utils.clip_grad_norm_(model.parameters(), 1.0)
        optimizer.step()
        metrics.append(
            {
                "update": update + 1,
                "loss_micros": int(round(float(loss.detach().cpu()) * 1_000_000)),
                **counts,
            }
        )
        if (update + 1) % config.checkpoint_interval == 0:
            torch.save(
                {
                    "schema": "v23-resumable-checkpoint-1",
                    "update": update + 1,
                    "model": model.state_dict(),
                    "optimizer": optimizer.state_dict(),
                    "torch_rng_state": torch.get_rng_state(),
                    "cuda_rng_state_all": (
                        torch.cuda.get_rng_state_all() if torch.cuda.is_available() else ()
                    ),
                },
                output / f"checkpoint_{update + 1:06d}.pt",
            )
    final_checkpoint = output / "checkpoint_final.pt"
    torch.save(model.state_dict(), final_checkpoint)
    manifest = {
        "schema": "v23-train-run-1",
        "config": dataclasses.asdict(config),
        "config_sha256": content_sha256(dataclasses.asdict(config)),
        "data_manifest_sha256": (
            None if config.run_kind == "smoke" else sha256_file(config.data_manifest)
        ),
        "python": sys.version,
        "platform": platform.platform(),
        "torch": torch.__version__,
        "cuda_available": torch.cuda.is_available(),
        "parameters": trainable_parameter_count(model),
        "forbidden_bypass_violations": model.forbidden_bypass_audit(),
        "protocol_coverage_complete": config.run_kind in {"final", "replication"}
        and config.maximum_updates == 120_000
        and config.batch_size == 64
        and config.training_seed in (
            range(10) if config.run_kind == "final" else range(10, 20)
        )
        and config.warmup_updates == 5_000
        and config.checkpoint_interval == 5_000
        and config.device == "cuda",
        "metrics": metrics,
        "final_checkpoint": final_checkpoint.name,
    }
    write_new_json(output / "run_manifest.json", manifest)
    return manifest
