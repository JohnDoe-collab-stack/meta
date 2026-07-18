import Meta.AdaptiveRepairability.PositiveInstance
import Meta.LatentRepair.CertifiedLatentRepair

namespace Meta.AdaptiveRepairability.LegacyInstanceAdapters

open Meta.ActiveSemanticClosure

/-!
Adapters from the previously published finite and open realizations to the
public binary interface used by the adaptive characterization.

The adapter does not identify the whole legacy world space with two worlds.
It represents exactly the two compatible worlds carried by each published
aliasing certificate and proves that the three public binary states represent
their before/left-posterior/right-posterior fibers faithfully on that slice.
-/

structure BinaryPublicFiberAdapter
    (LegacyWorld LegacyState LegacyAction LegacyResponse LegacyClosure : Type)
    where
  legacyCompatible : LegacyState → LegacyWorld → Prop
  legacyRequired : LegacyWorld → LegacyAction
  legacyRespond : LegacyWorld → LegacyResponse
  world : PositiveInstance.World → LegacyWorld
  state : PositiveInstance.State → LegacyState
  legacyBefore : LegacyState
  legacyActualAfter : LegacyState
  initialStateExact : state .initial = legacyBefore
  actualAfterStateExact : state .observedLeft = legacyActualAfter
  response : PositiveInstance.World → LegacyResponse
  action : PositiveInstance.World → LegacyAction
  compatibilityExact :
    ∀ s w,
      Compatible PositiveInstance.actionModel s w ↔
        legacyCompatible (state s) (world w)
  responseExact : ∀ w, legacyRespond (world w) = response w
  responsesSeparated : response .left = response .right → False
  requiredExact : ∀ w, legacyRequired (world w) = action w
  actionsSeparated : action .left = action .right → False
  legacyClosure : LegacyClosure
  adaptiveRepairability :
    CertifiedRepairableAt
      PositiveInstance.decisionDoctrine PositiveInstance.State.initial ()

inductive FiniteStage where
  | first
  | second
  | third
  deriving DecidableEq

def finiteWorld : FiniteStage → PositiveInstance.World → Finite.World
  | .first, .left => Finite.canonicalWorld
  | .first, .right => Finite.firstEliminatedWorld
  | .second, .left => Finite.canonicalWorld
  | .second, .right => Finite.secondEliminatedWorld
  | .third, .left => Finite.canonicalWorld
  | .third, .right => Finite.thirdEliminatedWorld

def finiteState : FiniteStage → PositiveInstance.State → Finite.AgentState
  | .first, .initial => Finite.state0.agent
  | .first, .observedLeft => Finite.state1.agent
  | .first, .observedRight => Finite.alternateState1.agent
  | .second, .initial => Finite.state1.agent
  | .second, .observedLeft => Finite.state2.agent
  | .second, .observedRight => Finite.alternateState2.agent
  | .third, .initial => Finite.state2.agent
  | .third, .observedLeft => Finite.state3.agent
  | .third, .observedRight => Finite.alternateState3.agent

def alternateRecordFirst : Finite.RepairRecord :=
  { index := .first, answer := some .blue, changedCandidate := true }

def alternateRecordSecond : Finite.RepairRecord :=
  { index := .second, answer := some .blue, changedCandidate := true }

def alternateRecordThird : Finite.RepairRecord :=
  { index := .third, answer := some .blue, changedCandidate := true }

theorem alternateState1_agent_eq :
    Finite.alternateState1.agent =
      { candidate :=
          { first := some .blue, second := none, third := none }
        observation :=
          { first := .exact .blue, second := .unknown, third := .unknown }
        history := [alternateRecordFirst] } :=
  rfl

theorem alternateState2_agent_eq :
    Finite.alternateState2.agent =
      { candidate :=
          { first := some .green, second := some .blue, third := none }
        observation :=
          { first := .exact .green, second := .exact .blue, third := .unknown }
        history := [Finite.terminalRecordFirst, alternateRecordSecond] } :=
  rfl

theorem alternateState3_agent_eq :
    Finite.alternateState3.agent =
      { candidate :=
          { first := some .green, second := some .green, third := some .blue }
        observation :=
          { first := .exact .green, second := .exact .green, third := .exact .blue }
        history :=
          [Finite.terminalRecordFirst, Finite.terminalRecordSecond,
            alternateRecordThird] } :=
  rfl

