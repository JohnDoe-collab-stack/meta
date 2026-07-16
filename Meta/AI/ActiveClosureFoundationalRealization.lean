import Meta.AI.FiniteActiveSemanticClosure
import Meta.Semantics.Soundness
import Meta.Semantics.IdentityConservativity
import Meta.Semantics.DynamicFoundationalStability

/-!
# Foundational realization of finite active semantic closure

The objects in this module are calculated from the finite active-closure orbit.
The contextual semantics, the dynamic return family, and the repair algebra do
not carry an independent successor.  Compatibility is represented
contravariantly because information growth shrinks the compatible-world fiber;
closure predicates are represented covariantly because repaired knowledge is
preserved by the orbit.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace Foundational

open ClosedStabilityTheorem
open DynamicRelaxedUsage
open RelaxedSemantics
open Finite

/-! ## The exact finite orbit -/

inductive OrbitStage where
  | initial
  | firstRepaired
  | secondRepaired
  | closed
  deriving DecidableEq

def stateAt : OrbitStage -> ClosedState
  | .initial => state0
  | .firstRepaired => state1
  | .secondRepaired => state2
  | .closed => state3

def nextStage : OrbitStage -> OrbitStage
  | .initial => .firstRepaired
  | .firstRepaired => .secondRepaired
  | .secondRepaired => .closed
  | .closed => .closed

def indexAt : OrbitStage -> Index
  | .initial => .first
  | .firstRepaired => .second
  | .secondRepaired => .third
  | .closed => .third

theorem stateAt_nextStage (stage : OrbitStage) :
    stateAt (nextStage stage) = finiteSystem.nextState (stateAt stage) := by
  cases stage <;> rfl

inductive ReachableStage : OrbitStage -> Type where
  | initial : ReachableStage .initial
  | first : ReachableStage .firstRepaired
  | second : ReachableStage .secondRepaired
  | terminal : ReachableStage .closed

def reachableStage (stage : OrbitStage) : ReachableStage stage := by
  cases stage
  · exact .initial
  · exact .first
  · exact .second
  · exact .terminal

inductive OpenOrbitStage where
  | first
  | second
  | third
  deriving DecidableEq

def OpenOrbitStage.source : OpenOrbitStage -> OrbitStage
  | .first => .initial
  | .second => .firstRepaired
  | .third => .secondRepaired

def OpenOrbitStage.target : OpenOrbitStage -> OrbitStage
  | .first => .firstRepaired
  | .second => .secondRepaired
  | .third => .closed

def OpenOrbitStage.gap
    (openStage : OpenOrbitStage) :
    Gap (stateAt openStage.source).agent := by
  cases openStage
  · exact gap0
  · exact gap1
  · exact gap2

def OpenOrbitStage.typedGap
    (openStage : OpenOrbitStage) :
    TypedSemanticGap
      finiteSystem
      finiteEvidenceRealization
      (stateAt openStage.source)
      openStage.gap := by
  cases openStage
  · exact typedGap0
  · exact typedGap1
  · exact typedGap2

def OpenOrbitStage.authorization
    (openStage : OpenOrbitStage) :
    AuthorizedUse
      (stateAt openStage.source).agent
      openStage.gap := by
  cases openStage
  · exact use0
  · exact use1
  · exact use2

def OpenOrbitStage.operationalTransport
    (openStage : OpenOrbitStage) :
    AuthorizedTransport
      (stateAt openStage.source).agent
      openStage.gap
      openStage.authorization := by
  cases openStage
  · exact transport0
  · exact transport1
  · exact transport2

def OpenOrbitStage.closure
    (openStage : OpenOrbitStage) :
    GapClosedBy
      finiteSystem
      (stateAt openStage.source)
      openStage.gap
      (stateAt openStage.target) := by
  cases openStage
  · exact gap0ClosedByState1
  · exact gap1ClosedByState2
  · exact gap2ClosedByState3

def OpenOrbitStage.strictFiberReduction
    (openStage : OpenOrbitStage) :
    StrictCompatibleFiberReduction
      (stateAt openStage.source)
      (stateAt openStage.target) := by
  cases openStage
  · exact state0_to_state1_strictFiberReduction
  · exact state1_to_state2_strictFiberReduction
  · exact state2_to_state3_strictFiberReduction

structure ValidatedOrbitGap (openStage : OpenOrbitStage) where
  sourceReachable : ReachableStage openStage.source
  targetReachable : ReachableStage openStage.target
  gap : Gap (stateAt openStage.source).agent
  gap_eq : gap = openStage.gap
  detected : finiteSystem.detectGap (stateAt openStage.source).agent = .open gap
  typed :
    TypedSemanticGap
      finiteSystem finiteEvidenceRealization
      (stateAt openStage.source) gap
  authorization : AuthorizedUse (stateAt openStage.source).agent gap
  authorization_eq :
    authorization = finiteSystem.authorize (stateAt openStage.source).agent gap
  operationalTransport :
    AuthorizedTransport
      (stateAt openStage.source).agent gap authorization
  operationalTransport_eq :
    operationalTransport =
      finiteSystem.executeTransport
        (stateAt openStage.source).agent gap authorization
  closure :
    GapClosedBy
      finiteSystem (stateAt openStage.source) gap (stateAt openStage.target)
  strictFiberReduction :
    StrictCompatibleFiberReduction
      (stateAt openStage.source) (stateAt openStage.target)

def validatedOrbitGap
    (openStage : OpenOrbitStage) :
    ValidatedOrbitGap openStage := by
  cases openStage with
  | first =>
      exact
        { sourceReachable := .initial
          targetReachable := .first
          gap := gap0
          gap_eq := rfl
          detected := state0_detects_gap0
          typed := typedGap0
          authorization := use0
          authorization_eq := rfl
          operationalTransport := transport0
          operationalTransport_eq := rfl
          closure := gap0ClosedByState1
          strictFiberReduction := state0_to_state1_strictFiberReduction }
  | second =>
      exact
        { sourceReachable := .first
          targetReachable := .second
          gap := gap1
          gap_eq := rfl
          detected := state1_detects_gap1
          typed := typedGap1
          authorization := use1
          authorization_eq := rfl
          operationalTransport := transport1
          operationalTransport_eq := rfl
          closure := gap1ClosedByState2
          strictFiberReduction := state1_to_state2_strictFiberReduction }
  | third =>
      exact
        { sourceReachable := .second
          targetReachable := .terminal
          gap := gap2
          gap_eq := rfl
          detected := state2_detects_gap2
          typed := typedGap2
          authorization := use2
          authorization_eq := rfl
          operationalTransport := transport2
          operationalTransport_eq := rfl
          closure := gap2ClosedByState3
          strictFiberReduction := state2_to_state3_strictFiberReduction }

/-! ## Intrinsic repairs and the generic repair algebra -/

abbrev FirstIntrinsicRepair :=
  IntrinsicRepair
    finiteData finiteGapLanguage finiteTransportLanguage
    finiteInteractionLanguage
    state0.agent gap0 use0 transport0 query0 response0

abbrev SecondIntrinsicRepair :=
  IntrinsicRepair
    finiteData finiteGapLanguage finiteTransportLanguage
    finiteInteractionLanguage
    state1.agent gap1 use1 transport1 query1 response1

abbrev ThirdIntrinsicRepair :=
  IntrinsicRepair
    finiteData finiteGapLanguage finiteTransportLanguage
    finiteInteractionLanguage
    state2.agent gap2 use2 transport2 query2 response2

structure StableClosureRepair where
  closedDetector : finiteSystem.detectGap state3.agent = .closed
  retained : RepairsRetained state3.agent
  knownClosed :
    KnownClosedOn
      finiteSystem state3.agent state3.agent.candidate repairedPrefix3
  stable : finiteSystem.nextState state3 = state3

inductive OrbitRepair : OrbitStage -> Type where
  | first
      (repair : FirstIntrinsicRepair)
      (repair_eq : repair = repair0) :
      OrbitRepair .initial
  | second
      (repair : SecondIntrinsicRepair)
      (repair_eq : repair = repair1) :
      OrbitRepair .firstRepaired
  | third
      (repair : ThirdIntrinsicRepair)
      (repair_eq : repair = repair2) :
      OrbitRepair .secondRepaired
  | stable (certificate : StableClosureRepair) : OrbitRepair .closed

def orbitRepairAt : (stage : OrbitStage) -> OrbitRepair stage
  | .initial => .first repair0 rfl
  | .firstRepaired => .second repair1 rfl
  | .secondRepaired => .third repair2 rfl
  | .closed =>
      .stable
        { closedDetector := state3_is_closed
          retained := state3_retainsRepairs
          knownClosed := state3_knownClosedOnRepairedPrefix
          stable := state3_is_stable }

def executeOrbitRepair : {stage : OrbitStage} -> OrbitRepair stage -> OrbitStage
  | .initial, .first _ _ => .firstRepaired
  | .firstRepaired, .second _ _ => .secondRepaired
  | .secondRepaired, .third _ _ => .closed
  | .closed, .stable _ => .closed

theorem executeOrbitRepair_eq_nextStage
    {stage : OrbitStage}
    (repair : OrbitRepair stage) :
    executeOrbitRepair repair = nextStage stage := by
  cases repair <;> rfl

theorem executeOrbitRepair_realizes_activeNext
    {stage : OrbitStage}
    (repair : OrbitRepair stage) :
    stateAt (executeOrbitRepair repair) =
      finiteSystem.nextState (stateAt stage) := by
  rw [executeOrbitRepair_eq_nextStage]
  exact stateAt_nextStage stage

inductive ClosureBranch where
  | active

