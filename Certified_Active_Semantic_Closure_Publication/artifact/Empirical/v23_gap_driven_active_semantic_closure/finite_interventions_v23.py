#!/usr/bin/env python3
"""Exact Level-A realization of every intervention declared by v23."""

from __future__ import annotations

from typing import Any

from environment_v23 import TraceProvenance, typed
from finite_reference_domain_v23 import (
    CANONICAL_WORLD,
    AgentState,
    AuthorizedUse,
    ClosedState,
    Index,
    Knowledge,
    KnowledgeKind,
    Observation,
    OpenTransition,
    PrivateFiniteManifest,
    Query,
    QueryKind,
    ReadingFocus,
    Response,
    ResponseKind,
    UseDirection,
    Value,
    agent_manifest,
    authorize,
    build_repair,
    compatible_with_view_history,
    execute_repair,
    execute_transport,
    fiber_commitments,
    gap_at,
    gap_closed_by,
    history_retained,
    index_typed,
    initial_state,
    known_closed_prefix,
    natural_trace_record,
    next_state,
    open_transition,
    persistence_obligations,
    query_admissible,
    repair_derived_from,
    repairs_retained,
    response_bits,
    response_max_bits,
    response_well_typed,
    serialize_agent_state,
    serialize_gap,
    serialize_gap_evidence,
    serialize_query,
    serialize_repair,
    serialize_response,
    serialize_transport,
    serialize_use,
    transport_with_focus,
    validate_semantic_gap,
    validate_transport,
    validate_use,
)
from trace_schema_v23 import (
    CAUSAL_VARIABLES,
    INTERVENTION_KINDS,
    INTERVENTION_TARGETS,
    OPEN_CAUSAL_FIELDS,
    canonical_sha256,
    validate_trace_record,
)


REFUSAL_STAGE = {
    "I_gap_suppress": "gap",
    "I_use_suppress": "use",
    "I_transport_suppress": "transport",
    "I_query_neutral": "query",
    "I_response_neutral": "response",
    "I_repair_neutral": "repair",
    "I_repair_permute": "repair",
    "I_next_bypass": "next",
    "I_order_swap": "transport",
    "I_unused_gap": "use",
}


def _attempt_payload(kind: str) -> dict[str, Any]:
    details: dict[str, Any] = {
        "I_gap_suppress": {"operation": "suppressOpenGap"},
        "I_use_suppress": {"operation": "suppressAuthorizedUse"},
        "I_transport_suppress": {"operation": "suppressAuthorizedTransport"},
        "I_query_neutral": {
            "proposedQuery": {"constructor": "noInformation", "index": "first"}
        },
        "I_response_neutral": {
            "proposedResponse": {"constructor": "noInformation", "index": "first"}
        },
        "I_repair_neutral": {
            "proposedPatch": {"constructor": "keep", "index": None, "value": None}
        },
        "I_repair_permute": {
            "proposedPatch": {"constructor": "set", "index": "first", "value": "blue"}
        },
        "I_next_bypass": {"operation": "reuseStateBeforeWithoutRepair"},
        "I_order_swap": {"proposedOrder": ["second", "first"]},
        "I_unused_gap": {"operation": "hideComputedGapFromDownstream"},
    }[kind]
    return typed("finite.InterventionAttempt", constructor=kind, **details)

STAGE_PREFIX = {
    "projection": 0,
    "gap": 0,
    "use": 2,
    "transport": 3,
    "query": 4,
    "response": 6,
    "repair": 8,
    "next": len(OPEN_CAUSAL_FIELDS),
    "history": len(OPEN_CAUSAL_FIELDS),
}


def _partition(kind: str) -> tuple[list[str], list[str]]:
    target = INTERVENTION_TARGETS[kind]
    position = CAUSAL_VARIABLES.index(target)
    return sorted(CAUSAL_VARIABLES[:position]), sorted(CAUSAL_VARIABLES[position:])


def _mark_intervention(
    record: dict[str, Any], kind: str, natural_hash: str, payload: dict[str, Any]
) -> None:
    fixed, recomputed = _partition(kind)
    record.update(
        {
            "split": "intervention",
            "intervention_kind": kind,
            "intervention_payload": payload,
            "fixed_variables": fixed,
            "recomputed_variables": recomputed,
            "natural_trace_hash": natural_hash,
        }
    )


