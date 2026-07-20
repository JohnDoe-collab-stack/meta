#!/usr/bin/env python3
"""Compile and compare the exhaustive Lean/Python Level-A snapshot."""

from __future__ import annotations

import argparse
import ast
import hashlib
import subprocess
import sys
from pathlib import Path
from typing import Any, Sequence

from environment_v23 import provenance_from_material
from finite_interventions_v23 import intervention_records
from finite_reference_domain_v23 import (
    ALL_WORLDS,
    INDICES,
    AgentState,
    CandidatePatch,
    GapEvidenceKind,
    GapKind,
    Index,
    Knowledge,
    KnowledgeKind,
    Observation,
    PatchKind,
    PrivateFiniteManifest,
    QueryKind,
    ReadingFocus,
    RepairRecord,
    Response,
    ResponseKind,
    UseDirection,
    Value,
    apply_observation_update,
    compatible_worlds,
    initial_state,
    next_state,
    open_transition,
)
from trace_schema_v23 import canonical_json, canonical_sha256
from verify_finite_reference_v23 import _decode_agent


LEAN_MODULE = Path("Meta/AI/FiniteActiveSemanticClosureConformance.lean")
BEGIN = "V23_CONFORMANCE_BEGIN"
END = "V23_CONFORMANCE_END"

VALUE_CODE = {Value.RED: 0, Value.GREEN: 1, Value.BLUE: 2}
INDEX_CODE = {Index.FIRST: 0, Index.SECOND: 1, Index.THIRD: 2}
KNOWLEDGE_CODE = {
    KnowledgeKind.UNKNOWN: 0,
    KnowledgeKind.EXCLUDES: 1,
    KnowledgeKind.EXACT: 2,
}
EVIDENCE_CODE = {
    GapEvidenceKind.EXACT_WRONG: 0,
    GapEvidenceKind.EXACT_MISSING: 1,
    GapEvidenceKind.EXCLUDED_PREDICTION: 2,
    GapEvidenceKind.UNKNOWN: 3,
    GapEvidenceKind.EXCLUDED_FIBER: 4,
}
GAP_CODE = {GapKind.WITNESSED_MISMATCH: 0, GapKind.UNRESOLVED_FIBER: 1}
USE_CODE = {
    UseDirection.CORRECT_WITNESSED_MISMATCH: 0,
    UseDirection.INSPECT_WITNESSED_MISMATCH: 1,
    UseDirection.RESOLVE_FIBER: 2,
    UseDirection.INSPECT_FIBER: 3,
}
FOCUS_CODE = {ReadingFocus.CANDIDATE: 0, ReadingFocus.EVIDENCE: 1}
QUERY_CODE = {QueryKind.REVEAL: 0, QueryKind.CONFIRM: 1, QueryKind.NO_INFORMATION: 2}
RESPONSE_CODE = {
    ResponseKind.REVEALED: 0,
    ResponseKind.CONFIRMED: 1,
    ResponseKind.NO_INFORMATION: 2,
}


def _option(value: Value | None) -> int:
    return 3 if value is None else VALUE_CODE[value]


def _knowledge(value: Knowledge) -> list[int]:
    return [KNOWLEDGE_CODE[value.kind], _option(value.value)]


def _observation(value: Observation) -> list[int]:
    result: list[int] = []
    for index in INDICES:
        result.extend(_knowledge(value.at(index)))
    return result


def _record(value: RepairRecord) -> list[int]:
    return [INDEX_CODE[value.index], _option(value.answer), int(value.changed_candidate)]


def _agent(value: AgentState) -> list[int]:
    result = [_option(value.candidate.at(index)) for index in INDICES]
    result.extend(_observation(value.observation))
    result.append(len(value.history))
    for record in value.history:
        result.extend(_record(record))
    return result


def _world_id(world: Any) -> int:
    return 9 * VALUE_CODE[world.first] + 3 * VALUE_CODE[world.second] + VALUE_CODE[world.third]