theorem alternateState1_rightCompatible :
    Finite.compatibleWithViewHistory
      Finite.alternateState1.agent Finite.firstEliminatedWorld := by
  rw [alternateState1_agent_eq]
  constructor
  · exact ⟨rfl, True.intro, True.intro⟩
  · intro record membership
    cases membership with
    | head => rfl
    | tail _ membership => cases membership

theorem alternateState2_rightCompatible :
    Finite.compatibleWithViewHistory
      Finite.alternateState2.agent Finite.secondEliminatedWorld := by
  rw [alternateState2_agent_eq]
  constructor
  · exact ⟨rfl, rfl, True.intro⟩
  · intro record membership
    cases membership with
    | head => rfl
    | tail _ membership =>
        cases membership with
        | head => rfl
        | tail _ membership => cases membership

theorem alternateState3_rightCompatible :
    Finite.compatibleWithViewHistory
      Finite.alternateState3.agent Finite.thirdEliminatedWorld := by
  rw [alternateState3_agent_eq]
  constructor
  · exact ⟨rfl, rfl, rfl⟩
  · intro record membership
    cases membership with
    | head => rfl
    | tail _ membership =>
        cases membership with
        | head => rfl
        | tail _ membership =>
            cases membership with
            | head => rfl
            | tail _ membership => cases membership

theorem finiteCompatibilityExact
    (stage : FiniteStage)
    (s : PositiveInstance.State)
    (w : PositiveInstance.World) :
    Compatible PositiveInstance.actionModel s w ↔
      Finite.compatibleWithViewHistory
        (finiteState stage s) (finiteWorld stage w) := by
  cases stage with
  | first =>
      cases s with
      | initial =>
          cases w with
          | left =>
              constructor
              · intro _
                exact Finite.state0_actualCompatible
              · intro _
                rfl

          | right =>
              constructor
              · intro _
                exact LatentRepair.finiteAliasing0.rightCompatible
              · intro _
                rfl
      | observedLeft =>
          cases w with
          | left =>
              constructor
              · intro _
                exact Finite.state1_actualCompatible
              · intro _
                rfl
          | right =>
              constructor
              · intro impossible
                exact False.elim (Bool.noConfusion impossible)
              · intro compatible
                exact False.elim
                  (LatentRepair.finiteStrictReduction0.incompatibleAfter compatible)
      | observedRight =>
          cases w with
          | left =>
              constructor
              · intro impossible
                exact False.elim (Bool.noConfusion impossible)
              · intro compatible
                exact False.elim
                  (Finite.alternateState1_actualIncompatible compatible)
          | right =>
              constructor
              · intro _
                exact alternateState1_rightCompatible
              · intro _
                rfl
  | second =>
      cases s with
      | initial =>
          cases w with
          | left =>
              constructor
              · intro _
                exact Finite.state1_actualCompatible
              · intro _
                rfl
          | right =>
              constructor
              · intro _
                exact LatentRepair.finiteAliasing1.rightCompatible
              · intro _
                rfl
      | observedLeft =>
          cases w with
          | left =>
              constructor
              · intro _
                exact Finite.state2_actualCompatible
              · intro _
                rfl
          | right =>
              constructor
              · intro impossible
                exact False.elim (Bool.noConfusion impossible)
              · intro compatible
                exact False.elim
                  (LatentRepair.finiteStrictReduction1.incompatibleAfter compatible)
      | observedRight =>
          cases w with
          | left =>
              constructor
              · intro impossible
                exact False.elim (Bool.noConfusion impossible)
              · intro compatible
                exact False.elim
                  (Finite.alternateState2_actualIncompatible compatible)
          | right =>
              constructor
              · intro _
                exact alternateState2_rightCompatible
              · intro _
                rfl
  | third =>
      cases s with
      | initial =>
          cases w with
          | left =>
              constructor
              · intro _
                exact Finite.state2_actualCompatible
              · intro _
                rfl
          | right =>
              constructor
              · intro _
                exact LatentRepair.finiteAliasing2.rightCompatible
              · intro _
                rfl
      | observedLeft =>
          cases w with
          | left =>
              constructor
              · intro _
                exact Finite.state3_actualCompatible
              · intro _
                rfl
          | right =>
              constructor
              · intro impossible
                exact False.elim (Bool.noConfusion impossible)
              · intro compatible
                exact False.elim
                  (LatentRepair.finiteStrictReduction2.incompatibleAfter compatible)
      | observedRight =>
          cases w with
          | left =>
              constructor
              · intro impossible
                exact False.elim (Bool.noConfusion impossible)
              · intro compatible
                exact False.elim
                  (Finite.alternateState3_actualIncompatible compatible)
          | right =>
              constructor
              · intro _
                exact alternateState3_rightCompatible
              · intro _
                rfl

