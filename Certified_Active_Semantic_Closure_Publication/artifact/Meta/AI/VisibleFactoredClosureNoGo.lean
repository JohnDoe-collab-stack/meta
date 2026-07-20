import Meta.AI.FiniteActiveSemanticClosure

/-!
# Passive and visible-factored closure no-go theorems

The passive theorem is tied to two concrete finite worlds that produce exactly
the same initial agent state and require incompatible targets.  The factored
theorem uses a separate one-query task whose full states are distinguishable
but whose visible states coincide.  Neither result is obtained from the
non-projectivity of `HasUse`.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace NoGo

open Finite

universe u v

structure ResourceBudget where
  steps : Nat
  memoryCells : Nat
  interactionQueries : Nat
  deriving DecidableEq

structure PassiveClosurePolicy (D : ActiveClosureData.{u}) where
  Memory : Type v
  initialMemory : AgentClosureState D -> Memory
  memoryFootprint : Memory -> Nat
  passiveStep :
    AgentClosureState D -> Memory -> D.CandidatePatch × Memory

structure PassiveRunState
    (D : ActiveClosureData.{u})
    (policy : PassiveClosurePolicy.{u, v} D) where
  agent : AgentClosureState D
  memory : policy.Memory

def initialPassiveRun
    {D : ActiveClosureData.{u}}
    (policy : PassiveClosurePolicy.{u, v} D)
    (agent : AgentClosureState D) : PassiveRunState D policy where
  agent := agent
  memory := policy.initialMemory agent

def passiveAdvance
    {D : ActiveClosureData.{u}}
    (policy : PassiveClosurePolicy.{u, v} D)
    (state : PassiveRunState D policy) : PassiveRunState D policy :=
  let result := policy.passiveStep state.agent state.memory
  { agent :=
      { candidate := D.applyCandidatePatch state.agent.candidate result.1
        observation := state.agent.observation
        history := state.agent.history }
    memory := result.2 }

def runPassive
    {D : ActiveClosureData.{u}}
    (policy : PassiveClosurePolicy.{u, v} D) :
    Nat -> AgentClosureState D -> PassiveRunState D policy
  | 0, agent => initialPassiveRun policy agent
  | steps + 1, agent => passiveAdvance policy (runPassive policy steps agent)

structure PassiveRunWithinBudget
    {D : ActiveClosureData.{u}}
    (policy : PassiveClosurePolicy.{u, v} D)
    (budget : ResourceBudget)
    (agent : AgentClosureState D) : Prop where
  finalMemoryWithinBudget :
    policy.memoryFootprint (runPassive policy budget.steps agent).memory ≤
      budget.memoryCells
  interactionDisabled : budget.interactionQueries = 0

theorem runPassive_sameAgent
    {D : ActiveClosureData.{u}}
    (policy : PassiveClosurePolicy.{u, v} D)
    (steps : Nat)
    (leftAgent rightAgent : AgentClosureState D)
    (sameAgent : leftAgent = rightAgent) :
    runPassive policy steps leftAgent = runPassive policy steps rightAgent := by
  cases sameAgent
  rfl

structure SameInitialInformation
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I) where
  left : ActiveSemanticClosureState D
  right : ActiveSemanticClosureState D
  statesSeparated : left = right -> False
  agentView_eq : left.agent = right.agent
  leftCompatible : system.CompatibleWithViewHistory left.agent left.world
  rightCompatible : system.CompatibleWithViewHistory right.agent right.world

structure IncompatibleRequiredRepairs
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    (pair : SameInitialInformation system) where
  index : D.VisibleIndex
  targetsSeparated :
    D.evaluate pair.left.world index = D.evaluate pair.right.world index -> False

