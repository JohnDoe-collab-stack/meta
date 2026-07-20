#!/usr/bin/env python3
import argparse
import json

from v23.assignment import assign_resources
from v23.canonical import sha256_file, write_new_json


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--resources", required=True)
    parser.add_argument("--benchmark", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    resources = json.loads(open(args.resources, encoding="utf-8").read())
    report = assign_resources(resources, sha256_file(args.benchmark))
    write_new_json(args.out, report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
