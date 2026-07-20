#!/usr/bin/env python3
"""Test a reaction-centre CP0 candidate against the corrected B2 baseline.

Only intrinsic input structures and separately exported targets are read.  C1
chooses one nucleophilic nitrogen and one carboxyl carbon without using target
values.  It transfers observations only between reactions run under the exact
same intrinsic environment, using Morgan environments rooted at those two
reactive atoms rather than whole-molecule fingerprints.

C1-RC-KNN is an operational, falsifiable analogue of a CP0 repair rule.  C2
then combines its local estimate with a whole-structure estimate at a fixed
weight selected on the already-open selection compartment.  Neither is
presented as a theorem derived from Core, and neither can extrapolate to an
unseen environment.  The corrected whole-molecule B2 implementation is loaded
from an immutable, hash-pinned script and is reproduced in the same run.
"""

from __future__ import annotations

import argparse
from collections import Counter, defaultdict
import datetime as dt
import gzip
import importlib.metadata
import importlib.util
import json
import math
from pathlib import Path
import platform
import shlex
import sys
from typing import Any


BASE_SCRIPT_SHA256 = (
    "ede5dde8c86e3e0c5b4d62e80df41c270f27431598e413e300449752b626ba24"
)
RADIUS_VALUES = (1, 2, 3)
K_VALUES = (1, 3, 5, 10)
PAIR_RULES = ("mean", "bottleneck", "geometric")
FP_SIZE = 2048
C2_GLOBAL_K = 1
C2_LOCAL_RADIUS = 3
C2_LOCAL_RULE = "mean"
C2_LOCAL_K = 10
C2_LOCAL_WEIGHT = 0.6
BOOTSTRAP_REPLICATES = 10_000
BOOTSTRAP_SEED = 0


class CandidateError(ValueError):
    """The frozen reaction-centre comparison contract was violated."""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--mode",
        required=True,
        choices=("construction-cv", "selection-eval"),
    )
    parser.add_argument("--base-script", required=True, type=Path)
    parser.add_argument("--source-pb-gz", required=True, type=Path)
    parser.add_argument("--i0-manifest-csv-gz", required=True, type=Path)
    parser.add_argument("--ord-schema-python-root", required=True, type=Path)
    parser.add_argument("--construction-targets-csv-gz", required=True, type=Path)
    parser.add_argument("--selection-targets-csv-gz", type=Path)
    parser.add_argument("--selection-targets-sha256")
    parser.add_argument("--out-predictions-csv-gz", required=True, type=Path)
    parser.add_argument("--out-jsonl", required=True, type=Path)
    parser.add_argument("--out-txt", required=True, type=Path)
    parser.add_argument("--out-dependencies-json", required=True, type=Path)
    parser.add_argument("--run-suffix", required=True)
    parser.add_argument("--script-sha256", required=True)
    parser.add_argument("--frozen-run", action="store_true")
    return parser.parse_args()


