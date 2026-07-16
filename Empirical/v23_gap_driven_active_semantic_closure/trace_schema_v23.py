#!/usr/bin/env python3
"""Canonical raw-trace schema for the v23 active semantic closure campaign.

This module validates serialization and causal envelope invariants only.  It
does not trust ``validity_flags`` and does not decide domain semantics.  Later
independent verifiers must recompute gaps, uses, transports, responses,
repairs, compatible fibers, and transitions from their authoritative inputs.
"""

from __future__ import annotations

import hashlib
import json
import re
import unicodedata
from dataclasses import dataclass
from typing import Any, Iterable, Mapping, NoReturn, Sequence


SCHEMA_VERSION = "v23.raw_trace.v1"
PROTOCOL_VERSION = "v23-protocol-1"

DOMAINS = frozenset(
    {
        "finite_reference",
        "perceptual_compositional",
        "symbolic_repair",
    }
)

SPLITS = frozenset(
    {
        "finite_exhaustive",
        "train",
        "iid_validation",
        "structural_validation",
        "iid_test",
        "ood_sealed",
        "intervention",
        "replication",
    }
)

PRODUCER_KINDS = frozenset(
    {"reference", "certifiable_agent", "scaling_agent", "baseline"}
)
GAP_STATUSES = frozenset({"open", "closed"})
EXECUTION_STATUSES = frozenset(
    {"advanced", "closed_stasis", "typed_refusal"}
)

INTERVENTION_KINDS = frozenset(
    {
        "natural",
        "I_projection",
        "I_gap_suppress",
        "I_gap_permute",
        "I_use_suppress",
        "I_use_permute",
        "I_transport_suppress",
        "I_transport_permute",
        "I_query_neutral",
        "I_query_alternate",
        "I_response_cross",
        "I_response_neutral",
        "I_repair_neutral",
        "I_repair_permute",
        "I_next_bypass",
        "I_history_drop",
        "I_order_swap",
        "I_random_gap",
        "I_unused_gap",
    }
)

INTERVENTION_TARGETS = {
    "I_projection": "projection",
    "I_gap_suppress": "gap",
    "I_gap_permute": "gap",
    "I_use_suppress": "use",
    "I_use_permute": "use",
    "I_transport_suppress": "transport",
    "I_transport_permute": "transport",
    "I_query_neutral": "query",
    "I_query_alternate": "query",
    "I_response_cross": "response",
    "I_response_neutral": "response",
    "I_repair_neutral": "repair",
    "I_repair_permute": "repair",
    "I_next_bypass": "next",
    "I_history_drop": "history",
    "I_order_swap": "transport",
    "I_random_gap": "gap",
    "I_unused_gap": "use",
}

