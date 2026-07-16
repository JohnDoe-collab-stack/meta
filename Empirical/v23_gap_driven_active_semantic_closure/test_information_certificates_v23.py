#!/usr/bin/env python3
"""Adversarial tests for exact Level-A information/no-go certificates."""

from __future__ import annotations

import copy
import unittest

from certify_information_v23 import build_certificate as build_information
from certify_visible_factored_nogo_v23 import build_certificate as build_factored
from verify_information_v23 import verify_certificate as verify_information
from verify_visible_factored_nogo_v23 import verify_certificate as verify_factored


class InformationCertificateTests(unittest.TestCase):
    def test_information_certificate_is_recomputed(self) -> None:
        report = verify_information(build_information())
        self.assertEqual(report["active_leaves"], 27)
        self.assertEqual(report["transcript_capacity_bits"], 5)

    def test_information_mutations_fail(self) -> None:
        mutations = (
            lambda value: value["passive_no_go"].__setitem__("candidate_count", 63),
            lambda value: value["passive_no_go"].__setitem__("deterministic_average_optimum", "1"),
            lambda value: value["passive_no_go"]["resource_grid"].pop(),
            lambda value: value["active_sufficiency"].__setitem__("leaves", 26),
            lambda value: value["active_sufficiency"].__setitem__("transcripts_sha256", "1" * 64),
            lambda value: value["composition"].__setitem__("every_step_strictly_reduces_fiber", False),
        )
        for mutate in mutations:
            with self.subTest(mutation=repr(mutate)):
                value = copy.deepcopy(build_information())
                mutate(value)
                with self.assertRaises(ValueError):
                    verify_information(value)

    def test_visible_factored_certificate_is_recomputed(self) -> None:
        report = verify_factored(build_factored())
        self.assertEqual(report["action_count"], 30)
        self.assertEqual(report["controller_count"], 900)

    def test_visible_factored_mutations_fail(self) -> None:
        mutations = (
            lambda value: value["exact_finite_class"].__setitem__("action_count", 29),
            lambda value: value["exact_finite_class"].__setitem__("best_average", "1"),
            lambda value: value["exact_finite_class"].__setitem__("enumeration_sha256", "2" * 64),
            lambda value: value["randomized_optimum"].__setitem__("guaranteed_worst_case_optimum", "1"),
            lambda value: value["active_full_state_comparator"].__setitem__("closes_both", False),
        )
        for mutate in mutations:
            with self.subTest(mutation=repr(mutate)):
                value = copy.deepcopy(build_factored())
                mutate(value)
                with self.assertRaises(ValueError):
                    verify_factored(value)


if __name__ == "__main__":
    unittest.main()