def _frame(payload: list[int]) -> list[int]:
    return [len(payload), *payload]


def _fiber(view: AgentState) -> list[int]:
    return [_world_id(world) for world in compatible_worlds(view)]


def _evidence(gap: Any) -> list[int]:
    evidence = gap.evidence
    return [
        EVIDENCE_CODE[evidence.kind],
        _option(evidence.observed),
        _option(evidence.predicted),
    ]


def _response(response: Response) -> list[int]:
    return [RESPONSE_CODE[response.kind], _option(response.value)]


def _patch(patch: CandidatePatch) -> list[int]:
    if patch.kind is PatchKind.KEEP:
        return [1, 3, 3]
    assert patch.index is not None and patch.value is not None
    return [0, INDEX_CODE[patch.index], VALUE_CODE[patch.value]]


def _natural_row(world: Any, stage: int) -> list[int]:
    state = initial_state(world)
    for _ in range(stage):
        state = next_state(state)
    row = [0, _world_id(world), stage, *_frame(_agent(state.agent)), *_frame(_fiber(state.agent))]
    transition = open_transition(state)
    if transition is None:
        return [*row, 0, *_frame(_agent(state.agent)), *_frame(_fiber(state.agent))]
    return [
        *row,
        1,
        INDEX_CODE[transition.gap.index],
        GAP_CODE[transition.gap.kind],
        *_evidence(transition.gap),
        USE_CODE[transition.use.direction],
        FOCUS_CODE[transition.transport.reading.focus],
        INDEX_CODE[transition.transport.output.requested_index],
        int(transition.transport.output.informative),
        QUERY_CODE[transition.query.kind],
        *_response(transition.response),
        *_patch(transition.repair.candidate_patch),
        *_observation(
            apply_observation_update(
                state.agent.observation, transition.repair.observation_update
            )
        ),
        *_record(transition.repair.history_record),
        *_frame(_agent(transition.after.agent)),
        *_frame(_fiber(transition.after.agent)),
    ]


def _intervention_rows() -> list[list[int]]:
    provenance = provenance_from_material(
        run_id="finite-conformance",
        environment_seed=23,
        source_bundle=b"finite-conformance",
        executed_script=b"finite-conformance",
        command="finite-conformance",
    )
    manifest = PrivateFiniteManifest(b"finite-conformance-private-salt")
    records = intervention_records(provenance=provenance, manifest=manifest)
    stage_code = {
        "gap": 0,
        "use": 1,
        "transport": 2,
        "query": 3,
        "response": 4,
        "repair": 5,
        "next": 6,
    }
    rows = []
    for code, record in enumerate(records):
        before = _decode_agent(record["state_before"], "$.state_before")
        after = _decode_agent(record["state_after"], "$.state_after")
        if record["execution_status"] == "advanced":
            gap = record["gap"]["value"]
            evidence = record["gap_evidence"]["value"]
            use = record["authorized_use"]["value"]
            transport = record["authorized_transport"]["value"]
            query = record["query"]["value"]
            response = record["response"]["value"]
            repair = record["intrinsic_repair"]["value"]
            patch = repair["candidatePatch"]
            history = repair["historyRecord"]
            observed = evidence["observed"]
            predicted = evidence["predicted"]
            response_value = response["value"]
            patch_value = patch["value"]
            rows.append(
                [
                    1,
                    code,
                    1,
                    *_frame(_agent(before)),
                    *_frame(_fiber(before)),
                    INDEX_CODE[Index(gap["index"])],
                    GAP_CODE[GapKind(gap["kind"])],
                    EVIDENCE_CODE[GapEvidenceKind(evidence["constructor"])],
                    _option(None if observed is None else Value(observed)),
                    _option(None if predicted is None else Value(predicted)),
                    USE_CODE[UseDirection(use["direction"])],
                    FOCUS_CODE[ReadingFocus(transport["reading"]["focus"])],
                    INDEX_CODE[Index(transport["output"]["requestedIndex"])],
                    int(transport["output"]["informative"]),
                    QUERY_CODE[QueryKind(query["constructor"])],
                    RESPONSE_CODE[ResponseKind(response["constructor"])],
                    _option(None if response_value is None else Value(response_value)),
                    1 if patch["constructor"] == "keep" else 0,
                    3 if patch["index"] is None else INDEX_CODE[Index(patch["index"])],
                    _option(None if patch_value is None else Value(patch_value)),
                    *_observation(after.observation),
                    INDEX_CODE[Index(history["index"])],
                    _option(None if history["answer"] is None else Value(history["answer"])),
                    int(history["changedCandidate"]),
                    *_frame(_agent(after)),
                    *_frame(_fiber(after)),
                ]
            )
        else:
            rows.append(
                [
                    1,
                    code,
                    0,
                    stage_code[record["refusal_stage"]],
                    *_frame(_agent(before)),
                    *_frame(_fiber(before)),
                    *_frame(_agent(after)),
                    *_frame(_fiber(after)),
                ]
            )
    return rows


