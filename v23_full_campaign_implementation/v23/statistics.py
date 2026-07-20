"""Deterministic paired statistics required by the confirmatory protocol."""

from __future__ import annotations

from itertools import product
from typing import Mapping, Sequence

import numpy as np

from .seeds import numpy_rng


def exact_sign_flip_pvalue(
    paired_differences: Sequence[float], alternative: str = "greater"
) -> float:
    values = np.asarray(paired_differences, dtype=np.float64)
    if values.ndim != 1 or len(values) == 0:
        raise ValueError("paired differences must be a non-empty vector")
    if len(values) > 20:
        raise ValueError("exact enumeration is intentionally bounded at 20 pairs")
    observed = float(values.mean())
    enumerated = []
    for signs in product((-1.0, 1.0), repeat=len(values)):
        enumerated.append(float((values * np.asarray(signs)).mean()))
    tolerance = 1e-15
    if alternative == "greater":
        extreme = sum(value >= observed - tolerance for value in enumerated)
    elif alternative == "less":
        extreme = sum(value <= observed + tolerance for value in enumerated)
    elif alternative == "two-sided":
        extreme = sum(abs(value) >= abs(observed) - tolerance for value in enumerated)
    else:
        raise ValueError("alternative must be greater, less or two-sided")
    return extreme / len(enumerated)


def holm_adjust(p_values: Mapping[str, float]) -> dict[str, float]:
    if any(value < 0 or value > 1 for value in p_values.values()):
        raise ValueError("p-values must lie in [0, 1]")
    ordered = sorted(p_values.items(), key=lambda item: (item[1], item[0]))
    count = len(ordered)
    adjusted: dict[str, float] = {}
    running = 0.0
    for rank, (name, value) in enumerate(ordered):
        candidate = min(1.0, (count - rank) * value)
        running = max(running, candidate)
        adjusted[name] = running
    return {name: adjusted[name] for name in p_values}


def hierarchical_paired_bootstrap(
    by_seed: Mapping[int, Sequence[float]],
    repetitions: int = 10_000,
    root_seed: int = 239_000,
) -> dict[str, int]:
    if repetitions <= 0 or not by_seed:
        raise ValueError("bootstrap needs data and positive repetitions")
    seeds = tuple(sorted(by_seed))
    if any(len(by_seed[seed]) == 0 for seed in seeds):
        raise ValueError("each seed needs at least one paired episode")
    generator = numpy_rng(root_seed, "hierarchical-paired-bootstrap")
    replicates = np.empty(repetitions, dtype=np.float64)
    for repetition in range(repetitions):
        sampled_seed_indices = generator.integers(0, len(seeds), size=len(seeds))
        seed_means = []
        for seed_index in sampled_seed_indices:
            values = np.asarray(by_seed[seeds[int(seed_index)]], dtype=np.float64)
            episode_indices = generator.integers(0, len(values), size=len(values))
            seed_means.append(float(values[episode_indices].mean()))
        replicates[repetition] = float(np.mean(seed_means))
    point = float(np.mean([np.mean(by_seed[seed]) for seed in seeds]))
    lower, upper = np.percentile(replicates, [2.5, 97.5], method="linear")
    return {
        "point_micros": int(round(point * 1_000_000)),
        "lower_95_micros": int(round(float(lower) * 1_000_000)),
        "upper_95_micros": int(round(float(upper) * 1_000_000)),
        "repetitions": repetitions,
        "seed_count": len(seeds),
    }


def expected_calibration_error(
    probabilities: Sequence[float], outcomes: Sequence[int], bins: int = 10
) -> float:
    if len(probabilities) != len(outcomes) or not probabilities:
        raise ValueError("probabilities and outcomes must be non-empty and aligned")
    if bins <= 0:
        raise ValueError("bins must be positive")
    values = np.asarray(probabilities, dtype=np.float64)
    labels = np.asarray(outcomes, dtype=np.float64)
    if np.any(values < 0) or np.any(values > 1):
        raise ValueError("probabilities must lie in [0, 1]")
    total = len(values)
    error = 0.0
    for index in range(bins):
        lower = index / bins
        upper = (index + 1) / bins
        selected = (values >= lower) & (
            values <= upper if index == bins - 1 else values < upper
        )
        if np.any(selected):
            error += float(selected.sum()) / total * abs(
                float(values[selected].mean()) - float(labels[selected].mean())
            )
    return error
