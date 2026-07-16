import Meta.AI.FiniteInterventionMatrix

/-!
# Executable finite-conformance snapshot

The snapshot below is computed from the actual finite Lean system over all 27
worlds and stages 0--3.  It uses a length-prefixed numeric encoding because
Lean's standard `String` concatenation carries an excluded logical dependency;
the conformance artifact itself must remain strictly constructive.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace FiniteConformance

open Finite
open Interventions

def valueCode : Value -> Nat
  | .red => 0
  | .green => 1
  | .blue => 2

def indexCode : Index -> Nat
  | .first => 0
  | .second => 1
  | .third => 2

def optionValueCode : Option Value -> Nat
  | none => 3
  | some value => valueCode value

def knowledgeCode : Knowledge -> List Nat
  | .unknown => [0, 3]
  | .excludes value => [1, valueCode value]
  | .exact value => [2, valueCode value]

def candidateCode (candidate : Candidate) : List Nat :=
  [optionValueCode candidate.first,
    optionValueCode candidate.second,
    optionValueCode candidate.third]

def observationCode (observation : Observation) : List Nat :=
  knowledgeCode observation.first ++
    knowledgeCode observation.second ++
    knowledgeCode observation.third

def boolCode : Bool -> Nat
  | false => 0
  | true => 1

def recordCode (record : RepairRecord) : List Nat :=
  [indexCode record.index, optionValueCode record.answer,
    boolCode record.changedCandidate]

def recordsCode : List RepairRecord -> List Nat
  | [] => []
  | record :: records => recordCode record ++ recordsCode records

def agentCode (view : AgentState) : List Nat :=
  candidateCode view.candidate ++
    observationCode view.observation ++
    [view.history.length] ++ recordsCode view.history

def worldCode (world : World) : Nat :=
  valueCode world.first * 9 +
    valueCode world.second * 3 +
    valueCode world.third

def allValues : List Value := [.red, .green, .blue]

def allWorlds : List World :=
  allValues.flatMap fun first =>
    allValues.flatMap fun second =>
      allValues.map fun third =>
        { first := first, second := second, third := third }

def knowledgeAllowsB : Knowledge -> Value -> Bool
  | .unknown, _ => true
  | .excludes excluded, value => !(decide (value = excluded))
  | .exact known, value => decide (value = known)

def knowledgeCompatibleB
    (observation : Observation)
    (world : World) : Bool :=
  knowledgeAllowsB observation.first world.first &&
    knowledgeAllowsB observation.second world.second &&
    knowledgeAllowsB observation.third world.third

def recordCompatibleB (record : RepairRecord) (world : World) : Bool :=
  match record.answer with
  | none => true
  | some value => decide (world.at record.index = value)

def historyCompatibleB : List RepairRecord -> World -> Bool
  | [], _ => true
  | record :: records, world =>
      recordCompatibleB record world && historyCompatibleB records world

def compatibleB (view : AgentState) (world : World) : Bool :=
  knowledgeCompatibleB view.observation world &&
    historyCompatibleB view.history world

theorem boolAnd_eq_true_iff (left right : Bool) :
    (left && right) = true ↔ left = true ∧ right = true := by
  cases left <;> cases right <;> decide

theorem knowledgeAllowsB_eq_true_iff
    (knowledge : Knowledge)
    (value : Value) :
    knowledgeAllowsB knowledge value = true ↔ knowledge.Allows value := by
  cases knowledge with
  | unknown =>
      exact Iff.intro (fun _ => True.intro) (fun _ => rfl)
  | excludes excluded =>
      cases excluded <;> cases value <;>
        unfold knowledgeAllowsB Knowledge.Allows <;> decide
  | exact known =>
      constructor
      · intro equality
        change decide (value = known) = true at equality
        change value = known
        exact of_decide_eq_true equality
      · intro same
        change value = known at same
        change decide (value = known) = true
        exact decide_eq_true same

theorem recordCompatibleB_eq_true_iff
    (record : RepairRecord)
    (world : World) :
    recordCompatibleB record world = true ↔ recordCompatible record world := by
  cases answerEq : record.answer with
  | none =>
      rw [recordCompatibleB, recordCompatible, answerEq]
      exact Iff.intro (fun _ => True.intro) (fun _ => rfl)
  | some value =>
      rw [recordCompatibleB, recordCompatible, answerEq]
      constructor
      · intro equality
        exact of_decide_eq_true equality
      · intro same
        exact decide_eq_true same

theorem historyCompatibleB_eq_true_iff
    (history : List RepairRecord)
    (world : World) :
    historyCompatibleB history world = true ↔
      ∀ record, record ∈ history -> recordCompatible record world := by
  induction history with
  | nil =>
      constructor
      · intro _ record membership
        cases membership
      · intro _
        rfl
  | cons head tail inductionHypothesis =>
      constructor
      · intro equality record membership
        have parts :
            recordCompatibleB head world = true ∧
              historyCompatibleB tail world = true :=
          (boolAnd_eq_true_iff _ _).mp equality
        cases membership with
        | head =>
            exact (recordCompatibleB_eq_true_iff head world).mp parts.1
        | tail _ tailMembership =>
            exact (inductionHypothesis.mp parts.2) record tailMembership
      · intro compatible
        exact (boolAnd_eq_true_iff _ _).mpr
          ⟨(recordCompatibleB_eq_true_iff head world).mpr
              (compatible head (List.Mem.head tail)),
            inductionHypothesis.mpr
              (fun record membership =>
                compatible record (List.Mem.tail head membership))⟩

