import Meta.Arithmetic.RelaxedOddProjectedIdentity
import Meta.Collatz.RelaxedOddActionBridge

/-!
# Collatz bridge to projected identity through relaxed odd

This file exposes the projected-identity relaxation activated by one Collatz
operational intersection.

The file does not rebuild the Collatz odd step.  It only instantiates the
already-built relaxed-odd OOD/projected-identity bridge at the formed index of
the intersection.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Collatz activation of the relaxed-odd constrained relaxation -/

/--
One Collatz operational intersection activates the relaxed-odd constrained
projection relaxation at its formed index.
-/
def collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ConstrainedProjectionRelaxation
      NatEnrichedParityRole
      Nat
      Nat
      Nat
      natEnrichedRelaxedOddOODProjectIn
      natEnrichedRelaxedOddOODProjectOut
      natEnrichedRelaxedOddOODReadIn
      natEnrichedRelaxedOddOODReadOut
      (fun _ => Nat)
      (fun _ witness => 0 < witness) :=
  natEnrichedRelaxedOddConstrainedProjectionRelaxation
    (formedPositiveExcessOfIntersection intersection)

/-! ## Extracted cells at the Collatz intersection -/

/-- Input projected identity cell activated by one Collatz intersection. -/
def collatzRelaxedOddProjectedIdentityCellInOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ProjectedIdentityCell
      NatEnrichedParityRole
      Nat
      natEnrichedRelaxedOddOODProjectIn :=
  projectedIdentityCellInOfConstrainedRelaxation
    (collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
      intersection)

/-- Output projected identity cell activated by one Collatz intersection. -/
def collatzRelaxedOddProjectedIdentityCellOutOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ProjectedIdentityCell
      NatEnrichedParityRole
      Nat
      natEnrichedRelaxedOddOODProjectOut :=
  projectedIdentityCellOutOfConstrainedRelaxation
    (collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
      intersection)

/-- Input read identity cell activated by one Collatz intersection. -/
def collatzRelaxedOddReadIdentityCellInOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ReadIdentityCell
      NatEnrichedParityRole
      Nat
      Nat
      natEnrichedRelaxedOddOODProjectIn
      natEnrichedRelaxedOddOODReadIn :=
  readIdentityCellInOfConstrainedRelaxation
    (collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
      intersection)

/-- Output read identity cell activated by one Collatz intersection. -/
def collatzRelaxedOddReadIdentityCellOutOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ReadIdentityCell
      NatEnrichedParityRole
      Nat
      Nat
      natEnrichedRelaxedOddOODProjectOut
      natEnrichedRelaxedOddOODReadOut :=
  readIdentityCellOutOfConstrainedRelaxation
    (collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
      intersection)

/-! ## Extracted invariant at the Collatz intersection -/

/-- Positive projected invariant activated by one Collatz intersection. -/
def collatzRelaxedOddPositiveProjectedInvariantOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    PositiveProjectedInvariant
      NatEnrichedParityRole
      Nat
      natEnrichedRelaxedOddOODProjectIn
      (fun _ => Nat)
      (fun _ witness => 0 < witness) :=
  positiveProjectedInvariantOfConstrainedRelaxation
    (collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
      intersection)

/-- The extracted invariant is the positive witness of the activated relaxed odd role. -/
theorem collatzRelaxedOddPositiveProjectedInvariant_eq_relaxedOddWitness
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedOddPositiveProjectedInvariantOfIntersection
        intersection).witness =
      (collatzRelaxedOddRoleOfIntersection intersection).positiveWitness :=
  rfl

/-- The extracted invariant is the Collatz relaxed positive diagonal value. -/
theorem collatzRelaxedOddPositiveProjectedInvariant_eq_positiveDiagonalValue
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedOddPositiveProjectedInvariantOfIntersection
        intersection).witness =
      collatzRelaxedPositiveDiagonalValueOfIntersection intersection :=
  collatzRelaxedOddRoleOfIntersection_witness_eq_positiveDiagonalValue
    intersection

