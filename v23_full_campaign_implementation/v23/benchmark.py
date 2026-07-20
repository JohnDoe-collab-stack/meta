"""Target-machine smoke benchmark used before G0 resource assignment."""

from __future__ import annotations

import platform
import time
from typing import Any

import torch

from .domains import PerceptualDomain, SymbolicDomain
from .encoding import BYTE_VOCAB_SIZE, byte_tokens, encode_episode_batch, pad_token_rows
from .models import CATALOG_SIZES, CausalAgent


def _synchronize(device: torch.device) -> None:
    if device.type == "cuda":
        torch.cuda.synchronize(device)


def run_smoke_benchmark(
    device_name: str,
    iterations: int = 5,
    batch_size: int = 2,
) -> dict[str, Any]:
    if iterations <= 0 or batch_size <= 0:
        raise ValueError("benchmark iterations and batch size must be positive")
    device = torch.device(device_name)
    if device.type == "cuda" and not torch.cuda.is_available():
        raise RuntimeError("CUDA benchmark requested but unavailable")
    results: dict[str, Any] = {}
    for size in ("small", "base", "large"):
        for domain in (SymbolicDomain(), PerceptualDomain()):
            model = CausalAgent(
                size=size, vocab_size=BYTE_VOCAB_SIZE, system_id="B13", dropout=0.0
            ).to(device).eval()
            episodes = [domain.generate_episode(900_000 + index, index) for index in range(batch_size)]
            encoded = encode_episode_batch(domain, episodes)
            observation = encoded.observation.to(device)
            candidate = encoded.candidate.to(device)
            history = encoded.history.to(device)
            masks = {
                name: torch.ones(batch_size, width, dtype=torch.bool, device=device)
                for name, width in CATALOG_SIZES.items()
            }
            responses = pad_token_rows(
                [byte_tokens({"response": "smoke"}) for _ in episodes]
            ).to(device)
            durations = []
            with torch.no_grad():
                for iteration in range(iterations + 2):
                    _synchronize(device)
                    started = time.perf_counter_ns()
                    context = model.encode_public(
                        observation, candidate, history, encoded.symbolic
                    )
                    pre = model.decide_pre_response(context, masks)
                    model.decide_post_response(
                        context,
                        {name: output[1] for name, output in pre.items()},
                        responses,
                        masks,
                    )
                    _synchronize(device)
                    elapsed = time.perf_counter_ns() - started
                    if iteration >= 2:
                        durations.append(elapsed)
            key = f"{domain.kind.value}:{size}"
            results[key] = {
                "batch_size": batch_size,
                "iterations": iterations,
                "median_batch_nanoseconds": sorted(durations)[len(durations) // 2],
                "minimum_batch_nanoseconds": min(durations),
                "maximum_batch_nanoseconds": max(durations),
            }
            del model
            if device.type == "cuda":
                torch.cuda.empty_cache()
    return {
        "schema": "v23-smoke-benchmark-1",
        "device": device_name,
        "python": platform.python_version(),
        "torch": torch.__version__,
        "cuda": torch.version.cuda,
        "results": results,
    }
