"""Trace persistence and independent structural verification."""

from __future__ import annotations

import dataclasses
import json
from pathlib import Path
from typing import Iterable

from .canonical import canonical_json, content_sha256, write_new_bytes
from .contracts import EpisodeTrace


TRACE_REQUIRED_KEYS = frozenset(
    {
        "schema_version",
        "episode_id",
        "system_id",
        "seed",
        "observation_hash",
        "actual_world_id",
        "initial_fiber",
        "steps",
        "final_fiber",
        "required_action",
        "predicted_action",
        "intervention_id",
        "closed",
    }
)


def trace_payload(trace: EpisodeTrace) -> dict[str, object]:
    trace.validate()
    return dataclasses.asdict(trace)


def write_trace_jsonl(path: str | Path, traces: Iterable[EpisodeTrace]) -> str:
    records = [trace_payload(trace) for trace in traces]
    payload = "".join(canonical_json(record) + "\n" for record in records).encode()
    write_new_bytes(path, payload)
    return content_sha256(records)


def audit_trace_jsonl(path: str | Path) -> dict[str, object]:
    count = 0
    errors: list[str] = []
    episode_ids: set[str] = set()
    with Path(path).open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            try:
                record = json.loads(line)
            except json.JSONDecodeError as error:
                errors.append(f"line {line_number}: invalid JSON: {error}")
                continue
            missing = TRACE_REQUIRED_KEYS - set(record)
            if missing:
                errors.append(f"line {line_number}: missing keys {sorted(missing)}")
            episode_id = record.get("episode_id")
            if episode_id in episode_ids:
                errors.append(f"line {line_number}: duplicate episode_id")
            if isinstance(episode_id, str):
                episode_ids.add(episode_id)
            if not record.get("steps"):
                errors.append(f"line {line_number}: empty repair episode")
            count += 1
    return {"records": count, "errors": tuple(errors), "ok": not errors}
