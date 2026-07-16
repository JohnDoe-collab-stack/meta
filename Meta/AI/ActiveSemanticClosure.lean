import Meta.Core.StrictRelaxation
import Meta.Core.TransportCoherence

/-!
# Active semantic closure

This module defines the executable causal kernel of active semantic closure.
The semantic world is kept outside the agent view.  An open operational gap
produces an authorized use, an explicit transport, a query, an environmental
response, and an intrinsic repair.  The next state is definitionally the
execution of that repair.
-/

namespace Meta
namespace ActiveSemanticClosure

universe u v

/-- Operational gaps distinguish observed disagreement from unresolved fibers. -/
inductive OperationalGapKind where
  | witnessedMismatch
  | unresolvedFiber
  deriving DecidableEq

/-- Domain data shared by every active-closure implementation. -/
structure ActiveClosureData where
  SemanticWorld : Type u
  Candidate : Type u
  Observation : Type u
  RepairRecord : Type u
  VisibleIndex : Type u
  Prediction : Type u
  Target : Type u
  CandidatePatch : Type u
  interpret : Candidate -> VisibleIndex -> Prediction
  evaluate : SemanticWorld -> VisibleIndex -> Target
  Agrees : Prediction -> Target -> Prop
  agrees_target_unique :
    (prediction : Prediction) ->
    (leftTarget rightTarget : Target) ->
    Agrees prediction leftTarget ->
    Agrees prediction rightTarget ->
    leftTarget = rightTarget
  observe : SemanticWorld -> Observation
  applyCandidatePatch : Candidate -> CandidatePatch -> Candidate

/-- The entire state accessible to the agent. -/
structure AgentClosureState (D : ActiveClosureData.{u}) where
  candidate : D.Candidate
  observation : D.Observation
  history : List D.RepairRecord

/-- The closed state keeps the semantic world outside the agent view. -/
structure ActiveSemanticClosureState (D : ActiveClosureData.{u}) where
  world : D.SemanticWorld
  agent : AgentClosureState D

/-- Semantic and syntactic poles are internally distinct by construction. -/
inductive ClosureInterface (D : ActiveClosureData.{u}) where
  | semantic (world : D.SemanticWorld) (index : D.VisibleIndex)
  | syntactic (candidate : D.Candidate) (index : D.VisibleIndex)

/-- Both interface constructors expose only their common visible index. -/
def ClosureInterface.project
    {D : ActiveClosureData.{u}} :
    ClosureInterface D -> D.VisibleIndex
  | .semantic _ index => index
  | .syntactic _ index => index

/-- Operational evidence, uses, and their provenance. -/
structure ActiveClosureGapLanguage (D : ActiveClosureData.{u}) where
  GapEvidence :
    (view : AgentClosureState D) ->
    D.VisibleIndex ->
    OperationalGapKind ->
    Type v
  UseDirection : Type u
  UseEvidence :
    (view : AgentClosureState D) ->
    (index : D.VisibleIndex) ->
    (kind : OperationalGapKind) ->
    GapEvidence view index kind ->
    UseDirection ->
    Type v

/-- A gap available to the agent contains no world, query, or expected answer. -/
structure OperationalGap
    (D : ActiveClosureData.{u})
    (G : ActiveClosureGapLanguage.{u, v} D)
    (view : AgentClosureState D) where
  index : D.VisibleIndex
  kind : OperationalGapKind
  observableEvidence : G.GapEvidence view index kind

/-- Gap detection either certifies stasis or returns a typed open gap. -/
inductive OperationalGapStatus
    (D : ActiveClosureData.{u})
    (G : ActiveClosureGapLanguage.{u, v} D)
    (view : AgentClosureState D) where
  | closed
  | open (gap : OperationalGap D G view)

/-- An authorized use remains indexed by the exact view and gap that produced it. -/
structure GapAuthorizedUse
    (D : ActiveClosureData.{u})
    (G : ActiveClosureGapLanguage.{u, v} D)
    (view : AgentClosureState D)
    (gap : OperationalGap D G view) where
  direction : G.UseDirection
  evidence :
    G.UseEvidence
      view gap.index gap.kind gap.observableEvidence direction

