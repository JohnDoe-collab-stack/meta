#!/usr/bin/env python3
"""Independent semantic verifier for the exact v23 finite reference domain.

The producer and this verifier share only the finite data representation and
canonical serialization.  This module deliberately does not call the
producer's detector, authorization, transport, response, repair, transition,
fiber, closure, or orbit functions.  Every semantic judgment is recomputed
below from the decoded private world and public agent state.
"""

from __future__ import annotations

import argparse
import hashlib
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping, Sequence

from environment_v23 import (
    SemanticVerificationError,
    fail,
    require,
    require_equal,
    sha256_bytes,
    typed,
)
from finite_reference_domain_v23 import (
    ALL_WORLDS,
    INDICES,
    AgentState,
    Candidate,
    GapEvidence,
    GapEvidenceKind,
    GapKind,
    Index,
    Knowledge,
    KnowledgeKind,
    Observation,
    OperationalGap,
    PrivateFiniteManifest,
    RepairRecord,
    UseDirection,
    Value,
    World,
    index_typed,
    serialize_agent_state,
    serialize_gap,
    serialize_gap_evidence,
)
from trace_schema_v23 import (
    FORBIDDEN_AGENT_FIELDS,
    VALIDITY_FLAG_NAMES,
    TraceSchemaError,
    canonical_json,
    canonical_json_bytes,
    canonical_sha256,
    parse_trace_line,
    validate_trace_record,
)


def _mapping(value: Any, path: str) -> Mapping[str, Any]:
    if not isinstance(value, dict):
        fail("semantic_expected_object", path, f"got {type(value).__name__}")
    return value


def _exact_fields(value: Mapping[str, Any], fields: set[str], path: str) -> None:
    actual = set(value)
    if actual != fields:
        fail(
            "semantic_field_mismatch",
            path,
            f"missing={sorted(fields - actual)}, extra={sorted(actual - fields)}",
        )


def _typed_payload(value: Any, tag: str, path: str) -> Mapping[str, Any]:
    wrapper = _mapping(value, path)
    _exact_fields(wrapper, {"type", "value"}, path)
    require_equal(wrapper["type"], tag, "semantic_type_tag", f"{path}.type")
    return _mapping(wrapper["value"], f"{path}.value")


def _enum(enum_type: type[Any], value: Any, path: str) -> Any:
    if not isinstance(value, str):
        fail("semantic_expected_enum", path, f"got {type(value).__name__}")
    try:
        return enum_type(value)
    except ValueError as error:
        fail("semantic_unknown_constructor", path, str(error))


def _optional_value(value: Any, path: str) -> Value | None:
    return None if value is None else _enum(Value, value, path)


def _decode_candidate(value: Any, path: str) -> Candidate:
    payload = _mapping(value, path)
    fields = {index.value for index in INDICES}
    _exact_fields(payload, fields, path)
    return Candidate(
        *(_optional_value(payload[index.value], f"{path}.{index.value}") for index in INDICES)
    )


def _decode_knowledge(value: Any, path: str) -> Knowledge:
    payload = _mapping(value, path)
    _exact_fields(payload, {"kind", "value"}, path)
    kind = _enum(KnowledgeKind, payload["kind"], f"{path}.kind")
    raw = _optional_value(payload["value"], f"{path}.value")
    try:
        return Knowledge(kind, raw)
    except ValueError as error:
        fail("semantic_invalid_knowledge", path, str(error))


def _decode_observation(value: Any, path: str) -> Observation:
    payload = _mapping(value, path)
    fields = {index.value for index in INDICES}
    _exact_fields(payload, fields, path)
    return Observation(
        *(
            _decode_knowledge(payload[index.value], f"{path}.{index.value}")
            for index in INDICES
        )
    )


