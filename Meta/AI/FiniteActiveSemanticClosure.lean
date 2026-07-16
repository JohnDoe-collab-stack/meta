import Meta.AI.ActiveSemanticClosure

/-!
# Finite active semantic closure

A closed three-index model executes one witnessed mismatch followed by two
unresolved fibers.  Each environmental answer updates the candidate,
observation, and history through the intrinsic repair carried by the causal
kernel.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace Finite

inductive Value where
  | red
  | green
  | blue
  deriving DecidableEq

inductive Index where
  | first
  | second
  | third
  deriving DecidableEq

structure World where
  first : Value
  second : Value
  third : Value
  deriving DecidableEq

def World.at (world : World) : Index -> Value
  | .first => world.first
  | .second => world.second
  | .third => world.third

def World.set (world : World) (index : Index) (value : Value) : World :=
  match index with
  | .first => { world with first := value }
  | .second => { world with second := value }
  | .third => { world with third := value }

structure Candidate where
  first : Option Value
  second : Option Value
  third : Option Value
  deriving DecidableEq

def Candidate.at (candidate : Candidate) : Index -> Option Value
  | .first => candidate.first
  | .second => candidate.second
  | .third => candidate.third

def Candidate.set
    (candidate : Candidate)
    (index : Index)
    (value : Value) : Candidate :=
  match index with
  | .first => { candidate with first := some value }
  | .second => { candidate with second := some value }
  | .third => { candidate with third := some value }

inductive Knowledge where
  | unknown
  | excludes (value : Value)
  | exact (value : Value)
  deriving DecidableEq

def Knowledge.Allows (knowledge : Knowledge) (value : Value) : Prop :=
  match knowledge with
  | .unknown => True
  | .excludes excluded => value = excluded -> False
  | .exact known => value = known

structure Observation where
  first : Knowledge
  second : Knowledge
  third : Knowledge
  deriving DecidableEq

def Observation.at (observation : Observation) : Index -> Knowledge
  | .first => observation.first
  | .second => observation.second
  | .third => observation.third

def Observation.setExact
    (observation : Observation)
    (index : Index)
    (value : Value) : Observation :=
  match index with
  | .first => { observation with first := .exact value }
  | .second => { observation with second := .exact value }
  | .third => { observation with third := .exact value }

inductive CandidatePatch where
  | set (index : Index) (value : Value)
  | keep
  deriving DecidableEq

def applyCandidatePatch
    (candidate : Candidate) : CandidatePatch -> Candidate
  | .set index value => candidate.set index value
  | .keep => candidate

structure RepairRecord where
  index : Index
  answer : Option Value
  changedCandidate : Bool
  deriving DecidableEq

def interpret (candidate : Candidate) (index : Index) : Option Value :=
  candidate.at index

def evaluate (world : World) (index : Index) : Value :=
  world.at index

def Agrees (prediction : Option Value) (target : Value) : Prop :=
  prediction = some target

def observe (world : World) : Observation :=
  { first :=
      match world.first with
      | .red => .exact .red
      | .green => .excludes .red
      | .blue => .excludes .red
    second := .unknown
    third := .unknown }

def finiteData : ActiveClosureData where
  SemanticWorld := World
  Candidate := Candidate
  Observation := Observation
  RepairRecord := RepairRecord
  VisibleIndex := Index
  Prediction := Option Value
  Target := Value
  CandidatePatch := CandidatePatch
  interpret := interpret
  evaluate := evaluate
  Agrees := Agrees
  agrees_target_unique := by
    intro prediction leftTarget rightTarget agreesLeft agreesRight
    exact Option.some.inj (agreesLeft.symm.trans agreesRight)
  observe := observe
  applyCandidatePatch := applyCandidatePatch

abbrev AgentState := AgentClosureState finiteData
abbrev ClosedState := ActiveSemanticClosureState finiteData

inductive GapEvidence
    (view : AgentState) :
    Index -> OperationalGapKind -> Type where
  | exactWrong
      (index : Index)
      (target predicted : Value)
      (observationEq : view.observation.at index = .exact target)
      (candidateEq : view.candidate.at index = some predicted)
      (different : predicted = target -> False) :
      GapEvidence view index .witnessedMismatch
  | exactMissing
      (index : Index)
      (target : Value)
      (observationEq : view.observation.at index = .exact target)
      (candidateEq : view.candidate.at index = none) :
      GapEvidence view index .witnessedMismatch
  | excludedPrediction
      (index : Index)
      (excluded : Value)
      (observationEq : view.observation.at index = .excludes excluded)
      (candidateEq : view.candidate.at index = some excluded) :
      GapEvidence view index .witnessedMismatch
  | unknown
      (index : Index)
      (observationEq : view.observation.at index = .unknown) :
      GapEvidence view index .unresolvedFiber
  | excludedFiber
      (index : Index)
      (excluded : Value)
      (observationEq : view.observation.at index = .excludes excluded)
      (candidateNotExcluded :
        view.candidate.at index = some excluded -> False) :
      GapEvidence view index .unresolvedFiber

inductive UseDirection where
  | correctWitnessedMismatch
  | inspectWitnessedMismatch
  | resolveFiber
  | inspectFiber
  deriving DecidableEq

inductive UseEvidence
    (view : AgentState)
    (index : Index) :
    (kind : OperationalGapKind) ->
    GapEvidence view index kind ->
    UseDirection ->
    Type where
  | mismatch
      (gapEvidence : GapEvidence view index .witnessedMismatch) :
      UseEvidence
        view index .witnessedMismatch gapEvidence
        .correctWitnessedMismatch
  | inspectMismatch
      (gapEvidence : GapEvidence view index .witnessedMismatch) :
      UseEvidence
        view index .witnessedMismatch gapEvidence
        .inspectWitnessedMismatch
  | fiber
      (gapEvidence : GapEvidence view index .unresolvedFiber) :
      UseEvidence
        view index .unresolvedFiber gapEvidence
        .resolveFiber
  | inspectFiber
      (gapEvidence : GapEvidence view index .unresolvedFiber) :
      UseEvidence
        view index .unresolvedFiber gapEvidence
        .inspectFiber

def finiteGapLanguage : ActiveClosureGapLanguage finiteData where
  GapEvidence := GapEvidence
  UseDirection := UseDirection
  UseEvidence := UseEvidence

abbrev Gap (view : AgentState) :=
  OperationalGap finiteData finiteGapLanguage view

abbrev AuthorizedUse (view : AgentState) (gap : Gap view) :=
  GapAuthorizedUse finiteData finiteGapLanguage view gap

inductive ReadingFocus where
  | candidate
  | evidence
  deriving DecidableEq

structure AuthorizedReading
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap) where
  index : Index
  indexEq : index = gap.index
  direction : UseDirection
  directionEq : direction = use.direction
  focus : ReadingFocus

structure TransportOutput
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap)
    (reading : AuthorizedReading view gap use) where
  requestedIndex : Index
  requestedEq : requestedIndex = reading.index
  informative : Bool

