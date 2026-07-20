import Meta.AI.ActiveSemanticClosure

/-!
# Open cumulative active semantic closure

This module gives an inhabited open instance of the active-closure kernel.
The candidate is a finite list of answers.  Its next unresolved index is the
length of that list.  Querying the semantic world at this index appends the
answer to the candidate and to the observation history.  Consequently every
finite stage preserves the repaired prefix and exposes a new fresh gap.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace Open

structure OpenWorld where
  valueAt : Nat -> Bool

structure OpenCandidate where
  values : List Bool
  deriving DecidableEq

def lookupBool : List Bool -> Nat -> Option Bool
  | [], _ => none
  | value :: _, 0 => some value
  | _ :: rest, index + 1 => lookupBool rest index

theorem lookupBool_length (values : List Bool) :
    lookupBool values values.length = none := by
  induction values with
  | nil => rfl
  | cons value rest inductionHypothesis =>
      exact inductionHypothesis

theorem lookupBool_append_existing
    {values : List Bool}
    {index : Nat}
    {value : Bool}
    (found : lookupBool values index = some value)
    (added : Bool) :
    lookupBool (values ++ [added]) index = some value := by
  induction values generalizing index with
  | nil =>
      cases index <;> cases found
  | cons head tail inductionHypothesis =>
      cases index with
      | zero => exact found
      | succ index =>
          exact inductionHypothesis found

theorem lookupBool_append_new (values : List Bool) (added : Bool) :
    lookupBool (values ++ [added]) values.length = some added := by
  induction values with
  | nil => rfl
  | cons head tail inductionHypothesis =>
      exact inductionHypothesis

theorem appendBool_assoc
    (first second third : List Bool) :
    (first ++ second) ++ third = first ++ (second ++ third) := by
  induction first with
  | nil => rfl
  | cons head tail inductionHypothesis =>
      exact congrArg (List.cons head) inductionHypothesis

theorem length_append_singleton_bool
    (values : List Bool)
    (added : Bool) :
    (values ++ [added]).length = values.length + 1 := by
  induction values with
  | nil => rfl
  | cons head tail inductionHypothesis =>
      exact congrArg Nat.succ inductionHypothesis

theorem lookupBool_append_cases
    (values : List Bool)
    (added : Bool)
    (index : Nat)
    (value : Bool)
    (found : lookupBool (values ++ [added]) index = some value) :
    (lookupBool values index = some value) ∨
      (index = values.length ∧ value = added) := by
  induction values generalizing index with
  | nil =>
      cases index with
      | zero =>
          right
          constructor
          · rfl
          · cases found
            rfl
      | succ index => cases found
  | cons head tail inductionHypothesis =>
      cases index with
      | zero =>
          left
          exact found
      | succ index =>
          cases inductionHypothesis index found with
          | inl earlier =>
              left
              exact earlier
          | inr fresh =>
              right
              constructor
              · exact congrArg Nat.succ fresh.1
              · exact fresh.2

def completionWorld
    (candidate : OpenCandidate)
    (freshValue : Bool) : OpenWorld where
  valueAt := fun index =>
    match lookupBool candidate.values index with
    | some value => value
    | none => if index = candidate.values.length then freshValue else false

def openInterpret (candidate : OpenCandidate) (index : Nat) : Option Bool :=
  lookupBool candidate.values index

def openEvaluate (world : OpenWorld) (index : Nat) : Bool :=
  world.valueAt index

def openAgrees (prediction : Option Bool) (target : Bool) : Prop :=
  prediction = some target

theorem openAgrees_target_unique
    (prediction : Option Bool)
    (leftTarget rightTarget : Bool)
    (left : openAgrees prediction leftTarget)
    (right : openAgrees prediction rightTarget) :
    leftTarget = rightTarget := by
  rw [left] at right
  cases right
  rfl

structure OpenObservation where
  answers : List Bool
  deriving DecidableEq

structure OpenCandidatePatch where
  value : Bool
  deriving DecidableEq

structure OpenRepairRecord where
  index : Nat
  value : Bool
  deriving DecidableEq

def openApplyCandidatePatch
    (candidate : OpenCandidate)
    (patch : OpenCandidatePatch) : OpenCandidate :=
  { values := candidate.values ++ [patch.value] }

def openData : ActiveClosureData where
  SemanticWorld := OpenWorld
  Candidate := OpenCandidate
  Observation := OpenObservation
  RepairRecord := OpenRepairRecord
  VisibleIndex := Nat
  Prediction := Option Bool
  Target := Bool
  CandidatePatch := OpenCandidatePatch
  interpret := openInterpret
  evaluate := openEvaluate
  Agrees := openAgrees
  agrees_target_unique := openAgrees_target_unique
  observe := fun _ => { answers := [] }
  applyCandidatePatch := openApplyCandidatePatch

abbrev OpenAgentState := AgentClosureState openData
abbrev OpenClosedState := ActiveSemanticClosureState openData

