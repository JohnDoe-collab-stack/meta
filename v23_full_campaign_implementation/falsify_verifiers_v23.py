#!/usr/bin/env python3
"""Cross-domain mutation campaign for independent verifiers."""

import argparse
import json

from v23.cli import command_falsify


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out-dir", required=True)
    args = parser.parse_args()
    report = command_falsify(args.out_dir)
    print(json.dumps(report, indent=2, default=str))
    return 0 if report["all_rejected"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
