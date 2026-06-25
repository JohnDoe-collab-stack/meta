import LocalSemanticClosure.Standalone.Clean.meta.Dynamics.ObservedDiscrete
import LocalSemanticClosure.Standalone.Clean.meta.Arithmetic.FinitePigeonhole

/-!
# Observed bounded windows

This file turns a bounded Nat-observed window of an arbitrary discrete system
into an observable repeated collision, constructively, using the finite
pigeonhole layer.
-/

namespace LocalSemanticClosure
namespace Standalone
namespace Clean
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
end Clean
end Standalone
end LocalSemanticClosure

/- AXIOM_AUDIT_BEGIN -/
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.ObservedBoundedWindow
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.observedWindowCollisionData
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.observedRepeatedCollision_of_boundedWindow
/- AXIOM_AUDIT_END -/
