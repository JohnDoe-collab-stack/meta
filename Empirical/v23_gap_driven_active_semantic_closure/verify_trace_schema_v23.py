#!/usr/bin/env python3
"""Command-line structural verifier for canonical v23 JSONL traces.

The executable reuses the normative parser from ``trace_schema_v23``. It is
not an independent semantic verifier and does not certify the producer's
``validity_flags``.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Sequence

from trace_schema_v23 import TraceSchemaError, canonical_json, parse_trace_line


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("trace", type=Path, help="canonical UTF-8 JSONL trace")
    parser.add_argument(
        "--require-validity-flags",
        action="store_true",
        help="reject records containing an explicitly false validity flag",
    )
    return parser


def verify_file(path: Path, *, require_validity_flags: bool = False) -> dict[str, object]:
    raw = path.read_bytes()
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError as error:
        raise TraceSchemaError("invalid_utf8", "$", str(error)) from error
    if not text:
        raise TraceSchemaError("empty_trace", "$", "at least one record is required")
    if not text.endswith("\n"):
        raise TraceSchemaError("missing_final_newline", "$", "JSONL must end with LF")
    if "\r" in text:
        raise TraceSchemaError("carriage_return", "$", "only LF line endings are allowed")

    counts: dict[str, int] = {}
    records = 0
    # Split only on the JSONL delimiter. Unicode line-separator characters are
    # valid JSON string content and must not be interpreted as record breaks.
    for line_number, line in enumerate(text[:-1].split("\n"), start=1):
        if not line:
            raise TraceSchemaError("empty_line", f"$[{line_number}]", "blank lines are forbidden")
        try:
            record = parse_trace_line(
                line,
                require_canonical=True,
                require_claimed_validity=require_validity_flags,
            )
        except TraceSchemaError as error:
            raise TraceSchemaError(
                error.code, f"$[{line_number}]{error.path[1:]}", error.detail
            ) from error
        status = str(record["execution_status"])
        counts[status] = counts.get(status, 0) + 1
        records += 1

    return {
        "execution_status_counts": dict(sorted(counts.items())),
        "records": records,
        "sha256": hashlib.sha256(raw).hexdigest(),
        "trace": str(path),
        "valid": True,
    }


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        report = verify_file(
            args.trace, require_validity_flags=args.require_validity_flags
        )
    except (OSError, TraceSchemaError) as error:
        failure = {
            "error": str(error),
            "trace": str(args.trace),
            "valid": False,
        }
        print(canonical_json(failure), file=sys.stderr)
        return 1
    print(canonical_json(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
