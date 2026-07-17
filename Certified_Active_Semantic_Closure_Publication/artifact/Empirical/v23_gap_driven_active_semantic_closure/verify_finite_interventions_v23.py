#!/usr/bin/env python3
"""Independent semantic verifier for the complete finite intervention matrix."""

from __future__ import annotations

from typing import Any, Mapping

from environment_v23 import require, require_equal, typed
from finite_reference_domain_v23 import (
    AgentState,
    Index,
    Knowledge,
    KnowledgeKind,
    Observation,
    PrivateFiniteManifest,
    ReadingFocus,
    RepairRecord,
    ResponseKind,
    UseDirection,
    Value,
    index_typed,
    serialize_agent_state,
    serialize_gap,
    serialize_gap_evidence,
)
from trace_schema_v23 import (
    INTERVENTION_KINDS,
    OPEN_CAUSAL_FIELDS,
    canonical_sha256,
    validate_trace_record,
)
from verify_finite_reference_v23 import (
    _advance,
    _decode_agent,
    _detect,
    _detect_at,
    _fiber,
    _fiber_commitments,
    _initial_agent,
    _known_prefix,
    _persistence,
    _verify_agent_manifest,
    _world_compatible,
)


REFUSAL_STAGE = {
    "I_gap_suppress": "gap",
    "I_use_suppress": "use",
    "I_transport_suppress": "transport",
    "I_query_neutral": "query",
    "I_response_neutral": "response",
    "I_repair_neutral": "repair",
    "I_repair_permute": "repair",
    "I_next_bypass": "next",
    "I_order_swap": "transport",
    "I_unused_gap": "use",
}

STAGE_PREFIX = {
    "gap": 0,
    "use": 2,
    "transport": 3,
    "query": 4,
    "response": 6,
    "repair": 8,
    "next": len(OPEN_CAUSAL_FIELDS),
}


def _agent_typed(agent: AgentState) -> dict[str, Any]:
    return typed("finite.AgentState", **serialize_agent_state(agent))


def _chain(
    before: AgentState,
    gap: Any,
    direction: UseDirection,
    focus: ReadingFocus,
    query_kind: str,
    response_kind: ResponseKind,
    response_value: Value,
) -> tuple[dict[str, Any], AgentState]:
    use = {
        "direction": direction.value,
        "gapKind": gap.kind.value,
        "gapIndex": gap.index.value,
    }
    transport = {
        "reading": {
            "index": gap.index.value,
            "direction": direction.value,
            "focus": focus.value,
        },
        "output": {"requestedIndex": gap.index.value, "informative": True},
        "evidence": {"direction": direction.value, "reachesGap": True},
    }
    response_constructor = response_kind.value
    query = {"constructor": query_kind, "index": gap.index.value}
    response = {
        "constructor": response_constructor,
        "index": gap.index.value,
        "value": response_value.value,
    }
    changed = True
    repair = {
        "causalIndex": gap.index.value,
        "candidatePatch": {
            "constructor": "set",
            "index": gap.index.value,
            "value": response_value.value,
        },
        "observationUpdate": {
            "constructor": response_constructor,
            "index": gap.index.value,
            "value": response_value.value,
        },
        "historyRecord": {
            "index": gap.index.value,
            "answer": response_value.value,
            "changedCandidate": changed,
        },
        "recordedDirection": direction.value,
        "transportIndex": gap.index.value,
    }
    after = AgentState(
        before.candidate.set(gap.index, response_value),
        before.observation.set_exact(gap.index, response_value),
        before.history + (RepairRecord(gap.index, response_value, True),),
    )
    fields = {
        "gap": typed("finite.OperationalGap", **serialize_gap(gap)),
        "gap_evidence": typed(
            "finite.GapEvidence", **serialize_gap_evidence(gap.evidence)
        ),
        "authorized_use": typed("finite.GapAuthorizedUse", **use),
        "authorized_transport": typed("finite.GapAuthorizedTransport", **transport),
        "query": typed("finite.Query", **query),
        "query_footprint": {
            "requested_index": index_typed(gap.index),
            "query_count": 1,
            "serialized_bits": 2,
        },
        "response": typed("finite.Response", **response),
        "response_footprint": {
            "requested_index": index_typed(gap.index),
            "actual_bits": 2,
            "max_bits": 2,
        },
        "intrinsic_repair": typed("finite.IntrinsicRepair", **repair),
    }
    return fields, after


