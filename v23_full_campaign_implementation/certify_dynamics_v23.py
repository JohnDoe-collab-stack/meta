#!/usr/bin/env python3
import argparse

from v23.canonical import write_new_json
from v23.dynamics import certify_dynamics_jsonl


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--traces", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    report = certify_dynamics_jsonl(args.traces)
    write_new_json(args.out, report)
    return 0 if report["ok"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