def load_base(path: Path) -> Any:
    spec = importlib.util.spec_from_file_location("cp0_empirical_v2_pinned", path)
    if spec is None or spec.loader is None:
        raise CandidateError("cannot load pinned empirical base script")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def validate_run(args: argparse.Namespace, base: Any) -> dict[str, Any]:
    script_hash = base.sha256_file(Path(__file__))
    if script_hash != args.script_sha256:
        raise CandidateError("candidate script hash mismatch")
    if base.sha256_file(args.base_script) != BASE_SCRIPT_SHA256:
        raise CandidateError("corrected B2 base-script hash mismatch")
    suffix = f"_{args.run_suffix}"
    endings = {
        args.out_predictions_csv_gz: f"{suffix}.csv.gz",
        args.out_jsonl: f"{suffix}.jsonl",
        args.out_txt: f"{suffix}.txt",
        args.out_dependencies_json: f"{suffix}.json",
    }
    for output, ending in endings.items():
        if not output.name.endswith(ending):
            raise CandidateError(f"output lacks common suffix: {output}")
        if output.exists():
            raise FileExistsError(f"refusing to overwrite {output}")
        output.parent.mkdir(parents=True, exist_ok=True)
    if args.frozen_run and not Path(__file__).stem.endswith(suffix):
        raise CandidateError("frozen script name lacks run suffix")
    if sys.version_info[:2] != (3, 10):
        raise CandidateError(
            f"Python 3.10 required, got {platform.python_version()}"
        )
    if args.source_pb_gz.stat().st_size != base.SOURCE_SIZE:
        raise CandidateError("unexpected source size")
    fixed_hashes = (
        (args.source_pb_gz, base.SOURCE_SHA256, "source"),
        (args.i0_manifest_csv_gz, base.I0_MANIFEST_SHA256, "I0 manifest"),
        (
            args.construction_targets_csv_gz,
            base.CONSTRUCTION_TARGETS_SHA256,
            "construction targets",
        ),
    )
    for path, expected, label in fixed_hashes:
        if base.sha256_file(path) != expected:
            raise CandidateError(f"unexpected {label} hash")
    reaction_pb2 = args.ord_schema_python_root / "ord_schema/proto/reaction_pb2.py"
    if base.sha256_file(reaction_pb2) != base.REACTION_PB2_SHA256:
        raise CandidateError("unexpected reaction_pb2.py hash")
    if args.mode == "construction-cv":
        if args.selection_targets_csv_gz is not None or args.selection_targets_sha256:
            raise CandidateError("construction-cv forbids selection targets")
    else:
        if args.selection_targets_csv_gz is None or not args.selection_targets_sha256:
            raise CandidateError("selection-eval requires selection targets and hash")
        if (
            base.sha256_file(args.selection_targets_csv_gz)
            != args.selection_targets_sha256
        ):
            raise CandidateError("selection-target hash mismatch")
    distributions = {
        name: importlib.metadata.version(name)
        for name in base.EXPECTED_DISTRIBUTIONS
    }
    if distributions != base.EXPECTED_DISTRIBUTIONS:
        raise CandidateError(f"unexpected distributions: {distributions}")
    return {"script_sha256": script_hash, "distributions": distributions}


def amine_center(molecule: Any) -> int:
    candidates = [
        atom.GetIdx()
        for atom in molecule.GetAtoms()
        if atom.GetAtomicNum() == 7
        and not atom.GetIsAromatic()
        and atom.GetFormalCharge() == 0
        and atom.GetTotalNumHs() > 0
    ]
    if len(candidates) != 1:
        raise CandidateError(
            f"expected one input-defined amine centre, got {len(candidates)}"
        )
    return candidates[0]


def acid_center(molecule: Any, pattern: Any) -> int:
    candidates = sorted(
        {match[0] for match in molecule.GetSubstructMatches(pattern)}
    )
    if len(candidates) != 1:
        raise CandidateError(
            f"expected one input-defined carboxyl centre, got {len(candidates)}"
        )
    return candidates[0]


def amine_class(molecule: Any, center: int) -> str:
    atom = molecule.GetAtomWithIdx(center)
    for neighbor in atom.GetNeighbors():
        if neighbor.GetAtomicNum() == 16:
            double_oxygen = sum(
                bond.GetBondTypeAsDouble() >= 1.9
                and bond.GetOtherAtom(neighbor).GetAtomicNum() == 8
                for bond in neighbor.GetBonds()
            )
            if double_oxygen >= 2:
                return "sulfonamide"
    if any(neighbor.GetIsAromatic() for neighbor in atom.GetNeighbors()):
        return "aniline"
    if atom.GetTotalNumHs() >= 2:
        return "primary_aliphatic"
    return "secondary_aliphatic"