abbrev closureCompleteness : BidirectionalCompleteness ClosureBranch where
  Complete := fun _ => OrbitStage
  Forward := fun _ => AgentState
  Backward := fun _ => World
  Intersection := fun _ => OrbitStage
  forwardOfComplete := fun _ stage => (stateAt stage).agent
  backwardOfComplete := fun _ stage => (stateAt stage).world
  intersectionOfComplete := fun _ stage => stage
  completeOfIntersection := fun _ stage => stage

def closureCoherence : RoundTripCoherence closureCompleteness where
  completeRoundTrip := { complete_stable := by intro branch stage; rfl }
  intersectionRoundTrip := { intersection_stable := by intro branch stage; rfl }

inductive OrbitInterface where
  | semantic (stage : OrbitStage)
  | syntactic (stage : OrbitStage)

def OrbitInterface.project : OrbitInterface -> Index
  | .semantic stage => indexAt stage
  | .syntactic stage => indexAt stage

theorem orbitInterface_separated (stage : OrbitStage) :
    OrbitInterface.semantic stage = .syntactic stage -> False := by
  intro equality
  cases equality

inductive OrbitInterfaceWitness : OrbitInterface -> Type where
  | semantic (stage : OrbitStage) :
      OrbitInterfaceWitness (.semantic stage)

structure OrbitCycleRealization
    (cycle :
      StrongTerminalCycleFromIntersection
        closureCompleteness ClosureBranch.active)
    (interface : OrbitInterface) where
  stage : OrbitStage
  source_eq : cycle.sourceIntersection = stage
  interface_eq : interface = .semantic stage

inductive OrbitInterfaceRepair : OrbitInterface -> Type where
  | semantic
      {stage : OrbitStage}
      (repair : OrbitRepair stage) :
      OrbitInterfaceRepair (.semantic stage)

def orbitDynamicReturn
    (stage : OrbitStage) :
    LocallyRecoveredDynamicReturn
      closureCompleteness closureCoherence ClosureBranch.active
      OrbitStage OrbitInterface OrbitInterfaceWitness
      OrbitCycleRealization Index OrbitInterface.project OrbitInterfaceRepair where
  formedReturn :=
    { source := stage
      intersection := stage }
  formed :=
    { interface := .semantic stage
      witness := .semantic stage }
  realizes :=
    { stage := stage
      source_eq := rfl
      interface_eq := rfl }
  localRecovery :=
    { formed := .semantic stage
      shadow := .syntactic stage
      sameProjection := rfl
      separated := orbitInterface_separated stage
      repair := .semantic (orbitRepairAt stage)
      recovered := .semantic stage
      recovered_eq_formed := rfl }
  localRecovery_sameInterface := rfl

def orbitReturnFamily :
    IntrinsicDynamicReturnFamily
      closureCompleteness closureCoherence ClosureBranch.active
      OrbitStage OrbitInterface OrbitInterfaceWitness OrbitCycleRealization
      Index OrbitInterface.project OrbitInterfaceRepair where
  initial := .initial
  returnAt := orbitDynamicReturn
  returnAt_source := fun _ => rfl

def executeInterfaceRepair
    (stage : OrbitStage)
    (causalState : DynamicGapCausalState orbitReturnFamily stage)
    (repair :
      OrbitInterfaceRepair (orbitReturnFamily.formedAt stage)) :
    OrbitStage := by
  cases causalState.memory.use.classify with
  | inl reflexive =>
      exact (orbitReturnFamily.separatedAt stage reflexive.down).elim
  | inr causes =>
      cases causes.2
      cases repair with
      | semantic orbitRepair => exact executeOrbitRepair orbitRepair

def orbitGapRepairAlgebra : GapRepairAlgebra orbitReturnFamily where
  executeRepair := executeInterfaceRepair

theorem orbitGapRepairAlgebra_next_eq_nextStage
    (stage : OrbitStage) :
    orbitGapRepairAlgebra.next stage = nextStage stage := by
  cases stage <;> rfl

theorem orbitGapRepairAlgebra_next_realizes_activeNext
    (stage : OrbitStage) :
    stateAt (orbitGapRepairAlgebra.next stage) =
      finiteSystem.nextState (stateAt stage) := by
  rw [orbitGapRepairAlgebra_next_eq_nextStage]
  exact stateAt_nextStage stage

/-! ## Contextual interpretation of operational gap poles -/

inductive ContextPrecision where
  | coarse
  | fine
  deriving DecidableEq

structure ClosureContext where
  precision : ContextPrecision
  stage : OrbitStage
  deriving DecidableEq

inductive PrecisionSub : ContextPrecision -> ContextPrecision -> Type where
  | coarseIdentity : PrecisionSub .coarse .coarse
  | fineIdentity : PrecisionSub .fine .fine
  | refine : PrecisionSub .fine .coarse

def precisionIdentity : (precision : ContextPrecision) ->
    PrecisionSub precision precision
  | .coarse => .coarseIdentity
  | .fine => .fineIdentity

def precisionCompose :
    {theta delta gamma : ContextPrecision} ->
    PrecisionSub theta delta ->
    PrecisionSub delta gamma ->
    PrecisionSub theta gamma
  | _, _, _, .coarseIdentity, .coarseIdentity => .coarseIdentity
  | _, _, _, .fineIdentity, .fineIdentity => .fineIdentity
  | _, _, _, .fineIdentity, .refine => .refine
  | _, _, _, .refine, .coarseIdentity => .refine

theorem precisionCompose_leftIdentity
    {delta gamma : ContextPrecision}
    (substitution : PrecisionSub delta gamma) :
    precisionCompose (precisionIdentity delta) substitution = substitution := by
  cases substitution <;> rfl

theorem precisionCompose_rightIdentity
    {delta gamma : ContextPrecision}
    (substitution : PrecisionSub delta gamma) :
    precisionCompose substitution (precisionIdentity gamma) = substitution := by
  cases substitution <;> rfl

theorem precisionCompose_associativity
    {omega theta delta gamma : ContextPrecision}
    (first : PrecisionSub omega theta)
    (second : PrecisionSub theta delta)
    (third : PrecisionSub delta gamma) :
    precisionCompose (precisionCompose first second) third =
      precisionCompose first (precisionCompose second third) := by
  cases first <;> cases second <;> cases third <;> rfl

structure ClosureSub (delta gamma : ClosureContext) where
  stage_eq : delta.stage = gamma.stage
  precisionSub : PrecisionSub delta.precision gamma.precision

theorem ClosureSub.ext
    {delta gamma : ClosureContext}
    (first second : ClosureSub delta gamma)
    (precision_eq : first.precisionSub = second.precisionSub) :
    first = second := by
  cases first
  cases second
  cases precision_eq
  rfl

def closureIdentity (context : ClosureContext) : ClosureSub context context :=
  { stage_eq := rfl
    precisionSub := precisionIdentity context.precision }

def closureRefinement (stage : OrbitStage) :
    ClosureSub
      { precision := .fine, stage := stage }
      { precision := .coarse, stage := stage } where
  stage_eq := rfl
  precisionSub := .refine

def closureCompose
    {theta delta gamma : ClosureContext}
    (first : ClosureSub theta delta)
    (second : ClosureSub delta gamma) :
    ClosureSub theta gamma where
  stage_eq := first.stage_eq.trans second.stage_eq
  precisionSub := precisionCompose first.precisionSub second.precisionSub

abbrev closureContextCategory : ContextCategory where
  Ctx := ClosureContext
  Sub := ClosureSub
  identity := closureIdentity
  compose := closureCompose

def closureContextLaws : LawfulContextCategory closureContextCategory where
  leftIdentity := by
    intro delta gamma substitution
    apply ClosureSub.ext
    exact precisionCompose_leftIdentity substitution.precisionSub
  rightIdentity := by
    intro delta gamma substitution
    apply ClosureSub.ext
    exact precisionCompose_rightIdentity substitution.precisionSub
  associativity := by
    intro omega theta delta gamma first second third
    apply ClosureSub.ext
    exact precisionCompose_associativity
      first.precisionSub second.precisionSub third.precisionSub

theorem coarseContext_ne_fineContext (stage : OrbitStage) :
    ({ precision := ContextPrecision.coarse, stage := stage } : ClosureContext) =
      { precision := ContextPrecision.fine, stage := stage } -> False := by
  intro equality
  have precisionEquality := congrArg ClosureContext.precision equality
  cases precisionEquality

def genuineContextRefinement (stage : OrbitStage) :
    NontrivialContextChange closureContextCategory where
  source := { precision := .fine, stage := stage }
  target := { precision := .coarse, stage := stage }
  substitution := closureRefinement stage
  contextsSeparated := fun equality =>
    coarseContext_ne_fineContext stage equality.symm

inductive ClosureSort where
  | gap

inductive Pole where
  | origin
  | destination
  deriving DecidableEq

theorem originPole_ne_destinationPole :
    Pole.origin = .destination -> False := by
  intro equality
  cases equality

def poleInterface (context : ClosureContext) : Pole -> OrbitInterface
  | .origin => .semantic context.stage
  | .destination => .syntactic context.stage

abbrev closureTermLanguage :
    IndexedTermLanguage closureContextCategory ClosureSort where
  Term := fun _ _ => Pole
  reindexTerm := fun {_ _} _ {_} pole => pole

def closureTermLanguageLaws :
    LawfulIndexedTermLanguage closureTermLanguage where
  reindexIdentity := by intro context sort pole; rfl
  reindexComposition := by
    intro theta delta gamma first second sort pole
    rfl

structure ContextualGapCertificate
    (context : ClosureContext)
    (openStage : OpenOrbitStage) where
  source_eq : openStage.source = context.stage
  validated : ValidatedOrbitGap openStage

