"""Paired learned-model execution for all 18 causal interventions."""

from __future__ import annotations

import dataclasses
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import torch

from .canonical import canonical_json, sha256_file, write_new_bytes, write_new_json
from .contracts import ActiveDomain
from .encoding import BYTE_VOCAB_SIZE
from .evaluation import evaluate_model_episode
from .interventions import INTERVENTIONS
from .models import CausalAgent
from .seeds import derive_seed


@dataclass(frozen=True)
class InterventionRunConfig:
    checkpoint: str
    training_manifest: str
    domain: str
    system: str
    size: str
    seeds: tuple[int, ...]
    episodes_per_seed: int
    maximum_steps: int
    output_directory: str
    device: str = "cpu"


def run_paired_interventions(
    config: InterventionRunConfig, domain: ActiveDomain
) -> dict[str, Any]:
    if config.system != "B13":
        raise ValueError("confirmatory causal interventions target B13")
    if not config.seeds or config.episodes_per_seed <= 0:
        raise ValueError("intervention campaign needs seeds and episodes")
    output = Path(config.output_directory)
    output.mkdir(parents=True, exist_ok=False)
    device = torch.device(config.device)
    model = CausalAgent(
        size=config.size,
        vocab_size=BYTE_VOCAB_SIZE,
        system_id=config.system,
        dropout=0.0,
    ).to(device)
    model.load_state_dict(
        torch.load(config.checkpoint, map_location=device, weights_only=True)
    )
    model.eval()
    lines: list[bytes] = []
    typed_refusals = 0
    with torch.no_grad():
        for seed in config.seeds:
            for episode_index in range(config.episodes_per_seed):
                episode_seed = derive_seed(seed, "intervention-episode", episode_index)
                episode = domain.generate_episode(episode_seed, episode_index % 32)
                _, control = evaluate_model_episode(
                    model,
                    domain,
                    episode,
                    episode_seed,
                    config.maximum_steps,
                    device,
                )
                control_score = int(
                    bool(control.get("closed")) and bool(control.get("certified"))
                ) * 1_000_000
                for intervention_id, spec in INTERVENTIONS.items():
                    _, intervened = evaluate_model_episode(
                        model,
                        domain,
                        episode,
                        episode_seed,
                        config.maximum_steps,
                        device,
                        intervention_id=intervention_id,
                    )
                    intervention_score = int(
                        bool(intervened.get("closed"))
                        and bool(intervened.get("certified"))
                    ) * 1_000_000
                    typed_refusal = bool(intervened.get("typed_refusal"))
                    typed_refusals += int(typed_refusal)
                    record = {
                        "schema": "v23-paired-intervention-1",
                        "intervention_id": intervention_id,
                        "seed": seed,
                        "episode_index": episode_index,
                        "episode_id": episode.episode_id,
                        "checkpoint_sha256": sha256_file(config.checkpoint),
                        "noise_seed": episode_seed,
                        "fixed_variables": spec.fixed_variables,
                        "recomputed_variables": spec.recomputed_variables,
                        "control_score_micros": control_score,
                        "intervened_score_micros": intervention_score,
                        "typed_refusal": typed_refusal,
                    }
                    lines.append((canonical_json(record) + "\n").encode("utf-8"))
    trace_path = output / "paired_interventions.jsonl"
    write_new_bytes(trace_path, b"".join(lines))
    report = {
        "schema": "v23-intervention-run-1",
        "config": dataclasses.asdict(config),
        "records": len(lines),
        "expected_records": len(config.seeds) * config.episodes_per_seed * len(INTERVENTIONS),
        "typed_refusals": typed_refusals,
        "next_bypass_refusals_expected": len(config.seeds) * config.episodes_per_seed,
        "checkpoint_sha256": sha256_file(config.checkpoint),
        "training_manifest_sha256": sha256_file(config.training_manifest),
        "complete": len(lines) == len(config.seeds) * config.episodes_per_seed * len(INTERVENTIONS)
        and typed_refusals == len(config.seeds) * config.episodes_per_seed,
        "protocol_coverage_complete": set(config.seeds) == set(range(10))
        and config.episodes_per_seed == 4096,
    }
    write_new_json(output / "intervention_run_manifest.json", report)
    return report