def python_conformance_rows() -> list[list[int]]:
    natural = [
        _natural_row(world, stage)
        for world in ALL_WORLDS
        for stage in range(4)
    ]
    return natural + _intervention_rows()


def extract_lean_rows(output: str) -> list[list[int]]:
    try:
        body = output.split(BEGIN + "\n", 1)[1].split("\n" + END, 1)[0]
    except IndexError as error:
        raise ValueError("Lean output lacks conformance markers") from error
    value = ast.literal_eval(body)
    if not isinstance(value, list) or not all(
        isinstance(row, list) and all(isinstance(token, int) for token in row)
        for row in value
    ):
        raise ValueError("Lean conformance payload is not List (List Nat)")
    return value


def compare_rows(lean_rows: list[list[int]], python_rows: list[list[int]]) -> dict[str, Any]:
    if len(lean_rows) != len(python_rows):
        raise ValueError(f"row count differs: Lean={len(lean_rows)}, Python={len(python_rows)}")
    for index, (lean_row, python_row) in enumerate(zip(lean_rows, python_rows)):
        if lean_row != python_row:
            raise ValueError(
                f"conformance mismatch at row {index}: Lean={lean_row!r}, Python={python_row!r}"
            )
    return {
        "intervention_rows": len(_intervention_rows()),
        "natural_rows": len(ALL_WORLDS) * 4,
        "rows": len(lean_rows),
        "snapshot_sha256": canonical_sha256(lean_rows),
        "valid": True,
        "worlds": len(ALL_WORLDS),
    }


def compile_and_compare(repo: Path) -> dict[str, Any]:
    module = repo / LEAN_MODULE
    build = subprocess.run(
        ["lake", "build", "Meta.AI.FiniteActiveSemanticClosureConformance"],
        cwd=repo,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if build.returncode != 0:
        raise RuntimeError(f"Lean conformance build failed:\n{build.stdout}")
    completed = subprocess.run(
        ["lake", "env", "lean", str(LEAN_MODULE)],
        cwd=repo,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if completed.returncode != 0:
        raise RuntimeError(f"Lean conformance module failed:\n{completed.stdout}")
    forbidden = ("depends on axioms", "sorryAx", "propext", "Quot.sound", "Classical")
    contamination = [token for token in forbidden if token in completed.stdout]
    if contamination:
        raise RuntimeError(f"Lean axiom audit is contaminated by {contamination}")
    report = compare_rows(extract_lean_rows(completed.stdout), python_conformance_rows())
    report["lean_module_sha256"] = hashlib.sha256(module.read_bytes()).hexdigest()
    return report


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, default=Path(__file__).resolve().parents[2])
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        report = compile_and_compare(args.repo.resolve())
    except (OSError, RuntimeError, ValueError, subprocess.SubprocessError) as error:
        print(canonical_json({"error": str(error), "valid": False}), file=sys.stderr)
        return 1
    print(canonical_json(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
