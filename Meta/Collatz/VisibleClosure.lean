import Meta.Collatz.InternalStateTrajectory

/-!
# Collatz visible closure

This file turns internal terminality into the visible-role closure theorem.

In this framework, visible infinite growth means that the internal trajectory
keeps asking for the mediating role at every step.  The closure loop rules this
out: every internal state reinserts the next visible role as `closingExcess`.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

/-! ## Terminality read as a visible closing role -/

/-- Role extracted from the next intersection of an internal terminality package. -/
def nextRoleOfInternalTerminality
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (terminality : CollatzInternalTerminality intersection) :
    NatEnrichedParityRole :=
  arithmeticClosingRoleOfIntersection terminality.nextIntersection

/-- Internal terminality exposes the next role as closing. -/
theorem collatzInternalTerminality_nextRole_eq_closing
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    nextRoleOfInternalTerminality
        (collatzInternalTerminality intersection) =
      NatEnrichedParityRole.closingExcess
        (collatzDynamicClosureLoop intersection).peak :=
  collatzCurrentPeak_reinserted_in_nextInternalIntersection intersection

/-- The next visible step of terminality is the closing reading. -/
theorem collatzInternalTerminality_nextVisibleStep_eq_closingStep
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzVisibleStepOfRole
        (nextRoleOfInternalTerminality
          (collatzInternalTerminality intersection)) =
      collatzVisibleClosingStep
        (natEnrichedParityRoleCode
          (NatEnrichedParityRole.closingExcess
            (collatzDynamicClosureLoop intersection).peak)) := by
  rw [collatzInternalTerminality_nextRole_eq_closing]
  rfl

/-! ## Visible mediating growth -/

/--
Visible mediating growth at time `t` means that the internally produced
trajectory asks for a mediating role at the next visible reading.
-/
structure CollatzVisibleMediatingGrowthAt
    (state : CollatzInternalState)
    (t : Nat) where
  current :
    CollatzInternalState
  current_eq :
    current = collatzInternalStateTrajectory state t
  nextRole :
    NatEnrichedParityRole
  nextRole_eq :
    nextRole = collatzNextInternalStateRole current
  mediatingIndex :
    Nat
  nextRole_is_mediating :
    nextRole =
      NatEnrichedParityRole.mediatingValue mediatingIndex

/-- No internal time has a next visible role that remains mediating. -/
theorem noCollatzVisibleMediatingGrowthAt
    (state : CollatzInternalState)
    (t : Nat) :
    CollatzVisibleMediatingGrowthAt state t -> False := by
  intro growth
  have hmedCurrent :
      collatzNextInternalStateRole growth.current =
        NatEnrichedParityRole.mediatingValue growth.mediatingIndex := by
    rw [← growth.nextRole_eq]
    exact growth.nextRole_is_mediating
  cases hcurrent : growth.current with
  | mk branch intersection =>
      have hclosing :
          collatzNextInternalStateRole (Sigma.mk branch intersection) =
            NatEnrichedParityRole.closingExcess
              (collatzDynamicClosureLoop intersection).peak :=
        collatzCurrentPeak_reinserted_in_nextInternalIntersection
          intersection
      rw [hcurrent] at hmedCurrent
      rw [hclosing] at hmedCurrent
      cases hmedCurrent

/-! ## No visible infinite mediating growth -/

/-- A visible trajectory that asks for mediating at every internal time. -/
structure CollatzVisibleInfiniteMediatingGrowth
    (state : CollatzInternalState) where
  growthAt :
    forall t : Nat,
      CollatzVisibleMediatingGrowthAt state t

/--
No internally generated Collatz trajectory can remain visibly mediating at all
times.
-/
theorem noCollatzVisibleInfiniteMediatingGrowth
    (state : CollatzInternalState) :
    CollatzVisibleInfiniteMediatingGrowth state -> False := by
  intro growth
  exact noCollatzVisibleMediatingGrowthAt state 0 (growth.growthAt 0)

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.nextRoleOfInternalTerminality
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInternalTerminality_nextRole_eq_closing
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInternalTerminality_nextVisibleStep_eq_closingStep
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzVisibleMediatingGrowthAt
#print axioms Meta.EnrichedNatClosedStabilityInstance.noCollatzVisibleMediatingGrowthAt
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzVisibleInfiniteMediatingGrowth
#print axioms Meta.EnrichedNatClosedStabilityInstance.noCollatzVisibleInfiniteMediatingGrowth
/- AXIOM_AUDIT_END -/
