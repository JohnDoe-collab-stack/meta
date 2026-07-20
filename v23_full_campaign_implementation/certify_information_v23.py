#!/usr/bin/env python3
import argparse

from v23.canonical import write_new_json
from v23.domains import FiniteReferenceDomain, PerceptualDomain, SymbolicDomain
from v23.no_go import certify_information_layer


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    reports = {
        domain.kind.value: certify_information_layer(domain)
        for domain in (FiniteReferenceDomain(), SymbolicDomain(), PerceptualDomain())
    }
    result = {
        "schema": "v23-all-information-layers-1",
        "reports": reports,
        "ok": all(report["ok"] for report in reports.values()),
    }
    write_new_json(args.out, result)
    return 0 if result["ok"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