def contextualGapCertificate
    (openStage : OpenOrbitStage) :
    ContextualGapCertificate
      { precision := .fine, stage := openStage.source }
      openStage where
  source_eq := rfl
  validated := validatedOrbitGap openStage

inductive PoleSeparation
    (context : ClosureContext) : Pole -> Pole -> Type where
  | current
      (openStage : OpenOrbitStage)
      (certificate : ContextualGapCertificate context openStage) :
      PoleSeparation context .origin .destination

inductive PoleCoordination
    (context : ClosureContext) : Pole -> Pole -> Type where
  | current
      (openStage : OpenOrbitStage)
      (certificate : ContextualGapCertificate context openStage) :
      PoleCoordination context .origin .destination

inductive PoleUse
    (context : ClosureContext) : Pole -> Pole -> Type where
  | identity (pole : Pole) : PoleUse context pole pole
  | authorizedGap
      (openStage : OpenOrbitStage)
      (certificate : ContextualGapCertificate context openStage)
      (authorization :
        AuthorizedUse
          (stateAt openStage.source).agent
          openStage.gap)
      (authorization_eq :
        authorization = openStage.authorization) :
      PoleUse context .origin .destination

def PoleUse.compose :
    {context : ClosureContext} ->
    {left middle right : Pole} ->
    PoleUse context left middle ->
    PoleUse context middle right ->
    PoleUse context left right
  | _, _, _, _, .identity _, second => second
  | _, _, _, _,
      .authorizedGap openStage certificate authorization authorization_eq,
      .identity _ =>
        .authorizedGap
          openStage certificate authorization authorization_eq

theorem PoleUse.leftIdentity
    {context : ClosureContext}
    {left right : Pole}
    (use : PoleUse context left right) :
    PoleUse.compose (.identity left) use = use := by
  cases use <;> rfl

theorem PoleUse.rightIdentity
    {context : ClosureContext}
    {left right : Pole}
    (use : PoleUse context left right) :
    PoleUse.compose use (.identity right) = use := by
  cases use <;> rfl

theorem PoleUse.associativity
    {context : ClosureContext}
    {firstPoint secondPoint thirdPoint fourthPoint : Pole}
    (first : PoleUse context firstPoint secondPoint)
    (second : PoleUse context secondPoint thirdPoint)
    (third : PoleUse context thirdPoint fourthPoint) :
    PoleUse.compose (PoleUse.compose first second) third =
      PoleUse.compose first (PoleUse.compose second third) := by
  cases first <;> cases second <;> cases third <;> rfl

def poleUseOfNoncontractive
    {context : ClosureContext}
    {left right : Pole}
    (_separation : PoleSeparation context left right)
    (coordination : PoleCoordination context left right) :
    PoleUse context left right := by
  cases coordination with
  | current openStage certificate =>
      exact .authorizedGap
        openStage certificate openStage.authorization rfl

theorem poleUse_noBackward
    (context : ClosureContext) :
    PoleUse context .destination .origin -> False := by
  intro use
  cases use

inductive PoleReading where
  | formed
  | visible

def PoleOutput : PoleReading -> Type
  | .formed => Pole
  | .visible => Index

def readPole (context : ClosureContext) :
    (reading : PoleReading) -> Pole -> PoleOutput reading
  | .formed, pole => pole
  | .visible, _ => indexAt context.stage

structure VisibleTransportStep (context : ClosureContext) where
  openStage : OpenOrbitStage
  certificate : ContextualGapCertificate context openStage
  authorization :
    AuthorizedUse
      (stateAt openStage.source).agent
      openStage.gap
  authorization_eq : authorization = openStage.authorization
  operationalTransport :
    AuthorizedTransport
      (stateAt openStage.source).agent
      openStage.gap
      openStage.authorization
  operationalTransport_eq :
    operationalTransport = openStage.operationalTransport

structure VisiblePoleTransport
    (context : ClosureContext) (left right : Index) where
  sameIndex : left = right
  steps : List (VisibleTransportStep context)

def VisiblePoleTransport.identity
    (context : ClosureContext)
    (index : Index) :
    VisiblePoleTransport context index index where
  sameIndex := rfl
  steps := []

def VisiblePoleTransport.authorizedGap
    {context : ClosureContext}
    (openStage : OpenOrbitStage)
    (certificate : ContextualGapCertificate context openStage)
    (authorization :
      AuthorizedUse
        (stateAt openStage.source).agent
        openStage.gap)
    (authorization_eq : authorization = openStage.authorization) :
    VisiblePoleTransport context
      (readPole context .visible .origin)
      (readPole context .visible .destination) where
  sameIndex := rfl
  steps :=
    [{ openStage := openStage
       certificate := certificate
       authorization := authorization
       authorization_eq := authorization_eq
       operationalTransport := openStage.operationalTransport
       operationalTransport_eq := rfl }]

theorem VisiblePoleTransport.ext
    {context : ClosureContext}
    {left right : Index}
    {first second : VisiblePoleTransport context left right}
    (steps_eq : first.steps = second.steps) :
    first = second := by
  cases first with
  | mk firstSame firstSteps =>
      cases second with
      | mk secondSame secondSteps =>
          cases steps_eq
          rfl

def VisiblePoleTransport.compose
    {context : ClosureContext}
    {left middle right : Index}
    (first : VisiblePoleTransport context left middle)
    (second : VisiblePoleTransport context middle right) :
    VisiblePoleTransport context left right where
  sameIndex := first.sameIndex.trans second.sameIndex
  steps := first.steps ++ second.steps

def PoleOutputRelation
    (context : ClosureContext)
    (reading : PoleReading) :
    PoleOutput reading -> PoleOutput reading -> Type :=
  match reading with
  | .formed => PoleUse context
  | .visible => VisiblePoleTransport context

def visibleTransportOfPoleUse :
    {context : ClosureContext} ->
    {left right : Pole} ->
    PoleUse context left right ->
    VisiblePoleTransport context
      (readPole context .visible left)
      (readPole context .visible right)
  | context, _, _, .identity _ =>
      .identity context (indexAt context.stage)
  | _, _, _,
      .authorizedGap openStage certificate authorization authorization_eq =>
        .authorizedGap
          openStage certificate authorization authorization_eq

theorem visibleTransportOfPoleUse_compose
    {context : ClosureContext}
    {left middle right : Pole}
    (first : PoleUse context left middle)
    (second : PoleUse context middle right) :
    visibleTransportOfPoleUse (PoleUse.compose first second) =
      VisiblePoleTransport.compose
        (visibleTransportOfPoleUse first)
        (visibleTransportOfPoleUse second) := by
  apply VisiblePoleTransport.ext
  cases first <;> cases second <;> rfl

def reindexPoleSeparation
    {delta gamma : ClosureContext}
    (substitution : ClosureSub delta gamma)
    {left right : Pole}
    (separation : PoleSeparation gamma left right) :
    PoleSeparation delta left right := by
  cases separation with
  | current openStage certificate =>
      exact .current openStage
        { source_eq := certificate.source_eq.trans substitution.stage_eq.symm
          validated := certificate.validated }

def reindexPoleCoordination
    {delta gamma : ClosureContext}
    (substitution : ClosureSub delta gamma)
    {left right : Pole}
    (coordination : PoleCoordination gamma left right) :
    PoleCoordination delta left right := by
  cases coordination with
  | current openStage certificate =>
      exact .current openStage
        { source_eq := certificate.source_eq.trans substitution.stage_eq.symm
          validated := certificate.validated }

def reindexPoleUse
    {delta gamma : ClosureContext}
    (substitution : ClosureSub delta gamma)
    : {left right : Pole} ->
      PoleUse gamma left right -> PoleUse delta left right
  | _, _, .identity pole => .identity pole
  | _, _, .authorizedGap openStage certificate authorization authorization_eq =>
      .authorizedGap openStage
        { source_eq := certificate.source_eq.trans substitution.stage_eq.symm
          validated := certificate.validated }
        authorization authorization_eq

def reindexVisibleTransportStep
    {delta gamma : ClosureContext}
    (substitution : ClosureSub delta gamma)
    (step : VisibleTransportStep gamma) :
    VisibleTransportStep delta where
  openStage := step.openStage
  certificate :=
    { source_eq :=
        step.certificate.source_eq.trans substitution.stage_eq.symm
      validated := step.certificate.validated }
  authorization := step.authorization
  authorization_eq := step.authorization_eq
  operationalTransport := step.operationalTransport
  operationalTransport_eq := step.operationalTransport_eq

def reindexVisibleTransportSteps
    {delta gamma : ClosureContext}
    (substitution : ClosureSub delta gamma) :
    List (VisibleTransportStep gamma) ->
      List (VisibleTransportStep delta)
  | [] => []
  | step :: rest =>
      reindexVisibleTransportStep substitution step ::
        reindexVisibleTransportSteps substitution rest

def reindexVisibleTransport
    {delta gamma : ClosureContext}
    (substitution : ClosureSub delta gamma)
    {left right : Index}
    (relation : VisiblePoleTransport gamma left right) :
    VisiblePoleTransport delta left right where
  sameIndex := relation.sameIndex
  steps := reindexVisibleTransportSteps substitution relation.steps

def reindexVisiblePoleTransport
    {delta gamma : ClosureContext}
    (substitution : ClosureSub delta gamma)
    {left right : Pole}
    (relation :
      VisiblePoleTransport gamma
        (readPole gamma .visible left)
        (readPole gamma .visible right)) :
    VisiblePoleTransport delta
      (readPole delta .visible left)
      (readPole delta .visible right) where
  sameIndex := rfl
  steps := reindexVisibleTransportSteps substitution relation.steps

