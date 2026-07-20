"""Independent semantic verification of reified traces."""

from __future__ import annotations

import dataclasses
from typing import Any

from .canonical import content_sha256
from .contracts import (
    ActiveDomain,
    CertifiedRepairStep,
    Decision,
    DecisionKind,
    Episode,
    EpisodeTrace,
    RepairRecord,
)
from .reference_agent import action_conflict_pairs
from .interventions import INTERVENTIONS


class VerificationError(ValueError):
    def __init__(self, code: str, path: str, message: str) -> None:
        super().__init__(f"{code} at {path}: {message}")
        self.code = code
        self.path = path
        self.message = message


def _tuple_strings(value: Any, path: str) -> tuple[str, ...]:
    if not isinstance(value, (list, tuple)) or not all(
        isinstance(item, str) for item in value
    ):
        raise VerificationError("TYPE", path, "expected a string array")
    return tuple(value)


def trace_from_payload(payload: dict[str, Any]) -> EpisodeTrace:
    try:
        steps: list[CertifiedRepairStep] = []
        for step_index, raw_step in enumerate(payload["steps"]):
            decisions: list[Decision] = []
            for decision_index, raw in enumerate(raw_step["decisions"]):
                path = f"steps[{step_index}].decisions[{decision_index}]"
                decisions.append(
                    Decision(
                        kind=DecisionKind(raw["kind"]),
                        selected_id=str(raw["selected_id"]),
                        catalog=_tuple_strings(raw["catalog"], path + ".catalog"),
                        allowed_mask=tuple(bool(item) for item in raw["allowed_mask"]),
                        logits_micros=tuple(int(item) for item in raw["logits_micros"]),
                        provenance=_tuple_strings(raw["provenance"], path + ".provenance"),
                    )
                )
            raw_repair = raw_step["repair"]
            repair = RepairRecord(
                repair_id=str(raw_repair["repair_id"]),
                query_id=str(raw_repair["query_id"]),
                response_id=str(raw_repair["response_id"]),
                fiber_before=_tuple_strings(raw_repair["fiber_before"], "repair.fiber_before"),
                fiber_after=_tuple_strings(raw_repair["fiber_after"], "repair.fiber_after"),
                retained_closures=_tuple_strings(raw_repair["retained_closures"], "repair.retained_closures"),
                provenance=_tuple_strings(raw_repair["provenance"], "repair.provenance"),
            )
            steps.append(
                CertifiedRepairStep(
                    step_index=int(raw_step["step_index"]),
                    fiber_before=_tuple_strings(raw_step["fiber_before"], "step.fiber_before"),
                    decisions=tuple(decisions),
                    query_id=str(raw_step["query_id"]),
                    response_id=str(raw_step["response_id"]),
                    repair=repair,
                    fiber_after=_tuple_strings(raw_step["fiber_after"], "step.fiber_after"),
                    memory_before=_tuple_strings(raw_step["memory_before"], "step.memory_before"),
                    memory_after=_tuple_strings(raw_step["memory_after"], "step.memory_after"),
                    predicted_action_after=(
                        None
                        if raw_step["predicted_action_after"] is None
                        else str(raw_step["predicted_action_after"])
                    ),
                    action_sufficient_after=bool(raw_step["action_sufficient_after"]),
                    transition_derived_from_repair=bool(raw_step["transition_derived_from_repair"]),
                )
            )
        return EpisodeTrace(
            schema_version=str(payload["schema_version"]),
            episode_id=str(payload["episode_id"]),
            system_id=str(payload["system_id"]),
            seed=int(payload["seed"]),
            observation_hash=str(payload["observation_hash"]),
            actual_world_id=str(payload["actual_world_id"]),
            initial_fiber=_tuple_strings(payload["initial_fiber"], "initial_fiber"),
            steps=tuple(steps),
            final_fiber=_tuple_strings(payload["final_fiber"], "final_fiber"),
            required_action=str(payload["required_action"]),
            predicted_action=str(payload["predicted_action"]),
            intervention_id=(
                None if payload["intervention_id"] is None else str(payload["intervention_id"])
            ),
            closed=bool(payload["closed"]),
        )
    except VerificationError:
        raise
    except (KeyError, TypeError, ValueError) as error:
        raise VerificationError("DECODE", "$", str(error)) from error