structure TransportEvidence
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap)
    (reading : AuthorizedReading view gap use)
    (output : TransportOutput view gap use reading) where
  direction : UseDirection
  directionEq : direction = use.direction
  informativeEq : output.informative = true
  reachesGap : output.requestedIndex = gap.index

def finiteTransportLanguage :
    ActiveClosureTransportLanguage finiteData finiteGapLanguage where
  AuthorizedReading := AuthorizedReading
  TransportOutput := TransportOutput
  TransportEvidence := TransportEvidence

abbrev AuthorizedTransport
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap) :=
  GapAuthorizedTransport
    finiteData finiteGapLanguage finiteTransportLanguage view gap use

inductive Query : Index -> Type where
  | reveal (index : Index) : Query index
  | confirm (index : Index) : Query index
  | noInformation (index : Index) : Query index

inductive Response : {index : Index} -> Query index -> Type where
  | revealed (value : Value) : Response (.reveal index)
  | confirmed (value : Value) : Response (.confirm index)
  | noInformation : Response (.noInformation index)

inductive QueryAdmissible
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap)
    (transport : AuthorizedTransport view gap use) :
    Query gap.index -> Type where
  | reveal : QueryAdmissible view gap use transport (.reveal gap.index)
  | confirm : QueryAdmissible view gap use transport (.confirm gap.index)

inductive ObservationUpdate
    (observation : Observation) :
    {index : Index} ->
    (query : Query index) ->
    Response query ->
    Type where
  | revealed
      (index : Index)
      (value : Value) :
      ObservationUpdate observation (.reveal index) (.revealed value)
  | confirmed
      (index : Index)
      (value : Value) :
      ObservationUpdate observation (.confirm index) (.confirmed value)
  | noInformation
      (index : Index) :
      ObservationUpdate
        observation (.noInformation index) .noInformation

def applyObservationUpdate
    {observation : Observation}
    {index : Index}
    {query : Query index}
    {response : Response query}
    (update : ObservationUpdate observation query response) : Observation := by
  cases update with
  | revealed value => exact observation.setExact index value
  | confirmed value => exact observation.setExact index value
  | noInformation => exact observation

def responseValue
    {index : Index}
    {query : Query index} : Response query -> Option Value
  | .revealed value => some value
  | .confirmed value => some value
  | .noInformation => none

def patchOfResponse
    (index : Index)
    {query : Query index}
    (response : Response query) : CandidatePatch :=
  match responseValue response with
  | some value => .set index value
  | none => .keep

def observationAfterResponse
    (observation : Observation)
    (index : Index)
    {query : Query index}
    (response : Response query) : Observation :=
  match responseValue response with
  | some value => observation.setExact index value
  | none => observation

def recordOfResponse
    (index : Index)
    {query : Query index}
    (response : Response query) : RepairRecord :=
  match responseValue response with
  | some value =>
      { index := index
        answer := some value
        changedCandidate := true }
  | none =>
      { index := index
        answer := none
        changedCandidate := false }

def updateOfResponse
    {observation : Observation}
    {index : Index}
    {query : Query index}
    (response : Response query) :
    ObservationUpdate observation query response := by
  cases response with
  | revealed value => exact .revealed index value
  | confirmed value => exact .confirmed index value
  | noInformation => exact .noInformation index

structure RepairDerivedFrom
    {observation : Observation}
    {index : Index}
    {query : Query index}
    (response : Response query)
    (patch : CandidatePatch)
    (update : ObservationUpdate observation query response)
    (record : RepairRecord) where
  causalIndex : Index
  causalIndexEq : causalIndex = index
  patchEq : patch = patchOfResponse index response
  updateEq :
    applyObservationUpdate update =
      observationAfterResponse observation index response
  recordEq : record = recordOfResponse index response

structure RepairProvenance
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap)
    (transport : AuthorizedTransport view gap use)
    (query : Query gap.index)
    (response : Response query)
    (patch : CandidatePatch)
    (update : ObservationUpdate view.observation query response)
    (record : RepairRecord) where
  recordedDirection : UseDirection
  recordedDirectionEq : recordedDirection = use.direction
  recordIndexEq : record.index = gap.index
  transportIndexEq : transport.output.requestedIndex = gap.index

abbrev finiteInteractionLanguage :
    ActiveClosureInteractionLanguage
      finiteData finiteGapLanguage finiteTransportLanguage where
  Query := Query
  Response := Response
  QueryAdmissible := QueryAdmissible
  ObservationUpdate := ObservationUpdate
  applyObservationUpdate := applyObservationUpdate
  RepairDerivedFrom := fun response patch update record =>
    RepairDerivedFrom response patch update record
  RepairProvenance := RepairProvenance

def gapAt (view : AgentState) (index : Index) : Option (Gap view) :=
  match observationEq : view.observation.at index with
  | .unknown =>
      some
        { index := index
          kind := .unresolvedFiber
          observableEvidence := .unknown index observationEq }
  | .excludes excluded =>
      match candidateEq : view.candidate.at index with
      | none =>
          some
            { index := index
              kind := .unresolvedFiber
              observableEvidence :=
                .excludedFiber index excluded observationEq (by
                  intro impossible
                  rw [candidateEq] at impossible
                  cases impossible) }
      | some predicted =>
          if same : predicted = excluded then
            some
              { index := index
                kind := .witnessedMismatch
                observableEvidence :=
                  .excludedPrediction
                    index excluded observationEq (candidateEq.trans (by rw [same])) }
          else
            some
              { index := index
                kind := .unresolvedFiber
                observableEvidence :=
                  .excludedFiber index excluded observationEq (by
                    intro impossible
                    rw [candidateEq] at impossible
                    cases impossible
                    exact same rfl) }
  | .exact target =>
      match candidateEq : view.candidate.at index with
      | none =>
          some
            { index := index
              kind := .witnessedMismatch
              observableEvidence :=
                .exactMissing index target observationEq candidateEq }
      | some predicted =>
          if same : predicted = target then
            none
          else
            some
              { index := index
                kind := .witnessedMismatch
                observableEvidence :=
                  .exactWrong
                    index target predicted observationEq candidateEq same }

def detectGap (view : AgentState) :
    OperationalGapStatus finiteData finiteGapLanguage view :=
  match gapAt view .first with
  | some gap => .open gap
  | none =>
      match gapAt view .second with
      | some gap => .open gap
      | none =>
          match gapAt view .third with
          | some gap => .open gap
          | none => .closed

def authorize (view : AgentState) :
    (gap : Gap view) -> AuthorizedUse view gap
  | ⟨_, .witnessedMismatch, evidence⟩ =>
      { direction := .correctWitnessedMismatch
        evidence := .mismatch evidence }
  | ⟨_, .unresolvedFiber, evidence⟩ =>
      { direction := .resolveFiber
        evidence := .fiber evidence }