theorem visibleTransportOfPoleUse_reindex
    {delta gamma : ClosureContext}
    (substitution : ClosureSub delta gamma)
    {left right : Pole}
    (use : PoleUse gamma left right) :
    reindexVisiblePoleTransport substitution
        (visibleTransportOfPoleUse use) =
      visibleTransportOfPoleUse (reindexPoleUse substitution use) := by
  apply VisiblePoleTransport.ext
  cases use <;> rfl

theorem VisiblePoleTransport.leftIdentity
    {context : ClosureContext}
    {left right : Index}
    (relation : VisiblePoleTransport context left right) :
    VisiblePoleTransport.compose
        (VisiblePoleTransport.identity context left) relation =
      relation := by
  cases relation
  rfl

theorem listAppendNil
    {Element : Type}
    (elements : List Element) :
    elements ++ [] = elements := by
  induction elements with
  | nil => rfl
  | cons head tail inductionHypothesis =>
      exact congrArg (List.cons head) inductionHypothesis

theorem listAppendAssociative
    {Element : Type}
    (first second third : List Element) :
    (first ++ second) ++ third = first ++ (second ++ third) := by
  induction first with
  | nil => rfl
  | cons head tail inductionHypothesis =>
      exact congrArg (List.cons head) inductionHypothesis

theorem VisiblePoleTransport.rightIdentity
    {context : ClosureContext}
    {left right : Index}
    (relation : VisiblePoleTransport context left right) :
    VisiblePoleTransport.compose relation
        (VisiblePoleTransport.identity context right) =
      relation :=
  VisiblePoleTransport.ext (listAppendNil relation.steps)

theorem VisiblePoleTransport.associativity
    {context : ClosureContext}
    {firstIndex secondIndex thirdIndex fourthIndex : Index}
    (first : VisiblePoleTransport context firstIndex secondIndex)
    (second : VisiblePoleTransport context secondIndex thirdIndex)
    (third : VisiblePoleTransport context thirdIndex fourthIndex) :
    VisiblePoleTransport.compose
        (VisiblePoleTransport.compose first second) third =
      VisiblePoleTransport.compose first
        (VisiblePoleTransport.compose second third) :=
  VisiblePoleTransport.ext
    (listAppendAssociative first.steps second.steps third.steps)

abbrev closureContextualRegime :
    ContextualRelaxedRegime closureContextCategory closureTermLanguage where
  Read := fun _ _ => PoleReading
  defaultRead := fun _ _ => .formed
  Out := fun _ _ reading => PoleOutput reading
  read := fun {context _} reading pole => readPole context reading pole
  Sep := fun {context _} left right => PoleSeparation context left right
  Coord := fun {context _} left right => PoleCoordination context left right
  Use := fun {context _} left right => PoleUse context left right
  OutRel := fun {context _} reading => PoleOutputRelation context reading
  identityUse := fun {_ _} pole => .identity pole
  composeUse := fun {_ _ _ _ _} first second => first.compose second
  useOfNoncontractive := fun {_ _ _ _} separation coordination =>
    poleUseOfNoncontractive separation coordination
  transport := by
    intro context sort left right use reading
    cases reading with
    | formed => exact use
    | visible => exact visibleTransportOfPoleUse use
  outIdentity := by
    intro context sort reading pole
    cases reading with
    | formed => exact .identity pole
    | visible =>
        exact .identity context (readPole context .visible pole)
  outCompose := by
    intro context sort reading left middle right first second
    cases reading with
    | formed => exact first.compose second
    | visible => exact first.compose second
  reindexRead := fun {_ _} _ {_} reading => reading
  reindexSep := fun {_ _} substitution {_ _ _} separation =>
    reindexPoleSeparation substitution separation
  reindexCoord := fun {_ _} substitution {_ _ _} coordination =>
    reindexPoleCoordination substitution coordination
  reindexUse := fun {_ _} substitution {_ _ _} use =>
    reindexPoleUse substitution use
  reindexOutRel := by
    intro delta gamma substitution sort reading left right relation
    cases reading with
    | formed => exact reindexPoleUse substitution relation
    | visible => exact reindexVisiblePoleTransport substitution relation

def closureContextualRegimeLaws :
    LawfulContextualRelaxedRegime closureContextualRegime where
  contextLaws := closureContextLaws
  termLaws := closureTermLanguageLaws
  separationRefutesIdentity := by
    intro context sort left right separation equality
    cases separation
    cases equality
  useLeftIdentity := by
    intro context sort left right use
    exact use.leftIdentity
  useRightIdentity := by
    intro context sort left right use
    exact use.rightIdentity
  useAssociativity := by
    intro context sort firstPoint secondPoint thirdPoint fourthPoint
      first second third
    exact PoleUse.associativity first second third
  outLeftIdentity := by
    intro context sort reading left right relation
    cases reading with
    | formed => cases relation <;> rfl
    | visible => exact relation.leftIdentity
  outRightIdentity := by
    intro context sort reading left right relation
    cases reading with
    | formed => cases relation <;> rfl
    | visible => exact relation.rightIdentity
  outAssociativity := by
    intro context sort reading firstPoint secondPoint thirdPoint fourthPoint
      first second third
    cases reading with
    | formed => cases first <;> cases second <;> cases third <;> rfl
    | visible => exact VisiblePoleTransport.associativity first second third
  transportIdentity := by
    intro context sort reading pole
    cases reading with
    | formed => rfl
    | visible => cases pole <;> rfl
  transportComposition := by
    intro context sort reading left middle right first second
    cases reading with
    | formed => cases first <;> cases second <;> rfl
    | visible => exact visibleTransportOfPoleUse_compose first second
  reindexReadIdentity := by
    intro context sort reading
    rfl
  reindexReadComposition := by
    intro theta delta gamma first second sort reading
    rfl
  transportReindexing := by
    intro delta gamma substitution sort reading left right use
    cases reading with
    | formed => rfl
    | visible => exact visibleTransportOfPoleUse_reindex substitution use

/-! ## Covariant admissible predicates and independent syntax -/

structure MonotonePolePredicate where
  Holds : Pole -> Prop
  preserves :
    {context : ClosureContext} ->
    {left right : Pole} ->
    PoleUse context left right ->
    Holds left ->
    Holds right

def polePredicateTop : MonotonePolePredicate where
  Holds := fun _ => True
  preserves := fun _ proof => proof

def polePredicateBottom : MonotonePolePredicate where
  Holds := fun _ => False
  preserves := fun _ impossible => impossible

def polePredicateConjunction
    (left right : MonotonePolePredicate) : MonotonePolePredicate where
  Holds := fun pole => left.Holds pole ∧ right.Holds pole
  preserves := fun use proof =>
    ⟨left.preserves use proof.1, right.preserves use proof.2⟩

def reachedRightPole : MonotonePolePredicate where
  Holds
    | .origin => False
    | .destination => True
  preserves := by
    intro context left right use proof
    cases use with
    | identity => exact proof
    | authorizedGap => exact True.intro

def constantPolePredicate (proposition : Prop) : MonotonePolePredicate where
  Holds := fun _ => proposition
  preserves := fun _ proof => proof

def correctPolePredicate
    (world : World)
    (candidate : Candidate)
    (index : Index) : MonotonePolePredicate :=
  constantPolePredicate (Finite.CorrectAt world candidate index)

def closedOnPolePredicate
    (world : World)
    (candidate : Candidate)
    (domain : List Index) : MonotonePolePredicate :=
  constantPolePredicate
    (ClosedOn finiteData world candidate domain)

def compatiblePredicateOfView
    (stage : OrbitStage)
    (world : World) : MonotonePolePredicate :=
  constantPolePredicate
    (finiteSystem.CompatibleWithViewHistory (stateAt stage).agent world)

def knownCorrectPredicateOfViewIndex
    (stage : OrbitStage)
    (index : Index) : MonotonePolePredicate :=
  constantPolePredicate
    (KnownCorrectAt
      finiteSystem (stateAt stage).agent
      (stateAt stage).agent.candidate index)

def predicateOfIndex
    (stage : OrbitStage)
    (index : Index) : MonotonePolePredicate :=
  knownCorrectPredicateOfViewIndex stage index

def knownClosedPolePredicate
    (stage : OrbitStage)
    (domain : List Index) : MonotonePolePredicate :=
  constantPolePredicate
    (KnownClosedOn
      finiteSystem (stateAt stage).agent
      (stateAt stage).agent.candidate domain)

def fiberDeterminatePolePredicate
    (stage : OrbitStage)
    (index : Index) : MonotonePolePredicate :=
  constantPolePredicate
    (FiberDeterminateAt finiteSystem (stateAt stage).agent index)

def gapClosedPolePredicate
    (openStage : OpenOrbitStage)
    (after : OrbitStage) : MonotonePolePredicate :=
  constantPolePredicate
    (GapClosedBy
      finiteSystem (stateAt openStage.source) openStage.gap (stateAt after))

abbrev closureDoctrine :
    AdmissiblePredicateDoctrine closureContextualRegime where
  Pred := fun _ _ => MonotonePolePredicate
  Holds := fun predicate pole => predicate.Holds pole
  top := fun _ _ => polePredicateTop
  bottom := fun _ _ => polePredicateBottom
  conjunction := fun left right => polePredicateConjunction left right
  reindexPred := fun {_ _} _ {_} predicate => predicate
  substituteUse :=
    fun {_ _ _ _} use predicate proof => predicate.preserves use proof

