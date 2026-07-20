#!/usr/bin/env python3
import argparse

from v23.benchmark import run_smoke_benchmark
from v23.canonical import write_new_json


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--device", default="cuda")
    parser.add_argument("--iterations", type=int, default=5)
    parser.add_argument("--batch-size", type=int, default=2)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    report = run_smoke_benchmark(args.device, args.iterations, args.batch_size)
    write_new_json(args.out, report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
