import Meta.Bell.ContextAmalgamation
import Meta.Core.ReferentialLength

/-!
# Bell amalgamation gap

This file connects the Bell pre-probabilistic layer to the transverse
referential-length vocabulary.

The classical Bell regime is a short co-indexation obtained by amalgamating
four local contexts into one global assignment.  In that regime, the pointwise
and classical CHSH bounds follow.  An amalgamation obstruction is the
pre-probabilistic failure of that short co-indexation for the specified family
of local contexts.
-/

namespace Meta
namespace ClosedStabilityTheorem

/-! ## Bell short co-indexation from amalgamation -/

/--
A Bell short co-indexation of local contexts is precisely an amalgamation of
those contexts into one global assignment.
-/
abbrev BellShortCoindexationOfContexts
    (contexts : BellFourContextAssignments) :
    Type :=
  BellContextAmalgamation contexts

/-- A Bell amalgamation exposes the global short co-indexation it carries. -/
def bellShortCoindexation_of_amalgamation
    {contexts : BellFourContextAssignments}
    (amalgamation : BellShortCoindexationOfContexts contexts) :
    BellShortCoindexation :=
  shortCoindexationOfAmalgamation amalgamation

/-- A compatible four-context family admits a short co-indexation. -/
def bellShortCoindexation_of_compatibility
    (contexts : BellFourContextAssignments)
    (compatibility : BellAmalgamationCompatibility contexts) :
    BellShortCoindexationOfContexts contexts :=
  amalgamationOfCompatibleContexts contexts compatibility

/-- Bell short co-indexation exists exactly when the local contexts are compatible. -/
theorem bellShortCoindexation_iff_compatibility
    (contexts : BellFourContextAssignments) :
    Nonempty (BellShortCoindexationOfContexts contexts) ↔
      Nonempty (BellAmalgamationCompatibility contexts) :=
  bellAmalgamation_iff_compatibility contexts

/-- A Bell short co-indexation of contexts gives the exact pointwise CHSH bound. -/
theorem bellPointwiseCHSHBound_of_shortCoindexedContexts
    {contexts : BellFourContextAssignments}
    (amalgamation : BellShortCoindexationOfContexts contexts) :
    BellPointwiseCHSHBound
      (bellShortCoindexation_of_amalgamation amalgamation) :=
  bellPointwiseCHSHBound_of_amalgamation amalgamation

/-- A Bell short co-indexation of contexts gives the standard classical CHSH bound. -/
theorem bellClassicalBound_of_shortCoindexedContexts
    {contexts : BellFourContextAssignments}
    (amalgamation : BellShortCoindexationOfContexts contexts) :
    BellGlobalAssignment.BellClassicalBound
      (bellShortCoindexation_of_amalgamation amalgamation) :=
  bellClassicalBound_of_amalgamation amalgamation

/-! ## Bell amalgamation obstruction -/

/--
A Bell amalgamation gap is the pre-probabilistic failure of short
co-indexation for a specified four-context family.
-/
abbrev BellAmalgamationGap
    (contexts : BellFourContextAssignments) :
    Prop :=
  BellContextAmalgamationObstruction contexts

/-- An amalgamation gap refutes short co-indexation of those contexts. -/
theorem bellAmalgamationGap_refutes_shortCoindexation
    {contexts : BellFourContextAssignments}
    (gap : BellAmalgamationGap contexts)
    (short :
      BellShortCoindexationOfContexts contexts) :
    False :=
  gap short

/-- An amalgamation gap refutes the existence of short co-indexation. -/
theorem bellAmalgamationGap_refutes_shortCoindexation_nonempty
    {contexts : BellFourContextAssignments}
    (gap : BellAmalgamationGap contexts)
    (short :
      Nonempty (BellShortCoindexationOfContexts contexts)) :
    False := by
  cases short with
  | intro amalgamation =>
      exact bellAmalgamationGap_refutes_shortCoindexation gap amalgamation

/-- A mismatch of the shared `A0` reading gives a Bell amalgamation gap. -/
def bellAmalgamationGap_of_A0_mismatch
    (contexts : BellFourContextAssignments)
    (mismatch :
      contexts.context00.alice = contexts.context01.alice -> False) :
    BellAmalgamationGap contexts :=
  noAmalgamation_of_A0_mismatch contexts mismatch

/-- A mismatch of the shared `A1` reading gives a Bell amalgamation gap. -/
def bellAmalgamationGap_of_A1_mismatch
    (contexts : BellFourContextAssignments)
    (mismatch :
      contexts.context10.alice = contexts.context11.alice -> False) :
    BellAmalgamationGap contexts :=
  noAmalgamation_of_A1_mismatch contexts mismatch

/-- A mismatch of the shared `B0` reading gives a Bell amalgamation gap. -/
def bellAmalgamationGap_of_B0_mismatch
    (contexts : BellFourContextAssignments)
    (mismatch :
      contexts.context00.bob = contexts.context10.bob -> False) :
    BellAmalgamationGap contexts :=
  noAmalgamation_of_B0_mismatch contexts mismatch

/-- A mismatch of the shared `B1` reading gives a Bell amalgamation gap. -/
def bellAmalgamationGap_of_B1_mismatch
    (contexts : BellFourContextAssignments)
    (mismatch :
      contexts.context01.bob = contexts.context11.bob -> False) :
    BellAmalgamationGap contexts :=
  noAmalgamation_of_B1_mismatch contexts mismatch

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.BellShortCoindexationOfContexts
#print axioms Meta.ClosedStabilityTheorem.bellShortCoindexation_of_amalgamation
#print axioms Meta.ClosedStabilityTheorem.bellShortCoindexation_of_compatibility
#print axioms Meta.ClosedStabilityTheorem.bellShortCoindexation_iff_compatibility
#print axioms Meta.ClosedStabilityTheorem.bellPointwiseCHSHBound_of_shortCoindexedContexts
#print axioms Meta.ClosedStabilityTheorem.bellClassicalBound_of_shortCoindexedContexts
#print axioms Meta.ClosedStabilityTheorem.BellAmalgamationGap
#print axioms Meta.ClosedStabilityTheorem.bellAmalgamationGap_refutes_shortCoindexation
#print axioms Meta.ClosedStabilityTheorem.bellAmalgamationGap_refutes_shortCoindexation_nonempty
#print axioms Meta.ClosedStabilityTheorem.bellAmalgamationGap_of_A0_mismatch
#print axioms Meta.ClosedStabilityTheorem.bellAmalgamationGap_of_A1_mismatch
#print axioms Meta.ClosedStabilityTheorem.bellAmalgamationGap_of_B0_mismatch
#print axioms Meta.ClosedStabilityTheorem.bellAmalgamationGap_of_B1_mismatch
/- AXIOM_AUDIT_END -/