theorem incompatibleTargets_refute_commonCandidate
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    {pair : SameInitialInformation system}
    (required : IncompatibleRequiredRepairs pair)
    (candidate : D.Candidate)
    (leftCorrect : CorrectAt D pair.left.world candidate required.index)
    (rightCorrect : CorrectAt D pair.right.world candidate required.index) : False :=
  required.targetsSeparated
    (D.agrees_target_unique
      (D.interpret candidate required.index)
      (D.evaluate pair.left.world required.index)
      (D.evaluate pair.right.world required.index)
      leftCorrect rightCorrect)

theorem passivePolicy_cannotCloseBoth
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    (pair : SameInitialInformation system)
    (required : IncompatibleRequiredRepairs pair)
    (policy : PassiveClosurePolicy.{u, v} D)
    (budget : ResourceBudget)
    (leftCorrect :
      CorrectAt D pair.left.world
        (runPassive policy budget.steps pair.left.agent).agent.candidate
        required.index)
    (rightCorrect :
      CorrectAt D pair.right.world
        (runPassive policy budget.steps pair.right.agent).agent.candidate
        required.index) : False := by
  have sameRun := runPassive_sameAgent
    policy budget.steps pair.left.agent pair.right.agent pair.agentView_eq
  have sameCandidate := congrArg
    (fun run => run.agent.candidate) sameRun
  have rightCorrectAtLeftCandidate :
      CorrectAt D pair.right.world
        (runPassive policy budget.steps pair.left.agent).agent.candidate
        required.index :=
    Eq.mp
      (congrArg
        (fun candidate => CorrectAt D pair.right.world candidate required.index)
        sameCandidate.symm)
      rightCorrect
  exact incompatibleTargets_refute_commonCandidate required
    (runPassive policy budget.steps pair.left.agent).agent.candidate
    leftCorrect
    rightCorrectAtLeftCandidate

structure SeededPassiveClosurePolicy (D : ActiveClosureData.{u}) where
  Seed : Type v
  policyAt : Seed -> PassiveClosurePolicy.{u, v} D

theorem seededPassivePolicy_cannotGuaranteeBoth
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    (pair : SameInitialInformation system)
    (required : IncompatibleRequiredRepairs pair)
    (seeded : SeededPassiveClosurePolicy.{u, v} D)
    (seed : seeded.Seed)
    (budget : ResourceBudget)
    (leftCorrect :
      CorrectAt D pair.left.world
        (runPassive (seeded.policyAt seed) budget.steps pair.left.agent).agent.candidate
        required.index)
    (rightCorrect :
      CorrectAt D pair.right.world
        (runPassive (seeded.policyAt seed) budget.steps pair.right.agent).agent.candidate
        required.index) : False :=
  passivePolicy_cannotCloseBoth pair required (seeded.policyAt seed) budget
    leftCorrect rightCorrect

def finitePassiveLeftState : ClosedState := state0

def finitePassiveRightState : ClosedState :=
  { world := firstEliminatedWorld
    agent := state0.agent }

theorem finitePassiveStatesSeparated :
    finitePassiveLeftState = finitePassiveRightState -> False := by
  intro equality
  have worldEquality := congrArg ActiveSemanticClosureState.world equality
  have targetEquality := congrArg (fun world => world.at Index.first) worldEquality
  cases targetEquality

def finiteSameInitialInformation : SameInitialInformation finiteSystem where
  left := finitePassiveLeftState
  right := finitePassiveRightState
  statesSeparated := finitePassiveStatesSeparated
  agentView_eq := rfl
  leftCompatible := state0_actualCompatible
  rightCompatible := state0_to_state1_strictFiberReduction.compatibleBefore

def finiteIncompatibleRequiredRepairs :
    IncompatibleRequiredRepairs finiteSameInitialInformation where
  index := .first
  targetsSeparated := by
    intro equality
    cases equality

