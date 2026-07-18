#!/usr/bin/env python3
"""Validate and execute the Lean-exported CW0 finite phase kernel.

This interpreter contains no carbon transition law. It loads the unique
successor of every exported source from ``kernel.json`` and rejects incomplete
or internally inconsistent tables before producing a trajectory.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import platform
import re
import shlex
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


SCHEMA_VERSION = "cw0-two-phase-v1"
MODEL_STATUS = "structural_witness_not_chemistry"
AUTHORITY_THEOREM = "Meta.Carbone.CW0.twoPhaseKernel_commutes"
FROZEN_NAME = re.compile(
    r"^simulate_two_phase_"
    r"(?P<suffix>\d{8}T\d{6}Z_sha256-(?P<hash>[0-9a-f]{64}))\.py$"
)


class ConformanceError(RuntimeError):
    """The export or invocation does not satisfy the declared contract."""


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ConformanceError(message)


def load_kernel(path: Path, expected_hash: str) -> tuple[dict[str, Any], str]:
    actual_hash = sha256_file(path)
    require(actual_hash == expected_hash, "kernel SHA-256 mismatch")
    with path.open("r", encoding="utf-8") as stream:
        payload = json.load(stream)
    require(isinstance(payload, dict), "kernel root must be an object")
    return payload, actual_hash


def validate_kernel(
    kernel: dict[str, Any],
) -> tuple[dict[int, dict[str, Any]], dict[int, dict[str, Any]]]:
    require(kernel.get("schema_version") == SCHEMA_VERSION, "wrong schema")
    require(kernel.get("status") == MODEL_STATUS, "wrong model status")
    authority = kernel.get("authority")
    require(isinstance(authority, dict), "missing authority")
    require(
        authority.get("commutation_theorem") == AUTHORITY_THEOREM,
        "wrong Lean commutation theorem",
    )
    scope = kernel.get("scope")
    require(isinstance(scope, dict), "missing scope")
    require(scope.get("exported") == "finite_phase_quotient", "wrong scope")
    require("unbounded_history" in scope.get("omitted", []), "history omission absent")

    states_raw = kernel.get("states")
    transitions_raw = kernel.get("transitions")
    require(isinstance(states_raw, list) and states_raw, "states must be nonempty")
    require(isinstance(transitions_raw, list), "transitions must be a list")

    states: dict[int, dict[str, Any]] = {}
    names: set[str] = set()
    for state in states_raw:
        require(isinstance(state, dict), "state must be an object")
        state_id = state.get("id")
        name = state.get("name")
        inventory = state.get("visible_inventory")
        require(isinstance(state_id, int) and state_id >= 0, "invalid state id")
        require(state_id not in states, "duplicate state id")
        require(isinstance(name, str) and name, "invalid state name")
        require(name not in names, "duplicate state name")
        require(isinstance(inventory, dict), "missing visible inventory")
        require(inventory.get("carbon", 0) > 0, "state contains no carbon")
        states[state_id] = state
        names.add(name)

    transitions: dict[int, dict[str, Any]] = {}
    for transition in transitions_raw:
        require(isinstance(transition, dict), "transition must be an object")
        source_id = transition.get("source_id")
        target_id = transition.get("target_id")
        require(source_id in states, "transition source outside domain")
        require(target_id in states, "transition target outside domain")
        require(source_id not in transitions, "source has multiple transitions")
        require(
            transition.get("inventory_before")
            == states[source_id]["visible_inventory"],
            "source inventory mismatch",
        )
        require(
            transition.get("inventory_after")
            == states[target_id]["visible_inventory"],
            "target inventory mismatch",
        )
        require(
            transition.get("inventory_before") == transition.get("inventory_after"),
            "transition changes visible inventory",
        )
        for provenance_field in (
            "gap_id",
            "interaction_id",
            "response_id",
            "repair_id",
        ):
            require(
                isinstance(transition.get(provenance_field), int),
                f"invalid {provenance_field}",
            )
        transitions[source_id] = transition

    require(set(transitions) == set(states), "transition table is not total")
    require(len(transitions_raw) == len(states), "transition table is not functional")

    for source_id in states:
        first = transitions[source_id]["target_id"]
        second = transitions[first]["target_id"]
        require(second == source_id, "two-step cycle check failed")

    return states, transitions


def resolve_initial(initial: str, states: dict[int, dict[str, Any]]) -> int:
    by_name = {state["name"]: state_id for state_id, state in states.items()}
    if initial in by_name:
        return by_name[initial]
    try:
        state_id = int(initial)
    except ValueError as error:
        raise ConformanceError("initial state is neither an id nor a name") from error
    require(state_id in states, "initial state outside domain")
    return state_id


def simulate(
    initial_id: int,
    steps: int,
    states: dict[int, dict[str, Any]],
    transitions: dict[int, dict[str, Any]],
) -> list[dict[str, Any]]:
    require(steps >= 0, "steps must be nonnegative")
    observations: list[dict[str, Any]] = []
    current = initial_id
    for transition_index in range(steps + 1):
        state = states[current]
        observations.append(
            {
                "transition_index": transition_index,
                "state_id": current,
                "state_name": state["name"],
                "visible_inventory": state["visible_inventory"],
                "physical_time": None,
                "generation_index": None,
            }
        )
        if transition_index < steps:
            current = transitions[current]["target_id"]
    require(len(observations) == steps + 1, "trajectory length mismatch")
    return observations


def scientific_suffix(script_path: Path, script_hash: str, smoke: bool) -> str | None:
    match = FROZEN_NAME.fullmatch(script_path.name)
    if smoke:
        return match.group("suffix") if match else None
    require(match is not None, "scientific run requires a frozen script filename")
    require(match.group("hash") == script_hash, "script filename hash mismatch")
    return match.group("suffix")


def validate_output_names(
    suffix: str | None,
    out_jsonl: Path,
    out_txt: Path,
    smoke: bool,
) -> None:
    if smoke:
        smoke_paths = (str(out_jsonl), str(out_txt))
        require(
            all(path.startswith("/tmp/") or "smoke" in path for path in smoke_paths),
            "smoke outputs must be in /tmp or explicitly named smoke",
        )
        return
    require(suffix is not None, "missing frozen suffix")
    require(out_jsonl.name == f"run_{suffix}.jsonl", "JSONL suffix mismatch")
    require(out_txt.name == f"run_{suffix}.txt", "TXT suffix mismatch")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--kernel", type=Path, required=True)
    parser.add_argument("--expected-kernel-sha256", required=True)
    parser.add_argument("--expected-script-sha256")
    parser.add_argument("--initial", default="chain")
    parser.add_argument("--steps", type=int, required=True)
    parser.add_argument("--out-jsonl", type=Path, required=True)
    parser.add_argument("--out-txt", type=Path, required=True)
    parser.add_argument("--smoke", action="store_true")
    return parser.parse_args()


def main() -> int:
    started = datetime.now(timezone.utc)
    args = parse_args()
    script_path = Path(__file__).resolve()
    script_hash = sha256_file(script_path)
    if not args.smoke:
        require(args.expected_script_sha256 is not None, "script hash is required")
    if args.expected_script_sha256 is not None:
        require(script_hash == args.expected_script_sha256, "script SHA-256 mismatch")

    suffix = scientific_suffix(script_path, script_hash, args.smoke)
    validate_output_names(suffix, args.out_jsonl, args.out_txt, args.smoke)
    kernel, kernel_hash = load_kernel(args.kernel, args.expected_kernel_sha256)
    states, transitions = validate_kernel(kernel)
    initial_id = resolve_initial(args.initial, states)
    observations = simulate(initial_id, args.steps, states, transitions)

    args.out_jsonl.parent.mkdir(parents=True, exist_ok=True)
    args.out_txt.parent.mkdir(parents=True, exist_ok=True)
    with args.out_jsonl.open("w", encoding="utf-8", newline="\n") as stream:
        for observation in observations:
            stream.write(json.dumps(observation, sort_keys=True, separators=(",", ":")))
            stream.write("\n")

    finished = datetime.now(timezone.utc)
    command = shlex.join([sys.executable, *sys.argv])
    report_lines = [
        f"command: {command}",
        f"script_sha256: {script_hash}",
        f"kernel_sha256: {kernel_hash}",
        "status: FINITE_PHASE_EXPORT_CONFORMANT",
        "validation_level: SIM0_PLUS_PHASE_CONFORMANCE_NOT_SIM1",
        f"schema_version: {SCHEMA_VERSION}",
        f"authority_theorem: {AUTHORITY_THEOREM}",
        f"states_total: {len(states)}",
        f"states_checked: {len(transitions)}",
        "divergences: 0",
        f"initial_state_id: {initial_id}",
        f"steps: {args.steps}",
        f"observations: {len(observations)}",
        "seed: none_deterministic",
        f"python: {platform.python_version()}",
        f"platform: {platform.platform()}",
        f"started_utc: {started.isoformat()}",
        f"finished_utc: {finished.isoformat()}",
        "scope: finite phase quotient only; no chemistry or empirical validation",
    ]
    args.out_txt.write_text("\n".join(report_lines) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ConformanceError as error:
        print(f"CONFORMANCE_ERROR: {error}", file=sys.stderr)
        raise SystemExit(2) from error
