#!/usr/bin/env python3
"""Create an immutable timestamp+SHA bundle and execute only that snapshot."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

from v23.canonical import canonical_json, sha256_file, write_new_bytes, write_new_json
from v23.preflight import run_preflight


PROFILES = (
    "finite-conformance",
    "certifiable-agent",
    "tune",
    "final-train",
    "interventions",
    "sealed-ood",
    "certify",
    "falsify",
    "replicate-eval",
    "replicate-train",
)


def bundle_files(root: Path) -> tuple[Path, ...]:
    excluded = {"__pycache__", ".pytest_cache", "runs", "snapshots", ".git"}
    return tuple(
        sorted(
            (
                path
                for path in root.rglob("*")
                if path.is_file()
                and not any(part in excluded for part in path.relative_to(root).parts)
                and path.suffix in {".py", ".json", ".md", ".toml"}
            ),
            key=lambda path: str(path.relative_to(root)),
        )
    )


def bundle_sha256(root: Path, files: tuple[Path, ...]) -> str:
    digest = hashlib.sha256()
    for path in files:
        relative = str(path.relative_to(root)).encode("utf-8")
        digest.update(len(relative).to_bytes(4, "big"))
        digest.update(relative)
        payload = path.read_bytes()
        digest.update(len(payload).to_bytes(8, "big"))
        digest.update(payload)
    return digest.hexdigest()


def snapshot_bundle(root: Path, snapshot: Path, files: tuple[Path, ...]) -> None:
    snapshot.mkdir(parents=True, exist_ok=False)
    for source in files:
        target = snapshot / source.relative_to(root)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)


def _profile_command(
    profile: str,
    snapshot: Path,
    campaign_script: Path,
    run_directory: Path,
    cell_config: str | None,
    campaign_key_file: str | None,
    input_root: str | None,
    episodes_per_ood_family: int,
) -> list[str]:
    if profile == "finite-conformance":
        return [sys.executable, str(campaign_script), "finite-conformance", "--out-dir", str(run_directory / "results")]
    if profile == "certifiable-agent":
        return [sys.executable, str(campaign_script), "certifiable-agent", "--out-dir", str(run_directory / "results")]
    if profile == "tune" and cell_config is None:
        return [sys.executable, str(campaign_script), "matrix", "--kind", "tune", "--out", str(run_directory / "tuning_matrix.json")]
    if profile == "interventions" and cell_config is None:
        return [sys.executable, str(campaign_script), "interventions", "--out-dir", str(run_directory / "results")]
    if profile == "interventions":
        payload = json.loads(Path(cell_config).read_text(encoding="utf-8"))
        payload["output_directory"] = str(run_directory / "results" / "interventions")
        effective = run_directory / "effective_intervention_config.json"
        write_new_json(effective, payload)
        return [sys.executable, str(campaign_script), "run-interventions", "--config", str(effective)]
    if profile == "falsify":
        return [sys.executable, str(campaign_script), "falsify", "--out-dir", str(run_directory / "results")]
    if profile == "sealed-ood":
        if campaign_key_file is None:
            raise ValueError("sealed-ood requires --campaign-key-file outside the snapshot")
        return [
            sys.executable,
            str(campaign_script),
            "sealed-ood",
            "--out-dir",
            str(run_directory / "results"),
            "--campaign-key-file",
            str(Path(campaign_key_file).resolve()),
            "--episodes-per-family",
            str(episodes_per_ood_family),
        ]
    if profile == "certify":
        if cell_config is not None:
            payload = json.loads(Path(cell_config).read_text(encoding="utf-8"))
            payload["output_directory"] = str(run_directory / "results" / "evaluation")
            effective = run_directory / "effective_evaluation_config.json"
            write_new_json(effective, payload)
            return [sys.executable, str(campaign_script), "evaluate-one", "--config", str(effective)]
        if input_root is None:
            raise ValueError("certify requires --cell-config for evaluation or --input-root for gate evidence")
        return [
            sys.executable,
            str(campaign_script),
            "audit",
            "--run-root",
            str(Path(input_root).resolve()),
            "--require-all-gates",
        ]
    if profile == "replicate-eval" and cell_config is None:
        return [sys.executable, str(campaign_script), "matrix", "--kind", "replicate-eval", "--out", str(run_directory / "replication_matrix.json")]
    if profile in {"tune", "final-train", "replicate-train"}:
        if cell_config is None:
            raise ValueError(f"profile {profile} requires --cell-config")
        payload = json.loads(Path(cell_config).read_text(encoding="utf-8"))
        payload["output_directory"] = str(run_directory / "results" / "training")
        effective = run_directory / "effective_train_config.json"
        write_new_json(effective, payload)
        return [sys.executable, str(campaign_script), "train-one", "--config", str(effective)]
    if profile == "replicate-eval":
        if cell_config is None:
            raise ValueError("replicate-eval requires an evaluation cell config")
        payload = json.loads(Path(cell_config).read_text(encoding="utf-8"))
        payload["output_directory"] = str(run_directory / "results" / "evaluation")
        effective = run_directory / "effective_evaluation_config.json"
        write_new_json(effective, payload)
        return [sys.executable, str(campaign_script), "evaluate-one", "--config", str(effective)]
    raise ValueError(f"profile {profile} has no valid invocation with the supplied arguments")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--profile", choices=PROFILES, required=True)
    parser.add_argument("--out-root", required=True)
    parser.add_argument("--cell-config")
    parser.add_argument("--campaign-key-file")
    parser.add_argument("--input-root")
    parser.add_argument("--episodes-per-ood-family", type=int, default=8192)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent
    out_root = Path(args.out_root).resolve()
    lock = json.loads((root / "protocol.lock.json").read_text(encoding="utf-8"))
    if lock.get("implementation_contract") != "v23.1":
        raise RuntimeError("protocol.lock.json does not authorize implementation contract v23.1")
    if args.profile in {"final-train", "replicate-train"} and args.cell_config is None:
        raise ValueError(f"{args.profile} requires --cell-config")
    if args.profile == "sealed-ood" and args.campaign_key_file is None:
        raise ValueError("sealed-ood requires --campaign-key-file")
    if args.profile == "certify" and args.cell_config is None and args.input_root is None:
        raise ValueError("certify requires --cell-config or --input-root")
    scientific_compute = (
        args.profile in {"final-train", "sealed-ood", "replicate-train"}
        or (args.profile in {"tune", "interventions", "replicate-eval", "certify"}
            and args.cell_config is not None)
    )
    preflight = run_preflight(root, require_scientific_resources=scientific_compute)
    if not preflight["ok"]:
        raise RuntimeError("preflight failed; no scientific snapshot or run was created")
    files = bundle_files(root)
    source_hash = bundle_sha256(root, files)
    timestamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    suffix = f"{timestamp}_{source_hash[:16]}"
    snapshot = out_root / "snapshots" / f"bundle_{suffix}"
    run_directory = out_root / "runs" / f"run_{suffix}"
    snapshot_bundle(root, snapshot, files)
    frozen_script = snapshot / f"campaign_v23_{suffix}.py"
    shutil.copy2(snapshot / "campaign_v23.py", frozen_script)
    run_directory.mkdir(parents=True, exist_ok=False)
    command = _profile_command(
        args.profile,
        snapshot,
        frozen_script,
        run_directory,
        args.cell_config,
        args.campaign_key_file,
        args.input_root,
        args.episodes_per_ood_family,
    )
    provenance = {
        "schema": "v23-frozen-run-1",
        "profile": args.profile,
        "started_utc": timestamp,
        "source_sha256": source_hash,
        "snapshot": str(snapshot),
        "frozen_script": str(frozen_script),
        "frozen_script_sha256": sha256_file(frozen_script),
        "command": command,
        "cell_config_sha256": sha256_file(args.cell_config) if args.cell_config else None,
        "preflight": preflight,
    }
    write_new_json(run_directory / f"provenance_{suffix}.json", provenance)
    environment = os.environ.copy()
    environment["PYTHONPATH"] = str(snapshot)
    completed = subprocess.run(
        command,
        cwd=snapshot,
        env=environment,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    transcript = (
        "COMMAND=" + " ".join(command) + "\n"
        + "SOURCE_SHA256=" + source_hash + "\n"
        + "STDOUT\n" + completed.stdout + "\nSTDERR\n" + completed.stderr
    ).encode("utf-8")
    write_new_bytes(run_directory / f"run_{suffix}.txt", transcript)
    final_manifest = provenance | {
        "exit_code": completed.returncode,
        "transcript_sha256": hashlib.sha256(transcript).hexdigest(),
        "completed": completed.returncode == 0,
    }
    write_new_json(run_directory / f"run_{suffix}.json", final_manifest)
    if completed.returncode == 0:
        write_new_bytes(run_directory / "completion.marker", source_hash.encode("ascii") + b"\n")
    print(canonical_json(final_manifest))
    return completed.returncode


if __name__ == "__main__":
    raise SystemExit(main())