inductive OpenGapEvidence :
    (view : OpenAgentState) -> Nat -> OperationalGapKind -> Type where
  | fresh (view : OpenAgentState) :
      OpenGapEvidence view view.candidate.values.length .unresolvedFiber

inductive OpenUseDirection where
  | resolveFresh
  deriving DecidableEq

inductive OpenUseEvidence :
    (view : OpenAgentState) ->
    (index : Nat) ->
    (kind : OperationalGapKind) ->
    OpenGapEvidence view index kind ->
    OpenUseDirection -> Type where
  | resolve (view : OpenAgentState) :
      OpenUseEvidence view view.candidate.values.length .unresolvedFiber
        (.fresh view) .resolveFresh

def openGapLanguage : ActiveClosureGapLanguage openData where
  GapEvidence := OpenGapEvidence
  UseDirection := OpenUseDirection
  UseEvidence := OpenUseEvidence

abbrev OpenGap (view : OpenAgentState) :=
  OperationalGap openData openGapLanguage view

abbrev OpenAuthorizedUse (view : OpenAgentState) (gap : OpenGap view) :=
  GapAuthorizedUse openData openGapLanguage view gap

inductive OpenAuthorizedReading
    (view : OpenAgentState)
    (gap : OpenGap view)
    (use : OpenAuthorizedUse view gap) where
  | freshIndex

structure OpenTransportOutput
    (view : OpenAgentState)
    (gap : OpenGap view)
    (use : OpenAuthorizedUse view gap)
    (_reading : OpenAuthorizedReading view gap use) where
  requestedIndex : Nat
  requestedIndex_eq : requestedIndex = gap.index
  unresolvedBefore : openInterpret view.candidate requestedIndex = none

structure OpenTransportEvidence
    (view : OpenAgentState)
    (gap : OpenGap view)
    (use : OpenAuthorizedUse view gap)
    (reading : OpenAuthorizedReading view gap use)
    (output : OpenTransportOutput view gap use reading) : Type where
  direction_eq : use.direction = .resolveFresh
  reachesGap : output.requestedIndex = gap.index
  carriesFreshness : openInterpret view.candidate output.requestedIndex = none

def openTransportLanguage :
    ActiveClosureTransportLanguage openData openGapLanguage where
  AuthorizedReading := OpenAuthorizedReading
  TransportOutput := OpenTransportOutput
  TransportEvidence := OpenTransportEvidence

abbrev OpenAuthorizedTransport
    (view : OpenAgentState)
    (gap : OpenGap view)
    (use : OpenAuthorizedUse view gap) :=
  GapAuthorizedTransport
    openData openGapLanguage openTransportLanguage view gap use

inductive OpenQuery : Nat -> Type where
  | reveal (index : Nat) : OpenQuery index

inductive OpenResponse : {index : Nat} -> OpenQuery index -> Type where
  | revealed {index : Nat} (value : Bool) :
      OpenResponse (.reveal index)

inductive OpenQueryAdmissible
    (view : OpenAgentState)
    (gap : OpenGap view)
    (use : OpenAuthorizedUse view gap)
    (transport : OpenAuthorizedTransport view gap use) :
    OpenQuery gap.index -> Type where
  | fresh : OpenQueryAdmissible view gap use transport (.reveal gap.index)

inductive OpenObservationUpdate :
    (observation : OpenObservation) ->
    {index : Nat} ->
    (query : OpenQuery index) ->
    OpenResponse query -> Type where
  | append
      (observation : OpenObservation)
      (index : Nat)
      (value : Bool) :
      OpenObservationUpdate observation (.reveal index) (.revealed value)

def applyOpenObservationUpdate :
    {observation : OpenObservation} ->
    {index : Nat} ->
    {query : OpenQuery index} ->
    {response : OpenResponse query} ->
    OpenObservationUpdate observation query response ->
    OpenObservation
  | observation, _, .reveal _, .revealed value, .append _ _ _ =>
      { answers := observation.answers ++ [value] }

inductive OpenRepairDerivedFrom :
    {index : Nat} ->
    {query : OpenQuery index} ->
    (response : OpenResponse query) ->
    (patch : OpenCandidatePatch) ->
    OpenObservationUpdate observation query response ->
    OpenRepairRecord -> Type where
  | derived
      (observation : OpenObservation)
      (index : Nat)
      (value : Bool) :
      OpenRepairDerivedFrom
        (.revealed value)
        { value := value }
        (.append observation index value)
        { index := index, value := value }

structure OpenRepairProvenance
    (view : OpenAgentState)
    (gap : OpenGap view)
    (use : OpenAuthorizedUse view gap)
    (transport : OpenAuthorizedTransport view gap use)
    (query : OpenQuery gap.index)
    (response : OpenResponse query)
    (patch : OpenCandidatePatch)
    (update : OpenObservationUpdate view.observation query response)
    (record : OpenRepairRecord) : Type where
  transportIndex_eq : transport.output.requestedIndex = gap.index
  recordIndex_eq : record.index = gap.index
  patchValue_eq_record : patch.value = record.value

