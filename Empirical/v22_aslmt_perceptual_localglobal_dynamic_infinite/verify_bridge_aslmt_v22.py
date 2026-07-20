from __future__ import annotations
import argparse
import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any


@dataclass(frozen=True)
class Violation:
    kind: str
    detail: str
    payload: dict


def _read_jsonl(path: Path) -> list[dict]:
    rows: list[dict] = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def _fail(vios: list[Violation], kind: str, detail: str, payload: dict | None = None) -> None:
    vios.append(Violation(kind=kind, detail=detail, payload={} if payload is None else payload))


def _verify_perceptual(row: dict, vios: list[Violation]) -> None:
    obs = row.get("observed", {})
    metrics = obs.get("metrics", {})
    split = str(row.get("split"))
    if not obs.get("struct_ok") or int(obs.get("struct_violations", -1)) != 0:
        _fail(vios, "perceptual_learning_gate", f"{split}: structural verifier did not pass", obs)
    if not obs.get("marginal_nogo_ok") or int(obs.get("marginal_violations", -1)) != 0:
        _fail(vios, "perceptual_learning_gate", f"{split}: marginal no-go verifier did not pass", obs)
    if not obs.get("minproof_ok") or int(obs.get("minproof_violations", -1)) != 0:
        _fail(vios, "perceptual_learning_gate", f"{split}: minproof verifier did not pass", obs)
    if float(metrics.get("z_acc", -1.0)) < 1.0:
        _fail(vios, "perceptual_learning_gate", f"{split}: z_acc below 1.0", metrics)
    if float(metrics.get("q_acc", -1.0)) < 1.0:
        _fail(vios, "perceptual_learning_gate", f"{split}: q_acc below 1.0", metrics)
    if float(metrics.get("res_acc", -1.0)) < 1.0:
        _fail(vios, "perceptual_learning_gate", f"{split}: res_acc below 1.0", metrics)
    if float(metrics.get("A_iou", -1.0)) < 0.80:
        _fail(vios, "perceptual_learning_gate", f"{split}: A_iou below 0.80", metrics)
    if float(metrics.get("B_img_iou", 1.0)) != 0.0 or float(metrics.get("B_cue_iou", 1.0)) != 0.0:
        _fail(vios, "perceptual_learning_gate", f"{split}: trivial baselines are not zero", metrics)


def _verify_localglobal(row: dict, vios: list[Violation]) -> None:
    obs = row.get("observed", {})
    split = str(row.get("split"))
    exact = {
        "obs_image_barrier_ok": True,
        "obs_cue_barrier_ok": True,
        "A_both_image_pair_rate": 1.0,
        "A_both_cue_pair_rate": 1.0,
        "B_image_only_both_rate": 0.0,
        "B_cue_only_both_rate": 0.0,
        "A_ablated_both_image_pair_rate": 0.0,
        "A_swap_follow_image_pair_rate": 1.0,
        "A_swap_orig_both_image_pair_rate": 0.0,
    }
    for key, expected in exact.items():
        got = obs.get(key)
        if isinstance(expected, bool):
            ok = bool(got) is expected
        else:
            ok = float(got) == float(expected)
        if not ok:
            _fail(vios, "local_global_bridge", f"{split}: {key} expected {expected!r}, got {got!r}", obs)


def _verify_dimension(row: dict, n_classes: int, vios: list[Violation]) -> None:
    seen: set[tuple[int, str]] = set()
    for rec in row.get("observed", []):
        z = int(rec.get("z_classes", -1))
        split = str(rec.get("split"))
        seen.add((z, split))
        if z >= int(n_classes):
            _fail(vios, "dimension_negative_control", "lower-dimension row is not lower-dimensional", rec)
        if int(rec.get("rc_verify_struct", 0)) == 0:
            _fail(vios, "dimension_negative_control", "z<n structural verifier unexpectedly passed", rec)
        if int(rec.get("rc_verify_minproof", 1)) != 0:
            _fail(vios, "dimension_negative_control", "z<n minproof verifier did not verify the collision witness", rec)
    expected = {(z, split) for z in range(1, int(n_classes)) for split in ("iid", "ood")}
    missing = sorted(expected - seen)
    if missing:
        _fail(vios, "dimension_negative_control", "missing lower-dimension controls", {"missing": missing})