def acid_class(molecule: Any, center: int) -> str:
    carbon = molecule.GetAtomWithIdx(center)
    attached = [
        bond.GetOtherAtom(carbon)
        for bond in carbon.GetBonds()
        if bond.GetBondTypeAsDouble() < 1.9
        and bond.GetOtherAtom(carbon).GetAtomicNum() != 8
    ]
    if len(attached) != 1:
        raise CandidateError("carboxyl centre lacks a unique carbon substituent")
    return "aromatic_acid" if attached[0].GetIsAromatic() else "aliphatic_acid"


def build_reactive_maps(
    args: argparse.Namespace,
    base: Any,
    deps: dict[str, Any],
) -> tuple[dict[int, dict[str, tuple[int, ...]]], dict[str, Any]]:
    reaction_pb2 = deps["reaction_pb2"]
    chemistry = deps["Chem"]
    pattern = chemistry.MolFromSmarts("[C;X3](=[O;X1])[O;H1,-1]")
    if pattern is None:
        raise CandidateError("RDKit rejected frozen carboxyl SMARTS")
    generators = {
        radius: deps["rdFingerprintGenerator"].GetMorganGenerator(
            radius=radius,
            fpSize=FP_SIZE,
        )
        for radius in RADIUS_VALUES
    }
    centre_fp: dict[int, dict[str, tuple[int, ...]]] = {
        radius: {} for radius in RADIUS_VALUES
    }
    identities: dict[str, str] = {}
    classes: dict[str, Counter[str]] = {
        "amine": Counter(),
        "carboxylic acid": Counter(),
    }
    selected_centres: dict[tuple[str, str], int] = {}

    for reaction_wire in base.parse_dataset(args.source_pb_gz):
        reaction = base.sanitize_reaction(reaction_wire, reaction_pb2)
        for group in ("amine", "carboxylic acid"):
            for component in reaction.inputs[group].components:
                canonical, role, molecule = base.canonical_component(
                    component,
                    reaction_pb2,
                    chemistry,
                )
                if role != "REACTANT":
                    continue
                identity = base.domain_hash("cp0-molecule-v1", canonical)
                previous = identities.setdefault(identity, canonical)
                if previous != canonical:
                    raise CandidateError("molecule-hash collision")
                key = (group, identity)
                center = (
                    amine_center(molecule)
                    if group == "amine"
                    else acid_center(molecule, pattern)
                )
                old_center = selected_centres.setdefault(key, center)
                if old_center != center:
                    raise CandidateError("non-deterministic reactive-centre selection")
                if identity not in centre_fp[RADIUS_VALUES[0]]:
                    class_name = (
                        amine_class(molecule, center)
                        if group == "amine"
                        else acid_class(molecule, center)
                    )
                    classes[group][class_name] += 1
                    for radius, generator in generators.items():
                        bits = tuple(
                            int(index)
                            for index in generator.GetFingerprint(
                                molecule,
                                fromAtoms=[center],
                            ).GetOnBits()
                        )
                        if not bits:
                            raise CandidateError("empty reactive-centre fingerprint")
                        centre_fp[radius][identity] = bits

    amine_identities = {
        identity for group, identity in selected_centres if group == "amine"
    }
    acid_identities = {
        identity
        for group, identity in selected_centres
        if group == "carboxylic acid"
    }
    if len(amine_identities) != 70 or len(acid_identities) != 66:
        raise CandidateError("unexpected unique partner inventory")
    if amine_identities & acid_identities:
        raise CandidateError("partner roles unexpectedly share an identity")
    for radius in RADIUS_VALUES:
        if set(centre_fp[radius]) != amine_identities | acid_identities:
            raise CandidateError("incomplete reactive-centre fingerprint map")
    audit = {
        "record_type": "reactive_center_audit",
        "amine_species": len(amine_identities),
        "acid_species": len(acid_identities),
        "amine_centres_per_species": 1,
        "acid_centres_per_species": 1,
        "amine_classes": dict(sorted(classes["amine"].items())),
        "acid_classes": dict(sorted(classes["carboxylic acid"].items())),
        "radii": list(RADIUS_VALUES),
        "fingerprint_size": FP_SIZE,
        "centre_choice_uses_targets": False,
        "whole_molecule_fingerprint_used_by_c1": False,
        "environment_hash_used_as_numeric_feature_by_c1": False,
        "environment_role": "exact intrinsic condition gate only",
        "c2_contains_whole_molecule_component": True,
        "c2_configuration_selected_on_open_selection": True,
        "outcome_fields_deserialized_from_source": 0,
    }
    return centre_fp, audit


