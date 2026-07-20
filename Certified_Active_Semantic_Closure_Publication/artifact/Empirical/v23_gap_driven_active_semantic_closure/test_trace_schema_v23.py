#!/usr/bin/env python3
"""Mechanical tests for the v23 canonical raw-trace envelope."""

from __future__ import annotations

import copy
import json
import tempfile
import unittest
from pathlib import Path

from trace_schema_v23 import (
    CAUSAL_VARIABLES,
    FORBIDDEN_AGENT_FIELDS,
    INTERVENTION_KINDS,
    INTERVENTION_TARGETS,
    MANDATORY_REFUSAL_INTERVENTIONS,
    PROTOCOL_VERSION,
    SCHEMA_VERSION,
    TraceSchemaError,
    canonical_json,
    canonical_sha256,
    parse_json_strict,
    parse_trace_line,
    validate_trace_record,
)
from verify_trace_schema_v23 import verify_file


H1 = "1" * 64
H2 = "2" * 64
H3 = "3" * 64
H4 = "4" * 64
H5 = "5" * 64
H6 = "6" * 64


def typed(tag: str, **value: object) -> dict[str, object]:
    return {"type": tag, "value": value}


def validity_flags() -> dict[str, bool]:
    return {
        "actual_world_compatible": True,
        "causal_chain_valid": True,
        "gap_closed": True,
        "gap_sound": True,
        "next_from_repair": True,
        "persistence_valid": True,
        "query_admissible": True,
        "repair_derived": True,
        "response_well_typed": True,
        "schema_valid": True,
        "transport_authorized": True,
        "use_authorized": True,
        "world_preserved": True,
    }


def natural_advanced_record() -> dict[str, object]:
    before = typed("finite.AgentState", candidate=0, history=[], observation=0)
    after = typed("finite.AgentState", candidate=1, history=[0], observation=1)
    record: dict[str, object] = {
        "schema_version": SCHEMA_VERSION,
        "protocol_version": PROTOCOL_VERSION,
        "run_id": "schema-test",
        "training_seed": None,
        "environment_seed": 230000,
        "domain": "finite_reference",
        "split": "finite_exhaustive",
        "episode_id": "world-000",
        "step": 0,
        "checkpoint_sha256": None,
        "source_bundle_sha256": H3,
        "executed_script_sha256": H4,
        "command_sha256": H5,
        "producer_kind": "reference",
        "world_commitment": H1,
        "agent_input_manifest": {
            "encoding": "finite.v1",
            "sha256": H6,
            "byte_length": 96,
            "fields": ["candidate", "history", "observation"],
            "forbidden_fields_absent": list(FORBIDDEN_AGENT_FIELDS),
        },
        "state_before": before,
        "compatible_fiber_before": [H1, H2],
        "gap_status": "open",
        "execution_status": "advanced",
        "refusal_stage": None,
        "refusal_reason": None,
        "gap": typed("finite.Gap", index="first", kind="witnessedMismatch"),
        "gap_evidence": typed("finite.GapEvidence", constructor="excludedPrediction"),
        "authorized_use": typed("finite.AuthorizedUse", direction="correctWitnessedMismatch"),
        "authorized_transport": typed("finite.AuthorizedTransport", focus="candidate"),
        "query": typed("finite.Query", constructor="reveal", index="first"),
        "query_footprint": {
            "requested_index": typed("finite.Index", constructor="first"),
            "query_count": 1,
            "serialized_bits": 2,
        },
        "response": typed("finite.Response", constructor="revealed", value="green"),
        "response_footprint": {
            "requested_index": typed("finite.Index", constructor="first"),
            "actual_bits": 2,
            "max_bits": 2,
        },
        "intrinsic_repair": typed("finite.IntrinsicRepair", index="first", value="green"),
        "state_after": after,
        "compatible_fiber_after": [H1],
        "gap_closed_by": typed("finite.GapClosedBy", index="first"),
        "known_closed_prefix": [typed("finite.Index", constructor="first")],
        "persistence_obligations": [],
        "state_after_hash": canonical_sha256(after),
        "intervention_kind": "natural",
        "intervention_payload": None,
        "fixed_variables": [],
        "recomputed_variables": [],
        "natural_trace_hash": None,
        "validity_flags": validity_flags(),
    }
    return record


