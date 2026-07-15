import Meta.Core.DynamicRelaxedUsage

/-!
# A finite nontrivial model of dynamic relaxed usage

The model has two alternating dynamic states, three formed interfaces, two
visible values, a globally nonconstant projection, a noninjective coordinated
fiber, four distinct bilateral data families, executable proof-relevant
repairs, and a transition that consumes the canonical causal state.
-/

namespace Meta
namespace DynamicRelaxedUsageModel

universe q

open ClosedStabilityTheorem
open RelaxedUsageRegime
open DynamicRelaxedUsage

/-! ## Nontrivial states, interfaces, and visible values -/

/-- The two orientations of the dynamic gap. -/
inductive SwitchState where
  | leftToRight
  | rightToLeft

/-- The intrinsic successor alternates the two orientations. -/
def switchState : SwitchState -> SwitchState
  | SwitchState.leftToRight => SwitchState.rightToLeft
  | SwitchState.rightToLeft => SwitchState.leftToRight

theorem switchState_left_ne_right :
    SwitchState.leftToRight = SwitchState.rightToLeft -> False := by
  intro equality
  cases equality

theorem switchState_right_ne_left :
    SwitchState.rightToLeft = SwitchState.leftToRight -> False := by
  intro equality
  cases equality

theorem switchState_ne_next (source : SwitchState) :
    source = switchState source -> False := by
  cases source with
  | leftToRight => exact switchState_left_ne_right
  | rightToLeft => exact switchState_right_ne_left

theorem switchState_involutive (source : SwitchState) :
    switchState (switchState source) = source := by
  cases source <;> rfl

/-- Two coordinated poles plus a visibly distinct marker. -/
inductive SwitchInterface where
  | leftPole
  | rightPole
  | marker

theorem switchInterface_left_ne_right :
    SwitchInterface.leftPole = SwitchInterface.rightPole -> False := by
  intro equality
  cases equality

theorem switchInterface_right_ne_left :
    SwitchInterface.rightPole = SwitchInterface.leftPole -> False := by
  intro equality
  cases equality

/-- The coordinated fiber and an independent visible marker. -/
inductive SwitchVisible where
  | coordinated
  | marked

/-- A nonconstant projection with one noninjective two-pole fiber. -/
def switchProjection : SwitchInterface -> SwitchVisible
  | SwitchInterface.leftPole => SwitchVisible.coordinated
  | SwitchInterface.rightPole => SwitchVisible.coordinated
  | SwitchInterface.marker => SwitchVisible.marked

theorem switchProjection_poles_same :
    switchProjection SwitchInterface.leftPole =
      switchProjection SwitchInterface.rightPole :=
  rfl

theorem switchProjection_left_ne_marker :
    switchProjection SwitchInterface.leftPole =
      switchProjection SwitchInterface.marker ->
    False := by
  intro equality
  cases equality

def switchProjection_nonconstant :
    Σ left right : SwitchInterface,
      PLift (switchProjection left = switchProjection right -> False) :=
  ⟨SwitchInterface.leftPole,
   SwitchInterface.marker,
   PLift.up switchProjection_left_ne_marker⟩

/-! ## Four genuinely distinct bilateral families -/

structure SwitchComplete (_branch : SwitchState) where
  state : SwitchState

structure SwitchForward (_branch : SwitchState) where
  state : SwitchState

structure SwitchBackward (_branch : SwitchState) where
  state : SwitchState

structure SwitchIntersection (_branch : SwitchState) where
  state : SwitchState

/-- Bilateral completeness transports the state through four distinct types. -/
def switchCompleteness : BidirectionalCompleteness SwitchState where
  Complete := SwitchComplete
  Forward := SwitchForward
  Backward := SwitchBackward
  Intersection := SwitchIntersection
  forwardOfComplete := fun _ complete => ⟨complete.state⟩
  backwardOfComplete := fun _ complete => ⟨complete.state⟩
  intersectionOfComplete := fun _ complete => ⟨complete.state⟩
  completeOfIntersection := fun _ intersection => ⟨intersection.state⟩

