#!/usr/bin/env python3
"""Evaluate one frozen checkpoint cell on a fixed split."""

import argparse
import json

from v23.cli import command_evaluate


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True)
    args = parser.parse_args()
    report = command_evaluate(args.config)
    print(json.dumps({key: value for key, value in report.items() if key != "outcomes"}, indent=2, default=str))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
