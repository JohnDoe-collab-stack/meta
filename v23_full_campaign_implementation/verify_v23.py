#!/usr/bin/env python3
"""Independent fail-closed G0–G8 verifier."""

import argparse
import json

from v23.audit import audit_all_gates


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-root", required=True)
    parser.add_argument("--require-all-gates", action="store_true")
    args = parser.parse_args()
    report = audit_all_gates(args.run_root)
    print(json.dumps(report, indent=2, default=str))
    return 2 if args.require_all_gates and not report["all_pass"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
