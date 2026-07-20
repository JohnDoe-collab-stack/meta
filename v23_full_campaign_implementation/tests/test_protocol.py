from __future__ import annotations

import dataclasses
import json
import tempfile
import unittest
from pathlib import Path

import torch

from v23.causality import certify_paired_causality
from v23.certifiable import CATALOG_CASES, build_int8_catalog_weights
from v23.domains import PerceptualDomain, SymbolicDomain
from v23.dynamics import certify_dynamics_payloads
from v23.encoding import BYTE_VOCAB_SIZE, encode_episode_batch
from v23.interventions import INTERVENTIONS
from v23.lean_export import render_trace_module
from v23.models import CATALOG_SIZES, CausalAgent
from v23.no_go import certify_information_layer
from v23.reference_agent import ExactActiveAgent
from v23.splits import OOD_FAMILIES, make_ood_episode, perceptual_ood_tensor
from v23.training import TrainConfig


class OODProtocolTests(unittest.TestCase):
    def test_every_ood_family_remains_closed_and_changes_the_fingerprint(self) -> None:
        for domain in (SymbolicDomain(), PerceptualDomain()):
            iid = domain.generate_episode(1234, 7)
            iid_fingerprint = iid.metadata.get("structural_fingerprint")
            seen = set()
            for family in OOD_FAMILIES:
                episode = make_ood_episode(domain, iid, family)
                episode.validate_closed_family()
                fingerprint = episode.metadata["structural_fingerprint"]
                self.assertNotEqual(fingerprint, iid_fingerprint)
                self.assertNotIn(fingerprint, seen)
                seen.add(fingerprint)

    def test_perceptual_ood_tensor_contracts(self) -> None:
        domain = PerceptualDomain()
        iid = domain.generate_episode(22, 2)
        expected_frames = {
            "OOD-composition": 3,
            "OOD-horizon": 16,
            "OOD-presentation": 2,
            "OOD-action-response": 2,
            "OOD-cross-family": 3,
        }
        for family, count in expected_frames.items():
            tensor = perceptual_ood_tensor(domain, make_ood_episode(domain, iid, family))
            self.assertEqual(tensor.shape, (count, 3, 64, 64))


class CausalAndDynamicTests(unittest.TestCase):
    def test_exact_trace_has_zero_structural_forgetting(self) -> None:
        domain = SymbolicDomain()
        episode = domain.generate_episode(77, 4)
        trace = ExactActiveAgent().run(domain, episode, 77)
        report = certify_dynamics_payloads([dataclasses.asdict(trace)])
        self.assertTrue(report["ok"], report)
        self.assertEqual(report["forgetting_events"], 0)

    def test_causal_certificate_refuses_incomplete_seed_coverage(self) -> None:
        spec = INTERVENTIONS["I_gap_suppress"]
        record = {
            "intervention_id": spec.intervention_id,
            "fixed_variables": spec.fixed_variables,
            "recomputed_variables": spec.recomputed_variables,
            "seed": 0,
            "control_score_micros": 1_000_000,
            "intervened_score_micros": 0,
        }
        report = certify_paired_causality(
            [record], expected_seeds=(0,), expected_episodes_per_seed=1
        )
        self.assertFalse(report["complete"])
        self.assertIn("I_query_neutral", report["missing_interventions"])

    def test_passive_no_go_and_active_sufficiency_are_computed(self) -> None:
        report = certify_information_layer(SymbolicDomain())
        self.assertTrue(report["ok"])
        self.assertTrue(report["passive_no_go"]["symbolic_impossibility"])
        self.assertEqual(report["active_sufficiency"]["closed"], 32)


class ArchitectureSeparationTests(unittest.TestCase):
    def test_b11_gap_intervention_cannot_reach_query(self) -> None:
        torch.manual_seed(2)
        model = CausalAgent(size="small", vocab_size=BYTE_VOCAB_SIZE, dropout=0.0, system_id="B11")
        model.eval()
        context = torch.randn(2, 64)
        masks = {
            name: torch.ones(2, size, dtype=torch.bool)
            for name, size in CATALOG_SIZES.items()
        }
        natural = model.decide_pre_response(context, masks)
        intervened = model.decide_pre_response(
            context, masks, intervention_id="I_gap_permute"
        )
        self.assertFalse(torch.equal(natural["gap"][1], intervened["gap"][1]))
        self.assertTrue(torch.equal(natural["query"][1], intervened["query"][1]))

    def test_b1_does_not_need_candidate_tokens(self) -> None:
        domain = SymbolicDomain()
        episode = domain.generate_episode(8, 0)
        encoded = encode_episode_batch(domain, [episode])
        model = CausalAgent(size="small", vocab_size=BYTE_VOCAB_SIZE, dropout=0.0, system_id="B1")
        broken_candidate = torch.full_like(encoded.candidate, BYTE_VOCAB_SIZE + 100)
        with torch.no_grad():
            context = model.encode_public(
                encoded.observation, broken_candidate, encoded.history, symbolic=True
            )
        self.assertEqual(tuple(context.shape), (1, 64))


class CertificationAndRunContractTests(unittest.TestCase):
    def test_generated_lean_has_one_final_audit(self) -> None:
        domain = PerceptualDomain()
        episode = domain.generate_episode(91, 5)
        trace = ExactActiveAgent().run(domain, episode, 91)
        source = render_trace_module(trace, 0)
        self.assertEqual(source.count("AXIOM_AUDIT_BEGIN"), 1)
        self.assertTrue(source.rstrip().endswith("/- AXIOM_AUDIT_END -/"))
        self.assertNotIn("sorry", source)
        self.assertNotIn("Classical", source)

    def test_int8_catalog_shape_is_fixed_at_697(self) -> None:
        cases = tuple(
            {
                "case_index": index,
                "target_index": index % 8,
            }
            for index in range(CATALOG_CASES)
        )
        weights = build_int8_catalog_weights(cases)
        self.assertEqual(weights.shape, (64, 697))
        self.assertEqual(str(weights.dtype), "int8")

    def test_final_training_contract_refuses_smoke_budget(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            manifest = Path(temporary) / "manifest.json"
            manifest.write_text(
                json.dumps(
                    {
                        "contains_ood": False,
                        "sealed_ood_key_access": False,
                        "structural_disjointness": {"ok": True},
                    }
                )
            )
            config = TrainConfig(
                domain="symbolic",
                system="B13",
                size="small",
                regime="R_causal",
                training_seed=0,
                output_directory=str(Path(temporary) / "new-run"),
                data_manifest=str(manifest),
                maximum_updates=1,
                batch_size=2,
                device="cpu",
                run_kind="final",
            )
            with self.assertRaises(ValueError):
                config.validate()


if __name__ == "__main__":
    unittest.main()
