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

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedCountdownConsumerIndex
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedCountdownConsumerIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess
/- AXIOM_AUDIT_END -/