def pair_similarity(left: float, right: float, rule: str) -> float:
    if rule == "mean":
        return (left + right) / 2.0
    if rule == "bottleneck":
        return min(left, right)
    if rule == "geometric":
        return math.sqrt(max(0.0, left * right))
    raise CandidateError(f"unknown pair rule {rule}")


def c1_predictions(
    train: list[dict[str, Any]],
    evaluation: list[dict[str, Any]],
    centre_fp: dict[int, dict[str, tuple[int, ...]]],
    base: Any,
) -> dict[tuple[int, str, int], list[float]]:
    by_environment: defaultdict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in train:
        by_environment[row["environment"]].append(row)
    predictions = {
        (radius, rule, k): []
        for radius in RADIUS_VALUES
        for rule in PAIR_RULES
        for k in K_VALUES
    }
    similarity_cache: dict[tuple[int, str, str], float] = {}

    def similarity(radius: int, left: str, right: str) -> float:
        key = (radius, left, right)
        reverse = (radius, right, left)
        if key not in similarity_cache:
            value = base.tanimoto(centre_fp[radius][left], centre_fp[radius][right])
            similarity_cache[key] = value
            similarity_cache[reverse] = value
        return similarity_cache[key]

    for row in evaluation:
        environment_candidates = by_environment[row["environment"]]
        if not environment_candidates:
            raise CandidateError("C1 has no exact-condition neighbor")
        for radius in RADIUS_VALUES:
            component_similarities = []
            for candidate in environment_candidates:
                component_similarities.append(
                    (
                        similarity(radius, row["amine"], candidate["amine"]),
                        similarity(radius, row["acid"], candidate["acid"]),
                        candidate["amine"],
                        candidate["acid"],
                        candidate["target"],
                    )
                )
            for rule in PAIR_RULES:
                ranked = [
                    (
                        pair_similarity(amine_sim, acid_sim, rule),
                        amine,
                        acid,
                        target,
                    )
                    for amine_sim, acid_sim, amine, acid, target
                    in component_similarities
                ]
                ranked.sort(key=lambda value: (-value[0], value[1], value[2]))
                for k in K_VALUES:
                    selected = ranked[:k]
                    weights = [max(value[0], 1e-6) ** 2 for value in selected]
                    prediction = sum(
                        weight * value[3]
                        for weight, value in zip(weights, selected)
                    ) / sum(weights)
                    predictions[(radius, rule, k)].append(prediction)
    return predictions


