#!/usr/bin/env python3
"""Exactly one training cell from an immutable JSON configuration."""

import argparse
import json

from v23.cli import command_train


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True)
    args = parser.parse_args()
    report = command_train(args.config)
    print(json.dumps({key: value for key, value in report.items() if key != "metrics"}, indent=2, default=str))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