def closed_stasis_record() -> dict[str, object]:
    record = natural_advanced_record()
    record["gap_status"] = "closed"
    record["execution_status"] = "closed_stasis"
    for field in (
        "gap",
        "gap_evidence",
        "authorized_use",
        "authorized_transport",
        "query",
        "query_footprint",
        "response",
        "response_footprint",
        "intrinsic_repair",
        "gap_closed_by",
    ):
        record[field] = None
    record["state_after"] = copy.deepcopy(record["state_before"])
    record["compatible_fiber_after"] = copy.deepcopy(record["compatible_fiber_before"])
    record["state_after_hash"] = canonical_sha256(record["state_after"])
    return record


def rejected_next_bypass_record() -> dict[str, object]:
    record = natural_advanced_record()
    record["execution_status"] = "typed_refusal"
    record["refusal_stage"] = "next"
    record["refusal_reason"] = "next must equal executeRepair"
    record["state_after"] = copy.deepcopy(record["state_before"])
    record["compatible_fiber_after"] = copy.deepcopy(record["compatible_fiber_before"])
    record["gap_closed_by"] = None
    record["state_after_hash"] = canonical_sha256(record["state_after"])
    record["intervention_kind"] = "I_next_bypass"
    record["split"] = "intervention"
    record["intervention_payload"] = typed("intervention.NextBypass", proposed_state=7)
    record["fixed_variables"] = [
        "gap",
        "projection",
        "query",
        "repair",
        "response",
        "transport",
        "use",
    ]
    record["recomputed_variables"] = ["history", "next"]
    record["natural_trace_hash"] = H2
    return record