def evaluate(
    train: list[dict[str, Any]],
    evaluation: list[dict[str, Any]],
    whole_fp: dict[str, tuple[int, ...]],
    centre_fp: dict[int, dict[str, tuple[int, ...]]],
    base: Any,
    deps: dict[str, Any],
) -> tuple[
    list[dict[str, Any]],
    list[dict[str, Any]],
    dict[str, Any],
    dict[str, Any],
]:
    np = deps["np"]
    y_train = np.asarray([row["target"] for row in train], dtype=np.float64)
    observed = np.asarray([row["target"] for row in evaluation], dtype=np.float64)
    predictions: dict[tuple[str, str], Any] = {}
    predictions[("B0", "global_mean")] = np.full(
        len(evaluation), float(np.mean(y_train))
    )
    condition_targets: defaultdict[str, list[float]] = defaultdict(list)
    for row in train:
        condition_targets[row["environment"]].append(row["target"])
    predictions[("B1", "condition_mean")] = np.asarray(
        [
            float(np.mean(condition_targets[row["environment"]]))
            for row in evaluation
        ]
    )
    b2_values = base.b2_predictions(train, evaluation, whole_fp)
    for k, values in b2_values.items():
        predictions[("B2", f"k={k}")] = np.asarray(values)
    c1_values = c1_predictions(
        train, evaluation, centre_fp, base
    )
    for (radius, rule, k), values in c1_values.items():
        variant = f"radius={radius},pair={rule},k={k}"
        predictions[("C1-RC-KNN", variant)] = np.asarray(values)
    c2_local = np.asarray(
        c1_values[(C2_LOCAL_RADIUS, C2_LOCAL_RULE, C2_LOCAL_K)]
    )
    c2_global = np.asarray(b2_values[C2_GLOBAL_K])
    c2_variant = (
        f"global_k={C2_GLOBAL_K},local_radius={C2_LOCAL_RADIUS},"
        f"local_pair={C2_LOCAL_RULE},local_k={C2_LOCAL_K},"
        f"local_weight={C2_LOCAL_WEIGHT:g}"
    )
    predictions[("C2-MS-REPAIR", c2_variant)] = (
        (1.0 - C2_LOCAL_WEIGHT) * c2_global
        + C2_LOCAL_WEIGHT * c2_local
    )

    metric_rows = []
    prediction_rows = []
    for (method, variant), raw_predictions in sorted(predictions.items()):
        clipped = np.clip(np.asarray(raw_predictions), 0.0, 100.0)
        metric_rows.append(
            {
                "record_type": "metric",
                "method": method,
                "variant": variant,
                "evaluation_groups": len(evaluation),
                **base.metrics(observed, clipped, deps),
            }
        )
        for row, predicted in zip(evaluation, clipped):
            prediction_rows.append(
                {
                    "amine_sha256": row["amine"],
                    "acid_sha256": row["acid"],
                    "semantic_condition_sha256": row["environment"],
                    "method": method,
                    "variant": variant,
                    "observed": format(row["target"], ".17g"),
                    "predicted": format(float(predicted), ".17g"),
                    "absolute_error": format(
                        abs(float(predicted) - row["target"]), ".17g"
                    ),
                }
            )
    best_b2 = min(
        (row for row in metric_rows if row["method"] == "B2"),
        key=lambda row: (row["mae"], row["variant"]),
    )
    best_c1 = min(
        (row for row in metric_rows if row["method"] == "C1-RC-KNN"),
        key=lambda row: (row["mae"], row["variant"]),
    )
    c1_comparison = {
        "record_type": "candidate_comparison",
        "baseline_method": "B2",
        "baseline_variant": best_b2["variant"],
        "baseline_mae": best_b2["mae"],
        "candidate_method": "C1-RC-KNN",
        "candidate_variant": best_c1["variant"],
        "candidate_mae": best_c1["mae"],
        "candidate_minus_baseline_mae": best_c1["mae"] - best_b2["mae"],
        "candidate_beats_baseline": best_c1["mae"] < best_b2["mae"],
    }
    c2_metric = next(
        row for row in metric_rows if row["method"] == "C2-MS-REPAIR"
    )
    baseline_predictions = predictions[("B2", best_b2["variant"])]
    c2_predictions = predictions[("C2-MS-REPAIR", c2_variant)]
    pair_differences: defaultdict[tuple[str, str], list[float]] = defaultdict(list)
    for row, baseline_prediction, candidate_prediction in zip(
        evaluation,
        baseline_predictions,
        c2_predictions,
    ):
        pair_differences[(row["amine"], row["acid"])].append(
            abs(float(candidate_prediction) - row["target"])
            - abs(float(baseline_prediction) - row["target"])
        )
    clusters = [
        np.asarray(values, dtype=np.float64)
        for _, values in sorted(pair_differences.items())
    ]
    random = np.random.default_rng(BOOTSTRAP_SEED)
    bootstrap = np.empty(BOOTSTRAP_REPLICATES, dtype=np.float64)
    for replicate in range(BOOTSTRAP_REPLICATES):
        indices = random.integers(0, len(clusters), size=len(clusters))
        bootstrap[replicate] = np.mean(
            np.concatenate([clusters[int(index)] for index in indices])
        )
    interval_low, interval_high = np.quantile(bootstrap, (0.025, 0.975))
    c2_delta = c2_metric["mae"] - best_b2["mae"]
    c2_comparison = {
        "record_type": "candidate_comparison",
        "baseline_method": "B2",
        "baseline_variant": best_b2["variant"],
        "baseline_mae": best_b2["mae"],
        "candidate_method": "C2-MS-REPAIR",
        "candidate_variant": c2_metric["variant"],
        "candidate_mae": c2_metric["mae"],
        "candidate_minus_baseline_mae": c2_delta,
        "candidate_beats_baseline": c2_delta < 0.0,
        "required_mae_improvement": 2.0,
        "mae_gate_passed": c2_delta <= -2.0,
        "bootstrap_unit": "amine-acid pair",
        "bootstrap_pairs": len(clusters),
        "bootstrap_replicates": BOOTSTRAP_REPLICATES,
        "bootstrap_seed": BOOTSTRAP_SEED,
        "difference_ci95_low": float(interval_low),
        "difference_ci95_high": float(interval_high),
        "confidence_gate_passed": float(interval_high) < 0.0,
    }
    c2_comparison["protocol_gate_passed"] = bool(
        c2_comparison["mae_gate_passed"]
        and c2_comparison["confidence_gate_passed"]
    )
    return metric_rows, prediction_rows, c1_comparison, c2_comparison


