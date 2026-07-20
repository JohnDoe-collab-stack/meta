import Meta.AI.ActiveClosureFoundationalRealization

/-!
# Exact certified inference for the finite active-closure model

Each inference step stores the exact detected gap, authorized use, transport,
query, environmental response, intrinsic repair, successor, closure proof, and
observable state change.  The three-step run is therefore replayable without
an external transition oracle.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace Certified

open Finite

structure CertifiedInferenceStep (before after : ClosedState) where
  gap : Gap before.agent
  detectedGap_eq_detectGap : finiteSystem.detectGap before.agent = .open gap
  use : AuthorizedUse before.agent gap
  authorizedUse_eq_authorize : use = finiteSystem.authorize before.agent gap
  transport : AuthorizedTransport before.agent gap use
  executedTransport_eq_executeTransport :
    transport = finiteSystem.executeTransport before.agent gap use
  query : Query gap.index
  selectedQuery_eq_selectQuery : query = finiteSystem.selectQuery transport
  response : Response query
  environmentResponse_eq_respond : response = finiteSystem.respond before.world query
  repair :
    IntrinsicRepair
      finiteData finiteGapLanguage finiteTransportLanguage finiteInteractionLanguage
      before.agent gap use transport query response
  builtRepair_eq_buildRepair :
    repair = finiteSystem.buildRepair
      before.agent gap use transport query response
  responseFootprint :
    Finite.ResponseFootprint query
  responseFootprint_eq : responseFootprint = Finite.responseFootprint query
  responseWithinBound :
    encodedResponseBits response <= responseFootprint.maxResponseBits
  nextAgent_eq_executeRepair :
    after = ActiveSemanticClosureSystem.executeRepair before repair
  canonicalNext_eq : after = finiteSystem.nextState before
  closesDetectedGap : GapClosedBy finiteSystem before gap after
  transitionEffective : after = before -> False

def certifiedStep0 : CertifiedInferenceStep state0 state1 where
  gap := gap0
  detectedGap_eq_detectGap := state0_detects_gap0
  use := use0
  authorizedUse_eq_authorize := rfl
  transport := transport0
  executedTransport_eq_executeTransport := rfl
  query := query0
  selectedQuery_eq_selectQuery := rfl
  response := response0
  environmentResponse_eq_respond := rfl
  repair := repair0
  builtRepair_eq_buildRepair := rfl
  responseFootprint := Finite.responseFootprint query0
  responseFootprint_eq := rfl
  responseWithinBound := respond_withinBound state0.world query0
  nextAgent_eq_executeRepair := state1_eq_executeRepair0
  canonicalNext_eq := rfl
  closesDetectedGap := gap0ClosedByState1
  transitionEffective := state1_differs_from_state0

def certifiedStep1 : CertifiedInferenceStep state1 state2 where
  gap := gap1
  detectedGap_eq_detectGap := state1_detects_gap1
  use := use1
  authorizedUse_eq_authorize := rfl
  transport := transport1
  executedTransport_eq_executeTransport := rfl
  query := query1
  selectedQuery_eq_selectQuery := rfl
  response := response1
  environmentResponse_eq_respond := rfl
  repair := repair1
  builtRepair_eq_buildRepair := rfl
  responseFootprint := Finite.responseFootprint query1
  responseFootprint_eq := rfl
  responseWithinBound := respond_withinBound state1.world query1
  nextAgent_eq_executeRepair := state2_eq_executeRepair1
  canonicalNext_eq := rfl
  closesDetectedGap := gap1ClosedByState2
  transitionEffective := state2_differs_from_state1

def certifiedStep2 : CertifiedInferenceStep state2 state3 where
  gap := gap2
  detectedGap_eq_detectGap := state2_detects_gap2
  use := use2
  authorizedUse_eq_authorize := rfl
  transport := transport2
  executedTransport_eq_executeTransport := rfl
  query := query2
  selectedQuery_eq_selectQuery := rfl
  response := response2
  environmentResponse_eq_respond := rfl
  repair := repair2
  builtRepair_eq_buildRepair := rfl
  responseFootprint := Finite.responseFootprint query2
  responseFootprint_eq := rfl
  responseWithinBound := respond_withinBound state2.world query2
  nextAgent_eq_executeRepair := state3_eq_executeRepair2
  canonicalNext_eq := rfl
  closesDetectedGap := gap2ClosedByState3
  transitionEffective := state3_differs_from_state2