def _run(
    state: ClosedState,
    gap: Any,
    use: AuthorizedUse,
    transport: Any,
    query: Query,
    response: Response,
) -> OpenTransition:
    repair = build_repair(state.agent, gap, use, transport, query, response)
    after = execute_repair(state, repair)
    return OpenTransition(state, gap, use, transport, query, response, repair, after)


def _advanced_record(
    transition: OpenTransition,
    *,
    paired_natural: dict[str, Any],
    kind: str,
    payload: dict[str, Any],
    provenance: TraceProvenance,
    manifest: PrivateFiniteManifest,
    episode_id: str,
    step: int,
    after_override: ClosedState | None = None,
) -> dict[str, Any]:
    before = transition.before
    after = transition.after if after_override is None else after_override
    record = natural_trace_record(
        before,
        step=step,
        episode_id=episode_id,
        provenance=provenance,
        manifest=manifest,
    )
    closure = gap_closed_by(before, transition.gap, after)
    record.update(
        {
            "agent_input_manifest": agent_manifest(before.agent),
            "state_before": typed("finite.AgentState", **serialize_agent_state(before.agent)),
            "compatible_fiber_before": fiber_commitments(before.agent, manifest),
            "gap_status": "open",
            "execution_status": "advanced",
            "refusal_stage": None,
            "refusal_reason": None,
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
            "response": typed(
                "finite.Response", **serialize_response(transition.response)
            ),
            "response_footprint": {
                "requested_index": index_typed(transition.query.index),
                "actual_bits": response_bits(transition.response),
                "max_bits": response_max_bits(transition.query),
            },
            "intrinsic_repair": typed(
                "finite.IntrinsicRepair", **serialize_repair(transition.repair)
            ),
            "state_after": typed("finite.AgentState", **serialize_agent_state(after.agent)),
            "compatible_fiber_after": fiber_commitments(after.agent, manifest),
            "gap_closed_by": (
                typed(
                    "finite.GapClosedBy",
                    index=transition.gap.index.value,
                    beforeFiberSize=len(fiber_commitments(before.agent, manifest)),
                    afterFiberSize=len(fiber_commitments(after.agent, manifest)),
                )
                if closure
                else None
            ),
            "known_closed_prefix": [
                index_typed(index) for index in known_closed_prefix(after.agent)
            ],
            "persistence_obligations": persistence_obligations(
                before.agent, after.agent
            ),
            "state_after_hash": canonical_sha256(
                typed("finite.AgentState", **serialize_agent_state(after.agent))
            ),
            "validity_flags": {
                "actual_world_compatible": compatible_with_view_history(
                    after.agent, after.world
                ),
                "causal_chain_valid": True,
                "gap_closed": closure,
                "gap_sound": validate_semantic_gap(before, transition.gap),
                "next_from_repair": execute_repair(before, transition.repair) == after,
                "persistence_valid": repairs_retained(after.agent)
                and history_retained(before.agent, after.agent),
                "query_admissible": query_admissible(
                    transition.gap,
                    transition.use,
                    transition.transport,
                    transition.query,
                ),
                "repair_derived": repair_derived_from(
                    before.agent,
                    transition.gap,
                    transition.use,
                    transition.transport,
                    transition.query,
                    transition.response,
                    transition.repair,
                ),
                "response_well_typed": response_well_typed(
                    transition.query, transition.response
                ),
                "schema_valid": True,
                "transport_authorized": validate_transport(
                    transition.gap, transition.use, transition.transport
                ),
                "use_authorized": validate_use(transition.gap, transition.use),
                "world_preserved": after.world == before.world,
            },
        }
    )
    _mark_intervention(record, kind, canonical_sha256(paired_natural), payload)
    validate_trace_record(record)
    return record


