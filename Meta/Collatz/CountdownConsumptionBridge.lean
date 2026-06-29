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

/-! ## Fibrewise structural peak activated by Collatz -/

/--
The fibrewise structural peak met by one Collatz operational intersection.

Collatz does not create this peak.  The intersection activates the peak already
carried by its formed enriched Nat index.
-/
def collatzFibrewiseStructuralPeak
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Nat :=
  collatzRelaxedPositiveDiagonalValueOfIntersection intersection

/-- The Collatz peak is the enriched Nat peak of the formed index. -/
theorem collatzFibrewiseStructuralPeak_eq_natPeak
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzFibrewiseStructuralPeak intersection =
      natEnrichedParityFibrewiseStructuralPeak
        (formedPositiveExcessOfIntersection intersection) :=
  collatzRelaxedPositiveDiagonalValue_eq_maximalDivergence intersection

/-- The Collatz peak is consumed as terminal excess by the canonical countdown consumer. -/
theorem collatzFibrewiseStructuralPeak_eq_countdownTerminalExcess
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzFibrewiseStructuralPeak intersection =
      formedPositiveExcessOfIntersection
        (collatzRelaxedCountdownConsumerIntersection intersection) :=
  collatzRelaxedPositiveDiagonalValue_eq_countdownTerminalExcess intersection

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
The peak activated by Collatz reenters through a forming/closing role of the
canonical countdown consumer.
-/
theorem collatzFibrewiseStructuralPeak_reenters_as_closing
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingRoleOfIntersection
        (collatzRelaxedCountdownConsumerIntersection intersection) =
      NatEnrichedParityRole.closingExcess
        (collatzFibrewiseStructuralPeak intersection) :=
  collatzRelaxedCountdownConsumer_closingRole_eq_positiveDiagonal
    intersection

/--
The positive value activated by Collatz reenters through a forming/closing role
of the canonical countdown consumer.
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
Structural package exposing the full fibrewise peak chain:
formed index, Nat peak, countdown consumption, and closing reinsertion.
-/
structure CollatzFibrewiseStructuralPeakPackage
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  peak : Nat
  peak_eq :
    peak = collatzFibrewiseStructuralPeak intersection
  peak_eq_natPeak :
    peak =
      natEnrichedParityFibrewiseStructuralPeak
        (formedPositiveExcessOfIntersection intersection)
  consumed_as_terminal_excess :
    peak =
      formedPositiveExcessOfIntersection
        (collatzRelaxedCountdownConsumerIntersection intersection)
  reenters_as_closing :
    arithmeticClosingRoleOfIntersection
        (collatzRelaxedCountdownConsumerIntersection intersection) =
      NatEnrichedParityRole.closingExcess peak

/-- The canonical fibrewise structural peak package for one Collatz intersection. -/
def collatzFibrewiseStructuralPeakPackage
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzFibrewiseStructuralPeakPackage intersection where
  peak := collatzFibrewiseStructuralPeak intersection
  peak_eq := rfl
  peak_eq_natPeak :=
    collatzFibrewiseStructuralPeak_eq_natPeak intersection
  consumed_as_terminal_excess :=
    collatzFibrewiseStructuralPeak_eq_countdownTerminalExcess
      intersection
  reenters_as_closing :=
    collatzFibrewiseStructuralPeak_reenters_as_closing
      intersection

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
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewiseStructuralPeak
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewiseStructuralPeak_eq_natPeak
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewiseStructuralPeak_eq_countdownTerminalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedCountdownConsumer_closingRole_eq_positiveDiagonal
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewiseStructuralPeak_reenters_as_closing
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedCountdownConsumer_reenters_formingRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzFibrewiseStructuralPeakPackage
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewiseStructuralPeakPackage
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzRelaxedCountdownReinsertion
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedCountdownReinsertion
/- AXIOM_AUDIT_END -/