def executeTransport
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap) :
    AuthorizedTransport view gap use where
  reading :=
    { index := gap.index
      indexEq := rfl
      direction := use.direction
      directionEq := rfl
      focus := .candidate }
  output :=
    { requestedIndex := gap.index
      requestedEq := rfl
      informative := true }
  evidence :=
    { direction := use.direction
      directionEq := rfl
      informativeEq := rfl
      reachesGap := rfl }

def selectQuery
    {view : AgentState}
    {gap : Gap view}
    {use : AuthorizedUse view gap}
    (transport : AuthorizedTransport view gap use) : Query gap.index :=
  match transport.reading.focus with
  | .candidate => @Query.reveal gap.index
  | .evidence => @Query.confirm gap.index

def selectedQueryAdmissible
    {view : AgentState}
    {gap : Gap view}
    {use : AuthorizedUse view gap}
    (transport : AuthorizedTransport view gap use) :
    QueryAdmissible view gap use transport (selectQuery transport) := by
  cases focusEq : transport.reading.focus with
  | candidate =>
      rw [selectQuery, focusEq]
      exact .reveal
  | evidence =>
      rw [selectQuery, focusEq]
      exact .confirm

def respond
    (world : World)
    {index : Index}
    (query : Query index) : Response query := by
  cases query with
  | reveal => exact .revealed (world.at index)
  | confirm => exact .confirmed (world.at index)
  | noInformation => exact .noInformation

structure ResponseFootprint
    {index : Index} (query : Query index) where
  requestedIndex : Index
  requestedIndex_eq : requestedIndex = index
  maxResponseBits : Nat

def responseFootprint
    {index : Index} (query : Query index) : ResponseFootprint query := by
  cases query with
  | reveal =>
      exact
        { requestedIndex := index
          requestedIndex_eq := rfl
          maxResponseBits := 2 }
  | confirm =>
      exact
        { requestedIndex := index
          requestedIndex_eq := rfl
          maxResponseBits := 2 }
  | noInformation =>
      exact
        { requestedIndex := index
          requestedIndex_eq := rfl
          maxResponseBits := 0 }

def WorldsAgreeOn
    {index : Index}
    {query : Query index}
    (footprint : ResponseFootprint query)
    (left right : World) : Prop :=
  left.at footprint.requestedIndex = right.at footprint.requestedIndex

def encodedResponseBits
    {index : Index}
    {query : Query index} : Response query -> Nat
  | .revealed _ => 2
  | .confirmed _ => 2
  | .noInformation => 0

theorem respond_local
    {index : Index}
    (query : Query index)
    (left right : World)
    (agree : WorldsAgreeOn (responseFootprint query) left right) :
    respond left query = respond right query := by
  cases query with
  | reveal =>
      have atIndex : left.at index = right.at index := by
        rw [<-(responseFootprint (Query.reveal index)).requestedIndex_eq]
        exact agree
      exact congrArg Response.revealed atIndex
  | confirm =>
      have atIndex : left.at index = right.at index := by
        rw [<-(responseFootprint (Query.confirm index)).requestedIndex_eq]
        exact agree
      exact congrArg Response.confirmed atIndex
  | noInformation => rfl

theorem respond_withinBound
    (world : World)
    {index : Index}
    (query : Query index) :
    encodedResponseBits (respond world query) <=
      (responseFootprint query).maxResponseBits := by
  cases query with
  | reveal =>
      change 2 <= 2
      exact Nat.le_refl 2
  | confirm =>
      change 2 <= 2
      exact Nat.le_refl 2
  | noInformation =>
      change 0 <= 0
      exact Nat.le_refl 0

def buildRepair
    (view : AgentState)
    (gap : Gap view)
    (use : AuthorizedUse view gap)
    (transport : AuthorizedTransport view gap use)
    (query : Query gap.index)
    (response : Response query) :
    IntrinsicRepair
      finiteData finiteGapLanguage finiteTransportLanguage
      finiteInteractionLanguage view gap use transport query response where
  candidatePatch := patchOfResponse gap.index response
  observationUpdate := updateOfResponse response
  historyRecord := recordOfResponse gap.index response
  responseUsed :=
    { causalIndex := gap.index
      causalIndexEq := rfl
      patchEq := rfl
      updateEq := by
        cases response <;> rfl
      recordEq := rfl }
  provenance :=
    { recordedDirection := use.direction
      recordedDirectionEq := rfl
      recordIndexEq := by
        cases response <;> rfl
      transportIndexEq := transport.evidence.reachesGap }

def knowledgeCompatible
    (observation : Observation)
    (world : World) : Prop :=
  observation.first.Allows world.first ∧
  observation.second.Allows world.second ∧
  observation.third.Allows world.third

def recordCompatible (record : RepairRecord) (world : World) : Prop :=
  match record.answer with
  | none => True
  | some value => world.at record.index = value

def compatibleWithViewHistory (view : AgentState) (world : World) : Prop :=
  knowledgeCompatible view.observation world ∧
  ∀ record, record ∈ view.history -> recordCompatible record world

def initialCandidate : Candidate :=
  { first := some .red
    second := none
    third := none }

def finiteSystem :
    ActiveSemanticClosureSystem
      finiteData finiteGapLanguage finiteTransportLanguage
      finiteInteractionLanguage where
  initialCandidate := initialCandidate
  detectGap := detectGap
  authorize := authorize
  executeTransport := executeTransport
  selectQuery := selectQuery
  selectedQueryAdmissible := selectedQueryAdmissible
  respond := fun world query => respond world query
  buildRepair := buildRepair
  CompatibleWithViewHistory := compatibleWithViewHistory

def canonicalWorld : World :=
  { first := .green
    second := .green
    third := .green }

def state0 : ClosedState :=
  finiteSystem.initialState canonicalWorld

def state1 : ClosedState :=
  finiteSystem.nextState state0

def state2 : ClosedState :=
  finiteSystem.nextState state1

def state3 : ClosedState :=
  finiteSystem.nextState state2

def state0_reachable :
    ReachableFromInitial finiteSystem canonicalWorld state0 :=
  .initial

def state1_reachable :
    ReachableFromInitial finiteSystem canonicalWorld state1 :=
  .next state0_reachable

def state2_reachable :
    ReachableFromInitial finiteSystem canonicalWorld state2 :=
  .next state1_reachable

def state3_reachable :
    ReachableFromInitial finiteSystem canonicalWorld state3 :=
  .next state2_reachable

def gap0 : Gap state0.agent :=
  { index := .first
    kind := .witnessedMismatch
    observableEvidence :=
      .excludedPrediction .first .red rfl rfl }

def gap1 : Gap state1.agent :=
  { index := .second
    kind := .unresolvedFiber
    observableEvidence := .unknown .second rfl }

def gap2 : Gap state2.agent :=
  { index := .third
    kind := .unresolvedFiber
    observableEvidence := .unknown .third rfl }

def use0 : AuthorizedUse state0.agent gap0 :=
  finiteSystem.authorize state0.agent gap0

def transport0 : AuthorizedTransport state0.agent gap0 use0 :=
  finiteSystem.executeTransport state0.agent gap0 use0