/-- Proof-relevant transport data, kept distinct from use and query. -/
structure ActiveClosureTransportLanguage
    (D : ActiveClosureData.{u})
    (G : ActiveClosureGapLanguage.{u, v} D) where
  AuthorizedReading :
    (view : AgentClosureState D) ->
    (gap : OperationalGap D G view) ->
    GapAuthorizedUse D G view gap ->
    Type u
  TransportOutput :
    (view : AgentClosureState D) ->
    (gap : OperationalGap D G view) ->
    (use : GapAuthorizedUse D G view gap) ->
    AuthorizedReading view gap use ->
    Type u
  TransportEvidence :
    (view : AgentClosureState D) ->
    (gap : OperationalGap D G view) ->
    (use : GapAuthorizedUse D G view gap) ->
    (reading : AuthorizedReading view gap use) ->
    TransportOutput view gap use reading ->
    Type v

/-- Execution of an authorized use exposes a reading and an output relation. -/
structure GapAuthorizedTransport
    (D : ActiveClosureData.{u})
    (G : ActiveClosureGapLanguage.{u, v} D)
    (T : ActiveClosureTransportLanguage.{u, v} D G)
    (view : AgentClosureState D)
    (gap : OperationalGap D G view)
    (use : GapAuthorizedUse D G view gap) where
  reading : T.AuthorizedReading view gap use
  output : T.TransportOutput view gap use reading
  evidence : T.TransportEvidence view gap use reading output

/-- Interaction and repair families attached to the causal kernel. -/
structure ActiveClosureInteractionLanguage
    (D : ActiveClosureData.{u})
    (G : ActiveClosureGapLanguage.{u, v} D)
    (T : ActiveClosureTransportLanguage.{u, v} D G) where
  Query : D.VisibleIndex -> Type u
  Response : {index : D.VisibleIndex} -> Query index -> Type u
  QueryAdmissible :
    (view : AgentClosureState D) ->
    (gap : OperationalGap D G view) ->
    (use : GapAuthorizedUse D G view gap) ->
    GapAuthorizedTransport D G T view gap use ->
    Query gap.index ->
    Type v
  ObservationUpdate :
    (observation : D.Observation) ->
    {index : D.VisibleIndex} ->
    (query : Query index) ->
    Response query ->
    Type u
  applyObservationUpdate :
    {observation : D.Observation} ->
    {index : D.VisibleIndex} ->
    {query : Query index} ->
    {response : Response query} ->
    ObservationUpdate observation query response ->
    D.Observation
  RepairDerivedFrom :
    {index : D.VisibleIndex} ->
    {query : Query index} ->
    (response : Response query) ->
    (patch : D.CandidatePatch) ->
    ObservationUpdate observation query response ->
    D.RepairRecord ->
    Type v
  RepairProvenance :
    (view : AgentClosureState D) ->
    (gap : OperationalGap D G view) ->
    (use : GapAuthorizedUse D G view gap) ->
    (transport : GapAuthorizedTransport D G T view gap use) ->
    (query : Query gap.index) ->
    (response : Response query) ->
    (patch : D.CandidatePatch) ->
    (update : ObservationUpdate view.observation query response) ->
    D.RepairRecord ->
    Type v

/-- A repair is a replayable agent-side program with complete causal provenance. -/
structure IntrinsicRepair
    (D : ActiveClosureData.{u})
    (G : ActiveClosureGapLanguage.{u, v} D)
    (T : ActiveClosureTransportLanguage.{u, v} D G)
    (I : ActiveClosureInteractionLanguage.{u, v} D G T)
    (view : AgentClosureState D)
    (gap : OperationalGap D G view)
    (use : GapAuthorizedUse D G view gap)
    (transport : GapAuthorizedTransport D G T view gap use)
    (query : I.Query gap.index)
    (response : I.Response query) where
  candidatePatch : D.CandidatePatch
  observationUpdate : I.ObservationUpdate view.observation query response
  historyRecord : D.RepairRecord
  responseUsed :
    I.RepairDerivedFrom
      response candidatePatch observationUpdate historyRecord
  provenance :
    I.RepairProvenance
      view gap use transport query response
      candidatePatch observationUpdate historyRecord