structure FiniteDetectionCertificate where
  mismatchGap : Gap state0.agent
  mismatchGap_eq : mismatchGap = gap0
  detectedMismatch : finiteSystem.detectGap state0.agent = .open mismatchGap
  mismatchKind : mismatchGap.kind = .witnessedMismatch
  mismatchSound :
    TypedSemanticGap finiteSystem finiteEvidenceRealization state0 mismatchGap
  firstFiberGap : Gap state1.agent
  firstFiberGap_eq : firstFiberGap = gap1
  firstFiberDetected : finiteSystem.detectGap state1.agent = .open firstFiberGap
  firstFiberKind : firstFiberGap.kind = .unresolvedFiber
  firstFiberSound :
    TypedSemanticGap finiteSystem finiteEvidenceRealization state1 firstFiberGap
  secondFiberGap : Gap state2.agent
  secondFiberGap_eq : secondFiberGap = gap2
  secondFiberDetected : finiteSystem.detectGap state2.agent = .open secondFiberGap
  secondFiberKind : secondFiberGap.kind = .unresolvedFiber
  secondFiberSound :
    TypedSemanticGap finiteSystem finiteEvidenceRealization state2 secondFiberGap
  terminalDetected : finiteSystem.detectGap state3.agent = .closed
  terminalKnownSound : KnownClosedOnAll state3.agent
  terminalActualSound : ClosedOnAll state3.world state3.agent.candidate

def finiteDetectionCertificate : FiniteDetectionCertificate where
  mismatchGap := gap0
  mismatchGap_eq := rfl
  detectedMismatch := state0_detects_gap0
  mismatchKind := rfl
  mismatchSound := typedGap0
  firstFiberGap := gap1
  firstFiberGap_eq := rfl
  firstFiberDetected := state1_detects_gap1
  firstFiberKind := rfl
  firstFiberSound := typedGap1
  secondFiberGap := gap2
  secondFiberGap_eq := rfl
  secondFiberDetected := state2_detects_gap2
  secondFiberKind := rfl
  secondFiberSound := typedGap2
  terminalDetected := state3_is_closed
  terminalKnownSound := state3_knownClosed
  terminalActualSound := state3_actualClosed

def detectedMismatch_sound :
    TypedSemanticGap finiteSystem finiteEvidenceRealization state0 gap0 :=
  finiteDetectionCertificate.mismatchSound

structure DetectedFiberSoundness where
  first : TypedSemanticGap finiteSystem finiteEvidenceRealization state1 gap1
  second : TypedSemanticGap finiteSystem finiteEvidenceRealization state2 gap2

def detectedFiber_sound : DetectedFiberSoundness where
  first := finiteDetectionCertificate.firstFiberSound
  second := finiteDetectionCertificate.secondFiberSound

structure CanonicalDetectionCoverage where
  state0Open : finiteSystem.detectGap state0.agent = .open gap0
  state1Open : finiteSystem.detectGap state1.agent = .open gap1
  state2Open : finiteSystem.detectGap state2.agent = .open gap2
  state3Closed : finiteSystem.detectGap state3.agent = .closed

def detectedGap_complete : CanonicalDetectionCoverage where
  state0Open := state0_detects_gap0
  state1Open := state1_detects_gap1
  state2Open := state2_detects_gap2
  state3Closed := state3_is_closed

theorem detectedGap_kind_correct :
    gap0.kind = .witnessedMismatch ∧
    gap1.kind = .unresolvedFiber ∧
    gap2.kind = .unresolvedFiber :=
  ⟨rfl, rfl, rfl⟩

theorem detectedGap_index_correct :
    gap0.index = .first ∧ gap1.index = .second ∧ gap2.index = .third :=
  ⟨rfl, rfl, rfl⟩