def finiteResponse0 :
    PositiveInstance.World → Finite.Response Finite.query0
  | .left => Finite.response0
  | .right => Finite.alternateResponse0

def finiteResponse1 :
    PositiveInstance.World → Finite.Response Finite.query1
  | .left => Finite.response1
  | .right => Finite.alternateResponse1

def finiteResponse2 :
    PositiveInstance.World → Finite.Response Finite.query2
  | .left => Finite.response2
  | .right => Finite.alternateResponse2

def finiteAction : PositiveInstance.World → Finite.Value
  | .left => .green
  | .right => .blue

abbrev FiniteClosure0 :=
  LatentRepair.CertifiedLatentRepairStep
    Finite.finiteSystem Finite.finiteEvidenceRealization
    Finite.state0 Finite.state1 Finite.gap0

abbrev FiniteClosure1 :=
  LatentRepair.CertifiedLatentRepairStep
    Finite.finiteSystem Finite.finiteEvidenceRealization
    Finite.state1 Finite.state2 Finite.gap1

abbrev FiniteClosure2 :=
  LatentRepair.CertifiedLatentRepairStep
    Finite.finiteSystem Finite.finiteEvidenceRealization
    Finite.state2 Finite.state3 Finite.gap2

def finiteLegacyAdapter0 :
    BinaryPublicFiberAdapter
      Finite.World Finite.AgentState Finite.Value
      (Finite.Response Finite.query0) FiniteClosure0 :=
  {
    legacyCompatible := Finite.compatibleWithViewHistory
    legacyRequired := fun world => world.at .first
    legacyRespond := fun world => Finite.finiteSystem.respond world Finite.query0
    world := finiteWorld .first
    state := finiteState .first
    legacyBefore := Finite.state0.agent
    legacyActualAfter := Finite.state1.agent
    initialStateExact := rfl
    actualAfterStateExact := rfl
    response := finiteResponse0
    action := finiteAction
    compatibilityExact := finiteCompatibilityExact .first
    responseExact := by
      intro w
      cases w <;> rfl
    responsesSeparated := by
      intro equality
      cases equality
    requiredExact := by
      intro w
      cases w <;> rfl
    actionsSeparated := by
      intro equality
      cases equality
    legacyClosure := LatentRepair.finiteCertifiedLatentRepair0
    adaptiveRepairability := PositiveInstance.exactInstanceCertifiedRepairable
  }

def finiteLegacyAdapter1 :
    BinaryPublicFiberAdapter
      Finite.World Finite.AgentState Finite.Value
      (Finite.Response Finite.query1) FiniteClosure1 :=
  {
    legacyCompatible := Finite.compatibleWithViewHistory
    legacyRequired := fun world => world.at .second
    legacyRespond := fun world => Finite.finiteSystem.respond world Finite.query1
    world := finiteWorld .second
    state := finiteState .second
    legacyBefore := Finite.state1.agent
    legacyActualAfter := Finite.state2.agent
    initialStateExact := rfl
    actualAfterStateExact := rfl
    response := finiteResponse1
    action := finiteAction
    compatibilityExact := finiteCompatibilityExact .second
    responseExact := by
      intro w
      cases w <;> rfl
    responsesSeparated := by
      intro equality
      cases equality
    requiredExact := by
      intro w
      cases w <;> rfl
    actionsSeparated := by
      intro equality
      cases equality
    legacyClosure := LatentRepair.finiteCertifiedLatentRepair1
    adaptiveRepairability := PositiveInstance.exactInstanceCertifiedRepairable
  }

