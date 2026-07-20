#!/usr/bin/env python3
"""Exact tests for the intrinsic semantic closure of the G3 certificate."""

from __future__ import annotations

import unittest
from pathlib import Path

from certify_quantized_semantic_alignment_v23 import (
    exported_examples,
    lean_modules,
    semantic_examples,
    semantic_permutation,
    semantic_references,
)


ROOT = Path(__file__).resolve().parent
REPOSITORY = ROOT.parents[1]
EXPECTED_COUNTS = {
    "gap": 15,
    "use": 22,
    "transport": 44,
    "query": 88,
    "repair": 528,
}


class QuantizedSemanticAlignmentTests(unittest.TestCase):
    def test_export_is_an_exact_semantic_permutation(self) -> None:
        semantic = semantic_examples()
        exported = exported_examples()
        permutation = semantic_permutation()

        self.assertEqual(len(semantic), 697)
        self.assertEqual(len(exported), 697)
        self.assertEqual(len(permutation), 697)
        self.assertEqual(tuple(sorted(permutation)), tuple(range(697)))
        self.assertEqual(
            tuple(exported[index] for index in range(697)),
            tuple(semantic[index] for index in permutation),
        )

    def test_semantic_references_cover_every_head_exactly(self) -> None:
        references = semantic_references()
        self.assertEqual(len(references), 697)
        for head, expected_count in EXPECTED_COUNTS.items():
            indices = tuple(index for name, index in references if name == head)
            self.assertEqual(len(indices), expected_count)
            self.assertEqual(tuple(sorted(indices)), tuple(range(expected_count)))

    def test_tracked_semantic_modules_are_the_exact_export(self) -> None:
        generated = lean_modules()
        self.assertEqual(len(generated), 90)
        for filename, expected in generated.items():
            with self.subTest(filename=filename):
                actual = (REPOSITORY / "Meta" / "AI" / filename).read_text(
                    encoding="utf-8"
                )
                self.assertEqual(actual, expected)


if __name__ == "__main__":
    unittest.main()
