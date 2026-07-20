"""Exhaustive campaign matrix, stable identifiers and dependency DAG."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterable

from .baselines import SYSTEMS
from .canonical import content_sha256


DOMAINS = ("perceptual", "symbolic")
SIZES = ("small", "base", "large")
REGIMES = ("R_supervised", "R_intermediate", "R_causal")
FINAL_SEEDS = tuple(range(10))
REPLICATION_SEEDS = tuple(range(10, 20))
SPLITS = ("iid_test", "ood_composition", "ood_horizon", "ood_presentation", "ood_action_response", "ood_cross_family")


@dataclass(frozen=True)
class RunCell:
    domain: str
    system: str
    size: str
    regime: str
    configuration: str
    seed: int
    split: str
    profile: str

    @property
    def run_id(self) -> str:
        return "v23-" + content_sha256(self.__dict__)[:24]


def final_training_matrix(seeds: Iterable[int] = FINAL_SEEDS) -> tuple[RunCell, ...]:
    cells = tuple(
        RunCell(domain, system, size, regime, "final", seed, "train", "final-train")
        for domain, system, size, regime, seed in product(
            DOMAINS, tuple(SYSTEMS), SIZES, REGIMES, tuple(seeds)
        )
    )
    validate_matrix(cells)
    return cells


def tuning_matrix() -> tuple[RunCell, ...]:
    configurations = tuple(
        f"lr{learning_rate}-wd{weight_decay}-do{dropout}"
        for learning_rate, weight_decay, dropout in product(
            (100, 300, 1000), (0, 10_000), (0, 100_000)
        )
    )
    cells = tuple(
        RunCell(domain, system, size, regime, configuration, seed, "validation", "tune")
        for domain, system, size, regime, configuration, seed in product(
            DOMAINS,
            tuple(SYSTEMS),
            SIZES,
            REGIMES,
            configurations,
            (100, 101, 102),
        )
    )
    validate_matrix(cells)
    return cells


def evaluation_matrix(replication: bool = False) -> tuple[RunCell, ...]:
    seeds = REPLICATION_SEEDS if replication else FINAL_SEEDS
    profile = "replicate-eval" if replication else "evaluate"
    cells = tuple(
        RunCell(domain, system, size, regime, "selected", seed, split, profile)
        for domain, system, size, regime, seed, split in product(
            DOMAINS, tuple(SYSTEMS), SIZES, REGIMES, seeds, SPLITS
        )
    )
    validate_matrix(cells)
    return cells


def validate_matrix(cells: tuple[RunCell, ...]) -> None:
    identifiers = [cell.run_id for cell in cells]
    if len(identifiers) != len(set(identifiers)):
        raise ValueError("campaign matrix contains duplicate stable run identifiers")
    for cell in cells:
        if cell.domain not in DOMAINS or cell.system not in SYSTEMS:
            raise ValueError("matrix contains an unknown domain or system")
        if cell.size not in SIZES or cell.regime not in REGIMES:
            raise ValueError("matrix contains an unknown size or regime")


def campaign_dag() -> dict[str, tuple[str, ...]]:
    return {
        "preflight": (),
        "finite-conformance": ("preflight",),
        "certifiable-agent": ("finite-conformance",),
        "sealed-ood": ("preflight",),
        "tune": ("preflight", "sealed-ood"),
        "final-train": ("tune",),
        "interventions": ("final-train",),
        "certify": ("interventions",),
        "falsify": ("certify",),
        "replicate-eval": ("falsify",),
        "replicate-train": ("falsify",),
        "audit": ("replicate-eval", "replicate-train"),
    }


def estimate_matrix(cells: tuple[RunCell, ...]) -> dict[str, int]:
    return {
        "run_cells": len(cells),
        "maximum_updates": sum(120_000 if cell.profile == "final-train" else 0 for cell in cells),
        "nominal_checkpoints": sum(24 if cell.profile == "final-train" else 0 for cell in cells),
    }