theorem finitePassivePolicy_noGo
    (policy : PassiveClosurePolicy.{0, 0} finiteData)
    (budget : ResourceBudget)
    (leftCorrect :
      Finite.CorrectAt finitePassiveLeftState.world
        (runPassive policy budget.steps finitePassiveLeftState.agent).agent.candidate
        .first)
    (rightCorrect :
      Finite.CorrectAt finitePassiveRightState.world
        (runPassive policy budget.steps finitePassiveRightState.agent).agent.candidate
        .first) : False :=
  passivePolicy_cannotCloseBoth
    finiteSameInitialInformation finiteIncompatibleRequiredRepairs
    policy budget leftCorrect rightCorrect

theorem finiteBudgetedPassivePolicy_noGo
    (policy : PassiveClosurePolicy.{0, 0} finiteData)
    (budget : ResourceBudget)
    (_leftWithin :
      PassiveRunWithinBudget policy budget finitePassiveLeftState.agent)
    (_rightWithin :
      PassiveRunWithinBudget policy budget finitePassiveRightState.agent)
    (leftCorrect :
      Finite.CorrectAt finitePassiveLeftState.world
        (runPassive policy budget.steps finitePassiveLeftState.agent).agent.candidate
        .first)
    (rightCorrect :
      Finite.CorrectAt finitePassiveRightState.world
        (runPassive policy budget.steps finitePassiveRightState.agent).agent.candidate
        .first) : False :=
  finitePassivePolicy_noGo policy budget leftCorrect rightCorrect

/-! ## One-query visible factorization no-go -/

inductive FactoredFullState where
  | needsLeft
  | needsRight
  | visibleAlternative
  deriving DecidableEq

inductive FactoredQuery where
  | askLeft
  | askRight
  deriving DecidableEq

def factoredVisibleState : FactoredFullState -> Bool
  | .needsLeft => false
  | .needsRight => false
  | .visibleAlternative => true

def requiredQuery : FactoredFullState -> FactoredQuery
  | .needsLeft => .askLeft
  | .needsRight => .askRight
  | .visibleAlternative => .askLeft

def ClosesWithinOne
    (state : FactoredFullState)
    (query : FactoredQuery) : Prop :=
  query = requiredQuery state

structure VisibleFactoredClosureController where
  selectVisible : Bool -> FactoredQuery
  selectQuery : FactoredFullState -> FactoredQuery
  selectQueryAt_eq :
    ∀ state, selectQuery state = selectVisible (factoredVisibleState state)

theorem factoredPair_sameVisible :
    factoredVisibleState .needsLeft = factoredVisibleState .needsRight :=
  rfl

theorem factoredProjection_nonconstant :
    factoredVisibleState .needsLeft = factoredVisibleState .visibleAlternative -> False := by
  intro equality
  cases equality

theorem requiredQueries_incompatible :
    requiredQuery .needsLeft = requiredQuery .needsRight -> False := by
  intro equality
  cases equality

theorem visibleFactored_selectsSameQuery
    (controller : VisibleFactoredClosureController) :
    controller.selectQuery .needsLeft = controller.selectQuery .needsRight :=
  (controller.selectQueryAt_eq .needsLeft).trans
    (controller.selectQueryAt_eq .needsRight).symm

theorem visibleFactored_cannotCloseBothWithinOne
    (controller : VisibleFactoredClosureController)
    (leftClosed : ClosesWithinOne .needsLeft
      (controller.selectQuery .needsLeft))
    (rightClosed : ClosesWithinOne .needsRight
      (controller.selectQuery .needsRight)) : False := by
  exact requiredQueries_incompatible
    (leftClosed.symm.trans
      ((visibleFactored_selectsSameQuery controller).trans rightClosed))

structure SeededVisibleFactoredController where
  Seed : Type
  controllerAt : Seed -> VisibleFactoredClosureController

