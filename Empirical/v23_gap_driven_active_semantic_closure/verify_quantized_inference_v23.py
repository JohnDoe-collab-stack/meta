#!/usr/bin/env python3
"""Independently replay a v23 quantized checkpoint on the exhaustive table."""

from __future__ import annotations

import argparse
import hashlib
import sys
from pathlib import Path
from typing import Sequence

from certifiable_agent_v23 import (
    HEAD_ORDER,
    certification_examples,
    checkpoint_error_report,
    checkpoint_from_dict,
    checkpoint_to_dict,
    infer_logits,
)
from trace_schema_v23 import canonical_json, parse_json_strict


def verify_checkpoint(value: object, *, replay_training: bool = False) -> dict[str, object]:
    checkpoint = checkpoint_from_dict(value)
    examples = certification_examples()
    report = checkpoint_error_report(checkpoint, examples)
    if report["valid"] is not True:
        raise ValueError("quantized checkpoint is not zero-error with strict margins")
    for name in HEAD_ORDER:
        expected_classes = tuple(sorted({row.target for row in examples[name]}))
        if checkpoint.heads[name].valid_classes != expected_classes:
            raise ValueError(f"{name} does not use the exact prescribed catalogue")
        valid = set(checkpoint.heads[name].valid_classes)
        for number, example in enumerate(examples[name]):
            logits = infer_logits(checkpoint.heads[name], example.features)
            if any(value != -128 for index, value in enumerate(logits) if index not in valid):
                raise ValueError(f"{name}[{number}] does not mask every reserved class")
    if replay_training:
        from train_certifiable_agent_v23 import train_first_admissible

        replayed = train_first_admissible()
        if checkpoint_to_dict(replayed.checkpoint) != checkpoint_to_dict(checkpoint):
            raise ValueError("deterministic training replay produced another checkpoint")
    return {
        **report,
        "replayed_training": replay_training,
        "seed": checkpoint.seed,
        "update": checkpoint.update,
    }


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("checkpoint", type=Path)
    parser.add_argument("--replay-training", action="store_true")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        raw = args.checkpoint.read_bytes()
        text = raw.decode("utf-8")
        if not text.endswith("\n") or "\r" in text:
            raise ValueError("checkpoint must be canonical LF-terminated UTF-8")
        value = parse_json_strict(text[:-1], require_canonical=True)
        report = verify_checkpoint(value, replay_training=args.replay_training)
        report["checkpoint_sha256"] = hashlib.sha256(raw).hexdigest()
    except (OSError, UnicodeDecodeError, ValueError) as error:
        print(canonical_json({"error": str(error), "valid": False}), file=sys.stderr)
        return 1
    print(canonical_json(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