def finiteLegacyAdapter2 :
    BinaryPublicFiberAdapter
      Finite.World Finite.AgentState Finite.Value
      (Finite.Response Finite.query2) FiniteClosure2 :=
  {
    legacyCompatible := Finite.compatibleWithViewHistory
    legacyRequired := fun world => world.at .third
    legacyRespond := fun world => Finite.finiteSystem.respond world Finite.query2
    world := finiteWorld .third
    state := finiteState .third
    legacyBefore := Finite.state2.agent
    legacyActualAfter := Finite.state3.agent
    initialStateExact := rfl
    actualAfterStateExact := rfl
    response := finiteResponse2
    action := finiteAction
    compatibilityExact := finiteCompatibilityExact .third
    responseExact := by
      intro w
      cases w <;> rfl
    responsesSeparated := by
      intro equality
      cases equality
    requiredExact := by
      intro w
      cases w <;> rfl
    actionsSeparated := by
      intro equality
      cases equality
    legacyClosure := LatentRepair.finiteCertifiedLatentRepair2
    adaptiveRepairability := PositiveInstance.exactInstanceCertifiedRepairable
  }

theorem completionWorld_atFresh
    (candidate : Open.OpenCandidate) (value : Bool) :
    (Open.completionWorld candidate value).valueAt candidate.values.length =
      value := by
  unfold Open.completionWorld
  change
    (match Open.lookupBool candidate.values candidate.values.length with
      | some found => found
      | none =>
          if candidate.values.length = candidate.values.length then value
          else false) = value
  rw [Open.lookupBool_length, if_pos rfl]

def openWorld
    (stage : Nat) (w : PositiveInstance.World) : Open.OpenWorld :=
  match w with
  | .left =>
      Open.completionWorld (Open.openStateAt stage).agent.candidate false
  | .right =>
      Open.completionWorld (Open.openStateAt stage).agent.candidate true

def openRightBranchBefore (stage : Nat) : Open.OpenClosedState :=
  { world := openWorld stage .right
    agent := (Open.openStateAt stage).agent }

def openState
    (stage : Nat) (s : PositiveInstance.State) : Open.OpenAgentState :=
  match s with
  | .initial => (Open.openStateAt stage).agent
  | .observedLeft => (Open.openStateAt (stage + 1)).agent
  | .observedRight =>
      (Open.openSystem.nextState (openRightBranchBefore stage)).agent

theorem openPublishedAfter_candidate (stage : Nat) :
    (Open.openStateAt (stage + 1)).agent.candidate.values =
      (Open.openStateAt stage).agent.candidate.values ++ [false] := by
  change
    (Open.openSystem.nextState (Open.openStateAt stage)).agent.candidate.values =
      (Open.openStateAt stage).agent.candidate.values ++ [false]
  rw [Open.openSystem_next_candidate, Open.openStateAt_world]
  rfl

theorem openRightAfter_candidate (stage : Nat) :
    (Open.openSystem.nextState (openRightBranchBefore stage)).agent.candidate.values =
      (Open.openStateAt stage).agent.candidate.values ++ [true] := by
  rw [Open.openSystem_next_candidate]
  change
    (Open.openStateAt stage).agent.candidate.values ++
        [(openWorld stage .right).valueAt
          (Open.openStateAt stage).agent.candidate.values.length] =
      (Open.openStateAt stage).agent.candidate.values ++ [true]
  have freshValue :
      (openWorld stage .right).valueAt
          (Open.openStateAt stage).agent.candidate.values.length = true := by
    exact completionWorld_atFresh _ true
  rw [freshValue]

theorem openPublishedAfter_leftCompatible (stage : Nat) :
    Open.openCompatible
      (Open.openStateAt (stage + 1)).agent (openWorld stage .left) := by
  intro index value found
  rw [openPublishedAfter_candidate] at found
  have beforeCompatible :=
    Open.completionCompatibleWithView (Open.openStateAt stage).agent false
  have afterCompatible :=
    Open.openCompatible_after_append
      (Open.openStateAt stage).agent.candidate.values
      (openWorld stage .left)
      beforeCompatible
  have freshValue :
      (openWorld stage .left).valueAt
          (Open.openStateAt stage).agent.candidate.values.length = false :=
    completionWorld_atFresh _ false
  rw [freshValue] at afterCompatible
  exact afterCompatible index value found

theorem openPublishedAfter_rightIncompatible (stage : Nat) :
    Open.openCompatible
      (Open.openStateAt (stage + 1)).agent (openWorld stage .right) → False := by
  intro compatible
  let index := (Open.openStateAt stage).agent.candidate.values.length
  have learned :
      Open.lookupBool
          (Open.openStateAt (stage + 1)).agent.candidate.values index =
        some false := by
    rw [openPublishedAfter_candidate]
    exact Open.lookupBool_append_new _ false
  have forcedFalse := compatible index false learned
  have actuallyTrue : (openWorld stage .right).valueAt index = true :=
    completionWorld_atFresh _ true
  have impossible : true = false := actuallyTrue.symm.trans forcedFalse
  cases impossible

