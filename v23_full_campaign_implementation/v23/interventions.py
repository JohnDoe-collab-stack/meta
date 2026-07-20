"""Pre-registered causal intervention matrix and DAG partition checks."""

from __future__ import annotations

from dataclasses import dataclass


CAUSAL_ORDER = (
    "projection",
    "gap",
    "use",
    "transport",
    "query",
    "response",
    "repair",
    "next",
    "history",
)


@dataclass(frozen=True)
class InterventionSpec:
    intervention_id: str
    target: str
    operator: str

    @property
    def fixed_variables(self) -> tuple[str, ...]:
        index = CAUSAL_ORDER.index(self.target)
        return CAUSAL_ORDER[:index]

    @property
    def recomputed_variables(self) -> tuple[str, ...]:
        index = CAUSAL_ORDER.index(self.target)
        return CAUSAL_ORDER[index:]


_RAW = (
    ("I_projection", "projection", "replace_with_declared_projection"),
    ("I_gap_suppress", "gap", "typed_neutral"),
    ("I_gap_permute", "gap", "canonical_permutation"),
    ("I_use_suppress", "use", "typed_neutral"),
    ("I_use_permute", "use", "canonical_permutation"),
    ("I_transport_suppress", "transport", "typed_neutral"),
    ("I_transport_permute", "transport", "canonical_permutation"),
    ("I_query_neutral", "query", "typed_neutral"),
    ("I_query_alternate", "query", "next_authorized"),
    ("I_response_cross", "response", "paired_cross_world"),
    ("I_response_neutral", "response", "typed_neutral"),
    ("I_repair_neutral", "repair", "typed_neutral"),
    ("I_repair_permute", "repair", "canonical_permutation"),
    ("I_next_bypass", "next", "forbidden_direct_transition"),
    ("I_history_drop", "history", "empty_history"),
    ("I_order_swap", "transport", "swap_authorized_order"),
    ("I_random_gap", "gap", "seeded_random_typed_gap"),
    ("I_unused_gap", "use", "disconnect_gap_from_descendants"),
)


INTERVENTIONS = {
    intervention_id: InterventionSpec(intervention_id, target, operator)
    for intervention_id, target, operator in _RAW
}


def validate_intervention_matrix() -> None:
    if len(INTERVENTIONS) != 18:
        raise ValueError("the pre-registered matrix must contain 18 interventions")
    for key, spec in INTERVENTIONS.items():
        if key != spec.intervention_id:
            raise ValueError("intervention registry key mismatch")
        fixed = set(spec.fixed_variables)
        recomputed = set(spec.recomputed_variables)
        if fixed & recomputed:
            raise ValueError("fixed and recomputed causal variables overlap")
        if fixed | recomputed != set(CAUSAL_ORDER):
            raise ValueError("causal partition is incomplete")
        ordered = spec.fixed_variables + spec.recomputed_variables
        if ordered != CAUSAL_ORDER:
            raise ValueError("causal partition violates the registered DAG")
    if INTERVENTIONS["I_next_bypass"].operator != "forbidden_direct_transition":
        raise ValueError("next bypass must lead to typed refusal")


validate_intervention_matrix()
