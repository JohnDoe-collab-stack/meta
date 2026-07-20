#!/usr/bin/env python3
import argparse

from v23.canonical import write_new_json
from v23.causality import certify_paired_causality, load_jsonl


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--paired-jsonl", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    report = certify_paired_causality(load_jsonl(args.paired_jsonl))
    write_new_json(args.out, report)
    return 0 if report["complete"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
