#!/usr/bin/env python3
"""Train and quantize the exhaustive v23 Level-A certifiable agent."""

from __future__ import annotations

import argparse
import hashlib
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence

import torch
from torch import nn

from certifiable_agent_v23 import (
    HEAD_INPUT_DIMS,
    HEAD_ORDER,
    HEAD_OUTPUT_DIMS,
    HIDDEN_DIM,
    INT8_MAX,
    INT8_MIN,
    HeadExample,
    QuantizedCheckpoint,
    QuantizedHead,
    canonical_argmax,
    certification_examples,
    checkpoint_error_report,
    checkpoint_to_dict,
    infer_logits,
)
from trace_schema_v23 import canonical_json, canonical_sha256


@dataclass(frozen=True)
class TrainingResult:
    checkpoint: QuantizedCheckpoint
    report: dict[str, object]


# Fixed before the certified run.  The pair is
# (first-layer scale power, second-layer scale power).
QUANTIZATION_POWERS: dict[str, tuple[int, int]] = {
    "gap": (2, 7),
    "use": (2, 7),
    "transport": (4, 5),
    "query": (2, 5),
    "repair": (6, 4),
}


class CertifiableHead(nn.Module):
    def __init__(self, input_dim: int, output_dim: int) -> None:
        super().__init__()
        self.hidden = nn.Linear(input_dim, HIDDEN_DIM)
        self.output = nn.Linear(HIDDEN_DIM, output_dim)

    def forward(self, inputs: torch.Tensor) -> torch.Tensor:
        return self.output(torch.relu(self.hidden(inputs)))


def _tensor_rows(examples: Sequence[HeadExample]) -> tuple[torch.Tensor, torch.Tensor]:
    features = torch.tensor([row.features for row in examples], dtype=torch.float32)
    targets = torch.tensor([row.target for row in examples], dtype=torch.long)
    return features, targets


def _quantize_tensor(tensor: torch.Tensor, scale_power: int) -> tuple[tuple[int, ...], ...]:
    scale = 1 << scale_power
    rows = torch.round(tensor.detach().cpu() * scale).to(torch.int64).tolist()
    return tuple(tuple(int(value) for value in row) for row in rows)


def _quantize_vector(tensor: torch.Tensor, scale_power: int) -> tuple[int, ...]:
    scale = 1 << scale_power
    return tuple(
        int(value)
        for value in torch.round(tensor.detach().cpu() * scale).to(torch.int64).tolist()
    )


def _within_int8(values: object) -> bool:
    if isinstance(values, int):
        return INT8_MIN <= values <= INT8_MAX
    return all(_within_int8(value) for value in values)  # type: ignore[arg-type]


def quantize_head(
    model: CertifiableHead,
    *,
    name: str,
    valid_classes: tuple[int, ...],
    examples: Sequence[HeadExample],
) -> QuantizedHead | None:
    hidden_power, output_power = QUANTIZATION_POWERS[name]
    hidden_weights = _quantize_tensor(model.hidden.weight, hidden_power)
    hidden_bias = _quantize_vector(model.hidden.bias, hidden_power)
    output_weights = _quantize_tensor(model.output.weight, output_power)
    output_bias = _quantize_vector(model.output.bias, hidden_power + output_power)
    if not all(
        _within_int8(values)
        for values in (hidden_weights, hidden_bias, output_weights, output_bias)
    ):
        return None
    head = QuantizedHead(
        input_dim=HEAD_INPUT_DIMS[name],
        output_dim=HEAD_OUTPUT_DIMS[name],
        hidden_weights=hidden_weights,
        hidden_bias=hidden_bias,
        output_weights=output_weights,
        output_bias=output_bias,
        hidden_shift=0,
        output_shift=hidden_power,
        valid_classes=valid_classes,
    )
    minimum_margin = 255
    for example in examples:
        logits = infer_logits(head, example.features)
        predicted = canonical_argmax(logits)
        competitors = [value for index, value in enumerate(logits) if index != predicted]
        minimum_margin = min(minimum_margin, logits[predicted] - max(competitors))
        if predicted != example.target:
            return None
    return head if minimum_margin > 0 else None


def train_first_admissible(
    *,
    seeds: Sequence[int] = tuple(range(10)),
    maximum_updates: int = 2000,
) -> TrainingResult:
    examples = certification_examples()
    tensors = {name: _tensor_rows(examples[name]) for name in HEAD_ORDER}
    valid_classes = {
        name: tuple(sorted({row.target for row in examples[name]})) for name in HEAD_ORDER
    }
    for seed in seeds:
        torch.manual_seed(seed)
        torch.use_deterministic_algorithms(True)
        models = {
            name: CertifiableHead(HEAD_INPUT_DIMS[name], HEAD_OUTPUT_DIMS[name])
            for name in HEAD_ORDER
        }
        parameters = chain_parameters(models)
        optimizer = torch.optim.AdamW(
            parameters,
            lr=0.001,
            betas=(0.9, 0.95),
            weight_decay=0.0,
        )
        for update in range(1, maximum_updates + 1):
            optimizer.zero_grad(set_to_none=True)
            loss = torch.zeros((), dtype=torch.float32)
            for name in HEAD_ORDER:
                features, targets = tensors[name]
                logits = models[name](features)
                invalid = sorted(
                    set(range(HEAD_OUTPUT_DIMS[name])) - set(valid_classes[name])
                )
                if invalid:
                    logits[:, invalid] = -1.0e9
                loss = loss + nn.functional.cross_entropy(logits, targets)
            loss.backward()
            optimizer.step()
            quantized: dict[str, QuantizedHead] = {}
            for name in HEAD_ORDER:
                head = quantize_head(
                    models[name],
                    name=name,
                    valid_classes=valid_classes[name],
                    examples=examples[name],
                )
                if head is None:
                    break
                quantized[name] = head
            if tuple(quantized) != HEAD_ORDER:
                continue
            checkpoint = QuantizedCheckpoint(
                heads=quantized, seed=seed, update=update
            )
            report = checkpoint_error_report(checkpoint, examples)
            if report["valid"] is True:
                return TrainingResult(checkpoint, report)
    raise RuntimeError("no admissible quantized checkpoint in the pre-registered grid")


def chain_parameters(models: dict[str, CertifiableHead]) -> list[nn.Parameter]:
    return [parameter for name in HEAD_ORDER for parameter in models[name].parameters()]


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--maximum-updates", type=int, default=2000)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        result = train_first_admissible(maximum_updates=args.maximum_updates)
        value = checkpoint_to_dict(result.checkpoint)
        args.out.write_text(canonical_json(value) + "\n", encoding="utf-8", newline="\n")
        report = {
            **result.report,
            "checkpoint": str(args.out),
            "checkpoint_sha256": hashlib.sha256(args.out.read_bytes()).hexdigest(),
            "dataset_sha256": canonical_sha256(
                {
                    name: [
                        {"features": list(row.features), "target": row.target}
                        for row in certification_examples()[name]
                    ]
                    for name in HEAD_ORDER
                }
            ),
            "seed": result.checkpoint.seed,
            "update": result.checkpoint.update,
        }
    except (OSError, RuntimeError, ValueError) as error:
        print(canonical_json({"error": str(error), "valid": False}), file=sys.stderr)
        return 1
    print(canonical_json(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
