#!/usr/bin/env python3
"""Independent verifier for the finite visible-factorization no-go."""

from __future__ import annotations

import argparse
import sys
from fractions import Fraction
from itertools import product
from pathlib import Path
from typing import Any, Sequence

from finite_reference_domain_v23 import INDICES, VALUES
from trace_schema_v23 import canonical_json, canonical_sha256, parse_json_strict


def _actions() -> tuple[tuple[str, str, str, str], ...]:
    patches = [("keep", "_", "_")] + [
        ("set", index.value, value.value) for index in INDICES for value in VALUES
    ]
    return tuple(
        (query.value, patch_kind, patch_index, patch_value)
        for query in INDICES
        for patch_kind, patch_index, patch_value in patches
    )


def _summary(actions: tuple[Any, ...], required: tuple[Any, Any]) -> dict[str, Any]:
    rows = []
    best_average = Fraction(-1)
    best_worst = -1
    best: list[Any] = []
    for false_action, true_action in product(actions, repeat=2):
        success = (int(false_action == required[0]), int(false_action == required[1]))
        average = Fraction(sum(success), 2)
        worst = min(success)
        encode = lambda action: list(action) if isinstance(action, tuple) else action
        rows.append([encode(false_action), encode(true_action), list(success)])
        if (average, worst) > (best_average, best_worst):
            best_average, best_worst, best = average, worst, [false_action]
        elif (average, worst) == (best_average, best_worst) and false_action not in best:
            best.append(false_action)
    return {
        "best_average": str(best_average),
        "best_false_actions": [list(item) if isinstance(item, tuple) else item for item in best],
        "best_worst_case": best_worst,
        "controller_count": len(rows),
        "enumeration_sha256": canonical_sha256(rows),
    }


def verify_certificate(value: Any) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ValueError("certificate must be an object")
    actions = _actions()
    first = ("first", "set", "first", "green")
    second = ("second", "set", "second", "green")
    expected_simple = _summary(("askLeft", "askRight"), ("askLeft", "askRight"))
    expected_exact = _summary(actions, (first, second))

    if value.get("schema") != "v23.visible_factored_nogo.v1":
        raise ValueError("wrong visible-factored certificate schema")
    budget = value.get("budget")
    if budget != {
        "candidate_patches": 1,
        "interaction_queries": 1,
        "response_bits_max": 2,
        "steps": 1,
    }:
        raise ValueError("the certified budget is not the one-query Lean budget")

    simple = value.get("simple_class")
    exact = value.get("exact_finite_class")
    if not isinstance(simple, dict) or not isinstance(exact, dict):
        raise ValueError("controller summaries are missing")
    for field, expected in expected_simple.items():
        if simple.get(field) != expected:
            raise ValueError(f"simple controller field {field} was not recomputed")
    for field, expected in expected_exact.items():
        if exact.get(field) != expected:
            raise ValueError(f"exact controller field {field} was not recomputed")
    if simple.get("same_visible") is not True or simple.get("visible_value") is not False:
        raise ValueError("the simple critical pair does not share the declared visible")
    if exact.get("same_visible") != {"coarseStatus": False, "visibleHistory": []}:
        raise ValueError("the exact critical pair does not share the Lean visible state")
    if exact.get("action_count") != 30 or exact.get("controller_count") != 900:
        raise ValueError("finite action/controller class is incomplete")
    if exact.get("required") != {"first": list(first), "second": list(second)}:
        raise ValueError("required exact actions differ from the Lean critical stages")
    if first == second or first[0] == second[0]:
        raise AssertionError("internal verifier error: required actions must be incompatible")

    randomized = value.get("randomized_optimum")
    if not isinstance(randomized, dict):
        raise ValueError("randomized optimum is missing")
    if Fraction(randomized.get("equiprobable_average_optimum", "-1")) != Fraction(1, 2):
        raise ValueError("wrong randomized average optimum")
    if Fraction(randomized.get("guaranteed_worst_case_optimum", "-1")) != Fraction(1, 2):
        raise ValueError("wrong randomized worst-case optimum")
    distribution = randomized.get("optimal_distribution")
    if distribution != [
        {"action": list(first), "probability": "1/2"},
        {"action": list(second), "probability": "1/2"},
    ]:
        raise ValueError("the claimed rational optimum lacks its exact witness")
    if value.get("active_full_state_comparator") != {
        "average_success": "1",
        "closes_both": True,
        "worst_case_success": "1",
    }:
        raise ValueError("active full-state comparator is not exact")
    return {
        "action_count": len(actions),
        "controller_count": len(actions) ** 2,
        "deterministic_average_optimum": str(Fraction(1, 2)),
        "randomized_worst_case_optimum": str(Fraction(1, 2)),
        "valid": True,
    }


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("certificate", type=Path)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        text = args.certificate.read_text(encoding="utf-8")
        value = parse_json_strict(text.rstrip("\n"), require_canonical=True)
        report = verify_certificate(value)
    except (OSError, ValueError) as error:
        print(canonical_json({"error": str(error), "valid": False}), file=sys.stderr)
        return 1
    print(canonical_json(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
