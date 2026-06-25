import LocalSemanticClosure.Standalone.Clean.meta.Arithmetic.DynamicGap

/-!
# Observed discrete systems

This file bridges arbitrary Nat-time state dynamics to the completed
arithmetic dynamic gap layer.

The bridge is intentionally direct:

```text
observed repeated collision
-> RepeatedIndexCollision
```

It does not pass through `NatTrajectoryRepeatedIndexCollision`, because the
state dynamics need not be a closed dynamics on `Nat`.
-/

namespace LocalSemanticClosure
namespace Standalone
namespace Clean
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

universe u

/-! ## Observed Nat-time systems -/

/-- A discrete system with arbitrary state type and a Nat-valued observation. -/
structure ObservedDiscreteSystem where
  State : Type u
  step : State -> State
  observe : State -> Nat

/-- The state trajectory generated from a start state. -/
def observedTrajectory
    (system : ObservedDiscreteSystem)
    (start : system.State) :
    Nat -> system.State
  | 0 => start
  | time + 1 => system.step (observedTrajectory system start time)

/-- The Nat-valued observation along a state trajectory. -/
def observedNatTrajectory
    (system : ObservedDiscreteSystem)
    (start : system.State) :
    Nat -> Nat :=
  fun time => system.observe (observedTrajectory system start time)

/-! ## Observable repeated collisions -/

/-- Two distinct times in one observed trajectory with the same Nat observation. -/
structure ObservedRepeatedCollision
    (system : ObservedDiscreteSystem)
    (start : system.State) where
  firstTime : Nat
  secondTime : Nat
  first_lt_second : firstTime < secondTime
  same_observation :
    observedNatTrajectory system start firstTime =
      observedNatTrajectory system start secondTime

/--
An observable repeated collision is exactly the repeated-index collision
consumed by the arithmetic dynamic gap layer.
-/
def repeatedIndexCollision_of_observedCollision
    {system : ObservedDiscreteSystem}
    {start : system.State}
    (collision : ObservedRepeatedCollision system start) :
    RepeatedIndexCollision where
  firstTime := collision.firstTime
  secondTime := collision.secondTime
  left := observedNatTrajectory system start collision.firstTime
  right := observedNatTrajectory system start collision.secondTime
  first_lt_second := collision.first_lt_second
  same_index := collision.same_observation

end EnrichedNatClosedStabilityInstance
end Clean
end Standalone
end LocalSemanticClosure

/- AXIOM_AUDIT_BEGIN -/
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.ObservedDiscreteSystem
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.observedTrajectory
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.observedNatTrajectory
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.ObservedRepeatedCollision
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.repeatedIndexCollision_of_observedCollision
/- AXIOM_AUDIT_END -/
