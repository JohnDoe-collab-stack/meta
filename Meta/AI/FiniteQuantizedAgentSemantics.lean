import Meta.AI.QuantizedInference
import Meta.AI.FiniteInterventionMatrix

/-!
# Typed finite inputs for the quantized certifiable agent

Every expected class below is computed from the dependent finite causal API.
Interventions enter only at their declared equation: downstream heads consume
the replacement one-hot, while no head is trained to predict its own forced
intervention.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace FiniteQuantized

open Finite
open Interventions
open Quantized

def certifiableArchitecture : QuantizedArchitecture where
  hiddenDim := 64
  headSpec
    | .gap =>
        { inputDim := 96, outputDim := 64, validClasses := [18, 28, 29] }
    | .use =>
        { inputDim := 160, outputDim := 8, validClasses := [0, 2] }
    | .transport =>
        { inputDim := 168
          outputDim := 64
          validClasses := [0, 2, 8, 10, 12, 14, 20, 22] }
    | .query =>
        { inputDim := 232, outputDim := 9, validClasses := [0, 1, 3, 4, 6, 7] }
    | .repair =>
        { inputDim := 257
          outputDim := 10
          validClasses := [1, 2, 3, 4, 5, 6, 7, 8, 9] }

def oneHot (size index : Nat) : List Int :=
  (List.range size).map fun position => if position = index then 1 else 0

def valueCode : Value -> Nat
  | .red => 0
  | .green => 1
  | .blue => 2

def indexCode : Index -> Nat
  | .first => 0
  | .second => 1
  | .third => 2

def knowledgeClass : Knowledge -> Nat
  | .unknown => 0
  | .excludes value => 1 + valueCode value
  | .exact value => 4 + valueCode value

def optionValueClass : Option Value -> Nat
  | none => 0
  | some value => 1 + valueCode value

def knowledgeFeatures (knowledge : Knowledge) : List Int :=
  oneHot 7 (knowledgeClass knowledge)

def observationFeatures (observation : Observation) : List Int :=
  knowledgeFeatures observation.first ++
    knowledgeFeatures observation.second ++
    knowledgeFeatures observation.third

def candidateFeatures (candidate : Candidate) : List Int :=
  oneHot 4 (optionValueClass candidate.first) ++
    oneHot 4 (optionValueClass candidate.second) ++
    oneHot 4 (optionValueClass candidate.third)

def answerFeatures : Option Value -> List Int
  | none => [0, 0, 0]
  | some value => oneHot 3 (valueCode value)

def boolInt : Bool -> Int
  | false => 0
  | true => 1

def recordFeatures (record : RepairRecord) : List Int :=
  oneHot 3 (indexCode record.index) ++
    answerFeatures record.answer ++
    [boolInt record.changedCandidate]

def emptyRecordFeatures : List Int := [0, 0, 0, 0, 0, 0, 0]

def historyFeatures : List RepairRecord -> Nat -> List Int
  | _, 0 => []
  | [], slots + 1 => emptyRecordFeatures ++ historyFeatures [] slots
  | record :: records, slots + 1 =>
      recordFeatures record ++ historyFeatures records slots

def stateInput (view : AgentState) : List Int :=
  observationFeatures view.observation ++
    candidateFeatures view.candidate ++
    historyFeatures view.history 3 ++
    oneHot 4 view.history.length ++
    List.replicate 38 0

def gapEvidenceClass
    {view : AgentState}
    {index : Index}
    {kind : OperationalGapKind}
    (evidence : GapEvidence view index kind) : Nat :=
  match evidence with
  | .exactWrong _ target _ _ _ _ =>
      indexCode index * 3 + valueCode target
  | .exactMissing _ target _ _ =>
      9 + indexCode index * 3 + valueCode target
  | .excludedPrediction _ excluded _ _ =>
      18 + indexCode index * 3 + valueCode excluded
  | .unknown _ _ => 27 + indexCode index
  | .excludedFiber _ excluded _ _ =>
      30 + indexCode index * 3 + valueCode excluded

def gapClass
    {view : AgentState}
    (gap : Gap view) : Nat :=
  gapEvidenceClass gap.observableEvidence

def useClass
    {view : AgentState}
    {gap : Gap view}
    (use : AuthorizedUse view gap) : Nat :=
  match use.direction with
  | .correctWitnessedMismatch => 0
  | .inspectWitnessedMismatch => 1
  | .resolveFiber => 2
  | .inspectFiber => 3