theorem seededVisibleFactored_cannotGuaranteeBoth
    (seeded : SeededVisibleFactoredController)
    (seed : seeded.Seed)
    (leftClosed : ClosesWithinOne .needsLeft
      ((seeded.controllerAt seed).selectQuery .needsLeft))
    (rightClosed : ClosesWithinOne .needsRight
      ((seeded.controllerAt seed).selectQuery .needsRight)) : False :=
  visibleFactored_cannotCloseBothWithinOne
    (seeded.controllerAt seed) leftClosed rightClosed

def activeFullStateController (state : FactoredFullState) : FactoredQuery :=
  requiredQuery state

theorem activeFullStateController_closes
    (state : FactoredFullState) :
    ClosesWithinOne state (activeFullStateController state) :=
  rfl

/-!
## Exact finite closure-task factorization no-go

The preceding small task isolates the information-theoretic shape.  The
following result is the closure theorem itself: its two critical full states,
gaps, intrinsic patches, and closure proofs are the concrete objects of
`FiniteActiveSemanticClosure`.
-/

inductive FiniteCriticalStage where
  | first
  | second
  deriving DecidableEq

structure FiniteVisibleState where
  coarseStatus : Bool
  visibleHistory : List Bool
  deriving DecidableEq

def finiteCriticalState : FiniteCriticalStage -> ClosedState
  | .first => state0
  | .second => state1

def finiteCriticalTarget : FiniteCriticalStage -> ClosedState
  | .first => state1
  | .second => state2

def finiteCriticalGap :
    (stage : FiniteCriticalStage) -> Gap (finiteCriticalState stage).agent
  | .first => gap0
  | .second => gap1

def finiteVisibleState : FiniteCriticalStage -> FiniteVisibleState
  | .first => { coarseStatus := false, visibleHistory := [] }
  | .second => { coarseStatus := false, visibleHistory := [] }

def finiteVisibleAlternative : FiniteVisibleState :=
  { coarseStatus := true, visibleHistory := [] }

theorem finiteCriticalPair_sameVisible :
    finiteVisibleState .first = finiteVisibleState .second :=
  rfl

theorem finiteCriticalProjection_nonconstant :
    finiteVisibleState .first = finiteVisibleAlternative -> False := by
  intro equality
  have statusEquality := congrArg FiniteVisibleState.coarseStatus equality
  cases statusEquality

structure FiniteFactoredAction where
  queryIndex : Index
  patch : CandidatePatch
  deriving DecidableEq

def finiteRequiredAction : FiniteCriticalStage -> FiniteFactoredAction
  | .first =>
      { queryIndex := gap0.index
        patch := repair0.candidatePatch }
  | .second =>
      { queryIndex := gap1.index
        patch := repair1.candidatePatch }

theorem finiteRequiredQueryIndicesSeparated :
    (finiteRequiredAction .first).queryIndex =
      (finiteRequiredAction .second).queryIndex -> False := by
  intro equality
  cases equality

def finiteCriticalClosure :
    (stage : FiniteCriticalStage) ->
      GapClosedBy finiteSystem
        (finiteCriticalState stage)
        (finiteCriticalGap stage)
        (finiteCriticalTarget stage)
  | .first => gap0ClosedByState1
  | .second => gap1ClosedByState2

structure FiniteVisibleFactoredClosureController where
  selectVisible : FiniteVisibleState -> FiniteFactoredAction
  selectAction : FiniteCriticalStage -> FiniteFactoredAction
  selectAction_factors :
    ∀ stage,
      selectAction stage = selectVisible (finiteVisibleState stage)

structure FiniteOneQueryClosure
    (controller : FiniteVisibleFactoredClosureController)
    (stage : FiniteCriticalStage) : Prop where
  selectedAction_eq_required :
    controller.selectAction stage = finiteRequiredAction stage
  closesOperationalGap :
    GapClosedBy finiteSystem
      (finiteCriticalState stage)
      (finiteCriticalGap stage)
      (finiteCriticalTarget stage)

theorem finiteVisibleFactored_selectsSameAction
    (controller : FiniteVisibleFactoredClosureController) :
    controller.selectAction .first = controller.selectAction .second :=
  (controller.selectAction_factors .first).trans
    (controller.selectAction_factors .second).symm

