"""CUDA smoke adapter with deterministic CPU sampling for discrete decisions."""

from __future__ import annotations

import contextlib
import os
import threading
from pathlib import Path
from typing import Iterator

import torch
from torch.distributions import Categorical

from .canonical import sha256_file, write_new_json
from .contracts import ActiveDomain
from .training import TrainConfig, train_one_run


_SAMPLING_LOCK = threading.RLock()


def _sample_on_cpu(
    distribution: Categorical,
    sample_shape: torch.Size = torch.Size(),
) -> torch.Tensor:
    """Match Categorical.sample shapes while using the deterministic CPU kernel."""
    shape = torch.Size(sample_shape)
    target_device = distribution.probs.device
    probabilities = distribution.probs.detach().to(device="cpu")
    probabilities_2d = probabilities.reshape(-1, distribution._num_events)
    samples_2d = torch.multinomial(
        probabilities_2d,
        shape.numel(),
        replacement=True,
    ).transpose(0, 1)
    return samples_2d.reshape(distribution._extended_shape(shape)).to(target_device)


@contextlib.contextmanager
def deterministic_cuda_sampling() -> Iterator[None]:
    """Temporarily route non-differentiable categorical sampling through CPU."""
    with _SAMPLING_LOCK:
        original_sample = Categorical.sample

        def replacement(
            distribution: Categorical,
            sample_shape: torch.Size = torch.Size(),
        ) -> torch.Tensor:
            return _sample_on_cpu(distribution, sample_shape)

        Categorical.sample = replacement
        try:
            yield
        finally:
            Categorical.sample = original_sample


def train_one_cuda_smoke_v2(
    config: TrainConfig,
    domain: ActiveDomain,
) -> dict[str, object]:
    if config.run_kind != "smoke":
        raise ValueError("the CUDA v2 adapter is restricted to non-scientific smoke runs")
    if torch.device(config.device).type != "cuda":
        raise ValueError("the CUDA v2 adapter requires a CUDA device")
    if os.environ.get("CUBLAS_WORKSPACE_CONFIG") not in {":4096:8", ":16:8"}:
        raise RuntimeError("deterministic CUDA smoke requires CUBLAS_WORKSPACE_CONFIG")
    if not torch.cuda.is_available():
        raise RuntimeError("PyTorch CUDA is unavailable")

    with deterministic_cuda_sampling():
        report = train_one_run(config, domain)

    output = Path(config.output_directory)
    adapter_path = Path(__file__).resolve()
    adapter_manifest = {
        "schema": "v23-cuda-smoke-sampling-v2",
        "scientific_result": False,
        "training_device": config.device,
        "logits_device": "cuda",
        "gradient_device": "cuda",
        "categorical_sampling_device": "cpu",
        "adapter_sha256": sha256_file(adapter_path),
        "base_run_manifest_sha256": sha256_file(output / "run_manifest.json"),
    }
    write_new_json(output / "cuda_sampling_v2_manifest.json", adapter_manifest)
    return report | {"cuda_sampling_v2": adapter_manifest}
