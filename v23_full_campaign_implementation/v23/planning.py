"""Pre-G0 compute and storage estimator derived from the registered matrix."""

from __future__ import annotations

import gc

from .campaign import evaluation_matrix, final_training_matrix, tuning_matrix
from .models import CausalAgent, trainable_parameter_count


def campaign_resource_estimate() -> dict[str, int]:
    parameters: dict[str, int] = {}
    for size in ("small", "base", "large"):
        model = CausalAgent(size=size, system_id="B12")
        parameters[size] = trainable_parameter_count(model)
        del model
        gc.collect()
    tune_cells = tuning_matrix()
    final_cells = final_training_matrix()
    evaluation_cells = evaluation_matrix()
    tune_per_size = len(tune_cells) // 3
    final_per_size = len(final_cells) // 3
    # AdamW resumable checkpoints: weights, two moments and conservative overhead.
    tune_checkpoint_bytes = sum(
        tune_per_size * (6 * 16 + 4) * parameters[size]
        for size in parameters
    )
    final_checkpoint_bytes = sum(
        final_per_size * (24 * 16 + 4) * parameters[size]
        for size in parameters
    )
    evaluation_episode_count = len(evaluation_cells) * 8192
    trace_bytes = evaluation_episode_count * 12 * 1024
    intervention_episode_count = 2 * 10 * 18 * 4096
    intervention_bytes = intervention_episode_count * 2 * 1024
    ood_episode_count = 2 * 5 * 8192
    sealed_ood_bytes = ood_episode_count * 64 * 1024
    manifests_and_reports = 20 * 1024**3
    estimated_storage = (
        tune_checkpoint_bytes
        + final_checkpoint_bytes
        + trace_bytes
        + intervention_bytes
        + sealed_ood_bytes
        + manifests_and_reports
    )
    return {
        "tuning_cells": len(tune_cells),
        "final_training_cells": len(final_cells),
        "evaluation_cells": len(evaluation_cells),
        "evaluation_episodes": evaluation_episode_count,
        "intervention_episodes": intervention_episode_count,
        "sealed_ood_episodes": ood_episode_count,
        "small_parameters_upper": parameters["small"],
        "base_parameters_upper": parameters["base"],
        "large_parameters_upper": parameters["large"],
        "tuning_checkpoint_bytes": tune_checkpoint_bytes,
        "final_checkpoint_bytes": final_checkpoint_bytes,
        "trace_bytes": trace_bytes,
        "intervention_bytes": intervention_bytes,
        "sealed_ood_bytes": sealed_ood_bytes,
        "estimated_storage_bytes": estimated_storage,
        "required_free_storage_bytes": (estimated_storage * 3 + 1) // 2,
    }