/-- Executable operations.  No independent successor is supplied. -/
structure ActiveSemanticClosureSystem
    (D : ActiveClosureData.{u})
    (G : ActiveClosureGapLanguage.{u, v} D)
    (T : ActiveClosureTransportLanguage.{u, v} D G)
    (I : ActiveClosureInteractionLanguage.{u, v} D G T) where
  initialCandidate : D.Candidate
  detectGap :
    (view : AgentClosureState D) ->
    OperationalGapStatus D G view
  authorize :
    (view : AgentClosureState D) ->
    (gap : OperationalGap D G view) ->
    GapAuthorizedUse D G view gap
  executeTransport :
    (view : AgentClosureState D) ->
    (gap : OperationalGap D G view) ->
    (use : GapAuthorizedUse D G view gap) ->
    GapAuthorizedTransport D G T view gap use
  selectQuery :
    {view : AgentClosureState D} ->
    {gap : OperationalGap D G view} ->
    {use : GapAuthorizedUse D G view gap} ->
    GapAuthorizedTransport D G T view gap use ->
    I.Query gap.index
  selectedQueryAdmissible :
    {view : AgentClosureState D} ->
    {gap : OperationalGap D G view} ->
    {use : GapAuthorizedUse D G view gap} ->
    (transport : GapAuthorizedTransport D G T view gap use) ->
    I.QueryAdmissible view gap use transport (selectQuery transport)
  respond :
    (world : D.SemanticWorld) ->
    (query : I.Query index) ->
    I.Response query
  buildRepair :
    (view : AgentClosureState D) ->
    (gap : OperationalGap D G view) ->
    (use : GapAuthorizedUse D G view gap) ->
    (transport : GapAuthorizedTransport D G T view gap use) ->
    (query : I.Query gap.index) ->
    (response : I.Response query) ->
    IntrinsicRepair D G T I view gap use transport query response
  CompatibleWithViewHistory :
    AgentClosureState D -> D.SemanticWorld -> Prop

namespace ActiveSemanticClosureSystem

variable
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}

/-- Canonical initial state with no fabricated history. -/
def initialState
    (system : ActiveSemanticClosureSystem D G T I)
    (world : D.SemanticWorld) :
    ActiveSemanticClosureState D where
  world := world
  agent :=
    { candidate := system.initialCandidate
      observation := D.observe world
      history := [] }

/-- Agent-side execution is determined by the repair fields. -/
def executeAgentRepair
    (view : AgentClosureState D)
    {gap : OperationalGap D G view}
    {use : GapAuthorizedUse D G view gap}
    {transport : GapAuthorizedTransport D G T view gap use}
    {query : I.Query gap.index}
    {response : I.Response query}
    (repair : IntrinsicRepair D G T I view gap use transport query response) :
    AgentClosureState D where
  candidate := D.applyCandidatePatch view.candidate repair.candidatePatch
  observation := I.applyObservationUpdate repair.observationUpdate
  history := view.history ++ [repair.historyRecord]

/-- Closed execution preserves the world and changes only the agent view. -/
def executeRepair
    (state : ActiveSemanticClosureState D)
    {gap : OperationalGap D G state.agent}
    {use : GapAuthorizedUse D G state.agent gap}
    {transport : GapAuthorizedTransport D G T state.agent gap use}
    {query : I.Query gap.index}
    {response : I.Response query}
    (repair :
      IntrinsicRepair D G T I
        state.agent gap use transport query response) :
    ActiveSemanticClosureState D where
  world := state.world
  agent := executeAgentRepair state.agent repair

/-- The unique natural transition follows the complete causal chain. -/
def nextState
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D) :
    ActiveSemanticClosureState D :=
  match system.detectGap state.agent with
  | .closed => state
  | .open gap =>
      let use := system.authorize state.agent gap
      let transport := system.executeTransport state.agent gap use
      let query := system.selectQuery transport
      let response := system.respond state.world query
      let repair :=
        system.buildRepair
          state.agent gap use transport query response
      executeRepair state repair