def _decode_record(value: Any, path: str) -> RepairRecord:
    payload = _mapping(value, path)
    _exact_fields(payload, {"index", "answer", "changedCandidate"}, path)
    changed = payload["changedCandidate"]
    require(isinstance(changed, bool), "semantic_expected_bool", f"{path}.changedCandidate", "expected bool")
    return RepairRecord(
        _enum(Index, payload["index"], f"{path}.index"),
        _optional_value(payload["answer"], f"{path}.answer"),
        changed,
    )


def _decode_agent(value: Any, path: str) -> AgentState:
    payload = _typed_payload(value, "finite.AgentState", path)
    _exact_fields(payload, {"candidate", "observation", "history"}, f"{path}.value")
    history_raw = payload["history"]
    require(isinstance(history_raw, list), "semantic_expected_array", f"{path}.value.history", "expected list")
    return AgentState(
        _decode_candidate(payload["candidate"], f"{path}.value.candidate"),
        _decode_observation(payload["observation"], f"{path}.value.observation"),
        tuple(
            _decode_record(item, f"{path}.value.history[{offset}]")
            for offset, item in enumerate(history_raw)
        ),
    )


def _allows(knowledge: Knowledge, value: Value) -> bool:
    if knowledge.kind is KnowledgeKind.UNKNOWN:
        return True
    if knowledge.kind is KnowledgeKind.EXCLUDES:
        return value is not knowledge.value
    return value is knowledge.value


def _world_compatible(view: AgentState, world: World) -> bool:
    observation_ok = all(
        _allows(view.observation.at(index), world.at(index)) for index in INDICES
    )
    history_ok = all(
        record.answer is None or world.at(record.index) is record.answer
        for record in view.history
    )
    return observation_ok and history_ok


def _fiber(view: AgentState) -> tuple[World, ...]:
    return tuple(world for world in ALL_WORLDS if _world_compatible(view, world))


def _detect_at(view: AgentState, index: Index) -> OperationalGap | None:
    knowledge = view.observation.at(index)
    predicted = view.candidate.at(index)
    if knowledge.kind is KnowledgeKind.UNKNOWN:
        return OperationalGap(
            index,
            GapKind.UNRESOLVED_FIBER,
            GapEvidence(GapEvidenceKind.UNKNOWN, index),
        )
    assert knowledge.value is not None
    if knowledge.kind is KnowledgeKind.EXCLUDES:
        if predicted is knowledge.value:
            return OperationalGap(
                index,
                GapKind.WITNESSED_MISMATCH,
                GapEvidence(
                    GapEvidenceKind.EXCLUDED_PREDICTION,
                    index,
                    observed=knowledge.value,
                    predicted=predicted,
                ),
            )
        return OperationalGap(
            index,
            GapKind.UNRESOLVED_FIBER,
            GapEvidence(
                GapEvidenceKind.EXCLUDED_FIBER,
                index,
                observed=knowledge.value,
                predicted=predicted,
            ),
        )
    if predicted is None:
        return OperationalGap(
            index,
            GapKind.WITNESSED_MISMATCH,
            GapEvidence(GapEvidenceKind.EXACT_MISSING, index, observed=knowledge.value),
        )
    if predicted is knowledge.value:
        return None
    return OperationalGap(
        index,
        GapKind.WITNESSED_MISMATCH,
        GapEvidence(
            GapEvidenceKind.EXACT_WRONG,
            index,
            observed=knowledge.value,
            predicted=predicted,
        ),
    )


def _detect(view: AgentState) -> OperationalGap | None:
    for index in INDICES:
        result = _detect_at(view, index)
        if result is not None:
            return result
    return None


def _expected_direction(gap: OperationalGap) -> UseDirection:
    if gap.kind is GapKind.WITNESSED_MISMATCH:
        return UseDirection.CORRECT_WITNESSED_MISMATCH
    return UseDirection.RESOLVE_FIBER


