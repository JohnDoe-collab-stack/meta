#!/usr/bin/env python3
"""Enumerate the exact finite visible-factored controller classes."""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Any

from finite_reference_domain_v23 import INDICES, VALUES, PatchKind
from trace_schema_v23 import canonical_json, canonical_sha256


SIMPLE_STATES = ("needsLeft", "needsRight")
SIMPLE_ACTIONS = ("askLeft", "askRight")
SIMPLE_VISIBLE = {"needsLeft": False, "needsRight": False, "visibleAlternative": True}
SIMPLE_REQUIRED = {"needsLeft": "askLeft", "needsRight": "askRight"}


def finite_actions() -> tuple[tuple[str, str, str, str], ...]:
    patches = [(PatchKind.KEEP.value, "_", "_")]
    patches.extend(
        (PatchKind.SET.value, index.value, value.value)
        for index in INDICES
        for value in VALUES
    )
    return tuple(
        (query_index.value, patch_kind, patch_index, patch_value)
        for query_index in INDICES
        for patch_kind, patch_index, patch_value in patches
    )


FINITE_ACTIONS = finite_actions()
FINITE_REQUIRED = {
    "first": ("first", "set", "first", "green"),
    "second": ("second", "set", "second", "green"),
}


def _successes(action: Any, required: dict[str, Any]) -> tuple[int, int]:
    return tuple(int(action == required[state]) for state in required)  # type: ignore[return-value]


def _json_action(action: Any) -> Any:
    return list(action) if isinstance(action, tuple) else action


def _controller_summary(actions: tuple[Any, ...], required: dict[str, Any]) -> dict[str, Any]:
    rows = []
    best_average = Fraction(-1, 1)
    best_worst = -1
    best: list[Any] = []
    for false_action, true_action in product(actions, repeat=2):
        success = _successes(false_action, required)
        average = Fraction(sum(success), len(success))
        worst = min(success)
        rows.append([_json_action(false_action), _json_action(true_action), list(success)])
        if (average, worst) > (best_average, best_worst):
            best_average, best_worst, best = average, worst, [false_action]
        elif (average, worst) == (best_average, best_worst):
            if false_action not in best:
                best.append(false_action)
    return {
        "best_average": str(best_average),
        "best_false_actions": [_json_action(action) for action in best],
        "best_worst_case": best_worst,
        "controller_count": len(rows),
        "enumeration_sha256": canonical_sha256(rows),
    }


def build_certificate() -> dict[str, Any]:
    simple = _controller_summary(SIMPLE_ACTIONS, SIMPLE_REQUIRED)
    exact = _controller_summary(FINITE_ACTIONS, FINITE_REQUIRED)
    randomized = {
        "equiprobable_average_optimum": "1/2",
        "guaranteed_worst_case_optimum": "1/2",
        "optimal_distribution": [
            {"action": list(FINITE_REQUIRED["first"]), "probability": "1/2"},
            {"action": list(FINITE_REQUIRED["second"]), "probability": "1/2"},
        ],
        "proof": "same_visible_implies_same_distribution_and_required_actions_are_disjoint",
    }
    certificate = {
        "schema": "v23.visible_factored_nogo.v1",
        "lean_witness": {
            "active_comparator": "Meta.ActiveSemanticClosure.NoGo.finiteActiveComparatorCertificate",
            "certificate": "Meta.ActiveSemanticClosure.NoGo.aiClosureNoGoCertificate",
            "no_go": "Meta.ActiveSemanticClosure.NoGo.finiteVisibleFactored_cannotCloseBoth",
        },
        "budget": {
            "candidate_patches": 1,
            "interaction_queries": 1,
            "response_bits_max": 2,
            "steps": 1,
        },
        "simple_class": {
            **simple,
            "actions": list(SIMPLE_ACTIONS),
            "critical_pair": list(SIMPLE_STATES),
            "same_visible": True,
            "visible_value": False,
            "required": SIMPLE_REQUIRED,
        },
        "exact_finite_class": {
            **exact,
            "action_count": len(FINITE_ACTIONS),
            "critical_pair": ["first", "second"],
            "same_visible": {"coarseStatus": False, "visibleHistory": []},
            "required": {
                state: list(action) for state, action in FINITE_REQUIRED.items()
            },
        },
        "randomized_optimum": randomized,
        "active_full_state_comparator": {
            "average_success": "1",
            "closes_both": True,
            "worst_case_success": "1",
        },
    }
    return certificate


def main() -> int:
    print(canonical_json(build_certificate()))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
