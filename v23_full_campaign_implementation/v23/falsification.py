"""Mutation harness proving that invalid certificates are rejected."""

from __future__ import annotations

import copy
from collections.abc import Callable
from typing import Any

from .contracts import ActiveDomain, Episode, EpisodeTrace
from .verification import VerificationError, payload_from_trace, verify_payload


Mutation = Callable[[dict[str, Any]], None]


def _set(path: tuple[Any, ...], value: Any) -> Mutation:
    def mutate(payload: dict[str, Any]) -> None:
        cursor: Any = payload
        for component in path[:-1]:
            cursor = cursor[component]
        cursor[path[-1]] = value

    return mutate


def _corrupt_selected_logit(payload: dict[str, Any]) -> None:
    decision = payload["steps"][0]["decisions"][4]
    selected = decision["catalog"].index(decision["selected_id"])
    alternate = next(index for index, allowed in enumerate(decision["allowed_mask"]) if allowed and index != selected)
    logits = list(decision["logits_micros"])
    logits[selected] = -999_999_999
    logits[alternate] = 999_999_999
    decision["logits_micros"] = logits


MUTATIONS: dict[str, Mutation] = {
    "gap_index": _set(("steps", 0, "decisions", 1, "selected_id"), "none"),
    "gap_genre": _set(("steps", 0, "decisions", 1, "kind"), "repair"),
    "gap_evidence": _set(("steps", 0, "decisions", 1, "provenance"), []),
    "usage": _set(("steps", 0, "decisions", 2, "selected_id"), "visible_state"),
    "transport_focus": _set(("steps", 0, "decisions", 3, "selected_id"), "none"),
    "transport_index": _set(("steps", 0, "decisions", 3, "allowed_mask"), [True, False]),
    "query": _set(("steps", 0, "query_id"), "not_authorized"),
    "response": _set(("steps", 0, "response_id"), "crossed-response"),
    "patch": _set(("steps", 0, "repair", "repair_id"), "defer"),
    "next_state": _set(("steps", 0, "transition_derived_from_repair"), False),
    "history": _set(("steps", 0, "memory_after"), []),
    "fiber": _set(("steps", 0, "fiber_after"), []),
    "closure": _set(("closed",), False),
    "logit": _corrupt_selected_logit,
    "tie_break": _set(("steps", 0, "decisions", 4, "selected_id"), "not_authorized"),
    "provenance_hash": _set(("observation_hash",), "0" * 64),
    "order": _set(("steps", 0, "step_index"), 8),
}


def run_mutation_suite(
    trace: EpisodeTrace, episode: Episode, domain: ActiveDomain
) -> dict[str, object]:
    base = payload_from_trace(trace)
    verify_payload(base, episode, domain)
    results: dict[str, dict[str, object]] = {}
    for name, mutate in MUTATIONS.items():
        candidate = copy.deepcopy(base)
        mutate(candidate)
        try:
            verify_payload(candidate, episode, domain)
        except VerificationError as error:
            results[name] = {
                "rejected": True,
                "code": error.code,
                "path": error.path,
            }
        except Exception as error:  # A verifier crash is itself a failure.
            results[name] = {
                "rejected": False,
                "unclassified_exception": type(error).__name__,
            }
        else:
            results[name] = {"rejected": False, "code": "ACCEPTED_INVALID"}
    return {
        "schema": "v23-falsification-1",
        "mutation_count": len(MUTATIONS),
        "rejected_count": sum(bool(item["rejected"]) for item in results.values()),
        "all_rejected": all(bool(item["rejected"]) for item in results.values()),
        "results": results,
    }
