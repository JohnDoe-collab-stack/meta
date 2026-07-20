"""Closed-world domains used by the campaign."""

from .finite import FiniteReferenceDomain
from .perceptual import PerceptualDomain
from .symbolic import SymbolicDomain

__all__ = ["FiniteReferenceDomain", "PerceptualDomain", "SymbolicDomain"]
