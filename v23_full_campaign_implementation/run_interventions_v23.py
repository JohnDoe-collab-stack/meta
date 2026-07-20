#!/usr/bin/env python3
import argparse
import json

from v23.cli import command_run_interventions


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True)
    args = parser.parse_args()
    report = command_run_interventions(args.config)
    print(json.dumps(report, indent=2, default=str))
    return 0 if report["complete"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