def inspectUse0 : AuthorizedUse state0.agent gap0 where
  direction := .inspectWitnessedMismatch
  evidence := .inspectMismatch gap0.observableEvidence

theorem use0_ne_inspectUse0 : use0 = inspectUse0 -> False := by
  intro equality
  have directionEquality := congrArg
    (fun use : AuthorizedUse state0.agent gap0 => use.direction) equality
  cases directionEquality

def evidenceReading0 : AuthorizedReading state0.agent gap0 use0 where
  index := gap0.index
  indexEq := rfl
  direction := use0.direction
  directionEq := rfl
  focus := .evidence

def evidenceTransport0 : AuthorizedTransport state0.agent gap0 use0 where
  reading := evidenceReading0
  output :=
    { requestedIndex := gap0.index
      requestedEq := rfl
      informative := true }
  evidence :=
    { direction := use0.direction
      directionEq := rfl
      informativeEq := rfl
      reachesGap := rfl }

def rejectedTransportOutput0 :
    TransportOutput state0.agent gap0 use0 transport0.reading where
  requestedIndex := gap0.index
  requestedEq := rfl
  informative := false

theorem rejectedTransportOutput0_hasNoEvidence :
    TransportEvidence
      state0.agent gap0 use0 transport0.reading rejectedTransportOutput0 -> False := by
  intro evidence
  cases evidence.informativeEq

theorem transport0_ne_evidenceTransport0 :
    transport0 = evidenceTransport0 -> False := by
  intro equality
  have focusEquality := congrArg
    (fun transport : AuthorizedTransport state0.agent gap0 use0 =>
      transport.reading.focus)
    equality
  cases focusEquality

def query0 : Query gap0.index :=
  finiteSystem.selectQuery transport0

def confirmQuery0 : Query gap0.index := .confirm gap0.index

def evidenceQuery0 : Query gap0.index :=
  finiteSystem.selectQuery evidenceTransport0

theorem evidenceQuery0_eq_confirm : evidenceQuery0 = confirmQuery0 := rfl

def confirmQuery0_admissible :
    QueryAdmissible state0.agent gap0 use0 transport0 confirmQuery0 :=
  .confirm

def noInformationQuery0 : Query gap0.index := .noInformation gap0.index

theorem noInformationQuery0_not_admissible :
    QueryAdmissible
      state0.agent gap0 use0 transport0 noInformationQuery0 -> False := by
  intro admissible
  cases admissible

theorem query0_ne_confirmQuery0 : query0 = confirmQuery0 -> False := by
  intro equality
  cases equality

def response0 : Response query0 :=
  finiteSystem.respond state0.world query0

def repair0 :=
  finiteSystem.buildRepair
    state0.agent gap0 use0 transport0 query0 response0

def use1 : AuthorizedUse state1.agent gap1 :=
  finiteSystem.authorize state1.agent gap1

def transport1 : AuthorizedTransport state1.agent gap1 use1 :=
  finiteSystem.executeTransport state1.agent gap1 use1

def query1 : Query gap1.index :=
  finiteSystem.selectQuery transport1

def response1 : Response query1 :=
  finiteSystem.respond state1.world query1

def repair1 :=
  finiteSystem.buildRepair
    state1.agent gap1 use1 transport1 query1 response1

def use2 : AuthorizedUse state2.agent gap2 :=
  finiteSystem.authorize state2.agent gap2

def transport2 : AuthorizedTransport state2.agent gap2 use2 :=
  finiteSystem.executeTransport state2.agent gap2 use2

def query2 : Query gap2.index :=
  finiteSystem.selectQuery transport2

def response2 : Response query2 :=
  finiteSystem.respond state2.world query2

def repair2 :=
  finiteSystem.buildRepair
    state2.agent gap2 use2 transport2 query2 response2

theorem state1_eq_executeRepair0 :
    state1 = ActiveSemanticClosureSystem.executeRepair state0 repair0 :=
  rfl

theorem state2_eq_executeRepair1 :
    state2 = ActiveSemanticClosureSystem.executeRepair state1 repair1 :=
  rfl

theorem state3_eq_executeRepair2 :
    state3 = ActiveSemanticClosureSystem.executeRepair state2 repair2 :=
  rfl

theorem state0_detects_gap0 :
    finiteSystem.detectGap state0.agent = .open gap0 :=
  rfl

theorem state1_detects_gap1 :
    finiteSystem.detectGap state1.agent = .open gap1 :=
  rfl

theorem state2_detects_gap2 :
    finiteSystem.detectGap state2.agent = .open gap2 :=
  rfl

theorem state0_gap_is_witnessedMismatch :
    ∃ gap,
      finiteSystem.detectGap state0.agent = .open gap ∧
      gap.kind = .witnessedMismatch := by
  exact ⟨gap0, state0_detects_gap0, rfl⟩

theorem state1_gap_is_unresolvedFiber :
    ∃ gap,
      finiteSystem.detectGap state1.agent = .open gap ∧
      gap.kind = .unresolvedFiber := by
  exact ⟨gap1, state1_detects_gap1, rfl⟩

theorem state2_gap_is_unresolvedFiber :
    ∃ gap,
      finiteSystem.detectGap state2.agent = .open gap ∧
      gap.kind = .unresolvedFiber := by
  exact ⟨gap2, state2_detects_gap2, rfl⟩

theorem state3_is_closed :
    finiteSystem.detectGap state3.agent = .closed :=
  rfl

theorem state1_differs_from_state0 : state1 = state0 -> False := by
  intro equality
  have candidateEquality := congrArg (fun state => state.agent.candidate) equality
  cases candidateEquality

theorem state2_differs_from_state1 : state2 = state1 -> False := by
  intro equality
  have candidateEquality := congrArg (fun state => state.agent.candidate) equality
  cases candidateEquality

theorem state3_differs_from_state2 : state3 = state2 -> False := by
  intro equality
  have candidateEquality := congrArg (fun state => state.agent.candidate) equality
  cases candidateEquality

def CorrectAt (world : World) (candidate : Candidate) (index : Index) : Prop :=
  Agrees (candidate.at index) (world.at index)

def ClosedOnAll (world : World) (candidate : Candidate) : Prop :=
  CorrectAt world candidate .first ∧
  CorrectAt world candidate .second ∧
  CorrectAt world candidate .third

def KnownClosedOnAll (view : AgentState) : Prop :=
  ∀ world,
    compatibleWithViewHistory view world ->
    ClosedOnAll world view.candidate

theorem state3_knownClosed : KnownClosedOnAll state3.agent := by
  intro world compatible
  have observationCompatible := compatible.1
  exact
    ⟨by
      change some Value.green = some world.first
      have firstEq : world.first = Value.green := observationCompatible.1
      rw [firstEq],
     by
      change some Value.green = some world.second
      have secondEq : world.second = Value.green := observationCompatible.2.1
      rw [secondEq],
     by
      change some Value.green = some world.third
      have thirdEq : world.third = Value.green := observationCompatible.2.2
      rw [thirdEq]⟩

def terminalRecordFirst : RepairRecord :=
  { index := .first
    answer := some .green
    changedCandidate := true }