def _expected_open_payloads(
    world: World, before: AgentState, gap: OperationalGap
) -> tuple[dict[str, Any], ...]:
    direction = _expected_direction(gap)
    use = {
        "direction": direction.value,
        "gapKind": gap.kind.value,
        "gapIndex": gap.index.value,
    }
    transport = {
        "reading": {
            "index": gap.index.value,
            "direction": direction.value,
            "focus": "candidate",
        },
        "output": {"requestedIndex": gap.index.value, "informative": True},
        "evidence": {"direction": direction.value, "reachesGap": True},
    }
    query = {"constructor": "reveal", "index": gap.index.value}
    target = world.at(gap.index)
    response = {
        "constructor": "revealed",
        "index": gap.index.value,
        "value": target.value,
    }
    patch = {"constructor": "set", "index": gap.index.value, "value": target.value}
    history = {
        "index": gap.index.value,
        "answer": target.value,
        "changedCandidate": True,
    }
    repair = {
        "causalIndex": gap.index.value,
        "candidatePatch": patch,
        "observationUpdate": {
            "constructor": "revealed",
            "index": gap.index.value,
            "value": target.value,
        },
        "historyRecord": history,
        "recordedDirection": direction.value,
        "transportIndex": gap.index.value,
    }
    after_candidate = before.candidate.set(gap.index, target)
    after_observation = before.observation.set_exact(gap.index, target)
    after = AgentState(
        after_candidate,
        after_observation,
        before.history + (RepairRecord(gap.index, target, True),),
    )
    return use, transport, query, response, repair, serialize_agent_state(after)


def _known_correct(view: AgentState, index: Index) -> bool:
    return all(view.candidate.at(index) is world.at(index) for world in _fiber(view))


def _known_prefix(view: AgentState) -> tuple[Index, ...]:
    result: list[Index] = []
    for index in INDICES:
        if not _known_correct(view, index):
            break
        result.append(index)
    return tuple(result)


def _persistence(before: AgentState, after: AgentState) -> list[dict[str, Any]]:
    return [
        {
            "index": index_typed(index),
            "preserved": _known_correct(after, index),
            "provenance_sha256": canonical_sha256(
                {"before": serialize_agent_state(before), "index": index.value}
            ),
        }
        for index in _known_prefix(before)
    ]


def _initial_agent(world: World) -> AgentState:
    first = (
        Knowledge(KnowledgeKind.EXACT, Value.RED)
        if world.first is Value.RED
        else Knowledge(KnowledgeKind.EXCLUDES, Value.RED)
    )
    return AgentState(
        Candidate(Value.RED, None, None),
        Observation(first, Knowledge(KnowledgeKind.UNKNOWN), Knowledge(KnowledgeKind.UNKNOWN)),
        (),
    )


def _advance(world: World, before: AgentState) -> AgentState:
    gap = _detect(before)
    if gap is None:
        return before
    *_, after_payload = _expected_open_payloads(world, before, gap)
    return AgentState(
        _decode_candidate(after_payload["candidate"], "$.internal.candidate"),
        _decode_observation(after_payload["observation"], "$.internal.observation"),
        tuple(
            _decode_record(record, f"$.internal.history[{index}]")
            for index, record in enumerate(after_payload["history"])
        ),
    )


def _state_at(world: World, step: int) -> AgentState:
    state = _initial_agent(world)
    for _ in range(step):
        state = _advance(world, state)
    return state


def _fiber_commitments(
    view: AgentState, manifest: PrivateFiniteManifest
) -> list[str]:
    return sorted(manifest.commitment(world) for world in _fiber(view))


def _verify_agent_manifest(record: Mapping[str, Any], before: AgentState) -> None:
    expected_bytes = canonical_json_bytes(
        typed("finite.AgentState", **serialize_agent_state(before))
    )
    expected = {
        "encoding": "finite.agent-state.v1",
        "sha256": sha256_bytes(expected_bytes),
        "byte_length": len(expected_bytes),
        "fields": ["candidate", "history", "observation"],
        "forbidden_fields_absent": list(FORBIDDEN_AGENT_FIELDS),
    }
    require_equal(
        record["agent_input_manifest"],
        expected,
        "semantic_agent_manifest",
        "$.agent_input_manifest",
    )


