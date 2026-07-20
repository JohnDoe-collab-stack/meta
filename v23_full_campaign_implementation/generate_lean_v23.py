#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

from v23.canonical import write_new_json
from v23.lean_export import export_trace_blocks
from v23.verification import trace_from_payload


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--traces", required=True)
    parser.add_argument("--out-dir", required=True)
    args = parser.parse_args()
    traces = []
    with Path(args.traces).open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            try:
                traces.append(trace_from_payload(json.loads(line)))
            except Exception as error:
                raise ValueError(f"cannot decode trace line {line_number}: {error}") from error
    report = export_trace_blocks(traces, args.out_dir)
    write_new_json(Path(args.out_dir) / "lean_export_manifest.json", report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