/-- Both bilateral round trips preserve the complete typed package. -/
def switchRoundTripCoherence : RoundTripCoherence switchCompleteness where
  completeRoundTrip :=
    { complete_stable := by
        intro branch complete
        cases complete
        rfl }
  intersectionRoundTrip :=
    { intersection_stable := by
        intro branch intersection
        cases intersection
        rfl }

theorem switchCompleteRoundTrip_state
    (branch : SwitchState)
    (complete : switchCompleteness.Complete branch) :
    (completeOfIntersection
      switchCompleteness
      (intersectionOfComplete switchCompleteness complete)).state =
      complete.state :=
  rfl

theorem switchIntersectionRoundTrip_state
    (branch : SwitchState)
    (intersection : switchCompleteness.Intersection branch) :
    (intersectionOfComplete
      switchCompleteness
      (completeOfIntersection switchCompleteness intersection)).state =
      intersection.state :=
  rfl

/-! ## State-indexed poles and proof-relevant realization -/

def switchFormedAt : SwitchState -> SwitchInterface
  | SwitchState.leftToRight => SwitchInterface.leftPole
  | SwitchState.rightToLeft => SwitchInterface.rightPole

def switchShadowAt : SwitchState -> SwitchInterface
  | SwitchState.leftToRight => SwitchInterface.rightPole
  | SwitchState.rightToLeft => SwitchInterface.leftPole

theorem switchFormed_ne_shadow (source : SwitchState) :
    switchFormedAt source = switchShadowAt source -> False := by
  cases source with
  | leftToRight => exact switchInterface_left_ne_right
  | rightToLeft => exact switchInterface_right_ne_left

theorem switchPoles_sameProjection (source : SwitchState) :
    switchProjection (switchFormedAt source) =
      switchProjection (switchShadowAt source) := by
  cases source <;> rfl

theorem switchFormed_next_eq_shadow (source : SwitchState) :
    switchFormedAt (switchState source) = switchShadowAt source := by
  cases source <;> rfl

theorem switchShadow_next_eq_formed (source : SwitchState) :
    switchShadowAt (switchState source) = switchFormedAt source := by
  cases source <;> rfl

/-- A formed interface witness retains its dynamic source. -/
structure SwitchInterfaceWitness (interface : SwitchInterface) where
  source : SwitchState
  interface_eq_formed : interface = switchFormedAt source

def switchInterfaceWitnessAt
    (source : SwitchState) :
    SwitchInterfaceWitness (switchFormedAt source) where
  source := source
  interface_eq_formed := rfl

/-- Realization ties the interface to the state stored by the source intersection. -/
structure SwitchRealizesInterface
    (cycle :
      StrongTerminalCycleFromIntersection
        switchCompleteness
        SwitchState.leftToRight)
    (interface : SwitchInterface) : Type where
  interface_eq_formed :
    interface = switchFormedAt cycle.sourceIntersection.state

def switchRealizesAt
    (source : SwitchState) :
    SwitchRealizesInterface
      (strongTerminalCycleFromIntersection
        switchCompleteness
        switchRoundTripCoherence
        (SwitchIntersection.mk source))
      (switchFormedAt source) where
  interface_eq_formed := rfl

/-! ## Executable, proof-relevant repair -/

/-- Repair instructions are indexed by both provenance and target interface. -/
inductive SwitchRepairInstruction :
    SwitchState -> SwitchInterface -> Type where
  | restoreLeft :
      SwitchRepairInstruction
        SwitchState.leftToRight
        SwitchInterface.leftPole
  | restoreRight :
      SwitchRepairInstruction
        SwitchState.rightToLeft
        SwitchInterface.rightPole
  | preserveMarker (source : SwitchState) :
      SwitchRepairInstruction source SwitchInterface.marker

/-- A repair contains an instruction whose indices determine its result. -/
structure SwitchRepair (interface : SwitchInterface) where
  source : SwitchState
  instruction : SwitchRepairInstruction source interface

/-- Execute a repair instruction. -/
def SwitchRepairInstruction.apply
    {source : SwitchState}
    {interface : SwitchInterface} :
    SwitchRepairInstruction source interface -> SwitchInterface
  | SwitchRepairInstruction.restoreLeft => SwitchInterface.leftPole
  | SwitchRepairInstruction.restoreRight => SwitchInterface.rightPole
  | SwitchRepairInstruction.preserveMarker _ => SwitchInterface.marker