@dataclass(frozen=True)
class FiniteSemanticReport:
    world: World
    before: AgentState
    after: AgentState
    open_gap: bool


def verify_finite_record(
    value: Mapping[str, Any], manifest: PrivateFiniteManifest
) -> FiniteSemanticReport:
    """Recompute and verify every semantic field of one natural Level-A record."""

    record = validate_trace_record(value, require_claimed_validity=True)
    require_equal(record["domain"], "finite_reference", "semantic_domain", "$.domain")
    require_equal(record["split"], "finite_exhaustive", "semantic_split", "$.split")
    require_equal(record["producer_kind"], "reference", "semantic_producer", "$.producer_kind")
    require_equal(record["intervention_kind"], "natural", "semantic_intervention", "$.intervention_kind")

    commitments = manifest.commitment_map()
    commitment = record["world_commitment"]
    require(commitment in commitments, "semantic_unknown_world", "$.world_commitment", "commitment is absent from the private manifest")
    world = commitments[commitment]
    before = _decode_agent(record["state_before"], "$.state_before")
    after = _decode_agent(record["state_after"], "$.state_after")

    require_equal(
        before,
        _state_at(world, record["step"]),
        "semantic_unreachable_state",
        "$.state_before",
    )
    require(_world_compatible(before, world), "semantic_world_incompatible", "$.state_before", "private world is incompatible with public evidence")
    _verify_agent_manifest(record, before)
    require_equal(record["compatible_fiber_before"], _fiber_commitments(before, manifest), "semantic_before_fiber", "$.compatible_fiber_before")

    gap = _detect(before)
    if gap is None:
        require_equal(record["gap_status"], "closed", "semantic_gap_status", "$.gap_status")
        require_equal(record["execution_status"], "closed_stasis", "semantic_execution_status", "$.execution_status")
        require_equal(after, before, "semantic_closed_state", "$.state_after")
    else:
        require_equal(record["gap_status"], "open", "semantic_gap_status", "$.gap_status")
        require_equal(record["execution_status"], "advanced", "semantic_execution_status", "$.execution_status")
        require_equal(record["gap"], typed("finite.OperationalGap", **serialize_gap(gap)), "semantic_gap", "$.gap")
        require_equal(record["gap_evidence"], typed("finite.GapEvidence", **serialize_gap_evidence(gap.evidence)), "semantic_gap_evidence", "$.gap_evidence")
        use, transport, query, response, repair, after_payload = _expected_open_payloads(world, before, gap)
        require_equal(record["authorized_use"], typed("finite.GapAuthorizedUse", **use), "semantic_use", "$.authorized_use")
        require_equal(record["authorized_transport"], typed("finite.GapAuthorizedTransport", **transport), "semantic_transport", "$.authorized_transport")
        require_equal(record["query"], typed("finite.Query", **query), "semantic_query", "$.query")
        require_equal(record["query_footprint"], {"requested_index": index_typed(gap.index), "query_count": 1, "serialized_bits": 2}, "semantic_query_footprint", "$.query_footprint")
        require_equal(record["response"], typed("finite.Response", **response), "semantic_response", "$.response")
        require_equal(record["response_footprint"], {"requested_index": index_typed(gap.index), "actual_bits": 2, "max_bits": 2}, "semantic_response_footprint", "$.response_footprint")
        require_equal(record["intrinsic_repair"], typed("finite.IntrinsicRepair", **repair), "semantic_repair", "$.intrinsic_repair")
        expected_after = _advance(world, before)
        require_equal(serialize_agent_state(expected_after), after_payload, "semantic_internal_transition", "$.state_after")
        require_equal(after, expected_after, "semantic_next_from_repair", "$.state_after")
        require(_known_correct(after, gap.index), "semantic_gap_not_closed", "$.gap_closed_by", "repair does not close the selected gap over the exact posterior fiber")
        require_equal(
            record["gap_closed_by"],
            typed(
                "finite.GapClosedBy",
                index=gap.index.value,
                beforeFiberSize=len(_fiber(before)),
                afterFiberSize=len(_fiber(after)),
            ),
            "semantic_gap_closure",
            "$.gap_closed_by",
        )

    require_equal(record["compatible_fiber_after"], _fiber_commitments(after, manifest), "semantic_after_fiber", "$.compatible_fiber_after")
    require(_world_compatible(after, world), "semantic_after_world_incompatible", "$.state_after", "repair excluded the actual world")
    require_equal(record["known_closed_prefix"], [index_typed(index) for index in _known_prefix(after)], "semantic_known_prefix", "$.known_closed_prefix")
    require_equal(record["persistence_obligations"], _persistence(before, after), "semantic_persistence", "$.persistence_obligations")
    require_equal(
        after.history[: len(before.history)],
        before.history,
        "semantic_history_not_retained",
        "$.state_after.value.history",
    )
    require(all(record["validity_flags"][name] is True for name in VALIDITY_FLAG_NAMES), "semantic_false_validity_flag", "$.validity_flags", "all natural reference judgments were independently established")
    return FiniteSemanticReport(world, before, after, gap is not None)