/-- Repair execution never changes the semantic world. -/
theorem executeRepair_world
    (state : ActiveSemanticClosureState D)
    {gap : OperationalGap D G state.agent}
    {use : GapAuthorizedUse D G state.agent gap}
    {transport : GapAuthorizedTransport D G T state.agent gap use}
    {query : I.Query gap.index}
    {response : I.Response query}
    (repair :
      IntrinsicRepair D G T I
        state.agent gap use transport query response) :
    (executeRepair state repair).world = state.world :=
  rfl

/-- A closed detector status makes the canonical transition definitionally stable. -/
theorem nextState_eq_self_of_closed
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D)
    (closed : system.detectGap state.agent = .closed) :
    system.nextState state = state := by
  rw [nextState, closed]

/-- For an open gap, the successor is exactly the repair built by the causal chain. -/
theorem nextState_eq_executeRepair_of_open
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D)
    (gap : OperationalGap D G state.agent)
    (detected : system.detectGap state.agent = .open gap) :
    system.nextState state =
      let use := system.authorize state.agent gap
      let transport := system.executeTransport state.agent gap use
      let query := system.selectQuery transport
      let response := system.respond state.world query
      let repair :=
        system.buildRepair
          state.agent gap use transport query response
      executeRepair state repair := by
  rw [nextState, detected]

/-- Every canonical transition preserves the semantic world. -/
theorem nextState_world
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D) :
    (system.nextState state).world = state.world := by
  unfold nextState
  cases system.detectGap state.agent <;> rfl

end ActiveSemanticClosureSystem

/-- Pointwise semantic correctness of a candidate. -/
def CorrectAt
    (D : ActiveClosureData.{u})
    (world : D.SemanticWorld)
    (candidate : D.Candidate)
    (index : D.VisibleIndex) : Prop :=
  D.Agrees (D.interpret candidate index) (D.evaluate world index)

/-- Correctness on an explicitly supplied finite domain. -/
def ClosedOn
    (D : ActiveClosureData.{u})
    (world : D.SemanticWorld)
    (candidate : D.Candidate)
    (domain : List D.VisibleIndex) : Prop :=
  ∀ index, index ∈ domain -> CorrectAt D world candidate index

/-- Pointwise correctness over the whole visible index type. -/
def GloballyClosed
    (D : ActiveClosureData.{u})
    (world : D.SemanticWorld)
    (candidate : D.Candidate) : Prop :=
  ∀ index, CorrectAt D world candidate index

/-- Epistemic correctness over every world compatible with the agent view. -/
def KnownCorrectAt
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I)
    (view : AgentClosureState D)
    (candidate : D.Candidate)
    (index : D.VisibleIndex) : Prop :=
  ∀ world,
    system.CompatibleWithViewHistory view world ->
    CorrectAt D world candidate index

/-- Epistemic correctness on a finite visible domain. -/
def KnownClosedOn
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I)
    (view : AgentClosureState D)
    (candidate : D.Candidate)
    (domain : List D.VisibleIndex) : Prop :=
  ∀ index,
    index ∈ domain -> KnownCorrectAt system view candidate index

/-- The current compatible fiber determines one target at an index. -/
def FiberDeterminateAt
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I)
    (view : AgentClosureState D)
    (index : D.VisibleIndex) : Prop :=
  ∀ leftWorld rightWorld,
    system.CompatibleWithViewHistory view leftWorld ->
    system.CompatibleWithViewHistory view rightWorld ->
    D.evaluate leftWorld index = D.evaluate rightWorld index

/-- Epistemic correctness implies correctness in the actual compatible world. -/
theorem correctAt_of_knownCorrectAt
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    {view : AgentClosureState D}
    {candidate : D.Candidate}
    {index : D.VisibleIndex}
    {world : D.SemanticWorld}
    (known : KnownCorrectAt system view candidate index)
    (actualCompatible :
      system.CompatibleWithViewHistory view world) :
    CorrectAt D world candidate index :=
  known world actualCompatible

/-- A unique target relation turns known correctness into fiber determinacy. -/
theorem fiberDeterminateAt_of_knownCorrectAt
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    {view : AgentClosureState D}
    {candidate : D.Candidate}
    {index : D.VisibleIndex}
    (known : KnownCorrectAt system view candidate index) :
    FiberDeterminateAt system view index := by
  intro leftWorld rightWorld leftCompatible rightCompatible
  exact D.agrees_target_unique
    (D.interpret candidate index)
    (D.evaluate leftWorld index)
    (D.evaluate rightWorld index)
    (known leftWorld leftCompatible)
    (known rightWorld rightCompatible)

