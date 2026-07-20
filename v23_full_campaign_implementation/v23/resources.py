"""Executed-branch parameter, activation and response-budget accounting."""

from __future__ import annotations

from typing import Any

import torch
from torch import nn

from .models import CausalAgent, trainable_parameter_count


def active_parameter_count(model: nn.Module, consumed_module_names: set[str]) -> int:
    active = 0
    for name, parameter in model.named_parameters():
        module_name = name.rsplit(".", 1)[0]
        if any(
            module_name == consumed or module_name.startswith(consumed + ".")
            for consumed in consumed_module_names
        ):
            active += parameter.numel()
    return active


def serialized_memory_bytes(memory: tuple[str, ...]) -> int:
    return sum(len(item.encode("utf-8")) + 4 for item in memory)


def resource_report(
    model: CausalAgent,
    consumed_module_names: set[str],
    queries: int,
    patches: int,
    steps: int,
    response_bytes: int,
    memory: tuple[str, ...],
) -> dict[str, Any]:
    active = active_parameter_count(model, consumed_module_names)
    total = trainable_parameter_count(model)
    violations = []
    if serialized_memory_bytes(memory) > 64 * 1024 and model.size_name == "base":
        violations.append("base serialized memory exceeds 64 KiB")
    if queries > steps or patches > steps:
        violations.append("query/patch count exceeds step budget")
    return {
        "schema": "v23-resource-report-1",
        "parameters_total": total,
        "parameters_active": active,
        "queries": queries,
        "patches": patches,
        "steps": steps,
        "response_bytes": response_bytes,
        "memory_bytes": serialized_memory_bytes(memory),
        "violations": tuple(violations),
        "ok": not violations,
    }