theorem openRightAfter_rightCompatible (stage : Nat) :
    Open.openCompatible
      (Open.openSystem.nextState (openRightBranchBefore stage)).agent
      (openWorld stage .right) := by
  have beforeCompatible :
      Open.openCompatible
        (openRightBranchBefore stage).agent
        (openRightBranchBefore stage).world :=
    Open.completionCompatibleWithView (Open.openStateAt stage).agent true
  have afterCompatible :=
    Open.openActualCompatible (openRightBranchBefore stage) beforeCompatible
  rw [Meta.ActiveSemanticClosure.ActiveSemanticClosureSystem.nextState_world]
    at afterCompatible
  exact afterCompatible

theorem openRightAfter_leftIncompatible (stage : Nat) :
    Open.openCompatible
      (Open.openSystem.nextState (openRightBranchBefore stage)).agent
      (openWorld stage .left) → False := by
  intro compatible
  let index := (Open.openStateAt stage).agent.candidate.values.length
  have learned :
      Open.lookupBool
          (Open.openSystem.nextState (openRightBranchBefore stage)).agent.candidate.values
          index = some true := by
    rw [openRightAfter_candidate]
    exact Open.lookupBool_append_new _ true
  have forcedTrue := compatible index true learned
  have actuallyFalse : (openWorld stage .left).valueAt index = false :=
    completionWorld_atFresh _ false
  have impossible : false = true := actuallyFalse.symm.trans forcedTrue
  cases impossible

theorem openCompatibilityExact
    (stage : Nat)
    (s : PositiveInstance.State)
    (w : PositiveInstance.World) :
    Compatible PositiveInstance.actionModel s w ↔
      Open.openCompatible (openState stage s) (openWorld stage w) := by
  cases s with
  | initial =>
      cases w with
      | left =>
          constructor
          · intro _
            exact
              Open.completionCompatibleWithView
                (Open.openStateAt stage).agent false
          · intro _
            rfl

      | right =>
          constructor
          · intro _
            exact
              Open.completionCompatibleWithView
                (Open.openStateAt stage).agent true
          · intro _
            rfl
  | observedLeft =>
      cases w with
      | left =>
          constructor
          · intro _
            exact openPublishedAfter_leftCompatible stage
          · intro _
            rfl
      | right =>
          constructor
          · intro impossible
            exact False.elim (Bool.noConfusion impossible)
          · intro compatible
            exact False.elim (openPublishedAfter_rightIncompatible stage compatible)
  | observedRight =>
      cases w with
      | left =>
          constructor
          · intro impossible
            exact False.elim (Bool.noConfusion impossible)
          · intro compatible
            exact False.elim (openRightAfter_leftIncompatible stage compatible)
      | right =>
          constructor
          · intro _
            exact openRightAfter_rightCompatible stage
          · intro _
            rfl

def openQueryAt (stage : Nat) :
    Open.OpenQuery (Open.freshGap (Open.openStateAt stage).agent).index :=
  Open.openSystem.selectQuery
    (Open.openSystem.executeTransport
      (Open.openStateAt stage).agent
      (Open.freshGap (Open.openStateAt stage).agent)
      (Open.openSystem.authorize
        (Open.openStateAt stage).agent
        (Open.freshGap (Open.openStateAt stage).agent)))

def openResponseAt
    (stage : Nat) (w : PositiveInstance.World) :
    Open.OpenResponse (openQueryAt stage) :=
  Open.openSystem.respond (openWorld stage w) (openQueryAt stage)

def openAction : PositiveInstance.World → Bool
  | .left => false
  | .right => true

theorem openResponseAt_value
    (stage : Nat) (w : PositiveInstance.World) :
    LatentRepair.openResponseValue (openResponseAt stage w) = openAction w := by
  cases w with
  | left =>
      change
        (openWorld stage .left).valueAt
            (Open.openStateAt stage).agent.candidate.values.length = false
      exact completionWorld_atFresh _ false
  | right =>
      change
        (openWorld stage .right).valueAt
            (Open.openStateAt stage).agent.candidate.values.length = true
      exact completionWorld_atFresh _ true