def verify_trace(
    trace: EpisodeTrace,
    episode: Episode,
    domain: ActiveDomain,
) -> None:
    try:
        trace.validate()
    except ValueError as error:
        raise VerificationError("STRUCTURE", "$", str(error)) from error
    if trace.episode_id != episode.episode_id:
        raise VerificationError("EPISODE", "episode_id", "trace is bound to another episode")
    actual = episode.actual_world()
    if trace.actual_world_id != actual.world_id:
        raise VerificationError("REAL_WORLD", "actual_world_id", "wrong actual world")
    if trace.observation_hash != content_sha256(actual.public_observation):
        raise VerificationError("OBSERVATION_HASH", "observation_hash", "hash mismatch")
    expected_fiber = domain.initial_fiber(episode)
    if trace.initial_fiber != expected_fiber:
        raise VerificationError("FIBER", "initial_fiber", "not the exact visible fiber")
    expected_kinds = tuple(DecisionKind)
    intervened_target = (
        INTERVENTIONS[trace.intervention_id].target
        if trace.intervention_id in INTERVENTIONS
        else None
    )
    for index, step in enumerate(trace.steps):
        path = f"steps[{index}]"
        if tuple(decision.kind for decision in step.decisions) != expected_kinds:
            raise VerificationError("DECISION_ORDER", path + ".decisions", "incomplete causal chain")
        for decision_index, decision in enumerate(step.decisions):
            if not decision.provenance:
                raise VerificationError(
                    "PROVENANCE", f"{path}.decisions[{decision_index}].provenance", "empty provenance"
                )
            allowed_logits = [
                (logit, catalog_index)
                for catalog_index, (logit, allowed) in enumerate(
                    zip(decision.logits_micros, decision.allowed_mask)
                )
                if allowed
            ]
            expected_index = max(allowed_logits, key=lambda item: (item[0], -item[1]))[1]
            decision_target = "gap" if decision.kind is DecisionKind.DETECT else decision.kind.value
            if (
                decision.catalog[expected_index] != decision.selected_id
                and decision_target != intervened_target
            ):
                raise VerificationError(
                    "ARGMAX", f"{path}.decisions[{decision_index}]", "selected id is not canonical argmax"
                )
        query_decision = step.decisions[4]
        repair_decision = step.decisions[5]
        if query_decision.selected_id != step.query_id:
            raise VerificationError("QUERY", path + ".query_id", "query decision mismatch")
        if repair_decision.selected_id != step.repair.repair_id:
            raise VerificationError("REPAIR", path + ".repair_id", "repair decision mismatch")
        try:
            expected_response = domain.answer(
                episode, episode.actual_world_id, step.query_id
            )
        except (KeyError, ValueError) as error:
            raise VerificationError("QUERY", path + ".query_id", str(error)) from error
        if step.response_id != expected_response:
            raise VerificationError("RESPONSE", path + ".response_id", "wrong domain response")
        posterior = domain.posterior(
            episode, step.fiber_before, step.query_id, step.response_id
        )
        if step.fiber_after != posterior:
            raise VerificationError("POSTERIOR", path + ".fiber_after", "not the exact posterior")
        if actual.world_id not in set(step.fiber_after):
            raise VerificationError("REAL_WORLD", path + ".fiber_after", "real world was removed")
        if action_conflict_pairs(episode, step.fiber_after) >= action_conflict_pairs(
            episode, step.fiber_before
        ):
            raise VerificationError("PROGRESS", path + ".fiber_after", "action conflict did not decrease")
        sufficient = domain.action_sufficient(episode, step.fiber_after)
        if step.action_sufficient_after != sufficient:
            raise VerificationError("SUFFICIENCY", path, "sufficiency flag mismatch")
        expected_retained = tuple(f"step:{prior}" for prior in range(index))
        if step.repair.retained_closures != expected_retained:
            raise VerificationError("RETENTION", path + ".repair", "prior closures were not retained")
        required_memory = {
            step.query_id,
            step.response_id,
            episode.episode_id,
            actual.world_id,
        }
        if not required_memory <= set(step.memory_after):
            raise VerificationError("MEMORY", path + ".memory_after", "causal provenance was forgotten")
        expected_fiber = step.fiber_after
    if trace.final_fiber != expected_fiber:
        raise VerificationError("FINAL_FIBER", "final_fiber", "final posterior mismatch")
    if not domain.action_sufficient(episode, trace.final_fiber):
        raise VerificationError("NOT_CLOSED", "final_fiber", "final fiber is action-ambiguous")
    if trace.required_action != actual.required_action:
        raise VerificationError("TARGET", "required_action", "wrong real-world target")
    possible = {
        world.required_action
        for world in episode.worlds
        if world.world_id in set(trace.final_fiber)
    }
    if possible != {trace.predicted_action}:
        raise VerificationError("CONTINUATION", "predicted_action", "not induced by final fiber")


def verify_payload(payload: dict[str, Any], episode: Episode, domain: ActiveDomain) -> None:
    trace = trace_from_payload(payload)
    verify_trace(trace, episode, domain)


def payload_from_trace(trace: EpisodeTrace) -> dict[str, Any]:
    return dataclasses.asdict(trace)