def closureDoctrineLaws :
    LawfulAdmissiblePredicateDoctrine closureDoctrine where
  holdsTop := by intro context sort pole; exact True.intro
  holdsBottomRefuted := fun impossible => impossible
  holdsConjunctionLeft := fun proof => proof.1
  holdsConjunctionRight := fun proof => proof.2
  holdsConjunction := fun left right => ⟨left, right⟩
  reindexHolds := by
    intro delta gamma substitution sort predicate pole proof
    exact proof
  reindexReflectsHolds := by
    intro delta gamma substitution sort predicate pole proof
    exact proof
  substitutionIdentity := by
    intro context sort pole predicate proof
    exact Subsingleton.elim _ _
  substitutionComposition := by
    intro context sort left middle right first second predicate proof
    exact Subsingleton.elim _ _

inductive ClosurePredicateAtom (context : ClosureContext) where
  | reachedRight
  | correct (world : World) (candidate : Candidate) (index : Index)
  | closedOn (world : World) (candidate : Candidate) (domain : List Index)
  | compatible (world : World)
  | knownCorrect (index : Index)
  | knownClosed (domain : List Index)
  | fiberDeterminate (index : Index)
  | gapClosed (openStage : OpenOrbitStage)

abbrev closureSignature : RelaxedTransportSignature closureContextCategory where
  Ty := ClosureSort
  SubstitutionAtom := ClosureSub
  TermAtom := fun _ _ => Pole
  SeparationAtom := fun {context _} left right =>
    PoleSeparation context left right
  CoordinationAtom := fun {context _} left right =>
    PoleCoordination context left right
  PredicateAtom := fun context _ => ClosurePredicateAtom context

def closureInterpretation :
    RelaxedInterpretation
      closureSignature closureTermLanguage
      closureContextualRegime closureDoctrine where
  substitutionAtom := fun substitution => substitution
  termAtom := fun pole => pole
  separationAtom := fun separation => separation
  coordinationAtom := fun coordination => coordination
  predicateAtom := by
    intro context sort atom
    cases atom with
    | reachedRight => exact reachedRightPole
    | correct world candidate index =>
        exact correctPolePredicate world candidate index
    | closedOn world candidate domain =>
        exact closedOnPolePredicate world candidate domain
    | compatible world =>
        exact compatiblePredicateOfView context.stage world
    | knownCorrect index =>
        exact knownCorrectPredicateOfViewIndex context.stage index
    | knownClosed domain =>
        exact knownClosedPolePredicate context.stage domain
    | fiberDeterminate index =>
        exact fiberDeterminatePolePredicate context.stage index
    | gapClosed openStage =>
        exact gapClosedPolePredicate openStage context.stage

def closureIdentityConservativity :
    StrictIdentityConservativity closureSignature :=
  strictIdentityConservativity closureSignature

theorem closureSyntax_consistent
    (context : ClosureContext) :
    ClosedRelaxedContradiction closureSignature context -> False :=
  closedRelaxedConsistency closureDoctrineLaws closureInterpretation context

/-! ## Exact alignment of operational and contextual objects -/

def contextOfState (stage : OrbitStage) : ClosureContext :=
  { precision := .fine, stage := stage }

def leftTermOfGap (_openStage : OpenOrbitStage) : Pole := .origin

def rightTermOfGap (_openStage : OpenOrbitStage) : Pole := .destination

def separationOfGap
    (openStage : OpenOrbitStage) :
    PoleSeparation (contextOfState openStage.source)
      (leftTermOfGap openStage) (rightTermOfGap openStage) :=
  .current openStage (contextualGapCertificate openStage)

def coordinationOfGap
    (openStage : OpenOrbitStage) :
    PoleCoordination (contextOfState openStage.source)
      (leftTermOfGap openStage) (rightTermOfGap openStage) :=
  .current openStage (contextualGapCertificate openStage)

def regimeUseOfAuthorization
    (openStage : OpenOrbitStage) :
    PoleUse (contextOfState openStage.source)
      (leftTermOfGap openStage) (rightTermOfGap openStage) :=
  @closureContextualRegime.useOfNoncontractive
    (contextOfState openStage.source)
    ClosureSort.gap
    (leftTermOfGap openStage)
    (rightTermOfGap openStage)
    (separationOfGap openStage)
    (coordinationOfGap openStage)

theorem regimeUseOfAuthorization_eq
    (openStage : OpenOrbitStage) :
    regimeUseOfAuthorization openStage =
      .authorizedGap
        openStage
        (contextualGapCertificate openStage)
        openStage.authorization
        rfl := by
  cases openStage <;> rfl

def regimeTransportOfExecution
    (openStage : OpenOrbitStage) :
    PoleOutputRelation
      (contextOfState openStage.source)
      .visible
      (readPole (contextOfState openStage.source) .visible
        (leftTermOfGap openStage))
      (readPole (contextOfState openStage.source) .visible
        (rightTermOfGap openStage)) :=
  @closureContextualRegime.transport
    (contextOfState openStage.source)
    ClosureSort.gap
    (leftTermOfGap openStage)
    (rightTermOfGap openStage)
    (regimeUseOfAuthorization openStage)
    .visible

theorem operationalTransport_reaches_sameIndex
    (openStage : OpenOrbitStage) :
    (validatedOrbitGap openStage).operationalTransport.output.requestedIndex =
      (validatedOrbitGap openStage).gap.index :=
  (validatedOrbitGap openStage).operationalTransport.evidence.reachesGap

theorem contextualTerms_project_to_operationalIndex
    (openStage : OpenOrbitStage) :
    readPole (contextOfState openStage.source) .visible
        (leftTermOfGap openStage) =
      (validatedOrbitGap openStage).gap.index ∧
    readPole (contextOfState openStage.source) .visible
        (rightTermOfGap openStage) =
      (validatedOrbitGap openStage).gap.index := by
  cases openStage <;> exact ⟨rfl, rfl⟩

theorem reachedRightPole_nonconstant :
    reachedRightPole.Holds .origin -> False :=
  fun impossible => impossible

theorem reachedRightPole_holds_right :
    reachedRightPole.Holds .destination :=
  True.intro

/-! ## Variance of epistemic judgments along the repair orbit -/

inductive OrbitAdvance : OrbitStage -> OrbitStage -> Type where
  | first
      (validated : ValidatedOrbitGap .first)
      (repair : OrbitRepair .initial) :
      OrbitAdvance .initial .firstRepaired
  | second
      (validated : ValidatedOrbitGap .second)
      (repair : OrbitRepair .firstRepaired) :
      OrbitAdvance .firstRepaired .secondRepaired
  | third
      (validated : ValidatedOrbitGap .third)
      (repair : OrbitRepair .secondRepaired) :
      OrbitAdvance .secondRepaired .closed
  | stable (certificate : StableClosureRepair) :
      OrbitAdvance .closed .closed

def orbitAdvanceAt :
    (stage : OrbitStage) -> OrbitAdvance stage (nextStage stage)
  | .initial => .first (validatedOrbitGap .first) (orbitRepairAt .initial)
  | .firstRepaired =>
      .second (validatedOrbitGap .second) (orbitRepairAt .firstRepaired)
  | .secondRepaired =>
      .third (validatedOrbitGap .third) (orbitRepairAt .secondRepaired)
  | .closed =>
      .stable
        { closedDetector := state3_is_closed
          retained := state3_retainsRepairs
          knownClosed := state3_knownClosedOnRepairedPrefix
          stable := state3_is_stable }

structure CovariantOrbitPredicate where
  Holds : OrbitStage -> Prop
  preserves :
    {source target : OrbitStage} ->
    OrbitAdvance source target ->
    Holds source ->
    Holds target

structure ContravariantOrbitPredicate where
  Holds : OrbitStage -> Prop
  reflects :
    {source target : OrbitStage} ->
    OrbitAdvance source target ->
    Holds target ->
    Holds source

def actualCompatibleAt (stage : OrbitStage) :
    finiteSystem.CompatibleWithViewHistory
      (stateAt stage).agent (stateAt stage).world := by
  cases stage
  · exact state0_actualCompatible
  · exact state1_actualCompatible
  · exact state2_actualCompatible
  · exact state3_actualCompatible

def repairedPrefix : OrbitStage -> List Index
  | .initial => []
  | .firstRepaired => repairedPrefix1
  | .secondRepaired => repairedPrefix2
  | .closed => repairedPrefix3

def compatibilityPredicateOfWorld
    (world : World) : ContravariantOrbitPredicate where
  Holds := fun stage =>
    finiteSystem.CompatibleWithViewHistory (stateAt stage).agent world
  reflects := by
    intro source target advance compatible
    cases advance with
    | first validated repair =>
        exact validated.strictFiberReduction.laterImpliesEarlier world compatible
    | second validated repair =>
        exact validated.strictFiberReduction.laterImpliesEarlier world compatible
    | third validated repair =>
        exact validated.strictFiberReduction.laterImpliesEarlier world compatible
    | stable certificate => exact compatible

theorem compatibility_not_covariant :
    (∀ {source target : OrbitStage},
      OrbitAdvance source target ->
      finiteSystem.CompatibleWithViewHistory
        (stateAt source).agent firstEliminatedWorld ->
      finiteSystem.CompatibleWithViewHistory
        (stateAt target).agent firstEliminatedWorld) ->
    False := by
  intro preserves
  exact state0_to_state1_strictFiberReduction.incompatibleAfter
    (preserves (orbitAdvanceAt .initial)
      state0_to_state1_strictFiberReduction.compatibleBefore)

theorem correctAt_preserved_next
    (stage : OrbitStage)
    (index : Index) :
    Finite.CorrectAt
        (stateAt stage).world (stateAt stage).agent.candidate index ->
      Finite.CorrectAt
        (stateAt (nextStage stage)).world
        (stateAt (nextStage stage)).agent.candidate index := by
  cases stage <;> cases index <;> intro correct
  · rfl
  · cases correct
  · cases correct
  · exact correct
  · rfl
  · cases correct
  · exact correct
  · exact correct
  · rfl
  · exact correct
  · exact correct
  · exact correct

