#!/usr/bin/env python3
import argparse

from v23.cli import command_seal_ood


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out-dir", required=True)
    parser.add_argument("--campaign-key-file", required=True)
    parser.add_argument("--episodes-per-family", type=int, default=8192)
    args = parser.parse_args()
    command_seal_ood(args.out_dir, args.campaign_key_file, args.episodes_per_family)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