def openInteractionLanguage :
    ActiveClosureInteractionLanguage
      openData openGapLanguage openTransportLanguage where
  Query := OpenQuery
  Response := OpenResponse
  QueryAdmissible := OpenQueryAdmissible
  ObservationUpdate := OpenObservationUpdate
  applyObservationUpdate := applyOpenObservationUpdate
  RepairDerivedFrom := OpenRepairDerivedFrom
  RepairProvenance := OpenRepairProvenance

def freshGap (view : OpenAgentState) : OpenGap view :=
  { index := view.candidate.values.length
    kind := .unresolvedFiber
    observableEvidence := .fresh view }

def openAuthorize
    (view : OpenAgentState)
    (gap : OpenGap view) : OpenAuthorizedUse view gap := by
  cases gap with
  | mk index kind evidence =>
      cases evidence
      exact
        { direction := .resolveFresh
          evidence := .resolve view }

def openExecuteTransport
    (view : OpenAgentState)
    (gap : OpenGap view)
    (use : OpenAuthorizedUse view gap) :
    OpenAuthorizedTransport view gap use := by
  cases gap with
  | mk index kind evidence =>
      cases evidence
      exact
        { reading := .freshIndex
          output :=
            { requestedIndex := view.candidate.values.length
              requestedIndex_eq := rfl
              unresolvedBefore := lookupBool_length view.candidate.values }
          evidence :=
            { direction_eq := by cases use.evidence; rfl
              reachesGap := rfl
              carriesFreshness := lookupBool_length view.candidate.values } }

def openSelectQuery
    {view : OpenAgentState}
    {gap : OpenGap view}
    {use : OpenAuthorizedUse view gap}
    (_transport : OpenAuthorizedTransport view gap use) :
    OpenQuery gap.index :=
  .reveal gap.index

def openSelectedQueryAdmissible
    {view : OpenAgentState}
    {gap : OpenGap view}
    {use : OpenAuthorizedUse view gap}
    (transport : OpenAuthorizedTransport view gap use) :
    OpenQueryAdmissible view gap use transport
      (openSelectQuery transport) :=
  .fresh

def openRespond
    (world : OpenWorld)
    {index : Nat}
  (query : OpenQuery index) : OpenResponse query := by
  cases query with
  | reveal => exact .revealed (world.valueAt index)

structure OpenResponseFootprint
    {index : Nat} (query : OpenQuery index) where
  requestedIndex : Nat
  requestedIndex_eq : requestedIndex = index
  maxResponseBits : Nat

def openResponseFootprint
    {index : Nat} (query : OpenQuery index) : OpenResponseFootprint query := by
  cases query with
  | reveal =>
      exact
        { requestedIndex := index
          requestedIndex_eq := rfl
          maxResponseBits := 1 }

def OpenWorldsAgreeOn
    {index : Nat}
    {query : OpenQuery index}
    (footprint : OpenResponseFootprint query)
    (left right : OpenWorld) : Prop :=
  left.valueAt footprint.requestedIndex =
    right.valueAt footprint.requestedIndex

def encodedOpenResponseBits
    {index : Nat}
    {query : OpenQuery index} (_response : OpenResponse query) : Nat := 1

theorem openRespond_local
    {index : Nat}
    (query : OpenQuery index)
    (left right : OpenWorld)
    (agree : OpenWorldsAgreeOn (openResponseFootprint query) left right) :
    openRespond left query = openRespond right query := by
  cases query with
  | reveal =>
      have atIndex : left.valueAt index = right.valueAt index := by
        rw [<-(openResponseFootprint (OpenQuery.reveal index)).requestedIndex_eq]
        exact agree
      exact congrArg OpenResponse.revealed atIndex

theorem openRespond_withinBound
    (world : OpenWorld)
    {index : Nat}
    (query : OpenQuery index) :
    encodedOpenResponseBits (openRespond world query) <=
      (openResponseFootprint query).maxResponseBits := by
  cases query
  change 1 <= 1
  exact Nat.le_refl 1

def openBuildRepair
    (view : OpenAgentState)
    (gap : OpenGap view)
    (use : OpenAuthorizedUse view gap)
    (transport : OpenAuthorizedTransport view gap use)
    (query : OpenQuery gap.index)
    (response : OpenResponse query) :
    IntrinsicRepair
      openData openGapLanguage openTransportLanguage openInteractionLanguage
  view gap use transport query response := by
  cases query with
  | reveal =>
      cases response with
      | revealed value =>
          exact
            { candidatePatch := { value := value }
              observationUpdate := .append view.observation gap.index value
              historyRecord := { index := gap.index, value := value }
              responseUsed := .derived view.observation gap.index value
              provenance :=
                { transportIndex_eq := transport.evidence.reachesGap
                  recordIndex_eq := rfl
                  patchValue_eq_record := rfl } }