REFUSAL_STAGES = (
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

MANDATORY_REFUSAL_INTERVENTIONS = {
    "I_gap_suppress": "gap",
    "I_use_suppress": "use",
    "I_transport_suppress": "transport",
    "I_next_bypass": "next",
    "I_unused_gap": "use",
}

CAUSAL_VARIABLES = (
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

FORBIDDEN_AGENT_FIELDS = (
    "compatible_fiber",
    "correct_patch",
    "ground_truth",
    "next_state",
    "oracle_patch",
    "semantic_world",
    "target",
    "world",
)

VALIDITY_FLAG_NAMES = (
    "actual_world_compatible",
    "causal_chain_valid",
    "gap_closed",
    "gap_sound",
    "next_from_repair",
    "persistence_valid",
    "query_admissible",
    "repair_derived",
    "response_well_typed",
    "schema_valid",
    "transport_authorized",
    "use_authorized",
    "world_preserved",
)

TOP_LEVEL_FIELDS = frozenset(
    {
        "schema_version",
        "protocol_version",
        "run_id",
        "training_seed",
        "environment_seed",
        "domain",
        "split",
        "episode_id",
        "step",
        "checkpoint_sha256",
        "source_bundle_sha256",
        "executed_script_sha256",
        "command_sha256",
        "producer_kind",
        "world_commitment",
        "agent_input_manifest",
        "state_before",
        "compatible_fiber_before",
        "gap_status",
        "execution_status",
        "refusal_stage",
        "refusal_reason",
        "gap",
        "gap_evidence",
        "authorized_use",
        "authorized_transport",
        "query",
        "query_footprint",
        "response",
        "response_footprint",
        "intrinsic_repair",
        "state_after",
        "compatible_fiber_after",
        "gap_closed_by",
        "known_closed_prefix",
        "persistence_obligations",
        "state_after_hash",
        "intervention_kind",
        "intervention_payload",
        "fixed_variables",
        "recomputed_variables",
        "natural_trace_hash",
        "validity_flags",
    }
)

OPEN_CAUSAL_FIELDS = (
    "gap",
    "gap_evidence",
    "authorized_use",
    "authorized_transport",
    "query",
    "query_footprint",
    "response",
    "response_footprint",
    "intrinsic_repair",
)

_HASH_RE = re.compile(r"^[0-9a-f]{64}$")
_ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._:-]{0,191}$")
_TYPE_TAG_RE = re.compile(r"^[A-Za-z][A-Za-z0-9_.:-]{0,127}$")


def _contains_surrogate(value: str) -> bool:
    return any(0xD800 <= ord(character) <= 0xDFFF for character in value)


@dataclass(frozen=True)
class TraceSchemaError(ValueError):
    """A deterministic validation failure with a stable machine code."""

    code: str
    path: str
    detail: str

    def __str__(self) -> str:
        return f"{self.code} at {self.path}: {self.detail}"


def _fail(code: str, path: str, detail: str) -> NoReturn:
    raise TraceSchemaError(code=code, path=path, detail=detail)


def _reject_constant(token: str) -> NoReturn:
    _fail("non_finite_number", "$", f"JSON constant {token!r} is forbidden")


def _object_without_duplicates(pairs: Sequence[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            _fail("duplicate_key", "$", f"duplicate JSON key {key!r}")
        result[key] = value
    return result


def _validate_json_tree(value: Any, path: str = "$") -> None:
    if value is None or isinstance(value, (bool, int)):
        return
    if isinstance(value, float):
        _fail("float_forbidden", path, "raw traces use exact integers only")
    if isinstance(value, str):
        if _contains_surrogate(value):
            _fail("unicode_surrogate", path, "UTF-8 traces cannot contain surrogates")
        if unicodedata.normalize("NFC", value) != value:
            _fail("non_nfc_string", path, "strings must use NFC normalization")
        return
    if isinstance(value, list):
        for index, item in enumerate(value):
            _validate_json_tree(item, f"{path}[{index}]")
        return
    if isinstance(value, dict):
        for key, item in value.items():
            if not isinstance(key, str):
                _fail("non_string_key", path, "all object keys must be strings")
            if _contains_surrogate(key):
                _fail("unicode_surrogate", path, "UTF-8 keys cannot contain surrogates")
            if unicodedata.normalize("NFC", key) != key:
                _fail("non_nfc_key", path, f"key {key!r} is not NFC")
            _validate_json_tree(item, f"{path}.{key}")
        return
    _fail("unsupported_json_type", path, f"unsupported value {type(value).__name__}")


def canonical_json(value: Any) -> str:
    """Serialize a JSON value in the campaign's canonical form."""

    _validate_json_tree(value)
    return json.dumps(
        value,
        ensure_ascii=False,
        allow_nan=False,
        sort_keys=True,
        separators=(",", ":"),
    )


def canonical_json_bytes(value: Any) -> bytes:
    return canonical_json(value).encode("utf-8")


def canonical_sha256(value: Any) -> str:
    return hashlib.sha256(canonical_json_bytes(value)).hexdigest()


def parse_json_strict(text: str, *, require_canonical: bool = True) -> Any:
    """Parse JSON while rejecting duplicate keys and non-canonical encodings."""

    try:
        value = json.loads(
            text,
            object_pairs_hook=_object_without_duplicates,
            parse_constant=_reject_constant,
        )
    except TraceSchemaError:
        raise
    except (json.JSONDecodeError, UnicodeDecodeError, ValueError) as error:
        _fail("invalid_json", "$", str(error))
    _validate_json_tree(value)
    if require_canonical and text != canonical_json(value):
        _fail("non_canonical_json", "$", "input differs from canonical serialization")
    return value


def _expect_dict(value: Any, path: str) -> Mapping[str, Any]:
    if not isinstance(value, dict):
        _fail("expected_object", path, f"got {type(value).__name__}")
    return value


def _expect_exact_fields(
    value: Mapping[str, Any], expected: Iterable[str], path: str
) -> None:
    expected_set = frozenset(expected)
    actual = frozenset(value)
    missing = sorted(expected_set - actual)
    extra = sorted(actual - expected_set)
    if missing or extra:
        _fail("field_mismatch", path, f"missing={missing}, extra={extra}")


def _expect_string(value: Any, path: str, *, nonempty: bool = True) -> str:
    if not isinstance(value, str):
        _fail("expected_string", path, f"got {type(value).__name__}")
    if nonempty and not value:
        _fail("empty_string", path, "a non-empty string is required")
    return value


def _expect_identifier(value: Any, path: str) -> str:
    result = _expect_string(value, path)
    if _ID_RE.fullmatch(result) is None:
        _fail("invalid_identifier", path, f"invalid identifier {result!r}")
    return result


def _expect_hash(value: Any, path: str) -> str:
    result = _expect_string(value, path)
    if _HASH_RE.fullmatch(result) is None:
        _fail("invalid_sha256", path, "expected 64 lowercase hexadecimal digits")
    if result == "0" * 64:
        _fail("sentinel_sha256", path, "the all-zero sentinel is not a content hash")
    return result


def _expect_int(value: Any, path: str, *, nullable: bool = False) -> int | None:
    if value is None and nullable:
        return None
    if isinstance(value, bool) or not isinstance(value, int):
        _fail("expected_integer", path, f"got {type(value).__name__}")
    if value < 0:
        _fail("negative_integer", path, "expected a non-negative integer")
    return value


def _expect_enum(value: Any, allowed: frozenset[str], path: str) -> str:
    result = _expect_string(value, path)
    if result not in allowed:
        _fail("invalid_enum", path, f"{result!r} not in {sorted(allowed)}")
    return result


def _expect_sorted_unique_strings(value: Any, path: str) -> list[str]:
    if not isinstance(value, list):
        _fail("expected_array", path, f"got {type(value).__name__}")
    result = [_expect_string(item, f"{path}[{i}]") for i, item in enumerate(value)]
    if result != sorted(set(result)):
        _fail("noncanonical_set", path, "array must be sorted and duplicate-free")
    return result


def _expect_hash_set(value: Any, path: str) -> list[str]:
    result = _expect_sorted_unique_strings(value, path)
    for index, item in enumerate(result):
        _expect_hash(item, f"{path}[{index}]")
    if not result:
        _fail("empty_fiber", path, "compatible fibers must be non-empty")
    return result


def _expect_typed_value(value: Any, path: str) -> Mapping[str, Any]:
    result = _expect_dict(value, path)
    _expect_exact_fields(result, {"type", "value"}, path)
    tag = _expect_string(result["type"], f"{path}.type")
    if _TYPE_TAG_RE.fullmatch(tag) is None:
        _fail("invalid_type_tag", f"{path}.type", f"invalid type tag {tag!r}")
    _validate_json_tree(result["value"], f"{path}.value")
    return result


def _find_forbidden_keys(value: Any, path: str) -> list[str]:
    found: list[str] = []
    if isinstance(value, dict):
        for key, item in value.items():
            child = f"{path}.{key}"
            if key in FORBIDDEN_AGENT_FIELDS:
                found.append(child)
            found.extend(_find_forbidden_keys(item, child))
    elif isinstance(value, list):
        for index, item in enumerate(value):
            found.extend(_find_forbidden_keys(item, f"{path}[{index}]"))
    return found


def _validate_agent_input_manifest(value: Any) -> None:
    path = "$.agent_input_manifest"
    manifest = _expect_dict(value, path)
    _expect_exact_fields(
        manifest,
        {"encoding", "sha256", "byte_length", "fields", "forbidden_fields_absent"},
        path,
    )
    _expect_identifier(manifest["encoding"], f"{path}.encoding")
    _expect_hash(manifest["sha256"], f"{path}.sha256")
    _expect_int(manifest["byte_length"], f"{path}.byte_length")
    fields = _expect_sorted_unique_strings(manifest["fields"], f"{path}.fields")
    leaked_fields = sorted(set(fields) & set(FORBIDDEN_AGENT_FIELDS))
    if leaked_fields:
        _fail(
            "forbidden_manifest_field",
            f"{path}.fields",
            f"forbidden fields {leaked_fields}",
        )
    absent = _expect_sorted_unique_strings(
        manifest["forbidden_fields_absent"], f"{path}.forbidden_fields_absent"
    )
    if absent != list(FORBIDDEN_AGENT_FIELDS):
        _fail(
            "incomplete_leak_manifest",
            f"{path}.forbidden_fields_absent",
            f"expected {list(FORBIDDEN_AGENT_FIELDS)}",
        )


def _validate_query_footprint(value: Any, path: str) -> None:
    footprint = _expect_dict(value, path)
    _expect_exact_fields(
        footprint, {"requested_index", "query_count", "serialized_bits"}, path
    )
    _expect_typed_value(footprint["requested_index"], f"{path}.requested_index")
    count = _expect_int(footprint["query_count"], f"{path}.query_count")
    if count != 1:
        _fail("invalid_query_count", f"{path}.query_count", "one query per step")
    _expect_int(footprint["serialized_bits"], f"{path}.serialized_bits")


def _validate_response_footprint(value: Any, path: str) -> None:
    footprint = _expect_dict(value, path)
    _expect_exact_fields(
        footprint, {"requested_index", "actual_bits", "max_bits"}, path
    )
    _expect_typed_value(footprint["requested_index"], f"{path}.requested_index")
    actual = _expect_int(footprint["actual_bits"], f"{path}.actual_bits")
    maximum = _expect_int(footprint["max_bits"], f"{path}.max_bits")
    assert actual is not None and maximum is not None
    if actual > maximum:
        _fail("response_budget_exceeded", path, f"actual_bits={actual} > max_bits={maximum}")


def _validate_persistence(value: Any) -> None:
    path = "$.persistence_obligations"
    if not isinstance(value, list):
        _fail("expected_array", path, f"got {type(value).__name__}")
    previous_encoding: str | None = None
    for index, item in enumerate(value):
        item_path = f"{path}[{index}]"
        obligation = _expect_dict(item, item_path)
        _expect_exact_fields(
            obligation, {"index", "preserved", "provenance_sha256"}, item_path
        )
        _expect_typed_value(obligation["index"], f"{item_path}.index")
        if not isinstance(obligation["preserved"], bool):
            _fail("expected_boolean", f"{item_path}.preserved", "expected bool")
        _expect_hash(obligation["provenance_sha256"], f"{item_path}.provenance_sha256")
        encoding = canonical_json(obligation["index"])
        if previous_encoding is not None and encoding <= previous_encoding:
            _fail("noncanonical_obligation_order", path, "indices must be strictly ordered")
        previous_encoding = encoding


def _validate_validity_flags(value: Any) -> None:
    path = "$.validity_flags"
    flags = _expect_dict(value, path)
    _expect_exact_fields(flags, VALIDITY_FLAG_NAMES, path)
    for name, flag in flags.items():
        if flag is not None and not isinstance(flag, bool):
            _fail("invalid_validity_flag", f"{path}.{name}", "expected bool or null")


def _validate_intervention(record: Mapping[str, Any]) -> str:
    kind = _expect_enum(
        record["intervention_kind"], INTERVENTION_KINDS, "$.intervention_kind"
    )
    fixed = _expect_sorted_unique_strings(record["fixed_variables"], "$.fixed_variables")
    recomputed = _expect_sorted_unique_strings(
        record["recomputed_variables"], "$.recomputed_variables"
    )
    unknown = sorted((set(fixed) | set(recomputed)) - set(CAUSAL_VARIABLES))
    if unknown:
        _fail("unknown_causal_variable", "$", f"unknown variables {unknown}")
    overlap = sorted(set(fixed) & set(recomputed))
    if overlap:
        _fail("intervention_partition_overlap", "$", f"overlap {overlap}")

    if kind == "natural":
        if record["intervention_payload"] is not None:
            _fail("natural_payload", "$.intervention_payload", "natural traces have no payload")
        if fixed or recomputed:
            _fail("natural_variable_partition", "$", "natural traces have no intervention partition")
        if record["natural_trace_hash"] is not None:
            _fail("natural_trace_self_reference", "$.natural_trace_hash", "must be null")
    else:
        _expect_typed_value(record["intervention_payload"], "$.intervention_payload")
        _expect_hash(record["natural_trace_hash"], "$.natural_trace_hash")
        if not recomputed:
            _fail("empty_intervention_recomputation", "$", "an intervention must recompute its target")
        omitted = sorted(set(CAUSAL_VARIABLES) - set(fixed) - set(recomputed))
        if omitted:
            _fail(
                "incomplete_intervention_partition",
                "$",
                f"omitted causal variables {omitted}",
            )
        target = INTERVENTION_TARGETS[kind]
        target_index = CAUSAL_VARIABLES.index(target)
        expected_fixed = sorted(CAUSAL_VARIABLES[:target_index])
        expected_recomputed = sorted(CAUSAL_VARIABLES[target_index:])
        if fixed != expected_fixed or recomputed != expected_recomputed:
            _fail(
                "invalid_intervention_causal_partition",
                "$",
                f"target={target}, fixed={expected_fixed}, recomputed={expected_recomputed}",
            )
    return kind


def _validate_closed_stasis(record: Mapping[str, Any]) -> None:
    if record["gap_status"] != "closed":
        _fail("closed_status_mismatch", "$.gap_status", "closed_stasis requires closed")
    for field in OPEN_CAUSAL_FIELDS:
        if record[field] is not None:
            _fail("closed_branch_payload", f"$.{field}", "closed branch requires null")
    if record["gap_closed_by"] is not None:
        _fail("closed_branch_certificate", "$.gap_closed_by", "no current gap exists")
    if record["state_after"] != record["state_before"]:
        _fail("closed_state_changed", "$.state_after", "closed stasis must preserve state")
    if record["compatible_fiber_after"] != record["compatible_fiber_before"]:
        _fail("closed_fiber_changed", "$.compatible_fiber_after", "closed stasis preserves fiber")


def _validate_advanced(record: Mapping[str, Any], intervention_kind: str) -> None:
    if record["gap_status"] != "open":
        _fail("advanced_status_mismatch", "$.gap_status", "advanced requires an open gap")
    for field in OPEN_CAUSAL_FIELDS:
        if record[field] is None:
            _fail("missing_causal_value", f"$.{field}", "advanced trace requires this value")
    for field in (
        "gap",
        "gap_evidence",
        "authorized_use",
        "authorized_transport",
        "query",
        "response",
        "intrinsic_repair",
    ):
        _expect_typed_value(record[field], f"$.{field}")
    _validate_query_footprint(record["query_footprint"], "$.query_footprint")
    _validate_response_footprint(record["response_footprint"], "$.response_footprint")
    if record["refusal_stage"] is not None or record["refusal_reason"] is not None:
        _fail("advanced_refusal_payload", "$", "advanced traces cannot carry refusal data")
    before = record["compatible_fiber_before"]
    after = record["compatible_fiber_after"]
    if not set(after).issubset(before):
        _fail("fiber_expansion", "$.compatible_fiber_after", "fiber must not gain worlds")
    if intervention_kind == "natural":
        if record["gap_closed_by"] is None:
            _fail("missing_gap_closure", "$.gap_closed_by", "natural advanced steps must close their gap")
        if len(after) >= len(before):
            _fail("missing_strict_fiber_reduction", "$.compatible_fiber_after", "natural informative step must strictly reduce the fiber")
        if record["state_after"] == record["state_before"]:
            _fail("ineffective_natural_repair", "$.state_after", "natural repair must change state")
    else:
        closure_flag = record["validity_flags"]["gap_closed"]
        if not isinstance(closure_flag, bool):
            _fail("intervention_closure_flag", "$.validity_flags.gap_closed", "advanced interventions require a boolean closure result")
        if closure_flag != (record["gap_closed_by"] is not None):
            _fail("intervention_closure_mismatch", "$.gap_closed_by", "certificate presence must match the recomputed closure flag")


def _validate_typed_refusal(record: Mapping[str, Any], intervention_kind: str) -> None:
    if intervention_kind == "natural":
        _fail("natural_refusal", "$.execution_status", "natural traces cannot refuse")
    if record["gap_status"] != "open":
        _fail("refusal_gap_status", "$.gap_status", "typed refusal requires an open causal attempt")
    stage = _expect_string(record["refusal_stage"], "$.refusal_stage")
    if stage not in REFUSAL_STAGES:
        _fail("invalid_refusal_stage", "$.refusal_stage", f"invalid stage {stage!r}")
    _expect_string(record["refusal_reason"], "$.refusal_reason")
    if record["state_after"] != record["state_before"]:
        _fail("refusal_changed_state", "$.state_after", "refusal must preserve state")
    if record["compatible_fiber_after"] != record["compatible_fiber_before"]:
        _fail("refusal_changed_fiber", "$.compatible_fiber_after", "refusal must preserve fiber")
    if record["gap_closed_by"] is not None:
        _fail("refusal_claims_closure", "$.gap_closed_by", "refusal cannot close a gap")
    if intervention_kind == "I_next_bypass" and stage != "next":
        _fail("next_bypass_not_rejected", "$.refusal_stage", "I_next_bypass must refuse at next")

    stage_to_prefix_length = {
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
    prefix_length = stage_to_prefix_length[stage]
    for field in OPEN_CAUSAL_FIELDS[:prefix_length]:
        if record[field] is None:
            _fail(
                "missing_value_before_refusal",
                f"$.{field}",
                f"must exist before refusal at {stage}",
            )
    if stage not in {"next", "history"}:
        for field in OPEN_CAUSAL_FIELDS[prefix_length:]:
            if record[field] is not None:
                _fail(
                    "value_after_refusal",
                    f"$.{field}",
                    f"must be null after refusal at {stage}",
                )


def validate_trace_record(
    value: Any, *, require_claimed_validity: bool = False
) -> Mapping[str, Any]:
    """Validate one decoded raw trace record and return it unchanged."""

    record = _expect_dict(value, "$")
    _expect_exact_fields(record, TOP_LEVEL_FIELDS, "$")
    if record["schema_version"] != SCHEMA_VERSION:
        _fail("schema_version", "$.schema_version", f"expected {SCHEMA_VERSION!r}")
    if record["protocol_version"] != PROTOCOL_VERSION:
        _fail("protocol_version", "$.protocol_version", f"expected {PROTOCOL_VERSION!r}")
    _expect_identifier(record["run_id"], "$.run_id")
    producer = _expect_enum(record["producer_kind"], PRODUCER_KINDS, "$.producer_kind")
    training_seed = _expect_int(record["training_seed"], "$.training_seed", nullable=True)
    if producer == "reference":
        if record["checkpoint_sha256"] is not None or training_seed is not None:
            _fail("reference_model_metadata", "$", "reference traces require null checkpoint and training seed")
    else:
        _expect_hash(record["checkpoint_sha256"], "$.checkpoint_sha256")
        if training_seed is None:
            _fail("missing_training_seed", "$.training_seed", "model traces require a seed")
    _expect_int(record["environment_seed"], "$.environment_seed")
    _expect_enum(record["domain"], DOMAINS, "$.domain")
    _expect_enum(record["split"], SPLITS, "$.split")
    _expect_identifier(record["episode_id"], "$.episode_id")
    _expect_int(record["step"], "$.step")
    for field in ("source_bundle_sha256", "executed_script_sha256", "command_sha256"):
        _expect_hash(record[field], f"$.{field}")
    world_commitment = _expect_hash(record["world_commitment"], "$.world_commitment")
    _validate_agent_input_manifest(record["agent_input_manifest"])
    for field in ("state_before", "state_after"):
        _expect_typed_value(record[field], f"$.{field}")
        leaks = _find_forbidden_keys(record[field], f"$.{field}")
        if leaks:
            _fail("agent_state_leak", f"$.{field}", f"forbidden keys at {leaks}")
    for field in (
        "gap",
        "gap_evidence",
        "authorized_use",
        "authorized_transport",
        "query",
        "intrinsic_repair",
    ):
        if record[field] is not None:
            leaks = _find_forbidden_keys(record[field], f"$.{field}")
            if leaks:
                _fail("agent_object_leak", f"$.{field}", f"forbidden keys at {leaks}")
    before_fiber = _expect_hash_set(record["compatible_fiber_before"], "$.compatible_fiber_before")
    after_fiber = _expect_hash_set(record["compatible_fiber_after"], "$.compatible_fiber_after")
    if world_commitment not in before_fiber:
        _fail("actual_world_missing", "$.compatible_fiber_before", "actual world commitment must be compatible before execution")
    _expect_enum(record["gap_status"], GAP_STATUSES, "$.gap_status")
    status = _expect_enum(record["execution_status"], EXECUTION_STATUSES, "$.execution_status")
    if not isinstance(record["known_closed_prefix"], list):
        _fail("expected_array", "$.known_closed_prefix", "expected list")
    for index, item in enumerate(record["known_closed_prefix"]):
        _expect_typed_value(item, f"$.known_closed_prefix[{index}]")
    _validate_persistence(record["persistence_obligations"])
    _expect_hash(record["state_after_hash"], "$.state_after_hash")
    expected_state_hash = canonical_sha256(record["state_after"])
    if record["state_after_hash"] != expected_state_hash:
        _fail("state_hash_mismatch", "$.state_after_hash", f"expected {expected_state_hash}")
    intervention_kind = _validate_intervention(record)
    if intervention_kind == "natural" and world_commitment not in after_fiber:
        _fail(
            "actual_world_missing",
            "$.compatible_fiber_after",
            "natural execution must preserve compatibility with the actual world",
        )
    if intervention_kind != "natural" and record["split"] != "intervention":
        _fail("intervention_split", "$.split", "intervened records belong to the intervention split")
    _validate_validity_flags(record["validity_flags"])

    mandatory_stage = MANDATORY_REFUSAL_INTERVENTIONS.get(intervention_kind)
    if mandatory_stage is not None:
        if status != "typed_refusal" or record["refusal_stage"] != mandatory_stage:
            _fail(
                "mandatory_typed_refusal",
                "$.execution_status",
                f"{intervention_kind} must refuse at {mandatory_stage}",
            )

    for field in (
        "gap",
        "gap_evidence",
        "authorized_use",
        "authorized_transport",
        "query",
        "response",
        "intrinsic_repair",
        "gap_closed_by",
    ):
        if record[field] is not None:
            _expect_typed_value(record[field], f"$.{field}")
    if record["query_footprint"] is not None:
        _validate_query_footprint(record["query_footprint"], "$.query_footprint")
    if record["response_footprint"] is not None:
        _validate_response_footprint(record["response_footprint"], "$.response_footprint")

    if status == "advanced":
        _validate_advanced(record, intervention_kind)
    elif status == "closed_stasis":
        if record["refusal_stage"] is not None or record["refusal_reason"] is not None:
            _fail("stasis_refusal_payload", "$", "closed stasis cannot carry refusal data")
        _validate_closed_stasis(record)
    else:
        _validate_typed_refusal(record, intervention_kind)

    if require_claimed_validity:
        false_flags = sorted(
            name for name, flag in record["validity_flags"].items() if flag is False
        )
        if false_flags:
            _fail("claimed_invalidity", "$.validity_flags", f"false flags {false_flags}")
    return record


def parse_trace_line(
    line: str, *, require_canonical: bool = True, require_claimed_validity: bool = False
) -> Mapping[str, Any]:
    """Parse and validate one JSONL record without its trailing newline."""

    if line.endswith("\n") or line.endswith("\r"):
        _fail("line_terminator", "$", "strip the JSONL line terminator before parsing")
    value = parse_json_strict(line, require_canonical=require_canonical)
    return validate_trace_record(value, require_claimed_validity=require_claimed_validity)


__all__ = [
    "CAUSAL_VARIABLES",
    "DOMAINS",
    "EXECUTION_STATUSES",
    "FORBIDDEN_AGENT_FIELDS",
    "GAP_STATUSES",
    "INTERVENTION_KINDS",
    "INTERVENTION_TARGETS",
    "MANDATORY_REFUSAL_INTERVENTIONS",
    "PRODUCER_KINDS",
    "PROTOCOL_VERSION",
    "SCHEMA_VERSION",
    "SPLITS",
    "TOP_LEVEL_FIELDS",
    "TraceSchemaError",
    "canonical_json",
    "canonical_json_bytes",
    "canonical_sha256",
    "parse_json_strict",
    "parse_trace_line",
    "validate_trace_record",
]