def _schema_base_interfaces(distinction_kind: str) -> list[str]:
    if distinction_kind == "h":
        return ["image", "wrong_constant"]
    if distinction_kind == "k":
        return ["cue", "wrong_constant"]
    raise ValueError(f"unknown schema distinction kind: {distinction_kind}")


def _schema_window_count(n_classes: int, level: int) -> int:
    return 4 * int(n_classes) * int(n_classes) * int(level) * int(level)


def _schema_case_count_per_ctx_time(n_classes: int) -> int:
    return 4 * int(n_classes) * int(n_classes)


def _verify_lean_infinite_schema(rows: list[dict], n_classes: int, vios: list[Violation]) -> None:
    contract = next((r for r in rows if r.get("kind") == "infinite_schema_contract"), None)
    if contract is None:
        _fail(vios, "infinite_schema_contract", "missing Lean-aligned infinite schema contract", {})
        return
    if contract.get("ctx_domain") != "Nat" or contract.get("time_domain") != "Nat":
        _fail(vios, "infinite_schema_contract", "schema is not over ctx : Nat and time : Nat", contract)
    if contract.get("global_state_enumeration") is not False:
        _fail(vios, "infinite_schema_contract", "schema claims or requires global state enumeration", contract)
    if contract.get("finite_exhaustive_global_reduction") is not False:
        _fail(vios, "infinite_schema_contract", "schema uses finite exhaustive global reduction", contract)
    if contract.get("local_global_alignment") != "LocalFiniteClosureCover_over_parameterized_finite_windows":
        _fail(vios, "infinite_schema_contract", "schema is not aligned with LocalFiniteClosureCover", contract)
    if contract.get("lean_target") != "PrimitiveHolonomy.MultiInterfaceModular.LocalFiniteClosureCover":
        _fail(vios, "infinite_schema_contract", "wrong Lean target", contract)

    basis_by_kind = {str(r.get("distinction_kind")): r for r in rows if r.get("kind") == "pointwise_finite_separation_basis_schema"}
    for distinction_kind in ("h", "k"):
        basis = basis_by_kind.get(distinction_kind)
        if basis is None:
            _fail(vios, "pointwise_finite_separation_basis_schema", f"missing {distinction_kind} basis", {})
            continue
        expected_witness = "read_h" if distinction_kind == "h" else "read_k"
        if basis.get("witness_interface") != expected_witness:
            _fail(vios, "pointwise_finite_separation_basis_schema", "wrong witness interface", basis)
        if list(basis.get("base_interfaces", [])) != _schema_base_interfaces(distinction_kind):
            _fail(vios, "pointwise_finite_separation_basis_schema", "wrong base interfaces", basis)
        if not basis.get("valid_for_all_ctx") or not basis.get("valid_for_all_time"):
            _fail(vios, "pointwise_finite_separation_basis_schema", "basis is not universal over ctx/time", basis)
        if not basis.get("parameterized_window_schema"):
            _fail(vios, "pointwise_finite_separation_basis_schema", "basis is not parameterized by finite windows", basis)
        if int(basis.get("finite_window_size", 0)) != 2:
            _fail(vios, "pointwise_finite_separation_basis_schema", "finite window size is not two", basis)
        if int(basis.get("finite_class_cases_per_ctx_time", -1)) != 2 * int(n_classes) * int(n_classes):
            _fail(vios, "pointwise_finite_separation_basis_schema", "bad finite class case count", basis)

    previous_level = 0
    prefix_rows = [r for r in rows if r.get("kind") == "filtered_prefix_level"]
    if not prefix_rows:
        _fail(vios, "filtered_prefix_level", "missing filtered finite-prefix readings", {})
    for row in prefix_rows:
        level = int(row.get("ctx_prefix", 0))
        time_prefix = int(row.get("time_prefix", 0))
        expected = _schema_window_count(n_classes, level)
        if level <= 0 or time_prefix != level:
            _fail(vios, "filtered_prefix_level", "prefix must be positive and square ctx/time", row)
        if previous_level != 0 and level <= previous_level:
            _fail(vios, "filtered_prefix_level", "prefix is not strictly extending", row)
        if int(row.get("window_count", -1)) != expected:
            _fail(vios, "filtered_prefix_level", "window count not recomputed", row)
        if int(row.get("required_distinctions", -1)) != expected:
            _fail(vios, "filtered_prefix_level", "required distinction count not recomputed", row)
        if int(row.get("zero_coordinate_windows", -1)) != expected:
            _fail(vios, "filtered_prefix_level", "zero-coordinate count not recomputed", row)
        if int(row.get("model_closed_by_local_window_count", -1)) != expected:
            _fail(vios, "filtered_prefix_level", "perceptual kernel is not recorded as closing all local windows", row)
        if not row.get("perceptual_kernel_checked_by_v22_gate"):
            _fail(vios, "filtered_prefix_level", "prefix is detached from v22 perceptual gate", row)
        if not row.get("prefix_is_finite_reading_not_global_exhaustion"):
            _fail(vios, "filtered_prefix_level", "prefix claims global exhaustion", row)
        previous_level = level

    local_global = next((r for r in rows if r.get("kind") == "local_global_infinite_cover_schema"), None)
    if local_global is None:
        _fail(vios, "local_global_infinite_cover_schema", "missing local-global schema cover", {})
    else:
        required_flags = (
            "forall_required_distinction",
            "finite_window_per_distinction",
            "zero_coordinate_after_witness_interface",
            "covers_arbitrary_ctx",
            "covers_arbitrary_time",
        )
        if not all(local_global.get(key) for key in required_flags):
            _fail(vios, "local_global_infinite_cover_schema", "schema cover is not total", local_global)
        if local_global.get("global_state_enumeration") is not False:
            _fail(vios, "local_global_infinite_cover_schema", "cover uses global enumeration", local_global)
        if local_global.get("finite_exhaustive_global_reduction") is not False:
            _fail(vios, "local_global_infinite_cover_schema", "cover uses finite exhaustive reduction", local_global)
        if local_global.get("cover_form") != "forall ctx time, exists finite local window with zero residual coordinate":
            _fail(vios, "local_global_infinite_cover_schema", "wrong cover form", local_global)
        if local_global.get("lean_target") != "PrimitiveHolonomy.MultiInterfaceModular.LocalFiniteClosureCover":
            _fail(vios, "local_global_infinite_cover_schema", "wrong Lean target", local_global)

    dynamic = next((r for r in rows if r.get("kind") == "dynamic_infinite_zero_elimination_schema"), None)
    if dynamic is None:
        _fail(vios, "dynamic_infinite_zero_elimination_schema", "missing dynamic infinite elimination schema", {})
    else:
        expected_dynamic = _schema_case_count_per_ctx_time(n_classes)
        required_flags = (
            "section_point_has_local_window",
            "local_window_has_zero_coordinate_after_witness",
            "stable_section_eliminated_by_local_zero_window",
            "transport_preserves_parameterized_window_schema",
        )
        if not all(dynamic.get(key) for key in required_flags):
            _fail(vios, "dynamic_infinite_zero_elimination_schema", "dynamic schema does not eliminate stable sections", dynamic)
        if dynamic.get("dynamic_profile_target") != "PrimitiveHolonomy.MultiInterfaceModular.DynamicResidualProfile":
            _fail(vios, "dynamic_infinite_zero_elimination_schema", "wrong dynamic profile target", dynamic)
        if dynamic.get("coordinate_target") != "PrimitiveHolonomy.MultiInterfaceModular.no_residualAt_of_rhoAt_eq_zero":
            _fail(vios, "dynamic_infinite_zero_elimination_schema", "wrong coordinate target", dynamic)
        if dynamic.get("stable_section_target") != "PrimitiveHolonomy.MultiInterfaceModular.StableResidualSection":
            _fail(vios, "dynamic_infinite_zero_elimination_schema", "wrong stable-section target", dynamic)
        for key in ("section_case_count_per_ctx_time", "zero_coordinate_case_count_per_ctx_time", "transport_case_count_per_ctx_time"):
            if int(dynamic.get(key, -1)) != expected_dynamic:
                _fail(vios, "dynamic_infinite_zero_elimination_schema", f"{key} not recomputed", dynamic)
        if dynamic.get("elimination_form") != "stable section gives rhoAt>0 in an explicit finite window; local zero coordinate gives not ResidualAt in that same window":
            _fail(vios, "dynamic_infinite_zero_elimination_schema", "wrong elimination form", dynamic)


