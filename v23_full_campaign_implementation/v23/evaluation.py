"""Checkpoint evaluation with complete learned causal traces."""

from __future__ import annotations

import dataclasses
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import torch

from .canonical import content_sha256, sha256_file, write_new_json
from .contracts import (
    ActiveDomain,
    CertifiedRepairStep,
    Decision,
    DecisionKind,
    Episode,
    EpisodeTrace,
    RepairRecord,
)
from .encoding import BYTE_VOCAB_SIZE, byte_tokens, encode_episode_batch, pad_token_rows
from .models import CATALOG_SIZES, CausalAgent
from .seeds import derive_seed
from .splits import OOD_FAMILIES, make_ood_episode
from .traces import write_trace_jsonl
from .verification import VerificationError, verify_trace


@dataclass(frozen=True)
class EvaluationConfig:
    checkpoint: str
    training_manifest: str
    domain: str
    system: str
    size: str
    seed: int
    episodes: int
    maximum_steps: int
    output_directory: str
    split: str = "iid_test"
    device: str = "cpu"


def _masks(episode: Episode, used_queries: set[str], device: torch.device) -> dict[str, torch.Tensor]:
    masks = {
        name: torch.zeros(1, size, dtype=torch.bool, device=device)
        for name, size in CATALOG_SIZES.items()
    }
    masks["gap"][0, :2] = True
    masks["use"][0, :2] = True
    masks["transport"][0, :2] = True
    for index, query in enumerate(episode.query_catalog):
        masks["query"][0, index] = query not in used_queries
    masks["repair"][0, : len(episode.repair_catalog)] = True
    masks["continue"][0, : len(episode.action_catalog) + 1] = True
    return masks


def _micros(logits: torch.Tensor, width: int) -> tuple[int, ...]:
    values = logits.detach().cpu()[0, :width].tolist()
    return tuple(int(round(float(value) * 1_000_000)) for value in values)


def _learned_decision(
    kind: DecisionKind,
    selected_index: int,
    catalog: tuple[str, ...],
    logits: torch.Tensor,
    provenance: tuple[str, ...],
) -> Decision:
    decision = Decision(
        kind=kind,
        selected_id=catalog[selected_index],
        catalog=catalog,
        allowed_mask=tuple(True for _ in catalog),
        logits_micros=_micros(logits, len(catalog)),
        provenance=provenance,
    )
    decision.validate()
    return decision


