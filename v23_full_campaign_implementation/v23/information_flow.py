"""Static architecture and runtime provenance checks."""

from __future__ import annotations

import inspect
from dataclasses import dataclass
from typing import Iterable

import torch
from torch import Tensor, nn

from .baselines import SYSTEMS
from .models import CausalAgent


FORBIDDEN_B13_TOKENS = (
    "world",
    "target",
    "correct_patch",
    "private_family",
    "ood_key",
    "next_head",
)


def static_information_flow_audit(model: CausalAgent) -> dict[str, object]:
    violations = list(model.forbidden_bypass_audit())
    if model.system.system_id == "B13":
        signatures = "\n".join(
            str(inspect.signature(method))
            for method in (
                model.encode_public,
                model.decide_pre_response,
                model.decide_post_response,
            )
        ).lower()
        for token in FORBIDDEN_B13_TOKENS:
            if token in signatures:
                violations.append(f"forbidden B13 argument token: {token}")
        if model.system.direct_next_head:
            violations.append("B13 system specification enables direct next")
    if SYSTEMS["B11"].gap_reaches_downstream:
        violations.append("B11 registry does not block gap downstream")
    return {
        "schema": "v23-information-flow-static-1",
        "system": model.system.system_id,
        "violations": tuple(violations),
        "ok": not violations,
    }


@dataclass
class RuntimeFlowRecorder:
    consumed_modules: list[str]

    def __init__(self) -> None:
        self.consumed_modules = []
        self._handles: list[torch.utils.hooks.RemovableHandle] = []

    def attach(self, model: nn.Module) -> None:
        for name, module in model.named_modules():
            if name and not any(True for _ in module.children()):
                self._handles.append(
                    module.register_forward_hook(
                        lambda _module, _inputs, _output, module_name=name: self.consumed_modules.append(module_name)
                    )
                )

    def close(self) -> None:
        for handle in self._handles:
            handle.remove()
        self._handles.clear()

    def report(self, expected_prefixes: Iterable[str]) -> dict[str, object]:
        prefixes = tuple(expected_prefixes)
        missing = tuple(
            prefix
            for prefix in prefixes
            if not any(name.startswith(prefix) for name in self.consumed_modules)
        )
        return {
            "schema": "v23-information-flow-runtime-1",
            "consumed_modules": tuple(self.consumed_modules),
            "missing_expected": missing,
            "ok": not missing,
        }