def terminalRecordSecond : RepairRecord :=
  { index := .second
    answer := some .green
    changedCandidate := true }

def terminalRecordThird : RepairRecord :=
  { index := .third
    answer := some .green
    changedCandidate := true }

theorem state0_agent_eq :
    state0.agent =
      { candidate := initialCandidate
        observation :=
          { first := .excludes .red
            second := .unknown
            third := .unknown }
        history := [] } :=
  rfl

theorem state1_agent_eq :
    state1.agent =
      { candidate :=
          { first := some .green
            second := none
            third := none }
        observation :=
          { first := .exact .green
            second := .unknown
            third := .unknown }
        history := [terminalRecordFirst] } :=
  rfl

theorem state2_agent_eq :
    state2.agent =
      { candidate :=
          { first := some .green
            second := some .green
            third := none }
        observation :=
          { first := .exact .green
            second := .exact .green
            third := .unknown }
        history := [terminalRecordFirst, terminalRecordSecond] } :=
  rfl

theorem state3_agent_eq :
    state3.agent =
      { candidate :=
          { first := some .green
            second := some .green
            third := some .green }
        observation :=
          { first := .exact .green
            second := .exact .green
            third := .exact .green }
        history :=
          [terminalRecordFirst, terminalRecordSecond, terminalRecordThird] } :=
  rfl

theorem state3_world_eq : state3.world = canonicalWorld :=
  rfl

theorem state3_actualCompatible :
    compatibleWithViewHistory state3.agent state3.world := by
  rw [state3_agent_eq, state3_world_eq]
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

theorem state3_actualClosed : ClosedOnAll state3.world state3.agent.candidate :=
  state3_knownClosed state3.world state3_actualCompatible

theorem compatible_state0_iff (world : World) :
    compatibleWithViewHistory state0.agent world ↔
      (world.first = .red -> False) := by
  rw [state0_agent_eq]
  constructor
  · intro compatible
    exact compatible.1.1
  · intro firstNotRed
    constructor
    · exact ⟨firstNotRed, True.intro, True.intro⟩
    · intro record membership
      cases membership

theorem compatible_state1_iff (world : World) :
    compatibleWithViewHistory state1.agent world ↔
      world.first = .green := by
  rw [state1_agent_eq]
  constructor
  · intro compatible
    exact compatible.1.1
  · intro firstGreen
    constructor
    · exact ⟨firstGreen, True.intro, True.intro⟩
    · intro record membership
      cases membership with
      | head => exact firstGreen
      | tail _ membership => cases membership

theorem compatible_state2_iff (world : World) :
    compatibleWithViewHistory state2.agent world ↔
      world.first = .green ∧ world.second = .green := by
  rw [state2_agent_eq]
  constructor
  · intro compatible
    exact ⟨compatible.1.1, compatible.1.2.1⟩
  · intro coordinates
    constructor
    · exact ⟨coordinates.1, coordinates.2, True.intro⟩
    · intro record membership
      cases membership with
      | head => exact coordinates.1
      | tail _ membership =>
          cases membership with
          | head => exact coordinates.2
          | tail _ membership => cases membership

theorem compatible_state3_iff (world : World) :
    compatibleWithViewHistory state3.agent world ↔
      world.first = .green ∧
      world.second = .green ∧
      world.third = .green := by
  rw [state3_agent_eq]
  constructor
  · intro compatible
    exact compatible.1
  · intro coordinates
    constructor
    · exact coordinates
    · intro record membership
      cases membership with
      | head => exact coordinates.1
      | tail _ membership =>
          cases membership with
          | head => exact coordinates.2.1
          | tail _ membership =>
              cases membership with
              | head => exact coordinates.2.2
              | tail _ membership => cases membership

theorem state0_actualCompatible :
    compatibleWithViewHistory state0.agent state0.world := by
  apply (compatible_state0_iff state0.world).mpr
  intro equality
  cases equality

theorem state1_actualCompatible :
    compatibleWithViewHistory state1.agent state1.world :=
  (compatible_state1_iff state1.world).mpr rfl

theorem state2_actualCompatible :
    compatibleWithViewHistory state2.agent state2.world :=
  (compatible_state2_iff state2.world).mpr ⟨rfl, rfl⟩

structure WitnessedEvidenceCertificate
    (state : ClosedState)
    (gap : Gap state.agent)
    (kindEq : gap.kind = .witnessedMismatch)
    (disagrees :
      Agrees
        (state.agent.candidate.at gap.index)
        (state.world.at gap.index) -> False) where
  observableEvidence :
    GapEvidence state.agent gap.index .witnessedMismatch
  observableEvidenceEq :
    observableEvidence = kindEq ▸ gap.observableEvidence
  candidateRead : Option Value
  worldRead : Value
  candidateReadEq :
    state.agent.candidate.at gap.index = candidateRead
  worldReadEq : state.world.at gap.index = worldRead
  readsDisagree : Agrees candidateRead worldRead -> False
  semanticDisagreement :
    Agrees
      (state.agent.candidate.at gap.index)
      (state.world.at gap.index) -> False

structure FiberEvidenceCertificate
    (state : ClosedState)
    (gap : Gap state.agent)
    (kindEq : gap.kind = .unresolvedFiber)
    (leftWorld rightWorld : World)
    (leftCompatible :
      compatibleWithViewHistory state.agent leftWorld)
    (rightCompatible :
      compatibleWithViewHistory state.agent rightWorld)
    (targetsSeparated :
      leftWorld.at gap.index = rightWorld.at gap.index -> False) where
  observableEvidence :
    GapEvidence state.agent gap.index .unresolvedFiber
  observableEvidenceEq :
    observableEvidence = kindEq ▸ gap.observableEvidence
  leftRead : Value
  rightRead : Value
  leftReadEq : leftWorld.at gap.index = leftRead
  rightReadEq : rightWorld.at gap.index = rightRead
  readsSeparated : leftRead = rightRead -> False
  leftStillCompatible :
    compatibleWithViewHistory state.agent leftWorld
  rightStillCompatible :
    compatibleWithViewHistory state.agent rightWorld
  semanticSeparation :
    leftWorld.at gap.index = rightWorld.at gap.index -> False

def finiteEvidenceRealization : GapEvidenceRealization finiteSystem where
  WitnessedEvidenceRealization :=
    WitnessedEvidenceCertificate
  FiberEvidenceRealization :=
    FiberEvidenceCertificate

def secondFiberAlternative : World :=
  { first := .green
    second := .blue
    third := .green }

def thirdFiberAlternative : World :=
  { first := .green
    second := .green
    third := .blue }

theorem secondFiberAlternative_compatible :
    compatibleWithViewHistory state1.agent secondFiberAlternative :=
  (compatible_state1_iff secondFiberAlternative).mpr rfl

theorem thirdFiberAlternative_compatible :
    compatibleWithViewHistory state2.agent thirdFiberAlternative :=
  (compatible_state2_iff thirdFiberAlternative).mpr ⟨rfl, rfl⟩

