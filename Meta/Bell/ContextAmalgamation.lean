import Meta.Bell.GapContraction

/-!
# Bell contextual amalgamation

This file isolates the pre-probabilistic amalgamation question behind the
short CHSH co-indexation.

Instead of starting from one global assignment, it starts from four local
measurement contexts:

```text
(A0, B0), (A0, B1), (A1, B0), (A1, B1)
```

The question is whether these four local contexts can be amalgamated into one
global assignment carrying `A0, A1, B0, B1`.  When they can, the pointwise CHSH
bound follows from `BellCoindexation`.
-/

namespace Meta
namespace ClosedStabilityTheorem

/-! ## Local contexts -/

/-- A local Bell context carries one Alice value and one Bob value. -/
structure BellLocalContextAssignment where
  alice : BellSign
  bob : BellSign

/-- The four local Bell contexts used in CHSH. -/
structure BellFourContextAssignments where
  context00 : BellLocalContextAssignment
  context01 : BellLocalContextAssignment
  context10 : BellLocalContextAssignment
  context11 : BellLocalContextAssignment

namespace BellGlobalAssignment

/-- The `(A0, B0)` context projected from a global assignment. -/
def context00
    (assignment : BellGlobalAssignment) :
    BellLocalContextAssignment where
  alice := assignment.A0
  bob := assignment.B0

/-- The `(A0, B1)` context projected from a global assignment. -/
def context01
    (assignment : BellGlobalAssignment) :
    BellLocalContextAssignment where
  alice := assignment.A0
  bob := assignment.B1

/-- The `(A1, B0)` context projected from a global assignment. -/
def context10
    (assignment : BellGlobalAssignment) :
    BellLocalContextAssignment where
  alice := assignment.A1
  bob := assignment.B0

/-- The `(A1, B1)` context projected from a global assignment. -/
def context11
    (assignment : BellGlobalAssignment) :
    BellLocalContextAssignment where
  alice := assignment.A1
  bob := assignment.B1

/-- The four local contexts projected from one global assignment. -/
def localContexts
    (assignment : BellGlobalAssignment) :
    BellFourContextAssignments where
  context00 := assignment.context00
  context01 := assignment.context01
  context10 := assignment.context10
  context11 := assignment.context11

end BellGlobalAssignment

/-! ## Amalgamation -/

/--
Compatibility data for amalgamating four local Bell contexts.

It says that the two occurrences of each marginal setting agree:
`A0`, `A1`, `B0`, and `B1` can each be read as one co-indexed value.
-/
structure BellAmalgamationCompatibility
    (contexts : BellFourContextAssignments) where
  A0_shared :
    contexts.context00.alice = contexts.context01.alice
  A1_shared :
    contexts.context10.alice = contexts.context11.alice
  B0_shared :
    contexts.context00.bob = contexts.context10.bob
  B1_shared :
    contexts.context01.bob = contexts.context11.bob

/-- A global assignment amalgamates four local contexts when it projects to them. -/
structure BellContextAmalgamation
    (contexts : BellFourContextAssignments) where
  global : BellGlobalAssignment
  matches_contexts :
    global.localContexts = contexts

/-- The contexts projected from a global assignment are automatically compatible. -/
def compatibilityOfGlobalAssignment
    (assignment : BellGlobalAssignment) :
    BellAmalgamationCompatibility assignment.localContexts where
  A0_shared := rfl
  A1_shared := rfl
  B0_shared := rfl
  B1_shared := rfl

/-- A global assignment amalgamates its own projected contexts. -/
def amalgamationOfGlobalAssignment
    (assignment : BellGlobalAssignment) :
    BellContextAmalgamation assignment.localContexts where
  global := assignment
  matches_contexts := rfl

/-- Build the global assignment determined by compatible local contexts. -/
def globalAssignmentOfCompatibleContexts
    (contexts : BellFourContextAssignments)
    (_compatibility : BellAmalgamationCompatibility contexts) :
    BellGlobalAssignment where
  A0 := contexts.context00.alice
  A1 := contexts.context10.alice
  B0 := contexts.context00.bob
  B1 := contexts.context01.bob

/-- Compatible local contexts amalgamate into one global co-indexation. -/
def amalgamationOfCompatibleContexts
    (contexts : BellFourContextAssignments)
    (compatibility : BellAmalgamationCompatibility contexts) :
    BellContextAmalgamation contexts where
  global :=
    globalAssignmentOfCompatibleContexts contexts compatibility
  matches_contexts := by
    cases contexts with
    | mk context00 context01 context10 context11 =>
        cases context00 with
        | mk A00 B00 =>
            cases context01 with
            | mk A01 B01 =>
                cases context10 with
                | mk A10 B10 =>
                    cases context11 with
                    | mk A11 B11 =>
                        cases compatibility with
                        | mk hA0 hA1 hB0 hB1 =>
                            cases hA0
                            cases hA1
                            cases hB0
                            cases hB1
                            rfl

/-- Any amalgamation supplies compatibility of the four local contexts. -/
def compatibilityOfAmalgamation
    {contexts : BellFourContextAssignments}
    (amalgamation : BellContextAmalgamation contexts) :
    BellAmalgamationCompatibility contexts := by
  cases amalgamation with
  | mk global matches_contexts =>
      cases matches_contexts
      exact compatibilityOfGlobalAssignment global