def _payload(kind: str) -> dict[str, Any]:
    if kind in REFUSAL_STAGE:
        details: dict[str, Any] = {
            "I_gap_suppress": {"operation": "suppressOpenGap"},
            "I_use_suppress": {"operation": "suppressAuthorizedUse"},
            "I_transport_suppress": {"operation": "suppressAuthorizedTransport"},
            "I_query_neutral": {
                "proposedQuery": {"constructor": "noInformation", "index": "first"}
            },
            "I_response_neutral": {
                "proposedResponse": {"constructor": "noInformation", "index": "first"}
            },
            "I_repair_neutral": {
                "proposedPatch": {"constructor": "keep", "index": None, "value": None}
            },
            "I_repair_permute": {
                "proposedPatch": {"constructor": "set", "index": "first", "value": "blue"}
            },
            "I_next_bypass": {"operation": "reuseStateBeforeWithoutRepair"},
            "I_order_swap": {"proposedOrder": ["second", "first"]},
            "I_unused_gap": {"operation": "hideComputedGapFromDownstream"},
        }[kind]
        return typed("finite.InterventionAttempt", constructor=kind, **details)
    if kind == "I_projection":
        return typed(
            "finite.ProjectionReplacement",
            observation={
                "first": {"kind": "excludes", "value": "red"},
                "second": {"kind": "exact", "value": "green"},
                "third": {"kind": "unknown", "value": None},
            },
            actualWorldCompatible=True,
        )
    if kind in {"I_gap_permute", "I_random_gap"}:
        return typed(
            "finite.GapReplacement",
            index="second" if kind == "I_gap_permute" else "third",
        )
    if kind == "I_use_permute":
        return typed(
            "finite.UseReplacement", direction="inspectWitnessedMismatch"
        )
    if kind == "I_transport_permute":
        return typed("finite.TransportReplacement", focus="evidence")
    if kind == "I_query_alternate":
        return typed("finite.QueryReplacement", constructor="confirm", index="first")
    if kind == "I_response_cross":
        return typed("finite.CrossedResponse", sourceWorldFirst="blue")
    if kind == "I_history_drop":
        return typed("finite.HistoryDrop", droppedPrefixRecords=1)
    raise AssertionError(f"unhandled intervention {kind}")


def _verify_common(
    record: Mapping[str, Any], before: AgentState, manifest: PrivateFiniteManifest
) -> None:
    require_equal(record["state_before"], _agent_typed(before), "intervention_before", "$.state_before")
    _verify_agent_manifest(record, before)
    require_equal(record["compatible_fiber_before"], _fiber_commitments(before, manifest), "intervention_before_fiber", "$.compatible_fiber_before")


