from __future__ import annotations
import argparse
import json
from pathlib import Path

from verify_bridge_aslmt_v22 import verify


def _read_jsonl(path: Path) -> list[dict]:
    rows: list[dict] = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def _mutate(rows: list[dict], mutation: str) -> list[dict]:
    out = json.loads(json.dumps(rows))
    if mutation == "hide_infinite_scope":
        for row in out:
            if row.get("kind") == "infinite_schema_bridge":
                row["scope"] = "unbounded empirical infinity"
                return out
    if mutation == "erase_dimension_negative_control":
        return [row for row in out if row.get("kind") != "dimension_negative_control"]
    if mutation == "turn_baseline_into_success":
        for row in out:
            if row.get("kind") == "local_global_bridge":
                row["observed"]["B_image_only_both_rate"] = 1.0
                return out
    if mutation == "lower_z_accuracy":
        for row in out:
            if row.get("kind") == "perceptual_learning_gate":
                row["observed"]["metrics"]["z_acc"] = 0.5
                return out
    if mutation == "break_lean_schema_domain":
        for row in out:
            if row.get("kind") == "infinite_schema_contract":
                row["ctx_domain"] = "FinPrefix"
                return out
    if mutation == "claim_global_exhaustion":
        for row in out:
            if row.get("kind") == "local_global_infinite_cover_schema":
                row["finite_exhaustive_global_reduction"] = True
                return out
    if mutation == "break_dynamic_elimination_count":
        for row in out:
            if row.get("kind") == "dynamic_infinite_zero_elimination_schema":
                row["zero_coordinate_case_count_per_ctx_time"] = 0
                return out
    raise ValueError(f"unknown mutation: {mutation}")


def main() -> int:
    p = argparse.ArgumentParser(description="Falsify v22 bridge verifier by injecting required bad certificates.")
    p.add_argument("--cert-jsonl", type=Path, required=True)
    p.add_argument("--out-json", type=Path, required=True)
    args = p.parse_args()

    rows = _read_jsonl(args.cert_jsonl)
    results = {}
    for mutation in (
        "hide_infinite_scope",
        "erase_dimension_negative_control",
        "turn_baseline_into_success",
        "lower_z_accuracy",
        "break_lean_schema_domain",
        "claim_global_exhaustion",
        "break_dynamic_elimination_count",
    ):
        report, violations = verify(_mutate(rows, mutation))
        results[mutation] = {"rejected": not bool(report["ok"]), "violation_count": len(violations)}
    final = {"ok": all(item["rejected"] for item in results.values()), "mutations": results}
    args.out_json.parent.mkdir(parents=True, exist_ok=True)
    args.out_json.write_text(json.dumps(final, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps(final, indent=2, sort_keys=True))
    return 0 if final["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())