theorem compatibleB_eq_true_iff
    (view : AgentState)
    (world : World) :
    compatibleB view world = true ↔
      compatibleWithViewHistory view world := by
  constructor
  · intro equality
    have outer := (boolAnd_eq_true_iff _ _).mp equality
    have firstPair := (boolAnd_eq_true_iff _ _).mp outer.1
    have firstSecond := (boolAnd_eq_true_iff _ _).mp firstPair.1
    exact
      { left :=
          ⟨(knowledgeAllowsB_eq_true_iff
              view.observation.first world.first).mp firstSecond.1,
            (knowledgeAllowsB_eq_true_iff
              view.observation.second world.second).mp firstSecond.2,
            (knowledgeAllowsB_eq_true_iff
              view.observation.third world.third).mp firstPair.2⟩
        right := (historyCompatibleB_eq_true_iff view.history world).mp outer.2 }
  · intro compatible
    exact (boolAnd_eq_true_iff _ _).mpr
      ⟨(boolAnd_eq_true_iff _ _).mpr
          ⟨(boolAnd_eq_true_iff _ _).mpr
              ⟨(knowledgeAllowsB_eq_true_iff
                  view.observation.first world.first).mpr compatible.1.1,
                (knowledgeAllowsB_eq_true_iff
                  view.observation.second world.second).mpr compatible.1.2.1⟩,
            (knowledgeAllowsB_eq_true_iff
              view.observation.third world.third).mpr compatible.1.2.2⟩,
        (historyCompatibleB_eq_true_iff view.history world).mpr compatible.2⟩

def compatibleFiberCode (view : AgentState) : List Nat :=
  (allWorlds.filter (compatibleB view)).map worldCode

def gapKindCode : OperationalGapKind -> Nat
  | .witnessedMismatch => 0
  | .unresolvedFiber => 1

def evidenceConstructorCode : Nat -> Nat := id

def gapEvidenceCode
    {view : AgentState}
    {index : Index}
    {kind : OperationalGapKind}
    (evidence : GapEvidence view index kind) : List Nat :=
  match evidence with
  | .exactWrong _ target predicted _ _ _ =>
      [evidenceConstructorCode 0, valueCode target, valueCode predicted]
  | .exactMissing _ target _ _ =>
      [evidenceConstructorCode 1, valueCode target, 3]
  | .excludedPrediction _ excluded _ _ =>
      [evidenceConstructorCode 2, valueCode excluded, valueCode excluded]
  | .unknown _ _ => [evidenceConstructorCode 3, 3, 3]
  | .excludedFiber _ excluded _ _ =>
      [evidenceConstructorCode 4, valueCode excluded,
        optionValueCode (view.candidate.at index)]

def useDirectionCode : UseDirection -> Nat
  | .correctWitnessedMismatch => 0
  | .inspectWitnessedMismatch => 1
  | .resolveFiber => 2
  | .inspectFiber => 3

def readingFocusCode : ReadingFocus -> Nat
  | .candidate => 0
  | .evidence => 1

def queryKindCode {index : Index} : Query index -> Nat
  | .reveal _ => 0
  | .confirm _ => 1
  | .noInformation _ => 2

def responseCode
    {index : Index}
    {query : Query index} : Response query -> List Nat
  | .revealed value => [0, valueCode value]
  | .confirmed value => [1, valueCode value]
  | .noInformation => [2, 3]

def patchCode : CandidatePatch -> List Nat
  | .set index value => [0, indexCode index, valueCode value]
  | .keep => [1, 3, 3]

def frame (payload : List Nat) : List Nat := payload.length :: payload

def stateAt (world : World) : Nat -> ClosedState
  | 0 => finiteSystem.initialState world
  | stage + 1 => finiteSystem.nextState (stateAt world stage)

def openPayloadCode
    (state : ClosedState)
    (gap : Gap state.agent) : List Nat :=
  let use := finiteSystem.authorize state.agent gap
  let transport := finiteSystem.executeTransport state.agent gap use
  let query := finiteSystem.selectQuery transport
  let response := finiteSystem.respond state.world query
  let repair :=
    finiteSystem.buildRepair state.agent gap use transport query response
  let after := ActiveSemanticClosureSystem.executeRepair state repair
  [1, indexCode gap.index, gapKindCode gap.kind] ++
    gapEvidenceCode gap.observableEvidence ++
    [useDirectionCode use.direction,
      readingFocusCode transport.reading.focus,
      indexCode transport.output.requestedIndex,
      boolCode transport.output.informative,
      queryKindCode query] ++
    responseCode response ++ patchCode repair.candidatePatch ++
    observationCode
      (finiteInteractionLanguage.applyObservationUpdate
        repair.observationUpdate) ++
    recordCode repair.historyRecord ++
    frame (agentCode after.agent) ++
    frame (compatibleFiberCode after.agent)

