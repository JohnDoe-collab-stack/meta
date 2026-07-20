#!/usr/bin/env python3
import argparse

from v23.canonical import write_new_json
from v23.causality import certify_paired_causality, load_jsonl


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--paired-jsonl", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--expected-episodes-per-seed", type=int, default=4096)
    parser.add_argument("--expected-seeds", default="0,1,2,3,4,5,6,7,8,9")
    args = parser.parse_args()
    seeds = tuple(int(value) for value in args.expected_seeds.split(",") if value)
    report = certify_paired_causality(
        load_jsonl(args.paired_jsonl), seeds, args.expected_episodes_per_seed
    )
    write_new_json(args.out, report)
    return 0 if report["complete"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
