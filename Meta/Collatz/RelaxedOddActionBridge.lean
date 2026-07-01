import Meta.Arithmetic.RelaxedOdd
import Meta.Collatz.OperationalParity

/-!
# Collatz relaxed odd action bridge

This file connects the relaxed odd role isolated in enriched Nat with the
Collatz odd visible action.  The bridge does not define relaxed oddness by the
non-relaxed code.  The code is used only as a visible concordance reading:

`3 * (2*k + 1) + 1 = 2 * rightPayload`.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Collatz visible odd step on a mediating index -/

/-- Visible Collatz odd step read from the non-relaxed mediating code at index `k`. -/
def collatzVisibleOddStepOfMediatingIndex
    (k : Nat) :
    Nat :=
  collatzParityAction
    (natEnrichedParityRoleCode (NatEnrichedParityRole.mediatingValue k))
    ParityRegime.right

/-- The visible odd step is the `3*n+1` expression on the mediating code. -/
theorem collatzVisibleOddStepOfMediatingIndex_eq_three_mul_code_add_one
    (k : Nat) :
    collatzVisibleOddStepOfMediatingIndex k =
      3 *
          (natEnrichedParityRoleCode
            (NatEnrichedParityRole.mediatingValue k)) + 1 := by
  unfold collatzVisibleOddStepOfMediatingIndex
  rw [collatzParityAction_right]

/--
The visible odd Collatz step on the non-relaxed mediating code is the double of
the relaxed right payload.
-/
theorem collatzVisibleOddStep_eq_two_mul_relaxedRightPayload
    (k : Nat) :
    collatzVisibleOddStepOfMediatingIndex k =
      2 * natEnrichedParityMaximallyRelaxedRightPayload k := by
  rw [collatzVisibleOddStepOfMediatingIndex_eq_three_mul_code_add_one]
  exact
    natEnrichedParityMediatingCode_three_mul_add_one_eq_two_mul_rightPayload k

/-- The visible odd step retracts by `/2` to the relaxed right payload. -/
theorem collatzVisibleOddStep_div_two_eq_relaxedRightPayload
    (k : Nat) :
    collatzVisibleOddStepOfMediatingIndex k / 2 =
      natEnrichedParityMaximallyRelaxedRightPayload k := by
  rw [collatzVisibleOddStepOfMediatingIndex_eq_three_mul_code_add_one]
  exact
    natEnrichedParityMediatingCode_three_mul_add_one_div_two_eq_rightPayload k

/-! ## Collatz action on a relaxed odd role -/

/-- Visible Collatz odd step read from a relaxed odd role. -/
def collatzRelaxedOddVisibleStep
    {k : Nat}
    (odd : NatEnrichedRelaxedOddRole k) :
    Nat :=
  collatzParityAction
    (natEnrichedParityRoleCode odd.mediatingRole)
    ParityRegime.right

/--
The visible Collatz odd step of a relaxed odd role is the double of its relaxed
right payload.
-/
theorem collatzRelaxedOddVisibleStep_eq_two_mul_rightPayload
    {k : Nat}
    (odd : NatEnrichedRelaxedOddRole k) :
    collatzRelaxedOddVisibleStep odd =
      2 * odd.rightPayload := by
  unfold collatzRelaxedOddVisibleStep
  rw [collatzParityAction_right]
  rw [odd.mediatingRole_eq]
  rw [odd.rightPayload_eq_maximallyRelaxed]
  exact
    natEnrichedParityMediatingCode_three_mul_add_one_eq_two_mul_rightPayload k

/-- The visible Collatz odd step of a relaxed odd role retracts to its right payload. -/
theorem collatzRelaxedOddVisibleStep_div_two_eq_rightPayload
    {k : Nat}
    (odd : NatEnrichedRelaxedOddRole k) :
    collatzRelaxedOddVisibleStep odd / 2 =
      odd.rightPayload := by
  rw [collatzRelaxedOddVisibleStep_eq_two_mul_rightPayload odd]
  exact nat_two_mul_div_two_clean odd.rightPayload

/-! ## Activation on a Collatz operational intersection -/

