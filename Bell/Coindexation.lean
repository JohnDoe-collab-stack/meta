import LocalSemanticClosure.Standalone.Clean.meta.Core.ClosedStabilityTheorem

/-!
# Bell co-indexation core

This file isolates the deterministic, pre-probabilistic CHSH core.

A global co-indexation carries four potential values

```text
A0, A1, B0, B1 in {-1, +1}
```

inside one assignment.  For every such assignment, the CHSH expression is
pointwise equal to `-2` or `2`.  Probabilities and averaging are not part of
this file.
-/

namespace LocalSemanticClosure
namespace Standalone
namespace Clean
namespace ClosedStabilityTheorem

/-! ## Signs and global co-indexation -/

/-- The two possible deterministic Bell values. -/
inductive BellSign where
  | neg
  | pos

namespace BellSign

/-- Integer reading of a Bell sign. -/
def toInt : BellSign -> Int
  | neg => -1
  | pos => 1

/-- Product of deterministic Bell signs. -/
def mul : BellSign -> BellSign -> BellSign
  | neg, neg => pos
  | neg, pos => neg
  | pos, neg => neg
  | pos, pos => pos

/-- Negation of a deterministic Bell sign. -/
def negSign : BellSign -> BellSign
  | neg => pos
  | pos => neg

/-- Sign multiplication agrees with integer multiplication. -/
theorem toInt_mul
    (left right : BellSign) :
    (mul left right).toInt = left.toInt * right.toInt := by
  cases left <;> cases right <;> rfl

/-- Sign negation agrees with integer negation. -/
theorem toInt_negSign
    (value : BellSign) :
    (negSign value).toInt = -value.toInt := by
  cases value <;> rfl

end BellSign

/--
A global Bell co-indexation.

The four potential values are carried by one assignment, before any
probabilistic averaging.
-/
structure BellGlobalAssignment where
  A0 : BellSign
  A1 : BellSign
  B0 : BellSign
  B1 : BellSign

namespace BellGlobalAssignment

/-- The first CHSH product term. -/
def term00
    (assignment : BellGlobalAssignment) :
    BellSign :=
  assignment.A0.mul assignment.B0

/-- The second CHSH product term. -/
def term01
    (assignment : BellGlobalAssignment) :
    BellSign :=
  assignment.A0.mul assignment.B1

/-- The third CHSH product term. -/
def term10
    (assignment : BellGlobalAssignment) :
    BellSign :=
  assignment.A1.mul assignment.B0

/-- The signed fourth CHSH product term. -/
def term11Neg
    (assignment : BellGlobalAssignment) :
    BellSign :=
  (assignment.A1.mul assignment.B1).negSign

/-- The pointwise CHSH integer value. -/
def chshValue
    (assignment : BellGlobalAssignment) :
    Int :=
  (assignment.term00).toInt +
    (assignment.term01).toInt +
    (assignment.term10).toInt +
    (assignment.term11Neg).toInt

/--
Exact pointwise CHSH bound.

For a single global co-indexation of `A0, A1, B0, B1`, the CHSH value is
already `-2` or `2`, before probabilities or averaging enter.
-/
theorem chshValue_eq_neg_two_or_two
    (assignment : BellGlobalAssignment) :
    assignment.chshValue = -2 ∨ assignment.chshValue = 2 := by
  cases assignment with
  | mk A0 A1 B0 B1 =>
      cases A0 <;> cases A1 <;> cases B0 <;> cases B1 <;>
        first
        | exact Or.inl rfl
        | exact Or.inr rfl

/--
The standard classical CHSH bound facade.

It is stated as `|S| <= 2`, using `Int.natAbs` for the absolute value.  The
pointwise exact theorem above is the stronger deterministic core.
-/
abbrev BellClassicalBound
    (assignment : BellGlobalAssignment) :
    Prop :=
  Int.natAbs assignment.chshValue <= 2

/-- The exact pointwise theorem implies the standard classical CHSH bound. -/
theorem bellClassicalBound_of_exact
    (assignment : BellGlobalAssignment)
    (exactBound :
      assignment.chshValue = -2 ∨ assignment.chshValue = 2) :
    BellClassicalBound assignment := by
  unfold BellClassicalBound
  cases exactBound with
  | inl hNeg =>
      rw [hNeg]
      decide
  | inr hPos =>
      rw [hPos]
      decide

/-- A global Bell co-indexation satisfies the standard classical CHSH bound. -/
theorem bellClassicalBound
    (assignment : BellGlobalAssignment) :
    BellClassicalBound assignment :=
  bellClassicalBound_of_exact
    assignment
    assignment.chshValue_eq_neg_two_or_two

end BellGlobalAssignment

end ClosedStabilityTheorem
end Clean
end Standalone
end LocalSemanticClosure

/- AXIOM_AUDIT_BEGIN -/
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellSign
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellSign.toInt
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellSign.mul
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellSign.negSign
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellSign.toInt_mul
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellSign.toInt_negSign
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellGlobalAssignment
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellGlobalAssignment.chshValue
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellGlobalAssignment.chshValue_eq_neg_two_or_two
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellGlobalAssignment.BellClassicalBound
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellGlobalAssignment.bellClassicalBound_of_exact
#print axioms LocalSemanticClosure.Standalone.Clean.ClosedStabilityTheorem.BellGlobalAssignment.bellClassicalBound
/- AXIOM_AUDIT_END -/