theorem finiteVisibleFactored_cannotCloseBoth
    (controller : FiniteVisibleFactoredClosureController)
    (firstClosed : FiniteOneQueryClosure controller .first)
    (secondClosed : FiniteOneQueryClosure controller .second) : False := by
  have requiredActionsEqual :
      finiteRequiredAction .first = finiteRequiredAction .second :=
    firstClosed.selectedAction_eq_required.symm.trans
      ((finiteVisibleFactored_selectsSameAction controller).trans
        secondClosed.selectedAction_eq_required)
  exact finiteRequiredQueryIndicesSeparated
    (congrArg FiniteFactoredAction.queryIndex requiredActionsEqual)

structure SeededFiniteVisibleFactoredController where
  Seed : Type
  controllerAt : Seed -> FiniteVisibleFactoredClosureController

theorem seededFiniteVisibleFactored_cannotGuaranteeBoth
    (seeded : SeededFiniteVisibleFactoredController)
    (seed : seeded.Seed)
    (firstClosed :
      FiniteOneQueryClosure (seeded.controllerAt seed) .first)
    (secondClosed :
      FiniteOneQueryClosure (seeded.controllerAt seed) .second) : False :=
  finiteVisibleFactored_cannotCloseBoth
    (seeded.controllerAt seed) firstClosed secondClosed

def finiteActiveFullStateAction
    (stage : FiniteCriticalStage) : FiniteFactoredAction :=
  finiteRequiredAction stage

def finiteActiveFullStateClosure
    (stage : FiniteCriticalStage) :
    GapClosedBy finiteSystem
      (finiteCriticalState stage)
      (finiteCriticalGap stage)
      (finiteCriticalTarget stage) :=
  finiteCriticalClosure stage

structure FiniteActiveComparatorCertificate where
  actionAt : FiniteCriticalStage -> FiniteFactoredAction
  actionAt_eq_required : ∀ stage, actionAt stage = finiteRequiredAction stage
  closesAt :
    ∀ stage,
      GapClosedBy finiteSystem
        (finiteCriticalState stage)
        (finiteCriticalGap stage)
        (finiteCriticalTarget stage)

def finiteActiveComparatorCertificate : FiniteActiveComparatorCertificate where
  actionAt := finiteActiveFullStateAction
  actionAt_eq_required := by intro stage; rfl
  closesAt := finiteActiveFullStateClosure

structure AIClosureNoGoCertificate where
  passivePair : SameInitialInformation finiteSystem
  passivePair_eq : passivePair = finiteSameInitialInformation
  incompatibleRepairs : IncompatibleRequiredRepairs passivePair
  passiveNoGo :
    ∀ (policy : PassiveClosurePolicy.{0, 0} finiteData) (budget : ResourceBudget),
      Finite.CorrectAt passivePair.left.world
          (runPassive policy budget.steps passivePair.left.agent).agent.candidate
          incompatibleRepairs.index ->
      Finite.CorrectAt passivePair.right.world
          (runPassive policy budget.steps passivePair.right.agent).agent.candidate
          incompatibleRepairs.index ->
        False
  budgetedPassiveNoGo :
    ∀ (policy : PassiveClosurePolicy.{0, 0} finiteData) (budget : ResourceBudget),
      PassiveRunWithinBudget policy budget passivePair.left.agent ->
      PassiveRunWithinBudget policy budget passivePair.right.agent ->
      Finite.CorrectAt passivePair.left.world
          (runPassive policy budget.steps passivePair.left.agent).agent.candidate
          incompatibleRepairs.index ->
      Finite.CorrectAt passivePair.right.world
          (runPassive policy budget.steps passivePair.right.agent).agent.candidate
          incompatibleRepairs.index ->
        False
  visibleProjectionNonconstant :
    factoredVisibleState .needsLeft = factoredVisibleState .visibleAlternative -> False
  visiblePairSame :
    factoredVisibleState .needsLeft = factoredVisibleState .needsRight
  incompatibleQueries :
    requiredQuery .needsLeft = requiredQuery .needsRight -> False
  visibleFactoredNoGo :
    ∀ controller : VisibleFactoredClosureController,
      ClosesWithinOne .needsLeft (controller.selectQuery .needsLeft) ->
      ClosesWithinOne .needsRight (controller.selectQuery .needsRight) ->
        False
  activeComparatorCloses :
    ∀ state, ClosesWithinOne state (activeFullStateController state)
  exactVisiblePairSame :
    finiteVisibleState .first = finiteVisibleState .second
  exactVisibleProjectionNonconstant :
    finiteVisibleState .first = finiteVisibleAlternative -> False
  exactRequiredQueriesIncompatible :
    (finiteRequiredAction .first).queryIndex =
      (finiteRequiredAction .second).queryIndex -> False
  exactVisibleFactoredNoGo :
    ∀ controller : FiniteVisibleFactoredClosureController,
      FiniteOneQueryClosure controller .first ->
      FiniteOneQueryClosure controller .second ->
        False
  exactActiveComparator : FiniteActiveComparatorCertificate