/-- One Collatz operational intersection activates the relaxed odd role at its formed index. -/
def collatzRelaxedOddRoleOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatEnrichedRelaxedOddRole
      (formedPositiveExcessOfIntersection intersection) :=
  natEnrichedRelaxedOddRole
    (formedPositiveExcessOfIntersection intersection)

/-- The activated relaxed odd role has the mediating role at the formed index. -/
theorem collatzRelaxedOddRoleOfIntersection_mediating_eq
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedOddRoleOfIntersection intersection).mediatingRole =
      NatEnrichedParityRole.mediatingValue
        (formedPositiveExcessOfIntersection intersection) :=
  rfl

/-- The activated relaxed odd role's mediating side is the extracted mediating role. -/
theorem collatzRelaxedOddRoleOfIntersection_mediating_eq_intersectionRole
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedOddRoleOfIntersection intersection).mediatingRole =
      arithmeticMediatingRoleOfIntersection intersection := by
  rw [arithmeticMediatingRoleOfIntersection_eq intersection]
  rfl

/-- The activated relaxed odd role's witness is the Collatz relaxed positive diagonal value. -/
theorem collatzRelaxedOddRoleOfIntersection_witness_eq_positiveDiagonalValue
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedOddRoleOfIntersection intersection).positiveWitness =
      collatzRelaxedPositiveDiagonalValueOfIntersection intersection := by
  rw [collatzRelaxedPositiveDiagonalValue_eq_maximalDivergence intersection]
  rfl

/-- The activated relaxed odd role's diagonal right side is the extracted mediating role. -/
theorem collatzRelaxedOddRoleOfIntersection_diagonal_right_eq_mediatingRole
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedOddRoleOfIntersection intersection).diagonalCertificate.right =
      arithmeticMediatingRoleOfIntersection intersection := by
  rw [arithmeticMediatingRoleOfIntersection_eq intersection]
  rfl

/-- The activated relaxed odd role's right payload is source plus witness. -/
theorem collatzRelaxedOddRoleOfIntersection_rightPayload_eq_source_add_witness
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedOddRoleOfIntersection intersection).rightPayload =
      formedPositiveExcessOfIntersection intersection +
        (collatzRelaxedOddRoleOfIntersection intersection).positiveWitness :=
  rfl

/-- The visible odd step activated by the intersection is double its relaxed right payload. -/
theorem collatzRelaxedOddRoleOfIntersection_visibleStep_eq_two_mul_rightPayload
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzRelaxedOddVisibleStep
        (collatzRelaxedOddRoleOfIntersection intersection) =
      2 * (collatzRelaxedOddRoleOfIntersection intersection).rightPayload :=
  collatzRelaxedOddVisibleStep_eq_two_mul_rightPayload
    (collatzRelaxedOddRoleOfIntersection intersection)

/--
The visible odd step activated by the intersection retracts by `/2` to the
relaxed right payload of the activated role.
-/
theorem collatzRelaxedOddRoleOfIntersection_visibleStep_div_two_eq_rightPayload
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzRelaxedOddVisibleStep
        (collatzRelaxedOddRoleOfIntersection intersection) / 2 =
      (collatzRelaxedOddRoleOfIntersection intersection).rightPayload :=
  collatzRelaxedOddVisibleStep_div_two_eq_rightPayload
    (collatzRelaxedOddRoleOfIntersection intersection)

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzVisibleOddStepOfMediatingIndex
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzVisibleOddStepOfMediatingIndex_eq_three_mul_code_add_one
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzVisibleOddStep_eq_two_mul_relaxedRightPayload
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzVisibleOddStep_div_two_eq_relaxedRightPayload
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddVisibleStep
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddVisibleStep_eq_two_mul_rightPayload
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddVisibleStep_div_two_eq_rightPayload
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddRoleOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddRoleOfIntersection_mediating_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddRoleOfIntersection_mediating_eq_intersectionRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddRoleOfIntersection_witness_eq_positiveDiagonalValue
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddRoleOfIntersection_diagonal_right_eq_mediatingRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddRoleOfIntersection_rightPayload_eq_source_add_witness
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddRoleOfIntersection_visibleStep_eq_two_mul_rightPayload
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddRoleOfIntersection_visibleStep_div_two_eq_rightPayload
/- AXIOM_AUDIT_END -/