def evaluate_model_episode(
    model: CausalAgent,
    domain: ActiveDomain,
    episode: Episode,
    seed: int,
    maximum_steps: int,
    device: torch.device,
    intervention_id: str | None = None,
) -> tuple[EpisodeTrace | None, dict[str, Any]]:
    actual = episode.actual_world()
    encoded = encode_episode_batch(domain, [episode])
    fiber = domain.initial_fiber(episode)
    initial_fiber = fiber
    memory: tuple[str, ...] = ()
    used_queries: set[str] = set()
    steps: list[CertifiedRepairStep] = []
    final_prediction = "defer"
    if "query" not in model.system.allowed_actions:
        context = model.encode_public(
            encoded.observation.to(device),
            encoded.candidate.to(device),
            encoded.history.to(device),
            encoded.symbolic,
        )
        continue_mask = torch.zeros(
            1, CATALOG_SIZES["continue"], dtype=torch.bool, device=device
        )
        continue_mask[0, 1 : len(episode.action_catalog) + 1] = True
        logits, selected = model.decide_passive(context, continue_mask)
        index = int(selected.item())
        final_prediction = episode.action_catalog[index - 1]
        return None, {
            "episode_id": episode.episode_id,
            "required_action": actual.required_action,
            "predicted_action": final_prediction,
            "closed": final_prediction == actual.required_action,
            "certified": False,
            "reason": "passive system has no repair episode",
            "continue_logits_micros": _micros(logits[:, 1:], len(episode.action_catalog)),
        }
    for step_index in range(maximum_steps):
        if domain.action_sufficient(episode, fiber):
            break
        if len(used_queries) == len(episode.query_catalog):
            break
        effective_memory = () if intervention_id == "I_history_drop" else memory
        history = pad_token_rows([byte_tokens({"memory": effective_memory})]).to(device)
        context = model.encode_public(
            encoded.observation.to(device),
            encoded.candidate.to(device),
            history,
            encoded.symbolic,
        )
        masks = _masks(episode, used_queries, device)
        pre = model.decide_pre_response(
            context,
            masks,
            intervention_id=intervention_id,
            intervention_seed=seed + step_index,
        )
        query_index = int(pre["query"][1].item())
        query_id = episode.query_catalog[query_index]
        used_queries.add(query_id)
        response_id = domain.answer(episode, actual.world_id, query_id)
        if intervention_id == "I_response_neutral":
            response_id = "typed-neutral-response"
        elif intervention_id == "I_response_cross":
            crossed = next(
                (
                    world_id
                    for world_id in fiber
                    if world_id != actual.world_id
                    and domain.answer(episode, world_id, query_id) != response_id
                ),
                next((world_id for world_id in fiber if world_id != actual.world_id), actual.world_id),
            )
            response_id = domain.answer(episode, crossed, query_id)
        response_tokens = pad_token_rows(
            [byte_tokens({"query": query_id, "response": response_id})]
        ).to(device)
        selected_pre = {name: output[1] for name, output in pre.items()}
        post = model.decide_post_response(
            context,
            selected_pre,
            response_tokens,
            masks,
            intervention_id=intervention_id,
            intervention_seed=seed + step_index,
        )
        if bool(post["typed_refusal"][0].item()):
            return None, {
                "episode_id": episode.episode_id,
                "required_action": actual.required_action,
                "predicted_action": "typed_refusal",
                "closed": False,
                "certified": False,
                "typed_refusal": True,
                "reason": "direct next bypass refused",
                "intervention_id": intervention_id,
            }
        repair_index = int(post["repair"][1].item())
        continue_index = int(post["continue"][1].item())
        if model.system.oracle_patch:
            repair_index = episode.repair_catalog.index(actual.required_action)
        repair_id = episode.repair_catalog[repair_index]
        final_prediction = (
            "defer"
            if continue_index == 0
            else episode.action_catalog[continue_index - 1]
        )
        fiber_after = domain.posterior(
            episode, fiber, query_id, response_id
        )
        provenance = (episode.episode_id, actual.world_id, query_id, response_id)
        memory_after = memory + tuple(
            item for item in provenance if item not in set(memory)
        )
        gap_catalog = ("closed", "action_conflict")
        use_catalog = ("visible_state", "query_response")
        transport_catalog = ("none", "authorized_query")
        repair_catalog = episode.repair_catalog
        continue_catalog = ("defer",) + episode.action_catalog
        decisions = (
            _learned_decision(DecisionKind.DETECT, int(pre["gap"][1]), gap_catalog, pre["gap"][0], ("public-context",)),
            _learned_decision(DecisionKind.GAP, int(pre["gap"][1]), gap_catalog, pre["gap"][0], ("public-context",)),
            _learned_decision(DecisionKind.USE, int(pre["use"][1]), use_catalog, pre["use"][0], ("selected-gap",)),
            _learned_decision(DecisionKind.TRANSPORT, int(pre["transport"][1]), transport_catalog, pre["transport"][0], ("selected-use",)),
            _learned_decision(DecisionKind.QUERY, query_index, episode.query_catalog, pre["query"][0], ("selected-transport",)),
            _learned_decision(DecisionKind.REPAIR, repair_index, repair_catalog, post["repair"][0], (query_id, response_id)),
            _learned_decision(DecisionKind.CONTINUE, continue_index, continue_catalog, post["continue"][0], ("executed-repair", repair_id)),
        )
        record = RepairRecord(
            repair_id=repair_id,
            query_id=query_id,
            response_id=response_id,
            fiber_before=tuple(fiber),
            fiber_after=tuple(fiber_after),
            retained_closures=tuple(f"step:{index}" for index in range(step_index)),
            provenance=(query_id, response_id, episode.episode_id, actual.world_id),
        )
        steps.append(
            CertifiedRepairStep(
                step_index=step_index,
                fiber_before=tuple(fiber),
                decisions=decisions,
                query_id=query_id,
                response_id=response_id,
                repair=record,
                fiber_after=tuple(fiber_after),
                memory_before=memory,
                memory_after=memory_after,
                predicted_action_after=final_prediction,
                action_sufficient_after=domain.action_sufficient(episode, fiber_after),
                transition_derived_from_repair=not model.system.direct_next_head,
            )
        )
        fiber = tuple(fiber_after)
        memory = memory_after
    if model.system.direct_next_head:
        return None, {
            "episode_id": episode.episode_id,
            "required_action": actual.required_action,
            "predicted_action": final_prediction,
            "closed": final_prediction == actual.required_action,
            "certified": False,
            "reason": "B12 direct-next bypass is diagnostic-only",
        }
    trace = EpisodeTrace(
        schema_version="v23.1",
        episode_id=episode.episode_id,
        system_id=model.system.system_id,
        seed=seed,
        observation_hash=content_sha256(actual.public_observation),
        actual_world_id=actual.world_id,
        initial_fiber=tuple(initial_fiber),
        steps=tuple(steps),
        final_fiber=tuple(fiber),
        required_action=actual.required_action,
        predicted_action=final_prediction,
            intervention_id=intervention_id,
        closed=final_prediction == actual.required_action,
    )
    structural = True
    error: str | None = None
    try:
        trace.validate()
        verify_trace(trace, episode, domain)
        certified = True
    except (ValueError, VerificationError) as caught:
        structural = False
        certified = False
        error = str(caught)
    return trace, {
        "episode_id": episode.episode_id,
        "required_action": actual.required_action,
        "predicted_action": final_prediction,
        "closed": trace.closed,
        "certified": certified,
        "structural": structural,
        "verification_error": error,
        "steps": len(steps),
        "queries": len(used_queries),
    }