def focusCode : ReadingFocus -> Nat
  | .candidate => 0
  | .evidence => 1

def transportClass
    {view : AgentState}
    {gap : Gap view}
    {use : AuthorizedUse view gap}
    (transport : AuthorizedTransport view gap use) : Nat :=
  (indexCode transport.output.requestedIndex * 4 + useClass use) * 2 +
    focusCode transport.reading.focus

def queryKindCode
    {index : Index} : Query index -> Nat
  | .reveal _ => 0
  | .confirm _ => 1
  | .noInformation _ => 2

def queryClass
    {index : Index}
    (query : Query index) : Nat :=
  indexCode index * 3 + queryKindCode query

def responseClass
    {index : Index}
    {query : Query index} : Response query -> Nat
  | .revealed value => indexCode index * 3 + valueCode value
  | .confirmed value => indexCode index * 3 + valueCode value
  | .noInformation => 9 + indexCode index

def patchClass : CandidatePatch -> Nat
  | .keep => 0
  | .set index value => 1 + indexCode index * 3 + valueCode value

def gapInput
    (view : AgentState)
    (gap : Gap view) : List Int :=
  stateInput view ++ oneHot 64 (gapClass gap)

def useInput
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap) : List Int :=
  gapInput view gap ++ oneHot 8 (useClass use)

def transportInput
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap)
    (transport : AuthorizedTransport view gap use) : List Int :=
  useInput view gap use ++ oneHot 64 (transportClass transport)

def repairInput
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap)
    (transport : AuthorizedTransport view gap use)
    (query : Query gap.index)
    (response : Response query) : List Int :=
  transportInput view gap use transport ++ oneHot 9 (queryClass query) ++
    oneHot 16 (responseClass response)

def gapExample
    (view : AgentState)
    (gap : Gap view) : CertifiedExample :=
  { head := .gap, input := stateInput view, expected := gapClass gap }

def useExample
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap) : CertifiedExample :=
  { head := .use, input := gapInput view gap, expected := useClass use }

def transportExample
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap)
    (transport : AuthorizedTransport view gap use) : CertifiedExample :=
  { head := .transport
    input := useInput view gap use
    expected := transportClass transport }

def queryExample
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap)
    (transport : AuthorizedTransport view gap use)
    (query : Query gap.index) : CertifiedExample :=
  { head := .query
    input := transportInput view gap use transport
    expected := queryClass query }

def repairExample
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap)
    (transport : AuthorizedTransport view gap use)
    (query : Query gap.index)
    (response : Response query)
    (repair :
      IntrinsicRepair
        finiteData finiteGapLanguage finiteTransportLanguage
        finiteInteractionLanguage view gap use transport query response) :
    CertifiedExample :=
  { head := .repair
    input := repairInput view gap use transport query response
    expected := patchClass repair.candidatePatch }

def fullRunExamples
    (state : ClosedState)
    (gap : Gap state.agent)
    (run : IntervenedOpenRun finiteSystem state gap) :
    List CertifiedExample :=
  [gapExample state.agent gap,
    useExample state.agent gap run.use,
    transportExample state.agent gap run.use run.transport,
    queryExample state.agent gap run.use run.transport run.query,
    repairExample state.agent gap run.use run.transport
      run.query run.response run.repair]

def examplesAfterGap
    (state : ClosedState)
    (gap : Gap state.agent)
    (run : IntervenedOpenRun finiteSystem state gap) :
    List CertifiedExample :=
  [useExample state.agent gap run.use,
    transportExample state.agent gap run.use run.transport,
    queryExample state.agent gap run.use run.transport run.query,
    repairExample state.agent gap run.use run.transport
      run.query run.response run.repair]

def examplesAfterUse
    (state : ClosedState)
    (gap : Gap state.agent)
    (run : IntervenedOpenRun finiteSystem state gap) :
    List CertifiedExample :=
  [transportExample state.agent gap run.use run.transport,
    queryExample state.agent gap run.use run.transport run.query,
    repairExample state.agent gap run.use run.transport
      run.query run.response run.repair]

def examplesAfterTransport
    (state : ClosedState)
    (gap : Gap state.agent)
    (run : IntervenedOpenRun finiteSystem state gap) :
    List CertifiedExample :=
  [queryExample state.agent gap run.use run.transport run.query,
    repairExample state.agent gap run.use run.transport
      run.query run.response run.repair]