def correctPredicateOfIndex
    (index : Index) : CovariantOrbitPredicate where
  Holds := fun stage =>
    Finite.CorrectAt
      (stateAt stage).world (stateAt stage).agent.candidate index
  preserves := by
    intro source target advance correct
    cases advance with
    | first => exact correctAt_preserved_next .initial index correct
    | second => exact correctAt_preserved_next .firstRepaired index correct
    | third => exact correctAt_preserved_next .secondRepaired index correct
    | stable => exact correct

theorem knownCorrectAt_preserved_next
    (stage : OrbitStage)
    (index : Index) :
    KnownCorrectAt
        finiteSystem (stateAt stage).agent
        (stateAt stage).agent.candidate index ->
      KnownCorrectAt
        finiteSystem (stateAt (nextStage stage)).agent
        (stateAt (nextStage stage)).agent.candidate index := by
  cases stage with
  | initial =>
      cases index with
      | first =>
          intro _
          exact gap0ClosedByState1.knownCorrect
      | second =>
          intro known
          have impossible := known state0.world state0_actualCompatible
          cases impossible
      | third =>
          intro known
          have impossible := known state0.world state0_actualCompatible
          cases impossible
  | firstRepaired =>
      cases index with
      | first =>
          intro known world compatible
          exact known world
            (state1_to_state2_strictFiberReduction.laterImpliesEarlier
              world compatible)
      | second =>
          intro _
          exact gap1ClosedByState2.knownCorrect
      | third =>
          intro known
          have impossible := known state1.world state1_actualCompatible
          cases impossible
  | secondRepaired =>
      cases index with
      | first =>
          intro known world compatible
          exact known world
            (state2_to_state3_strictFiberReduction.laterImpliesEarlier
              world compatible)
      | second =>
          intro known world compatible
          exact known world
            (state2_to_state3_strictFiberReduction.laterImpliesEarlier
              world compatible)
      | third =>
          intro _
          exact gap2ClosedByState3.knownCorrect
  | closed =>
      intro known
      exact known

def knownCorrectPredicateOfIndex
    (index : Index) : CovariantOrbitPredicate where
  Holds := fun stage =>
    KnownCorrectAt
      finiteSystem (stateAt stage).agent
      (stateAt stage).agent.candidate index
  preserves := by
    intro source target advance known
    cases advance with
    | first => exact knownCorrectAt_preserved_next .initial index known
    | second => exact knownCorrectAt_preserved_next .firstRepaired index known
    | third => exact knownCorrectAt_preserved_next .secondRepaired index known
    | stable => exact known

theorem knownClosedOn_preserved_next
    (stage : OrbitStage)
    (domain : List Index) :
    KnownClosedOn
        finiteSystem (stateAt stage).agent
        (stateAt stage).agent.candidate domain ->
      KnownClosedOn
        finiteSystem (stateAt (nextStage stage)).agent
        (stateAt (nextStage stage)).agent.candidate domain := by
  intro known index membership
  exact knownCorrectAt_preserved_next stage index (known index membership)

def knownClosedPredicate
    (domain : List Index) : CovariantOrbitPredicate where
  Holds := fun stage =>
    KnownClosedOn
      finiteSystem (stateAt stage).agent
      (stateAt stage).agent.candidate domain
  preserves := by
    intro source target advance known
    cases advance with
    | first => exact knownClosedOn_preserved_next .initial domain known
    | second =>
        exact knownClosedOn_preserved_next .firstRepaired domain known
    | third =>
        exact knownClosedOn_preserved_next .secondRepaired domain known
    | stable => exact known

theorem fiberDeterminateAt_preserved_next
    (stage : OrbitStage)
    (index : Index) :
    FiberDeterminateAt finiteSystem (stateAt stage).agent index ->
      FiberDeterminateAt
        finiteSystem (stateAt (nextStage stage)).agent index := by
  intro determinate leftWorld rightWorld leftCompatible rightCompatible
  cases stage with
  | initial =>
      exact determinate leftWorld rightWorld
        (state0_to_state1_strictFiberReduction.laterImpliesEarlier
          leftWorld leftCompatible)
        (state0_to_state1_strictFiberReduction.laterImpliesEarlier
          rightWorld rightCompatible)
  | firstRepaired =>
      exact determinate leftWorld rightWorld
        (state1_to_state2_strictFiberReduction.laterImpliesEarlier
          leftWorld leftCompatible)
        (state1_to_state2_strictFiberReduction.laterImpliesEarlier
          rightWorld rightCompatible)
  | secondRepaired =>
      exact determinate leftWorld rightWorld
        (state2_to_state3_strictFiberReduction.laterImpliesEarlier
          leftWorld leftCompatible)
        (state2_to_state3_strictFiberReduction.laterImpliesEarlier
          rightWorld rightCompatible)
  | closed => exact determinate leftWorld rightWorld leftCompatible rightCompatible

def fiberDeterminatePredicateOfIndex
    (index : Index) : CovariantOrbitPredicate where
  Holds := fun stage =>
    FiberDeterminateAt finiteSystem (stateAt stage).agent index
  preserves := by
    intro source target advance determinate
    cases advance with
    | first => exact fiberDeterminateAt_preserved_next .initial index determinate
    | second =>
        exact fiberDeterminateAt_preserved_next .firstRepaired index determinate
    | third =>
        exact fiberDeterminateAt_preserved_next .secondRepaired index determinate
    | stable => exact determinate

def gapClosedPredicate
    (openStage : OpenOrbitStage) : CovariantOrbitPredicate where
  Holds := fun stage =>
    GapClosedBy
      finiteSystem (stateAt openStage.source) openStage.gap (stateAt stage)
  preserves := by
    intro source target advance closed
    refine
      { worldPreserved := ?_
        actualCompatible := actualCompatibleAt target
        knownCorrect := ?_ }
    · cases openStage <;> cases advance <;> rfl
    · cases advance with
      | first =>
          exact knownCorrectAt_preserved_next .initial openStage.gap.index
            closed.knownCorrect
      | second =>
          exact knownCorrectAt_preserved_next .firstRepaired
            openStage.gap.index closed.knownCorrect
      | third =>
          exact knownCorrectAt_preserved_next .secondRepaired
            openStage.gap.index closed.knownCorrect
      | stable => exact closed.knownCorrect

theorem canonicalGapClosure_holds
    (openStage : OpenOrbitStage) :
    (gapClosedPredicate openStage).Holds openStage.target :=
  openStage.closure

/-! ## Proof-relevant operational alignments -/

def evidenceKindOfGap
    (openStage : OpenOrbitStage) : OperationalGapKind :=
  (validatedOrbitGap openStage).gap.kind

def poleRealizationOfGap
    (openStage : OpenOrbitStage) : Pole -> ClosureInterface finiteData
  | .origin => (validatedOrbitGap openStage).typed.leftPole
  | .destination => (validatedOrbitGap openStage).typed.rightPole

theorem poleRealizationOfGap_left
    (openStage : OpenOrbitStage) :
    poleRealizationOfGap openStage (leftTermOfGap openStage) =
      (validatedOrbitGap openStage).typed.leftPole :=
  rfl

theorem poleRealizationOfGap_right
    (openStage : OpenOrbitStage) :
    poleRealizationOfGap openStage (rightTermOfGap openStage) =
      (validatedOrbitGap openStage).typed.rightPole :=
  rfl

theorem poleRealizationOfGap_left_projects
    (openStage : OpenOrbitStage) :
    ClosureInterface.project
        (poleRealizationOfGap openStage (leftTermOfGap openStage)) =
      (validatedOrbitGap openStage).gap.index :=
  (validatedOrbitGap openStage).typed.leftProjects

theorem poleRealizationOfGap_right_projects
    (openStage : OpenOrbitStage) :
    ClosureInterface.project
        (poleRealizationOfGap openStage (rightTermOfGap openStage)) =
      (validatedOrbitGap openStage).gap.index :=
  (validatedOrbitGap openStage).typed.rightProjects

theorem poleRealizationOfGap_separated
    (openStage : OpenOrbitStage) :
    poleRealizationOfGap openStage (leftTermOfGap openStage) =
        poleRealizationOfGap openStage (rightTermOfGap openStage) ->
      False :=
  (validatedOrbitGap openStage).typed.separated

structure OperationalGapAlignment (openStage : OpenOrbitStage) where
  context : ClosureContext
  context_eq : context = contextOfState openStage.source
  validated : ValidatedOrbitGap openStage
  validated_eq : validated = validatedOrbitGap openStage
  evidenceKind : OperationalGapKind
  evidenceKind_eq : evidenceKind = validated.gap.kind
  leftTerm : Pole
  rightTerm : Pole
  leftTerm_eq : leftTerm = leftTermOfGap openStage
  rightTerm_eq : rightTerm = rightTermOfGap openStage
  separation : PoleSeparation context leftTerm rightTerm
  coordination : PoleCoordination context leftTerm rightTerm
  leftRealization : ClosureInterface finiteData
  rightRealization : ClosureInterface finiteData
  leftRealization_eq : leftRealization = validated.typed.leftPole
  rightRealization_eq : rightRealization = validated.typed.rightPole
  leftProjects : ClosureInterface.project leftRealization = validated.gap.index
  rightProjects : ClosureInterface.project rightRealization = validated.gap.index
  realizedSeparated : leftRealization = rightRealization -> False
  contextualProjection :
    readPole context .visible leftTerm = readPole context .visible rightTerm

