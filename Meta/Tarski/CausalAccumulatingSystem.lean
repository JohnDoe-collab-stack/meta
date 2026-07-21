import Meta.Core.CausalAdditive
import Meta.Tarski.CausalOrbit

/-!
# Accumulating causal system intrinsic to patchable Tarski repair

This module exposes the Tarski causal state as an accumulating causal system
before any comparison with `Nat`.  The three memory laws are derived from the
intrinsic causal memory and are not supplied as external assumptions.
-/

namespace Meta
namespace ClosedStabilityTheorem
namespace PatchableArithmeticTarskiContext

universe u v

/-- The causal state before any Tarski repair. -/
def initialCausalState
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    CausalState patchable initial where
  current := initial
  memory := CausalMemory.root

/-- Every patchable Tarski context intrinsically supplies the three laws of an
accumulating causal system. -/
def tarskiAccumulatingCausalSystem
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    CausalAdditive.AccumulatingCausalSystem
      (CausalState patchable initial)
      patchable.context.Sentence where
  gap := fun state => patchable.diagonalSentence state.current
  Memory := fun state sentence =>
    CausalMemory.Remembers patchable initial state.memory sentence
  advance := CausalState.advance patchable initial
  gap_absent := by
    intro state
    exact CausalState.currentGap_not_remembered patchable initial state
  gap_inscribed := by
    intro state
    exact CausalState.advance_remembers_current_gap patchable initial state
  memory_preserved := by
    intro state sentence remembered
    exact
      CausalState.advance_remembers_previous
        patchable initial state remembered

end PatchableArithmeticTarskiContext
end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.initialCausalState
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.tarskiAccumulatingCausalSystem
/- AXIOM_AUDIT_END -/