def exampleAfterQuery
    (state : ClosedState)
    (gap : Gap state.agent)
    (run : IntervenedOpenRun finiteSystem state gap) :
    List CertifiedExample :=
  [repairExample state.agent gap run.use run.transport
    run.query run.response run.repair]

def naturalExamples (state : ClosedState) : List CertifiedExample :=
  match finiteSystem.detectGap state.agent with
  | .closed => []
  | .open gap =>
      let use := finiteSystem.authorize state.agent gap
      let transport := finiteSystem.executeTransport state.agent gap use
      let query := finiteSystem.selectQuery transport
      let response := finiteSystem.respond state.world query
      let repair := finiteSystem.buildRepair
        state.agent gap use transport query response
      [gapExample state.agent gap,
        useExample state.agent gap use,
        transportExample state.agent gap use transport,
        queryExample state.agent gap use transport query,
        repairExample state.agent gap use transport query response repair]

def allValues : List Value := [.red, .green, .blue]

def allWorlds : List World :=
  allValues.flatMap fun first =>
    allValues.flatMap fun second =>
      allValues.map fun third =>
        { first := first, second := second, third := third }

def stateAt (world : World) : Nat -> ClosedState
  | 0 => finiteSystem.initialState world
  | stage + 1 => finiteSystem.nextState (stateAt world stage)

def candidateEqB (left right : Candidate) : Bool := left == right

def observationEqB (left right : Observation) : Bool := left == right

def repairHistoryEqB
    (left right : List RepairRecord) : Bool := left == right

def agentStateEqB (left right : AgentState) : Bool :=
  candidateEqB left.candidate right.candidate &&
    observationEqB left.observation right.observation &&
    repairHistoryEqB left.history right.history

instance agentStateBEq : BEq AgentState where
  beq := agentStateEqB

def optionToList {α : Type} : Option α -> List α
  | none => []
  | some value => [value]

def gapsOfView (view : AgentState) : List (Gap view) :=
  optionToList (gapAt view .first) ++
    optionToList (gapAt view .second) ++
    optionToList (gapAt view .third)

def usesOfGap
    {view : AgentState}
    (gap : Gap view) : List (AuthorizedUse view gap) :=
  match gap with
  | ⟨_, .witnessedMismatch, evidence⟩ =>
      [ { direction := .correctWitnessedMismatch
          evidence := .mismatch evidence },
        { direction := .inspectWitnessedMismatch
          evidence := .inspectMismatch evidence } ]
  | ⟨_, .unresolvedFiber, evidence⟩ =>
      [ { direction := .resolveFiber
          evidence := .fiber evidence },
        { direction := .inspectFiber
          evidence := .inspectFiber evidence } ]

def transportWithFocus
    {view : AgentState}
    (gap : Gap view)
    (use : AuthorizedUse view gap)
    (focus : ReadingFocus) : AuthorizedTransport view gap use where
  reading :=
    { index := gap.index
      indexEq := rfl
      direction := use.direction
      directionEq := rfl
      focus := focus }
  output :=
    { requestedIndex := gap.index
      requestedEq := rfl
      informative := true }
  evidence :=
    { direction := use.direction
      directionEq := rfl
      informativeEq := rfl
      reachesGap := rfl }

def transportsOfUse
    {view : AgentState}
    (gap : Gap view)
    (use : AuthorizedUse view gap) :
    List (AuthorizedTransport view gap use) :=
  [transportWithFocus gap use .candidate,
    transportWithFocus gap use .evidence]

def repairExamplesOfTransport
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap)
    (transport : AuthorizedTransport view gap use) :
    List CertifiedExample :=
  let revealQuery := @Query.reveal gap.index
  let confirmQuery := @Query.confirm gap.index
  [ repairExample view gap use transport revealQuery (.revealed .red)
      (buildRepair view gap use transport revealQuery (.revealed .red)),
    repairExample view gap use transport revealQuery (.revealed .green)
      (buildRepair view gap use transport revealQuery (.revealed .green)),
    repairExample view gap use transport revealQuery (.revealed .blue)
      (buildRepair view gap use transport revealQuery (.revealed .blue)),
    repairExample view gap use transport confirmQuery (.confirmed .red)
      (buildRepair view gap use transport confirmQuery (.confirmed .red)),
    repairExample view gap use transport confirmQuery (.confirmed .green)
      (buildRepair view gap use transport confirmQuery (.confirmed .green)),
    repairExample view gap use transport confirmQuery (.confirmed .blue)
      (buildRepair view gap use transport confirmQuery (.confirmed .blue)) ]

