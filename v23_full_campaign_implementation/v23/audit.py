"""Fail-closed G0–G8 evidence audit."""

from __future__ import annotations

import json
from dataclasses import asdict
from pathlib import Path
from typing import Any

from .canonical import sha256_file
from .contracts import GateResult, GateStatus


GATE_REQUIREMENTS: dict[str, tuple[str, ...]] = {
    "G0": ("protocol", "source_bundle", "environment", "commands", "seeds", "snapshots"),
    "G1": ("lean_build", "axiom_audit", "nontriviality", "formal_aggregate"),
    "G2": ("finite_conformance", "intervention_conformance", "lean_python_zero_divergence"),
    "G3": ("quantized_catalog", "int8_weights", "int32_accumulators", "lean_recalculation"),
    "G4": ("passive_no_go", "visible_no_go", "best_finite_controller", "transcript_capacity", "active_sufficiency"),
    "G5": ("H4", "H5", "bypass_refusals", "information_flow", "zero_structural_violations"),
    "G6": ("H6", "persistence", "composition", "multi_step_closure"),
    "G7": ("H3", "H7", "two_domains", "ten_seeds", "sealed_opening_order", "paired_comparisons"),
    "G8": ("certificates", "falsification", "evaluation_replication", "training_replication", "complete_reports"),
}


def _audit_evidence_file(path: Path, requirements: tuple[str, ...]) -> GateResult:
    gate_id = path.stem.upper()
    if not path.exists():
        return GateResult(gate_id, GateStatus.NOT_RUN, (), (), (f"missing {path}",))
    try:
        payload: dict[str, Any] = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        return GateResult(gate_id, GateStatus.FAIL, (), (), (str(error),))
    checks = payload.get("checks")
    files = payload.get("files")
    if not isinstance(checks, dict) or not isinstance(files, list):
        return GateResult(gate_id, GateStatus.FAIL, (), (), ("malformed evidence manifest",))
    blockers: list[str] = []
    passed: list[str] = []
    for requirement in requirements:
        if checks.get(requirement) is True:
            passed.append(requirement)
        else:
            blockers.append(f"check not proven: {requirement}")
    evidence: list[str] = []
    for entry in files:
        if not isinstance(entry, dict) or set(entry) < {"path", "sha256"}:
            blockers.append("malformed evidence file entry")
            continue
        target = path.parent.parent / entry["path"]
        if not target.is_file():
            blockers.append(f"missing evidence file: {entry['path']}")
        elif sha256_file(target) != entry["sha256"]:
            blockers.append(f"evidence hash mismatch: {entry['path']}")
        else:
            evidence.append(str(target))
    status = GateStatus.FAIL if blockers else GateStatus.PASS
    return GateResult(gate_id, status, tuple(passed), tuple(evidence), tuple(blockers))


def audit_all_gates(run_root: str | Path) -> dict[str, Any]:
    root = Path(run_root)
    results = [
        _audit_evidence_file(root / "gates" / f"{gate.lower()}.json", requirements)
        for gate, requirements in GATE_REQUIREMENTS.items()
    ]
    return {
        "schema": "v23-global-audit-1",
        "gates": [asdict(result) for result in results],
        "all_pass": all(result.status is GateStatus.PASS for result in results),
        "has_failure": any(result.status is GateStatus.FAIL for result in results),
        "has_not_run": any(result.status is GateStatus.NOT_RUN for result in results),
    }
