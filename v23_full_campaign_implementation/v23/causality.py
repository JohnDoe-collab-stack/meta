"""Paired causal certificates recomputed from intervention records."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Iterable

from .interventions import CAUSAL_ORDER, INTERVENTIONS
from .statistics import exact_sign_flip_pvalue, hierarchical_paired_bootstrap


def load_jsonl(path: str | Path) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    with Path(path).open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            try:
                record = json.loads(line)
            except json.JSONDecodeError as error:
                raise ValueError(f"invalid JSON at line {line_number}: {error}") from error
            if not isinstance(record, dict):
                raise ValueError(f"line {line_number} is not an object")
            records.append(record)
    return records


def certify_paired_causality(
    records: Iterable[dict[str, Any]],
    expected_seeds: tuple[int, ...] = tuple(range(10)),
    expected_episodes_per_seed: int = 4096,
) -> dict[str, Any]:
    violations: list[str] = []
    by_intervention: dict[str, dict[int, list[float]]] = {}
    count = 0
    for index, record in enumerate(records):
        count += 1
        intervention_id = record.get("intervention_id")
        if intervention_id not in INTERVENTIONS:
            violations.append(f"record {index}: unknown intervention")
            continue
        spec = INTERVENTIONS[intervention_id]
        fixed = tuple(record.get("fixed_variables", ()))
        recomputed = tuple(record.get("recomputed_variables", ()))
        if fixed != spec.fixed_variables or recomputed != spec.recomputed_variables:
            violations.append(f"record {index}: invalid causal partition")
        if set(fixed) & set(recomputed) or set(fixed) | set(recomputed) != set(CAUSAL_ORDER):
            violations.append(f"record {index}: incomplete causal partition")
        try:
            seed = int(record["seed"])
            control = int(record["control_score_micros"])
            intervened = int(record["intervened_score_micros"])
        except (KeyError, TypeError, ValueError):
            violations.append(f"record {index}: malformed scores or seed")
            continue
        if not (0 <= control <= 1_000_000 and 0 <= intervened <= 1_000_000):
            violations.append(f"record {index}: score outside [0, 1]")
            continue
        effect = (control - intervened) / 1_000_000
        by_intervention.setdefault(intervention_id, {}).setdefault(seed, []).append(effect)
    summaries: dict[str, Any] = {}
    for intervention_id in sorted(by_intervention):
        by_seed = by_intervention[intervention_id]
        seed_effects = [sum(values) / len(values) for _, values in sorted(by_seed.items())]
        summaries[intervention_id] = {
            "bootstrap": hierarchical_paired_bootstrap(by_seed),
            "sign_flip_p_micros": int(
                round(exact_sign_flip_pvalue(seed_effects, "greater") * 1_000_000)
            ),
            "seed_effects_micros": tuple(
                int(round(value * 1_000_000)) for value in seed_effects
            ),
        }
    missing = tuple(sorted(set(INTERVENTIONS) - set(by_intervention)))
    coverage_violations: list[str] = []
    for intervention_id in INTERVENTIONS:
        seed_map = by_intervention.get(intervention_id, {})
        if set(seed_map) != set(expected_seeds):
            coverage_violations.append(
                f"{intervention_id}: seed coverage {sorted(seed_map)} != {list(expected_seeds)}"
            )
            continue
        for seed in expected_seeds:
            if len(seed_map[seed]) != expected_episodes_per_seed:
                coverage_violations.append(
                    f"{intervention_id} seed {seed}: {len(seed_map[seed])} episodes != {expected_episodes_per_seed}"
                )
    return {
        "schema": "v23-causality-certificate-1",
        "records": count,
        "summaries": summaries,
        "missing_interventions": missing,
        "expected_seeds": expected_seeds,
        "expected_episodes_per_seed": expected_episodes_per_seed,
        "coverage_violations": tuple(coverage_violations),
        "violations": tuple(violations),
        "complete": not missing and not violations and not coverage_violations,
    }
