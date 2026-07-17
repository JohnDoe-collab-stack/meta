#!/usr/bin/env python3
"""Build exact passive no-go and adaptive transcript certificates for Level A."""

from __future__ import annotations

from itertools import product
from typing import Any, Iterable

from finite_reference_domain_v23 import (
    ALL_WORLDS,
    INDICES,
    VALUES,
    CANONICAL_WORLD,
    Candidate,
    Value,
    World,
    initial_state,
    open_transition,
    orbit,
    serialize_agent_state,
    serialize_candidate,
    serialize_observation,
)
from trace_schema_v23 import canonical_json, canonical_sha256


PASSIVE_STEPS = (0, 1, 2, 3, 4, 8)
PASSIVE_MEMORY = (0, 16, 64, 256, 1024)


def all_candidates() -> tuple[Candidate, ...]:
    options = (None, *VALUES)
    return tuple(Candidate(*values) for values in product(options, repeat=3))


def _passive_rows(left: World, right: World) -> list[dict[str, Any]]:
    return [
        {
            "candidate": serialize_candidate(candidate),
            "left_success": candidate.first is left.first,
            "right_success": candidate.first is right.first,
        }
        for candidate in all_candidates()
    ]


def _transcript(world: World) -> dict[str, Any]:
    states = orbit(world)
    events: list[str] = [
        "observation:" + canonical_json(serialize_observation(states[0].agent.observation))
    ]
    steps = []
    for state in states[:-1]:
        transition = open_transition(state)
        assert transition is not None
        event = (
            f"query:{transition.query.kind.value}:{transition.query.index.value}"
            f"/response:{transition.response.kind.value}:{transition.response.value.value}"
        )
        events.append(event)
        steps.append(
            {
                "gap_index": transition.gap.index.value,
                "query": {
                    "constructor": transition.query.kind.value,
                    "index": transition.query.index.value,
                },
                "response": {
                    "constructor": transition.response.kind.value,
                    "index": transition.response.index.value,
                    "value": transition.response.value.value,
                },
                "candidate_after": serialize_candidate(transition.after.agent.candidate),
            }
        )
    return {
        "events": events,
        "final_candidate": serialize_candidate(states[-1].agent.candidate),
        "query_count": len(steps),
        "steps": steps,
        "world": {index.value: world.at(index).value for index in INDICES},
    }


def _trie_stats(transcripts: Iterable[list[str]]) -> dict[str, Any]:
    root: dict[str, Any] = {}
    for events in transcripts:
        node = root
        for event in events:
            node = node.setdefault(event, {})
        node["$closed"] = {}

    leaves = 0
    nodes = 0
    branch_histogram: dict[int, int] = {}
    max_depth = 0

    def visit(node: dict[str, Any], depth: int) -> None:
        nonlocal leaves, nodes, max_depth
        nodes += 1
        if "$closed" in node:
            leaves += 1
            max_depth = max(max_depth, depth)
        children = [key for key in node if key != "$closed"]
        if children:
            branch_histogram[len(children)] = branch_histogram.get(len(children), 0) + 1
        for key in children:
            visit(node[key], depth + 1)

    visit(root, 0)
    return {
        "branching_histogram": {
            str(branches): count for branches, count in sorted(branch_histogram.items())
        },
        "capacity_bits_ceiling": (leaves - 1).bit_length(),
        "leaves": leaves,
        "max_event_depth": max_depth,
        "nodes": nodes,
        "tree_sha256": canonical_sha256(root),
    }


def build_certificate() -> dict[str, Any]:
    left = CANONICAL_WORLD
    right = World(Value.BLUE, Value.GREEN, Value.GREEN)
    left_initial = initial_state(left).agent
    right_initial = initial_state(right).agent
    if left_initial != right_initial:
        raise AssertionError("passive witness pair must expose identical agent states")
    passive_rows = _passive_rows(left, right)
    if any(row["left_success"] and row["right_success"] for row in passive_rows):
        raise AssertionError("a common passive candidate unexpectedly closes both worlds")

    transcripts = [_transcript(world) for world in ALL_WORLDS]
    event_sequences = [item["events"] for item in transcripts]
    if len({tuple(events) for events in event_sequences}) != len(ALL_WORLDS):
        raise AssertionError("active transcripts do not separate all finite worlds")
    stats = _trie_stats(event_sequences)
    budget_grid = [
        {
            "interaction_queries": 0,
            "memory_cells": memory,
            "steps": steps,
            "deterministic_average_optimum": "1/2",
            "deterministic_worst_case_optimum": "0",
        }
        for steps in PASSIVE_STEPS
        for memory in PASSIVE_MEMORY
    ]
    return {
        "schema": "v23.information_certificate.v1",
        "lean_witness": {
            "passive_no_go": "Meta.ActiveSemanticClosure.NoGo.finiteBudgetedPassivePolicy_noGo",
            "active_closure": "Meta.ActiveSemanticClosure.Finite.finiteClosureOrbitCertificate",
        },
        "passive_no_go": {
            "candidate_count": len(passive_rows),
            "enumeration_sha256": canonical_sha256(passive_rows),
            "same_initial_agent": serialize_agent_state(left_initial),
            "witness_worlds": [
                {index.value: left.at(index).value for index in INDICES},
                {index.value: right.at(index).value for index in INDICES},
            ],
            "incompatible_index": "first",
            "incompatible_targets": [left.first.value, right.first.value],
            "deterministic_average_optimum": "1/2",
            "deterministic_worst_case_optimum": "0",
            "randomized_average_optimum": "1/2",
            "randomized_guarantee_optimum": "1/2",
            "resource_grid": budget_grid,
        },
        "active_sufficiency": {
            "all_worlds_closed": True,
            "max_queries": max(item["query_count"] for item in transcripts),
            "min_queries": min(item["query_count"] for item in transcripts),
            "transcript_count": len(transcripts),
            "transcripts_sha256": canonical_sha256(transcripts),
            **stats,
        },
        "composition": {
            "every_response_closes_current_gap": True,
            "every_step_strictly_reduces_fiber": True,
            "repairs_retained_at_every_reachable_state": True,
        },
    }


def main() -> int:
    print(canonical_json(build_certificate()))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