def verify(rows: list[dict]) -> tuple[dict, list[Violation]]:
    vios: list[Violation] = []
    kinds = [str(r.get("kind")) for r in rows]
    required = {
        "v22_bridge_metadata",
        "perceptual_learning_gate",
        "local_global_bridge",
        "dimension_negative_control",
        "dynamic_context_bridge",
        "infinite_schema_bridge",
        "infinite_schema_contract",
        "pointwise_finite_separation_basis_schema",
        "filtered_prefix_level",
        "local_global_infinite_cover_schema",
        "dynamic_infinite_zero_elimination_schema",
    }
    for kind in required:
        if kind not in kinds:
            _fail(vios, "manifest", f"missing certificate kind: {kind}", {})

    meta = next((r for r in rows if r.get("kind") == "v22_bridge_metadata"), {})
    n_classes = int(meta.get("n_classes", 0))
    z_classes = int(meta.get("z_classes", -1))
    if n_classes <= 0 or z_classes != n_classes:
        _fail(vios, "v22_bridge_metadata", "v22 final gate requires z_classes == n_classes > 0", meta)

    for row in rows:
        kind = row.get("kind")
        if kind == "perceptual_learning_gate":
            _verify_perceptual(row, vios)
        elif kind == "local_global_bridge":
            _verify_localglobal(row, vios)
        elif kind == "dimension_negative_control":
            _verify_dimension(row, n_classes, vios)
        elif kind == "dynamic_context_bridge":
            if row.get("scope") != "finite temporal-context generalization, not an unbounded transition-system proof":
                _fail(vios, "dynamic_context_bridge", "scope text was changed or hidden", row)
        elif kind == "infinite_schema_bridge":
            if row.get("scope") != "schema-level infinite-prefix obligation, not an empirical exhaustive infinity":
                _fail(vios, "infinite_schema_bridge", "scope text was changed or hidden", row)

    if n_classes > 0:
        _verify_lean_infinite_schema(rows, n_classes, vios)

    report = {
        "ok": len(vios) == 0,
        "violation_count": len(vios),
        "kinds": {kind: kinds.count(kind) for kind in sorted(set(kinds))},
        "meaning": "ok=True means v22 passed perceptual learning, negative controls, local-global bridge, dynamic finite-context scope, and the Lean-aligned infinite local-window schema.",
    }
    return report, vios


def main() -> int:
    p = argparse.ArgumentParser(description="Verify v22 bridge certificates.")
    p.add_argument("--cert-jsonl", type=Path, required=True)
    p.add_argument("--out-json", type=Path, required=True)
    p.add_argument("--violations-jsonl", type=Path, required=True)
    args = p.parse_args()
    report, vios = verify(_read_jsonl(args.cert_jsonl))
    args.out_json.parent.mkdir(parents=True, exist_ok=True)
    args.out_json.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    with open(args.violations_jsonl, "w", encoding="utf-8") as f:
        for vio in vios:
            f.write(json.dumps(asdict(vio), sort_keys=True) + "\n")
    print(json.dumps(report, indent=2, sort_keys=True))
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())