def aiClosureNoGoCertificate : AIClosureNoGoCertificate where
  passivePair := finiteSameInitialInformation
  passivePair_eq := rfl
  incompatibleRepairs := finiteIncompatibleRequiredRepairs
  passiveNoGo := by
    intro policy budget leftCorrect rightCorrect
    exact finitePassivePolicy_noGo policy budget leftCorrect rightCorrect
  budgetedPassiveNoGo := by
    intro policy budget leftWithin rightWithin leftCorrect rightCorrect
    exact finiteBudgetedPassivePolicy_noGo
      policy budget leftWithin rightWithin leftCorrect rightCorrect
  visibleProjectionNonconstant := factoredProjection_nonconstant
  visiblePairSame := factoredPair_sameVisible
  incompatibleQueries := requiredQueries_incompatible
  visibleFactoredNoGo := visibleFactored_cannotCloseBothWithinOne
  activeComparatorCloses := activeFullStateController_closes
  exactVisiblePairSame := finiteCriticalPair_sameVisible
  exactVisibleProjectionNonconstant := finiteCriticalProjection_nonconstant
  exactRequiredQueriesIncompatible := finiteRequiredQueryIndicesSeparated
  exactVisibleFactoredNoGo := finiteVisibleFactored_cannotCloseBoth
  exactActiveComparator := finiteActiveComparatorCertificate

end NoGo
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.NoGo.runPassive_sameAgent
#print axioms Meta.ActiveSemanticClosure.NoGo.passivePolicy_cannotCloseBoth
#print axioms Meta.ActiveSemanticClosure.NoGo.finitePassivePolicy_noGo
#print axioms Meta.ActiveSemanticClosure.NoGo.finiteBudgetedPassivePolicy_noGo
#print axioms Meta.ActiveSemanticClosure.NoGo.visibleFactored_cannotCloseBothWithinOne
#print axioms Meta.ActiveSemanticClosure.NoGo.seededVisibleFactored_cannotGuaranteeBoth
#print axioms Meta.ActiveSemanticClosure.NoGo.activeFullStateController_closes
#print axioms Meta.ActiveSemanticClosure.NoGo.finiteVisibleFactored_cannotCloseBoth
#print axioms Meta.ActiveSemanticClosure.NoGo.seededFiniteVisibleFactored_cannotGuaranteeBoth
#print axioms Meta.ActiveSemanticClosure.NoGo.finiteActiveComparatorCertificate
#print axioms Meta.ActiveSemanticClosure.NoGo.aiClosureNoGoCertificate
/- AXIOM_AUDIT_END -/