/--
Four local Bell contexts are globally amalgamable exactly when the repeated
marginal readings are compatible.
-/
theorem bellAmalgamation_iff_compatibility
    (contexts : BellFourContextAssignments) :
    Nonempty (BellContextAmalgamation contexts) ↔
      Nonempty (BellAmalgamationCompatibility contexts) := by
  constructor
  · intro hAmalgamation
    cases hAmalgamation with
    | intro amalgamation =>
        exact ⟨compatibilityOfAmalgamation amalgamation⟩
  · intro hCompatibility
    cases hCompatibility with
    | intro compatibility =>
        exact ⟨amalgamationOfCompatibleContexts contexts compatibility⟩

/-- Any amalgamation exposes the short global co-indexation it carries. -/
def shortCoindexationOfAmalgamation
    {contexts : BellFourContextAssignments}
    (amalgamation : BellContextAmalgamation contexts) :
    BellShortCoindexation :=
  amalgamation.global

/-- Amalgamated local contexts satisfy the exact pointwise CHSH bound. -/
theorem bellPointwiseCHSHBound_of_amalgamation
    {contexts : BellFourContextAssignments}
    (amalgamation : BellContextAmalgamation contexts) :
    BellPointwiseCHSHBound
      (shortCoindexationOfAmalgamation amalgamation) :=
  bellPointwiseCHSHBound_of_shortCoindexation
    (shortCoindexationOfAmalgamation amalgamation)

/-- Amalgamated local contexts satisfy the standard classical CHSH bound. -/
theorem bellClassicalBound_of_amalgamation
    {contexts : BellFourContextAssignments}
    (amalgamation : BellContextAmalgamation contexts) :
    BellGlobalAssignment.BellClassicalBound
      (shortCoindexationOfAmalgamation amalgamation) :=
  BellGlobalAssignment.bellClassicalBound
    (shortCoindexationOfAmalgamation amalgamation)

/-! ## Amalgamation obstructions -/

/-- Failure of amalgamation for a specified four-context family. -/
abbrev BellContextAmalgamationObstruction
    (contexts : BellFourContextAssignments) :
    Prop :=
  BellContextAmalgamation contexts -> False

/-- If the two `A0` readings disagree, no global amalgamation exists. -/
theorem noAmalgamation_of_A0_mismatch
    (contexts : BellFourContextAssignments)
    (mismatch :
      contexts.context00.alice = contexts.context01.alice -> False) :
    BellContextAmalgamationObstruction contexts := by
  intro amalgamation
  exact
    mismatch
      (compatibilityOfAmalgamation amalgamation).A0_shared

/-- If the two `A1` readings disagree, no global amalgamation exists. -/
theorem noAmalgamation_of_A1_mismatch
    (contexts : BellFourContextAssignments)
    (mismatch :
      contexts.context10.alice = contexts.context11.alice -> False) :
    BellContextAmalgamationObstruction contexts := by
  intro amalgamation
  exact
    mismatch
      (compatibilityOfAmalgamation amalgamation).A1_shared

/-- If the two `B0` readings disagree, no global amalgamation exists. -/
theorem noAmalgamation_of_B0_mismatch
    (contexts : BellFourContextAssignments)
    (mismatch :
      contexts.context00.bob = contexts.context10.bob -> False) :
    BellContextAmalgamationObstruction contexts := by
  intro amalgamation
  exact
    mismatch
      (compatibilityOfAmalgamation amalgamation).B0_shared

/-- If the two `B1` readings disagree, no global amalgamation exists. -/
theorem noAmalgamation_of_B1_mismatch
    (contexts : BellFourContextAssignments)
    (mismatch :
      contexts.context01.bob = contexts.context11.bob -> False) :
    BellContextAmalgamationObstruction contexts := by
  intro amalgamation
  exact
    mismatch
      (compatibilityOfAmalgamation amalgamation).B1_shared

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.BellLocalContextAssignment
#print axioms Meta.ClosedStabilityTheorem.BellFourContextAssignments
#print axioms Meta.ClosedStabilityTheorem.BellGlobalAssignment.localContexts
#print axioms Meta.ClosedStabilityTheorem.BellAmalgamationCompatibility
#print axioms Meta.ClosedStabilityTheorem.BellContextAmalgamation
#print axioms Meta.ClosedStabilityTheorem.compatibilityOfGlobalAssignment
#print axioms Meta.ClosedStabilityTheorem.amalgamationOfGlobalAssignment
#print axioms Meta.ClosedStabilityTheorem.globalAssignmentOfCompatibleContexts
#print axioms Meta.ClosedStabilityTheorem.amalgamationOfCompatibleContexts
#print axioms Meta.ClosedStabilityTheorem.compatibilityOfAmalgamation
#print axioms Meta.ClosedStabilityTheorem.bellAmalgamation_iff_compatibility
#print axioms Meta.ClosedStabilityTheorem.shortCoindexationOfAmalgamation
#print axioms Meta.ClosedStabilityTheorem.bellPointwiseCHSHBound_of_amalgamation
#print axioms Meta.ClosedStabilityTheorem.bellClassicalBound_of_amalgamation
#print axioms Meta.ClosedStabilityTheorem.BellContextAmalgamationObstruction
#print axioms Meta.ClosedStabilityTheorem.noAmalgamation_of_A0_mismatch
#print axioms Meta.ClosedStabilityTheorem.noAmalgamation_of_A1_mismatch
#print axioms Meta.ClosedStabilityTheorem.noAmalgamation_of_B0_mismatch
#print axioms Meta.ClosedStabilityTheorem.noAmalgamation_of_B1_mismatch
/- AXIOM_AUDIT_END -/
