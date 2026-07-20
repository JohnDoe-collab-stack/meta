#!/usr/bin/env python3
"""Exact executable counterpart of ``FiniteActiveSemanticClosure.lean``.

The detector, use, transport, query, response, intrinsic repair, and successor
are separate total functions.  Only ``respond`` reads ``World``.  Compatible
fibers and closure judgments are exact enumerations of the 27-world universe.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from itertools import product
from typing import Any, Iterable

from environment_v23 import TraceProvenance, salted_commitment, sha256_bytes, typed
from trace_schema_v23 import (
    FORBIDDEN_AGENT_FIELDS,
    PROTOCOL_VERSION,
    SCHEMA_VERSION,
    canonical_json_bytes,
    canonical_sha256,
)


class Value(str, Enum):
    RED = "red"
    GREEN = "green"
    BLUE = "blue"


class Index(str, Enum):
    FIRST = "first"
    SECOND = "second"
    THIRD = "third"


VALUES = tuple(Value)
INDICES = tuple(Index)


@dataclass(frozen=True)
class World:
    first: Value
    second: Value
    third: Value

    def at(self, index: Index) -> Value:
        return getattr(self, index.value)


@dataclass(frozen=True)
class Candidate:
    first: Value | None
    second: Value | None
    third: Value | None

    def at(self, index: Index) -> Value | None:
        return getattr(self, index.value)

    def set(self, index: Index, value: Value) -> "Candidate":
        values = {item.value: self.at(item) for item in INDICES}
        values[index.value] = value
        return Candidate(**values)


class KnowledgeKind(str, Enum):
    UNKNOWN = "unknown"
    EXCLUDES = "excludes"
    EXACT = "exact"


@dataclass(frozen=True)
class Knowledge:
    kind: KnowledgeKind
    value: Value | None = None

    def __post_init__(self) -> None:
        if (self.kind is KnowledgeKind.UNKNOWN) != (self.value is None):
            raise ValueError("unknown has no value; excludes/exact require one")

    def allows(self, value: Value) -> bool:
        if self.kind is KnowledgeKind.UNKNOWN:
            return True
        if self.kind is KnowledgeKind.EXCLUDES:
            return value is not self.value
        return value is self.value


UNKNOWN = Knowledge(KnowledgeKind.UNKNOWN)


@dataclass(frozen=True)
class Observation:
    first: Knowledge
    second: Knowledge
    third: Knowledge

    def at(self, index: Index) -> Knowledge:
        return getattr(self, index.value)

    def set_exact(self, index: Index, value: Value) -> "Observation":
        values = {item.value: self.at(item) for item in INDICES}
        values[index.value] = Knowledge(KnowledgeKind.EXACT, value)
        return Observation(**values)


class PatchKind(str, Enum):
    SET = "set"
    KEEP = "keep"


@dataclass(frozen=True)
class CandidatePatch:
    kind: PatchKind
    index: Index | None = None
    value: Value | None = None

    def __post_init__(self) -> None:
        complete = self.index is not None and self.value is not None
        if (self.kind is PatchKind.SET) != complete:
            raise ValueError("set requires index/value; keep forbids them")


KEEP_PATCH = CandidatePatch(PatchKind.KEEP)


@dataclass(frozen=True)
class RepairRecord:
    index: Index
    answer: Value | None
    changed_candidate: bool


@dataclass(frozen=True)
class AgentState:
    candidate: Candidate
    observation: Observation
    history: tuple[RepairRecord, ...]


@dataclass(frozen=True)
class ClosedState:
    world: World
    agent: AgentState


class GapKind(str, Enum):
    WITNESSED_MISMATCH = "witnessedMismatch"
    UNRESOLVED_FIBER = "unresolvedFiber"


class GapEvidenceKind(str, Enum):
    EXACT_WRONG = "exactWrong"
    EXACT_MISSING = "exactMissing"
    EXCLUDED_PREDICTION = "excludedPrediction"
    UNKNOWN = "unknown"
    EXCLUDED_FIBER = "excludedFiber"


@dataclass(frozen=True)
class GapEvidence:
    kind: GapEvidenceKind
    index: Index
    observed: Value | None = None
    predicted: Value | None = None


@dataclass(frozen=True)
class OperationalGap:
    index: Index
    kind: GapKind
    evidence: GapEvidence


class UseDirection(str, Enum):
    CORRECT_WITNESSED_MISMATCH = "correctWitnessedMismatch"
    INSPECT_WITNESSED_MISMATCH = "inspectWitnessedMismatch"
    RESOLVE_FIBER = "resolveFiber"
    INSPECT_FIBER = "inspectFiber"


@dataclass(frozen=True)
class AuthorizedUse:
    direction: UseDirection
    gap_kind: GapKind
    gap_index: Index


class ReadingFocus(str, Enum):
    CANDIDATE = "candidate"
    EVIDENCE = "evidence"


@dataclass(frozen=True)
class AuthorizedReading:
    index: Index
    direction: UseDirection
    focus: ReadingFocus


@dataclass(frozen=True)
class TransportOutput:
    requested_index: Index
    informative: bool


@dataclass(frozen=True)
class AuthorizedTransport:
    reading: AuthorizedReading
    output: TransportOutput
    evidence_direction: UseDirection
    reaches_gap: bool


class QueryKind(str, Enum):
    REVEAL = "reveal"
    CONFIRM = "confirm"
    NO_INFORMATION = "noInformation"


@dataclass(frozen=True)
class Query:
    kind: QueryKind
    index: Index


class ResponseKind(str, Enum):
    REVEALED = "revealed"
    CONFIRMED = "confirmed"
    NO_INFORMATION = "noInformation"


@dataclass(frozen=True)
class Response:
    kind: ResponseKind
    index: Index
    value: Value | None = None

    def __post_init__(self) -> None:
        if (self.kind is ResponseKind.NO_INFORMATION) != (self.value is None):
            raise ValueError("informative responses require a value")


@dataclass(frozen=True)
class ObservationUpdate:
    kind: ResponseKind
    index: Index
    value: Value | None


@dataclass(frozen=True)
class IntrinsicRepair:
    causal_index: Index
    candidate_patch: CandidatePatch
    observation_update: ObservationUpdate
    history_record: RepairRecord
    recorded_direction: UseDirection
    transport_index: Index


@dataclass(frozen=True)
class OpenTransition:
    before: ClosedState
    gap: OperationalGap
    use: AuthorizedUse
    transport: AuthorizedTransport
    query: Query
    response: Response
    repair: IntrinsicRepair
    after: ClosedState


def all_worlds() -> tuple[World, ...]:
    return tuple(World(*coordinates) for coordinates in product(VALUES, repeat=3))


ALL_WORLDS = all_worlds()
INITIAL_CANDIDATE = Candidate(Value.RED, None, None)
CANONICAL_WORLD = World(Value.GREEN, Value.GREEN, Value.GREEN)


def observe(world: World) -> Observation:
    first = (
        Knowledge(KnowledgeKind.EXACT, Value.RED)
        if world.first is Value.RED
        else Knowledge(KnowledgeKind.EXCLUDES, Value.RED)
    )
    return Observation(first, UNKNOWN, UNKNOWN)


def initial_state(world: World) -> ClosedState:
    return ClosedState(world, AgentState(INITIAL_CANDIDATE, observe(world), ()))


def interpret(candidate: Candidate, index: Index) -> Value | None:
    return candidate.at(index)


def evaluate(world: World, index: Index) -> Value:
    return world.at(index)


def agrees(prediction: Value | None, target: Value) -> bool:
    return prediction is target


def apply_candidate_patch(candidate: Candidate, patch: CandidatePatch) -> Candidate:
    if patch.kind is PatchKind.KEEP:
        return candidate
    assert patch.index is not None and patch.value is not None
    return candidate.set(patch.index, patch.value)


def gap_at(view: AgentState, index: Index) -> OperationalGap | None:
    knowledge = view.observation.at(index)
    predicted = view.candidate.at(index)
    if knowledge.kind is KnowledgeKind.UNKNOWN:
        evidence = GapEvidence(GapEvidenceKind.UNKNOWN, index)
        return OperationalGap(index, GapKind.UNRESOLVED_FIBER, evidence)
    assert knowledge.value is not None
    if knowledge.kind is KnowledgeKind.EXCLUDES:
        if predicted is knowledge.value:
            evidence = GapEvidence(
                GapEvidenceKind.EXCLUDED_PREDICTION,
                index,
                observed=knowledge.value,
                predicted=predicted,
            )
            return OperationalGap(index, GapKind.WITNESSED_MISMATCH, evidence)
        evidence = GapEvidence(
            GapEvidenceKind.EXCLUDED_FIBER,
            index,
            observed=knowledge.value,
            predicted=predicted,
        )
        return OperationalGap(index, GapKind.UNRESOLVED_FIBER, evidence)
    if predicted is None:
        evidence = GapEvidence(
            GapEvidenceKind.EXACT_MISSING, index, observed=knowledge.value
        )
        return OperationalGap(index, GapKind.WITNESSED_MISMATCH, evidence)
    if predicted is knowledge.value:
        return None
    evidence = GapEvidence(
        GapEvidenceKind.EXACT_WRONG,
        index,
        observed=knowledge.value,
        predicted=predicted,
    )
    return OperationalGap(index, GapKind.WITNESSED_MISMATCH, evidence)


def detect_gap(view: AgentState) -> OperationalGap | None:
    for index in INDICES:
        gap = gap_at(view, index)
        if gap is not None:
            return gap
    return None


def enumerate_gaps(view: AgentState) -> tuple[OperationalGap, ...]:
    return tuple(gap for index in INDICES if (gap := gap_at(view, index)) is not None)


def enumerate_uses(gap: OperationalGap) -> tuple[AuthorizedUse, ...]:
    directions = (
        (
            UseDirection.CORRECT_WITNESSED_MISMATCH,
            UseDirection.INSPECT_WITNESSED_MISMATCH,
        )
        if gap.kind is GapKind.WITNESSED_MISMATCH
        else (UseDirection.RESOLVE_FIBER, UseDirection.INSPECT_FIBER)
    )
    return tuple(AuthorizedUse(direction, gap.kind, gap.index) for direction in directions)


def authorize(view: AgentState, gap: OperationalGap) -> AuthorizedUse:
    del view
    return enumerate_uses(gap)[0]


def validate_use(gap: OperationalGap, use: AuthorizedUse) -> bool:
    return use in enumerate_uses(gap)


def transport_with_focus(
    gap: OperationalGap, use: AuthorizedUse, focus: ReadingFocus
) -> AuthorizedTransport:
    if not validate_use(gap, use):
        raise ValueError("use is not indexed by the supplied gap")
    reading = AuthorizedReading(gap.index, use.direction, focus)
    output = TransportOutput(gap.index, True)
    return AuthorizedTransport(reading, output, use.direction, True)


def execute_transport(
    view: AgentState, gap: OperationalGap, use: AuthorizedUse
) -> AuthorizedTransport:
    del view
    return transport_with_focus(gap, use, ReadingFocus.CANDIDATE)


def enumerate_transports(
    gap: OperationalGap, use: AuthorizedUse
) -> tuple[AuthorizedTransport, ...]:
    return tuple(transport_with_focus(gap, use, focus) for focus in ReadingFocus)


def validate_transport(
    gap: OperationalGap, use: AuthorizedUse, transport: AuthorizedTransport
) -> bool:
    return (
        validate_use(gap, use)
        and transport.reading.index is gap.index
        and transport.reading.direction is use.direction
        and transport.output.requested_index is gap.index
        and transport.output.informative
        and transport.evidence_direction is use.direction
        and transport.reaches_gap
    )


def select_query(transport: AuthorizedTransport) -> Query:
    kind = (
        QueryKind.REVEAL
        if transport.reading.focus is ReadingFocus.CANDIDATE
        else QueryKind.CONFIRM
    )
    return Query(kind, transport.output.requested_index)


def enumerate_queries(index: Index) -> tuple[Query, ...]:
    return tuple(Query(kind, index) for kind in QueryKind)


def query_admissible(
    gap: OperationalGap,
    use: AuthorizedUse,
    transport: AuthorizedTransport,
    query: Query,
) -> bool:
    return (
        validate_transport(gap, use, transport)
        and query.index is gap.index
        and query.kind in {QueryKind.REVEAL, QueryKind.CONFIRM}
    )


def respond(world: World, query: Query) -> Response:
    if query.kind is QueryKind.REVEAL:
        return Response(ResponseKind.REVEALED, query.index, world.at(query.index))
    if query.kind is QueryKind.CONFIRM:
        return Response(ResponseKind.CONFIRMED, query.index, world.at(query.index))
    return Response(ResponseKind.NO_INFORMATION, query.index)


def enumerate_responses(query: Query) -> tuple[Response, ...]:
    if query.kind is QueryKind.NO_INFORMATION:
        return (Response(ResponseKind.NO_INFORMATION, query.index),)
    kind = (
        ResponseKind.REVEALED
        if query.kind is QueryKind.REVEAL
        else ResponseKind.CONFIRMED
    )
    return tuple(Response(kind, query.index, value) for value in VALUES)


def response_well_typed(query: Query, response: Response) -> bool:
    if response.index is not query.index:
        return False
    expected = {
        QueryKind.REVEAL: ResponseKind.REVEALED,
        QueryKind.CONFIRM: ResponseKind.CONFIRMED,
        QueryKind.NO_INFORMATION: ResponseKind.NO_INFORMATION,
    }[query.kind]
    return response.kind is expected


def response_bits(response: Response) -> int:
    return 0 if response.kind is ResponseKind.NO_INFORMATION else 2


def response_max_bits(query: Query) -> int:
    return 0 if query.kind is QueryKind.NO_INFORMATION else 2


def patch_of_response(index: Index, response: Response) -> CandidatePatch:
    if response.value is None:
        return KEEP_PATCH
    return CandidatePatch(PatchKind.SET, index, response.value)


def observation_update_of_response(index: Index, response: Response) -> ObservationUpdate:
    return ObservationUpdate(response.kind, index, response.value)


def record_of_response(index: Index, response: Response) -> RepairRecord:
    return RepairRecord(index, response.value, response.value is not None)


def build_repair(
    view: AgentState,
    gap: OperationalGap,
    use: AuthorizedUse,
    transport: AuthorizedTransport,
    query: Query,
    response: Response,
) -> IntrinsicRepair:
    del view
    if not query_admissible(gap, use, transport, query):
        raise ValueError("query is not admissible for this causal prefix")
    if not response_well_typed(query, response):
        raise ValueError("response is not indexed by the query")
    return IntrinsicRepair(
        causal_index=gap.index,
        candidate_patch=patch_of_response(gap.index, response),
        observation_update=observation_update_of_response(gap.index, response),
        history_record=record_of_response(gap.index, response),
        recorded_direction=use.direction,
        transport_index=transport.output.requested_index,
    )


def repair_derived_from(
    view: AgentState,
    gap: OperationalGap,
    use: AuthorizedUse,
    transport: AuthorizedTransport,
    query: Query,
    response: Response,
    repair: IntrinsicRepair,
) -> bool:
    try:
        expected = build_repair(
            view,
            gap,
            use,
            transport,
            query,
            response,
        )
    except ValueError:
        return False
    return repair == expected


def apply_observation_update(
    observation: Observation, update: ObservationUpdate
) -> Observation:
    if update.value is None:
        return observation
    return observation.set_exact(update.index, update.value)


def execute_repair(state: ClosedState, repair: IntrinsicRepair) -> ClosedState:
    agent = AgentState(
        candidate=apply_candidate_patch(state.agent.candidate, repair.candidate_patch),
        observation=apply_observation_update(
            state.agent.observation, repair.observation_update
        ),
        history=state.agent.history + (repair.history_record,),
    )
    return ClosedState(state.world, agent)


def open_transition(state: ClosedState) -> OpenTransition | None:
    gap = detect_gap(state.agent)
    if gap is None:
        return None
    use = authorize(state.agent, gap)
    transport = execute_transport(state.agent, gap, use)
    query = select_query(transport)
    response = respond(state.world, query)
    repair = build_repair(state.agent, gap, use, transport, query, response)
    after = execute_repair(state, repair)
    return OpenTransition(state, gap, use, transport, query, response, repair, after)


def next_state(state: ClosedState) -> ClosedState:
    transition = open_transition(state)
    return state if transition is None else transition.after


def knowledge_compatible(observation: Observation, world: World) -> bool:
    return all(observation.at(index).allows(world.at(index)) for index in INDICES)


def record_compatible(record: RepairRecord, world: World) -> bool:
    return record.answer is None or world.at(record.index) is record.answer


def compatible_with_view_history(view: AgentState, world: World) -> bool:
    return knowledge_compatible(view.observation, world) and all(
        record_compatible(record, world) for record in view.history
    )


def compatible_worlds(view: AgentState) -> tuple[World, ...]:
    return tuple(world for world in ALL_WORLDS if compatible_with_view_history(view, world))


def correct_at(world: World, candidate: Candidate, index: Index) -> bool:
    return agrees(interpret(candidate, index), evaluate(world, index))


def closed_on(world: World, candidate: Candidate, domain: Iterable[Index]) -> bool:
    return all(correct_at(world, candidate, index) for index in domain)


def known_correct_at(view: AgentState, index: Index) -> bool:
    return all(correct_at(world, view.candidate, index) for world in compatible_worlds(view))


def known_closed_on(view: AgentState, domain: Iterable[Index]) -> bool:
    return all(known_correct_at(view, index) for index in domain)


def known_closed_prefix(view: AgentState) -> tuple[Index, ...]:
    prefix: list[Index] = []
    for index in INDICES:
        if not known_correct_at(view, index):
            break
        prefix.append(index)
    return tuple(prefix)


def fiber_determinate_at(view: AgentState, index: Index) -> bool:
    targets = {world.at(index) for world in compatible_worlds(view)}
    return len(targets) <= 1


def validate_semantic_gap(state: ClosedState, gap: OperationalGap) -> bool:
    if gap not in enumerate_gaps(state.agent):
        return False
    if not compatible_with_view_history(state.agent, state.world):
        return False
    if gap.kind is GapKind.WITNESSED_MISMATCH:
        return not correct_at(state.world, state.agent.candidate, gap.index)
    fiber = compatible_worlds(state.agent)
    return any(
        left.at(gap.index) is not right.at(gap.index)
        for left in fiber
        for right in fiber
    )


def gap_closed_by(before: ClosedState, gap: OperationalGap, after: ClosedState) -> bool:
    return (
        after.world == before.world
        and compatible_with_view_history(after.agent, after.world)
        and known_correct_at(after.agent, gap.index)
    )


def repairs_retained(view: AgentState) -> bool:
    return all(
        record.answer is None or view.candidate.at(record.index) is record.answer
        for record in view.history
    )


def history_retained(before: AgentState, after: AgentState) -> bool:
    """Every prior causal record remains as the exact history prefix."""

    return after.history[: len(before.history)] == before.history


def orbit(world: World, *, include_terminal_stasis: bool = False) -> tuple[ClosedState, ...]:
    states = [initial_state(world)]
    while detect_gap(states[-1].agent) is not None:
        if len(states) > len(INDICES):
            raise RuntimeError("finite orbit exceeded the exact closure bound")
        states.append(next_state(states[-1]))
    if include_terminal_stasis:
        states.append(next_state(states[-1]))
    return tuple(states)


def all_reachable_states() -> tuple[ClosedState, ...]:
    unique: dict[ClosedState, None] = {}
    for world in ALL_WORLDS:
        for state in orbit(world):
            unique[state] = None
    return tuple(unique)


def serialize_world(world: World) -> dict[str, str]:
    return {index.value: world.at(index).value for index in INDICES}


def serialize_candidate(candidate: Candidate) -> dict[str, str | None]:
    return {
        index.value: None if candidate.at(index) is None else candidate.at(index).value
        for index in INDICES
    }


def serialize_knowledge(knowledge: Knowledge) -> dict[str, str | None]:
    return {
        "kind": knowledge.kind.value,
        "value": None if knowledge.value is None else knowledge.value.value,
    }


def serialize_observation(observation: Observation) -> dict[str, Any]:
    return {index.value: serialize_knowledge(observation.at(index)) for index in INDICES}


def serialize_record(record: RepairRecord) -> dict[str, Any]:
    return {
        "index": record.index.value,
        "answer": None if record.answer is None else record.answer.value,
        "changedCandidate": record.changed_candidate,
    }


def serialize_agent_state(view: AgentState) -> dict[str, Any]:
    return {
        "candidate": serialize_candidate(view.candidate),
        "observation": serialize_observation(view.observation),
        "history": [serialize_record(record) for record in view.history],
    }


def serialize_gap(gap: OperationalGap) -> dict[str, Any]:
    return {"index": gap.index.value, "kind": gap.kind.value}


def serialize_gap_evidence(evidence: GapEvidence) -> dict[str, Any]:
    return {
        "constructor": evidence.kind.value,
        "index": evidence.index.value,
        "observed": None if evidence.observed is None else evidence.observed.value,
        "predicted": None if evidence.predicted is None else evidence.predicted.value,
    }


def serialize_use(use: AuthorizedUse) -> dict[str, Any]:
    return {
        "direction": use.direction.value,
        "gapKind": use.gap_kind.value,
        "gapIndex": use.gap_index.value,
    }


def serialize_transport(transport: AuthorizedTransport) -> dict[str, Any]:
    return {
        "reading": {
            "index": transport.reading.index.value,
            "direction": transport.reading.direction.value,
            "focus": transport.reading.focus.value,
        },
        "output": {
            "requestedIndex": transport.output.requested_index.value,
            "informative": transport.output.informative,
        },
        "evidence": {
            "direction": transport.evidence_direction.value,
            "reachesGap": transport.reaches_gap,
        },
    }


def serialize_query(query: Query) -> dict[str, str]:
    return {"constructor": query.kind.value, "index": query.index.value}


def serialize_response(response: Response) -> dict[str, str | None]:
    return {
        "constructor": response.kind.value,
        "index": response.index.value,
        "value": None if response.value is None else response.value.value,
    }


def serialize_patch(patch: CandidatePatch) -> dict[str, str | None]:
    return {
        "constructor": patch.kind.value,
        "index": None if patch.index is None else patch.index.value,
        "value": None if patch.value is None else patch.value.value,
    }


def serialize_repair(repair: IntrinsicRepair) -> dict[str, Any]:
    return {
        "causalIndex": repair.causal_index.value,
        "candidatePatch": serialize_patch(repair.candidate_patch),
        "observationUpdate": {
            "constructor": repair.observation_update.kind.value,
            "index": repair.observation_update.index.value,
            "value": (
                None
                if repair.observation_update.value is None
                else repair.observation_update.value.value
            ),
        },
        "historyRecord": serialize_record(repair.history_record),
        "recordedDirection": repair.recorded_direction.value,
        "transportIndex": repair.transport_index.value,
    }


def index_typed(index: Index) -> dict[str, Any]:
    return typed("finite.Index", constructor=index.value)


@dataclass(frozen=True)
class PrivateFiniteManifest:
    salt: bytes
    worlds: tuple[World, ...] = ALL_WORLDS

    def commitment(self, world: World) -> str:
        return salted_commitment("finite.World", serialize_world(world), self.salt)

    def commitment_map(self) -> dict[str, World]:
        result = {self.commitment(world): world for world in self.worlds}
        if len(result) != len(self.worlds):
            raise ValueError("world commitments collide")
        return result


def fiber_commitments(view: AgentState, manifest: PrivateFiniteManifest) -> list[str]:
    return sorted(manifest.commitment(world) for world in compatible_worlds(view))


def agent_manifest(view: AgentState) -> dict[str, Any]:
    encoded = canonical_json_bytes(typed("finite.AgentState", **serialize_agent_state(view)))
    return {
        "encoding": "finite.agent-state.v1",
        "sha256": sha256_bytes(encoded),
        "byte_length": len(encoded),
        "fields": ["candidate", "history", "observation"],
        "forbidden_fields_absent": list(FORBIDDEN_AGENT_FIELDS),
    }


def persistence_obligations(before: AgentState, after: AgentState) -> list[dict[str, Any]]:
    obligations = []
    for index in known_closed_prefix(before):
        provenance = {
            "before": serialize_agent_state(before),
            "index": index.value,
        }
        obligations.append(
            {
                "index": index_typed(index),
                "preserved": known_correct_at(after, index),
                "provenance_sha256": canonical_sha256(provenance),
            }
        )
    return obligations


def natural_trace_record(
    state: ClosedState,
    *,
    step: int,
    episode_id: str,
    provenance: TraceProvenance,
    manifest: PrivateFiniteManifest,
) -> dict[str, Any]:
    transition = open_transition(state)
    after = state if transition is None else transition.after
    before_agent = typed("finite.AgentState", **serialize_agent_state(state.agent))
    after_agent = typed("finite.AgentState", **serialize_agent_state(after.agent))
    common: dict[str, Any] = {
        "schema_version": SCHEMA_VERSION,
        "protocol_version": PROTOCOL_VERSION,
        "run_id": provenance.run_id,
        "training_seed": None,
        "environment_seed": provenance.environment_seed,
        "domain": "finite_reference",
        "split": "finite_exhaustive",
        "episode_id": episode_id,
        "step": step,
        "checkpoint_sha256": None,
        "source_bundle_sha256": provenance.source_bundle_sha256,
        "executed_script_sha256": provenance.executed_script_sha256,
        "command_sha256": provenance.command_sha256,
        "producer_kind": "reference",
        "world_commitment": manifest.commitment(state.world),
        "agent_input_manifest": agent_manifest(state.agent),
        "state_before": before_agent,
        "compatible_fiber_before": fiber_commitments(state.agent, manifest),
        "gap_status": "closed" if transition is None else "open",
        "execution_status": "closed_stasis" if transition is None else "advanced",
        "refusal_stage": None,
        "refusal_reason": None,
        "state_after": after_agent,
        "compatible_fiber_after": fiber_commitments(after.agent, manifest),
        "known_closed_prefix": [index_typed(index) for index in known_closed_prefix(after.agent)],
        "persistence_obligations": persistence_obligations(state.agent, after.agent),
        "state_after_hash": canonical_sha256(after_agent),
        "intervention_kind": "natural",
        "intervention_payload": None,
        "fixed_variables": [],
        "recomputed_variables": [],
        "natural_trace_hash": None,
        "validity_flags": {
            "actual_world_compatible": compatible_with_view_history(after.agent, after.world),
            "causal_chain_valid": True,
            "gap_closed": transition is None or gap_closed_by(state, transition.gap, after),
            "gap_sound": transition is None or validate_semantic_gap(state, transition.gap),
            "next_from_repair": transition is None or execute_repair(state, transition.repair) == after,
            "persistence_valid": repairs_retained(after.agent)
            and history_retained(state.agent, after.agent),
            "query_admissible": transition is None or query_admissible(
                transition.gap, transition.use, transition.transport, transition.query
            ),
            "repair_derived": transition is None or repair_derived_from(
                state.agent,
                transition.gap,
                transition.use,
                transition.transport,
                transition.query,
                transition.response,
                transition.repair,
            ),
            "response_well_typed": transition is None or response_well_typed(
                transition.query, transition.response
            ),
            "schema_valid": True,
            "transport_authorized": transition is None or validate_transport(
                transition.gap, transition.use, transition.transport
            ),
            "use_authorized": transition is None or validate_use(
                transition.gap, transition.use
            ),
            "world_preserved": after.world == state.world,
        },
    }
    if transition is None:
        common.update(
            {
                "gap": None,
                "gap_evidence": None,
                "authorized_use": None,
                "authorized_transport": None,
                "query": None,
                "query_footprint": None,
                "response": None,
                "response_footprint": None,
                "intrinsic_repair": None,
                "gap_closed_by": None,
            }
        )
        return common
    common.update(
        {
            "gap": typed("finite.OperationalGap", **serialize_gap(transition.gap)),
            "gap_evidence": typed(
                "finite.GapEvidence", **serialize_gap_evidence(transition.gap.evidence)
            ),
            "authorized_use": typed(
                "finite.GapAuthorizedUse", **serialize_use(transition.use)
            ),
            "authorized_transport": typed(
                "finite.GapAuthorizedTransport", **serialize_transport(transition.transport)
            ),
            "query": typed("finite.Query", **serialize_query(transition.query)),
            "query_footprint": {
                "requested_index": index_typed(transition.query.index),
                "query_count": 1,
                "serialized_bits": 2,
            },
            "response": typed("finite.Response", **serialize_response(transition.response)),
            "response_footprint": {
                "requested_index": index_typed(transition.query.index),
                "actual_bits": response_bits(transition.response),
                "max_bits": response_max_bits(transition.query),
            },
            "intrinsic_repair": typed(
                "finite.IntrinsicRepair", **serialize_repair(transition.repair)
            ),
            "gap_closed_by": typed(
                "finite.GapClosedBy",
                index=transition.gap.index.value,
                beforeFiberSize=len(compatible_worlds(state.agent)),
                afterFiberSize=len(compatible_worlds(after.agent)),
            ),
        }
    )
    return common


def canonical_orbit() -> tuple[ClosedState, ...]:
    return orbit(CANONICAL_WORLD)