def openCompatible
    (view : OpenAgentState)
    (world : OpenWorld) : Prop :=
  ∀ index value,
    lookupBool view.candidate.values index = some value ->
      world.valueAt index = value

theorem openCompatible_after_append
    (values : List Bool)
    (world : OpenWorld)
    (compatible :
      ∀ index value,
        lookupBool values index = some value -> world.valueAt index = value) :
    ∀ index value,
      lookupBool (values ++ [world.valueAt values.length]) index = some value ->
        world.valueAt index = value := by
  intro index value found
  cases lookupBool_append_cases
      values (world.valueAt values.length) index value found with
  | inl earlier => exact compatible index value earlier
  | inr fresh =>
      rw [fresh.1, fresh.2]

def openSystem :
    ActiveSemanticClosureSystem
      openData openGapLanguage openTransportLanguage openInteractionLanguage where
  initialCandidate := { values := [] }
  detectGap := fun view => .open (freshGap view)
  authorize := openAuthorize
  executeTransport := openExecuteTransport
  selectQuery := openSelectQuery
  selectedQueryAdmissible := openSelectedQueryAdmissible
  respond := fun world query => openRespond world query
  buildRepair := fun view gap use transport query response =>
    openBuildRepair view gap use transport query response
  CompatibleWithViewHistory := fun view world => openCompatible view world

def baselineWorld : OpenWorld :=
  { valueAt := fun _ => false }

def openInitialState : OpenClosedState :=
  openSystem.initialState baselineWorld

def openStateAt : Nat -> OpenClosedState
  | 0 => openInitialState
  | stage + 1 => openSystem.nextState (openStateAt stage)

theorem openSystem_detects_fresh (view : OpenAgentState) :
    openSystem.detectGap view = .open (freshGap view) :=
  rfl

theorem openSystem_next_candidate
    (state : OpenClosedState) :
    (openSystem.nextState state).agent.candidate.values =
      state.agent.candidate.values ++
        [state.world.valueAt state.agent.candidate.values.length] :=
  rfl

theorem openSystem_next_observation
    (state : OpenClosedState) :
    (openSystem.nextState state).agent.observation.answers =
      state.agent.observation.answers ++
        [state.world.valueAt state.agent.candidate.values.length] :=
  rfl

theorem openSystem_next_history
    (state : OpenClosedState) :
    (openSystem.nextState state).agent.history =
      state.agent.history ++
        [{ index := state.agent.candidate.values.length,
           value := state.world.valueAt state.agent.candidate.values.length }] :=
  rfl

theorem openSystem_next_length
    (state : OpenClosedState) :
    (openSystem.nextState state).agent.candidate.values.length =
      state.agent.candidate.values.length + 1 := by
  exact
    (congrArg List.length (openSystem_next_candidate state)).trans
      (length_append_singleton_bool
        state.agent.candidate.values
        (state.world.valueAt state.agent.candidate.values.length))

theorem openStateAt_world (stage : Nat) :
    (openStateAt stage).world = baselineWorld := by
  induction stage with
  | zero => rfl
  | succ stage inductionHypothesis =>
      exact (ActiveSemanticClosureSystem.nextState_world
        openSystem (openStateAt stage)).trans inductionHypothesis

theorem openStateAt_length (stage : Nat) :
    (openStateAt stage).agent.candidate.values.length = stage := by
  induction stage with
  | zero => rfl
  | succ stage inductionHypothesis =>
      exact
        (openSystem_next_length (openStateAt stage)).trans
          (congrArg Nat.succ inductionHypothesis)

def falsePrefix : Nat -> List Bool
  | 0 => []
  | stage + 1 => falsePrefix stage ++ [false]

theorem openStateAt_values (stage : Nat) :
    (openStateAt stage).agent.candidate.values = falsePrefix stage := by
  induction stage with
  | zero => rfl
  | succ stage inductionHypothesis =>
      change
        (openSystem.nextState (openStateAt stage)).agent.candidate.values =
          falsePrefix (stage + 1)
      rw [openSystem_next_candidate, openStateAt_world, inductionHypothesis]
      rfl

theorem openStateAt_injective
    {left right : Nat}
    (statesEqual : openStateAt left = openStateAt right) :
    left = right := by
  have lengthsEqual := congrArg
    (fun state => state.agent.candidate.values.length) statesEqual
  exact (openStateAt_length left).symm.trans
    (lengthsEqual.trans (openStateAt_length right))

theorem openStateAt_noReturn
    {left right : Nat}
    (stagesSeparated : left = right -> False)
    (statesEqual : openStateAt left = openStateAt right) : False :=
  stagesSeparated (openStateAt_injective statesEqual)