/-- A transition closes a gap only through world preservation and known correctness. -/
structure GapClosedBy
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I)
    (before : ActiveSemanticClosureState D)
    (gap : OperationalGap D G before.agent)
    (after : ActiveSemanticClosureState D) : Prop where
  worldPreserved : after.world = before.world
  actualCompatible :
    system.CompatibleWithViewHistory after.agent after.world
  knownCorrect :
    KnownCorrectAt system after.agent after.agent.candidate gap.index

/-- Realization families tying observable evidence to semantic evidence. -/
structure GapEvidenceRealization
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I) where
  WitnessedEvidenceRealization :
    (state : ActiveSemanticClosureState D) ->
    (gap : OperationalGap D G state.agent) ->
    (kindEq : gap.kind = .witnessedMismatch) ->
    (disagrees :
      D.Agrees
        (D.interpret state.agent.candidate gap.index)
        (D.evaluate state.world gap.index) -> False) ->
    Type v
  FiberEvidenceRealization :
    (state : ActiveSemanticClosureState D) ->
    (gap : OperationalGap D G state.agent) ->
    (kindEq : gap.kind = .unresolvedFiber) ->
    (leftWorld rightWorld : D.SemanticWorld) ->
    system.CompatibleWithViewHistory state.agent leftWorld ->
    system.CompatibleWithViewHistory state.agent rightWorld ->
    (D.evaluate leftWorld gap.index =
      D.evaluate rightWorld gap.index -> False) ->
    Type v

/-- Constructive semantic validation of the exact operational evidence. -/
inductive SemanticGapEvidence
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I)
    (realization : GapEvidenceRealization system)
    (state : ActiveSemanticClosureState D)
    (gap : OperationalGap D G state.agent) where
  | witnessedMismatch
      (kindEq : gap.kind = .witnessedMismatch)
      (disagrees :
        D.Agrees
          (D.interpret state.agent.candidate gap.index)
          (D.evaluate state.world gap.index) -> False)
      (observableEvidenceRealization :
        realization.WitnessedEvidenceRealization
          state gap kindEq disagrees)
  | unresolvedFiber
      (kindEq : gap.kind = .unresolvedFiber)
      (leftWorld rightWorld : D.SemanticWorld)
      (leftCompatible :
        system.CompatibleWithViewHistory state.agent leftWorld)
      (rightCompatible :
        system.CompatibleWithViewHistory state.agent rightWorld)
      (targetsSeparated :
        D.evaluate leftWorld gap.index =
          D.evaluate rightWorld gap.index -> False)
      (observableEvidenceRealization :
        realization.FiberEvidenceRealization
          state gap kindEq leftWorld rightWorld
          leftCompatible rightCompatible targetsSeparated)

/-- The expected left pole is determined by the semantic evidence kind. -/
def SemanticGapEvidence.expectedLeftPole
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    {realization : GapEvidenceRealization system}
    {state : ActiveSemanticClosureState D}
    {gap : OperationalGap D G state.agent}
    (evidence : SemanticGapEvidence system realization state gap) :
    ClosureInterface D :=
  match evidence with
  | .witnessedMismatch _ _ _ => .semantic state.world gap.index
  | .unresolvedFiber _ leftWorld _ _ _ _ _ =>
      .semantic leftWorld gap.index

/-- The expected right pole is determined by the semantic evidence kind. -/
def SemanticGapEvidence.expectedRightPole
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    {realization : GapEvidenceRealization system}
    {state : ActiveSemanticClosureState D}
    {gap : OperationalGap D G state.agent}
    (evidence : SemanticGapEvidence system realization state gap) :
    ClosureInterface D :=
  match evidence with
  | .witnessedMismatch _ _ _ =>
      .syntactic state.agent.candidate gap.index
  | .unresolvedFiber _ _ rightWorld _ _ _ _ =>
      .semantic rightWorld gap.index