def main() -> None:
    args = parse_args()
    base = load_base(args.base_script)
    provenance = validate_run(args, base)
    deps = base.import_dependencies(args.ord_schema_python_root)
    command = shlex.join(sys.argv)
    run_at = dt.datetime.now(dt.timezone.utc).isoformat()
    whole_fp, _, _, _, input_audit = base.build_intrinsic_maps(
        args.source_pb_gz,
        args.i0_manifest_csv_gz,
        deps,
    )
    input_audit["hashes_used_as_numeric_features_by_c1_rc_knn"] = False
    centre_fp, centre_audit = build_reactive_maps(args, base, deps)
    construction = base.load_targets(args.construction_targets_csv_gz)
    if args.mode == "construction-cv":
        train, evaluation, split_audit = base.internal_bilateral_split(construction)
        selection_targets_opened = False
    else:
        if args.selection_targets_csv_gz is None:
            raise CandidateError("selection path vanished after validation")
        train = construction
        evaluation = base.load_targets(args.selection_targets_csv_gz)
        amine_overlap = len(
            {row["amine"] for row in train}
            & {row["amine"] for row in evaluation}
        )
        acid_overlap = len(
            {row["acid"] for row in train}
            & {row["acid"] for row in evaluation}
        )
        if amine_overlap != 0 or acid_overlap != 0:
            raise CandidateError("selection partner leaked into construction")
        split_audit = {
            "record_type": "evaluation_split",
            "mode": "selection-eval",
            "train_groups": len(train),
            "evaluation_groups": len(evaluation),
            "evaluation_amine_overlap": amine_overlap,
            "evaluation_acid_overlap": acid_overlap,
        }
        selection_targets_opened = True

    metric_rows, prediction_rows, c1_comparison, c2_comparison = evaluate(
        train,
        evaluation,
        whole_fp,
        centre_fp,
        base,
        deps,
    )
    base.write_predictions(args.out_predictions_csv_gz, prediction_rows)
    predictions_hash = base.sha256_file(args.out_predictions_csv_gz)
    if args.mode == "selection-eval":
        verdict = (
            "C2_SELECTION_GATE_PASSED_DEVELOPMENT_ONLY"
            if c2_comparison["protocol_gate_passed"]
            else "NO-GO-PROTOCOL-C2-MS-REPAIR-SELECTION"
        )
    else:
        verdict = "C1_CONSTRUCTION_CV_COMPLETED"
    run_record = {
        "record_type": "run",
        "command": command,
        "run_at_utc": run_at,
        "mode": args.mode,
        "script_sha256": provenance["script_sha256"],
        "base_script_sha256": BASE_SCRIPT_SHA256,
        "construction_targets_sha256": base.CONSTRUCTION_TARGETS_SHA256,
        "selection_targets_sha256": args.selection_targets_sha256,
        "selection_targets_opened": selection_targets_opened,
        "selection_is_development_for_c1_and_c2": True,
        "c2_configuration_selected_after_selection_was_opened": True,
        "held_out_test_targets_opened": False,
        "predictions_csv_gz_sha256": predictions_hash,
        "verdict": verdict,
    }
    with args.out_jsonl.open("x", encoding="utf-8", newline="\n") as handle:
        for record in (
            run_record,
            input_audit,
            centre_audit,
            split_audit,
            *metric_rows,
            c1_comparison,
            c2_comparison,
        ):
            handle.write(base.canonical_json(record) + "\n")

    dependencies = {
        "command": command,
        "python_version": platform.python_version(),
        "script_sha256": provenance["script_sha256"],
        "base_script_sha256": BASE_SCRIPT_SHA256,
        "source_sha256": base.SOURCE_SHA256,
        "i0_manifest_sha256": base.I0_MANIFEST_SHA256,
        "reaction_pb2_sha256": base.REACTION_PB2_SHA256,
        "construction_targets_sha256": base.CONSTRUCTION_TARGETS_SHA256,
        "selection_targets_sha256": args.selection_targets_sha256,
        "distributions": provenance["distributions"],
        "wheel_sha256": base.WHEEL_SHA256,
    }
    with args.out_dependencies_json.open(
        "x", encoding="utf-8", newline="\n"
    ) as handle:
        json.dump(dependencies, handle, indent=2, sort_keys=True)
        handle.write("\n")

    ranked = sorted(
        metric_rows,
        key=lambda row: (row["mae"], row["method"], row["variant"]),
    )
    summary = [
        f"command: {command}",
        f"script_sha256: {provenance['script_sha256']}",
        f"base_script_sha256: {BASE_SCRIPT_SHA256}",
        f"mode: {args.mode}",
        f"run_at_utc: {run_at}",
        f"train_groups: {len(train)}",
        f"evaluation_groups: {len(evaluation)}",
        f"selection_targets_opened: {str(selection_targets_opened).lower()}",
        "held_out_test_targets_opened: false",
        f"predictions_csv_gz_sha256: {predictions_hash}",
    ]
    for row in ranked:
        summary.append(
            f"{row['method']} {row['variant']} MAE={row['mae']:.8f} "
            f"RMSE={row['rmse']:.8f} Spearman={row['spearman']:.8f}"
        )
    summary.extend(
        (
            "c1_minus_baseline_mae: "
            f"{c1_comparison['candidate_minus_baseline_mae']:.8f}",
            "c2_minus_baseline_mae: "
            f"{c2_comparison['candidate_minus_baseline_mae']:.8f}",
            "c2_difference_ci95: "
            f"[{c2_comparison['difference_ci95_low']:.8f}, "
            f"{c2_comparison['difference_ci95_high']:.8f}]",
            f"verdict: {verdict}",
        )
    )
    args.out_txt.write_text("\n".join(summary) + "\n", encoding="utf-8")
    print(summary[-1])


if __name__ == "__main__":
    main()
