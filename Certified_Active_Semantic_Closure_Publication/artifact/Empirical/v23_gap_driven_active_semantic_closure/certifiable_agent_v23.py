#!/usr/bin/env python3
"""Exact finite dataset and integer kernel for the v23 certifiable agent.

This module contains no training code.  It fixes the public agent encoding,
the dependent catalogues, the exhaustive local alternatives, and the exact
integer inference semantics shared by training, export, verification, and
Lean reification.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import chain
from typing import Iterable, Mapping, Sequence

from finite_reference_domain_v23 import (
    ALL_WORLDS,
    CANONICAL_WORLD,
    INDICES,
    VALUES,
    AgentState,
    AuthorizedTransport,
    AuthorizedUse,
    Candidate,
    CandidatePatch,
    ClosedState,
    GapEvidenceKind,
    GapKind,
    Index,
    Knowledge,
    KnowledgeKind,
    OperationalGap,
    Observation,
    PatchKind,
    Query,
    QueryKind,
    ReadingFocus,
    RepairRecord,
    Response,
    ResponseKind,
    UseDirection,
    Value,
    all_reachable_states,
    authorize,
    build_repair,
    detect_gap,
    enumerate_gaps,
    enumerate_queries,
    enumerate_responses,
    enumerate_transports,
    enumerate_uses,
    execute_transport,
    gap_at,
    initial_state,
    next_state,
    query_admissible,
    select_query,
)


INT8_MIN = -128
INT8_MAX = 127
INT32_MIN = -(2**31)
INT32_MAX = 2**31 - 1
STATE_DIM = 96
HIDDEN_DIM = 64

HEAD_ORDER = ("gap", "use", "transport", "query", "repair")
HEAD_INPUT_DIMS = {
    "gap": 96,
    "use": 160,
    "transport": 168,
    "query": 232,
    "repair": 257,
}
HEAD_OUTPUT_DIMS = {
    "gap": 64,
    "use": 8,
    "transport": 64,
    "query": 9,
    "repair": 10,
}

VALUE_CODE = {value: number for number, value in enumerate(VALUES)}
INDEX_CODE = {index: number for number, index in enumerate(INDICES)}
KNOWLEDGE_CODE = {
    Knowledge(KnowledgeKind.UNKNOWN): 0,
    **{
        Knowledge(KnowledgeKind.EXCLUDES, value): 1 + VALUE_CODE[value]
        for value in VALUES
    },
    **{
        Knowledge(KnowledgeKind.EXACT, value): 4 + VALUE_CODE[value]
        for value in VALUES
    },
}
CANDIDATE_CODE = {None: 0, **{value: 1 + VALUE_CODE[value] for value in VALUES}}
USE_DIRECTION_CODE = {
    UseDirection.CORRECT_WITNESSED_MISMATCH: 0,
    UseDirection.INSPECT_WITNESSED_MISMATCH: 1,
    UseDirection.RESOLVE_FIBER: 2,
    UseDirection.INSPECT_FIBER: 3,
}
FOCUS_CODE = {ReadingFocus.CANDIDATE: 0, ReadingFocus.EVIDENCE: 1}
QUERY_KIND_CODE = {
    QueryKind.REVEAL: 0,
    QueryKind.CONFIRM: 1,
    QueryKind.NO_INFORMATION: 2,
}


def one_hot(size: int, index: int) -> tuple[int, ...]:
    if not 0 <= index < size:
        raise ValueError(f"one-hot index {index} is outside 0..{size - 1}")
    return tuple(1 if position == index else 0 for position in range(size))


def _record_features(record: RepairRecord | None) -> tuple[int, ...]:
    if record is None:
        return (0,) * 7
    if record.answer is None:
        answer = (0, 0, 0)
    else:
        answer = one_hot(3, VALUE_CODE[record.answer])
    return (
        *one_hot(3, INDEX_CODE[record.index]),
        *answer,
        int(record.changed_candidate),
    )


def encode_agent_state(view: AgentState) -> tuple[int, ...]:
    """Encode only the agent-visible state into the normative 96 Int8 slots."""

    if len(view.history) > 3:
        raise ValueError("the finite certifiable domain admits at most three repairs")
    observation = tuple(
        chain.from_iterable(
            one_hot(7, KNOWLEDGE_CODE[view.observation.at(index)]) for index in INDICES
        )
    )
    candidate = tuple(
        chain.from_iterable(
            one_hot(4, CANDIDATE_CODE[view.candidate.at(index)]) for index in INDICES
        )
    )
    padded_history = tuple(view.history) + (None,) * (3 - len(view.history))
    history = tuple(chain.from_iterable(_record_features(item) for item in padded_history))
    length = one_hot(4, len(view.history))
    encoded = observation + candidate + history + length + (0,) * 38
    if len(encoded) != STATE_DIM:
        raise AssertionError(f"state encoder produced {len(encoded)} coordinates")
    if any(value not in (0, 1) for value in encoded):
        raise AssertionError("state encoder left the binary Int8 domain")
    if any(encoded[-38:]):
        raise AssertionError("reserved state padding is not zero")
    return encoded


def gap_class(gap: OperationalGap) -> int:
    """Encode evidence constructively; predicted values are recovered from state."""

    constructor = gap.evidence.kind
    index = INDEX_CODE[gap.index]
    observed = 0 if gap.evidence.observed is None else VALUE_CODE[gap.evidence.observed]
    if constructor is GapEvidenceKind.EXACT_WRONG:
        return index * 3 + observed
    if constructor is GapEvidenceKind.EXACT_MISSING:
        return 9 + index * 3 + observed
    if constructor is GapEvidenceKind.EXCLUDED_PREDICTION:
        return 18 + index * 3 + observed
    if constructor is GapEvidenceKind.UNKNOWN:
        return 27 + index
    if constructor is GapEvidenceKind.EXCLUDED_FIBER:
        return 30 + index * 3 + observed
    raise AssertionError(f"unhandled gap evidence {constructor}")


def decode_gap_class(view: AgentState, class_index: int) -> OperationalGap | None:
    for gap in enumerate_gaps(view):
        if gap_class(gap) == class_index:
            return gap
    return None


def use_class(use: AuthorizedUse) -> int:
    direction = USE_DIRECTION_CODE[use.direction]
    valid_kind = (
        direction < 2 and use.gap_kind is GapKind.WITNESSED_MISMATCH
    ) or (direction >= 2 and use.gap_kind is GapKind.UNRESOLVED_FIBER)
    if not valid_kind:
        raise ValueError("use direction is not indexed by its gap kind")
    return direction


def transport_class(transport: AuthorizedTransport) -> int:
    return (
        (INDEX_CODE[transport.output.requested_index] * 4
         + USE_DIRECTION_CODE[transport.reading.direction])
        * 2
        + FOCUS_CODE[transport.reading.focus]
    )


def query_class(query: Query) -> int:
    return INDEX_CODE[query.index] * 3 + QUERY_KIND_CODE[query.kind]


def response_class(response: Response) -> int:
    if response.kind is ResponseKind.NO_INFORMATION:
        return 9 + INDEX_CODE[response.index]
    if response.value is None:
        raise ValueError("an informative response has no value")
    return INDEX_CODE[response.index] * 3 + VALUE_CODE[response.value]


def patch_class(patch: CandidatePatch) -> int:
    if patch.kind is PatchKind.KEEP:
        return 0
    if patch.index is None or patch.value is None:
        raise ValueError("set patch lacks an index or value")
    return 1 + INDEX_CODE[patch.index] * 3 + VALUE_CODE[patch.value]


def _gap_one_hot(gap: OperationalGap) -> tuple[int, ...]:
    return one_hot(64, gap_class(gap))


def _use_one_hot(use: AuthorizedUse) -> tuple[int, ...]:
    return one_hot(8, use_class(use))


def _transport_one_hot(transport: AuthorizedTransport) -> tuple[int, ...]:
    return one_hot(64, transport_class(transport))


def _query_one_hot(query: Query) -> tuple[int, ...]:
    return one_hot(9, query_class(query))


def _response_one_hot(response: Response) -> tuple[int, ...]:
    return one_hot(16, response_class(response))


@dataclass(frozen=True)
class HeadExample:
    head: str
    features: tuple[int, ...]
    target: int
    semantic_key: str

    def __post_init__(self) -> None:
        if self.head not in HEAD_ORDER:
            raise ValueError(f"unknown head {self.head}")
        if len(self.features) != HEAD_INPUT_DIMS[self.head]:
            raise ValueError(
                f"{self.head} input has {len(self.features)} coordinates, "
                f"expected {HEAD_INPUT_DIMS[self.head]}"
            )
        if not 0 <= self.target < HEAD_OUTPUT_DIMS[self.head]:
            raise ValueError(f"{self.head} target {self.target} is out of range")
        if any(value not in (0, 1) for value in self.features):
            raise ValueError("certifiable inputs must remain binary Int8 values")


def _agent_states() -> tuple[AgentState, ...]:
    states: dict[AgentState, None] = {
        state.agent: None for state in all_reachable_states()
    }
    projected = initial_state(CANONICAL_WORLD)
    projected_view = AgentState(
        projected.agent.candidate,
        Observation(
            Knowledge(KnowledgeKind.EXCLUDES, Value.RED),
            Knowledge(KnowledgeKind.EXACT, Value.GREEN),
            Knowledge(KnowledgeKind.UNKNOWN),
        ),
        projected.agent.history,
    )
    states[projected_view] = None
    state1 = next_state(projected)
    state2 = next_state(state1)
    dropped_history = AgentState(
        state2.agent.candidate,
        state2.agent.observation,
        (state2.agent.history[-1],),
    )
    states[dropped_history] = None
    return tuple(states)


def certification_examples() -> dict[str, tuple[HeadExample, ...]]:
    """Enumerate every typed local alternative used by the finite causal API."""

    rows: dict[str, dict[tuple[tuple[int, ...], int], HeadExample]] = {
        head: {} for head in HEAD_ORDER
    }

    def add(example: HeadExample) -> None:
        key = (example.features, example.target)
        conflicting = [
            old for (features, target), old in rows[example.head].items()
            if features == example.features and target != example.target
        ]
        if conflicting:
            raise AssertionError(
                f"{example.head} received incompatible labels for one visible input"
            )
        rows[example.head][key] = example

    for view in _agent_states():
        state_features = encode_agent_state(view)
        detected = detect_gap(view)
        if detected is not None:
            add(HeadExample("gap", state_features, gap_class(detected), "detect"))
        for gap in enumerate_gaps(view):
            gap_features = state_features + _gap_one_hot(gap)
            natural_use = authorize(view, gap)
            add(HeadExample("use", gap_features, use_class(natural_use), "authorize"))
            for use in enumerate_uses(gap):
                use_features = gap_features + _use_one_hot(use)
                natural_transport = execute_transport(view, gap, use)
                add(
                    HeadExample(
                        "transport",
                        use_features,
                        transport_class(natural_transport),
                        "executeTransport",
                    )
                )
                for transport in enumerate_transports(gap, use):
                    transport_features = use_features + _transport_one_hot(transport)
                    natural_query = select_query(transport)
                    add(
                        HeadExample(
                            "query",
                            transport_features,
                            query_class(natural_query),
                            "selectQuery",
                        )
                    )
                    for query in enumerate_queries(gap.index):
                        if not query_admissible(gap, use, transport, query):
                            continue
                        query_features = transport_features + _query_one_hot(query)
                        for response in enumerate_responses(query):
                            repair = build_repair(
                                view, gap, use, transport, query, response
                            )
                            add(
                                HeadExample(
                                    "repair",
                                    query_features + _response_one_hot(response),
                                    patch_class(repair.candidate_patch),
                                    "buildRepair",
                                )
                            )
    return {
        head: tuple(
            sorted(
                examples.values(),
                key=lambda item: (item.features, item.target, item.semantic_key),
            )
        )
        for head, examples in rows.items()
    }


@dataclass(frozen=True)
class QuantizedHead:
    input_dim: int
    output_dim: int
    hidden_weights: tuple[tuple[int, ...], ...]
    hidden_bias: tuple[int, ...]
    output_weights: tuple[tuple[int, ...], ...]
    output_bias: tuple[int, ...]
    hidden_shift: int
    output_shift: int
    valid_classes: tuple[int, ...]

    def validate(self) -> None:
        if len(self.hidden_weights) != HIDDEN_DIM:
            raise ValueError("hidden matrix has the wrong number of rows")
        if any(len(row) != self.input_dim for row in self.hidden_weights):
            raise ValueError("hidden matrix has the wrong input dimension")
        if len(self.hidden_bias) != HIDDEN_DIM:
            raise ValueError("hidden bias has the wrong dimension")
        if len(self.output_weights) != self.output_dim:
            raise ValueError("output matrix has the wrong number of rows")
        if any(len(row) != HIDDEN_DIM for row in self.output_weights):
            raise ValueError("output matrix has the wrong hidden dimension")
        if len(self.output_bias) != self.output_dim:
            raise ValueError("output bias has the wrong dimension")
        if not 0 <= self.hidden_shift <= 15 or not 0 <= self.output_shift <= 15:
            raise ValueError("quantized shift is outside 0..15")
        parameters = chain(
            chain.from_iterable(self.hidden_weights),
            self.hidden_bias,
            chain.from_iterable(self.output_weights),
            self.output_bias,
        )
        if any(not INT8_MIN <= value <= INT8_MAX for value in parameters):
            raise ValueError("a quantized parameter is outside Int8")
        if tuple(sorted(set(self.valid_classes))) != self.valid_classes:
            raise ValueError("valid classes are not a canonical sorted set")
        if any(not 0 <= value < self.output_dim for value in self.valid_classes):
            raise ValueError("a valid class is outside the output dimension")


@dataclass(frozen=True)
class QuantizedCheckpoint:
    heads: Mapping[str, QuantizedHead]
    seed: int
    update: int

    def validate(self) -> None:
        if self.seed < 0 or self.update <= 0:
            raise ValueError("checkpoint seed/update are outside the training order")
        if tuple(self.heads) != HEAD_ORDER:
            raise ValueError("checkpoint heads are not in canonical causal order")
        for name, head in self.heads.items():
            if head.input_dim != HEAD_INPUT_DIMS[name]:
                raise ValueError(f"{name} checkpoint input dimension differs")
            if head.output_dim != HEAD_OUTPUT_DIMS[name]:
                raise ValueError(f"{name} checkpoint output dimension differs")
            head.validate()


def quantized_head_to_dict(head: QuantizedHead) -> dict[str, object]:
    head.validate()
    return {
        "hidden_bias": list(head.hidden_bias),
        "hidden_shift": head.hidden_shift,
        "hidden_weights": [list(row) for row in head.hidden_weights],
        "input_dim": head.input_dim,
        "output_bias": list(head.output_bias),
        "output_dim": head.output_dim,
        "output_shift": head.output_shift,
        "output_weights": [list(row) for row in head.output_weights],
        "valid_classes": list(head.valid_classes),
    }


def checkpoint_to_dict(checkpoint: QuantizedCheckpoint) -> dict[str, object]:
    checkpoint.validate()
    return {
        "schema": "v23.quantized_checkpoint.v1",
        "seed": checkpoint.seed,
        "update": checkpoint.update,
        "heads": {
            name: quantized_head_to_dict(checkpoint.heads[name]) for name in HEAD_ORDER
        },
    }


def _integer(value: object, field: str) -> int:
    if isinstance(value, bool) or not isinstance(value, int):
        raise ValueError(f"{field} must be an integer")
    return value


def _integer_vector(value: object, field: str) -> tuple[int, ...]:
    if not isinstance(value, list):
        raise ValueError(f"{field} must be a list")
    return tuple(_integer(item, f"{field}[{index}]") for index, item in enumerate(value))


def _integer_matrix(value: object, field: str) -> tuple[tuple[int, ...], ...]:
    if not isinstance(value, list):
        raise ValueError(f"{field} must be a list")
    return tuple(
        _integer_vector(row, f"{field}[{index}]") for index, row in enumerate(value)
    )


def checkpoint_from_dict(value: object) -> QuantizedCheckpoint:
    if not isinstance(value, dict) or set(value) != {"schema", "seed", "update", "heads"}:
        raise ValueError("quantized checkpoint has the wrong top-level schema")
    if value["schema"] != "v23.quantized_checkpoint.v1":
        raise ValueError("quantized checkpoint version differs")
    encoded_heads = value["heads"]
    if not isinstance(encoded_heads, dict) or set(encoded_heads) != set(HEAD_ORDER):
        raise ValueError("quantized checkpoint head order differs")
    heads: dict[str, QuantizedHead] = {}
    expected_fields = {
        "hidden_bias",
        "hidden_shift",
        "hidden_weights",
        "input_dim",
        "output_bias",
        "output_dim",
        "output_shift",
        "output_weights",
        "valid_classes",
    }
    for name in HEAD_ORDER:
        encoded = encoded_heads[name]
        if not isinstance(encoded, dict) or set(encoded) != expected_fields:
            raise ValueError(f"{name} checkpoint schema differs")
        heads[name] = QuantizedHead(
            input_dim=_integer(encoded["input_dim"], f"{name}.input_dim"),
            output_dim=_integer(encoded["output_dim"], f"{name}.output_dim"),
            hidden_weights=_integer_matrix(
                encoded["hidden_weights"], f"{name}.hidden_weights"
            ),
            hidden_bias=_integer_vector(encoded["hidden_bias"], f"{name}.hidden_bias"),
            output_weights=_integer_matrix(
                encoded["output_weights"], f"{name}.output_weights"
            ),
            output_bias=_integer_vector(encoded["output_bias"], f"{name}.output_bias"),
            hidden_shift=_integer(encoded["hidden_shift"], f"{name}.hidden_shift"),
            output_shift=_integer(encoded["output_shift"], f"{name}.output_shift"),
            valid_classes=_integer_vector(
                encoded["valid_classes"], f"{name}.valid_classes"
            ),
        )
    checkpoint = QuantizedCheckpoint(
        heads=heads,
        seed=_integer(value["seed"], "seed"),
        update=_integer(value["update"], "update"),
    )
    checkpoint.validate()
    return checkpoint


def round_ties_to_even(value: int, shift: int) -> int:
    if not 0 <= shift <= 15:
        raise ValueError("shift is outside 0..15")
    if shift == 0:
        return value
    divisor = 1 << shift
    sign = -1 if value < 0 else 1
    magnitude = abs(value)
    quotient, remainder = divmod(magnitude, divisor)
    doubled = remainder * 2
    if doubled > divisor or (doubled == divisor and quotient % 2 == 1):
        quotient += 1
    return sign * quotient


def saturate_int8(value: int) -> int:
    return max(INT8_MIN, min(INT8_MAX, value))


def _affine(
    matrix: Sequence[Sequence[int]],
    bias: Sequence[int],
    vector: Sequence[int],
) -> tuple[int, ...]:
    values = tuple(
        offset + sum(weight * item for weight, item in zip(row, vector))
        for row, offset in zip(matrix, bias)
    )
    if any(not INT32_MIN <= value <= INT32_MAX for value in values):
        raise OverflowError("quantized accumulator left Int32")
    return values


def infer_logits(head: QuantizedHead, features: Sequence[int]) -> tuple[int, ...]:
    head.validate()
    if len(features) != head.input_dim:
        raise ValueError("inference input has the wrong dimension")
    if any(not INT8_MIN <= value <= INT8_MAX for value in features):
        raise ValueError("inference input left Int8")
    hidden = tuple(
        max(0, saturate_int8(round_ties_to_even(value, head.hidden_shift)))
        for value in _affine(head.hidden_weights, head.hidden_bias, features)
    )
    logits = tuple(
        saturate_int8(round_ties_to_even(value, head.output_shift))
        for value in _affine(head.output_weights, head.output_bias, hidden)
    )
    valid = set(head.valid_classes)
    return tuple(value if index in valid else INT8_MIN for index, value in enumerate(logits))


def canonical_argmax(logits: Sequence[int]) -> int:
    if not logits:
        raise ValueError("argmax of an empty vector")
    maximum = max(logits)
    return next(index for index, value in enumerate(logits) if value == maximum)


def infer_class(head: QuantizedHead, features: Sequence[int]) -> int:
    return canonical_argmax(infer_logits(head, features))


def checkpoint_error_report(
    checkpoint: QuantizedCheckpoint,
    examples: Mapping[str, Sequence[HeadExample]] | None = None,
) -> dict[str, object]:
    checkpoint.validate()
    dataset = certification_examples() if examples is None else examples
    heads: dict[str, dict[str, int]] = {}
    total = 0
    errors = 0
    minimum_margin = INT8_MAX - INT8_MIN
    for name in HEAD_ORDER:
        head_errors = 0
        for example in dataset[name]:
            logits = infer_logits(checkpoint.heads[name], example.features)
            predicted = canonical_argmax(logits)
            competitors = [value for index, value in enumerate(logits) if index != predicted]
            margin = logits[predicted] - max(competitors)
            minimum_margin = min(minimum_margin, margin)
            if predicted != example.target:
                head_errors += 1
        count = len(dataset[name])
        heads[name] = {"errors": head_errors, "examples": count}
        total += count
        errors += head_errors
    return {
        "errors": errors,
        "examples": total,
        "heads": heads,
        "minimum_integer_margin": minimum_margin,
        "valid": errors == 0 and minimum_margin > 0,
    }


__all__ = [
    "HEAD_INPUT_DIMS",
    "HEAD_ORDER",
    "HEAD_OUTPUT_DIMS",
    "HIDDEN_DIM",
    "HeadExample",
    "INT8_MAX",
    "INT8_MIN",
    "QuantizedCheckpoint",
    "QuantizedHead",
    "STATE_DIM",
    "canonical_argmax",
    "certification_examples",
    "checkpoint_from_dict",
    "checkpoint_error_report",
    "checkpoint_to_dict",
    "decode_gap_class",
    "encode_agent_state",
    "gap_class",
    "infer_class",
    "infer_logits",
    "one_hot",
    "patch_class",
    "query_class",
    "response_class",
    "round_ties_to_even",
    "saturate_int8",
    "transport_class",
    "use_class",
]
