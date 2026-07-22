#!/usr/bin/env python3
"""Non-scientific CUDA smoke for inference, backpropagation and discrete training."""

from __future__ import annotations

import argparse
import os
import platform
import sys
from pathlib import Path

import torch

from v23.benchmark import run_smoke_benchmark
from v23.canonical import sha256_file, write_new_json
from v23.domains import SymbolicDomain
from v23.training import TrainConfig, train_one_run


def _training_smoke(output: Path, regime: str, seed: int) -> dict[str, object]:
    config = TrainConfig(
        domain="symbolic",
        system="B13",
        size="small",
        regime=regime,
        training_seed=seed,
        output_directory=str(output),
        data_manifest="smoke-only",
        maximum_updates=1,
        batch_size=2,
        warmup_updates=1,
        checkpoint_interval=10,
        dropout_micros=0,
        device="cuda",
        run_kind="smoke",
    )
    report = train_one_run(config, SymbolicDomain())
    return {
        "checkpoint": report["final_checkpoint"],
        "cuda_available": report["cuda_available"],
        "forbidden_bypass_violations": report["forbidden_bypass_violations"],
        "metrics": report["metrics"],
        "parameters": report["parameters"],
        "regime": regime,
    }


def run_cuda_smoke(output_directory: str, iterations: int) -> dict[str, object]:
    if os.environ.get("CUBLAS_WORKSPACE_CONFIG") not in {":4096:8", ":16:8"}:
        raise RuntimeError(
            "set CUBLAS_WORKSPACE_CONFIG=:4096:8 before starting the CUDA smoke"
        )
    if not torch.cuda.is_available():
        raise RuntimeError("PyTorch CUDA is unavailable")
    if iterations <= 0:
        raise ValueError("iterations must be positive")

    output = Path(output_directory)
    output.mkdir(parents=True, exist_ok=False)
    torch.cuda.set_device(0)
    torch.cuda.reset_peak_memory_stats(0)

    left = torch.arange(4096, dtype=torch.float32, device="cuda").reshape(64, 64)
    product = left @ left.transpose(0, 1)
    torch.cuda.synchronize(0)
    tensor_smoke_ok = bool(torch.isfinite(product).all().item())
    del left, product

    benchmark = run_smoke_benchmark(
        device_name="cuda",
        iterations=iterations,
        batch_size=1,
    )
    supervised = _training_smoke(
        output / "training_supervised_smoke", "R_supervised", 23
    )
    causal = _training_smoke(output / "training_causal_smoke", "R_causal", 24)
    torch.cuda.synchronize(0)
    properties = torch.cuda.get_device_properties(0)
    script_path = Path(__file__).resolve()
    report = {
        "schema": "v23-cuda-smoke-1",
        "scientific_result": False,
        "ok": tensor_smoke_ok
        and bool(supervised["cuda_available"])
        and bool(causal["cuda_available"]),
        "command": [str(script_path), *sys.argv[1:]],
        "script_sha256": sha256_file(script_path),
        "python": platform.python_version(),
        "torch": torch.__version__,
        "compiled_cuda": torch.version.cuda,
        "cudnn": torch.backends.cudnn.version(),
        "determinism": os.environ["CUBLAS_WORKSPACE_CONFIG"],
        "device": {
            "name": properties.name,
            "compute_capability": f"{properties.major}.{properties.minor}",
            "total_memory_bytes": int(properties.total_memory),
            "peak_memory_allocated_bytes": int(torch.cuda.max_memory_allocated(0)),
        },
        "tensor_smoke_ok": tensor_smoke_ok,
        "benchmark": benchmark,
        "training": {
            "supervised": supervised,
            "causal": causal,
        },
    }
    write_new_json(output / "cuda_smoke_report.json", report)
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out-dir", required=True)
    parser.add_argument("--iterations", type=int, default=2)
    args = parser.parse_args()
    report = run_cuda_smoke(args.out_dir, args.iterations)
    print(f"CUDA_SMOKE_OK={report['ok']}")
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