theorem openStateAt_freshIndex (stage : Nat) :
    (freshGap (openStateAt stage).agent).index = stage :=
  openStateAt_length stage

structure CandidatePrefix (before after : OpenCandidate) : Type where
  suffix : List Bool
  values_eq : after.values = before.values ++ suffix

def openSystem_next_preservesPrefix (state : OpenClosedState) :
    CandidatePrefix
      state.agent.candidate
      (openSystem.nextState state).agent.candidate := by
  exact
    { suffix := [state.world.valueAt state.agent.candidate.values.length]
      values_eq := openSystem_next_candidate state }

def candidatePrefix_trans
    {first second third : OpenCandidate}
    (firstSecond : CandidatePrefix first second)
    (secondThird : CandidatePrefix second third) :
    CandidatePrefix first third := by
  exact
    { suffix := firstSecond.suffix ++ secondThird.suffix
      values_eq :=
        secondThird.values_eq.trans
          ((congrArg
              (fun values => values ++ secondThird.suffix)
              firstSecond.values_eq).trans
            (appendBool_assoc
              first.values firstSecond.suffix secondThird.suffix)) }

def openOrbit_preservesPrefix (stage : Nat) :
    CandidatePrefix
      openInitialState.agent.candidate
      (openStateAt stage).agent.candidate := by
  induction stage with
  | zero =>
      exact { suffix := [], values_eq := rfl }
  | succ stage inductionHypothesis =>
      exact candidatePrefix_trans inductionHypothesis
        (openSystem_next_preservesPrefix (openStateAt stage))

structure RepairedPrefixKnown (view : OpenAgentState) : Prop where
  knownEntry :
    ∀ index value,
      lookupBool view.candidate.values index = some value ->
        KnownCorrectAt openSystem view view.candidate index

def repairedPrefixKnown (view : OpenAgentState) : RepairedPrefixKnown view where
  knownEntry := by
    intro index value found world compatible
    change
      lookupBool view.candidate.values index = some (world.valueAt index)
    exact found.trans (congrArg some (compatible index value found).symm)

def openStateAt_repairedPrefixKnown (stage : Nat) :
    RepairedPrefixKnown (openStateAt stage).agent :=
  repairedPrefixKnown (openStateAt stage).agent

theorem openRepair_preservesKnownPrefix
    (stage index : Nat)
    (value : Bool)
    (knownBefore :
      lookupBool (openStateAt stage).agent.candidate.values index = some value) :
    lookupBool
        (openStateAt (stage + 1)).agent.candidate.values index = some value ∧
      KnownCorrectAt openSystem
        (openStateAt (stage + 1)).agent
        (openStateAt (stage + 1)).agent.candidate index := by
  have retained :
      lookupBool
          ((openStateAt stage).agent.candidate.values ++
            [(openStateAt stage).world.valueAt
              (openStateAt stage).agent.candidate.values.length])
          index = some value :=
    lookupBool_append_existing knownBefore
      ((openStateAt stage).world.valueAt
        (openStateAt stage).agent.candidate.values.length)
  have retainedInNext :
      lookupBool (openStateAt (stage + 1)).agent.candidate.values index =
        some value :=
    (congrArg
        (fun values => lookupBool values index)
        (openSystem_next_candidate (openStateAt stage))).trans retained
  exact
    ⟨retainedInNext,
      (openStateAt_repairedPrefixKnown (stage + 1)).knownEntry
        index value retainedInNext⟩

theorem openOrbit_hasFreshGap (stage : Nat) :
    openSystem.detectGap (openStateAt stage).agent =
      .open (freshGap (openStateAt stage).agent) :=
  rfl

theorem openOrbit_notGloballyClosed (stage : Nat) :
    GloballyClosed openData
        (openStateAt stage).world (openStateAt stage).agent.candidate ->
      False := by
  intro globallyClosed
  have freshCorrect := globallyClosed
    (openStateAt stage).agent.candidate.values.length
  change
    openAgrees
      (openInterpret (openStateAt stage).agent.candidate
        (openStateAt stage).agent.candidate.values.length)
      (openEvaluate (openStateAt stage).world
        (openStateAt stage).agent.candidate.values.length) at freshCorrect
  unfold openAgrees openInterpret at freshCorrect
  rw [lookupBool_length] at freshCorrect
  cases freshCorrect

theorem openOrbit_transitionEffective (stage : Nat) :
    openSystem.nextState (openStateAt stage) = openStateAt stage -> False := by
  intro equality
  have lengthEquality := congrArg
    (fun state => state.agent.candidate.values.length) equality
  have impossible : Nat.succ stage = stage :=
    (congrArg Nat.succ (openStateAt_length stage)).symm.trans
      ((openSystem_next_length (openStateAt stage)).symm.trans
        (lengthEquality.trans (openStateAt_length stage)))
  exact Nat.succ_ne_self stage impossible

