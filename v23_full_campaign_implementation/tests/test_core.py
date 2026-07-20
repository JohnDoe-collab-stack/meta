from __future__ import annotations

import dataclasses
import json
import tempfile
import unittest
from pathlib import Path

import numpy as np
import torch

from v23.audit import audit_all_gates
from v23.campaign import evaluation_matrix, final_training_matrix, tuning_matrix
from v23.canonical import CanonicalizationError, canonical_json, content_sha256
from v23.domains import FiniteReferenceDomain, PerceptualDomain, SymbolicDomain
from v23.domains.perceptual import PALETTE, SceneObject, render_scene
from v23.domains.symbolic import branch_program
from v23.falsification import run_mutation_suite
from v23.fairness import parameter_fairness_report
from v23.information_flow import static_information_flow_audit
from v23.interventions import CAUSAL_ORDER, INTERVENTIONS
from v23.models import CausalAgent, masked_argmax
from v23.ood import open_records, seal_records
from v23.quantized import canonical_argmax_int32, int8_linear, quantized_linear_certificate
from v23.reference_agent import ExactActiveAgent, action_conflict_pairs
from v23.seeds import derive_seed
from v23.statistics import exact_sign_flip_pvalue, hierarchical_paired_bootstrap, holm_adjust
from v23.training import leave_one_out_reinforce_loss
from v23.verification import verify_trace


class CanonicalTests(unittest.TestCase):
    def test_canonical_key_order_and_float_refusal(self) -> None:
        self.assertEqual(canonical_json({"b": 2, "a": 1}), '{"a":1,"b":2}')
        with self.assertRaises(CanonicalizationError):
            canonical_json({"forbidden": 0.5})

    def test_seed_domain_separation(self) -> None:
        first = derive_seed(23, "domain-a", 0)
        self.assertEqual(first, derive_seed(23, "domain-a", 0))
        self.assertNotEqual(first, derive_seed(23, "domain-b", 0))
        self.assertNotEqual(first, derive_seed(23, "domain-a", 1))


class DomainTests(unittest.TestCase):
    def test_all_closed_family_contracts(self) -> None:
        for domain in (FiniteReferenceDomain(), SymbolicDomain(), PerceptualDomain()):
            for actual_index in (0, 7, 8, 19, 31):
                episode = domain.generate_episode(123, actual_index)
                episode.validate_closed_family()
                fiber = domain.initial_fiber(episode)
                self.assertEqual(len(fiber), 8)
                self.assertGreater(action_conflict_pairs(episode, fiber), 0)

    def test_symbolic_differential_interpreter(self) -> None:
        domain = SymbolicDomain()
        for zero_value in range(8):
            for offset in range(4):
                program = branch_program(zero_value, offset)
                for input_value in range(-3, 10):
                    self.assertEqual(
                        program.evaluate(input_value),
                        domain.independent_evaluate(program.to_tokens(), input_value),
                    )

    def test_integer_renderer_occlusion(self) -> None:
        back = SceneObject("a", "square", "red", 2, 2, 0)
        front = SceneObject("b", "square", "blue", 2, 2, 1)
        pixels = render_scene((front, back))
        self.assertEqual(pixels.dtype, np.uint8)
        self.assertEqual(tuple(pixels[16, 16]), PALETTE["blue"])
        self.assertEqual(content_sha256(pixels.tolist()), content_sha256(render_scene((back, front)).tolist()))


class ExactAgentTests(unittest.TestCase):
    def test_exact_policy_and_semantic_verifier(self) -> None:
        agent = ExactActiveAgent()
        for domain in (FiniteReferenceDomain(), SymbolicDomain(), PerceptualDomain()):
            episode = domain.generate_episode(456, 7)
            trace = agent.run(domain, episode, 456)
            self.assertTrue(trace.closed)
            verify_trace(trace, episode, domain)
            self.assertLess(
                action_conflict_pairs(episode, trace.final_fiber),
                action_conflict_pairs(episode, trace.initial_fiber),
            )

    def test_every_registered_mutation_is_rejected(self) -> None:
        domain = PerceptualDomain()
        episode = domain.generate_episode(789, 6)
        trace = ExactActiveAgent().run(domain, episode, 789)
        result = run_mutation_suite(trace, episode, domain)
        self.assertTrue(result["all_rejected"], result)
        self.assertEqual(result["mutation_count"], 17)