def gap0SemanticEvidence :
    SemanticGapEvidence
      finiteSystem finiteEvidenceRealization state0 gap0 :=
  .witnessedMismatch rfl (by
    intro agreement
    cases agreement) {
      observableEvidence := gap0.observableEvidence
      observableEvidenceEq := rfl
      candidateRead := some .red
      worldRead := .green
      candidateReadEq := rfl
      worldReadEq := rfl
      readsDisagree := by
        intro agreement
        cases agreement
      semanticDisagreement := by
        intro agreement
        cases agreement }

def gap1SemanticEvidence :
    SemanticGapEvidence
      finiteSystem finiteEvidenceRealization state1 gap1 :=
  .unresolvedFiber rfl canonicalWorld secondFiberAlternative
    state1_actualCompatible secondFiberAlternative_compatible (by
      intro equality
      cases equality) {
        observableEvidence := gap1.observableEvidence
        observableEvidenceEq := rfl
        leftRead := .green
        rightRead := .blue
        leftReadEq := rfl
        rightReadEq := rfl
        readsSeparated := by
          intro equality
          cases equality
        leftStillCompatible := state1_actualCompatible
        rightStillCompatible := secondFiberAlternative_compatible
        semanticSeparation := by
          intro equality
          cases equality }

def gap2SemanticEvidence :
    SemanticGapEvidence
      finiteSystem finiteEvidenceRealization state2 gap2 :=
  .unresolvedFiber rfl canonicalWorld thirdFiberAlternative
    state2_actualCompatible thirdFiberAlternative_compatible (by
      intro equality
      cases equality) {
        observableEvidence := gap2.observableEvidence
        observableEvidenceEq := rfl
        leftRead := .green
        rightRead := .blue
        leftReadEq := rfl
        rightReadEq := rfl
        readsSeparated := by
          intro equality
          cases equality
        leftStillCompatible := state2_actualCompatible
        rightStillCompatible := thirdFiberAlternative_compatible
        semanticSeparation := by
          intro equality
          cases equality }

def typedGap0 :
    TypedSemanticGap
      finiteSystem finiteEvidenceRealization state0 gap0 :=
  typedSemanticGapOfEvidence state0_actualCompatible gap0SemanticEvidence

def typedGap1 :
    TypedSemanticGap
      finiteSystem finiteEvidenceRealization state1 gap1 :=
  typedSemanticGapOfEvidence state1_actualCompatible gap1SemanticEvidence

def typedGap2 :
    TypedSemanticGap
      finiteSystem finiteEvidenceRealization state2 gap2 :=
  typedSemanticGapOfEvidence state2_actualCompatible gap2SemanticEvidence

structure StrictCompatibleFiberReduction
    (before after : ClosedState) where
  laterImpliesEarlier :
    ∀ world,
      compatibleWithViewHistory after.agent world ->
      compatibleWithViewHistory before.agent world
  eliminatedWorld : World
  compatibleBefore :
    compatibleWithViewHistory before.agent eliminatedWorld
  incompatibleAfter :
    compatibleWithViewHistory after.agent eliminatedWorld -> False

def firstEliminatedWorld : World :=
  { first := .blue
    second := .green
    third := .green }

def secondEliminatedWorld : World := secondFiberAlternative

def thirdEliminatedWorld : World := thirdFiberAlternative

structure SelectedQuerySplitsCompatibleFiber
    (state : ClosedState)
    (gap : Gap state.agent)
    (use : AuthorizedUse state.agent gap)
    (transport : AuthorizedTransport state.agent gap use) where
  leftWorld : World
  rightWorld : World
  leftCompatible : compatibleWithViewHistory state.agent leftWorld
  rightCompatible : compatibleWithViewHistory state.agent rightWorld
  responsesSeparated :
    finiteSystem.respond leftWorld (finiteSystem.selectQuery transport) =
      finiteSystem.respond rightWorld (finiteSystem.selectQuery transport) -> False

def selectedQuery0_splitsCompatibleFiber :
    SelectedQuerySplitsCompatibleFiber state0 gap0 use0 transport0 where
  leftWorld := canonicalWorld
  rightWorld := firstEliminatedWorld
  leftCompatible := state0_actualCompatible
  rightCompatible := (compatible_state0_iff firstEliminatedWorld).mpr (by
    intro equality
    cases equality)
  responsesSeparated := by
    intro equality
    cases equality

def selectedQuery1_splitsCompatibleFiber :
    SelectedQuerySplitsCompatibleFiber state1 gap1 use1 transport1 where
  leftWorld := canonicalWorld
  rightWorld := secondFiberAlternative
  leftCompatible := state1_actualCompatible
  rightCompatible := secondFiberAlternative_compatible
  responsesSeparated := by
    intro equality
    cases equality

def selectedQuery2_splitsCompatibleFiber :
    SelectedQuerySplitsCompatibleFiber state2 gap2 use2 transport2 where
  leftWorld := canonicalWorld
  rightWorld := thirdFiberAlternative
  leftCompatible := state2_actualCompatible
  rightCompatible := thirdFiberAlternative_compatible
  responsesSeparated := by
    intro equality
    cases equality

def alternateResponse0 : Response query0 := .revealed .blue

def alternateRepair0 :=
  finiteSystem.buildRepair
    state0.agent gap0 use0 transport0 query0 alternateResponse0

def alternateState1 : ClosedState :=
  ActiveSemanticClosureSystem.executeRepair state0 alternateRepair0

def alternateResponse1 : Response query1 := .revealed .blue

def alternateRepair1 :=
  finiteSystem.buildRepair
    state1.agent gap1 use1 transport1 query1 alternateResponse1

def alternateState2 : ClosedState :=
  ActiveSemanticClosureSystem.executeRepair state1 alternateRepair1

def alternateResponse2 : Response query2 := .revealed .blue

def alternateRepair2 :=
  finiteSystem.buildRepair
    state2.agent gap2 use2 transport2 query2 alternateResponse2

def alternateState3 : ClosedState :=
  ActiveSemanticClosureSystem.executeRepair state2 alternateRepair2

theorem alternateResponse0_from_compatibleWorld :
    alternateResponse0 =
      finiteSystem.respond firstEliminatedWorld query0 :=
  rfl

theorem alternateResponse1_from_compatibleWorld :
    alternateResponse1 =
      finiteSystem.respond secondEliminatedWorld query1 :=
  rfl

theorem alternateResponse2_from_compatibleWorld :
    alternateResponse2 =
      finiteSystem.respond thirdEliminatedWorld query2 :=
  rfl

def state0_to_state1_strictFiberReduction :
    StrictCompatibleFiberReduction state0 state1 where
  laterImpliesEarlier := by
    intro world later
    apply (compatible_state0_iff world).mpr
    intro firstRed
    have firstGreen := (compatible_state1_iff world).mp later
    rw [firstRed] at firstGreen
    cases firstGreen
  eliminatedWorld := firstEliminatedWorld
  compatibleBefore := by
    apply (compatible_state0_iff firstEliminatedWorld).mpr
    intro equality
    cases equality
  incompatibleAfter := by
    intro compatible
    have firstGreen :=
      (compatible_state1_iff firstEliminatedWorld).mp compatible
    cases firstGreen