def operationalGapAlignment
    (openStage : OpenOrbitStage) : OperationalGapAlignment openStage where
  context := contextOfState openStage.source
  context_eq := rfl
  validated := validatedOrbitGap openStage
  validated_eq := rfl
  evidenceKind := evidenceKindOfGap openStage
  evidenceKind_eq := rfl
  leftTerm := leftTermOfGap openStage
  rightTerm := rightTermOfGap openStage
  leftTerm_eq := rfl
  rightTerm_eq := rfl
  separation := separationOfGap openStage
  coordination := coordinationOfGap openStage
  leftRealization := poleRealizationOfGap openStage (leftTermOfGap openStage)
  rightRealization := poleRealizationOfGap openStage (rightTermOfGap openStage)
  leftRealization_eq := rfl
  rightRealization_eq := rfl
  leftProjects := poleRealizationOfGap_left_projects openStage
  rightProjects := poleRealizationOfGap_right_projects openStage
  realizedSeparated := poleRealizationOfGap_separated openStage
  contextualProjection := rfl

structure AuthorizedUseAlignment (openStage : OpenOrbitStage) where
  operational :
    AuthorizedUse
      (stateAt openStage.source).agent (validatedOrbitGap openStage).gap
  operational_eq : operational = (validatedOrbitGap openStage).authorization
  contextual :
    PoleUse (contextOfState openStage.source)
      (leftTermOfGap openStage) (rightTermOfGap openStage)
  contextual_eq : contextual = regimeUseOfAuthorization openStage
  authorizationRecovered :
    contextual =
      .authorizedGap openStage (contextualGapCertificate openStage)
        openStage.authorization rfl
  inverseRefuted :
    PoleUse (contextOfState openStage.source)
      (rightTermOfGap openStage) (leftTermOfGap openStage) -> False

def authorizedUseAlignment
    (openStage : OpenOrbitStage) : AuthorizedUseAlignment openStage where
  operational := (validatedOrbitGap openStage).authorization
  operational_eq := rfl
  contextual := regimeUseOfAuthorization openStage
  contextual_eq := rfl
  authorizationRecovered := regimeUseOfAuthorization_eq openStage
  inverseRefuted := poleUse_noBackward _

theorem regimeTransport_steps_eq_singleton
    (openStage : OpenOrbitStage) :
    (regimeTransportOfExecution openStage).steps =
      [{ openStage := openStage
         certificate := contextualGapCertificate openStage
         authorization := openStage.authorization
         authorization_eq := rfl
         operationalTransport := openStage.operationalTransport
         operationalTransport_eq := rfl }] := by
  cases openStage <;> rfl

structure OperationalTransportAlignment (openStage : OpenOrbitStage) where
  operational :
    AuthorizedTransport
      (stateAt openStage.source).agent
      (validatedOrbitGap openStage).gap
      (validatedOrbitGap openStage).authorization
  operational_eq : operational = (validatedOrbitGap openStage).operationalTransport
  contextual :
    VisiblePoleTransport
      (contextOfState openStage.source)
      (readPole (contextOfState openStage.source) .visible
        (leftTermOfGap openStage))
      (readPole (contextOfState openStage.source) .visible
        (rightTermOfGap openStage))
  contextual_eq : contextual = regimeTransportOfExecution openStage
  contextualSteps : List (VisibleTransportStep (contextOfState openStage.source))
  contextualSteps_eq : contextualSteps = contextual.steps
  exactStep :
    contextualSteps =
      [{ openStage := openStage
         certificate := contextualGapCertificate openStage
         authorization := openStage.authorization
         authorization_eq := rfl
         operationalTransport := openStage.operationalTransport
         operationalTransport_eq := rfl }]
  reachesGap : operational.output.requestedIndex =
    (validatedOrbitGap openStage).gap.index

def operationalTransportAlignment
    (openStage : OpenOrbitStage) : OperationalTransportAlignment openStage where
  operational := (validatedOrbitGap openStage).operationalTransport
  operational_eq := rfl
  contextual := regimeTransportOfExecution openStage
  contextual_eq := rfl
  contextualSteps := (regimeTransportOfExecution openStage).steps
  contextualSteps_eq := rfl
  exactStep := regimeTransport_steps_eq_singleton openStage
  reachesGap := operationalTransport_reaches_sameIndex openStage

inductive CanonicalIntrinsicRepair where
  | first (repair : FirstIntrinsicRepair) (repair_eq : repair = repair0)
  | second (repair : SecondIntrinsicRepair) (repair_eq : repair = repair1)
  | third (repair : ThirdIntrinsicRepair) (repair_eq : repair = repair2)

def CanonicalIntrinsicRepair.stage : CanonicalIntrinsicRepair -> OrbitStage
  | .first _ _ => .initial
  | .second _ _ => .firstRepaired
  | .third _ _ => .secondRepaired

def CanonicalIntrinsicRepair.toOrbitRepair :
    (repair : CanonicalIntrinsicRepair) -> OrbitRepair repair.stage
  | .first repair repair_eq => .first repair repair_eq
  | .second repair repair_eq => .second repair repair_eq
  | .third repair repair_eq => .third repair repair_eq

def repairOfIntrinsic
    (repair : CanonicalIntrinsicRepair) :
    OrbitInterfaceRepair (.semantic repair.stage) :=
  .semantic repair.toOrbitRepair

def canonicalIntrinsicRepair : OpenOrbitStage -> CanonicalIntrinsicRepair
  | .first => .first repair0 rfl
  | .second => .second repair1 rfl
  | .third => .third repair2 rfl

theorem canonicalIntrinsicRepair_stage
    (openStage : OpenOrbitStage) :
    (canonicalIntrinsicRepair openStage).stage = openStage.source := by
  cases openStage <;> rfl

theorem intrinsicRepair_execution_eq_target
    (openStage : OpenOrbitStage) :
    executeOrbitRepair (canonicalIntrinsicRepair openStage).toOrbitRepair =
      openStage.target := by
  cases openStage <;> rfl

def closureHoldsAt
    (stage : OrbitStage)
    (predicate : MonotonePolePredicate)
    (pole : Pole) : Prop :=
  @closureDoctrine.Holds
    (contextOfState stage) ClosureSort.gap predicate pole

def interpretPoleAt (stage : OrbitStage) (pole : Pole) : Pole :=
  @closureInterpretation.termAtom
    (contextOfState stage) ClosureSort.gap pole

structure ClosurePredicateAlignment where
  correct :
    (stage : OrbitStage) ->
    (world : World) ->
    (candidate : Candidate) ->
    (index : Index) ->
    (pole : Pole) ->
    closureHoldsAt stage
        (correctPolePredicate world candidate index) pole ↔
      Finite.CorrectAt world candidate index
  closedOn :
    (stage : OrbitStage) ->
    (world : World) ->
    (candidate : Candidate) ->
    (domain : List Index) ->
    (pole : Pole) ->
    closureHoldsAt stage
        (closedOnPolePredicate world candidate domain) pole ↔
      ClosedOn finiteData world candidate domain
  compatible :
    (stage : OrbitStage) ->
    (world : World) ->
    (pole : Pole) ->
    closureHoldsAt stage
        (compatiblePredicateOfView stage world) pole ↔
      finiteSystem.CompatibleWithViewHistory (stateAt stage).agent world
  knownCorrect :
    (stage : OrbitStage) ->
    (index : Index) ->
    (pole : Pole) ->
    closureHoldsAt stage
        (knownCorrectPredicateOfViewIndex stage index) pole ↔
      KnownCorrectAt finiteSystem (stateAt stage).agent
        (stateAt stage).agent.candidate index
  knownClosed :
    (stage : OrbitStage) ->
    (domain : List Index) ->
    (pole : Pole) ->
    closureHoldsAt stage
        (knownClosedPolePredicate stage domain) pole ↔
      KnownClosedOn finiteSystem (stateAt stage).agent
        (stateAt stage).agent.candidate domain
  fiberDeterminate :
    (stage : OrbitStage) ->
    (index : Index) ->
    (pole : Pole) ->
    closureHoldsAt stage
        (fiberDeterminatePolePredicate stage index) pole ↔
      FiberDeterminateAt finiteSystem (stateAt stage).agent index
  gapClosed :
    (openStage : OpenOrbitStage) ->
    (after : OrbitStage) ->
    (pole : Pole) ->
    closureHoldsAt after
        (gapClosedPolePredicate openStage after) pole ↔
      GapClosedBy finiteSystem
        (stateAt openStage.source) openStage.gap (stateAt after)
  compatibilityVariance :
    (world : World) -> ContravariantOrbitPredicate
  knownCorrectVariance :
    (index : Index) -> CovariantOrbitPredicate
  knownClosedVariance :
    (domain : List Index) -> CovariantOrbitPredicate
  fiberVariance :
    (index : Index) -> CovariantOrbitPredicate
  compatibilityCannotBeCovariant :
    (∀ {source target : OrbitStage},
      OrbitAdvance source target ->
      finiteSystem.CompatibleWithViewHistory
        (stateAt source).agent firstEliminatedWorld ->
      finiteSystem.CompatibleWithViewHistory
        (stateAt target).agent firstEliminatedWorld) -> False

def closurePredicateAlignment : ClosurePredicateAlignment where
  correct := by intros; exact Iff.rfl
  closedOn := by intros; exact Iff.rfl
  compatible := by intros; exact Iff.rfl
  knownCorrect := by intros; exact Iff.rfl
  knownClosed := by intros; exact Iff.rfl
  fiberDeterminate := by intros; exact Iff.rfl
  gapClosed := by intros; exact Iff.rfl
  compatibilityVariance := compatibilityPredicateOfWorld
  knownCorrectVariance := knownCorrectPredicateOfIndex
  knownClosedVariance := knownClosedPredicate
  fiberVariance := fiberDeterminatePredicateOfIndex
  compatibilityCannotBeCovariant := compatibility_not_covariant

