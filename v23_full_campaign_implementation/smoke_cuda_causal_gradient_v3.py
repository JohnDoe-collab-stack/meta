#!/usr/bin/env python3
"""Non-scientific smoke proving a non-zero causal gradient on CUDA."""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

import torch

from v23.canonical import sha256_file, write_new_json
from v23.domains import SymbolicDomain
from v23.encoding import BYTE_VOCAB_SIZE
from v23.models import CausalAgent
from v23.seeds import derive_seed, torch_seed
from v23.training import _supervised_step
from v23.training_cuda_smoke_v2 import deterministic_cuda_sampling


def run(output_path: str, batch_size: int, training_seed: int) -> dict[str, object]:
    if os.environ.get("CUBLAS_WORKSPACE_CONFIG") not in {":4096:8", ":16:8"}:
        raise RuntimeError("deterministic CUDA smoke requires CUBLAS_WORKSPACE_CONFIG")
    if not torch.cuda.is_available():
        raise RuntimeError("PyTorch CUDA is unavailable")
    if batch_size < 32:
        raise ValueError("causal gradient smoke requires a batch of at least 32")

    device = torch.device("cuda")
    seed = torch_seed(training_seed, "model-init")
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.use_deterministic_algorithms(True)
    model = CausalAgent(
        size="small",
        vocab_size=BYTE_VOCAB_SIZE,
        dropout=0.0,
        system_id="B13",
    ).to(device)
    domain = SymbolicDomain()
    episodes = [
        domain.generate_episode(
            derive_seed(training_seed, "training-episode", item),
            actual_index=item % 32,
        )
        for item in range(batch_size)
    ]
    model.zero_grad(set_to_none=True)
    with deterministic_cuda_sampling():
        loss, counts = _supervised_step(
            model,
            domain,
            episodes,
            "R_causal",
            device,
        )
    loss.backward()
    gradients = [
        parameter.grad.detach()
        for parameter in model.parameters()
        if parameter.grad is not None
    ]
    nonzero_gradient_elements = sum(
        int(torch.count_nonzero(gradient).item()) for gradient in gradients
    )
    gradient_l1_nanos = int(
        round(sum(float(gradient.abs().sum().cpu()) for gradient in gradients) * 1_000_000_000)
    )
    loss_nanos = int(round(float(loss.detach().cpu()) * 1_000_000_000))
    script_path = Path(__file__).resolve()
    report = {
        "schema": "v23-cuda-causal-gradient-smoke-3",
        "scientific_result": False,
        "ok": loss_nanos != 0
        and nonzero_gradient_elements > 0
        and gradient_l1_nanos > 0,
        "command": [str(script_path), *sys.argv[1:]],
        "script_sha256": sha256_file(script_path),
        "torch": torch.__version__,
        "compiled_cuda": torch.version.cuda,
        "device": torch.cuda.get_device_name(0),
        "batch_size": batch_size,
        "training_seed": training_seed,
        "loss_nanos": loss_nanos,
        "gradient_tensor_count": len(gradients),
        "nonzero_gradient_elements": nonzero_gradient_elements,
        "gradient_l1_nanos": gradient_l1_nanos,
        "counts": counts,
    }
    write_new_json(output_path, report)
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", required=True)
    parser.add_argument("--batch-size", type=int, default=64)
    parser.add_argument("--training-seed", type=int, default=25)
    args = parser.parse_args()
    report = run(args.out, args.batch_size, args.training_seed)
    print(f"CUDA_CAUSAL_GRADIENT_SMOKE_OK={report['ok']}")
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
