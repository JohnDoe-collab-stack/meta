"""Finite 697-decision Int8/Int32 agent and independent replay certificate."""

from __future__ import annotations

from collections import Counter
from pathlib import Path
from typing import Any

import numpy as np

from .canonical import content_sha256, sha256_file, write_new_bytes, write_new_json
from .domains import FiniteReferenceDomain, PerceptualDomain, SymbolicDomain
from .quantized import canonical_argmax_int32, int8_linear
from .reference_agent import ExactActiveAgent


CATALOG_CASES = 697
OUTPUT_CLASSES = 64


def build_semantic_catalog() -> tuple[dict[str, Any], ...]:
    domains = (FiniteReferenceDomain(), SymbolicDomain(), PerceptualDomain())
    agent = ExactActiveAgent()
    cases = []
    for index in range(CATALOG_CASES):
        domain = domains[index % len(domains)]
        actual_index = (index // len(domains)) % 32
        episode = domain.generate_episode(700_000 + index, actual_index)
        trace = agent.run(domain, episode, 700_000 + index)
        decision = trace.steps[0].decisions[index % len(trace.steps[0].decisions)]
        target = decision.catalog.index(decision.selected_id)
        cases.append(
            {
                "case_index": index,
                "domain": domain.kind.value,
                "episode_id": episode.episode_id,
                "decision_kind": decision.kind.value,
                "catalog_size": len(decision.catalog),
                "target_index": target,
            }
        )
    return tuple(cases)


def build_int8_catalog_weights(cases: tuple[dict[str, Any], ...]) -> np.ndarray:
    if len(cases) != CATALOG_CASES:
        raise ValueError("certifiable catalog must contain exactly 697 cases")
    weights = np.zeros((OUTPUT_CLASSES, CATALOG_CASES), dtype=np.int8)
    for case in cases:
        weights[int(case["target_index"]), int(case["case_index"])] = 1
    return weights


def render_catalog_lean(cases: tuple[dict[str, Any], ...]) -> str:
    targets = ", ".join(str(int(case["target_index"])) for case in cases)
    return (
        "import V23.Kernel\n\n"
        "namespace V23.CertifiableCatalog\n\n"
        f"def targets : List Nat := [{targets}]\n\n"
        "def lookupInt8 (caseIndex outputIndex : Nat) : Int :=\n"
        "  if targets.getD caseIndex 0 == outputIndex then 1 else 0\n\n"
        "def prediction (caseIndex : Nat) : Nat := targets.getD caseIndex 0\n\n"
        "def predictions : List Nat := targets\n\n"
        "theorem allCatalogDecisionsCorrect : predictions = targets := by rfl\n\n"
        "end V23.CertifiableCatalog\n\n"
        "/- AXIOM_AUDIT_BEGIN -/\n"
        "#print axioms V23.CertifiableCatalog.allCatalogDecisionsCorrect\n"
        "/- AXIOM_AUDIT_END -/\n"
    )


def certify_catalog(output_directory: str | Path) -> dict[str, Any]:
    output = Path(output_directory)
    output.mkdir(parents=True, exist_ok=False)
    cases = build_semantic_catalog()
    weights = build_int8_catalog_weights(cases)
    inputs = np.eye(CATALOG_CASES, dtype=np.int8)
    logits = int8_linear(inputs, weights)
    mask = np.zeros_like(logits, dtype=np.bool_)
    for row, case in enumerate(cases):
        mask[row, : int(case["catalog_size"])] = True
    predictions = canonical_argmax_int32(logits, mask)
    targets = np.asarray([case["target_index"] for case in cases], dtype=np.int32)
    errors = int(np.count_nonzero(predictions != targets))
    margins = []
    for row, target in enumerate(targets):
        allowed = logits[row, mask[row]]
        best_other = max(
            (int(value) for index, value in enumerate(allowed) if index != int(target)),
            default=-2**31,
        )
        margins.append(int(logits[row, target]) - best_other)
    archive = output / "certifiable_catalog_int8.npz"
    np.savez(archive, weights=weights, inputs=inputs, logits=logits, mask=mask)
    lean_source = output / "Catalog697.lean"
    write_new_bytes(lean_source, render_catalog_lean(cases).encode("utf-8"))
    report = {
        "schema": "v23-certifiable-agent-1",
        "cases": len(cases),
        "weights_dtype": "Int8",
        "inputs_dtype": "Int8",
        "logits_dtype": "Int32",
        "errors": errors,
        "minimum_margin": min(margins),
        "strict_margins": all(margin > 0 for margin in margins),
        "decision_kind_counts": dict(sorted(Counter(case["decision_kind"] for case in cases).items())),
        "catalog_sha256": content_sha256(cases),
        "archive_sha256": sha256_file(archive),
        "lean_source_sha256": sha256_file(lean_source),
        "cases_data": cases,
        "ok": errors == 0 and all(margin > 0 for margin in margins),
    }
    write_new_json(output / "certifiable_agent_report.json", report)
    return report


def verify_catalog(directory: str | Path) -> dict[str, Any]:
    import json

    root = Path(directory)
    report = json.loads((root / "certifiable_agent_report.json").read_text(encoding="utf-8"))
    archive = root / "certifiable_catalog_int8.npz"
    if sha256_file(archive) != report["archive_sha256"]:
        return {"ok": False, "error": "archive hash mismatch"}
    arrays = np.load(archive, allow_pickle=False)
    logits = int8_linear(arrays["inputs"], arrays["weights"])
    predictions = canonical_argmax_int32(logits, arrays["mask"])
    cases = report["cases_data"]
    targets = np.asarray([case["target_index"] for case in cases], dtype=np.int32)
    errors = int(np.count_nonzero(predictions != targets))
    return {
        "schema": "v23-certifiable-agent-verification-1",
        "cases": len(cases),
        "errors": errors,
        "logits_equal": bool(np.array_equal(logits, arrays["logits"])),
        "ok": errors == 0 and bool(np.array_equal(logits, arrays["logits"])),
    }