def state1_to_state2_strictFiberReduction :
    StrictCompatibleFiberReduction state1 state2 where
  laterImpliesEarlier := by
    intro world later
    exact (compatible_state1_iff world).mpr
      ((compatible_state2_iff world).mp later).1
  eliminatedWorld := secondEliminatedWorld
  compatibleBefore := secondFiberAlternative_compatible
  incompatibleAfter := by
    intro compatible
    have secondGreen :=
      ((compatible_state2_iff secondEliminatedWorld).mp compatible).2
    cases secondGreen

def state2_to_state3_strictFiberReduction :
    StrictCompatibleFiberReduction state2 state3 where
  laterImpliesEarlier := by
    intro world later
    have coordinates := (compatible_state3_iff world).mp later
    exact (compatible_state2_iff world).mpr
      ⟨coordinates.1, coordinates.2.1⟩
  eliminatedWorld := thirdEliminatedWorld
  compatibleBefore := thirdFiberAlternative_compatible
  incompatibleAfter := by
    intro compatible
    have thirdGreen :=
      ((compatible_state3_iff thirdEliminatedWorld).mp compatible).2.2
    cases thirdGreen

theorem alternateState1_actualIncompatible :
    compatibleWithViewHistory
      alternateState1.agent alternateState1.world -> False := by
  intro compatible
  have firstBlue := compatible.1.1
  change Value.green = Value.blue at firstBlue
  cases firstBlue

theorem alternateState2_actualIncompatible :
    compatibleWithViewHistory
      alternateState2.agent alternateState2.world -> False := by
  intro compatible
  have secondBlue := compatible.1.2.1
  change Value.green = Value.blue at secondBlue
  cases secondBlue

theorem alternateState3_actualIncompatible :
    compatibleWithViewHistory
      alternateState3.agent alternateState3.world -> False := by
  intro compatible
  have thirdBlue := compatible.1.2.2
  change Value.green = Value.blue at thirdBlue
  cases thirdBlue

theorem alternateResponse0_not_closesGap :
    GapClosedBy finiteSystem state0 gap0 alternateState1 -> False := by
  intro closure
  exact alternateState1_actualIncompatible closure.actualCompatible

theorem alternateResponse1_not_closesGap :
    GapClosedBy finiteSystem state1 gap1 alternateState2 -> False := by
  intro closure
  exact alternateState2_actualIncompatible closure.actualCompatible

theorem alternateResponse2_not_closesGap :
    GapClosedBy finiteSystem state2 gap2 alternateState3 -> False := by
  intro closure
  exact alternateState3_actualIncompatible closure.actualCompatible

def RepairsRetained (view : AgentState) : Prop :=
  ∀ record,
    record ∈ view.history ->
    match record.answer with
    | none => True
    | some value => view.candidate.at record.index = some value

theorem state1_retainsRepairs : RepairsRetained state1.agent := by
  rw [state1_agent_eq]
  intro record membership
  cases membership with
  | head => rfl
  | tail _ membership => cases membership

theorem state2_retainsRepairs : RepairsRetained state2.agent := by
  rw [state2_agent_eq]
  intro record membership
  cases membership with
  | head => rfl
  | tail _ membership =>
      cases membership with
      | head => rfl
      | tail _ membership => cases membership

theorem state3_retainsRepairs : RepairsRetained state3.agent := by
  rw [state3_agent_eq]
  intro record membership
  cases membership with
  | head => rfl
  | tail _ membership =>
      cases membership with
      | head => rfl
      | tail _ membership =>
          cases membership with
          | head => rfl
          | tail _ membership => cases membership

def gap0ClosedByState1 : GapClosedBy finiteSystem state0 gap0 state1 where
  worldPreserved := rfl
  actualCompatible := state1_actualCompatible
  knownCorrect := by
    intro world compatible
    change some Value.green = some world.first
    rw [(compatible_state1_iff world).mp compatible]

def gap1ClosedByState2 : GapClosedBy finiteSystem state1 gap1 state2 where
  worldPreserved := rfl
  actualCompatible := state2_actualCompatible
  knownCorrect := by
    intro world compatible
    change some Value.green = some world.second
    rw [((compatible_state2_iff world).mp compatible).2]

def gap2ClosedByState3 : GapClosedBy finiteSystem state2 gap2 state3 where
  worldPreserved := rfl
  actualCompatible := state3_actualCompatible
  knownCorrect := by
    intro world compatible
    change some Value.green = some world.third
    rw [((compatible_state3_iff world).mp compatible).2.2]

def repairedPrefix1 : List Index := [.first]

def repairedPrefix2 : List Index := [.first, .second]

def repairedPrefix3 : List Index := [.first, .second, .third]

theorem state1_knownClosedOnRepairedPrefix :
    KnownClosedOn
      finiteSystem state1.agent state1.agent.candidate repairedPrefix1 := by
  intro index membership
  cases membership with
  | head => exact gap0ClosedByState1.knownCorrect
  | tail _ membership => cases membership

theorem state2_knownClosedOnRepairedPrefix :
    KnownClosedOn
      finiteSystem state2.agent state2.agent.candidate repairedPrefix2 := by
  intro index membership
  cases membership with
  | head =>
      intro world compatible
      change some Value.green = some world.first
      rw [((compatible_state2_iff world).mp compatible).1]
  | tail _ membership =>
      cases membership with
      | head => exact gap1ClosedByState2.knownCorrect
      | tail _ membership => cases membership

theorem state3_knownClosedOnRepairedPrefix :
    KnownClosedOn
      finiteSystem state3.agent state3.agent.candidate repairedPrefix3 := by
  intro index membership
  cases membership with
  | head =>
      intro world compatible
      change some Value.green = some world.first
      rw [((compatible_state3_iff world).mp compatible).1]
  | tail _ membership =>
      cases membership with
      | head =>
          intro world compatible
          change some Value.green = some world.second
          rw [((compatible_state3_iff world).mp compatible).2.1]
      | tail _ membership =>
          cases membership with
          | head => exact gap2ClosedByState3.knownCorrect
          | tail _ membership => cases membership

def canonicalDomain : List Index := [.first, .second, .third]

def gapPresenceCount (view : AgentState) (index : Index) : Nat :=
  match gapAt view index with
  | none => 0
  | some _ => 1

def openGapCount (view : AgentState) : Nat :=
  gapPresenceCount view .first +
    gapPresenceCount view .second +
    gapPresenceCount view .third

theorem state0_openGapCount : openGapCount state0.agent = 3 := rfl

theorem state1_openGapCount : openGapCount state1.agent = 2 := rfl

theorem state2_openGapCount : openGapCount state2.agent = 1 := rfl

theorem state3_openGapCount : openGapCount state3.agent = 0 := rfl

