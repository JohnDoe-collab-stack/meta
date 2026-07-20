"""Pre-evaluation baseline capacity and principal-contrast eligibility audit."""

from __future__ import annotations

from typing import Iterable

from torch import nn

from .baselines import SYSTEMS
from .models import CausalAgent


def _intended_prefixes(model: CausalAgent) -> tuple[str, ...]:
    prefixes = ["aggregator", "final_norm", "type_embedding", "aggregate_position"]
    allowed_inputs = set(model.system.allowed_inputs)
    if "observation" in allowed_inputs:
        prefixes.extend(("perceptual_encoder", "symbolic_encoder"))
    if "candidate" in allowed_inputs:
        prefixes.append("candidate_encoder")
    if "history" in allowed_inputs:
        prefixes.append("history_encoder")
    if "response" in allowed_inputs or "query" in model.system.allowed_actions:
        prefixes.append("response_encoder")
    for action in model.system.allowed_actions:
        if action in {"gap", "use", "transport", "query", "repair", "continue"}:
            prefixes.extend((f"heads.{action}", f"decision_embedding.{action}"))
    if model.system.direct_next_head:
        prefixes.append("direct_next_head")
    return tuple(prefixes)


def intended_parameter_count(model: nn.Module, prefixes: Iterable[str]) -> int:
    selected = tuple(prefixes)
    return sum(
        parameter.numel()
        for name, parameter in model.named_parameters()
        if parameter.requires_grad
        and any(name == prefix or name.startswith(prefix + ".") for prefix in selected)
    )


def parameter_fairness_report(size: str, domain: str) -> dict[str, object]:
    if domain not in {"perceptual", "symbolic"}:
        raise ValueError("domain must be perceptual or symbolic")
    counts: dict[str, int] = {}
    models: dict[str, CausalAgent] = {}
    for system_id in SYSTEMS:
        model = CausalAgent(size=size, system_id=system_id)
        models[system_id] = model
        prefixes = list(_intended_prefixes(model))
        unused_observation = "symbolic_encoder" if domain == "perceptual" else "perceptual_encoder"
        prefixes = [prefix for prefix in prefixes if prefix != unused_observation]
        counts[system_id] = intended_parameter_count(model, prefixes)
    target = counts["B13"]
    rows = {}
    for system_id, count in counts.items():
        deviation_ppm = abs(count - target) * 1_000_000 // max(1, target)
        matched = deviation_ppm <= 50_000
        spec = SYSTEMS[system_id]
        rows[system_id] = {
            "active_parameters": count,
            "target_parameters": target,
            "deviation_ppm": deviation_ppm,
            "within_five_percent": matched,
            "pre_registered_principal": spec.principal_contrast,
            "principal_contrast_eligible": spec.principal_contrast and matched,
            "resource_curve_required": spec.principal_contrast and not matched,
            "diagnostic_only": not spec.principal_contrast,
        }
    return {
        "schema": "v23-parameter-fairness-1",
        "size": size,
        "domain": domain,
        "rows": rows,
        "all_pre_registered_principal_matched": all(
            not SYSTEMS[system_id].principal_contrast or rows[system_id]["within_five_percent"]
            for system_id in SYSTEMS
        ),
    }
