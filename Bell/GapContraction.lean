import LocalSemanticClosure.Standalone.Clean.meta.Bell.Coindexation
import LocalSemanticClosure.Standalone.Clean.meta.Tarski.GapContraction

/-!
# Bell gap contraction

This file is the gap-reading layer for the deterministic CHSH core.

`BellCoindexation` proves the pre-probabilistic pointwise fact:

```text
one global assignment of A0, A1, B0, B1
→ CHSH value is -2 or 2
```

Here that global assignment is named as the short co-indexed regime.  A
contextual gap is not used to claim any probabilistic or physical violation;
it only names, in the shared projection vocabulary, the failure of a
contractible visible-to-interface reading.
-/

namespace LocalSemanticClosure
namespace Standalone
namespace Clean
namespace ClosedStabilityTheorem

universe u v s

/-! ## Short co-indexation -/

/-- A short Bell co-indexation is one global assignment of all four values. -/
abbrev BellShortCoindexation :
    Type :=
  BellGlobalAssignment

/-- Pointwise CHSH boundedness in the short co-indexed regime. -/
abbrev BellPointwiseCHSHBound
    (assignment : BellShortCoindexation) :
    Prop :=
  assignment.chshValue = -2 ∨ assignment.chshValue = 2

/--
The short co-indexed regime forces the pointwise CHSH bound.

This is the algebraic core before probabilistic averaging.
-/
theorem bellPointwiseCHSHBound_of_shortCoindexation
    (assignment : BellShortCoindexation) :
    BellPointwiseCHSHBound assignment :=
  assignment.chshValue_eq_neg_two_or_two

/-! ## Contextual gap vocabulary -/

/--
A structural Bell contextual gap.

This is the projective vocabulary for saying that a visible context does not
determine a unique enriched measurement interface.
-/
abbrev BellContextualStructuralGap
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Type (max u v) :=
  StructuralReferentialGap Interface Visible project

/--
An operational Bell contextual gap.

This strengthens a structural contextual gap with a local repair package
indexed by the formed interface.
-/
abbrev BellContextualOperationalGap
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max u v s) :=
  OperationalReferentialGap Interface Visible project RepairOf

/-- An operational contextual gap exposes its structural contextual gap. -/
def structuralGapOfBellOperationalGap
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      BellContextualOperationalGap Interface Visible project RepairOf) :
    BellContextualStructuralGap Interface Visible project :=
  structuralGapOfOperationalGap gap

/-- A structural contextual gap refutes contractibility of its visible fiber. -/
theorem bellContextualStructuralGap_not_contractible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (gap :
      BellContextualStructuralGap Interface Visible project)
    (contractible :
      ContractibleReferentialGap Interface Visible project) :
    False :=
  structuralGap_not_contractible gap contractible

/-- An operational contextual gap refutes contractibility of its visible fiber. -/
theorem bellContextualOperationalGap_not_contractible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      BellContextualOperationalGap Interface Visible project RepairOf)
    (contractible :
      ContractibleReferentialGap Interface Visible project) :
    False :=
  operationalGap_not_contractible gap contractible

end ClosedStabilityTheorem
end Clean
end Standalone
end LocalSemanticClosure

/- AXIOM_AUDIT_BEGIN -/
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellShortCoindexation
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellPointwiseCHSHBound
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.bellPointwiseCHSHBound_of_shortCoindexation
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellContextualStructuralGap
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellContextualOperationalGap
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.structuralGapOfBellOperationalGap
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.bellContextualStructuralGap_not_contractible
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.bellContextualOperationalGap_not_contractible
/- AXIOM_AUDIT_END -/