/-- Execute a proof-relevant repair. -/
def SwitchRepair.apply
    {interface : SwitchInterface}
    (repair : SwitchRepair interface) :
    SwitchInterface :=
  repair.instruction.apply

/-- Executing an indexed repair returns exactly its indexed interface. -/
theorem SwitchRepair.apply_correct
    {interface : SwitchInterface}
    (repair : SwitchRepair interface) :
    repair.apply = interface := by
  cases repair with
  | mk source instruction =>
      cases instruction <;> rfl

def switchRepairAt
    (source : SwitchState) :
    SwitchRepair (switchFormedAt source) := by
  cases source with
  | leftToRight =>
      exact ⟨SwitchState.leftToRight, SwitchRepairInstruction.restoreLeft⟩
  | rightToLeft =>
      exact ⟨SwitchState.rightToLeft, SwitchRepairInstruction.restoreRight⟩

def switchMarkerRepair
    (source : SwitchState) :
    SwitchRepair SwitchInterface.marker :=
  ⟨source, SwitchRepairInstruction.preserveMarker source⟩

/-! ## A locally recovered return at every state -/

def switchLocalRecovery
    (source : SwitchState) :
    LocalProjectiveRecovery
      SwitchInterface
      SwitchVisible
      switchProjection
      SwitchRepair :=
  let repair := switchRepairAt source
  { formed := switchFormedAt source
    shadow := switchShadowAt source
    sameProjection := switchPoles_sameProjection source
    separated := switchFormed_ne_shadow source
    repair := repair
    recovered := repair.apply
    recovered_eq_formed := repair.apply_correct }

theorem switchLocalRecovery_recovered_eq_apply
    (source : SwitchState) :
    (switchLocalRecovery source).recovered =
      (switchLocalRecovery source).repair.apply :=
  rfl

def switchLocallyRecoveredDynamicReturn
    (source : SwitchState) :
    LocallyRecoveredDynamicReturn
      switchCompleteness
      switchRoundTripCoherence
      SwitchState.leftToRight
      SwitchState
      SwitchInterface
      SwitchInterfaceWitness
      SwitchRealizesInterface
      SwitchVisible
      switchProjection
      SwitchRepair where
  formedReturn :=
    { source := source
      intersection := SwitchIntersection.mk source }
  formed :=
    { interface := switchFormedAt source
      witness := switchInterfaceWitnessAt source }
  realizes := switchRealizesAt source
  localRecovery := switchLocalRecovery source
  localRecovery_sameInterface := rfl

theorem switchReturn_source
    (source : SwitchState) :
    (switchLocallyRecoveredDynamicReturn source).formedReturn.source = source :=
  rfl

theorem switchReturn_intersection_state
    (source : SwitchState) :
    (switchLocallyRecoveredDynamicReturn source).formedReturn.intersection.state =
      source :=
  rfl

/-! ## Closed intrinsic family and causal transition -/

def switchIntrinsicDynamicReturnFamily :
    IntrinsicDynamicReturnFamily
      switchCompleteness
      switchRoundTripCoherence
      SwitchState.leftToRight
      SwitchState
      SwitchInterface
      SwitchInterfaceWitness
      SwitchRealizesInterface
      SwitchVisible
      switchProjection
      SwitchRepair where
  initial := SwitchState.leftToRight
  returnAt := switchLocallyRecoveredDynamicReturn
  returnAt_source := switchReturn_source

/--
The model transition consumes the causal package and inspects the authorized
use stored in its bilateral memory before alternating the state.
-/
def switchAdvance :
    (Σ source : SwitchState,
      DynamicGapCausalState switchIntrinsicDynamicReturnFamily source) ->
    SwitchState := by
  intro input
  cases input with
  | mk source causalState =>
      cases causalState.memory.use.classify with
      | inl reflexive =>
          exact (switchFormed_ne_shadow source reflexive.down).elim
      | inr causes =>
          cases causes.2
          cases source with
          | leftToRight => exact SwitchState.rightToLeft
          | rightToLeft => exact SwitchState.leftToRight

def switchGapDrivenDynamicSystem :
    GapDrivenDynamicSystem switchIntrinsicDynamicReturnFamily where
  advance := switchAdvance

