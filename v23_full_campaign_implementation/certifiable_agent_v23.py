#!/usr/bin/env python3
import argparse
import json

from v23.certifiable import certify_catalog, verify_catalog


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    certify = subparsers.add_parser("certify")
    certify.add_argument("--out-dir", required=True)
    verify = subparsers.add_parser("verify")
    verify.add_argument("--directory", required=True)
    args = parser.parse_args()
    report = (
        certify_catalog(args.out_dir)
        if args.command == "certify"
        else verify_catalog(args.directory)
    )
    print(json.dumps({key: value for key, value in report.items() if key != "cases_data"}, indent=2))
    return 0 if report["ok"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
