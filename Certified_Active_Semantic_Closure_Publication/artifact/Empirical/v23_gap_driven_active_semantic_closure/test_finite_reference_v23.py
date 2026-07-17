#!/usr/bin/env python3
"""Exhaustive and adversarial tests for the exact finite Level-A model."""

from __future__ import annotations

import copy
import tempfile
import unittest
from pathlib import Path

from environment_v23 import SemanticVerificationError, provenance_from_material
from finite_reference_domain_v23 import (
    ALL_WORLDS,
    CANONICAL_WORLD,
    INDICES,
    PrivateFiniteManifest,
    compatible_with_view_history,
    compatible_worlds,
    detect_gap,
    enumerate_gaps,
    enumerate_queries,
    enumerate_responses,
    enumerate_transports,
    enumerate_uses,
    gap_closed_by,
    initial_state,
    known_closed_on,
    natural_trace_record,
    open_transition,
    orbit,
    query_admissible,
    repairs_retained,
    response_well_typed,
    validate_semantic_gap,
    validate_transport,
    validate_use,
)
from trace_schema_v23 import canonical_json
from finite_interventions_v23 import intervention_records
from verify_finite_interventions_v23 import verify_intervention_matrix
from compile_lean_trace_v23 import compare_rows, python_conformance_rows
from verify_finite_reference_v23 import verify_finite_file, verify_finite_record


class FiniteReferenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.manifest = PrivateFiniteManifest(b"v23-finite-test-private-salt")
        cls.provenance = provenance_from_material(
            run_id="finite-test",
            environment_seed=23,
            source_bundle=b"finite-test-source",
            executed_script=b"finite-test-script",
            command="finite-test-command",
        )

    def _record(self) -> dict[str, object]:
        return natural_trace_record(
            initial_state(CANONICAL_WORLD),
            step=0,
            episode_id="canonical",
            provenance=self.provenance,
            manifest=self.manifest,
        )

    def test_every_world_closes_with_strict_causal_progress(self) -> None:
        open_steps = 0
        for world in ALL_WORLDS:
            states = orbit(world)
            self.assertLessEqual(len(states) - 1, len(INDICES))
            self.assertIsNone(detect_gap(states[-1].agent))
            self.assertTrue(known_closed_on(states[-1].agent, INDICES))
            self.assertTrue(compatible_with_view_history(states[-1].agent, world))
            self.assertTrue(repairs_retained(states[-1].agent))
            for before, after in zip(states, states[1:]):
                transition = open_transition(before)
                self.assertIsNotNone(transition)
                assert transition is not None
                self.assertEqual(transition.after, after)
                self.assertTrue(validate_semantic_gap(before, transition.gap))
                self.assertTrue(validate_use(transition.gap, transition.use))
                self.assertTrue(
                    validate_transport(
                        transition.gap, transition.use, transition.transport
                    )
                )
                self.assertTrue(
                    query_admissible(
                        transition.gap,
                        transition.use,
                        transition.transport,
                        transition.query,
                    )
                )
                self.assertTrue(
                    response_well_typed(transition.query, transition.response)
                )
                self.assertTrue(gap_closed_by(before, transition.gap, after))
                self.assertLess(
                    len(compatible_worlds(after.agent)),
                    len(compatible_worlds(before.agent)),
                )
                self.assertTrue(repairs_retained(after.agent))
                open_steps += 1
        self.assertEqual(open_steps, 72)

    def test_canonical_orbit_has_the_exact_announced_geometry(self) -> None:
        states = orbit(CANONICAL_WORLD)
        self.assertEqual([len(compatible_worlds(state.agent)) for state in states], [18, 9, 3, 1])
        self.assertEqual(
            [detect_gap(state.agent).index.value for state in states[:-1]],
            ["first", "second", "third"],
        )
        self.assertEqual(
            [detect_gap(state.agent).kind.value for state in states[:-1]],
            ["witnessedMismatch", "unresolvedFiber", "unresolvedFiber"],
        )

    def test_all_typed_local_alternatives_are_finite_and_indexed(self) -> None:
        counts = {"gaps": 0, "uses": 0, "transports": 0, "queries": 0, "responses": 0}
        for world in ALL_WORLDS:
            for state in orbit(world):
                for gap in enumerate_gaps(state.agent):
                    self.assertEqual(gap.index, gap.evidence.index)
                    counts["gaps"] += 1
                    for use in enumerate_uses(gap):
                        self.assertTrue(validate_use(gap, use))
                        counts["uses"] += 1
                        for transport in enumerate_transports(gap, use):
                            self.assertTrue(validate_transport(gap, use, transport))
                            counts["transports"] += 1
                            for query in enumerate_queries(gap.index):
                                counts["queries"] += 1
                                for response in enumerate_responses(query):
                                    self.assertTrue(response_well_typed(query, response))
                                    counts["responses"] += 1
        self.assertEqual(counts, {"gaps": 135, "uses": 270, "transports": 540, "queries": 1620, "responses": 3780})

    def test_independent_verifier_accepts_every_reachable_record(self) -> None:
        verified = 0
        for world_number, world in enumerate(ALL_WORLDS):
            for step, state in enumerate(orbit(world, include_terminal_stasis=True)):
                record = natural_trace_record(
                    state,
                    step=step,
                    episode_id=f"world-{world_number:03d}",
                    provenance=self.provenance,
                    manifest=self.manifest,
                )
                verify_finite_record(record, self.manifest)
                verified += 1
        self.assertEqual(verified, 126)

    def test_file_verifier_checks_episode_continuity_and_semantics(self) -> None:
        records: list[dict[str, object]] = []
        for world_number, world in enumerate(ALL_WORLDS):
            for step, state in enumerate(orbit(world, include_terminal_stasis=True)):
                records.append(
                    natural_trace_record(
                        state,
                        step=step,
                        episode_id=f"world-{world_number:03d}",
                        provenance=self.provenance,
                        manifest=self.manifest,
                    )
                )
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "finite_smoke_trace.jsonl"
            path.write_text("".join(canonical_json(record) + "\n" for record in records), encoding="utf-8")
            report = verify_finite_file(path, self.manifest)
        self.assertEqual(report["episodes"], 27)
        self.assertEqual(report["records"], 126)
        self.assertEqual(report["advanced"], 72)
        self.assertEqual(report["closed_stasis"], 54)

    def test_semantic_mutations_are_rejected_independently(self) -> None:
        mutations = []

        def mutation(name: str, edit: object) -> None:
            mutations.append((name, edit))

        mutation("gap", lambda r: r["gap"]["value"].__setitem__("index", "second"))
        mutation("evidence", lambda r: r["gap_evidence"]["value"].__setitem__("constructor", "unknown"))
        mutation("use", lambda r: r["authorized_use"]["value"].__setitem__("direction", "inspectWitnessedMismatch"))
        mutation("transport", lambda r: r["authorized_transport"]["value"]["reading"].__setitem__("focus", "evidence"))
        mutation("query", lambda r: r["query"]["value"].__setitem__("constructor", "confirm"))
        mutation("response", lambda r: r["response"]["value"].__setitem__("value", "blue"))
        mutation("repair", lambda r: r["intrinsic_repair"]["value"]["candidatePatch"].__setitem__("value", "blue"))
        mutation("after", lambda r: r["state_after"]["value"]["candidate"].__setitem__("first", "blue"))
        mutation("fiber", lambda r: r["compatible_fiber_after"].pop())
        mutation("prefix", lambda r: r.__setitem__("known_closed_prefix", []))
        mutation("manifest", lambda r: r["agent_input_manifest"].__setitem__("byte_length", 1))

        for name, edit in mutations:
            with self.subTest(name=name):
                record = copy.deepcopy(self._record())
                edit(record)
                # Keep the envelope hash valid so rejection cannot be attributed
                # merely to the generic state hash check.
                if name == "after":
                    from trace_schema_v23 import canonical_sha256

                    record["state_after_hash"] = canonical_sha256(record["state_after"])
                with self.assertRaises((SemanticVerificationError, ValueError)):
                    verify_finite_record(record, self.manifest)

    def test_complete_intervention_matrix_is_independently_verified(self) -> None:
        state0 = initial_state(CANONICAL_WORLD)
        state1 = open_transition(state0).after  # type: ignore[union-attr]
        naturals = [
            natural_trace_record(
                state0,
                step=0,
                episode_id="canonical-natural-0",
                provenance=self.provenance,
                manifest=self.manifest,
            ),
            natural_trace_record(
                state1,
                step=1,
                episode_id="canonical-natural-1",
                provenance=self.provenance,
                manifest=self.manifest,
            ),
        ]
        interventions = intervention_records(
            provenance=self.provenance, manifest=self.manifest
        )
        report = verify_intervention_matrix(
            interventions, manifest=self.manifest, natural_records=naturals
        )
        self.assertEqual(report, {"advanced": 8, "interventions": 18, "typed_refusals": 10, "valid": True})
        alternate_query = next(
            record
            for record in interventions
            if record["intervention_kind"] == "I_query_alternate"
        )
        self.assertEqual(alternate_query["execution_status"], "advanced")
        self.assertEqual(
            alternate_query["query"]["value"],
            {"constructor": "confirm", "index": "first"},
        )
        self.assertEqual(
            alternate_query["response"]["value"]["constructor"], "confirmed"
        )

    def test_intervention_payload_and_pairing_mutations_fail(self) -> None:
        state0 = initial_state(CANONICAL_WORLD)
        state1 = open_transition(state0).after  # type: ignore[union-attr]
        naturals = [
            natural_trace_record(
                state,
                step=step,
                episode_id=f"canonical-natural-{step}",
                provenance=self.provenance,
                manifest=self.manifest,
            )
            for step, state in enumerate((state0, state1))
        ]
        interventions = intervention_records(
            provenance=self.provenance, manifest=self.manifest
        )
        mutated = copy.deepcopy(interventions)
        mutated[0]["intervention_payload"]["value"]["index"] = "first"
        with self.assertRaises((SemanticVerificationError, ValueError)):
            verify_intervention_matrix(
                mutated, manifest=self.manifest, natural_records=naturals
            )

        mutated = copy.deepcopy(interventions)
        mutated[-1]["natural_trace_hash"] = "1" * 64
        with self.assertRaises((SemanticVerificationError, ValueError)):
            verify_intervention_matrix(
                mutated, manifest=self.manifest, natural_records=naturals
            )

    def test_conformance_comparator_rejects_one_token_difference(self) -> None:
        rows = python_conformance_rows()
        report = compare_rows(copy.deepcopy(rows), rows)
        self.assertEqual(report["rows"], 126)
        mutated = copy.deepcopy(rows)
        mutated[73][-1] += 1
        with self.assertRaisesRegex(ValueError, "conformance mismatch at row 73"):
            compare_rows(mutated, rows)

        mutated = copy.deepcopy(rows)
        mutated[-1][-1] += 1
        with self.assertRaisesRegex(ValueError, "conformance mismatch at row 125"):
            compare_rows(mutated, rows)


if __name__ == "__main__":
    unittest.main()