def completionCompatible
    (candidate : OpenCandidate)
    (freshValue : Bool) :
    openCompatible
      { candidate := candidate,
        observation := { answers := [] },
        history := [] }
      (completionWorld candidate freshValue) := by
  intro index value found
  unfold completionWorld
  change
    (match lookupBool candidate.values index with
      | some foundValue => foundValue
      | none => if index = candidate.values.length then freshValue else false) = value
  rw [found]

theorem completionWorlds_separatedAtFresh (candidate : OpenCandidate) :
    openEvaluate (completionWorld candidate false) candidate.values.length =
        openEvaluate (completionWorld candidate true) candidate.values.length ->
      False := by
  intro equality
  change
    (match lookupBool candidate.values candidate.values.length with
      | some value => value
      | none => if candidate.values.length = candidate.values.length then false else false) =
    (match lookupBool candidate.values candidate.values.length with
      | some value => value
      | none => if candidate.values.length = candidate.values.length then true else false)
      at equality
  rw [lookupBool_length, if_pos rfl, if_pos rfl] at equality
  cases equality

structure OpenFiberEvidenceCertificate
    (state : OpenClosedState)
    (gap : OpenGap state.agent)
    (kindEq : gap.kind = .unresolvedFiber)
    (leftWorld rightWorld : OpenWorld)
    (leftCompatible : openCompatible state.agent leftWorld)
    (rightCompatible : openCompatible state.agent rightWorld)
    (targetsSeparated :
      openEvaluate leftWorld gap.index = openEvaluate rightWorld gap.index -> False) : Type where
  observedFresh : gap.index = state.agent.candidate.values.length
  leftStillCompatible : openCompatible state.agent leftWorld
  rightStillCompatible : openCompatible state.agent rightWorld
  semanticSeparation :
    openEvaluate leftWorld gap.index = openEvaluate rightWorld gap.index -> False

structure OpenWitnessedEvidenceCertificate
    (state : OpenClosedState)
    (gap : OpenGap state.agent)
    (kindEq : gap.kind = .witnessedMismatch)
    (disagrees :
      openAgrees
        (openInterpret state.agent.candidate gap.index)
        (openEvaluate state.world gap.index) -> False) : Type where
  disagreementCertificate :
    openAgrees
      (openInterpret state.agent.candidate gap.index)
      (openEvaluate state.world gap.index) -> False

def openEvidenceRealization : GapEvidenceRealization openSystem where
  WitnessedEvidenceRealization := OpenWitnessedEvidenceCertificate
  FiberEvidenceRealization := OpenFiberEvidenceCertificate

def completionCompatibleWithView
    (view : OpenAgentState)
    (freshValue : Bool) : openCompatible view (completionWorld view.candidate freshValue) := by
  intro index value found
  exact completionCompatible view.candidate freshValue index value found

def openFreshSemanticEvidence
    (state : OpenClosedState) :
    SemanticGapEvidence
      openSystem openEvidenceRealization state (freshGap state.agent) := by
  let leftWorld := completionWorld state.agent.candidate false
  let rightWorld := completionWorld state.agent.candidate true
  refine .unresolvedFiber rfl leftWorld rightWorld
    (completionCompatibleWithView state.agent false)
    (completionCompatibleWithView state.agent true) ?_ ?_
  · exact completionWorlds_separatedAtFresh state.agent.candidate
  · exact
      { observedFresh := rfl
        leftStillCompatible := completionCompatibleWithView state.agent false
        rightStillCompatible := completionCompatibleWithView state.agent true
        semanticSeparation := completionWorlds_separatedAtFresh state.agent.candidate }

def openActualCompatible (state : OpenClosedState)
    (compatible : openCompatible state.agent state.world) :
    openCompatible (openSystem.nextState state).agent
      (openSystem.nextState state).world := by
  rw [ActiveSemanticClosureSystem.nextState_world]
  exact openCompatible_after_append
    state.agent.candidate.values state.world compatible

def openInitialActualCompatible (world : OpenWorld) :
    openCompatible (openSystem.initialState world).agent world := by
  intro index value found
  change lookupBool [] index = some value at found
  cases index <;> cases found

def lawfulOpenSystem : LawfulActiveSemanticClosureSystem openSystem where
  evidenceRealization := openEvidenceRealization
  initialActualCompatible := openInitialActualCompatible
  validatesOpenGap := by
    intro state gap detected
    cases gap with
    | mk index kind evidence =>
        cases evidence
        exact openFreshSemanticEvidence state
  nextPreservesActualCompatibility := openActualCompatible

def openStateAt_actualCompatible (stage : Nat) :
    openCompatible (openStateAt stage).agent (openStateAt stage).world := by
  induction stage with
  | zero => exact openInitialActualCompatible baselineWorld
  | succ stage inductionHypothesis =>
      exact openActualCompatible (openStateAt stage) inductionHypothesis

