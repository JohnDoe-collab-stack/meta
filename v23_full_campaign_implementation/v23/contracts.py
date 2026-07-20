"""Frozen contracts shared by domains, agents, traces and audits."""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Mapping, Protocol, Sequence

from .canonical import content_sha256


JsonMap = Mapping[str, Any]


class DomainKind(str, Enum):
    FINITE = "finite"
    PERCEPTUAL = "perceptual"
    SYMBOLIC = "symbolic"


class GateStatus(str, Enum):
    PASS = "PASS"
    FAIL = "FAIL"
    NOT_RUN = "NOT_RUN"


class DecisionKind(str, Enum):
    DETECT = "detect"
    GAP = "gap"
    USE = "use"
    TRANSPORT = "transport"
    QUERY = "query"
    REPAIR = "repair"
    CONTINUE = "continue"


@dataclass(frozen=True)
class World:
    world_id: str
    public_observation: JsonMap
    hidden_state: JsonMap
    required_action: str
    query_answers: Mapping[str, str]


@dataclass(frozen=True)
class Episode:
    episode_id: str
    domain: DomainKind
    worlds: tuple[World, ...]
    actual_world_id: str
    query_catalog: tuple[str, ...]
    action_catalog: tuple[str, ...]
    repair_catalog: tuple[str, ...]
    metadata: JsonMap = field(default_factory=dict)

    def actual_world(self) -> World:
        for world in self.worlds:
            if world.world_id == self.actual_world_id:
                return world
        raise KeyError(f"unknown actual world {self.actual_world_id}")

    def validate_closed_family(self, exact_size: int = 32) -> None:
        if len(self.worlds) != exact_size:
            raise ValueError(f"family must contain exactly {exact_size} worlds")
        ids = [world.world_id for world in self.worlds]
        if len(ids) != len(set(ids)):
            raise ValueError("world ids must be unique")
        if self.actual_world_id not in set(ids):
            raise ValueError("actual world is not in the family")
        observation_groups: dict[str, list[World]] = {}
        for world in self.worlds:
            key = content_sha256(world.public_observation)
            observation_groups.setdefault(key, []).append(world)
            unknown_queries = set(world.query_answers) - set(self.query_catalog)
            if unknown_queries:
                raise ValueError(f"answers for unknown queries: {unknown_queries}")
            if world.required_action not in self.action_catalog:
                raise ValueError("required action is outside the catalog")
        if len(observation_groups) < 2:
            raise ValueError("a family must expose at least two public observations")
        actual_key = content_sha256(self.actual_world().public_observation)
        actual_group = observation_groups[actual_key]
        if len(actual_group) < 4:
            raise ValueError("at least four worlds must alias the actual observation")
        if len({world.required_action for world in actual_group}) < 2:
            raise ValueError("the actual observation must contain an action conflict")
        discriminates = any(
            len({world.query_answers.get(query) for world in actual_group}) > 1
            for query in self.query_catalog
        )
        if not discriminates:
            raise ValueError("no authorized query discriminates the actual alias class")


@dataclass(frozen=True)
class Decision:
    kind: DecisionKind
    selected_id: str
    catalog: tuple[str, ...]
    allowed_mask: tuple[bool, ...]
    logits_micros: tuple[int, ...]
    provenance: tuple[str, ...]

    def validate(self) -> None:
        size = len(self.catalog)
        if not (size == len(self.allowed_mask) == len(self.logits_micros)):
            raise ValueError("catalog, mask and logits must have identical sizes")
        if self.selected_id not in self.catalog:
            raise ValueError("selected decision is outside its catalog")
        index = self.catalog.index(self.selected_id)
        if not self.allowed_mask[index]:
            raise ValueError("selected decision is masked")
        if not any(self.allowed_mask):
            raise ValueError("at least one decision must be allowed")


@dataclass(frozen=True)
class RepairRecord:
    repair_id: str
    query_id: str
    response_id: str
    fiber_before: tuple[str, ...]
    fiber_after: tuple[str, ...]
    retained_closures: tuple[str, ...]
    provenance: tuple[str, ...]

    def validate(self) -> None:
        before = set(self.fiber_before)
        after = set(self.fiber_after)
        if not after:
            raise ValueError("repair may not eliminate the real world")
        if not after <= before:
            raise ValueError("repair must monotonically refine the fiber")
        if not {self.query_id, self.response_id} <= set(self.provenance):
            raise ValueError("repair provenance is incomplete")


@dataclass(frozen=True)
class CertifiedRepairStep:
    step_index: int
    fiber_before: tuple[str, ...]
    decisions: tuple[Decision, ...]
    query_id: str
    response_id: str
    repair: RepairRecord
    fiber_after: tuple[str, ...]
    memory_before: tuple[str, ...]
    memory_after: tuple[str, ...]
    predicted_action_after: str | None
    action_sufficient_after: bool
    transition_derived_from_repair: bool

    def validate(self) -> None:
        if self.step_index < 0:
            raise ValueError("step index must be non-negative")
        if not self.decisions:
            raise ValueError("repair step has no decisions")
        for decision in self.decisions:
            decision.validate()
        self.repair.validate()
        if self.query_id != self.repair.query_id:
            raise ValueError("query and repair disagree")
        if self.response_id != self.repair.response_id:
            raise ValueError("response and repair disagree")
        if tuple(self.fiber_before) != tuple(self.repair.fiber_before):
            raise ValueError("step input is not repair input")
        if tuple(self.fiber_after) != tuple(self.repair.fiber_after):
            raise ValueError("step output is not repair output")
        if not self.transition_derived_from_repair:
            raise ValueError("next transition must be derived from repair")
        if not set(self.memory_before) <= set(self.memory_after):
            raise ValueError("memory is not cumulative")


@dataclass(frozen=True)
class EpisodeTrace:
    schema_version: str
    episode_id: str
    system_id: str
    seed: int
    observation_hash: str
    actual_world_id: str
    initial_fiber: tuple[str, ...]
    steps: tuple[CertifiedRepairStep, ...]
    final_fiber: tuple[str, ...]
    required_action: str
    predicted_action: str
    intervention_id: str | None
    closed: bool

    def validate(self) -> None:
        if self.schema_version != "v23.1":
            raise ValueError("unsupported trace schema")
        if not self.actual_world_id:
            raise ValueError("trace must name its actual world")
        current = self.initial_fiber
        expected_index = 0
        for step in self.steps:
            step.validate()
            if step.step_index != expected_index:
                raise ValueError("step indices must be contiguous")
            if tuple(step.fiber_before) != tuple(current):
                raise ValueError("repair steps do not form a chain")
            current = step.fiber_after
            expected_index += 1
        if tuple(current) != tuple(self.final_fiber):
            raise ValueError("final fiber does not match the episode chain")
        if self.closed != (self.required_action == self.predicted_action):
            raise ValueError("closure verdict is inconsistent")


@dataclass(frozen=True)
class GateResult:
    gate_id: str
    status: GateStatus
    checks: tuple[str, ...]
    evidence: tuple[str, ...]
    blockers: tuple[str, ...] = ()


class ActiveDomain(Protocol):
    kind: DomainKind

    def generate_episode(self, seed: int, actual_index: int = 0) -> Episode: ...

    def initial_fiber(self, episode: Episode) -> tuple[str, ...]: ...

    def answer(self, episode: Episode, world_id: str, query_id: str) -> str: ...

    def posterior(
        self,
        episode: Episode,
        fiber: Sequence[str],
        query_id: str,
        response_id: str,
    ) -> tuple[str, ...]: ...

    def action_sufficient(self, episode: Episode, fiber: Sequence[str]) -> bool: ...