theorem state1_strictlyReducesOpenGaps :
    openGapCount state1.agent < openGapCount state0.agent := by
  rw [state1_openGapCount, state0_openGapCount]
  exact Nat.lt_succ_self 2

theorem state2_strictlyReducesOpenGaps :
    openGapCount state2.agent < openGapCount state1.agent := by
  rw [state2_openGapCount, state1_openGapCount]
  exact Nat.lt_succ_self 1

theorem state3_strictlyReducesOpenGaps :
    openGapCount state3.agent < openGapCount state2.agent := by
  rw [state3_openGapCount, state2_openGapCount]
  exact Nat.lt_succ_self 0

def finiteClosureBound : Nat := canonicalDomain.length

def finiteStateAt : Nat -> ClosedState
  | 0 => state0
  | stage + 1 => finiteSystem.nextState (finiteStateAt stage)

theorem finiteStateAt_zero : finiteStateAt 0 = state0 := rfl

theorem finiteStateAt_one : finiteStateAt 1 = state1 := rfl

theorem finiteStateAt_two : finiteStateAt 2 = state2 := rfl

theorem finiteStateAt_bound : finiteStateAt finiteClosureBound = state3 := rfl

theorem finiteOrbit_reachesKnownClosedOn :
    KnownClosedOn finiteSystem
      (finiteStateAt finiteClosureBound).agent
      (finiteStateAt finiteClosureBound).agent.candidate
      canonicalDomain := by
  change KnownClosedOn finiteSystem
    state3.agent state3.agent.candidate repairedPrefix3
  exact state3_knownClosedOnRepairedPrefix

theorem finiteOrbit_reachesClosedOn :
    ClosedOn finiteData
      (finiteStateAt finiteClosureBound).world
      (finiteStateAt finiteClosureBound).agent.candidate
      canonicalDomain := by
  change ClosedOn finiteData state3.world state3.agent.candidate canonicalDomain
  intro index membership
  exact correctAt_of_knownCorrectAt
    (finiteOrbit_reachesKnownClosedOn index membership)
    state3_actualCompatible

structure FiniteClosureOrbitCertificate where
  firstGap :
    TypedSemanticGap
      finiteSystem finiteEvidenceRealization state0 gap0
  firstClosure : GapClosedBy finiteSystem state0 gap0 state1
  firstStrictReduction : StrictCompatibleFiberReduction state0 state1
  secondGap :
    TypedSemanticGap
      finiteSystem finiteEvidenceRealization state1 gap1
  secondClosure : GapClosedBy finiteSystem state1 gap1 state2
  secondStrictReduction : StrictCompatibleFiberReduction state1 state2
  thirdGap :
    TypedSemanticGap
      finiteSystem finiteEvidenceRealization state2 gap2
  thirdClosure : GapClosedBy finiteSystem state2 gap2 state3
  thirdStrictReduction : StrictCompatibleFiberReduction state2 state3
  firstResponseNecessary :
    GapClosedBy finiteSystem state0 gap0 alternateState1 -> False
  secondResponseNecessary :
    GapClosedBy finiteSystem state1 gap1 alternateState2 -> False
  thirdResponseNecessary :
    GapClosedBy finiteSystem state2 gap2 alternateState3 -> False
  firstStateChanges : state1 = state0 -> False
  secondStateChanges : state2 = state1 -> False
  thirdStateChanges : state3 = state2 -> False
  cumulativeClosure :
    KnownClosedOn
      finiteSystem state3.agent state3.agent.candidate repairedPrefix3
  cumulativeProvenance : RepairsRetained state3.agent
  terminalDetector : finiteSystem.detectGap state3.agent = .closed
  terminalStable : finiteSystem.nextState state3 = state3

theorem state3_is_stable : finiteSystem.nextState state3 = state3 :=
  finiteSystem.nextState_eq_self_of_closed state3 state3_is_closed

def finiteClosureOrbitCertificate : FiniteClosureOrbitCertificate where
  firstGap := typedGap0
  firstClosure := gap0ClosedByState1
  firstStrictReduction := state0_to_state1_strictFiberReduction
  secondGap := typedGap1
  secondClosure := gap1ClosedByState2
  secondStrictReduction := state1_to_state2_strictFiberReduction
  thirdGap := typedGap2
  thirdClosure := gap2ClosedByState3
  thirdStrictReduction := state2_to_state3_strictFiberReduction
  firstResponseNecessary := alternateResponse0_not_closesGap
  secondResponseNecessary := alternateResponse1_not_closesGap
  thirdResponseNecessary := alternateResponse2_not_closesGap
  firstStateChanges := state1_differs_from_state0
  secondStateChanges := state2_differs_from_state1
  thirdStateChanges := state3_differs_from_state2
  cumulativeClosure := state3_knownClosedOnRepairedPrefix
  cumulativeProvenance := state3_retainsRepairs
  terminalDetector := state3_is_closed
  terminalStable := state3_is_stable

end Finite
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.Finite.finiteSystem
#print axioms Meta.ActiveSemanticClosure.Finite.state3_reachable
#print axioms Meta.ActiveSemanticClosure.Finite.typedGap0
#print axioms Meta.ActiveSemanticClosure.Finite.typedGap1
#print axioms Meta.ActiveSemanticClosure.Finite.typedGap2
#print axioms Meta.ActiveSemanticClosure.Finite.state0_to_state1_strictFiberReduction
#print axioms Meta.ActiveSemanticClosure.Finite.state1_to_state2_strictFiberReduction
#print axioms Meta.ActiveSemanticClosure.Finite.state2_to_state3_strictFiberReduction
#print axioms Meta.ActiveSemanticClosure.Finite.gap0ClosedByState1
#print axioms Meta.ActiveSemanticClosure.Finite.gap1ClosedByState2
#print axioms Meta.ActiveSemanticClosure.Finite.gap2ClosedByState3
#print axioms Meta.ActiveSemanticClosure.Finite.alternateResponse0_not_closesGap
#print axioms Meta.ActiveSemanticClosure.Finite.alternateResponse1_not_closesGap
#print axioms Meta.ActiveSemanticClosure.Finite.alternateResponse2_not_closesGap
#print axioms Meta.ActiveSemanticClosure.Finite.respond_local
#print axioms Meta.ActiveSemanticClosure.Finite.respond_withinBound
#print axioms Meta.ActiveSemanticClosure.Finite.use0_ne_inspectUse0
#print axioms Meta.ActiveSemanticClosure.Finite.transport0_ne_evidenceTransport0
#print axioms Meta.ActiveSemanticClosure.Finite.noInformationQuery0_not_admissible
#print axioms Meta.ActiveSemanticClosure.Finite.selectedQuery0_splitsCompatibleFiber
#print axioms Meta.ActiveSemanticClosure.Finite.finiteOrbit_reachesKnownClosedOn
#print axioms Meta.ActiveSemanticClosure.Finite.finiteOrbit_reachesClosedOn
#print axioms Meta.ActiveSemanticClosure.Finite.finiteClosureOrbitCertificate
/- AXIOM_AUDIT_END -/
