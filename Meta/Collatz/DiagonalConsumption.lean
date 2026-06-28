import Meta.Collatz.Countdown

/-!
# Collatz diagonal consumption

This file implements the diagonal-consumption layer described in
`Docs/CollatzDiagonalConsumption.md`.

The layer does not introduce a trajectory-height route.  It connects the
support carried by the local Collatz role divergence to the terminal excess
consumed by the enriched Nat countdown dynamic row.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Consumer index for the carried diagonal support -/

/--
Countdown consumer index selected by the Collatz relaxed right role.

The resulting countdown terminal excess is the support carried by
`collatzRoleDivergenceMaximum n`.
-/
def collatzDiagonalConsumerIndex
    (n : Nat) :
    Nat :=
  3 * n

/-- The countdown row at the consumer index consumes the carried Collatz support. -/
theorem collatzDiagonalConsumer_terminalExcess_eq_support
    (n : Nat) :
    (countdownTerminalDynamicGapRow
        (collatzDiagonalConsumerIndex n)).terminalExcess =
      (collatzRoleDivergenceMaximum n).support := by
  rw [countdownTerminalDynamicGapRow_terminalExcess_eq_n_plus_two]
  rw [collatzRoleDivergenceMaximum_support_eq]
  rfl

/-- The carried Collatz support is the terminal excess of its countdown consumer. -/
theorem collatzDiagonalSupport_eq_consumerTerminalExcess
    (n : Nat) :
    (collatzRoleDivergenceMaximum n).support =
      (countdownTerminalDynamicGapRow
        (collatzDiagonalConsumerIndex n)).terminalExcess :=
  Eq.symm (collatzDiagonalConsumer_terminalExcess_eq_support n)

/-! ## Support carried by an arbitrary divergence -/

/-- The support of a carried divergence is the relaxed support selected by its role. -/
theorem collatzRoleDivergence_support_eq_relaxed
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    divergence.support =
      collatzRelaxedRightSupport n := by
  rw [divergence.support_eq_relaxedPayload]
  rw [divergence.relaxedRightRole_eq]
  rfl

/-- The support of a carried divergence coincides with the canonical support. -/
theorem collatzRoleDivergence_support_eq_canonical
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    divergence.support =
      (collatzRoleDivergenceMaximum n).support := by
  rw [collatzRoleDivergence_support_eq_relaxed divergence]
  rfl

/--
The countdown row at the consumer index consumes the support of any carried
Collatz role divergence.
-/
theorem collatzDiagonalConsumer_terminalExcess_eq_divergenceSupport
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    (countdownTerminalDynamicGapRow
        (collatzDiagonalConsumerIndex n)).terminalExcess =
      divergence.support := by
  rw [collatzDiagonalConsumer_terminalExcess_eq_support n]
  exact Eq.symm
    (collatzRoleDivergence_support_eq_canonical divergence)

/-- A carried Collatz divergence support is consumed as terminal excess. -/
theorem collatzDivergenceSupport_eq_consumerTerminalExcess
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    divergence.support =
      (countdownTerminalDynamicGapRow
        (collatzDiagonalConsumerIndex n)).terminalExcess :=
  Eq.symm
    (collatzDiagonalConsumer_terminalExcess_eq_divergenceSupport
      divergence)

/-! ## Diagonal consumption package -/

/--
Consumption of the positive Collatz diagonal support by an enriched Nat dynamic
row.

The package keeps the producer and the consumer together:

