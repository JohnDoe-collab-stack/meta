#!/usr/bin/env python3
"""Exhaustive and adversarial tests for the v23 certifiable agent."""

from __future__ import annotations

import copy
import hashlib
import json
import unittest
from pathlib import Path

from certifiable_agent_v23 import (
    HEAD_INPUT_DIMS,
    HEAD_ORDER,
    HEAD_OUTPUT_DIMS,
    certification_examples,
    checkpoint_from_dict,
    encode_agent_state,
    round_ties_to_even,
)
from finite_reference_domain_v23 import ALL_WORLDS, all_reachable_states
from train_certifiable_agent_v23 import QUANTIZATION_POWERS, train_first_admissible
from export_quantized_agent_v23 import lean_modules
from verify_quantized_inference_v23 import verify_checkpoint


ROOT = Path(__file__).resolve().parent
REPOSITORY = ROOT.parents[1]
CHECKPOINT = ROOT / "artifacts" / "development" / "quantized_checkpoint_v23.json"


class CertifiableAgentTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.value = json.loads(CHECKPOINT.read_text(encoding="utf-8"))

    def test_visible_encoding_is_binary_fixed_and_world_free(self) -> None:
        encoded_states = 0
        for state in all_reachable_states():
            encoded = encode_agent_state(state.agent)
            self.assertEqual(len(encoded), 96)
            self.assertEqual(set(encoded) - {0, 1}, set())
            self.assertEqual(encoded[-38:], (0,) * 38)
            encoded_states += 1
        self.assertEqual(encoded_states, 99)
        self.assertEqual(len(ALL_WORLDS), 27)

    def test_exhaustive_typed_table_has_the_frozen_geometry(self) -> None:
        examples = certification_examples()
        self.assertEqual(tuple(examples), HEAD_ORDER)
        self.assertEqual(
            {name: len(rows) for name, rows in examples.items()},
            {"gap": 15, "use": 22, "transport": 44, "query": 88, "repair": 528},
        )
        self.assertEqual(sum(map(len, examples.values())), 697)
        for name, rows in examples.items():
            self.assertTrue(rows)
            self.assertTrue(all(len(row.features) == HEAD_INPUT_DIMS[name] for row in rows))
            self.assertTrue(all(0 <= row.target < HEAD_OUTPUT_DIMS[name] for row in rows))
            self.assertEqual(len({(row.features, row.target) for row in rows}), len(rows))

    def test_ties_to_even_is_signed_and_exact(self) -> None:
        cases = {
            (1, 1): 0,
            (3, 1): 2,
            (5, 1): 2,
            (7, 1): 4,
            (-1, 1): 0,
            (-3, 1): -2,
            (-5, 1): -2,
            (-7, 1): -4,
        }
        for arguments, expected in cases.items():
            with self.subTest(arguments=arguments):
                self.assertEqual(round_ties_to_even(*arguments), expected)

    def test_checkpoint_is_exact_zero_error_and_strict(self) -> None:
        report = verify_checkpoint(self.value)
        self.assertTrue(report["valid"])
        self.assertEqual(report["errors"], 0)
        self.assertEqual(report["examples"], 697)
        self.assertGreater(report["minimum_integer_margin"], 0)
        self.assertEqual((report["seed"], report["update"]), (0, 156))

    def test_architecture_and_quantization_are_frozen(self) -> None:
        checkpoint = checkpoint_from_dict(self.value)
        self.assertEqual(
            QUANTIZATION_POWERS,
            {
                "gap": (2, 7),
                "use": (2, 7),
                "transport": (4, 5),
                "query": (2, 5),
                "repair": (6, 4),
            },
        )
        for name in HEAD_ORDER:
            head = checkpoint.heads[name]
            self.assertEqual(head.input_dim, HEAD_INPUT_DIMS[name])
            self.assertEqual(head.output_dim, HEAD_OUTPUT_DIMS[name])
            self.assertEqual(head.output_shift, QUANTIZATION_POWERS[name][0])

    def test_catalogue_or_parameter_mutation_is_rejected(self) -> None:
        widened = copy.deepcopy(self.value)
        widened["heads"]["gap"]["valid_classes"].append(30)
        with self.assertRaisesRegex(ValueError, "exact prescribed catalogue"):
            verify_checkpoint(widened)

        malformed = copy.deepcopy(self.value)
        malformed["heads"]["repair"]["output_bias"][0] = 128
        with self.assertRaisesRegex(ValueError, "outside Int8"):
            verify_checkpoint(malformed)

    def test_training_replay_returns_the_first_admissible_checkpoint(self) -> None:
        replayed = train_first_admissible(seeds=(0,), maximum_updates=156)
        expected = checkpoint_from_dict(self.value)
        self.assertEqual(replayed.checkpoint, expected)
        with self.assertRaisesRegex(RuntimeError, "no admissible"):
            train_first_admissible(seeds=(0,), maximum_updates=155)

    def test_checkpoint_parser_rejects_noncanonical_shape(self) -> None:
        malformed = copy.deepcopy(self.value)
        malformed["unexpected"] = True
        with self.assertRaisesRegex(ValueError, "top-level schema"):
            checkpoint_from_dict(malformed)

        bad_order = copy.deepcopy(self.value)
        bad_order["update"] = 0
        with self.assertRaisesRegex(ValueError, "training order"):
            checkpoint_from_dict(bad_order)

    def test_tracked_lean_module_is_the_exact_export(self) -> None:
        checkpoint_hash = hashlib.sha256(CHECKPOINT.read_bytes()).hexdigest()
        expected = lean_modules(CHECKPOINT, checkpoint_hash, self.value)
        for filename, contents in expected.items():
            with self.subTest(filename=filename):
                actual = (REPOSITORY / "Meta" / "AI" / filename).read_text(
                    encoding="utf-8"
                )
                self.assertEqual(actual, contents)


if __name__ == "__main__":
    unittest.main()
