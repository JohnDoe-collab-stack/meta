#!/usr/bin/env python3
"""Independent exact verifier for the finite v23 information certificate."""

from __future__ import annotations

import argparse
import sys
from fractions import Fraction
from itertools import product
from pathlib import Path
from typing import Any, Iterable, Sequence

from finite_reference_domain_v23 import ALL_WORLDS, INDICES, VALUES, Value, World
from trace_schema_v23 import canonical_json, canonical_sha256, parse_json_strict


def _candidate_payload(values: tuple[Value | None, ...]) -> dict[str, str | None]:
    return {
        index.value: None if value is None else value.value
        for index, value in zip(INDICES, values)
    }


def _observation_payload(world: World) -> dict[str, Any]:
    first = (
        {"kind": "exact", "value": "red"}
        if world.first is Value.RED
        else {"kind": "excludes", "value": "red"}
    )
    unknown = {"kind": "unknown", "value": None}
    return {"first": first, "second": unknown, "third": unknown}


def _initial_agent_payload(world: World) -> dict[str, Any]:
    return {
        "candidate": {"first": "red", "second": None, "third": None},
        "observation": _observation_payload(world),
        "history": [],
    }


def _manual_transcript(world: World) -> dict[str, Any]:
    observation = _observation_payload(world)
    candidate: dict[str, str | None] = {"first": "red", "second": None, "third": None}
    events = ["observation:" + canonical_json(observation)]
    steps = []
    query_indices = list(INDICES if world.first is not Value.RED else INDICES[1:])
    for index in query_indices:
        target = world.at(index).value
        events.append(f"query:reveal:{index.value}/response:revealed:{target}")
        candidate = dict(candidate)
        candidate[index.value] = target
        steps.append(
            {
                "gap_index": index.value,
                "query": {"constructor": "reveal", "index": index.value},
                "response": {
                    "constructor": "revealed",
                    "index": index.value,
                    "value": target,
                },
                "candidate_after": candidate,
            }
        )
    return {
        "events": events,
        "final_candidate": candidate,
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
    maximum = 0
    histogram: dict[int, int] = {}

    def walk(node: dict[str, Any], depth: int) -> None:
        nonlocal leaves, nodes, maximum
        nodes += 1
        if "$closed" in node:
            leaves += 1
            maximum = max(maximum, depth)
        children = [key for key in node if key != "$closed"]
        if children:
            histogram[len(children)] = histogram.get(len(children), 0) + 1
        for child in children:
            walk(node[child], depth + 1)

    walk(root, 0)
    return {
        "branching_histogram": {str(key): value for key, value in sorted(histogram.items())},
        "capacity_bits_ceiling": (leaves - 1).bit_length(),
        "leaves": leaves,
        "max_event_depth": maximum,
        "nodes": nodes,
        "tree_sha256": canonical_sha256(root),
    }


def verify_certificate(value: Any) -> dict[str, Any]:
    if not isinstance(value, dict) or value.get("schema") != "v23.information_certificate.v1":
        raise ValueError("wrong information certificate schema")
    passive = value.get("passive_no_go")
    active = value.get("active_sufficiency")
    if not isinstance(passive, dict) or not isinstance(active, dict):
        raise ValueError("passive or active certificate is missing")

    left = World(Value.GREEN, Value.GREEN, Value.GREEN)
    right = World(Value.BLUE, Value.GREEN, Value.GREEN)
    if _initial_agent_payload(left) != _initial_agent_payload(right):
        raise AssertionError("internal verifier error: passive views differ")
    options = (None, *VALUES)
    rows = []
    for candidate in product(options, repeat=3):
        left_success = candidate[0] is left.first
        right_success = candidate[0] is right.first
        if left_success and right_success:
            raise AssertionError("incompatible targets admitted a common candidate")
        rows.append(
            {
                "candidate": _candidate_payload(candidate),
                "left_success": left_success,
                "right_success": right_success,
            }
        )
    expected_worlds = [
        {index.value: world.at(index).value for index in INDICES}
        for world in (left, right)
    ]
    if passive.get("candidate_count") != 64:
        raise ValueError("passive final candidate enumeration is incomplete")
    if passive.get("enumeration_sha256") != canonical_sha256(rows):
        raise ValueError("passive candidate enumeration hash differs")
    if passive.get("same_initial_agent") != _initial_agent_payload(left):
        raise ValueError("the no-go pair does not expose the same exact agent state")
    if passive.get("witness_worlds") != expected_worlds:
        raise ValueError("passive witness worlds differ")
    for field, expected in (
        ("deterministic_average_optimum", Fraction(1, 2)),
        ("deterministic_worst_case_optimum", Fraction(0, 1)),
        ("randomized_average_optimum", Fraction(1, 2)),
        ("randomized_guarantee_optimum", Fraction(1, 2)),
    ):
        if Fraction(passive.get(field, "-1")) != expected:
            raise ValueError(f"wrong passive optimum {field}")
    grid = passive.get("resource_grid")
    expected_budgets = {
        (steps, memory) for steps in (0, 1, 2, 3, 4, 8) for memory in (0, 16, 64, 256, 1024)
    }
    if not isinstance(grid, list) or {
        (row.get("steps"), row.get("memory_cells")) for row in grid if isinstance(row, dict)
    } != expected_budgets:
        raise ValueError("passive budget grid is incomplete")
    if any(
        row.get("interaction_queries") != 0
        or Fraction(row.get("deterministic_average_optimum", "-1")) != Fraction(1, 2)
        or Fraction(row.get("deterministic_worst_case_optimum", "-1")) != 0
        for row in grid
    ):
        raise ValueError("a passive budget row changes the information-theoretic optimum")

    transcripts = [_manual_transcript(world) for world in ALL_WORLDS]
    sequences = [item["events"] for item in transcripts]
    if len(set(map(tuple, sequences))) != 27:
        raise AssertionError("manual active transcripts are not sufficient")
    expected_stats = _trie_stats(sequences)
    for field, expected in expected_stats.items():
        if active.get(field) != expected:
            raise ValueError(f"active transcript field {field} differs")
    if active.get("transcripts_sha256") != canonical_sha256(transcripts):
        raise ValueError("active transcript enumeration differs")
    if active.get("transcript_count") != 27 or active.get("min_queries") != 2 or active.get("max_queries") != 3:
        raise ValueError("active query geometry differs")
    if active.get("all_worlds_closed") is not True:
        raise ValueError("active sufficiency is not certified")
    if value.get("composition") != {
        "every_response_closes_current_gap": True,
        "every_step_strictly_reduces_fiber": True,
        "repairs_retained_at_every_reachable_state": True,
    }:
        raise ValueError("composition claims are incomplete")
    return {
        "active_leaves": expected_stats["leaves"],
        "passive_candidates": len(rows),
        "passive_pair_optimum": "1/2",
        "transcript_capacity_bits": expected_stats["capacity_bits_ceiling"],
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