def verify_finite_file(path: Path, manifest: PrivateFiniteManifest) -> dict[str, Any]:
    raw = path.read_bytes()
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError as error:
        fail("semantic_invalid_utf8", "$", str(error))
    require(text.endswith("\n"), "semantic_missing_final_newline", "$", "JSONL must end with LF")
    lines = text[:-1].split("\n")
    require(bool(lines) and all(lines), "semantic_empty_trace", "$", "trace must contain no blank records")
    previous: dict[str, tuple[int, AgentState, World]] = {}
    advanced = 0
    closed = 0
    for line_number, line in enumerate(lines, start=1):
        try:
            record = parse_trace_line(line, require_canonical=True, require_claimed_validity=True)
            report = verify_finite_record(record, manifest)
        except (TraceSchemaError, SemanticVerificationError) as error:
            fail("semantic_record_failure", f"$[{line_number}]", str(error))
        episode = record["episode_id"]
        if episode in previous:
            last_step, last_after, last_world = previous[episode]
            require_equal(record["step"], last_step + 1, "semantic_nonconsecutive_step", f"$[{line_number}].step")
            require_equal(report.before, last_after, "semantic_broken_episode_chain", f"$[{line_number}].state_before")
            require_equal(report.world, last_world, "semantic_world_changed", f"$[{line_number}].world_commitment")
        else:
            require_equal(record["step"], 0, "semantic_episode_not_zero_based", f"$[{line_number}].step")
        previous[episode] = (record["step"], report.after, report.world)
        if report.open_gap:
            advanced += 1
        else:
            closed += 1
    return {
        "advanced": advanced,
        "closed_stasis": closed,
        "episodes": len(previous),
        "records": len(lines),
        "sha256": hashlib.sha256(raw).hexdigest(),
        "valid": True,
    }


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("trace", type=Path)
    parser.add_argument(
        "--manifest-salt-hex",
        required=True,
        help="private finite-manifest salt as non-empty hexadecimal bytes",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        salt = bytes.fromhex(args.manifest_salt_hex)
        require(bool(salt), "semantic_empty_manifest_salt", "$.manifest", "salt is required")
        report = verify_finite_file(args.trace, PrivateFiniteManifest(salt))
    except (OSError, ValueError, TraceSchemaError, SemanticVerificationError) as error:
        print(canonical_json({"error": str(error), "valid": False}), file=sys.stderr)
        return 1
    print(canonical_json(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
