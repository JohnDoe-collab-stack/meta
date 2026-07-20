import Meta.Core.Specialization.DynamicRelaxedUsageModel
import Meta.Semantics.DynamicFoundationalStability

/-!
# Finite repair-driven dynamic semantics

The switch model's next state is reconstructed by inspecting the current gap
use and executing the indexed repair instruction.  The pre-existing arbitrary
`advance` field is not used as a primitive of this model.
-/

namespace Meta
namespace RelaxedSemantics
namespace FiniteDynamicModel

open DynamicRelaxedUsage
open DynamicRelaxedUsageModel
open RelaxedUsageRegime

/-- A repair instruction computes the orientation following its execution. -/
def switchRepairSuccessor
    {interface : SwitchInterface}
    (repair : SwitchRepair interface) :
    SwitchState := by
  cases repair with
  | mk source instruction =>
      cases instruction with
      | restoreLeft => exact .rightToLeft
      | restoreRight => exact .leftToRight
      | preserveMarker source => exact switchState source

/-- Every repair indexed by the formed pole computes the intrinsic successor. -/
theorem switchRepairSuccessor_eq
    (source : SwitchState)
    (repair : SwitchRepair (switchFormedAt source)) :
    switchRepairSuccessor repair = switchState source := by
  cases source <;> cases repair with
  | mk repairSource instruction => cases instruction <;> rfl

/-- Execute repair only after the bilateral memory exposes the current gap. -/
def switchMemoryRepairExecute
    (source : SwitchState)
    (causalState :
      DynamicGapCausalState switchIntrinsicDynamicReturnFamily source)
    (repair :
      SwitchRepair (switchIntrinsicDynamicReturnFamily.formedAt source)) :
    SwitchState := by
  cases causalState.memory.use.classify with
  | inl reflexive =>
      exact (switchFormed_ne_shadow source reflexive.down).elim
  | inr causes =>
      cases causes.2
      exact switchRepairSuccessor repair

/-- The same repair can be routed through the visible transport chain. -/
def switchVisibleRepairExecute
    (source : SwitchState)
    (causalState :
      DynamicGapCausalState switchIntrinsicDynamicReturnFamily source)
    (repair :
      SwitchRepair (switchIntrinsicDynamicReturnFamily.formedAt source)) :
    SwitchState := by
  cases causalState.visibleTransport.use.classify with
  | inl reflexive =>
      exact (switchFormed_ne_shadow source reflexive.down).elim
  | inr causes =>
      cases causes.2
      exact switchRepairSuccessor repair

def switchMemoryRepairAlgebra :
    GapRepairAlgebra switchIntrinsicDynamicReturnFamily where
  executeRepair := switchMemoryRepairExecute

def switchVisibleRepairAlgebra :
    GapRepairAlgebra switchIntrinsicDynamicReturnFamily where
  executeRepair := switchVisibleRepairExecute

theorem switchMemoryRepairNext_eq_switchState
    (source : SwitchState) :
    switchMemoryRepairAlgebra.next source = switchState source := by
  cases source <;> rfl

theorem switchVisibleRepairNext_eq_switchState
    (source : SwitchState) :
    switchVisibleRepairAlgebra.next source = switchState source := by
  cases source <;> rfl

/-- Two internal causal routes induce exactly the same external state graph. -/
theorem switchRepairAlgebras_sameNext
    (source : SwitchState) :
    switchMemoryRepairAlgebra.next source =
      switchVisibleRepairAlgebra.next source :=
  (switchMemoryRepairNext_eq_switchState source).trans
    (switchVisibleRepairNext_eq_switchState source).symm

/-- Every step is effective: repair execution changes the current orientation. -/
def switchRepairEffectiveAt
    (source : SwitchState) :
    EffectiveRepairAt switchMemoryRepairAlgebra source where
  changesSource := by
    intro equality
    exact
      switchState_ne_next source
        (equality.symm.trans (switchMemoryRepairNext_eq_switchState source))