def naturalRow (world : World) (stage : Nat) : List Nat :=
  let state := stateAt world stage
  let rowHead :=
    [0, worldCode world, stage] ++
      frame (agentCode state.agent) ++
      frame (compatibleFiberCode state.agent)
  match finiteSystem.detectGap state.agent with
  | .closed =>
      rowHead ++ [0] ++ frame (agentCode state.agent) ++
        frame (compatibleFiberCode state.agent)
  | .open gap => rowHead ++ openPayloadCode state gap

def naturalRows : List (List Nat) :=
  allWorlds.flatMap fun world =>
    [naturalRow world 0, naturalRow world 1,
      naturalRow world 2, naturalRow world 3]

def refusalStageCode :
    FiniteInterventionMatrix.RefusalStage -> Nat
  | .gap => 0
  | .use => 1
  | .transport => 2
  | .query => 3
  | .response => 4
  | .repair => 5
  | .next => 6

def intervenedPayloadCode
    (state : ClosedState)
    (gap : Gap state.agent)
    (run : Interventions.IntervenedOpenRun finiteSystem state gap)
    (after : ClosedState) : List Nat :=
  [indexCode gap.index, gapKindCode gap.kind] ++
    gapEvidenceCode gap.observableEvidence ++
    [useDirectionCode run.use.direction,
      readingFocusCode run.transport.reading.focus,
      indexCode run.transport.output.requestedIndex,
      boolCode run.transport.output.informative,
      queryKindCode run.query] ++
    responseCode run.response ++ patchCode run.repair.candidatePatch ++
    observationCode
      (finiteInteractionLanguage.applyObservationUpdate
        run.repair.observationUpdate) ++
    recordCode run.repair.historyRecord ++
    frame (agentCode after.agent) ++
    frame (compatibleFiberCode after.agent)

def advancedInterventionRow
    (code : Nat)
    (state : ClosedState)
    (gap : Gap state.agent)
    (run : Interventions.IntervenedOpenRun finiteSystem state gap)
    (after : ClosedState := run.after) : List Nat :=
  [1, code, 1] ++
    frame (agentCode state.agent) ++
    frame (compatibleFiberCode state.agent) ++
    intervenedPayloadCode state gap run after

def refusedInterventionRow
    (code : Nat)
    (stage : FiniteInterventionMatrix.RefusalStage) : List Nat :=
  [1, code, 0, refusalStageCode stage] ++
    frame (agentCode state0.agent) ++
    frame (compatibleFiberCode state0.agent) ++
    frame (agentCode state0.agent) ++
    frame (compatibleFiberCode state0.agent)

def interventionRows : List (List Nat) :=
  [
    advancedInterventionRow 0 state0 alternateGap0 finiteGapIntervention0,
    refusedInterventionRow 1 .gap,
    advancedInterventionRow 2 state1 gap1
      (Interventions.runWithGap finiteSystem state1 gap1)
      FiniteInterventionMatrix.droppedHistoryState2,
    refusedInterventionRow 3 .next,
    refusedInterventionRow 4 .transport,
    advancedInterventionRow 5 observationIntervenedState0
      FiniteInterventionMatrix.observationIntervenedGap0
      FiniteInterventionMatrix.finiteObservationOpenIntervention0,
    advancedInterventionRow 6 state0 gap0 finiteConfirmQueryIntervention0,
    refusedInterventionRow 7 .query,
    advancedInterventionRow 8 state0
      FiniteInterventionMatrix.alternateGapThird0
      FiniteInterventionMatrix.finiteRandomGapIntervention0,
    refusedInterventionRow 9 .repair,
    refusedInterventionRow 10 .repair,
    advancedInterventionRow 11 state0 gap0 finiteCrossedResponseIntervention0,
    refusedInterventionRow 12 .response,
    advancedInterventionRow 13 state0 gap0 finiteTransportIntervention0,
    refusedInterventionRow 14 .transport,
    refusedInterventionRow 15 .use,
    advancedInterventionRow 16 state0 gap0 finiteUseIntervention0,
    refusedInterventionRow 17 .use
  ]

def conformanceRows : List (List Nat) := naturalRows ++ interventionRows

#eval IO.println "V23_CONFORMANCE_BEGIN"
#eval conformanceRows
#eval IO.println "V23_CONFORMANCE_END"

end FiniteConformance
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.FiniteConformance.compatibleB_eq_true_iff
#print axioms Meta.ActiveSemanticClosure.FiniteConformance.naturalRows
#print axioms Meta.ActiveSemanticClosure.FiniteConformance.interventionRows
#print axioms Meta.ActiveSemanticClosure.FiniteConformance.conformanceRows
/- AXIOM_AUDIT_END -/
