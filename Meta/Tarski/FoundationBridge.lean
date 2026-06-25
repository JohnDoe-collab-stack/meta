import Meta.Tarski.TruthGap
import Foundation.FirstOrder.Bootstrapping.FixedPoint

/-!
# External Foundation bridge for Tarski

This file records the Lean-checked bridge from the internal projective Tarski
corollary to the arithmetic Tarski statement in the `Foundation` language.

It is intentionally separate from the clean internal kernel: the imported
`Foundation` syntax, quotation, fixed-point, and semantic infrastructure audit
with classical dependencies in `Foundation` itself.  The purpose of this file
is therefore exact external instantiation, not admission into the constructive
core.

Important: this file does not use
`LO.FirstOrder.Arithmetic.undefinability_of_truth`.  It derives the same
arithmetic shape by instantiating
`ArithmeticTarskiContext.undefinability_of_truth_via_projective_corollary`
with `Foundation`'s quotation and diagonal fixed-point machinery.
-/

namespace Meta
namespace ClosedStabilityTheorem

open _root_.LO.FirstOrder.Arithmetic

/-- The official Foundation Tarski statement, written as a local projective target. -/
abbrev FoundationProjectiveTarskiStatement : Prop :=
  ¬∃ tau : LO.FirstOrder.Semisentence ℒₒᵣ 1,
    ∀ sentence : LO.FirstOrder.Sentence ℒₒᵣ,
      ℕ ⊧ₘ sentence ↔ ℕ ⊧ₘ tau/[⌜sentence⌝]

/--
The locally named projective statement is definitionally the same proposition
as the official displayed Foundation shape.
-/
theorem foundationProjectiveTarskiStatement_iff_officialShape :
    FoundationProjectiveTarskiStatement ↔
      (¬∃ tau : LO.FirstOrder.Semisentence ℒₒᵣ 1,
        ∀ sentence : LO.FirstOrder.Sentence ℒₒᵣ,
          ℕ ⊧ₘ sentence ↔ ℕ ⊧ₘ tau/[⌜sentence⌝]) := by
  rfl

/--
The Foundation-shaped Tarski statement derived from the internal projective
gap corollary.

This is the direction needed for the bridge: Foundation supplies the arithmetic
fixed point and semantic transport, then the projective corollary supplies the
undefinability result.
-/
theorem foundationProjectiveTarskiStatement_from_projectiveGap :
    FoundationProjectiveTarskiStatement :=
  ArithmeticTarskiContext.undefinability_of_truth_via_projective_corollary
    { Sentence := LO.FirstOrder.Sentence ℒₒᵣ
      Predicate := LO.FirstOrder.Semisentence ℒₒᵣ 1
      applyQuote := fun tau sentence => tau/[⌜sentence⌝]
      models := fun sentence => ℕ ⊧ₘ sentence
      diagonal := fun tau => fixedpoint (∼tau)
      diagonal_spec := by
        intro tau
        have hDiagonal :
            ℕ ⊧ₘ fixedpoint (∼tau) 🡘
              (∼tau)/[⌜fixedpoint (∼tau)⌝] :=
          TA.provable_iff.mp
            (diagonal (T := 𝗧𝗔) (∼tau))
        simpa using hDiagonal }

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.FoundationProjectiveTarskiStatement
#print axioms Meta.ClosedStabilityTheorem.foundationProjectiveTarskiStatement_iff_officialShape
#print axioms Meta.ClosedStabilityTheorem.foundationProjectiveTarskiStatement_from_projectiveGap
/- AXIOM_AUDIT_END -/
