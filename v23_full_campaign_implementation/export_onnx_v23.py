#!/usr/bin/env python3
from __future__ import annotations

import argparse

import torch

from v23.encoding import BYTE_VOCAB_SIZE
from v23.models import CATALOG_SIZES, CausalAgent
from v23.onnx_support import export_symbolic_pre_response


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--checkpoint", required=True)
    parser.add_argument("--system", default="B13")
    parser.add_argument("--size", choices=("small", "base", "large"), default="base")
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    model = CausalAgent(
        size=args.size, vocab_size=BYTE_VOCAB_SIZE, system_id=args.system, dropout=0.0
    )
    model.load_state_dict(torch.load(args.checkpoint, map_location="cpu", weights_only=True))
    model.eval()
    sample = (
        torch.zeros(1, 32, dtype=torch.long),
        torch.zeros(1, 32, dtype=torch.long),
        torch.zeros(1, 16, dtype=torch.long),
        torch.ones(1, CATALOG_SIZES["gap"], dtype=torch.bool),
        torch.ones(1, CATALOG_SIZES["use"], dtype=torch.bool),
        torch.ones(1, CATALOG_SIZES["transport"], dtype=torch.bool),
        torch.ones(1, CATALOG_SIZES["query"], dtype=torch.bool),
    )
    export_symbolic_pre_response(model, sample, args.out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