def evaluate_checkpoint(config: EvaluationConfig, domain: ActiveDomain) -> dict[str, Any]:
    output = Path(config.output_directory)
    output.mkdir(parents=True, exist_ok=False)
    device = torch.device(config.device)
    model = CausalAgent(
        size=config.size,
        vocab_size=BYTE_VOCAB_SIZE,
        system_id=config.system,
        dropout=0.0,
    ).to(device)
    state = torch.load(config.checkpoint, map_location=device, weights_only=True)
    model.load_state_dict(state)
    model.eval()
    outcomes: list[dict[str, Any]] = []
    traces: list[EpisodeTrace] = []
    with torch.no_grad():
        for index in range(config.episodes):
            episode_seed = derive_seed(config.seed, "evaluation-episode", index)
            episode = domain.generate_episode(episode_seed, actual_index=index % 32)
            if config.split in OOD_FAMILIES:
                episode = make_ood_episode(domain, episode, config.split)
            elif config.split != "iid_test":
                raise ValueError(f"unknown evaluation split {config.split}")
            trace, outcome = evaluate_model_episode(
                model, domain, episode, episode_seed, config.maximum_steps, device
            )
            outcomes.append(outcome)
            if trace is not None and outcome.get("structural"):
                traces.append(trace)
    if traces:
        trace_hash = write_trace_jsonl(output / "learned_traces.jsonl", traces)
    else:
        trace_hash = None
    report = {
        "schema": "v23-evaluation-1",
        "config": dataclasses.asdict(config),
        "checkpoint_sha256": sha256_file(config.checkpoint),
        "training_manifest_sha256": sha256_file(config.training_manifest),
        "episodes": len(outcomes),
        "closed": sum(bool(outcome["closed"]) for outcome in outcomes),
        "certified_closed": sum(
            bool(outcome["closed"] and outcome["certified"]) for outcome in outcomes
        ),
        "trace_sha256": trace_hash,
        "protocol_coverage_complete": config.episodes == 8192
        and config.seed in range(10)
        and config.split in ("iid_test",) + OOD_FAMILIES,
        "outcomes": outcomes,
    }
    write_new_json(output / "evaluation_report.json", report)
    return report