def mandatory_refusal_record(kind: str, stage: str) -> dict[str, object]:
    record = natural_advanced_record()
    prefix_lengths = {"gap": 0, "use": 2, "transport": 3, "next": 9}
    open_fields = (
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
    for field in open_fields[prefix_lengths[stage] :]:
        record[field] = None
    record["execution_status"] = "typed_refusal"
    record["refusal_stage"] = stage
    record["refusal_reason"] = f"mandatory refusal for {kind}"
    record["state_after"] = copy.deepcopy(record["state_before"])
    record["compatible_fiber_after"] = copy.deepcopy(record["compatible_fiber_before"])
    record["gap_closed_by"] = None
    record["state_after_hash"] = canonical_sha256(record["state_after"])
    record["intervention_kind"] = kind
    record["split"] = "intervention"
    record["intervention_payload"] = typed("intervention.Suppression", stage=stage)
    causal_index = CAUSAL_VARIABLES.index(stage)
    record["fixed_variables"] = sorted(CAUSAL_VARIABLES[:causal_index])
    record["recomputed_variables"] = sorted(CAUSAL_VARIABLES[causal_index:])
    record["natural_trace_hash"] = H2
    return record


def structurally_valid_intervention_record(kind: str) -> dict[str, object]:
    mandatory_stage = MANDATORY_REFUSAL_INTERVENTIONS.get(kind)
    if mandatory_stage is not None:
        return mandatory_refusal_record(kind, mandatory_stage)
    record = natural_advanced_record()
    target = INTERVENTION_TARGETS[kind]
    target_index = CAUSAL_VARIABLES.index(target)
    record["split"] = "intervention"
    record["intervention_kind"] = kind
    record["intervention_payload"] = typed(
        "intervention.StructuralEnvelope", target=target
    )
    record["fixed_variables"] = sorted(CAUSAL_VARIABLES[:target_index])
    record["recomputed_variables"] = sorted(CAUSAL_VARIABLES[target_index:])
    record["natural_trace_hash"] = H2
    return record


def neutral_query_record() -> dict[str, object]:
    record = natural_advanced_record()
    record["split"] = "intervention"
    record["intervention_kind"] = "I_query_neutral"
    record["intervention_payload"] = typed("intervention.NeutralQuery", index="first")
    record["fixed_variables"] = ["gap", "projection", "transport", "use"]
    record["recomputed_variables"] = ["history", "next", "query", "repair", "response"]
    record["natural_trace_hash"] = H2
    record["query"] = typed("finite.Query", constructor="noInformation", index="first")
    record["query_footprint"] = {
        "requested_index": typed("finite.Index", constructor="first"),
        "query_count": 1,
        "serialized_bits": 2,
    }
    record["response"] = typed("finite.Response", constructor="noInformation")
    record["response_footprint"] = {
        "requested_index": typed("finite.Index", constructor="first"),
        "actual_bits": 0,
        "max_bits": 0,
    }
    record["intrinsic_repair"] = typed("finite.IntrinsicRepair", constructor="keep")
    record["state_after"] = copy.deepcopy(record["state_before"])
    record["compatible_fiber_after"] = copy.deepcopy(record["compatible_fiber_before"])
    record["gap_closed_by"] = None
    record["state_after_hash"] = canonical_sha256(record["state_after"])
    record["validity_flags"]["gap_closed"] = False  # type: ignore[index]
    return record


class TraceSchemaTests(unittest.TestCase):
    def test_natural_advanced_record_is_canonical_and_valid(self) -> None:
        record = natural_advanced_record()
        line = canonical_json(record)
        self.assertEqual(parse_trace_line(line), record)

    def test_closed_stasis_contains_no_sentinel_objects(self) -> None:
        record = closed_stasis_record()
        self.assertEqual(validate_trace_record(record), record)
        record["query"] = typed("finite.Query", constructor="noInformation")
        with self.assertRaisesRegex(TraceSchemaError, "closed_branch_payload"):
            validate_trace_record(record)

    def test_closed_stasis_preserves_state_and_fiber_exactly(self) -> None:
        state_record = closed_stasis_record()
        state_record["state_after"] = typed("finite.AgentState", candidate=9)
        state_record["state_after_hash"] = canonical_sha256(state_record["state_after"])
        with self.assertRaisesRegex(TraceSchemaError, "closed_state_changed"):
            validate_trace_record(state_record)

        fiber_record = closed_stasis_record()
        fiber_record["compatible_fiber_after"] = [H1]
        with self.assertRaisesRegex(TraceSchemaError, "closed_fiber_changed"):
            validate_trace_record(fiber_record)

    def test_next_bypass_is_valid_only_as_typed_refusal(self) -> None:
        record = rejected_next_bypass_record()
        self.assertEqual(validate_trace_record(record), record)
        record["execution_status"] = "advanced"
        record["refusal_stage"] = None
        record["refusal_reason"] = None
        with self.assertRaisesRegex(TraceSchemaError, "mandatory_typed_refusal"):
            validate_trace_record(record)

    def test_every_mandatory_suppression_refuses_at_its_declared_stage(self) -> None:
        for kind, stage in sorted(MANDATORY_REFUSAL_INTERVENTIONS.items()):
            with self.subTest(kind=kind, stage=stage):
                record = mandatory_refusal_record(kind, stage)
                self.assertEqual(validate_trace_record(record), record)

                wrong_stage = "transport" if stage != "transport" else "query"
                record["refusal_stage"] = wrong_stage
                with self.assertRaisesRegex(TraceSchemaError, "mandatory_typed_refusal"):
                    validate_trace_record(record)

    def test_every_declared_intervention_has_a_valid_structural_envelope(self) -> None:
        expected = set(INTERVENTION_KINDS) - {"natural"}
        self.assertEqual(set(INTERVENTION_TARGETS), expected)
        for kind in sorted(expected):
            with self.subTest(kind=kind):
                record = structurally_valid_intervention_record(kind)
                self.assertEqual(validate_trace_record(record), record)

    def test_refusal_requires_complete_causal_prefix(self) -> None:
        record = rejected_next_bypass_record()
        record["response"] = None
        with self.assertRaisesRegex(TraceSchemaError, "missing_value_before_refusal"):
            validate_trace_record(record)

    def test_refusal_rejects_values_after_stage(self) -> None:
        record = rejected_next_bypass_record()
        record["intervention_kind"] = "I_use_suppress"
        record["refusal_stage"] = "use"
        record["refusal_reason"] = "authorized use deliberately removed"
        record["fixed_variables"] = ["gap", "projection"]
        record["recomputed_variables"] = [
            "history",
            "next",
            "query",
            "repair",
            "response",
            "transport",
            "use",
        ]
        with self.assertRaisesRegex(TraceSchemaError, "value_after_refusal"):
            validate_trace_record(record)

    def test_neutral_query_can_execute_without_closing_gap(self) -> None:
        record = neutral_query_record()
        self.assertEqual(validate_trace_record(record), record)
        record["validity_flags"]["gap_closed"] = True  # type: ignore[index]
        with self.assertRaisesRegex(TraceSchemaError, "intervention_closure_mismatch"):
            validate_trace_record(record)

    def test_strict_claim_mode_rejects_a_reported_failed_check(self) -> None:
        record = neutral_query_record()
        with self.assertRaisesRegex(TraceSchemaError, "claimed_invalidity"):
            validate_trace_record(record, require_claimed_validity=True)

    def test_state_hash_is_recomputed(self) -> None:
        record = natural_advanced_record()
        record["state_after_hash"] = H2
        with self.assertRaisesRegex(TraceSchemaError, "state_hash_mismatch"):
            validate_trace_record(record)

    def test_actual_world_must_remain_compatible(self) -> None:
        record = natural_advanced_record()
        record["compatible_fiber_after"] = [H2]
        with self.assertRaisesRegex(TraceSchemaError, "actual_world_missing"):
            validate_trace_record(record)

    def test_counterfactual_intervention_may_exclude_actual_world(self) -> None:
        record = structurally_valid_intervention_record("I_response_cross")
        record["compatible_fiber_after"] = [H2]
        record["gap_closed_by"] = None
        record["validity_flags"]["actual_world_compatible"] = False  # type: ignore[index]
        record["validity_flags"]["gap_closed"] = False  # type: ignore[index]
        self.assertEqual(validate_trace_record(record), record)

    def test_natural_step_must_reduce_fiber_and_change_state(self) -> None:
        record = natural_advanced_record()
        record["compatible_fiber_after"] = copy.deepcopy(record["compatible_fiber_before"])
        with self.assertRaisesRegex(TraceSchemaError, "missing_strict_fiber_reduction"):
            validate_trace_record(record)

    def test_agent_state_rejects_world_leak(self) -> None:
        record = natural_advanced_record()
        record["state_before"]["value"]["semantic_world"] = {"secret": 1}  # type: ignore[index]
        with self.assertRaisesRegex(TraceSchemaError, "agent_state_leak"):
            validate_trace_record(record)

    def test_manifest_cannot_claim_a_forbidden_input(self) -> None:
        record = natural_advanced_record()
        record["agent_input_manifest"]["fields"] = [  # type: ignore[index]
            "candidate",
            "history",
            "observation",
            "world",
        ]
        with self.assertRaisesRegex(TraceSchemaError, "forbidden_manifest_field"):
            validate_trace_record(record)

    def test_intervention_partition_must_cover_every_causal_variable(self) -> None:
        record = neutral_query_record()
        record["fixed_variables"].remove("gap")  # type: ignore[union-attr]
        with self.assertRaisesRegex(TraceSchemaError, "incomplete_intervention_partition"):
            validate_trace_record(record)

    def test_intervention_partition_must_be_disjoint(self) -> None:
        record = neutral_query_record()
        record["fixed_variables"].append("next")  # type: ignore[union-attr]
        record["fixed_variables"].sort()  # type: ignore[union-attr]
        with self.assertRaisesRegex(TraceSchemaError, "intervention_partition_overlap"):
            validate_trace_record(record)

    def test_intervention_partition_must_follow_causal_descendants(self) -> None:
        record = neutral_query_record()
        record["fixed_variables"].append("history")  # type: ignore[union-attr]
        record["fixed_variables"].sort()  # type: ignore[union-attr]
        record["recomputed_variables"].remove("history")  # type: ignore[union-attr]
        with self.assertRaisesRegex(
            TraceSchemaError, "invalid_intervention_causal_partition"
        ):
            validate_trace_record(record)

    def test_projection_intervention_has_no_artificial_fixed_ancestor(self) -> None:
        record = neutral_query_record()
        record["intervention_kind"] = "I_projection"
        record["intervention_payload"] = typed(
            "intervention.Projection", observation="compatible-alternative"
        )
        record["fixed_variables"] = []
        record["recomputed_variables"] = sorted(CAUSAL_VARIABLES)
        self.assertEqual(validate_trace_record(record), record)

    def test_duplicate_keys_are_rejected(self) -> None:
        with self.assertRaisesRegex(TraceSchemaError, "duplicate_key"):
            parse_json_strict('{"a":1,"a":2}')

    def test_top_level_schema_is_closed(self) -> None:
        base = natural_advanced_record()
        for field in sorted(base):
            with self.subTest(missing=field):
                record = copy.deepcopy(base)
                del record[field]
                with self.assertRaisesRegex(TraceSchemaError, "field_mismatch"):
                    validate_trace_record(record)
        extra = copy.deepcopy(base)
        extra["unregistered_claim"] = True
        with self.assertRaisesRegex(TraceSchemaError, "field_mismatch"):
            validate_trace_record(extra)

    def test_noncanonical_json_is_rejected(self) -> None:
        with self.assertRaisesRegex(TraceSchemaError, "non_canonical_json"):
            parse_json_strict('{"b": 2, "a": 1}')

    def test_non_finite_and_floating_numbers_are_rejected(self) -> None:
        with self.assertRaisesRegex(TraceSchemaError, "non_finite_number"):
            parse_json_strict("NaN")
        with self.assertRaisesRegex(TraceSchemaError, "float_forbidden"):
            parse_json_strict("1.5")

    def test_unicode_surrogates_are_rejected(self) -> None:
        surrogate = json.loads('"\\ud800"')
        with self.assertRaisesRegex(TraceSchemaError, "unicode_surrogate"):
            canonical_json(surrogate)

    def test_all_zero_hash_is_rejected_as_sentinel(self) -> None:
        record = natural_advanced_record()
        record["command_sha256"] = "0" * 64
        with self.assertRaisesRegex(TraceSchemaError, "sentinel_sha256"):
            validate_trace_record(record)

    def test_file_verifier_requires_lf_and_reports_hash(self) -> None:
        line = canonical_json(natural_advanced_record())
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "trace.jsonl"
            path.write_text(line + "\n", encoding="utf-8", newline="\n")
            report = verify_file(path, require_validity_flags=True)
            self.assertTrue(report["valid"])
            self.assertEqual(report["records"], 1)
            self.assertEqual(report["execution_status_counts"], {"advanced": 1})

    def test_file_verifier_preserves_unicode_line_separator_in_json(self) -> None:
        record = natural_advanced_record()
        record["refusal_reason"] = None
        record["state_before"]["value"]["note"] = "left\u2028right"  # type: ignore[index]
        record["state_after_hash"] = canonical_sha256(record["state_after"])
        line = canonical_json(record)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "trace.jsonl"
            path.write_text(line + "\n", encoding="utf-8", newline="\n")
            report = verify_file(path)
            self.assertEqual(report["records"], 1)

    def test_file_verifier_rejects_missing_lf_and_crlf(self) -> None:
        line = canonical_json(natural_advanced_record())
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "trace.jsonl"
            path.write_bytes(line.encode("utf-8"))
            with self.assertRaisesRegex(TraceSchemaError, "missing_final_newline"):
                verify_file(path)
            path.write_bytes((line + "\r\n").encode("utf-8"))
            with self.assertRaisesRegex(TraceSchemaError, "carriage_return"):
                verify_file(path)


if __name__ == "__main__":
    unittest.main()
