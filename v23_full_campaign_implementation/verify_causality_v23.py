#!/usr/bin/env python3
import argparse
import json

from v23.canonical import canonical_json
from v23.causality import certify_paired_causality, load_jsonl


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--paired-jsonl", required=True)
    parser.add_argument("--certificate", required=True)
    args = parser.parse_args()
    recalculated = certify_paired_causality(load_jsonl(args.paired_jsonl))
    published = json.loads(open(args.certificate, encoding="utf-8").read())
    same = canonical_json(recalculated) == canonical_json(published)
    print(json.dumps({"same": same, "complete": recalculated["complete"]}, indent=2))
    return 0 if same and recalculated["complete"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
