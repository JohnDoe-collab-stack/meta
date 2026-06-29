import Meta.Collatz.CountdownConsumptionBridge

/-!
# Collatz dynamic closure loop

This file exposes the canonical structural loop already carried by the
Collatz/countdown bridge: activation, positive witness, fibrewise peak,
countdown consumption, and closing/forming reinsertion.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

/-! ## Public loop equalities -/

/-- The canonical countdown consumer index is the doubled formed index. -/
theorem collatzDynamicClosureLoop_consumerIndex_eq_double_formed
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzRelaxedCountdownConsumerIndex intersection =
      formedPositiveExcessOfIntersection intersection +
        formedPositiveExcessOfIntersection intersection :=
  rfl

/-- The fibrewise structural peak is the positive relaxed witness. -/
theorem collatzDynamicClosureLoop_peak_eq_positiveWitness
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzFibrewiseStructuralPeak intersection =
      collatzRelaxedPositiveDiagonalValueOfIntersection intersection :=
  rfl

/-- The peak activated by Collatz is consumed by its canonical countdown consumer. -/
theorem collatzDynamicClosureLoop_peak_consumed
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzFibrewiseStructuralPeak intersection =
      formedPositiveExcessOfIntersection
        (collatzRelaxedCountdownConsumerIntersection intersection) :=
  collatzFibrewiseStructuralPeak_eq_countdownTerminalExcess intersection

/-- The consumed peak reenters as a closing/forming role. -/
theorem collatzDynamicClosureLoop_peak_reenters
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingRoleOfIntersection
        (collatzRelaxedCountdownConsumerIntersection intersection) =
      NatEnrichedParityRole.closingExcess
        (collatzFibrewiseStructuralPeak intersection) :=
  collatzFibrewiseStructuralPeak_reenters_as_closing intersection

/-! ## Canonical dynamic closure loop -/

/--
Canonical structural loop attached to one Collatz operational intersection.

It is a positive certificate: the relaxed divergence is not left as a bare
growth value. It is identified with the fibrewise peak, consumed by the
canonical countdown consumer, and reinserted as `closingExcess peak`.
-/
structure CollatzDynamicClosureLoop
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  formedIndex : Nat
  formedIndex_eq :
    formedIndex = formedPositiveExcessOfIntersection intersection
  positiveWitness : Nat
  positiveWitness_eq :
    positiveWitness =
      collatzRelaxedPositiveDiagonalValueOfIntersection intersection
  peak : Nat
  peak_eq :
    peak = collatzFibrewiseStructuralPeak intersection
  positiveWitness_eq_peak :
    positiveWitness = peak
  peak_eq_natPeak :
    peak = natEnrichedParityFibrewiseStructuralPeak formedIndex
  consumer :
    PrimitiveMemoryReadingIntersection
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision
              (collatzRelaxedCountdownConsumerIndex intersection)))))
  consumer_eq :
    consumer = collatzRelaxedCountdownConsumerIntersection intersection
  consumed_as_terminal_excess :
    peak = formedPositiveExcessOfIntersection consumer
  reenters_as_closing :
    arithmeticClosingRoleOfIntersection consumer =
      NatEnrichedParityRole.closingExcess peak

/-- The canonical dynamic closure loop for one Collatz operational intersection. -/
def collatzDynamicClosureLoop
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzDynamicClosureLoop intersection where
  formedIndex := formedPositiveExcessOfIntersection intersection
  formedIndex_eq := rfl
  positiveWitness :=
    collatzRelaxedPositiveDiagonalValueOfIntersection intersection
  positiveWitness_eq := rfl
  peak := collatzFibrewiseStructuralPeak intersection
  peak_eq := rfl
  positiveWitness_eq_peak := by
    rw [collatzDynamicClosureLoop_peak_eq_positiveWitness]
  peak_eq_natPeak :=
    collatzFibrewiseStructuralPeak_eq_natPeak intersection
  consumer := collatzRelaxedCountdownConsumerIntersection intersection
  consumer_eq := rfl
  consumed_as_terminal_excess :=
    collatzDynamicClosureLoop_peak_consumed intersection
  reenters_as_closing :=
    collatzDynamicClosureLoop_peak_reenters intersection

/-! ## Projections of the canonical loop -/

/-- The canonical loop consumes its peak as terminal excess. -/
theorem collatzDynamicClosureLoop_consumed_as_terminal_excess
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzDynamicClosureLoop intersection).peak =
      formedPositiveExcessOfIntersection
        (collatzDynamicClosureLoop intersection).consumer :=
  (collatzDynamicClosureLoop intersection).consumed_as_terminal_excess

/-- The canonical loop reinscribes its peak as a closing/forming role. -/
theorem collatzDynamicClosureLoop_reenters_as_closing
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingRoleOfIntersection
        (collatzDynamicClosureLoop intersection).consumer =
      NatEnrichedParityRole.closingExcess
        (collatzDynamicClosureLoop intersection).peak :=
  (collatzDynamicClosureLoop intersection).reenters_as_closing

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicClosureLoop_consumerIndex_eq_double_formed
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicClosureLoop_peak_eq_positiveWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicClosureLoop_peak_consumed
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicClosureLoop_peak_reenters
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzDynamicClosureLoop
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicClosureLoop
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicClosureLoop_consumed_as_terminal_excess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicClosureLoop_reenters_as_closing
/- AXIOM_AUDIT_END -/