/-- The extracted invariant is positive. -/
theorem collatzRelaxedOddPositiveProjectedInvariant_pos
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    0 <
      (collatzRelaxedOddPositiveProjectedInvariantOfIntersection
        intersection).witness :=
  (collatzRelaxedOddPositiveProjectedInvariantOfIntersection
    intersection).witness_pos

/-! ## Collatz roles exposed by the projected-identity cell -/

/-- The input cell formed side is the extracted Collatz closing role. -/
theorem collatzRelaxedOddProjectedIdentityCellIn_formed_eq_closingRole
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedOddProjectedIdentityCellInOfIntersection
        intersection).formed =
      arithmeticClosingRoleOfIntersection intersection := by
  rw [arithmeticClosingRoleOfIntersection_eq intersection]
  rfl

/-- The input cell shadow side is the extracted Collatz mediating role. -/
theorem collatzRelaxedOddProjectedIdentityCellIn_shadow_eq_mediatingRole
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedOddProjectedIdentityCellInOfIntersection
        intersection).shadow =
      arithmeticMediatingRoleOfIntersection intersection := by
  rw [arithmeticMediatingRoleOfIntersection_eq intersection]
  rfl

/--
The activated constrained relaxation exposes the visible shift of the relaxed
odd regime at the Collatz intersection.
-/
def collatzRelaxedOddVisibleShiftOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    natEnrichedRelaxedOddOODReadIn
        (natEnrichedRelaxedOddOODProjectIn
          (collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
            intersection).formed) =
      natEnrichedRelaxedOddOODReadOut
        (natEnrichedRelaxedOddOODProjectOut
          (collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
            intersection).formed) -> False :=
  (collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
    intersection).visibleShift

/-! ## Obstructions and non-reconstruction at the Collatz intersection -/

/-- Input projection obstruction activated by one Collatz intersection. -/
def collatzRelaxedOddProjectionObstructionInOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedRelaxedOddOODProjectIn :=
  projectionObstructionInOfConstrainedRelaxation
    (collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
      intersection)

/-- Output projection obstruction activated by one Collatz intersection. -/
def collatzRelaxedOddProjectionObstructionOutOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedRelaxedOddOODProjectOut :=
  projectionObstructionOutOfConstrainedRelaxation
    (collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
      intersection)

/-- Input non-reconstruction activated by one Collatz intersection. -/
def collatzRelaxedOddNoProjectiveReconstructionInOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ((recover : Nat -> NatEnrichedParityRole) ->
      ((interface : NatEnrichedParityRole) ->
        recover (natEnrichedRelaxedOddOODProjectIn interface) = interface) ->
          False) :=
  noProjectiveReconstructionInOfConstrainedRelaxation
    (collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
      intersection)

/-- Output non-reconstruction activated by one Collatz intersection. -/
def collatzRelaxedOddNoProjectiveReconstructionOutOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ((recover : Nat -> NatEnrichedParityRole) ->
      ((interface : NatEnrichedParityRole) ->
        recover (natEnrichedRelaxedOddOODProjectOut interface) = interface) ->
          False) :=
  noProjectiveReconstructionOutOfConstrainedRelaxation
    (collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
      intersection)

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddConstrainedProjectionRelaxationOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddProjectedIdentityCellInOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddProjectedIdentityCellOutOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddReadIdentityCellInOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddReadIdentityCellOutOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddPositiveProjectedInvariantOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddPositiveProjectedInvariant_eq_relaxedOddWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddPositiveProjectedInvariant_eq_positiveDiagonalValue
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddPositiveProjectedInvariant_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddProjectedIdentityCellIn_formed_eq_closingRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddProjectedIdentityCellIn_shadow_eq_mediatingRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddVisibleShiftOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddProjectionObstructionInOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddProjectionObstructionOutOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddNoProjectiveReconstructionInOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedOddNoProjectiveReconstructionOutOfIntersection
/- AXIOM_AUDIT_END -/
