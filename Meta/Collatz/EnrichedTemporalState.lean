import Meta.Collatz.OperationalTemporalRepresentation
import Meta.Collatz.InitialIndexedFibre

/-!
# Collatz enriched temporal state

This file introduces the enriched temporal state used for fibrewise height
concordance.  The height is carried by the enriched state, not reconstructed as
a raw visited `Nat` value.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Generic enriched trajectory -/

/-- Iteration of a state dynamics for a fixed number of steps. -/
def enrichedTrajectory
    {State : Type}
    (step : State -> State)
    (start : State) :
    Nat -> State
  | 0 => start
  | t + 1 => step (enrichedTrajectory step start t)

/-! ## Collatz temporal fibre state -/

/-- Temporal state of the Collatz fibre opened by the initial index `n`. -/
structure CollatzTemporalFibreState
    (n : Nat) where
  visible : Nat
  fibre :
    CollatzInitialIndexedFibreHeightPackage n
  activeHeight : Nat
  activeHeight_eq :
    activeHeight = fibre.height
  positiveWitness :
    NatEnrichedParityPositiveInternalDiagonalWitness n
  positiveWitness_eq_activeHeight :
    positiveWitness.witness = activeHeight

/-- Initial enriched temporal state of the fibre opened by `n`. -/
def collatzInitialTemporalFibreState
    (n : Nat) :
    CollatzTemporalFibreState n where
  visible := n
  fibre := collatzInitialIndexedFibreHeightPackage n
  activeHeight := (collatzInitialIndexedFibreHeightPackage n).height
  activeHeight_eq := rfl
  positiveWitness := collatzInitialIndexFibreHeightWitness n
  positiveWitness_eq_activeHeight :=
    collatzInitialIndexFibreHeightWitness_witness_eq_height n

/-- One enriched temporal step preserves the fibre data and updates only the visible projection. -/
def collatzEnrichedTemporalStep
    (n : Nat) :
    CollatzTemporalFibreState n ->
      CollatzTemporalFibreState n
  | state =>
      { state with
        visible := collatzOperationalTemporalStep state.visible }

/-! ## Public readings -/

/-- The initial enriched temporal state carries the initial-index fibre height. -/
theorem collatzInitialTemporalFibreState_activeHeight_eq_fibre
    (n : Nat) :
    (collatzInitialTemporalFibreState n).activeHeight =
      collatzInitialIndexFibreHeight n :=
  collatzInitialIndexedFibre_height_eq n

/-- The enriched temporal step preserves the active height. -/
theorem collatzEnrichedTemporalStep_preserves_activeHeight
    (n : Nat)
    (state : CollatzTemporalFibreState n) :
    (collatzEnrichedTemporalStep n state).activeHeight =
      state.activeHeight :=
  rfl

/-- The enriched temporal step projects visibly through the operational temporal step. -/
theorem collatzEnrichedTemporalStep_visible_eq
    (n : Nat)
    (state : CollatzTemporalFibreState n) :
    (collatzEnrichedTemporalStep n state).visible =
      collatzOperationalTemporalStep state.visible :=
  rfl

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.enrichedTrajectory
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzTemporalFibreState
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialTemporalFibreState
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzEnrichedTemporalStep
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialTemporalFibreState_activeHeight_eq_fibre
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzEnrichedTemporalStep_preserves_activeHeight
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzEnrichedTemporalStep_visible_eq
/- AXIOM_AUDIT_END -/