structure RepairTransitionAlignment where
  intrinsicRepair : OpenOrbitStage -> CanonicalIntrinsicRepair
  intrinsicRepair_eq : intrinsicRepair = canonicalIntrinsicRepair
  interfaceRepair :
    (openStage : OpenOrbitStage) ->
      OrbitInterfaceRepair (.semantic (intrinsicRepair openStage).stage)
  interfaceRepair_eq :
    ∀ openStage,
      interfaceRepair openStage = repairOfIntrinsic (intrinsicRepair openStage)
  source_eq :
    ∀ openStage, (intrinsicRepair openStage).stage = openStage.source
  target_eq :
    ∀ openStage,
      executeOrbitRepair (intrinsicRepair openStage).toOrbitRepair =
        openStage.target
  algebraNext_eq :
    ∀ stage, orbitGapRepairAlgebra.next stage = nextStage stage
  activeNext_eq :
    ∀ stage,
      stateAt (orbitGapRepairAlgebra.next stage) =
        finiteSystem.nextState (stateAt stage)

def repairTransitionAlignment : RepairTransitionAlignment where
  intrinsicRepair := canonicalIntrinsicRepair
  intrinsicRepair_eq := rfl
  interfaceRepair := fun openStage =>
    repairOfIntrinsic (canonicalIntrinsicRepair openStage)
  interfaceRepair_eq := by intro openStage; rfl
  source_eq := canonicalIntrinsicRepair_stage
  target_eq := intrinsicRepair_execution_eq_target
  algebraNext_eq := orbitGapRepairAlgebra_next_eq_nextStage
  activeNext_eq := orbitGapRepairAlgebra_next_realizes_activeNext

structure ActiveClosureFoundationalNontriviality where
  contextChange : NontrivialContextChange closureContextCategory
  contextChange_eq : contextChange = genuineContextRefinement .initial
  leftTerm : Pole
  rightTerm : Pole
  reindexedLeftTerm : Pole
  reindexedLeftTerm_eq :
    reindexedLeftTerm =
      @closureTermLanguage.reindexTerm
        contextChange.source contextChange.target
        contextChange.substitution ClosureSort.gap leftTerm
  reindexPreservesLeftTerm : reindexedLeftTerm = leftTerm
  termsSeparated : leftTerm = rightTerm -> False
  separation : PoleSeparation (contextOfState .initial) leftTerm rightTerm
  coordination : PoleCoordination (contextOfState .initial) leftTerm rightTerm
  forwardUse : PoleUse (contextOfState .initial) leftTerm rightTerm
  inverseUseRefuted :
    PoleUse (contextOfState .initial) rightTerm leftTerm -> False
  visibleTransport :
    VisiblePoleTransport
      (contextOfState .initial)
      (readPole (contextOfState .initial) .visible leftTerm)
      (readPole (contextOfState .initial) .visible rightTerm)
  visibleTransport_eq : visibleTransport = regimeTransportOfExecution .first
  visibleTransportHasOperationalStep :
    visibleTransport.steps =
      [{ openStage := .first
         certificate := contextualGapCertificate .first
         authorization := OpenOrbitStage.first.authorization
         authorization_eq := rfl
         operationalTransport := OpenOrbitStage.first.operationalTransport
         operationalTransport_eq := rfl }]
  leftPredicateRefuted : reachedRightPole.Holds leftTerm -> False
  rightPredicateHolds : reachedRightPole.Holds rightTerm
  positivePredicate : MonotonePolePredicate
  negativePredicate : MonotonePolePredicate
  positivePredicateHolds : positivePredicate.Holds leftTerm
  negativePredicateRefuted : negativePredicate.Holds leftTerm -> False
  predicatesSeparated : positivePredicate = negativePredicate -> False
  repair : CanonicalIntrinsicRepair
  repair_eq : repair = canonicalIntrinsicRepair .first
  repairChangesStage :
    executeOrbitRepair repair.toOrbitRepair = .firstRepaired
  repairChangesState :
    stateAt (executeOrbitRepair repair.toOrbitRepair) = stateAt .initial -> False
  repairPreservesActualCompatibility :
    finiteSystem.CompatibleWithViewHistory
      (stateAt (executeOrbitRepair repair.toOrbitRepair)).agent
      (stateAt (executeOrbitRepair repair.toOrbitRepair)).world
  repairClosesInitialGap :
    GapClosedBy finiteSystem state0 gap0
      (stateAt (executeOrbitRepair repair.toOrbitRepair))
  interpretationSeparatesTerms :
    interpretPoleAt .initial leftTerm =
      interpretPoleAt .initial rightTerm -> False

def activeClosureFoundationalNontriviality :
    ActiveClosureFoundationalNontriviality where
  contextChange := genuineContextRefinement .initial
  contextChange_eq := rfl
  leftTerm := .origin
  rightTerm := .destination
  reindexedLeftTerm := .origin
  reindexedLeftTerm_eq := rfl
  reindexPreservesLeftTerm := rfl
  termsSeparated := originPole_ne_destinationPole
  separation := separationOfGap .first
  coordination := coordinationOfGap .first
  forwardUse := regimeUseOfAuthorization .first
  inverseUseRefuted := poleUse_noBackward _
  visibleTransport := regimeTransportOfExecution .first
  visibleTransport_eq := rfl
  visibleTransportHasOperationalStep := regimeTransport_steps_eq_singleton .first
  leftPredicateRefuted := fun impossible => impossible
  rightPredicateHolds := True.intro
  positivePredicate := polePredicateTop
  negativePredicate := polePredicateBottom
  positivePredicateHolds := True.intro
  negativePredicateRefuted := fun impossible => impossible
  predicatesSeparated := by
    intro equality
    have transported : polePredicateBottom.Holds .origin :=
      equality ▸ (True.intro : polePredicateTop.Holds .origin)
    exact transported
  repair := canonicalIntrinsicRepair .first
  repair_eq := rfl
  repairChangesStage := rfl
  repairChangesState := state1_differs_from_state0
  repairPreservesActualCompatibility := state1_actualCompatible
  repairClosesInitialGap := gap0ClosedByState1
  interpretationSeparatesTerms := originPole_ne_destinationPole

structure AIContextualModel where
  contextLaws : LawfulContextCategory closureContextCategory
  termLaws : LawfulIndexedTermLanguage closureTermLanguage
  regimeLaws : LawfulContextualRelaxedRegime closureContextualRegime
  doctrineLaws : LawfulAdmissiblePredicateDoctrine closureDoctrine
  interpretation :
    RelaxedInterpretation
      closureSignature closureTermLanguage
      closureContextualRegime closureDoctrine
  identityConservativity : StrictIdentityConservativity closureSignature
  syntaxConsistency :
    ∀ context, ClosedRelaxedContradiction closureSignature context -> False

def aiContextualModel : AIContextualModel where
  contextLaws := closureContextLaws
  termLaws := closureTermLanguageLaws
  regimeLaws := closureContextualRegimeLaws
  doctrineLaws := closureDoctrineLaws
  interpretation := closureInterpretation
  identityConservativity := closureIdentityConservativity
  syntaxConsistency := closureSyntax_consistent

structure ActiveClosureFoundationalRealization where
  contextualModel : AIContextualModel
  repairAlgebra : GapRepairAlgebra orbitReturnFamily
  gapAlignment : (openStage : OpenOrbitStage) -> OperationalGapAlignment openStage
  useAlignment : (openStage : OpenOrbitStage) -> AuthorizedUseAlignment openStage
  transportAlignment :
    (openStage : OpenOrbitStage) -> OperationalTransportAlignment openStage
  correctnessAlignment : ClosurePredicateAlignment
  transitionAlignment : RepairTransitionAlignment
  nontriviality : ActiveClosureFoundationalNontriviality
  terminalClosure : StableClosureRepair

def activeClosureFoundationalRealization :
    ActiveClosureFoundationalRealization where
  contextualModel := aiContextualModel
  repairAlgebra := orbitGapRepairAlgebra
  gapAlignment := operationalGapAlignment
  useAlignment := authorizedUseAlignment
  transportAlignment := operationalTransportAlignment
  correctnessAlignment := closurePredicateAlignment
  transitionAlignment := repairTransitionAlignment
  nontriviality := activeClosureFoundationalNontriviality
  terminalClosure :=
    { closedDetector := state3_is_closed
      retained := state3_retainsRepairs
      knownClosed := state3_knownClosedOnRepairedPrefix
      stable := state3_is_stable }

end Foundational
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.Foundational.validatedOrbitGap
#print axioms Meta.ActiveSemanticClosure.Foundational.orbitGapRepairAlgebra_next_realizes_activeNext
#print axioms Meta.ActiveSemanticClosure.Foundational.closureContextualRegimeLaws
#print axioms Meta.ActiveSemanticClosure.Foundational.closureDoctrineLaws
#print axioms Meta.ActiveSemanticClosure.Foundational.compatibility_not_covariant
#print axioms Meta.ActiveSemanticClosure.Foundational.operationalGapAlignment
#print axioms Meta.ActiveSemanticClosure.Foundational.operationalTransportAlignment
#print axioms Meta.ActiveSemanticClosure.Foundational.repairTransitionAlignment
#print axioms Meta.ActiveSemanticClosure.Foundational.activeClosureFoundationalNontriviality
#print axioms Meta.ActiveSemanticClosure.Foundational.activeClosureFoundationalRealization
/- AXIOM_AUDIT_END -/
