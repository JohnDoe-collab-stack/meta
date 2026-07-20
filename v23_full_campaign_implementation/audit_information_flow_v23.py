#!/usr/bin/env python3
import argparse

from v23.baselines import SYSTEMS
from v23.canonical import write_new_json
from v23.information_flow import static_information_flow_audit
from v23.models import CausalAgent


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--size", choices=("small", "base", "large"), default="base")
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    reports = {
        system: static_information_flow_audit(
            CausalAgent(size=args.size, system_id=system)
        )
        for system in SYSTEMS
    }
    payload = {
        "schema": "v23-information-flow-all-systems-1",
        "reports": reports,
        "all_ok": all(report["ok"] for report in reports.values()),
    }
    write_new_json(args.out, payload)
    return 0 if payload["all_ok"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