* the local Collatz role divergence produces the carried support;
* the positive diagonal witness diagonalizes that support internally;
* the countdown terminal row consumes the same support as terminal excess.
-/
structure CollatzDiagonalConsumption
    (n : Nat) where
  divergence :
    CollatzRoleDivergenceMaximum n
  positiveDiagonal :
    CollatzRoleDivergencePositiveDiagonalWitness n
  positiveDiagonal_roleDivergence_eq :
    positiveDiagonal.roleDivergence = divergence
  consumerIntersection :
    PrimitiveMemoryReadingIntersection
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision
              (collatzDiagonalConsumerIndex n)))))
  consumerIntersection_eq :
    consumerIntersection =
      countdownTerminalIntersection (collatzDiagonalConsumerIndex n)
  consumerRow :
    ArithmeticDynamicGapRow
  consumerRow_eq :
    consumerRow =
      countdownTerminalDynamicGapRow
        (collatzDiagonalConsumerIndex n)
  support_eq_terminalExcess :
    divergence.support = consumerRow.terminalExcess

/-- Consumption of the support carried by a specific Collatz role divergence. -/
def collatzDiagonalConsumptionOfDivergence
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    CollatzDiagonalConsumption n where
  divergence := divergence
  positiveDiagonal :=
    collatzRoleDivergencePositiveDiagonalWitness divergence
  positiveDiagonal_roleDivergence_eq := rfl
  consumerIntersection :=
    countdownTerminalIntersection (collatzDiagonalConsumerIndex n)
  consumerIntersection_eq := rfl
  consumerRow :=
    countdownTerminalDynamicGapRow (collatzDiagonalConsumerIndex n)
  consumerRow_eq := rfl
  support_eq_terminalExcess :=
    collatzDivergenceSupport_eq_consumerTerminalExcess divergence

/-- Canonical consumption of the carried Collatz diagonal support. -/
def collatzDiagonalConsumption
    (n : Nat) :
    CollatzDiagonalConsumption n :=
  collatzDiagonalConsumptionOfDivergence
    (collatzRoleDivergenceMaximum n)

/-- The canonical package consumes exactly the support carried by its divergence. -/
theorem collatzDiagonalConsumption_support_eq_terminalExcess
    (n : Nat) :
    (collatzDiagonalConsumption n).divergence.support =
      (collatzDiagonalConsumption n).consumerRow.terminalExcess :=
  (collatzDiagonalConsumption n).support_eq_terminalExcess

/-- The canonical package uses the internal positive diagonal of its divergence. -/
theorem collatzDiagonalConsumption_positiveDiagonal_eq
    (n : Nat) :
    (collatzDiagonalConsumption n).positiveDiagonal.roleDivergence =
      (collatzDiagonalConsumption n).divergence :=
  (collatzDiagonalConsumption n).positiveDiagonal_roleDivergence_eq

/-- The carried-divergence package consumes exactly its divergence support. -/
theorem collatzDiagonalConsumptionOfDivergence_support_eq_terminalExcess
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    (collatzDiagonalConsumptionOfDivergence divergence).divergence.support =
      (collatzDiagonalConsumptionOfDivergence divergence).consumerRow.terminalExcess :=
  (collatzDiagonalConsumptionOfDivergence divergence).support_eq_terminalExcess

/-- The carried-divergence package uses the internal positive diagonal of its divergence. -/
theorem collatzDiagonalConsumptionOfDivergence_positiveDiagonal_eq
    {n : Nat}
    (divergence : CollatzRoleDivergenceMaximum n) :
    (collatzDiagonalConsumptionOfDivergence divergence).positiveDiagonal.roleDivergence =
      (collatzDiagonalConsumptionOfDivergence divergence).divergence :=
  (collatzDiagonalConsumptionOfDivergence divergence).positiveDiagonal_roleDivergence_eq

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumerIndex
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumer_terminalExcess_eq_support
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalSupport_eq_consumerTerminalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRoleDivergence_support_eq_relaxed
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRoleDivergence_support_eq_canonical
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumer_terminalExcess_eq_divergenceSupport
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDivergenceSupport_eq_consumerTerminalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzDiagonalConsumption
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumptionOfDivergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumption
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumption_support_eq_terminalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumption_positiveDiagonal_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumptionOfDivergence_support_eq_terminalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalConsumptionOfDivergence_positiveDiagonal_eq
/- AXIOM_AUDIT_END -/