def openStateAt_reachable (stage : Nat) :
    ReachableFromInitial openSystem baselineWorld (openStateAt stage) := by
  induction stage with
  | zero => exact .initial
  | succ stage inductionHypothesis => exact .next inductionHypothesis

theorem openStateAt_actualCompatible_fromReachability (stage : Nat) :
    ActualWorldCompatible openSystem (openStateAt stage) :=
  reachable_actualCompatible lawfulOpenSystem (openStateAt_reachable stage)

def openTypedGapAt (stage : Nat) :
    TypedSemanticGap
      openSystem openEvidenceRealization
      (openStateAt stage) (freshGap (openStateAt stage).agent) :=
  typedSemanticGapOfEvidence
    (openStateAt_actualCompatible stage)
    (openFreshSemanticEvidence (openStateAt stage))

def openGapClosedByNext (stage : Nat) :
    GapClosedBy
      openSystem
      (openStateAt stage)
      (freshGap (openStateAt stage).agent)
      (openSystem.nextState (openStateAt stage)) where
  worldPreserved := ActiveSemanticClosureSystem.nextState_world
    openSystem (openStateAt stage)
  actualCompatible :=
    openActualCompatible
      (openStateAt stage)
      (openStateAt_actualCompatible stage)
  knownCorrect := by
    intro world compatible
    let sourceValues := (openStateAt stage).agent.candidate.values
    let sourceIndex := sourceValues.length
    let learnedValue := (openStateAt stage).world.valueAt sourceIndex
    have nextCandidateEq :
        (openSystem.nextState (openStateAt stage)).agent.candidate.values =
          sourceValues ++ [learnedValue] :=
      openSystem_next_candidate (openStateAt stage)
    have learnedLookup :
        lookupBool
            (openSystem.nextState (openStateAt stage)).agent.candidate.values
            sourceIndex =
          some learnedValue :=
      (congrArg
          (fun values => lookupBool values sourceIndex)
          nextCandidateEq).trans
        (lookupBool_append_new sourceValues learnedValue)
    have worldLearns : world.valueAt sourceIndex = learnedValue :=
      compatible sourceIndex learnedValue learnedLookup
    change
      openAgrees
        (openInterpret
          (openSystem.nextState (openStateAt stage)).agent.candidate
          sourceIndex)
        (openEvaluate world sourceIndex)
    unfold openAgrees openInterpret openEvaluate
    exact learnedLookup.trans (congrArg some worldLearns.symm)

def openProjectionObstruction (stage : Nat) :
    ClosedStabilityTheorem.ProjectionObstruction
      (ClosureInterface openData)
      Nat
      ClosureInterface.project :=
  let typed := openTypedGapAt stage
  { left := typed.leftPole
    right := typed.rightPole
    sameProjection := typed.leftProjects.trans typed.rightProjects.symm
    separatedInterface := typed.separated }

def openNoProjectiveReconstruction (stage : Nat) :
    ((recover : Nat -> ClosureInterface openData) ->
      ((interface : ClosureInterface openData) ->
        recover (ClosureInterface.project interface) = interface) -> False) :=
  ClosedStabilityTheorem.noProjectiveReconstruction
    (openProjectionObstruction stage)

structure AIOpenOrbitCertificate where
  stateAt : Nat -> OpenClosedState
  stateAt_eq : stateAt = openStateAt
  reachable :
    ∀ stage,
      ReachableFromInitial openSystem baselineWorld (stateAt stage)
  actualCompatibleFromReachability :
    ∀ stage, ActualWorldCompatible openSystem (stateAt stage)
  freshGapAt : (stage : Nat) -> OpenGap (stateAt stage).agent
  freshGapAt_eq : ∀ stage, freshGapAt stage = freshGap (stateAt stage).agent
  detectedFresh :
    ∀ stage, openSystem.detectGap (stateAt stage).agent = .open (freshGapAt stage)
  typedFresh :
    ∀ stage,
      TypedSemanticGap openSystem openEvidenceRealization
        (stateAt stage) (freshGapAt stage)
  responseFootprint :
    {index : Nat} -> (query : OpenQuery index) -> OpenResponseFootprint query
  responseFootprint_eq :
    ∀ {index} (query : OpenQuery index),
      responseFootprint query = openResponseFootprint query
  responseLocality :
    ∀ {index} (query : OpenQuery index) left right,
      OpenWorldsAgreeOn (responseFootprint query) left right ->
      openRespond left query = openRespond right query
  responseBounded :
    ∀ world {index} (query : OpenQuery index),
      encodedOpenResponseBits (openRespond world query) <=
        (responseFootprint query).maxResponseBits
  next_eq : ∀ stage, stateAt (stage + 1) = openSystem.nextState (stateAt stage)
  prefixPreserved :
    ∀ stage, CandidatePrefix openInitialState.agent.candidate
      (stateAt stage).agent.candidate
  exactCandidateShape :
    ∀ stage, (stateAt stage).agent.candidate.values = falsePrefix stage
  repairedPrefixKnown :
    ∀ stage, RepairedPrefixKnown (stateAt stage).agent
  repairsPreserveKnownEntries :
    ∀ stage index value,
      lookupBool (stateAt stage).agent.candidate.values index = some value ->
      lookupBool (stateAt (stage + 1)).agent.candidate.values index = some value ∧
        KnownCorrectAt openSystem
          (stateAt (stage + 1)).agent
          (stateAt (stage + 1)).agent.candidate index
  freshIndex_eq : ∀ stage, (freshGapAt stage).index = stage
  transitionEffective :
    ∀ stage, openSystem.nextState (stateAt stage) = stateAt stage -> False
  neverGloballyClosed :
    ∀ stage,
      GloballyClosed openData (stateAt stage).world (stateAt stage).agent.candidate ->
        False
  actualCompatible :
    ∀ stage, openCompatible (stateAt stage).agent (stateAt stage).world
  closesCurrentGap :
    ∀ stage,
      GapClosedBy openSystem (stateAt stage) (freshGapAt stage)
        (openSystem.nextState (stateAt stage))
  projectiveObstruction :
    ∀ _stage : Nat,
      ClosedStabilityTheorem.ProjectionObstruction
        (ClosureInterface openData) Nat ClosureInterface.project
  noProjectiveReconstruction :
    ∀ _stage : Nat,
      (recover : Nat -> ClosureInterface openData) ->
      ((interface : ClosureInterface openData) ->
        recover (ClosureInterface.project interface) = interface) -> False
  stateAtInjective :
    ∀ {left right}, stateAt left = stateAt right -> left = right
  noExactReturn :
    ∀ {left right},
      (left = right -> False) -> stateAt left = stateAt right -> False

