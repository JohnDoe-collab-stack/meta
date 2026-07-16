import Meta.AI.ActiveClosureInterventions
import Meta.AI.CertifiedInference
import Meta.AI.ActiveClosureUseGraphNonReduction
import Meta.AI.OpenClosureFoundationalRealization
import Meta.AI.VisibleFactoredClosureNoGo

/-!
# Complete non-empirical validation obligations

This module closes the Lean obligations that precede the empirical v23
campaign.  Every witness is tied either to a canonical reachable state or to a
well-typed intervention on such a state.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace LeanValidation

open Finite
open Open
open Interventions

def embedValue (value : Value) : Option Value := some value

theorem agrees_embedValue (value : Value) :
    Agrees (embedValue value) value := rfl

theorem finiteDistinctSemanticValues :
    evaluate canonicalWorld .first =
      evaluate firstEliminatedWorld .first -> False := by
  intro equality
  cases equality

theorem finiteWorldsSeparated :
    canonicalWorld = firstEliminatedWorld -> False := by
  intro equality
  exact finiteDistinctSemanticValues
    (congrArg (fun world => evaluate world .first) equality)

theorem finiteCandidatesSeparated :
    state0.agent.candidate = state1.agent.candidate -> False := by
  intro equality
  have firstEquality := congrArg Candidate.first equality
  cases firstEquality

theorem finiteIndicesSeparated : Index.first = .second -> False := by
  intro equality
  cases equality

theorem finiteProjectionNonconstant :
    ClosureInterface.project
        (@ClosureInterface.semantic finiteData canonicalWorld Index.first) =
      ClosureInterface.project
        (@ClosureInterface.semantic finiteData canonicalWorld Index.second) -> False :=
  finiteIndicesSeparated

theorem finiteAgreesPositive : Agrees (some .green) .green := rfl

theorem finiteAgreesNegative : Agrees (some .red) .green -> False := by
  intro agreement
  cases agreement

theorem finiteGapEvidenceKindsSeparated : gap0.kind = gap1.kind -> False := by
  intro equality
  cases equality

theorem finiteSelectedQuerySensitiveToTransport :
    finiteSystem.selectQuery transport0 =
      finiteSystem.selectQuery evidenceTransport0 -> False := by
  intro equality
  cases equality

theorem finiteRepairsSensitiveToResponse :
    repair0.candidatePatch = alternateRepair0.candidatePatch -> False := by
  intro equality
  cases equality

structure FiniteSemanticNontriviality where
  sourceState : ClosedState
  sourceState_eq : sourceState = state0
  sourceReachable :
    ReachableFromInitial finiteSystem canonicalWorld sourceState
  repairedState : ClosedState
  repairedState_eq : repairedState = state1
  repairedStateReachable :
    ReachableFromInitial finiteSystem canonicalWorld repairedState
  worldLeft : World
  worldRight : World
  worldLeftCompatible :
    finiteSystem.CompatibleWithViewHistory sourceState.agent worldLeft
  worldRightCompatible :
    finiteSystem.CompatibleWithViewHistory sourceState.agent worldRight
  worldsSeparated : worldLeft = worldRight -> False
  candidateLeft : Candidate
  candidateRight : Candidate
  candidateLeft_eq : candidateLeft = sourceState.agent.candidate
  candidateRight_eq : candidateRight = repairedState.agent.candidate
  candidatesSeparated : candidateLeft = candidateRight -> False
  indexLeft : Index
  indexRight : Index
  indicesSeparated : indexLeft = indexRight -> False
  projectionNonconstant :
    ClosureInterface.project
        (@ClosureInterface.semantic finiteData worldLeft indexLeft) =
      ClosureInterface.project
        (@ClosureInterface.semantic finiteData worldLeft indexRight) -> False
  sameVisibleSeparatedFiber :
    ClosureInterface.project typedGap0.leftPole =
      ClosureInterface.project typedGap0.rightPole
  fiberPolesSeparated : typedGap0.leftPole = typedGap0.rightPole -> False
  fiberIndex_eq : gap0.index = indexLeft
  semanticValuesSeparated :
    evaluate worldLeft indexLeft = evaluate worldRight indexLeft -> False
  agreesPositive : Agrees (embedValue .green) .green
  agreesNegative : Agrees (embedValue .red) .green -> False
  targetUnique :
    ∀ prediction left right,
      Agrees prediction left -> Agrees prediction right -> left = right

