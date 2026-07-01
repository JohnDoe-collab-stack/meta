import Meta.Collatz.EnrichedTemporalState

/-!
# Collatz enriched temporal/fibrewise concordance

This file proves the corrected concordance target: the height support carried
by the enriched temporal state is the fibrewise height of the initial index.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Enriched temporal height concordance -/

/--
Along the enriched temporal trajectory of the fibre opened by `n`, the active
height remains the fibrewise height of the initial index.
-/
theorem collatzEnrichedTemporalHeightConcordance
    (n time : Nat) :
    (enrichedTrajectory
      (collatzEnrichedTemporalStep n)
      (collatzInitialTemporalFibreState n)
      time).activeHeight =
      collatzInitialIndexFibreHeight n := by
  induction time with
  | zero =>
      exact collatzInitialTemporalFibreState_activeHeight_eq_fibre n
  | succ time ih =>
      calc
        (enrichedTrajectory
            (collatzEnrichedTemporalStep n)
            (collatzInitialTemporalFibreState n)
            (time + 1)).activeHeight =
            (enrichedTrajectory
              (collatzEnrichedTemporalStep n)
              (collatzInitialTemporalFibreState n)
              time).activeHeight :=
          collatzEnrichedTemporalStep_preserves_activeHeight
            n
            (enrichedTrajectory
              (collatzEnrichedTemporalStep n)
              (collatzInitialTemporalFibreState n)
              time)
        _ = collatzInitialIndexFibreHeight n := ih

/-- The initial state is the zero-time case of enriched temporal height concordance. -/
theorem collatzEnrichedTemporalHeightConcordance_zero
    (n : Nat) :
    (enrichedTrajectory
      (collatzEnrichedTemporalStep n)
      (collatzInitialTemporalFibreState n)
      0).activeHeight =
      collatzInitialIndexFibreHeight n :=
  collatzEnrichedTemporalHeightConcordance n 0

/-- The successor case preserves the same fibrewise height support. -/
theorem collatzEnrichedTemporalHeightConcordance_succ
    (n time : Nat) :
    (enrichedTrajectory
      (collatzEnrichedTemporalStep n)
      (collatzInitialTemporalFibreState n)
      (time + 1)).activeHeight =
      collatzInitialIndexFibreHeight n :=
  collatzEnrichedTemporalHeightConcordance n (time + 1)

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzEnrichedTemporalHeightConcordance
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzEnrichedTemporalHeightConcordance_zero
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzEnrichedTemporalHeightConcordance_succ
/- AXIOM_AUDIT_END -/
