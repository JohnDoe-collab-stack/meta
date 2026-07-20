"""Single authoritative registry for systems B1 through B13."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class SystemSpec:
    system_id: str
    scientific_class: str
    allowed_inputs: tuple[str, ...]
    allowed_actions: tuple[str, ...]
    principal_contrast: bool
    reason: str
    computes_gap: bool = False
    gap_reaches_downstream: bool = False
    direct_next_head: bool = False
    oracle_patch: bool = False
    random_gap: bool = False


SYSTEMS: dict[str, SystemSpec] = {
    "B1": SystemSpec(
        "B1", "observation-only", ("observation",), ("continue",), True,
        "Tests whether the public observation alone is sufficient.",
    ),
    "B2": SystemSpec(
        "B2", "candidate-only", ("candidate",), ("continue",), True,
        "Tests whether candidate syntax leaks the answer.",
    ),
    "B3": SystemSpec(
        "B3", "passive-all-observations", ("observation", "candidate"),
        ("continue",), True, "Strong non-interactive encoder.",
    ),
    "B4": SystemSpec(
        "B4", "passive-recurrent", ("observation", "candidate", "history"),
        ("continue",), True, "Memory without authorized acquisition.",
    ),
    "B5": SystemSpec(
        "B5", "active-monolithic", ("observation", "candidate", "history"),
        ("query", "repair", "continue"), True,
        "Active sensing without typed gap/use/transport.",
    ),
    "B6": SystemSpec(
        "B6", "latent-planner", ("observation", "candidate", "history"),
        ("query", "repair", "continue"), True,
        "Learned latent state and explicit planner.",
    ),
    "B7": SystemSpec(
        "B7", "visible-factorized", ("observation", "candidate", "history"),
        ("gap", "use", "transport", "query", "repair", "continue"), True,
        "Factorization constrained to declared visible state.", True, True,
    ),
    "B8": SystemSpec(
        "B8", "query-patch-monolithic", ("observation", "candidate", "history", "response"),
        ("query", "repair", "continue"), True,
        "Separates interaction from typed intrinsic repair.",
    ),
    "B9": SystemSpec(
        "B9", "oracle-patch", ("observation", "candidate", "history", "response", "world"),
        ("query", "repair", "continue"), False,
        "Diagnostic upper bound using a forbidden external oracle.", oracle_patch=True,
    ),
    "B10": SystemSpec(
        "B10", "random-gap", ("observation", "candidate", "history", "random_gap"),
        ("gap", "use", "transport", "query", "repair", "continue"), True,
        "Falsifies the claim that any gap token is sufficient.", True, True,
        random_gap=True,
    ),
    "B11": SystemSpec(
        "B11", "blocked-gap", ("observation", "candidate", "history"),
        ("gap", "query", "repair", "continue"), True,
        "Computes a gap while blocking activation and gradient downstream.", True, False,
    ),
    "B12": SystemSpec(
        "B12", "direct-next", ("observation", "candidate", "history", "response"),
        ("query", "next", "continue"), False,
        "Diagnostic bypass whose next state is predicted directly.", direct_next_head=True,
    ),
    "B13": SystemSpec(
        "B13", "gap-driven-complete", ("observation", "candidate", "history", "response"),
        ("gap", "use", "transport", "query", "repair", "continue"), True,
        "Tested architecture with repair-derived transition.", True, True,
    ),
}


def validate_registry() -> None:
    expected = {f"B{index}" for index in range(1, 14)}
    if set(SYSTEMS) != expected:
        raise ValueError("system registry must contain exactly B1 through B13")
    for key, spec in SYSTEMS.items():
        if key != spec.system_id:
            raise ValueError("registry key and system id disagree")
    if not SYSTEMS["B9"].oracle_patch:
        raise ValueError("B9 must remain explicitly marked as an oracle")
    if not SYSTEMS["B12"].direct_next_head:
        raise ValueError("B12 must remain explicitly marked as a next-state bypass")
    if SYSTEMS["B13"].direct_next_head or SYSTEMS["B13"].oracle_patch:
        raise ValueError("B13 contains a forbidden bypass")


validate_registry()