def finiteSemanticNontriviality : FiniteSemanticNontriviality where
  sourceState := state0
  sourceState_eq := rfl
  sourceReachable := state0_reachable
  repairedState := state1
  repairedState_eq := rfl
  repairedStateReachable := state1_reachable
  worldLeft := canonicalWorld
  worldRight := firstEliminatedWorld
  worldLeftCompatible := state0_actualCompatible
  worldRightCompatible :=
    (compatible_state0_iff firstEliminatedWorld).mpr (by
      intro equality
      cases equality)
  worldsSeparated := finiteWorldsSeparated
  candidateLeft := state0.agent.candidate
  candidateRight := state1.agent.candidate
  candidateLeft_eq := rfl
  candidateRight_eq := rfl
  candidatesSeparated := finiteCandidatesSeparated
  indexLeft := .first
  indexRight := .second
  indicesSeparated := finiteIndicesSeparated
  projectionNonconstant := finiteProjectionNonconstant
  sameVisibleSeparatedFiber := typedGap0.leftProjects.trans typedGap0.rightProjects.symm
  fiberPolesSeparated := typedGap0.separated
  fiberIndex_eq := rfl
  semanticValuesSeparated := finiteDistinctSemanticValues
  agreesPositive := finiteAgreesPositive
  agreesNegative := finiteAgreesNegative
  targetUnique := finiteData.agrees_target_unique

structure FiniteOperationalNontriviality where
  firstGap : Gap state0.agent
  firstGap_eq : firstGap = gap0
  secondGap : Gap state1.agent
  secondGap_eq : secondGap = gap1
  gapsHaveDifferentKinds : firstGap.kind = secondGap.kind -> False
  primaryUse : AuthorizedUse state0.agent gap0
  alternateUse : AuthorizedUse state0.agent gap0
  usesSeparated : primaryUse = alternateUse -> False
  primaryTransport : AuthorizedTransport state0.agent gap0 primaryUse
  alternateTransport : AuthorizedTransport state0.agent gap0 primaryUse
  transportsSeparated : primaryTransport = alternateTransport -> False
  selectedQueriesSeparated :
    finiteSystem.selectQuery primaryTransport =
      finiteSystem.selectQuery alternateTransport -> False
  firstAdmissibleQuery : Query gap0.index
  firstAdmissible :
    QueryAdmissible state0.agent gap0 primaryUse primaryTransport
      firstAdmissibleQuery
  secondAdmissibleQuery : Query gap0.index
  secondAdmissible :
    QueryAdmissible state0.agent gap0 primaryUse primaryTransport
      secondAdmissibleQuery
  admissibleQueriesSeparated :
    firstAdmissibleQuery = secondAdmissibleQuery -> False
  rejectedQuery : Query gap0.index
  rejectedQueryRefuted :
    QueryAdmissible state0.agent gap0 primaryUse primaryTransport
      rejectedQuery -> False
  positiveOutputEvidence :
    TransportEvidence state0.agent gap0 primaryUse
      primaryTransport.reading primaryTransport.output
  rejectedOutput :
    TransportOutput state0.agent gap0 primaryUse primaryTransport.reading
  rejectedOutputRefuted :
    TransportEvidence state0.agent gap0 primaryUse
      primaryTransport.reading rejectedOutput -> False
  responseChangesRepair :
    repair0.candidatePatch = alternateRepair0.candidatePatch -> False

def finiteOperationalNontriviality : FiniteOperationalNontriviality where
  firstGap := gap0
  firstGap_eq := rfl
  secondGap := gap1
  secondGap_eq := rfl
  gapsHaveDifferentKinds := finiteGapEvidenceKindsSeparated
  primaryUse := use0
  alternateUse := inspectUse0
  usesSeparated := use0_ne_inspectUse0
  primaryTransport := transport0
  alternateTransport := evidenceTransport0
  transportsSeparated := transport0_ne_evidenceTransport0
  selectedQueriesSeparated := finiteSelectedQuerySensitiveToTransport
  firstAdmissibleQuery := query0
  firstAdmissible := finiteSystem.selectedQueryAdmissible transport0
  secondAdmissibleQuery := confirmQuery0
  secondAdmissible := confirmQuery0_admissible
  admissibleQueriesSeparated := query0_ne_confirmQuery0
  rejectedQuery := noInformationQuery0
  rejectedQueryRefuted := noInformationQuery0_not_admissible
  positiveOutputEvidence := transport0.evidence
  rejectedOutput := rejectedTransportOutput0
  rejectedOutputRefuted := rejectedTransportOutput0_hasNoEvidence
  responseChangesRepair := finiteRepairsSensitiveToResponse

