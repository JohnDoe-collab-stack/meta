import LocalSemanticClosure.Standalone.Clean.meta.Arithmetic.Trajectory

/-!
# Window
-/

namespace LocalSemanticClosure
namespace Standalone
namespace Clean
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-- A collision inside a finite window of a Nat trajectory. -/
structure NatTrajectoryWindowCollision
    (step : Nat -> Nat)
    (start : Nat)
    (windowStart : Nat)
    (windowLength : Nat) where
  leftOffset : Nat
  rightOffset : Nat
  left_lt_right : leftOffset < rightOffset
  right_lt_length : rightOffset < windowLength
  same_value :
    natTrajectory step start (windowStart + leftOffset) =
      natTrajectory step start (windowStart + rightOffset)

/-- A finite-window collision is a trajectory repeated-index collision. -/
def trajectoryCollision_of_windowCollision
    {step : Nat -> Nat}
    {start windowStart windowLength : Nat}
    (collision :
      NatTrajectoryWindowCollision step start windowStart windowLength) :
    NatTrajectoryRepeatedIndexCollision step start where
  firstTime := windowStart + collision.leftOffset
  secondTime := windowStart + collision.rightOffset
  first_lt_second :=
    Nat.add_lt_add_left collision.left_lt_right windowStart
  same_value := collision.same_value

/-- Closed stability generated from a finite-window collision. -/
def windowCollisionClosedStabilityInstance
    {step : Nat -> Nat}
    {start windowStart windowLength : Nat}
    (collision :
      NatTrajectoryWindowCollision step start windowStart windowLength) :
    RecoveredNonProjectiveClosedStabilityFromIntersection
      bidirectionalCompleteness
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision collision)))
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads
      NatInterfaceRepair :=
  trajectoryRepeatedIndexClosedStabilityInstance
    (trajectoryCollision_of_windowCollision collision)


/-! ## Bounded finite-window collision production -/

/-- A bounded trajectory window has all offsets `0, ..., B + 1` below `B`. -/
structure NatTrajectoryBoundedWindow
    (step : Nat -> Nat)
    (start windowStart B : Nat) where
  value_le_bound :
    ∀ offset : Nat,
      offset ≤ B + 1 ->
        natTrajectory step start (windowStart + offset) ≤ B

/-- A bounded finite trajectory window constructively produces a collision. -/
def windowCollision_of_boundedWindow
    {step : Nat -> Nat}
    {start windowStart B : Nat}
    (window : NatTrajectoryBoundedWindow step start windowStart B) :
    NatTrajectoryWindowCollision step start windowStart (B + 2) := by
  let collision :=
    natFiniteWindowCollisionData_of_bounded
      (fun offset => natTrajectory step start (windowStart + offset))
      B
      window.value_le_bound
  exact
    { leftOffset := collision.leftIndex
      rightOffset := collision.rightIndex
      left_lt_right := collision.left_lt_right
      right_lt_length := Nat.lt_succ_of_le collision.right_le_bound_succ
      same_value := collision.values_eq }

/-- A bounded finite trajectory window generates closed stability. -/
def boundedWindowClosedStabilityInstance
    {step : Nat -> Nat}
    {start windowStart B : Nat}
    (window : NatTrajectoryBoundedWindow step start windowStart B) :
    RecoveredNonProjectiveClosedStabilityFromIntersection
      bidirectionalCompleteness
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (windowCollision_of_boundedWindow window))))
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads
      NatInterfaceRepair :=
  windowCollisionClosedStabilityInstance
    (windowCollision_of_boundedWindow window)

end EnrichedNatClosedStabilityInstance
end Clean
end Standalone
end LocalSemanticClosure

/- AXIOM_AUDIT_BEGIN -/
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.NatTrajectoryWindowCollision
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.trajectoryCollision_of_windowCollision
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.windowCollision_of_boundedWindow
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.boundedWindowClosedStabilityInstance
/- AXIOM_AUDIT_END -/
