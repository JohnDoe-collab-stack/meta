from __future__ import annotations

import unittest

import torch
from torch.distributions import Categorical

from v23.training_cuda_smoke_v2 import (
    _sample_on_cpu,
    deterministic_cuda_sampling,
)


class DeterministicCudaSamplingTests(unittest.TestCase):
    def test_cpu_adapter_preserves_categorical_sample_shape_and_seed(self) -> None:
        distribution = Categorical(
            logits=torch.tensor([[0.0, 1.0, 2.0], [2.0, 1.0, 0.0]])
        )
        torch.manual_seed(2301)
        first = _sample_on_cpu(distribution, torch.Size((7,)))
        torch.manual_seed(2301)
        second = _sample_on_cpu(distribution, torch.Size((7,)))
        self.assertEqual(first.shape, (7, 2))
        self.assertTrue(torch.equal(first, second))
        self.assertTrue(bool(((first >= 0) & (first < 3)).all()))

    def test_context_restores_original_categorical_sampler(self) -> None:
        original = Categorical.sample
        with deterministic_cuda_sampling():
            self.assertIsNot(Categorical.sample, original)
        self.assertIs(Categorical.sample, original)


if __name__ == "__main__":
    unittest.main()