structure FiniteResponseContract where
  footprint :
    {index : Index} -> (query : Query index) -> ResponseFootprint query
  footprint_eq :
    ∀ {index} (query : Query index), footprint query = responseFootprint query
  responseLocality :
    ∀ {index} (query : Query index) left right,
      WorldsAgreeOn (footprint query) left right ->
      respond left query = respond right query
  bounded :
    ∀ world {index} (query : Query index),
      encodedResponseBits (respond world query) <=
        (footprint query).maxResponseBits
  firstSplit : SelectedQuerySplitsCompatibleFiber state0 gap0 use0 transport0
  secondSplit : SelectedQuerySplitsCompatibleFiber state1 gap1 use1 transport1
  thirdSplit : SelectedQuerySplitsCompatibleFiber state2 gap2 use2 transport2

def finiteResponseContract : FiniteResponseContract where
  footprint := responseFootprint
  footprint_eq := by intros; rfl
  responseLocality := respond_local
  bounded := respond_withinBound
  firstSplit := selectedQuery0_splitsCompatibleFiber
  secondSplit := selectedQuery1_splitsCompatibleFiber
  thirdSplit := selectedQuery2_splitsCompatibleFiber

structure FiniteMeasureClosureCertificate where
  domain : List Index
  domain_eq : domain = canonicalDomain
  bound : Nat
  bound_eq : bound = domain.length
  count0 : openGapCount state0.agent = 3
  count1 : openGapCount state1.agent = 2
  count2 : openGapCount state2.agent = 1
  count3 : openGapCount state3.agent = 0
  firstDecrease : openGapCount state1.agent < openGapCount state0.agent
  secondDecrease : openGapCount state2.agent < openGapCount state1.agent
  thirdDecrease : openGapCount state3.agent < openGapCount state2.agent
  reachesBound : finiteStateAt bound = state3
  knownClosedAtBound :
    KnownClosedOn finiteSystem
      (finiteStateAt bound).agent
      (finiteStateAt bound).agent.candidate domain
  closedAtBound :
    ClosedOn finiteData
      (finiteStateAt bound).world
      (finiteStateAt bound).agent.candidate domain
  terminalStasis : finiteSystem.nextState (finiteStateAt bound) = finiteStateAt bound

def finiteMeasureClosureCertificate : FiniteMeasureClosureCertificate where
  domain := canonicalDomain
  domain_eq := rfl
  bound := finiteClosureBound
  bound_eq := rfl
  count0 := state0_openGapCount
  count1 := state1_openGapCount
  count2 := state2_openGapCount
  count3 := state3_openGapCount
  firstDecrease := state1_strictlyReducesOpenGaps
  secondDecrease := state2_strictlyReducesOpenGaps
  thirdDecrease := state3_strictlyReducesOpenGaps
  reachesBound := finiteStateAt_bound
  knownClosedAtBound := finiteOrbit_reachesKnownClosedOn
  closedAtBound := finiteOrbit_reachesClosedOn
  terminalStasis := by change finiteSystem.nextState state3 = state3; exact state3_is_stable

structure TypedInterventionCertificate where
  natural : IntervenedOpenRun finiteSystem state0 gap0
  useIntervention : IntervenedOpenRun finiteSystem state0 gap0
  transportIntervention : IntervenedOpenRun finiteSystem state0 gap0
  queryIntervention : IntervenedOpenRun finiteSystem state0 gap0
  responseIntervention : IntervenedOpenRun finiteSystem state0 gap0
  patchIntervention : IntervenedOpenRun finiteSystem state0 gap0
  useChangesDirection :
    natural.use.direction = useIntervention.use.direction -> False
  useChangesTransport :
    natural.transport.reading.direction =
      useIntervention.transport.reading.direction -> False
  transportChangesQuery :
    natural.query = transportIntervention.query -> False
  responseChangesRepair :
    natural.repair.candidatePatch =
      responseIntervention.repair.candidatePatch -> False
  responseChangesSuccessor : natural.after = responseIntervention.after -> False
  crossedResponseFailsClosure :
    GapClosedBy finiteSystem state0 gap0 responseIntervention.after -> False
  allRunsPreserveWorld :
    natural.after.world = state0.world ∧
    useIntervention.after.world = state0.world ∧
    transportIntervention.after.world = state0.world ∧
    queryIntervention.after.world = state0.world ∧
    responseIntervention.after.world = state0.world ∧
    patchIntervention.after.world = state0.world

