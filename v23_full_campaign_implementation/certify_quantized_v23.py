#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import torch

from v23.canonical import sha256_file, write_new_json
from v23.quantized import quantize_symmetric


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--checkpoint", required=True)
    parser.add_argument("--out-dir", required=True)
    args = parser.parse_args()
    output = Path(args.out_dir)
    output.mkdir(parents=True, exist_ok=False)
    state = torch.load(args.checkpoint, map_location="cpu", weights_only=True)
    arrays = {}
    tensors = {}
    for name in sorted(state):
        quantized = quantize_symmetric(state[name])
        arrays[name] = quantized.array()
        tensors[name] = {
            "shape": quantized.shape,
            "scale_nanos": quantized.scale_nanos,
            "dtype": "Int8",
        }
    archive = output / "weights_int8.npz"
    np.savez(archive, **arrays)
    report = {
        "schema": "v23-quantized-checkpoint-1",
        "checkpoint_sha256": sha256_file(args.checkpoint),
        "archive_sha256": sha256_file(archive),
        "weight_dtype": "Int8",
        "accumulator_dtype": "Int32",
        "tensors": tensors,
    }
    write_new_json(output / "quantized_manifest.json", report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