def _refusal_record(
    base: dict[str, Any], kind: str, stage: str, payload: dict[str, Any]
) -> dict[str, Any]:
    record = {key: value for key, value in base.items()}
    # Nested values retained before the refusal are immutable for this builder;
    # every changed container below is replaced rather than mutated.
    prefix_length = STAGE_PREFIX[stage]
    for field in OPEN_CAUSAL_FIELDS[prefix_length:]:
        record[field] = None
    record.update(
        {
            "split": "intervention",
            "execution_status": "typed_refusal",
            "refusal_stage": stage,
            "refusal_reason": f"{kind} violates the dependent causal contract at {stage}",
            "state_after": base["state_before"],
            "compatible_fiber_after": list(base["compatible_fiber_before"]),
            "gap_closed_by": None,
            "known_closed_prefix": [],
            "persistence_obligations": [],
            "state_after_hash": canonical_sha256(base["state_before"]),
            "validity_flags": {
                "actual_world_compatible": True,
                "causal_chain_valid": False,
                "gap_closed": False,
                "gap_sound": stage not in {"projection", "gap"},
                "next_from_repair": stage not in {"next", "history"},
                "persistence_valid": True,
                "query_admissible": stage not in {"query"},
                "repair_derived": stage not in {"repair"},
                "response_well_typed": stage not in {"response"},
                "schema_valid": True,
                "transport_authorized": stage not in {"transport"},
                "use_authorized": stage not in {"use"},
                "world_preserved": True,
            },
        }
    )
    _mark_intervention(record, kind, canonical_sha256(base), payload)
    validate_trace_record(record)
    return record