theorem closedStatus_known_sound : KnownClosedOnAll state3.agent :=
  state3_knownClosed

theorem closedStatus_sound : ClosedOnAll state3.world state3.agent.candidate :=
  state3_actualClosed

structure RepairClosureCertificate where
  first : GapClosedBy finiteSystem state0 gap0 state1
  second : GapClosedBy finiteSystem state1 gap1 state2
  third : GapClosedBy finiteSystem state2 gap2 state3
  firstNecessary : GapClosedBy finiteSystem state0 gap0 alternateState1 -> False
  secondNecessary : GapClosedBy finiteSystem state1 gap1 alternateState2 -> False
  thirdNecessary : GapClosedBy finiteSystem state2 gap2 alternateState3 -> False

def repair_closes_detectedGap : RepairClosureCertificate where
  first := gap0ClosedByState1
  second := gap1ClosedByState2
  third := gap2ClosedByState3
  firstNecessary := alternateResponse0_not_closesGap
  secondNecessary := alternateResponse1_not_closesGap
  thirdNecessary := alternateResponse2_not_closesGap

structure RepairPrefixCertificate where
  state1Prefix :
    KnownClosedOn finiteSystem state1.agent state1.agent.candidate repairedPrefix1
  state2Prefix :
    KnownClosedOn finiteSystem state2.agent state2.agent.candidate repairedPrefix2
  state3Prefix :
    KnownClosedOn finiteSystem state3.agent state3.agent.candidate repairedPrefix3
  retainedAt1 : RepairsRetained state1.agent
  retainedAt2 : RepairsRetained state2.agent
  retainedAt3 : RepairsRetained state3.agent

def repair_preserves_closedPrefix : RepairPrefixCertificate where
  state1Prefix := state1_knownClosedOnRepairedPrefix
  state2Prefix := state2_knownClosedOnRepairedPrefix
  state3Prefix := state3_knownClosedOnRepairedPrefix
  retainedAt1 := state1_retainsRepairs
  retainedAt2 := state2_retainsRepairs
  retainedAt3 := state3_retainsRepairs

/-! ## Observable causal sensitivity of the concrete chain -/

theorem firstSecondGapIndicesSeparated :
    gap0.index = gap1.index -> False := by
  intro equality
  cases equality

theorem firstSecondUseDirectionsSeparated :
    use0.direction = use1.direction -> False := by
  intro equality
  cases equality

theorem firstSecondTransportIndicesSeparated :
    transport0.output.requestedIndex = transport1.output.requestedIndex -> False := by
  intro equality
  cases equality

theorem actualAlternateResponseSeparated :
    response0 = alternateResponse0 -> False := by
  intro equality
  cases equality

theorem actualAlternatePatchSeparated :
    repair0.candidatePatch = alternateRepair0.candidatePatch -> False := by
  intro equality
  cases equality

theorem actualAlternateSuccessorSeparated :
    state1 = alternateState1 -> False := by
  intro equality
  have candidateEquality := congrArg
    (fun state => state.agent.candidate.first) equality
  cases candidateEquality

structure StructuralCausalityCertificate where
  gapsAffectIndices : gap0.index = gap1.index -> False
  usesAffectDirections : use0.direction = use1.direction -> False
  transportsAffectRequests :
    transport0.output.requestedIndex = transport1.output.requestedIndex -> False
  responsesAffectRepairs : response0 = alternateResponse0 -> False
  repairsCarryDifferentPatches :
    repair0.candidatePatch = alternateRepair0.candidatePatch -> False
  repairsAffectSuccessors : state1 = alternateState1 -> False
  crossedResponseFailsClosure :
    GapClosedBy finiteSystem state0 gap0 alternateState1 -> False
  openGapCausesEffectiveTransition : state1 = state0 -> False
  closedStatusCausesStasis : finiteSystem.nextState state3 = state3
  separationPersistsAfterClosure :
    (typedGap0.leftPole = typedGap0.rightPole -> False) ∧
    (typedGap1.leftPole = typedGap1.rightPole -> False)