def verify_intervention_record(
    value: Mapping[str, Any],
    *,
    manifest: PrivateFiniteManifest,
    natural_records: Mapping[str, Mapping[str, Any]],
) -> str:
    record = validate_trace_record(value)
    kind = record["intervention_kind"]
    require(kind in INTERVENTION_KINDS - {"natural"}, "intervention_kind", "$.intervention_kind", "expected a declared intervention")
    require_equal(record["intervention_payload"], _payload(kind), "intervention_payload", "$.intervention_payload")
    natural_hash = record["natural_trace_hash"]
    require(natural_hash in natural_records, "intervention_unpaired", "$.natural_trace_hash", "paired natural trace is missing")
    natural = natural_records[natural_hash]
    validate_trace_record(natural, require_claimed_validity=True)
    require_equal(natural["world_commitment"], record["world_commitment"], "intervention_world_pair", "$.world_commitment")
    require_equal(natural["checkpoint_sha256"], record["checkpoint_sha256"], "intervention_checkpoint_pair", "$.checkpoint_sha256")
    require_equal(natural["environment_seed"], record["environment_seed"], "intervention_seed_pair", "$.environment_seed")

    world = manifest.commitment_map()[record["world_commitment"]]
    require_equal(world.first, Value.GREEN, "intervention_world", "$.world_commitment")
    require_equal(world.second, Value.GREEN, "intervention_world", "$.world_commitment")
    require_equal(world.third, Value.GREEN, "intervention_world", "$.world_commitment")
    state0 = _initial_agent(world)
    state1 = _advance(world, state0)

    if kind in REFUSAL_STAGE:
        before = state0
        _verify_common(record, before, manifest)
        stage = REFUSAL_STAGE[kind]
        require_equal(record["execution_status"], "typed_refusal", "intervention_refusal_status", "$.execution_status")
        require_equal(record["refusal_stage"], stage, "intervention_refusal_stage", "$.refusal_stage")
        gap = _detect(before)
        assert gap is not None
        fields, _ = _chain(
            before,
            gap,
            UseDirection.CORRECT_WITNESSED_MISMATCH,
            ReadingFocus.CANDIDATE,
            "reveal",
            ResponseKind.REVEALED,
            world.at(gap.index),
        )
        for field in OPEN_CAUSAL_FIELDS[: STAGE_PREFIX[stage]]:
            require_equal(record[field], fields[field], "intervention_refusal_prefix", f"$.{field}")
        for field in OPEN_CAUSAL_FIELDS[STAGE_PREFIX[stage] :]:
            require_equal(record[field], None, "intervention_value_after_refusal", f"$.{field}")
        require_equal(_decode_agent(record["state_after"], "$.state_after"), before, "intervention_refusal_state", "$.state_after")
        require_equal(record["compatible_fiber_after"], _fiber_commitments(before, manifest), "intervention_refusal_fiber", "$.compatible_fiber_after")
        return kind

    if kind == "I_projection":
        before = AgentState(
            state0.candidate,
            Observation(
                Knowledge(KnowledgeKind.EXCLUDES, Value.RED),
                Knowledge(KnowledgeKind.EXACT, Value.GREEN),
                Knowledge(KnowledgeKind.UNKNOWN),
            ),
            (),
        )
        gap = _detect(before)
        direction = UseDirection.CORRECT_WITNESSED_MISMATCH
        focus = ReadingFocus.CANDIDATE
        query_kind = "reveal"
        response_kind = ResponseKind.REVEALED
        response_value = Value.GREEN
    elif kind in {"I_gap_permute", "I_random_gap"}:
        before = state0
        index = Index.SECOND if kind == "I_gap_permute" else Index.THIRD
        gap = _detect_at(before, index)
        direction = UseDirection.RESOLVE_FIBER
        focus = ReadingFocus.CANDIDATE
        query_kind = "reveal"
        response_kind = ResponseKind.REVEALED
        response_value = world.at(index)
    elif kind == "I_use_permute":
        before = state0
        gap = _detect(before)
        direction = UseDirection.INSPECT_WITNESSED_MISMATCH
        focus = ReadingFocus.CANDIDATE
        query_kind = "reveal"
        response_kind = ResponseKind.REVEALED
        response_value = Value.GREEN
    elif kind == "I_transport_permute":
        before = state0
        gap = _detect(before)
        direction = UseDirection.CORRECT_WITNESSED_MISMATCH
        focus = ReadingFocus.EVIDENCE
        query_kind = "confirm"
        response_kind = ResponseKind.CONFIRMED
        response_value = Value.GREEN
    elif kind == "I_query_alternate":
        before = state0
        gap = _detect(before)
        direction = UseDirection.CORRECT_WITNESSED_MISMATCH
        focus = ReadingFocus.CANDIDATE
        query_kind = "confirm"
        response_kind = ResponseKind.CONFIRMED
        response_value = Value.GREEN
    elif kind == "I_response_cross":
        before = state0
        gap = _detect(before)
        direction = UseDirection.CORRECT_WITNESSED_MISMATCH
        focus = ReadingFocus.CANDIDATE
        query_kind = "reveal"
        response_kind = ResponseKind.REVEALED
        response_value = Value.BLUE
    elif kind == "I_history_drop":
        before = state1
        gap = _detect(before)
        direction = UseDirection.RESOLVE_FIBER
        focus = ReadingFocus.CANDIDATE
        query_kind = "reveal"
        response_kind = ResponseKind.REVEALED
        response_value = Value.GREEN
    else:
        raise AssertionError(f"unhandled advanced intervention {kind}")
    assert gap is not None
    _verify_common(record, before, manifest)
    fields, expected_after = _chain(
        before, gap, direction, focus, query_kind, response_kind, response_value
    )
    if kind == "I_history_drop":
        expected_after = AgentState(
            expected_after.candidate,
            expected_after.observation,
            (expected_after.history[-1],),
        )
    for field, expected in fields.items():
        require_equal(record[field], expected, "intervention_chain", f"$.{field}")
    after = _decode_agent(record["state_after"], "$.state_after")
    require_equal(after, expected_after, "intervention_after", "$.state_after")
    require_equal(record["compatible_fiber_after"], _fiber_commitments(after, manifest), "intervention_after_fiber", "$.compatible_fiber_after")
    require_equal(record["known_closed_prefix"], [index_typed(index) for index in _known_prefix(after)], "intervention_prefix", "$.known_closed_prefix")
    require_equal(record["persistence_obligations"], _persistence(before, after), "intervention_persistence", "$.persistence_obligations")
    actual_compatible = _world_compatible(after, world)
    history_ok = after.history[: len(before.history)] == before.history
    flags = record["validity_flags"]
    require_equal(flags["actual_world_compatible"], actual_compatible, "intervention_actual_compatibility", "$.validity_flags.actual_world_compatible")
    require_equal(flags["next_from_repair"], kind != "I_history_drop", "intervention_next_flag", "$.validity_flags.next_from_repair")
    require_equal(flags["persistence_valid"], history_ok, "intervention_history_flag", "$.validity_flags.persistence_valid")
    closure = actual_compatible and all(
        after.candidate.at(gap.index) is candidate_world.at(gap.index)
        for candidate_world in _fiber(after)
    )
    require_equal(flags["gap_closed"], closure, "intervention_gap_closure_flag", "$.validity_flags.gap_closed")
    require_equal(record["gap_closed_by"] is not None, closure, "intervention_gap_closure_certificate", "$.gap_closed_by")
    return kind


def verify_intervention_matrix(
    records: list[Mapping[str, Any]],
    *,
    manifest: PrivateFiniteManifest,
    natural_records: list[Mapping[str, Any]],
) -> dict[str, Any]:
    natural_by_hash = {canonical_sha256(record): record for record in natural_records}
    kinds = [
        verify_intervention_record(
            record, manifest=manifest, natural_records=natural_by_hash
        )
        for record in records
    ]
    expected = set(INTERVENTION_KINDS) - {"natural"}
    require_equal(set(kinds), expected, "intervention_matrix_coverage", "$.interventions")
    require_equal(len(kinds), len(expected), "intervention_matrix_duplicates", "$.interventions")
    return {
        "advanced": sum(record["execution_status"] == "advanced" for record in records),
        "interventions": len(records),
        "typed_refusals": sum(record["execution_status"] == "typed_refusal" for record in records),
        "valid": True,
    }
