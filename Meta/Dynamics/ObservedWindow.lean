import Meta.Dynamics.ObservedDiscrete
import Meta.Arithmetic.FinitePigeonhole

/-!
# Observed bounded windows

This file turns a bounded Nat-observed window of an arbitrary discrete system
into an observable repeated collision, constructively, using the finite
pigeonhole layer.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Observed bounded windows -/

/--
A bounded observed window: offsets `0, ..., B + 1` all have observed payload at
most `B`.
-/
structure ObservedBoundedWindow
    (system : ObservedDiscreteSystem)
    (start : system.State)
    (windowStart B : Nat) where
  value_le_bound :
    (offset : Nat) ->
      offset <= B + 1 ->
        observedNatTrajectory system start (windowStart + offset) <= B

/-- Constructive collision data for a bounded observed window. -/
def observedWindowCollisionData
    {system : ObservedDiscreteSystem}
    {start : system.State}
    {windowStart B : Nat}
    (window : ObservedBoundedWindow system start windowStart B) :
    NatFiniteWindowCollisionData
      (fun offset =>
        observedNatTrajectory system start (windowStart + offset))
      B :=
  natFiniteWindowCollisionData_of_bounded
    (fun offset =>
      observedNatTrajectory system start (windowStart + offset))
    B
    window.value_le_bound

/-- A bounded observed window constructively produces an observed collision. -/
def observedRepeatedCollision_of_boundedWindow
    {system : ObservedDiscreteSystem}
    {start : system.State}
    {windowStart B : Nat}
    (window : ObservedBoundedWindow system start windowStart B) :
    ObservedRepeatedCollision system start := by
  let collision := observedWindowCollisionData window
  exact
    { firstTime := windowStart + collision.leftIndex
      secondTime := windowStart + collision.rightIndex
      first_lt_second :=
        Nat.add_lt_add_left collision.left_lt_right windowStart
      same_observation := collision.values_eq }

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.ObservedBoundedWindow
#print axioms Meta.EnrichedNatClosedStabilityInstance.observedWindowCollisionData
#print axioms Meta.EnrichedNatClosedStabilityInstance.observedRepeatedCollision_of_boundedWindow
/- AXIOM_AUDIT_END -/