class LearnedArchitectureTests(unittest.TestCase):
    def test_masked_argmax_is_typed_and_canonical(self) -> None:
        logits = torch.tensor([[2.0, 2.0, 100.0]])
        mask = torch.tensor([[True, True, False]])
        self.assertEqual(int(masked_argmax(logits, mask)), 0)
        with self.assertRaises(ValueError):
            masked_argmax(logits, torch.zeros_like(mask, dtype=torch.bool))

    def test_b13_has_no_bypass(self) -> None:
        model = CausalAgent(size="small", vocab_size=259, dropout=0.0, system_id="B13")
        self.assertEqual(model.forbidden_bypass_audit(), ())
        self.assertTrue(static_information_flow_audit(model)["ok"])

    def test_leave_one_out_estimator(self) -> None:
        log_prob = torch.tensor([[-0.1, -0.2, -0.3], [-0.4, -0.5, -0.6]], requires_grad=True)
        rewards = torch.tensor([[1.0, 0.0, 0.0], [0.0, 1.0, 0.0]])
        loss = leave_one_out_reinforce_loss(log_prob, rewards)
        self.assertTrue(torch.isfinite(loss))
        loss.backward()
        self.assertIsNotNone(log_prob.grad)

    def test_int8_int32_reference_is_exact(self) -> None:
        inputs = np.asarray([[1, -2, 3]], dtype=np.int8)
        weights = np.asarray([[4, 5, -6], [-1, 2, 3]], dtype=np.int8)
        output = int8_linear(inputs, weights)
        self.assertEqual(output.dtype, np.int32)
        self.assertEqual(output.tolist(), [[-24, 4]])
        chosen = canonical_argmax_int32(output, np.asarray([[True, True]], dtype=np.bool_))
        self.assertEqual(chosen.tolist(), [1])
        certificate = quantized_linear_certificate(
            torch.tensor([[0.1, -0.2, 0.3]]),
            torch.tensor([[0.4, 0.5, -0.6], [-0.1, 0.2, 0.3]]),
        )
        self.assertEqual(len(certificate["certificate_sha256"]), 64)


class StatisticsAndSecurityTests(unittest.TestCase):
    def test_exact_signs_holm_and_bootstrap(self) -> None:
        self.assertAlmostEqual(exact_sign_flip_pvalue([1.0] * 10), 1 / 1024)
        adjusted = holm_adjust({"a": 0.01, "b": 0.04, "c": 0.5})
        self.assertEqual(adjusted, {"a": 0.03, "b": 0.08, "c": 0.5})
        data = {seed: [0.2, 0.3] for seed in range(10)}
        first = hierarchical_paired_bootstrap(data, repetitions=100, root_seed=5)
        second = hierarchical_paired_bootstrap(data, repetitions=100, root_seed=5)
        self.assertEqual(first, second)

    def test_ood_authentication_and_nonce_uniqueness(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary) / "sealed"
            manifest = seal_records(
                ({"id": index} for index in range(8)),
                root,
                bytes(range(32)),
                {"family": "unit"},
                record_count=8,
            )
            self.assertTrue(manifest["nonce_unique"])
            self.assertEqual(len(open_records(root, bytes(range(32)))), 8)
            with self.assertRaises(Exception):
                open_records(root, bytes(reversed(range(32))))


class OrchestrationTests(unittest.TestCase):
    def test_complete_matrix_sizes(self) -> None:
        self.assertEqual(len(final_training_matrix()), 2 * 13 * 3 * 3 * 10)
        self.assertEqual(len(tuning_matrix()), 2 * 13 * 3 * 3 * 12 * 3)
        self.assertEqual(len(evaluation_matrix()), 2 * 13 * 3 * 3 * 10 * 6)

    def test_all_interventions_partition_the_dag(self) -> None:
        self.assertEqual(len(INTERVENTIONS), 18)
        for intervention in INTERVENTIONS.values():
            self.assertEqual(
                intervention.fixed_variables + intervention.recomputed_variables,
                CAUSAL_ORDER,
            )

    def test_missing_gate_evidence_is_not_pass(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            report = audit_all_gates(temporary)
        self.assertFalse(report["all_pass"])
        self.assertTrue(report["has_not_run"])

    def test_fairness_audit_never_silently_accepts_mismatch(self) -> None:
        report = parameter_fairness_report("small", "symbolic")
        self.assertEqual(set(report["rows"]), {f"B{index}" for index in range(1, 14)})
        for row in report["rows"].values():
            if row["pre_registered_principal"] and not row["within_five_percent"]:
                self.assertTrue(row["resource_curve_required"])
                self.assertFalse(row["principal_contrast_eligible"])


if __name__ == "__main__":
    unittest.main()