/-- Pole realization records that no arbitrary separated pair was substituted. -/
structure SemanticGapPoleRealization
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    {realization : GapEvidenceRealization system}
    {state : ActiveSemanticClosureState D}
    {gap : OperationalGap D G state.agent}
    (evidence : SemanticGapEvidence system realization state gap)
    (leftPole rightPole : ClosureInterface D) where
  leftEq : leftPole = evidence.expectedLeftPole
  rightEq : rightPole = evidence.expectedRightPole

/-- A validated gap combines the operational object with its canonical poles. -/
structure TypedSemanticGap
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I)
    (realization : GapEvidenceRealization system)
    (state : ActiveSemanticClosureState D)
    (gap : OperationalGap D G state.agent) where
  actualCompatible :
    system.CompatibleWithViewHistory state.agent state.world
  leftPole : ClosureInterface D
  rightPole : ClosureInterface D
  leftProjects : ClosureInterface.project leftPole = gap.index
  rightProjects : ClosureInterface.project rightPole = gap.index
  separated : leftPole = rightPole -> False
  evidence : SemanticGapEvidence system realization state gap
  poleRealization :
    SemanticGapPoleRealization evidence leftPole rightPole

/-- Build canonical typed poles from any validated semantic evidence. -/
def typedSemanticGapOfEvidence
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    {realization : GapEvidenceRealization system}
    {state : ActiveSemanticClosureState D}
    {gap : OperationalGap D G state.agent}
    (actualCompatible :
      system.CompatibleWithViewHistory state.agent state.world)
    (evidence : SemanticGapEvidence system realization state gap) :
    TypedSemanticGap system realization state gap := by
  cases evidence with
  | witnessedMismatch kindEq disagrees evidenceRealization =>
      exact
        { actualCompatible := actualCompatible
          leftPole := .semantic state.world gap.index
          rightPole := .syntactic state.agent.candidate gap.index
          leftProjects := rfl
          rightProjects := rfl
          separated := by
            intro equality
            cases equality
          evidence :=
            .witnessedMismatch kindEq disagrees evidenceRealization
          poleRealization :=
            { leftEq := rfl
              rightEq := rfl } }
  | unresolvedFiber kindEq leftWorld rightWorld leftCompatible
      rightCompatible targetsSeparated evidenceRealization =>
      exact
        { actualCompatible := actualCompatible
          leftPole := .semantic leftWorld gap.index
          rightPole := .semantic rightWorld gap.index
          leftProjects := rfl
          rightProjects := rfl
          separated := by
            intro equality
            cases equality
            exact targetsSeparated rfl
          evidence :=
            .unresolvedFiber
              kindEq leftWorld rightWorld
              leftCompatible rightCompatible targetsSeparated
              evidenceRealization
          poleRealization :=
            { leftEq := rfl
              rightEq := rfl } }

/-- Laws preventing vacuous closure and external transition data. -/
structure LawfulActiveSemanticClosureSystem
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I) where
  evidenceRealization : GapEvidenceRealization system
  initialActualCompatible :
    (world : D.SemanticWorld) ->
    system.CompatibleWithViewHistory
      (system.initialState world).agent world
  validatesOpenGap :
    (state : ActiveSemanticClosureState D) ->
    (gap : OperationalGap D G state.agent) ->
    system.detectGap state.agent = .open gap ->
    SemanticGapEvidence system evidenceRealization state gap
  nextPreservesActualCompatibility :
    (state : ActiveSemanticClosureState D) ->
    system.CompatibleWithViewHistory state.agent state.world ->
    system.CompatibleWithViewHistory
      (system.nextState state).agent
      (system.nextState state).world

end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.ActiveSemanticClosureSystem.nextState
#print axioms Meta.ActiveSemanticClosure.ActiveSemanticClosureSystem.nextState_eq_executeRepair_of_open
#print axioms Meta.ActiveSemanticClosure.ActiveSemanticClosureSystem.nextState_world
#print axioms Meta.ActiveSemanticClosure.typedSemanticGapOfEvidence
#print axioms Meta.ActiveSemanticClosure.fiberDeterminateAt_of_knownCorrectAt
#print axioms Meta.ActiveSemanticClosure.GapClosedBy
#print axioms Meta.ActiveSemanticClosure.LawfulActiveSemanticClosureSystem
/- AXIOM_AUDIT_END -/