/-- Substantive invariant preserved by the repair orbit. -/
structure SwitchOrbitStable (source : SwitchState) where
  recordedOrientation : SwitchState
  recordedOrientation_eq : recordedOrientation = source
  formedSuccessor_is_shadow :
    switchFormedAt (switchState source) = switchShadowAt source
  shadowSuccessor_is_formed :
    switchShadowAt (switchState source) = switchFormedAt source
  sourceSeparatedFromSuccessor : source = switchState source -> False

def switchOrbitStable (source : SwitchState) : SwitchOrbitStable source where
  recordedOrientation := source
  recordedOrientation_eq := rfl
  formedSuccessor_is_shadow := switchFormed_next_eq_shadow source
  shadowSuccessor_is_formed := switchShadow_next_eq_formed source
  sourceSeparatedFromSuccessor := switchState_ne_next source

def switchRepairInvariant :
    RepairDrivenInvariant switchMemoryRepairAlgebra where
  Stable := SwitchOrbitStable
  initiallyStable := switchOrbitStable .leftToRight
  preserved := fun source _ => by
    rw [switchMemoryRepairNext_eq_switchState]
    exact switchOrbitStable (switchState source)

/-- Every point of the repair-driven orbit preserves pole exchange and change. -/
def switchStableAtIteration
    (n : Nat) :
    SwitchOrbitStable
      (switchMemoryRepairAlgebra.iterate
        n
        switchIntrinsicDynamicReturnFamily.initial) :=
  switchRepairInvariant.stableAtIteration n

theorem switchFirstRepairStep :
    switchMemoryRepairAlgebra.next .leftToRight = .rightToLeft :=
  switchMemoryRepairNext_eq_switchState .leftToRight

theorem switchSecondRepairStep :
    switchMemoryRepairAlgebra.next .rightToLeft = .leftToRight :=
  switchMemoryRepairNext_eq_switchState .rightToLeft

/--
A challenge is not a channel label: it contains the actual causal object read
from the current gap state.
-/
inductive SwitchCausalChallenge (source : SwitchState) : Type where
  | bilateralMemory
      (memory :
        DynamicUsageMemory
          switchIntrinsicDynamicReturnFamily
          (switchIntrinsicDynamicReturnFamily.contextAt source)) :
      SwitchCausalChallenge source
  | visibleTransport
      (transport :
        LocalTransportChain
          (dynamicRelaxedRegimeOfReturnFamily
            switchIntrinsicDynamicReturnFamily)
          (switchIntrinsicDynamicReturnFamily.contextAt source)
          (switchIntrinsicDynamicReturnFamily.formedAt source)
          (switchIntrinsicDynamicReturnFamily.shadowAt source)
          DynamicGapReading.visible) :
      SwitchCausalChallenge source

/-- The canonical challenge read through bilateral memory. -/
def switchMemoryChallenge
    (source : SwitchState) :
    SwitchCausalChallenge source :=
  .bilateralMemory (dynamicGapCausalState
    switchIntrinsicDynamicReturnFamily source).memory

/-- The canonical challenge read through the visible transport computation. -/
def switchVisibleChallenge
    (source : SwitchState) :
    SwitchCausalChallenge source :=
  .visibleTransport (dynamicGapCausalState
    switchIntrinsicDynamicReturnFamily source).visibleTransport

/-- The two causal readings cannot be contracted to one challenge. -/
theorem switchChallenges_separated
    (source : SwitchState) :
    switchMemoryChallenge source = switchVisibleChallenge source ->
    False := by
  intro equality
  cases equality

/--
One repair effect records the complete internal causal path.  Its target is
computed by the algebra and repairs the current shadow while preserving the
former formed pole as the next shadow.
-/
structure SwitchRepairEffect
    (algebra : GapRepairAlgebra switchIntrinsicDynamicReturnFamily)
    (source : SwitchState)
    (challenge : SwitchCausalChallenge source) : Type where
  currentMismatch :
    switchFormedAt source = switchShadowAt source -> False
  consumedRepair :
    SwitchRepair (switchIntrinsicDynamicReturnFamily.formedAt source)
  consumedRepair_eq_current :
    consumedRepair = switchIntrinsicDynamicReturnFamily.repairAt source
  target : SwitchState
  target_eq_repairExecution : target = algebra.next source
  repairsCurrentChallenge :
    switchFormedAt target = switchShadowAt source
  preservesPreviousPole :
    switchShadowAt target = switchFormedAt source

