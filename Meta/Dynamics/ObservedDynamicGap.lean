import Meta.Dynamics.ObservedWindow

/-!
# Observed dynamic gap

This file closes the bridge from arbitrary Nat-observed discrete systems to the
arithmetic dynamic closed-stability row.

Certified observable collisions are sent directly to the arithmetic dynamic
gap layer.  Bounded observed windows first construct a collision by finite
pigeonhole, then use the same bridge.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Certified observed collisions -/

/-- A certified observed collision produces a full dynamic closed-stability row. -/
def observedDynamicClosedStabilityRow
    {system : ObservedDiscreteSystem}
    {start : system.State}
    (collision : ObservedRepeatedCollision system start) :
    ArithmeticDynamicClosedStabilityRow
      (repeatedIndexBranch
        (repeatedIndexCollision_of_observedCollision collision)) :=
  repeatedIndexDynamicClosedStabilityRow
    (repeatedIndexCollision_of_observedCollision collision)

/-- The terminal excess of an observed collision is its second time plus one. -/
theorem observedCollision_terminalExcess_eq
    {system : ObservedDiscreteSystem}
    {start : system.State}
    (collision : ObservedRepeatedCollision system start) :
    formedPositiveExcessOfIntersection
      (repeatedIndexIntersection
        (repeatedIndexCollision_of_observedCollision collision)) =
        collision.secondTime + 1 :=
  rfl

/-- The observed collision row exposes equal visible payloads. -/
theorem observedCollision_sameVisible
    {system : ObservedDiscreteSystem}
    {start : system.State}
    (collision : ObservedRepeatedCollision system start) :
    tracePayloads
      (formedTraceOfIntersection
        (repeatedIndexIntersection
          (repeatedIndexCollision_of_observedCollision collision))) =
      tracePayloads
        (payloadOnlyTraceOfIntersection
          (repeatedIndexIntersection
            (repeatedIndexCollision_of_observedCollision collision))) :=
  (observedDynamicClosedStabilityRow collision).gapRow.sameVisible

/-- The observed collision row separates the formed trace from its shadow. -/
theorem observedCollision_separated
    {system : ObservedDiscreteSystem}
    {start : system.State}
    (collision : ObservedRepeatedCollision system start) :
    formedTraceOfIntersection
      (repeatedIndexIntersection
        (repeatedIndexCollision_of_observedCollision collision)) =
      payloadOnlyTraceOfIntersection
        (repeatedIndexIntersection
          (repeatedIndexCollision_of_observedCollision collision)) ->
        False :=
  (observedDynamicClosedStabilityRow collision).gapRow.separated

/-! ## Constructively produced observed collisions -/

/--
A bounded observed window constructively produces a full dynamic
closed-stability row.
-/
def observedBoundedWindowDynamicClosedStabilityRow
    {system : ObservedDiscreteSystem}
    {start : system.State}
    {windowStart B : Nat}
    (window : ObservedBoundedWindow system start windowStart B) :
    ArithmeticDynamicClosedStabilityRow
      (repeatedIndexBranch
        (repeatedIndexCollision_of_observedCollision
          (observedRepeatedCollision_of_boundedWindow window))) :=
  observedDynamicClosedStabilityRow
    (observedRepeatedCollision_of_boundedWindow window)

/--
The terminal excess produced from a bounded observed window is the second time
of the constructed observed collision plus one.
-/
theorem observedBoundedWindow_terminalExcess_eq
    {system : ObservedDiscreteSystem}
    {start : system.State}
    {windowStart B : Nat}
    (window : ObservedBoundedWindow system start windowStart B) :
    formedPositiveExcessOfIntersection
      (repeatedIndexIntersection
        (repeatedIndexCollision_of_observedCollision
          (observedRepeatedCollision_of_boundedWindow window))) =
        (observedRepeatedCollision_of_boundedWindow window).secondTime + 1 :=
  observedCollision_terminalExcess_eq
    (observedRepeatedCollision_of_boundedWindow window)

/--
Expanded terminal excess for a bounded observed window, in terms of the
right collision offset produced by the finite-window pigeonhole layer.
-/
theorem observedBoundedWindow_terminalExcess_eq_window_right
    {system : ObservedDiscreteSystem}
    {start : system.State}
    {windowStart B : Nat}
    (window : ObservedBoundedWindow system start windowStart B) :
    formedPositiveExcessOfIntersection
      (repeatedIndexIntersection
        (repeatedIndexCollision_of_observedCollision
          (observedRepeatedCollision_of_boundedWindow window))) =
        windowStart + (observedWindowCollisionData window).rightIndex + 1 :=
  rfl

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.observedDynamicClosedStabilityRow
#print axioms Meta.EnrichedNatClosedStabilityInstance.observedCollision_terminalExcess_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.observedCollision_sameVisible
#print axioms Meta.EnrichedNatClosedStabilityInstance.observedCollision_separated
#print axioms Meta.EnrichedNatClosedStabilityInstance.observedBoundedWindowDynamicClosedStabilityRow
#print axioms Meta.EnrichedNatClosedStabilityInstance.observedBoundedWindow_terminalExcess_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.observedBoundedWindow_terminalExcess_eq_window_right
/- AXIOM_AUDIT_END -/