theorem switchAdvance_leftToRight_of_currentUse :
    switchAdvance
      (GapDrivenDynamicSystem.canonicalCausalInput
        (family := switchIntrinsicDynamicReturnFamily)
        SwitchState.leftToRight) =
      SwitchState.rightToLeft :=
  rfl

theorem switchAdvance_rightToLeft_of_currentUse :
    switchAdvance
      (GapDrivenDynamicSystem.canonicalCausalInput
        (family := switchIntrinsicDynamicReturnFamily)
        SwitchState.rightToLeft) =
      SwitchState.leftToRight :=
  rfl

theorem switchNext_leftToRight :
    switchGapDrivenDynamicSystem.next SwitchState.leftToRight =
      SwitchState.rightToLeft :=
  rfl

theorem switchNext_rightToLeft :
    switchGapDrivenDynamicSystem.next SwitchState.rightToLeft =
      SwitchState.leftToRight :=
  rfl

def switchGenuineDynamicUsageVariation :
    GenuineDynamicUsageVariation switchGapDrivenDynamicSystem where
  source := SwitchState.leftToRight
  source_ne_next := by
    rw [switchNext_leftToRight]
    exact switchState_left_ne_right
  next_formed_eq_current_shadow := by
    rw [switchNext_leftToRight]
    rfl
  next_shadow_eq_current_formed := by
    rw [switchNext_leftToRight]
    rfl

def switchGenuinelyVaryingDynamicUsageSystem :
    GenuinelyVaryingDynamicUsageSystem
      switchCompleteness
      switchRoundTripCoherence
      SwitchState.leftToRight
      SwitchState
      SwitchInterface
      SwitchInterfaceWitness
      SwitchRealizesInterface
      SwitchVisible
      switchProjection
      SwitchRepair where
  family := switchIntrinsicDynamicReturnFamily
  dynamics := switchGapDrivenDynamicSystem
  variation := switchGenuineDynamicUsageVariation

/-! ## Closed nontriviality and strictness results -/

theorem switchContextsSeparated :
    switchIntrinsicDynamicReturnFamily.contextAt SwitchState.leftToRight =
      switchIntrinsicDynamicReturnFamily.contextAt SwitchState.rightToLeft ->
    False := by
  intro sameContext
  exact
    switchState_left_ne_right
      (congrArg DynamicUsageContext.source sameContext)

def switchHasUse_leftToRight :
    HasUse
      (dynamicRelaxedRegimeOfReturnFamily
        switchIntrinsicDynamicReturnFamily)
      (switchIntrinsicDynamicReturnFamily.contextAt SwitchState.leftToRight)
      SwitchInterface.leftPole
      SwitchInterface.rightPole :=
  Nonempty.intro
    (dynamicGapAuthorizedUse
      switchIntrinsicDynamicReturnFamily
      SwitchState.leftToRight)

theorem switchNotHasUse_rightToLeft_at_leftToRight :
    HasUse
      (dynamicRelaxedRegimeOfReturnFamily
        switchIntrinsicDynamicReturnFamily)
      (switchIntrinsicDynamicReturnFamily.contextAt SwitchState.leftToRight)
      SwitchInterface.rightPole
      SwitchInterface.leftPole ->
    False := by
  intro use
  exact
    Nonempty.elim use
      (fun impossible =>
        dynamicGapUse_noBackward
          switchIntrinsicDynamicReturnFamily
          (switchIntrinsicDynamicReturnFamily.contextAt
            SwitchState.leftToRight)
          impossible)

def switchHasUse_rightToLeft :
    HasUse
      (dynamicRelaxedRegimeOfReturnFamily
        switchIntrinsicDynamicReturnFamily)
      (switchIntrinsicDynamicReturnFamily.contextAt SwitchState.rightToLeft)
      SwitchInterface.rightPole
      SwitchInterface.leftPole :=
  Nonempty.intro
    (dynamicGapAuthorizedUse
      switchIntrinsicDynamicReturnFamily
      SwitchState.rightToLeft)

