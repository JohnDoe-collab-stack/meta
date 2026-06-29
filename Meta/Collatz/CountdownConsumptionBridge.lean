import Meta.Collatz.OperationalParity
import Meta.Arithmetic.CountdownRelaxedParity

/-!
# Collatz/countdown consumption bridge

This file connects the positive relaxed diagonal value activated by a Collatz
operational intersection to the terminal excess of a canonical countdown
consumer.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

/-! ## Canonical countdown consumer -/

/--
The canonical countdown consumer index for the relaxed diagonal activated at
one Collatz operational intersection.
-/
def collatzRelaxedCountdownConsumerIndex
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Nat :=
  formedPositiveExcessOfIntersection intersection +
    formedPositiveExcessOfIntersection intersection

/--
The canonical countdown consumer intersection for the relaxed diagonal
activated by one Collatz operational intersection.
-/
def collatzRelaxedCountdownConsumerIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    PrimitiveMemoryReadingIntersection
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision
              (collatzRelaxedCountdownConsumerIndex intersection))))) :=
  countdownTerminalIntersection
    (collatzRelaxedCountdownConsumerIndex intersection)

/-! ## Consumption equality -/

/--
The positive relaxed diagonal value activated by Collatz is exactly the
terminal excess of its canonical countdown consumer.
-/
theorem collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzRelaxedPositiveDiagonalValueOfIntersection intersection =
      formedPositiveExcessOfIntersection
        (collatzRelaxedCountdownConsumerIntersection intersection) := by
  unfold collatzRelaxedCountdownConsumerIntersection
  unfold collatzRelaxedCountdownConsumerIndex
  rw [collatzRelaxedPositiveDiagonalValue_eq_maximalDivergence]
  rw [countdownArithmeticGapTerminalExcess_eq_n_plus_two]
  rw [natEnrichedParityMaximalRelaxedDivergence_eq_double_add_two]

/-! ## Formed reinsertion -/

/--
The canonical countdown consumer reinscribes the positive relaxed diagonal value
activated by Collatz as a closing excess role.
-/
theorem collatzRelaxedCountdownConsumer_closingRole_eq_positiveDiagonal
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingRoleOfIntersection
        (collatzRelaxedCountdownConsumerIntersection intersection) =
      NatEnrichedParityRole.closingExcess
        (collatzRelaxedPositiveDiagonalValueOfIntersection intersection) := by
  rw [arithmeticClosingRoleOfIntersection_eq]
  rw [← collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess]

/--
Facade exposing that the positive value activated by Collatz reenters through a
forming/closing role of the canonical countdown consumer.
-/
theorem collatzRelaxedCountdownConsumer_reenters_formingRole
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Exists (fun w : Nat =>
      w = collatzRelaxedPositiveDiagonalValueOfIntersection intersection /\
      arithmeticClosingRoleOfIntersection
          (collatzRelaxedCountdownConsumerIntersection intersection) =
        NatEnrichedParityRole.closingExcess w) := by
  exact
    ⟨collatzRelaxedPositiveDiagonalValueOfIntersection intersection,
      rfl,
      collatzRelaxedCountdownConsumer_closingRole_eq_positiveDiagonal
        intersection⟩

/--
Structural package for the Collatz/countdown loop:
positive production, terminal consumption, and formed reinsertion.
-/
structure CollatzRelaxedCountdownReinsertion
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  positiveWitness : Nat
  positiveWitness_eq :
    positiveWitness =
      collatzRelaxedPositiveDiagonalValueOfIntersection intersection
  consumer :
    PrimitiveMemoryReadingIntersection
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision
              (collatzRelaxedCountdownConsumerIndex intersection)))))
  consumer_eq :
    consumer =
      collatzRelaxedCountdownConsumerIntersection intersection
  consumed_as_terminal_excess :
    positiveWitness =
      formedPositiveExcessOfIntersection consumer
  reenters_as_closing :
    arithmeticClosingRoleOfIntersection consumer =
      NatEnrichedParityRole.closingExcess positiveWitness

/--
The canonical structural reinsertion package for one Collatz operational
intersection.
-/
def collatzRelaxedCountdownReinsertion
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzRelaxedCountdownReinsertion intersection where
  positiveWitness :=
    collatzRelaxedPositiveDiagonalValueOfIntersection intersection
  positiveWitness_eq := rfl
  consumer :=
    collatzRelaxedCountdownConsumerIntersection intersection
  consumer_eq := rfl
  consumed_as_terminal_excess :=
    collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess
      intersection
  reenters_as_closing :=
    collatzRelaxedCountdownConsumer_closingRole_eq_positiveDiagonal
      intersection

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedCountdownConsumerIndex
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedCountdownConsumerIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedCountdownConsumer_closingRole_eq_positiveDiagonal
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedCountdownConsumer_reenters_formingRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzRelaxedCountdownReinsertion
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedCountdownReinsertion
/- AXIOM_AUDIT_END -/