def typedInterventionCertificate : TypedInterventionCertificate where
  natural := finiteNaturalOpenRun0
  useIntervention := finiteUseIntervention0
  transportIntervention := finiteTransportIntervention0
  queryIntervention := finiteConfirmQueryIntervention0
  responseIntervention := finiteCrossedResponseIntervention0
  patchIntervention := finiteCrossedPatchIntervention0
  useChangesDirection := finiteUseIntervention_changesDirection
  useChangesTransport := finiteUseIntervention_changesTransport
  transportChangesQuery := finiteTransportIntervention_changesQuery
  responseChangesRepair := finiteCrossedResponse_changesRepair
  responseChangesSuccessor := finiteCrossedResponse_changesSuccessor
  crossedResponseFailsClosure := finiteCrossedResponse_failsClosure
  allRunsPreserveWorld :=
    ⟨intervenedOpenRun_world _, intervenedOpenRun_world _,
      intervenedOpenRun_world _, intervenedOpenRun_world _,
      intervenedOpenRun_world _, intervenedOpenRun_world _⟩

structure AILeanNonV23Obligations where
  finiteSemantic : FiniteSemanticNontriviality
  finiteOperational : FiniteOperationalNontriviality
  finiteResponses : FiniteResponseContract
  finiteMeasureClosure : FiniteMeasureClosureCertificate
  typedInterventions : TypedInterventionCertificate
  finiteCertifiedRun : Certified.AICertifiedRunCertificate
  finiteFoundational : Foundational.ActiveClosureFoundationalRealization
  openOrbit : AIOpenOrbitCertificate
  openFoundational : OpenFoundational.OpenActiveClosureFoundationalRealization
  passiveAndFactoredNoGo : NoGo.AIClosureNoGoCertificate
  useGraphNonReduction :
    FoundationalNonReduction.AIUseGraphNonReductionCertificate
  finiteUseNotProjective :
    RelaxedUsageRegime.ExactProjectiveRepresentation.{0, 0}
      Foundational.initialClosureFiberRegime -> False
  openUseNotProjective :
    ∀ stage,
      RelaxedUsageRegime.ExactProjectiveRepresentation.{0, 0}
        (OpenFoundational.openFiberRegimeAt stage) -> False

def aiLeanNonV23Obligations : AILeanNonV23Obligations where
  finiteSemantic := finiteSemanticNontriviality
  finiteOperational := finiteOperationalNontriviality
  finiteResponses := finiteResponseContract
  finiteMeasureClosure := finiteMeasureClosureCertificate
  typedInterventions := typedInterventionCertificate
  finiteCertifiedRun := Certified.aiCertifiedRunCertificate
  finiteFoundational := Foundational.activeClosureFoundationalRealization
  openOrbit := aiOpenOrbitCertificate
  openFoundational := OpenFoundational.openActiveClosureFoundationalRealization
  passiveAndFactoredNoGo := NoGo.aiClosureNoGoCertificate
  useGraphNonReduction :=
    FoundationalNonReduction.aiUseGraphNonReductionCertificate
  finiteUseNotProjective :=
    Foundational.initialClosureFiber_not_exactProjective
  openUseNotProjective := OpenFoundational.openFiber_not_exactProjective

end LeanValidation
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.LeanValidation.finiteSemanticNontriviality
#print axioms Meta.ActiveSemanticClosure.LeanValidation.finiteOperationalNontriviality
#print axioms Meta.ActiveSemanticClosure.LeanValidation.finiteResponseContract
#print axioms Meta.ActiveSemanticClosure.LeanValidation.finiteMeasureClosureCertificate
#print axioms Meta.ActiveSemanticClosure.LeanValidation.typedInterventionCertificate
#print axioms Meta.ActiveSemanticClosure.LeanValidation.aiLeanNonV23Obligations
/- AXIOM_AUDIT_END -/
