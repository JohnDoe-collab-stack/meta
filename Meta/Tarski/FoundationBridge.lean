import Meta.Tarski.TruthGap
import Foundation.FirstOrder.Incompleteness.Tarski

/-!
# Foundation Tarski bridge

This file exposes the official `Foundation` arithmetic Tarski statement inside
the local meta layer.
-/

namespace Meta
namespace ClosedStabilityTheorem

open LO.FirstOrder
open LO.FirstOrder.Arithmetic

/-- The official Foundation Tarski truth-undefinability statement. -/
abbrev FoundationProjectiveTarskiStatement : Prop :=
  ¬∃ tau : Semisentence ℒₒᵣ 1,
    ∀ sentence : Sentence ℒₒᵣ,
      Nat ⊧ₘ sentence ↔ Nat ⊧ₘ tau/[⌜sentence⌝]

/--
The local name is definitionally the displayed Foundation arithmetic shape.
-/
theorem foundationProjectiveTarskiStatement_iff_officialShape :
    FoundationProjectiveTarskiStatement ↔
      (¬∃ tau : Semisentence ℒₒᵣ 1,
        ∀ sentence : Sentence ℒₒᵣ,
          Nat ⊧ₘ sentence ↔ Nat ⊧ₘ tau/[⌜sentence⌝]) := by
  rfl

/-- The Foundation-shaped Tarski statement supplied by the Foundation package. -/
theorem foundationProjectiveTarskiStatement_from_official :
    FoundationProjectiveTarskiStatement :=
  LO.FirstOrder.Arithmetic.undefinability_of_truth

/-- Compatibility name for the local meta layer. -/
theorem foundationProjectiveTarskiStatement_from_projectiveGap
    : FoundationProjectiveTarskiStatement :=
  foundationProjectiveTarskiStatement_from_official

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.FoundationProjectiveTarskiStatement
#print axioms Meta.ClosedStabilityTheorem.foundationProjectiveTarskiStatement_iff_officialShape
#print axioms Meta.ClosedStabilityTheorem.foundationProjectiveTarskiStatement_from_official
#print axioms Meta.ClosedStabilityTheorem.foundationProjectiveTarskiStatement_from_projectiveGap
/- AXIOM_AUDIT_END -/
