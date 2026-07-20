#!/usr/bin/env python3
"""Common exact infrastructure for the v23 finite reference environment.

This module contains no learned component and no semantic oracle hidden behind
an agent-facing API.  It only provides provenance, commitments, typed JSON
helpers, and deterministic verification failures shared by producers and
independent verifiers.
"""

from __future__ import annotations

import hashlib
from dataclasses import dataclass
from pathlib import Path
from typing import Any, NoReturn

from trace_schema_v23 import canonical_json_bytes


@dataclass(frozen=True)
class SemanticVerificationError(ValueError):
    code: str
    path: str
    detail: str

    def __str__(self) -> str:
        return f"{self.code} at {self.path}: {self.detail}"


def fail(code: str, path: str, detail: str) -> NoReturn:
    raise SemanticVerificationError(code, path, detail)


def require(condition: bool, code: str, path: str, detail: str) -> None:
    if not condition:
        fail(code, path, detail)


def require_equal(actual: Any, expected: Any, code: str, path: str) -> None:
    if actual != expected:
        fail(code, path, f"expected={expected!r}, actual={actual!r}")


def sha256_bytes(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def typed(type_tag: str, **value: Any) -> dict[str, Any]:
    return {"type": type_tag, "value": value}


def salted_commitment(type_tag: str, value: Any, salt: bytes) -> str:
    """Commit to a typed value without exposing it in the public trace."""

    require(bool(salt), "empty_commitment_salt", "$.salt", "salt must be non-empty")
    payload = typed(type_tag, payload=value)
    framed = (
        len(salt).to_bytes(8, "big")
        + salt
        + len(type_tag.encode("utf-8")).to_bytes(8, "big")
        + canonical_json_bytes(payload)
    )
    return sha256_bytes(framed)


@dataclass(frozen=True)
class TraceProvenance:
    run_id: str
    environment_seed: int
    source_bundle_sha256: str
    executed_script_sha256: str
    command_sha256: str


def provenance_from_material(
    *, run_id: str, environment_seed: int, source_bundle: bytes,
    executed_script: bytes, command: str
) -> TraceProvenance:
    """Build deterministic smoke/conformance provenance from explicit bytes."""

    return TraceProvenance(
        run_id=run_id,
        environment_seed=environment_seed,
        source_bundle_sha256=sha256_bytes(source_bundle),
        executed_script_sha256=sha256_bytes(executed_script),
        command_sha256=sha256_bytes(command.encode("utf-8")),
    )


__all__ = [
    "SemanticVerificationError",
    "TraceProvenance",
    "fail",
    "provenance_from_material",
    "require",
    "require_equal",
    "salted_commitment",
    "sha256_bytes",
    "sha256_file",
    "typed",
]
