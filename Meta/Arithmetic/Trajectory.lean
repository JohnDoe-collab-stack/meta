import Meta.Arithmetic.FinitePigeonhole

/-!
# Trajectory
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Trajectory and finite-window collision layer -/

/-- Iteration of a Nat dynamics for a fixed number of steps. -/
def natTrajectory
    (step : Nat -> Nat)
    (start : Nat) : Nat -> Nat
  | 0 => start
  | t + 1 => step (natTrajectory step start t)

/-- A collision produced by one Nat trajectory at two distinct times. -/
structure NatTrajectoryRepeatedIndexCollision
    (step : Nat -> Nat)
    (start : Nat) where
  firstTime : Nat
  secondTime : Nat
  first_lt_second : firstTime < secondTime
  same_value :
    natTrajectory step start firstTime =
      natTrajectory step start secondTime

/-- A trajectory collision exposes the repeated-index collision consumed by closure. -/
def repeatedIndexCollision_of_trajectoryCollision
    {step : Nat -> Nat}
    {start : Nat}
    (collision : NatTrajectoryRepeatedIndexCollision step start) :
    RepeatedIndexCollision where
  firstTime := collision.firstTime
  secondTime := collision.secondTime
  left := natTrajectory step start collision.firstTime
  right := natTrajectory step start collision.secondTime
  first_lt_second := collision.first_lt_second
  same_index := collision.same_value

/-- Closed stability generated from a repeated value in a Nat trajectory. -/
def trajectoryRepeatedIndexClosedStabilityInstance
    {step : Nat -> Nat}
    {start : Nat}
    (collision : NatTrajectoryRepeatedIndexCollision step start) :
    RecoveredNonProjectiveClosedStabilityFromIntersection
      bidirectionalCompleteness
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision collision))
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads
      NatInterfaceRepair :=
  repeatedIndexClosedStabilityInstance
    (repeatedIndexCollision_of_trajectoryCollision collision)


end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.natTrajectory
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatTrajectoryRepeatedIndexCollision
#print axioms Meta.EnrichedNatClosedStabilityInstance.repeatedIndexCollision_of_trajectoryCollision
#print axioms Meta.EnrichedNatClosedStabilityInstance.trajectoryRepeatedIndexClosedStabilityInstance
/- AXIOM_AUDIT_END -/