def structuralCausalityCertificate : StructuralCausalityCertificate where
  gapsAffectIndices := firstSecondGapIndicesSeparated
  usesAffectDirections := firstSecondUseDirectionsSeparated
  transportsAffectRequests := firstSecondTransportIndicesSeparated
  responsesAffectRepairs := actualAlternateResponseSeparated
  repairsCarryDifferentPatches := actualAlternatePatchSeparated
  repairsAffectSuccessors := actualAlternateSuccessorSeparated
  crossedResponseFailsClosure := alternateResponse0_not_closesGap
  openGapCausesEffectiveTransition := state1_differs_from_state0
  closedStatusCausesStasis := state3_is_stable
  separationPersistsAfterClosure := ⟨typedGap0.separated, typedGap1.separated⟩

structure AICertifiedRunCertificate where
  first : CertifiedInferenceStep state0 state1
  second : CertifiedInferenceStep state1 state2
  third : CertifiedInferenceStep state2 state3
  exactOrbit : FiniteClosureOrbitCertificate
  detection : FiniteDetectionCertificate
  repairClosure : RepairClosureCertificate
  prefixCertificate : RepairPrefixCertificate
  causalSensitivity : StructuralCausalityCertificate
  reachesClosedOn : ClosedOnAll state3.world state3.agent.candidate
  reachesKnownClosedOn : KnownClosedOnAll state3.agent
  terminalStable : finiteSystem.nextState state3 = state3

def aiCertifiedRunCertificate : AICertifiedRunCertificate where
  first := certifiedStep0
  second := certifiedStep1
  third := certifiedStep2
  exactOrbit := finiteClosureOrbitCertificate
  detection := finiteDetectionCertificate
  repairClosure := repair_closes_detectedGap
  prefixCertificate := repair_preserves_closedPrefix
  causalSensitivity := structuralCausalityCertificate
  reachesClosedOn := state3_actualClosed
  reachesKnownClosedOn := state3_knownClosed
  terminalStable := state3_is_stable

structure AIFiniteClosureCertificate where
  foundational : Foundational.ActiveClosureFoundationalRealization
  foundational_eq :
    foundational = Foundational.activeClosureFoundationalRealization
  orbit : FiniteClosureOrbitCertificate
  certifiedRun : AICertifiedRunCertificate
  detectionSoundness : FiniteDetectionCertificate
  repairSoundness : RepairClosureCertificate
  prefixPreservation : RepairPrefixCertificate
  terminalClosed : ClosedOnAll state3.world state3.agent.candidate
  terminalKnown : KnownClosedOnAll state3.agent
  terminalStable : finiteSystem.nextState state3 = state3

def aiFiniteClosureCertificate : AIFiniteClosureCertificate where
  foundational := Foundational.activeClosureFoundationalRealization
  foundational_eq := rfl
  orbit := finiteClosureOrbitCertificate
  certifiedRun := aiCertifiedRunCertificate
  detectionSoundness := finiteDetectionCertificate
  repairSoundness := repair_closes_detectedGap
  prefixPreservation := repair_preserves_closedPrefix
  terminalClosed := state3_actualClosed
  terminalKnown := state3_knownClosed
  terminalStable := state3_is_stable

end Certified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.Certified.certifiedStep0
#print axioms Meta.ActiveSemanticClosure.Certified.certifiedStep1
#print axioms Meta.ActiveSemanticClosure.Certified.certifiedStep2
#print axioms Meta.ActiveSemanticClosure.Certified.detectedMismatch_sound
#print axioms Meta.ActiveSemanticClosure.Certified.detectedFiber_sound
#print axioms Meta.ActiveSemanticClosure.Certified.detectedGap_complete
#print axioms Meta.ActiveSemanticClosure.Certified.repair_closes_detectedGap
#print axioms Meta.ActiveSemanticClosure.Certified.repair_preserves_closedPrefix
#print axioms Meta.ActiveSemanticClosure.Certified.structuralCausalityCertificate
#print axioms Meta.ActiveSemanticClosure.Certified.aiCertifiedRunCertificate
#print axioms Meta.ActiveSemanticClosure.Certified.aiFiniteClosureCertificate
/- AXIOM_AUDIT_END -/