/-- Effect calculated through bilateral memory. -/
def switchMemoryRepairEffect
    (source : SwitchState) :
    SwitchRepairEffect
      switchMemoryRepairAlgebra
      source
      (switchMemoryChallenge source) where
  currentMismatch := switchFormed_ne_shadow source
  consumedRepair := switchIntrinsicDynamicReturnFamily.repairAt source
  consumedRepair_eq_current := rfl
  target := switchState source
  target_eq_repairExecution :=
    (switchMemoryRepairNext_eq_switchState source).symm
  repairsCurrentChallenge := switchFormed_next_eq_shadow source
  preservesPreviousPole := switchShadow_next_eq_formed source

/-- Effect calculated through the visible transport chain. -/
def switchVisibleRepairEffect
    (source : SwitchState) :
    SwitchRepairEffect
      switchVisibleRepairAlgebra
      source
      (switchVisibleChallenge source) where
  currentMismatch := switchFormed_ne_shadow source
  consumedRepair := switchIntrinsicDynamicReturnFamily.repairAt source
  consumedRepair_eq_current := rfl
  target := switchState source
  target_eq_repairExecution :=
    (switchVisibleRepairNext_eq_switchState source).symm
  repairsCurrentChallenge := switchFormed_next_eq_shadow source
  preservesPreviousPole := switchShadow_next_eq_formed source

/--
Same transition graph, distinct intrinsic challenges, and complete repair
effects for both causal readings.
-/
structure DynamicTransitionSemanticDistinction : Type where
  source : SwitchState
  memoryChallenge : SwitchCausalChallenge source
  visibleChallenge : SwitchCausalChallenge source
  memoryChallenge_eq : memoryChallenge = switchMemoryChallenge source
  visibleChallenge_eq : visibleChallenge = switchVisibleChallenge source
  challengesSeparated : memoryChallenge = visibleChallenge -> False
  memoryEffect :
    SwitchRepairEffect switchMemoryRepairAlgebra source memoryChallenge
  visibleEffect :
    SwitchRepairEffect switchVisibleRepairAlgebra source visibleChallenge
  sameTransition :
    switchMemoryRepairAlgebra.next source =
      switchVisibleRepairAlgebra.next source

/-- Closed witness that transition graphs do not determine repair causality. -/
def finiteTransitionGraphSemanticDistinction :
    DynamicTransitionSemanticDistinction where
  source := .leftToRight
  memoryChallenge := switchMemoryChallenge .leftToRight
  visibleChallenge := switchVisibleChallenge .leftToRight
  memoryChallenge_eq := rfl
  visibleChallenge_eq := rfl
  challengesSeparated := switchChallenges_separated .leftToRight
  memoryEffect := switchMemoryRepairEffect .leftToRight
  visibleEffect := switchVisibleRepairEffect .leftToRight
  sameTransition := switchRepairAlgebras_sameNext .leftToRight

end FiniteDynamicModel
end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.FiniteDynamicModel.switchRepairSuccessor_eq
#print axioms Meta.RelaxedSemantics.FiniteDynamicModel.switchMemoryRepairAlgebra
#print axioms Meta.RelaxedSemantics.FiniteDynamicModel.switchVisibleRepairAlgebra
#print axioms Meta.RelaxedSemantics.FiniteDynamicModel.switchRepairAlgebras_sameNext
#print axioms Meta.RelaxedSemantics.FiniteDynamicModel.switchRepairEffectiveAt
#print axioms Meta.RelaxedSemantics.FiniteDynamicModel.switchRepairInvariant
#print axioms Meta.RelaxedSemantics.FiniteDynamicModel.switchStableAtIteration
#print axioms Meta.RelaxedSemantics.FiniteDynamicModel.SwitchCausalChallenge
#print axioms Meta.RelaxedSemantics.FiniteDynamicModel.SwitchRepairEffect
#print axioms Meta.RelaxedSemantics.FiniteDynamicModel.DynamicTransitionSemanticDistinction
#print axioms Meta.RelaxedSemantics.FiniteDynamicModel.finiteTransitionGraphSemanticDistinction
/- AXIOM_AUDIT_END -/
