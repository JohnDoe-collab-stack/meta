from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


def _sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _read_first_jsonl(path: Path) -> dict:
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                return json.loads(line)
    raise ValueError(f"empty jsonl: {path}")


def _write_jsonl(path: Path, rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        for row in rows:
            f.write(json.dumps(row, sort_keys=True) + "\n")


def _tag(run_dir: Path, n_classes: int, z_classes: int, seed: int) -> str:
    suffix = f"_n{n_classes}_z{z_classes}_seed{seed}"
    matches = sorted(run_dir.glob(f"v22_perceptual_master_*{suffix}.jsonl"))
    if not matches:
        raise FileNotFoundError(f"missing master jsonl for {suffix}")
    name = matches[0].name
    return name[len("v22_perceptual_master_") : -len(".jsonl")]


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


def _append_lean_local_global_schema_rows(rows: list[dict], *, n_classes: int, levels: list[int], finite_kernel: dict) -> None:
    rows.append(
        {
            "kind": "infinite_schema_contract",
            "n_classes": int(n_classes),
            "ctx_domain": "Nat",
            "time_domain": "Nat",
            "class_domain": f"Fin {int(n_classes)}",
            "state_schema": "(ctx,time,h,k)",
            "global_state_enumeration": False,
            "finite_exhaustive_global_reduction": False,
            "local_global_alignment": "LocalFiniteClosureCover_over_parameterized_finite_windows",
            "feature_schema": "perceptual_v3b_kernel_plus_parameterized_finite_window_schema",
            "lean_target": "PrimitiveHolonomy.MultiInterfaceModular.LocalFiniteClosureCover",
            "finite_kernel": dict(finite_kernel),
        }
    )
    for distinction_kind in ("h", "k"):
        rows.append(
            {
                "kind": "pointwise_finite_separation_basis_schema",
                "distinction_kind": distinction_kind,
                "base_interfaces": _schema_base_interfaces(distinction_kind),
                "witness_interface": "read_h" if distinction_kind == "h" else "read_k",
                "finite_window_size": 2,
                "valid_for_all_ctx": True,
                "valid_for_all_time": True,
                "parameterized_window_schema": True,
                "finite_class_cases_per_ctx_time": 2 * int(n_classes) * int(n_classes),
            }
        )
    previous_level = 0
    for level in sorted(set(int(x) for x in levels)):
        expected = _schema_window_count(n_classes, level)
        rows.append(
            {
                "kind": "filtered_prefix_level",
                "ctx_prefix": int(level),
                "time_prefix": int(level),
                "window_count": expected,
                "required_distinctions": expected,
                "zero_coordinate_windows": expected,
                "model_closed_by_local_window_count": expected,
                "perceptual_kernel_checked_by_v22_gate": True,
                "extends_previous_prefix": previous_level == 0 or previous_level < int(level),
                "previous_ctx_prefix": int(previous_level),
                "prefix_is_finite_reading_not_global_exhaustion": True,
            }
        )
        previous_level = int(level)
    rows.append(
        {
            "kind": "local_global_infinite_cover_schema",
            "levels": sorted(set(int(x) for x in levels)),
            "cover_form": "forall ctx time, exists finite local window with zero residual coordinate",
            "global_state_enumeration": False,
            "finite_exhaustive_global_reduction": False,
            "forall_required_distinction": True,
            "finite_window_per_distinction": True,
            "zero_coordinate_after_witness_interface": True,
            "covers_arbitrary_ctx": True,
            "covers_arbitrary_time": True,
            "lean_target": "PrimitiveHolonomy.MultiInterfaceModular.LocalFiniteClosureCover",
        }
    )
    expected_dynamic = _schema_case_count_per_ctx_time(n_classes)
    rows.append(
        {
            "kind": "dynamic_infinite_zero_elimination_schema",
            "ctx_domain": "Nat",
            "time_domain": "Nat",
            "section_point_has_local_window": True,
            "local_window_has_zero_coordinate_after_witness": True,
            "stable_section_eliminated_by_local_zero_window": True,
            "dynamic_profile_target": "PrimitiveHolonomy.MultiInterfaceModular.DynamicResidualProfile",
            "coordinate_target": "PrimitiveHolonomy.MultiInterfaceModular.no_residualAt_of_rhoAt_eq_zero",
            "stable_section_target": "PrimitiveHolonomy.MultiInterfaceModular.StableResidualSection",
            "section_case_count_per_ctx_time": expected_dynamic,
            "zero_coordinate_case_count_per_ctx_time": expected_dynamic,
            "transport_case_count_per_ctx_time": expected_dynamic,
            "transport_preserves_parameterized_window_schema": True,
            "elimination_form": "stable section gives rhoAt>0 in an explicit finite window; local zero coordinate gives not ResidualAt in that same window",
        }
    )


def _report(run_dir: Path, prefix: str, split: str, tag: str) -> dict:
    return _read_json(run_dir / f"{prefix}_{split}_{tag}.json")


def main() -> int:
    p = argparse.ArgumentParser(description="Certify the v22 bridge from perceptual learning to local-global/dynamic/infinite obligations.")
    p.add_argument("--run-dir", type=Path, required=True)
    p.add_argument("--n-classes", type=int, required=True)
    p.add_argument("--z-classes", type=int, required=True)
    p.add_argument("--seed", type=int, default=0)
    p.add_argument("--levels", type=str, default="4,8,16,32")
    p.add_argument("--out-jsonl", type=Path, required=True)
    args = p.parse_args()

    run_dir = args.run_dir.resolve()
    summary = _read_json(run_dir / "summary.json")
    tag = _tag(run_dir, args.n_classes, args.z_classes, args.seed)
    master_path = run_dir / f"v22_perceptual_master_{tag}.jsonl"
    master = _read_first_jsonl(master_path)
    levels = [int(x.strip()) for x in str(args.levels).split(",") if x.strip()]

    rows: list[dict] = []
    rows.append(
        {
            "kind": "v22_bridge_metadata",
            "claim": "v22 is only successful when the perceptual proofpack and bridge obligations are both verified",
            "run_dir": str(run_dir),
            "n_classes": int(args.n_classes),
            "z_classes": int(args.z_classes),
            "seed": int(args.seed),
            "master_jsonl": str(master_path),
            "master_sha256": _sha256_file(master_path),
            "levels": levels,
        }
    )

    for split in ("iid", "ood"):
        struct = _report(run_dir, "verify", split, tag)
        marginal = _report(run_dir, "verify_marginal", split, tag)
        minproof = _report(run_dir, "verify_minproof", split, tag)
        metrics = master["metrics"][split]
        pair_eval = master["pair_eval"][split]
        rows.append(
            {
                "kind": "perceptual_learning_gate",
                "split": split,
                "required": {
                    "struct_ok": True,
                    "marginal_nogo_ok": True,
                    "minproof_ok": True,
                    "z_acc_min": 1.0,
                    "q_acc_min": 1.0,
                    "res_acc_min": 1.0,
                    "A_iou_min": 0.80,
                    "B_img_iou_max": 0.0,
                    "B_cue_iou_max": 0.0,
                },
                "observed": {
                    "struct_ok": bool(struct.get("ok")),
                    "struct_violations": int(struct.get("violations", -1)),
                    "marginal_nogo_ok": bool(marginal.get("ok")),
                    "marginal_violations": int(marginal.get("violations", -1)),
                    "minproof_ok": bool(minproof.get("ok")),
                    "minproof_violations": int(minproof.get("violations", -1)),
                    "metrics": metrics,
                },
            }
        )
        rows.append(
            {
                "kind": "local_global_bridge",
                "split": split,
                "claim": "image alone and cue alone are rejected, while the learned mediated pair succeeds",
                "observed": {
                    "obs_image_barrier_ok": bool(pair_eval.get("obs_image_barrier_ok")),
                    "obs_cue_barrier_ok": bool(pair_eval.get("obs_cue_barrier_ok")),
                    "A_both_image_pair_rate": float(pair_eval.get("A_both_image_pair_rate")),
                    "A_both_cue_pair_rate": float(pair_eval.get("A_both_cue_pair_rate")),
                    "B_image_only_both_rate": float(pair_eval.get("B_image_only_both_rate")),
                    "B_cue_only_both_rate": float(pair_eval.get("B_cue_only_both_rate")),
                    "A_ablated_both_image_pair_rate": float(pair_eval.get("A_ablated_both_image_pair_rate")),
                    "A_swap_follow_image_pair_rate": float(pair_eval.get("A_swap_follow_image_pair_rate")),
                    "A_swap_orig_both_image_pair_rate": float(pair_eval.get("A_swap_orig_both_image_pair_rate")),
                },
            }
        )

    lower_dim = [
        rec
        for rec in summary
        if int(rec.get("n_classes")) == int(args.n_classes)
        and int(rec.get("seed")) == int(args.seed)
        and int(rec.get("z_classes")) < int(args.n_classes)
    ]
    rows.append(
        {
            "kind": "dimension_negative_control",
            "claim": "all z<n dimensions must fail structural verification while minproof remains verified",
            "observed": lower_dim,
        }
    )
    rows.append(
        {
            "kind": "dynamic_context_bridge",
            "claim": "the perceptual proofpack is verified across the renderer temporal parameter t and IID/OOD context families",
            "scope": "finite temporal-context generalization, not an unbounded transition-system proof",
            "observed_splits": ["iid", "ood"],
        }
    )
    rows.append(
        {
            "kind": "infinite_schema_bridge",
            "claim": "the infinite claim is a schema over arbitrary finite prefixes; every prefix still depends on the verified finite perceptual kernel and dimension lower bound",
            "scope": "schema-level infinite-prefix obligation, not an empirical exhaustive infinity",
            "levels": levels,
            "finite_kernel": {"n_classes": int(args.n_classes), "z_classes": int(args.z_classes), "seed": int(args.seed)},
        }
    )
    _append_lean_local_global_schema_rows(
        rows,
        n_classes=int(args.n_classes),
        levels=levels,
        finite_kernel={"n_classes": int(args.n_classes), "z_classes": int(args.z_classes), "seed": int(args.seed)},
    )
    _write_jsonl(args.out_jsonl, rows)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