theorem switchNotHasUse_leftToRight_at_rightToLeft :
    HasUse
      (dynamicRelaxedRegimeOfReturnFamily
        switchIntrinsicDynamicReturnFamily)
      (switchIntrinsicDynamicReturnFamily.contextAt SwitchState.rightToLeft)
      SwitchInterface.leftPole
      SwitchInterface.rightPole ->
    False := by
  intro use
  exact
    Nonempty.elim use
      (fun impossible =>
        dynamicGapUse_noBackward
          switchIntrinsicDynamicReturnFamily
          (switchIntrinsicDynamicReturnFamily.contextAt
            SwitchState.rightToLeft)
          impossible)

theorem switchProjection_notInformationConserving
    (conserving :
      ProjectionInformationConserving
        SwitchInterface
        SwitchVisible
        switchProjection) :
    False :=
  projectionObstruction_notInformationConserving
    { left := SwitchInterface.leftPole
      right := SwitchInterface.rightPole
      sameProjection := switchProjection_poles_same
      separatedInterface := switchInterface_left_ne_right }
    conserving

theorem switchDynamicRegime_notExactProjective
    (representation :
      ExactProjectiveRepresentation
        (dynamicRelaxedRegimeOfReturnFamily
          switchIntrinsicDynamicReturnFamily)) :
    False :=
  dynamicRelaxedRegime_not_exactProjective
    switchIntrinsicDynamicReturnFamily
    representation

theorem switchInitialCycle_preservesIntersection :
    intersectionOfComplete
        switchCompleteness
        (completeOfIntersection
          switchCompleteness
          (switchIntrinsicDynamicReturnFamily.contextAt
            SwitchState.leftToRight).intersection) =
      (switchIntrinsicDynamicReturnFamily.contextAt
        SwitchState.leftToRight).intersection :=
  (dynamicUsageMemory
    switchIntrinsicDynamicReturnFamily
    (switchIntrinsicDynamicReturnFamily.contextAt
      SwitchState.leftToRight)).sourceIntersection_preserved

def switchIterationMemory (n : Nat) :
    DynamicUsageMemory
      switchIntrinsicDynamicReturnFamily
      (switchGapDrivenDynamicSystem.iterationContext n) :=
  switchGapDrivenDynamicSystem.iterationMemory n

theorem switchTwoSteps_returnToInitial :
    switchGapDrivenDynamicSystem.iterateSource
      2
      SwitchState.leftToRight =
    SwitchState.leftToRight :=
  rfl

theorem switchTwoSteps_return (source : SwitchState) :
    switchGapDrivenDynamicSystem.iterateSource 2 source = source := by
  cases source <;> rfl

def switchLeftWitness :
    SwitchInterfaceWitness SwitchInterface.leftPole :=
  switchInterfaceWitnessAt SwitchState.leftToRight

def switchRightWitness :
    SwitchInterfaceWitness SwitchInterface.rightPole :=
  switchInterfaceWitnessAt SwitchState.rightToLeft

def switchLeftRepair : SwitchRepair SwitchInterface.leftPole :=
  switchRepairAt SwitchState.leftToRight

def switchRightRepair : SwitchRepair SwitchInterface.rightPole :=
  switchRepairAt SwitchState.rightToLeft

/-- The closed result retains the system and every substantive witness. -/
structure SwitchDynamicRelaxationSynthesis where
  varyingSystem :
    GenuinelyVaryingDynamicUsageSystem
      switchCompleteness
      switchRoundTripCoherence
      SwitchState.leftToRight
      SwitchState
      SwitchInterface
      SwitchInterfaceWitness
      SwitchRealizesInterface
      SwitchVisible
      switchProjection
      SwitchRepair
  varyingSystem_eq :
    varyingSystem = switchGenuinelyVaryingDynamicUsageSystem
  initialStep :
    DynamicUsageStep
      switchGapDrivenDynamicSystem
      SwitchState.leftToRight
  projection_nonconstant :
    switchProjection SwitchInterface.leftPole =
      switchProjection SwitchInterface.marker ->
    False
  currentUse :
    DynamicGapUse
      switchIntrinsicDynamicReturnFamily
      (switchIntrinsicDynamicReturnFamily.contextAt
        SwitchState.leftToRight)
      SwitchInterface.leftPole
      SwitchInterface.rightPole
  nextUse :
    DynamicGapUse
      switchIntrinsicDynamicReturnFamily
      (switchIntrinsicDynamicReturnFamily.contextAt
        SwitchState.rightToLeft)
      SwitchInterface.rightPole
      SwitchInterface.leftPole
  leftRepair : SwitchRepair SwitchInterface.leftPole
  rightRepair : SwitchRepair SwitchInterface.rightPole
  notExactProjective :
    ExactProjectiveRepresentation.{0, q, 0, 0, 0, 0, 0, 0, 0}
        (dynamicRelaxedRegimeOfReturnFamily
          switchIntrinsicDynamicReturnFamily) ->
      False

