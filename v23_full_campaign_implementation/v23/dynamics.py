"""Structural persistence and monotone-repair audit over trace payloads."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Iterable


def certify_dynamics_payloads(records: Iterable[dict[str, Any]]) -> dict[str, Any]:
    violations: list[str] = []
    forgetting_events = 0
    transitions = 0
    episodes = 0
    horizons: dict[int, int] = {}
    for record_index, record in enumerate(records):
        episodes += 1
        current = tuple(record.get("initial_fiber", ()))
        retained: set[str] = set()
        steps = record.get("steps", ())
        if not isinstance(steps, (list, tuple)):
            violations.append(f"record {record_index}: steps is not an array")
            continue
        horizons[len(steps)] = horizons.get(len(steps), 0) + 1
        for step_index, step in enumerate(steps):
            transitions += 1
            before = tuple(step.get("fiber_before", ()))
            after = tuple(step.get("fiber_after", ()))
            if before != current:
                violations.append(f"record {record_index} step {step_index}: broken orbit")
            if not set(after) <= set(before):
                violations.append(f"record {record_index} step {step_index}: non-monotone fiber")
            if not after:
                violations.append(f"record {record_index} step {step_index}: empty posterior")
            if not step.get("transition_derived_from_repair"):
                violations.append(f"record {record_index} step {step_index}: opaque next state")
            repair = step.get("repair", {})
            declared = set(repair.get("retained_closures", ()))
            if not retained <= declared:
                forgetting_events += 1
                violations.append(f"record {record_index} step {step_index}: forgotten repair")
            retained.add(f"step:{step_index}")
            memory_before = set(step.get("memory_before", ()))
            memory_after = set(step.get("memory_after", ()))
            if not memory_before <= memory_after:
                forgetting_events += 1
                violations.append(f"record {record_index} step {step_index}: non-cumulative memory")
            current = after
        if tuple(record.get("final_fiber", ())) != current:
            violations.append(f"record {record_index}: final fiber mismatch")
    forgetting_micros = int(round(forgetting_events * 1_000_000 / max(1, transitions)))
    return {
        "schema": "v23-dynamics-certificate-1",
        "episodes": episodes,
        "transitions": transitions,
        "horizon_histogram": {str(key): value for key, value in sorted(horizons.items())},
        "forgetting_events": forgetting_events,
        "forgetting_rate_micros": forgetting_micros,
        "violations": tuple(violations),
        "ok": not violations,
    }


def certify_dynamics_jsonl(path: str | Path) -> dict[str, Any]:
    records = []
    with Path(path).open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            try:
                records.append(json.loads(line))
            except json.JSONDecodeError as error:
                raise ValueError(f"invalid JSON line {line_number}: {error}") from error
    return certify_dynamics_payloads(records)
