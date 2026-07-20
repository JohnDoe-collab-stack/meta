#!/usr/bin/env python3
import argparse

from v23.data import build_public_data_manifest


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", required=True)
    parser.add_argument("--without-commitments", action="store_true")
    args = parser.parse_args()
    build_public_data_manifest(args.out, not args.without_commitments)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