def switchDynamicRelaxationSynthesis :
    SwitchDynamicRelaxationSynthesis where
  varyingSystem := switchGenuinelyVaryingDynamicUsageSystem
  varyingSystem_eq := rfl
  initialStep :=
    dynamicUsageStep
      switchGapDrivenDynamicSystem
      SwitchState.leftToRight
  projection_nonconstant := switchProjection_left_ne_marker
  currentUse :=
    dynamicGapAuthorizedUse
      switchIntrinsicDynamicReturnFamily
      SwitchState.leftToRight
  nextUse :=
    dynamicGapAuthorizedUse
      switchIntrinsicDynamicReturnFamily
      SwitchState.rightToLeft
  leftRepair := switchLeftRepair
  rightRepair := switchRightRepair
  notExactProjective := switchDynamicRegime_notExactProjective

end DynamicRelaxedUsageModel
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.DynamicRelaxedUsageModel.SwitchState
#print axioms Meta.DynamicRelaxedUsageModel.SwitchInterface
#print axioms Meta.DynamicRelaxedUsageModel.switchProjection
#print axioms Meta.DynamicRelaxedUsageModel.switchProjection_nonconstant
#print axioms Meta.DynamicRelaxedUsageModel.SwitchComplete
#print axioms Meta.DynamicRelaxedUsageModel.SwitchForward
#print axioms Meta.DynamicRelaxedUsageModel.SwitchBackward
#print axioms Meta.DynamicRelaxedUsageModel.SwitchIntersection
#print axioms Meta.DynamicRelaxedUsageModel.SwitchInterfaceWitness
#print axioms Meta.DynamicRelaxedUsageModel.SwitchRepairInstruction
#print axioms Meta.DynamicRelaxedUsageModel.SwitchRepair
#print axioms Meta.DynamicRelaxedUsageModel.SwitchRepair.apply_correct
#print axioms Meta.DynamicRelaxedUsageModel.switchLocalRecovery_recovered_eq_apply
#print axioms Meta.DynamicRelaxedUsageModel.switchIntrinsicDynamicReturnFamily
#print axioms Meta.DynamicRelaxedUsageModel.switchAdvance
#print axioms Meta.DynamicRelaxedUsageModel.switchGapDrivenDynamicSystem
#print axioms Meta.DynamicRelaxedUsageModel.switchNext_leftToRight
#print axioms Meta.DynamicRelaxedUsageModel.switchNext_rightToLeft
#print axioms Meta.DynamicRelaxedUsageModel.switchGenuineDynamicUsageVariation
#print axioms Meta.DynamicRelaxedUsageModel.switchGenuinelyVaryingDynamicUsageSystem
#print axioms Meta.DynamicRelaxedUsageModel.switchNotHasUse_rightToLeft_at_leftToRight
#print axioms Meta.DynamicRelaxedUsageModel.switchNotHasUse_leftToRight_at_rightToLeft
#print axioms Meta.DynamicRelaxedUsageModel.switchProjection_notInformationConserving
#print axioms Meta.DynamicRelaxedUsageModel.switchDynamicRegime_notExactProjective
#print axioms Meta.DynamicRelaxedUsageModel.switchInitialCycle_preservesIntersection
#print axioms Meta.DynamicRelaxedUsageModel.switchTwoSteps_return
#print axioms Meta.DynamicRelaxedUsageModel.SwitchDynamicRelaxationSynthesis
#print axioms Meta.DynamicRelaxedUsageModel.switchDynamicRelaxationSynthesis
/- AXIOM_AUDIT_END -/
