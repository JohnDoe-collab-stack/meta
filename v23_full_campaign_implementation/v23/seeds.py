"""Domain-separated deterministic seed derivation."""

from __future__ import annotations

import hashlib
import random

import numpy as np


def derive_seed(root_seed: int, label: str, ordinal: int = 0) -> int:
    if root_seed < 0 or ordinal < 0:
        raise ValueError("seeds and ordinals must be non-negative")
    encoded = label.encode("utf-8")
    message = (
        len(encoded).to_bytes(4, "big")
        + encoded
        + root_seed.to_bytes(16, "big", signed=False)
        + ordinal.to_bytes(16, "big", signed=False)
    )
    return int.from_bytes(hashlib.sha256(message).digest()[:8], "big")


def python_rng(root_seed: int, label: str, ordinal: int = 0) -> random.Random:
    return random.Random(derive_seed(root_seed, label, ordinal))


def numpy_rng(root_seed: int, label: str, ordinal: int = 0) -> np.random.Generator:
    return np.random.Generator(np.random.PCG64(derive_seed(root_seed, label, ordinal)))


def torch_seed(root_seed: int, label: str, ordinal: int = 0) -> int:
    return derive_seed(root_seed, label, ordinal) % (2**63 - 1)