def intervention_records(
    *, provenance: TraceProvenance, manifest: PrivateFiniteManifest
) -> list[dict[str, Any]]:
    state0 = initial_state(CANONICAL_WORLD)
    state1 = next_state(state0)
    natural0 = natural_trace_record(
        state0,
        step=0,
        episode_id="canonical-natural-0",
        provenance=provenance,
        manifest=manifest,
    )
    natural1 = natural_trace_record(
        state1,
        step=1,
        episode_id="canonical-natural-1",
        provenance=provenance,
        manifest=manifest,
    )
    natural_transition0 = open_transition(state0)
    natural_transition1 = open_transition(state1)
    assert natural_transition0 is not None and natural_transition1 is not None

    records: dict[str, dict[str, Any]] = {}
    for kind, stage in REFUSAL_STAGE.items():
        records[kind] = _refusal_record(
            natural0,
            kind,
            stage,
            _attempt_payload(kind),
        )

    projected_observation = Observation(
        Knowledge(KnowledgeKind.EXCLUDES, Value.RED),
        Knowledge(KnowledgeKind.EXACT, Value.GREEN),
        Knowledge(KnowledgeKind.UNKNOWN),
    )
    projected_state = ClosedState(
        state0.world,
        AgentState(state0.agent.candidate, projected_observation, state0.agent.history),
    )
    projected_transition = open_transition(projected_state)
    assert projected_transition is not None
    records["I_projection"] = _advanced_record(
        projected_transition,
        paired_natural=natural0,
        kind="I_projection",
        payload=typed(
            "finite.ProjectionReplacement",
            observation={
                "first": {"kind": "excludes", "value": "red"},
                "second": {"kind": "exact", "value": "green"},
                "third": {"kind": "unknown", "value": None},
            },
            actualWorldCompatible=True,
        ),
        provenance=provenance,
        manifest=manifest,
        episode_id="canonical-I_projection",
        step=0,
    )

    for kind, index in (("I_gap_permute", Index.SECOND), ("I_random_gap", Index.THIRD)):
        alternative_gap = gap_at(state0.agent, index)
        assert alternative_gap is not None
        use = authorize(state0.agent, alternative_gap)
        transport = execute_transport(state0.agent, alternative_gap, use)
        query = Query(QueryKind.REVEAL, index)
        response = Response(ResponseKind.REVEALED, index, state0.world.at(index))
        transition = _run(state0, alternative_gap, use, transport, query, response)
        records[kind] = _advanced_record(
            transition,
            paired_natural=natural0,
            kind=kind,
            payload=typed("finite.GapReplacement", index=index.value),
            provenance=provenance,
            manifest=manifest,
            episode_id=f"canonical-{kind}",
            step=0,
        )

    inspect_use = AuthorizedUse(
        UseDirection.INSPECT_WITNESSED_MISMATCH,
        natural_transition0.gap.kind,
        natural_transition0.gap.index,
    )
    inspect_transport = execute_transport(state0.agent, natural_transition0.gap, inspect_use)
    inspect_query = Query(QueryKind.REVEAL, natural_transition0.gap.index)
    inspect_response = Response(
        ResponseKind.REVEALED,
        natural_transition0.gap.index,
        state0.world.at(natural_transition0.gap.index),
    )
    inspect_transition = _run(
        state0,
        natural_transition0.gap,
        inspect_use,
        inspect_transport,
        inspect_query,
        inspect_response,
    )
    records["I_use_permute"] = _advanced_record(
        inspect_transition,
        paired_natural=natural0,
        kind="I_use_permute",
        payload=typed("finite.UseReplacement", direction=inspect_use.direction.value),
        provenance=provenance,
        manifest=manifest,
        episode_id="canonical-I_use_permute",
        step=0,
    )

    evidence_transport = transport_with_focus(
        natural_transition0.gap, natural_transition0.use, ReadingFocus.EVIDENCE
    )
    confirm_query = Query(QueryKind.CONFIRM, natural_transition0.gap.index)
    confirm_response = Response(
        ResponseKind.CONFIRMED,
        natural_transition0.gap.index,
        state0.world.at(natural_transition0.gap.index),
    )
    evidence_transition = _run(
        state0,
        natural_transition0.gap,
        natural_transition0.use,
        evidence_transport,
        confirm_query,
        confirm_response,
    )
    records["I_transport_permute"] = _advanced_record(
        evidence_transition,
        paired_natural=natural0,
        kind="I_transport_permute",
        payload=typed("finite.TransportReplacement", focus="evidence"),
        provenance=provenance,
        manifest=manifest,
        episode_id="canonical-I_transport_permute",
        step=0,
    )

    alternate_query = Query(QueryKind.CONFIRM, natural_transition0.gap.index)
    alternate_response = Response(
        ResponseKind.CONFIRMED,
        natural_transition0.gap.index,
        state0.world.at(natural_transition0.gap.index),
    )
    alternate_query_transition = _run(
        state0,
        natural_transition0.gap,
        natural_transition0.use,
        natural_transition0.transport,
        alternate_query,
        alternate_response,
    )
    records["I_query_alternate"] = _advanced_record(
        alternate_query_transition,
        paired_natural=natural0,
        kind="I_query_alternate",
        payload=typed(
            "finite.QueryReplacement",
            constructor="confirm",
            index=natural_transition0.gap.index.value,
        ),
        provenance=provenance,
        manifest=manifest,
        episode_id="canonical-I_query_alternate",
        step=0,
    )

    crossed_response = Response(ResponseKind.REVEALED, Index.FIRST, Value.BLUE)
    crossed_transition = _run(
        state0,
        natural_transition0.gap,
        natural_transition0.use,
        natural_transition0.transport,
        natural_transition0.query,
        crossed_response,
    )
    records["I_response_cross"] = _advanced_record(
        crossed_transition,
        paired_natural=natural0,
        kind="I_response_cross",
        payload=typed("finite.CrossedResponse", sourceWorldFirst="blue"),
        provenance=provenance,
        manifest=manifest,
        episode_id="canonical-I_response_cross",
        step=0,
    )

    natural_after1 = natural_transition1.after
    dropped_after = ClosedState(
        natural_after1.world,
        AgentState(
            natural_after1.agent.candidate,
            natural_after1.agent.observation,
            (natural_transition1.repair.history_record,),
        ),
    )
    records["I_history_drop"] = _advanced_record(
        natural_transition1,
        paired_natural=natural1,
        kind="I_history_drop",
        payload=typed("finite.HistoryDrop", droppedPrefixRecords=1),
        provenance=provenance,
        manifest=manifest,
        episode_id="canonical-I_history_drop",
        step=1,
        after_override=dropped_after,
    )

    expected = set(INTERVENTION_KINDS) - {"natural"}
    if set(records) != expected:
        raise AssertionError(
            f"intervention matrix incomplete: missing={sorted(expected - set(records))}"
        )
    return [records[kind] for kind in sorted(records)]
