import Meta.OOD.ProjectedIdentityBridge
import Meta.Arithmetic.RelaxedOddOOD

/-!
# Relaxed odd projected identity

This file exposes the projected-identity core carried by the arithmetic OOD
lock for the enriched relaxed odd role.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem
open OOD

/-! ## Constrained relaxation of the relaxed odd OOD lock -/

/-- The relaxed odd OOD lock as a constrained projection relaxation. -/
def natEnrichedRelaxedOddConstrainedProjectionRelaxation
    (k : Nat) :
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
  constrainedProjectionRelaxationOfOODPositiveWitnessTransport
    (natEnrichedRelaxedOddOODPositiveWitnessTransport k)

/-! ## Extracted cells -/

/-- Input projected identity cell of the relaxed odd lock. -/
def natEnrichedRelaxedOddProjectedIdentityCellIn
    (k : Nat) :
    ProjectedIdentityCell
      NatEnrichedParityRole
      Nat
      natEnrichedRelaxedOddOODProjectIn :=
  projectedIdentityCellInOfConstrainedRelaxation
    (natEnrichedRelaxedOddConstrainedProjectionRelaxation k)

/-- Output projected identity cell of the relaxed odd lock. -/
def natEnrichedRelaxedOddProjectedIdentityCellOut
    (k : Nat) :
    ProjectedIdentityCell
      NatEnrichedParityRole
      Nat
      natEnrichedRelaxedOddOODProjectOut :=
  projectedIdentityCellOutOfConstrainedRelaxation
    (natEnrichedRelaxedOddConstrainedProjectionRelaxation k)

/-- Input read identity cell of the relaxed odd lock. -/
def natEnrichedRelaxedOddReadIdentityCellIn
    (k : Nat) :
    ReadIdentityCell
      NatEnrichedParityRole
      Nat
      Nat
      natEnrichedRelaxedOddOODProjectIn
      natEnrichedRelaxedOddOODReadIn :=
  readIdentityCellInOfConstrainedRelaxation
    (natEnrichedRelaxedOddConstrainedProjectionRelaxation k)

/-- Output read identity cell of the relaxed odd lock. -/
def natEnrichedRelaxedOddReadIdentityCellOut
    (k : Nat) :
    ReadIdentityCell
      NatEnrichedParityRole
      Nat
      Nat
      natEnrichedRelaxedOddOODProjectOut
      natEnrichedRelaxedOddOODReadOut :=
  readIdentityCellOutOfConstrainedRelaxation
    (natEnrichedRelaxedOddConstrainedProjectionRelaxation k)

/-! ## Extracted positive invariant -/

/-- Positive projected invariant of the relaxed odd lock. -/
def natEnrichedRelaxedOddPositiveProjectedInvariant
    (k : Nat) :
    PositiveProjectedInvariant
      NatEnrichedParityRole
      Nat
      natEnrichedRelaxedOddOODProjectIn
      (fun _ => Nat)
      (fun _ witness => 0 < witness) :=
  positiveProjectedInvariantOfConstrainedRelaxation
    (natEnrichedRelaxedOddConstrainedProjectionRelaxation k)

/-- The extracted invariant is exactly the relaxed odd positive witness. -/
theorem natEnrichedRelaxedOddPositiveProjectedInvariant_eq_positiveWitness
    (k : Nat) :
    (natEnrichedRelaxedOddPositiveProjectedInvariant k).witness =
      (natEnrichedRelaxedOddRole k).positiveWitness :=
  rfl

/-- The extracted invariant is positive. -/
theorem natEnrichedRelaxedOddPositiveProjectedInvariant_pos
    (k : Nat) :
    0 < (natEnrichedRelaxedOddPositiveProjectedInvariant k).witness :=
  (natEnrichedRelaxedOddPositiveProjectedInvariant k).witness_pos

/-! ## Extracted obstructions and non-reconstruction -/

/-- Input projection obstruction of the relaxed odd lock. -/
def natEnrichedRelaxedOddProjectionObstructionIn
    (k : Nat) :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedRelaxedOddOODProjectIn :=
  projectionObstructionInOfConstrainedRelaxation
    (natEnrichedRelaxedOddConstrainedProjectionRelaxation k)

/-- Output projection obstruction of the relaxed odd lock. -/
def natEnrichedRelaxedOddProjectionObstructionOut
    (k : Nat) :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedRelaxedOddOODProjectOut :=
  projectionObstructionOutOfConstrainedRelaxation
    (natEnrichedRelaxedOddConstrainedProjectionRelaxation k)

/-- Input non-reconstruction of the relaxed odd lock. -/
def natEnrichedRelaxedOddNoProjectiveReconstructionIn
    (k : Nat) :
    ((recover : Nat -> NatEnrichedParityRole) ->
      ((interface : NatEnrichedParityRole) ->
        recover (natEnrichedRelaxedOddOODProjectIn interface) = interface) ->
          False) :=
  noProjectiveReconstructionInOfConstrainedRelaxation
    (natEnrichedRelaxedOddConstrainedProjectionRelaxation k)

/-- Output non-reconstruction of the relaxed odd lock. -/
def natEnrichedRelaxedOddNoProjectiveReconstructionOut
    (k : Nat) :
    ((recover : Nat -> NatEnrichedParityRole) ->
      ((interface : NatEnrichedParityRole) ->
        recover (natEnrichedRelaxedOddOODProjectOut interface) = interface) ->
          False) :=
  noProjectiveReconstructionOutOfConstrainedRelaxation
    (natEnrichedRelaxedOddConstrainedProjectionRelaxation k)

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddConstrainedProjectionRelaxation
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddProjectedIdentityCellIn
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddProjectedIdentityCellOut
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddReadIdentityCellIn
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddReadIdentityCellOut
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddPositiveProjectedInvariant
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddPositiveProjectedInvariant_eq_positiveWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddPositiveProjectedInvariant_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddProjectionObstructionIn
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddProjectionObstructionOut
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddNoProjectiveReconstructionIn
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddNoProjectiveReconstructionOut
/- AXIOM_AUDIT_END -/
