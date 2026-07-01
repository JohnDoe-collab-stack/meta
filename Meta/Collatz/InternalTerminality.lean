import Meta.Collatz.DynamicClosureLoop

/-!
# Collatz internal terminality

This file exposes the internal terminality facade carried by the Collatz
dynamic closure loop: the consumer is the next internal intersection, the
current peak is consumed as terminal excess there, and the same consumer is
again a valid input for the loop.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

/-! ## Next internal intersection -/

/-- Branch of the next internal intersection produced by the closure loop. -/
abbrev collatzNextInternalBranch
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    MemoryBranch :=
  repeatedIndexBranch
    (repeatedIndexCollision_of_trajectoryCollision
      (trajectoryCollision_of_windowCollision
        (countdownTerminalWindowCollision
          (collatzRelaxedCountdownConsumerIndex intersection))))

/-- The next internal intersection is the countdown consumer of the loop. -/
def collatzNextInternalIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    PrimitiveMemoryReadingIntersection
      (collatzNextInternalBranch intersection) :=
  (collatzDynamicClosureLoop intersection).consumer

/-- The next internal intersection is definitionally the loop consumer. -/
theorem collatzNextInternalIntersection_eq_consumer
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzNextInternalIntersection intersection =
      (collatzDynamicClosureLoop intersection).consumer :=
  rfl

/-! ## Consumption and reinsertion through the next internal intersection -/

/-- The current peak is consumed as terminal excess by the next internal intersection. -/
theorem collatzCurrentPeak_consumed_by_nextInternalIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzDynamicClosureLoop intersection).peak =
      formedPositiveExcessOfIntersection
        (collatzNextInternalIntersection intersection) :=
  collatzDynamicClosureLoop_consumed_as_terminal_excess intersection

/-- The next internal intersection reinscribes the current peak as closing. -/
theorem collatzCurrentPeak_reinserted_in_nextInternalIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingRoleOfIntersection
        (collatzNextInternalIntersection intersection) =
      NatEnrichedParityRole.closingExcess
        (collatzDynamicClosureLoop intersection).peak :=
  collatzDynamicClosureLoop_reenters_as_closing intersection

/-! ## Reactivation of the loop -/

/--
The next internal intersection is already a valid input for the same closure
loop.
-/
def collatzNextDynamicClosureLoop
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzDynamicClosureLoop
      (collatzNextInternalIntersection intersection) :=
  collatzDynamicClosureLoop
    (collatzNextInternalIntersection intersection)

/-! ## Positive internal terminality package -/

/--
Positive internal terminality certificate for one Collatz operational
intersection.

It packages the current loop, the next internal intersection, the consumption
of the current peak there, the closing reinsertion, and the fact that the next
intersection can be fed into the same loop again.
-/
structure CollatzInternalTerminality
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  currentLoop :
    CollatzDynamicClosureLoop intersection
  nextIntersection :
    PrimitiveMemoryReadingIntersection
      (collatzNextInternalBranch intersection)
  next_eq_consumer :
    nextIntersection =
      (collatzDynamicClosureLoop intersection).consumer
  consumed :
    (collatzDynamicClosureLoop intersection).peak =
      formedPositiveExcessOfIntersection nextIntersection
  reinserted :
    arithmeticClosingRoleOfIntersection nextIntersection =
      NatEnrichedParityRole.closingExcess
        (collatzDynamicClosureLoop intersection).peak
  nextLoop :
    CollatzDynamicClosureLoop nextIntersection

/-- The canonical internal terminality certificate for one Collatz intersection. -/
def collatzInternalTerminality
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzInternalTerminality intersection where
  currentLoop := collatzDynamicClosureLoop intersection
  nextIntersection := collatzNextInternalIntersection intersection
  next_eq_consumer := rfl
  consumed :=
    collatzCurrentPeak_consumed_by_nextInternalIntersection
      intersection
  reinserted :=
    collatzCurrentPeak_reinserted_in_nextInternalIntersection
      intersection
  nextLoop := collatzNextDynamicClosureLoop intersection

/-! ## Derived exclusion of bare non-terminal activation -/

/--
A bare non-terminal activation would be a peak identified with the current
loop peak while refusing the terminal excess consumption carried by the next
internal intersection.
-/
structure CollatzBareNonTerminalActivation
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  gap : Nat
  gap_eq_peak :
    gap = (collatzDynamicClosureLoop intersection).peak
  not_consumed :
    gap ≠ formedPositiveExcessOfIntersection
      (collatzNextInternalIntersection intersection)

/-- No activation can be bare non-terminal against its canonical internal consumer. -/
theorem noCollatzBareNonTerminalActivation
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzBareNonTerminalActivation intersection -> False := by
  intro bare
  apply bare.not_consumed
  rw [bare.gap_eq_peak]
  exact
    collatzCurrentPeak_consumed_by_nextInternalIntersection
      intersection

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzNextInternalBranch
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzNextInternalIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzNextInternalIntersection_eq_consumer
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzCurrentPeak_consumed_by_nextInternalIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzCurrentPeak_reinserted_in_nextInternalIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzNextDynamicClosureLoop
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzInternalTerminality
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInternalTerminality
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzBareNonTerminalActivation
#print axioms Meta.EnrichedNatClosedStabilityInstance.noCollatzBareNonTerminalActivation
/- AXIOM_AUDIT_END -/