def aiOpenOrbitCertificate : AIOpenOrbitCertificate where
  stateAt := openStateAt
  stateAt_eq := rfl
  reachable := openStateAt_reachable
  actualCompatibleFromReachability :=
    openStateAt_actualCompatible_fromReachability
  freshGapAt := fun stage => freshGap (openStateAt stage).agent
  freshGapAt_eq := by intro stage; rfl
  detectedFresh := openOrbit_hasFreshGap
  typedFresh := openTypedGapAt
  responseFootprint := openResponseFootprint
  responseFootprint_eq := by intros; rfl
  responseLocality := openRespond_local
  responseBounded := openRespond_withinBound
  next_eq := by intro stage; rfl
  prefixPreserved := openOrbit_preservesPrefix
  exactCandidateShape := openStateAt_values
  repairedPrefixKnown := openStateAt_repairedPrefixKnown
  repairsPreserveKnownEntries := openRepair_preservesKnownPrefix
  freshIndex_eq := openStateAt_freshIndex
  transitionEffective := openOrbit_transitionEffective
  neverGloballyClosed := openOrbit_notGloballyClosed
  actualCompatible := openStateAt_actualCompatible
  closesCurrentGap := openGapClosedByNext
  projectiveObstruction := openProjectionObstruction
  noProjectiveReconstruction := openNoProjectiveReconstruction
  stateAtInjective := openStateAt_injective
  noExactReturn := openStateAt_noReturn

end Open
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.Open.openSystem
#print axioms Meta.ActiveSemanticClosure.Open.lawfulOpenSystem
#print axioms Meta.ActiveSemanticClosure.Open.openOrbit_preservesPrefix
#print axioms Meta.ActiveSemanticClosure.Open.openStateAt_values
#print axioms Meta.ActiveSemanticClosure.Open.openRepair_preservesKnownPrefix
#print axioms Meta.ActiveSemanticClosure.Open.openStateAt_noReturn
#print axioms Meta.ActiveSemanticClosure.Open.openOrbit_hasFreshGap
#print axioms Meta.ActiveSemanticClosure.Open.openOrbit_notGloballyClosed
#print axioms Meta.ActiveSemanticClosure.Open.openTypedGapAt
#print axioms Meta.ActiveSemanticClosure.Open.openGapClosedByNext
#print axioms Meta.ActiveSemanticClosure.Open.openProjectionObstruction
#print axioms Meta.ActiveSemanticClosure.Open.openNoProjectiveReconstruction
#print axioms Meta.ActiveSemanticClosure.Open.openStateAt_freshIndex
#print axioms Meta.ActiveSemanticClosure.Open.openOrbit_transitionEffective
#print axioms Meta.ActiveSemanticClosure.Open.openStateAt_actualCompatible
#print axioms Meta.ActiveSemanticClosure.Open.openStateAt_actualCompatible_fromReachability
#print axioms Meta.ActiveSemanticClosure.Open.openRespond_local
#print axioms Meta.ActiveSemanticClosure.Open.openRespond_withinBound
#print axioms Meta.ActiveSemanticClosure.Open.aiOpenOrbitCertificate
/- AXIOM_AUDIT_END -/