theorem openResponseAt_separated (stage : Nat) :
    openResponseAt stage .left = openResponseAt stage .right → False := by
  intro equality
  have valuesEqual :=
    congrArg LatentRepair.openResponseValue equality
  rw [openResponseAt_value, openResponseAt_value] at valuesEqual
  cases valuesEqual

abbrev OpenClosureAt (stage : Nat) :=
  LatentRepair.CertifiedLatentRepairStep
    Open.openSystem Open.openEvidenceRealization
    (Open.openStateAt stage) (Open.openStateAt (stage + 1))
    (Open.freshGap (Open.openStateAt stage).agent)

def openLegacyAdapterAt (stage : Nat) :
    BinaryPublicFiberAdapter
      Open.OpenWorld Open.OpenAgentState Bool
      (Open.OpenResponse (openQueryAt stage)) (OpenClosureAt stage) :=
  {
    legacyCompatible := Open.openCompatible
    legacyRequired := fun world =>
      Open.openEvaluate world
        (Open.freshGap (Open.openStateAt stage).agent).index
    legacyRespond := fun world =>
      Open.openSystem.respond world (openQueryAt stage)
    world := openWorld stage
    state := openState stage
    legacyBefore := (Open.openStateAt stage).agent
    legacyActualAfter := (Open.openStateAt (stage + 1)).agent
    initialStateExact := rfl
    actualAfterStateExact := rfl
    response := openResponseAt stage
    action := openAction
    compatibilityExact := openCompatibilityExact stage
    responseExact := by
      intro w
      rfl
    responsesSeparated := openResponseAt_separated stage
    requiredExact := by
      intro w
      cases w <;> exact completionWorld_atFresh _ _
    actionsSeparated := by
      intro equality
      cases equality
    legacyClosure := LatentRepair.openCertifiedLatentRepairAt stage
    adaptiveRepairability := PositiveInstance.exactInstanceCertifiedRepairable
  }

abbrev FiniteAdapter0 :=
  BinaryPublicFiberAdapter
    Finite.World Finite.AgentState Finite.Value
    (Finite.Response Finite.query0) FiniteClosure0

abbrev FiniteAdapter1 :=
  BinaryPublicFiberAdapter
    Finite.World Finite.AgentState Finite.Value
    (Finite.Response Finite.query1) FiniteClosure1

abbrev FiniteAdapter2 :=
  BinaryPublicFiberAdapter
    Finite.World Finite.AgentState Finite.Value
    (Finite.Response Finite.query2) FiniteClosure2

abbrev OpenAdapterAt (stage : Nat) :=
  BinaryPublicFiberAdapter
    Open.OpenWorld Open.OpenAgentState Bool
    (Open.OpenResponse (openQueryAt stage)) (OpenClosureAt stage)

structure LegacyAdaptiveIntegration where
  finiteFirst : FiniteAdapter0
  finiteSecond : FiniteAdapter1
  finiteThird : FiniteAdapter2
  finiteFirstToSecond :
    finiteFirst.legacyActualAfter = finiteSecond.legacyBefore
  finiteSecondToThird :
    finiteSecond.legacyActualAfter = finiteThird.legacyBefore
  openAt : ∀ stage, OpenAdapterAt stage
  openSequential :
    ∀ stage,
      (openAt stage).legacyActualAfter =
        (openAt (stage + 1)).legacyBefore

def legacyAdaptiveIntegration : LegacyAdaptiveIntegration :=
  {
    finiteFirst := finiteLegacyAdapter0
    finiteSecond := finiteLegacyAdapter1
    finiteThird := finiteLegacyAdapter2
    finiteFirstToSecond := rfl
    finiteSecondToThird := rfl
    openAt := openLegacyAdapterAt
    openSequential := by
      intro stage
      rfl
  }

/- AXIOM_AUDIT_BEGIN -/
#print axioms alternateState1_rightCompatible
#print axioms alternateState2_rightCompatible
#print axioms alternateState3_rightCompatible
#print axioms finiteCompatibilityExact
#print axioms finiteLegacyAdapter0
#print axioms finiteLegacyAdapter1
#print axioms finiteLegacyAdapter2
#print axioms openCompatibilityExact
#print axioms openLegacyAdapterAt
#print axioms legacyAdaptiveIntegration
/- AXIOM_AUDIT_END -/