def reachableAgentStates : List AgentState :=
  (allWorlds.flatMap fun world =>
    [ (stateAt world 0).agent,
      (stateAt world 1).agent,
      (stateAt world 2).agent,
      (stateAt world 3).agent ]).eraseDups

def certifiableAgentStates : List AgentState :=
  (reachableAgentStates ++
    [ Interventions.observationIntervenedState0.agent,
      FiniteInterventionMatrix.droppedHistoryState2.agent ]).eraseDups

def semanticGapInputs : List CertifiedExample :=
  certifiableAgentStates.flatMap fun view =>
    match finiteSystem.detectGap view with
    | .closed => []
    | .open gap => [gapExample view gap]

def semanticUseInputs : List CertifiedExample :=
  certifiableAgentStates.flatMap fun view =>
    (gapsOfView view).map fun gap =>
      useExample view gap (finiteSystem.authorize view gap)

def semanticTransportInputs : List CertifiedExample :=
  certifiableAgentStates.flatMap fun view =>
    (gapsOfView view).flatMap fun gap =>
      (usesOfGap gap).map fun use =>
        transportExample view gap use
          (finiteSystem.executeTransport view gap use)

def semanticQueryInputs : List CertifiedExample :=
  certifiableAgentStates.flatMap fun view =>
    (gapsOfView view).flatMap fun gap =>
      (usesOfGap gap).flatMap fun use =>
        (transportsOfUse gap use).map fun transport =>
          queryExample view gap use transport
            (finiteSystem.selectQuery transport)

def semanticRepairInputs : List CertifiedExample :=
  certifiableAgentStates.flatMap fun view =>
    (gapsOfView view).flatMap fun gap =>
      (usesOfGap gap).flatMap fun use =>
        (transportsOfUse gap use).flatMap fun transport =>
          repairExamplesOfTransport view gap use transport

def semanticCertifiedInputs : List CertifiedExample :=
  semanticGapInputs ++ semanticUseInputs ++ semanticTransportInputs ++
    semanticQueryInputs ++ semanticRepairInputs

def naturalCertifiedInputs : List CertifiedExample :=
  allWorlds.flatMap fun world =>
    naturalExamples (stateAt world 0) ++
      naturalExamples (stateAt world 1) ++
      naturalExamples (stateAt world 2) ++
      naturalExamples (stateAt world 3)

def interventionCertifiedInputs : List CertifiedExample :=
  fullRunExamples observationIntervenedState0
      FiniteInterventionMatrix.observationIntervenedGap0
      FiniteInterventionMatrix.finiteObservationOpenIntervention0 ++
    examplesAfterGap state0 alternateGap0 finiteGapIntervention0 ++
    examplesAfterGap state0
      FiniteInterventionMatrix.alternateGapThird0
      FiniteInterventionMatrix.finiteRandomGapIntervention0 ++
    examplesAfterUse state0 gap0 finiteUseIntervention0 ++
    examplesAfterTransport state0 gap0 finiteTransportIntervention0 ++
    exampleAfterQuery state0 gap0 finiteConfirmQueryIntervention0 ++
    exampleAfterQuery state0 gap0 finiteCrossedResponseIntervention0 ++
    naturalExamples FiniteInterventionMatrix.droppedHistoryState2

def certifiedInputs : List CertifiedExample :=
  (naturalCertifiedInputs ++ interventionCertifiedInputs).eraseDups

end FiniteQuantized
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.FiniteQuantized.certifiableArchitecture
#print axioms Meta.ActiveSemanticClosure.FiniteQuantized.stateInput
#print axioms Meta.ActiveSemanticClosure.FiniteQuantized.naturalCertifiedInputs
#print axioms Meta.ActiveSemanticClosure.FiniteQuantized.interventionCertifiedInputs
#print axioms Meta.ActiveSemanticClosure.FiniteQuantized.certifiedInputs
#print axioms Meta.ActiveSemanticClosure.FiniteQuantized.semanticCertifiedInputs
/- AXIOM_AUDIT_END -/
