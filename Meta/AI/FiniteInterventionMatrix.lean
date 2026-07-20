import Meta.AI.ActiveClosureInterventions

/-!
# Complete finite intervention matrix

All eighteen protocol interventions are classified internally.  Positive
replacements execute the dependent causal chain.  Suppressions and ill-indexed
replacements stop at the first stage for which no well-typed downstream object
can be supplied.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace FiniteInterventionMatrix

open Finite
open Interventions

inductive InterventionKind where
  | projection
  | gapSuppress
  | gapPermute
  | useSuppress
  | usePermute
  | transportSuppress
  | transportPermute
  | queryNeutral
  | queryAlternate
  | responseCross
  | responseNeutral
  | repairNeutral
  | repairPermute
  | nextBypass
  | historyDrop
  | orderSwap
  | randomGap
  | unusedGap
  deriving DecidableEq

inductive RefusalStage where
  | gap
  | use
  | transport
  | query
  | response
  | repair
  | next
  deriving DecidableEq

inductive InterventionOutcome where
  | advanced (after : ClosedState)
  | typedRefusal (stage : RefusalStage)

def alternateGapThird0 : Gap state0.agent :=
  { index := .third
    kind := .unresolvedFiber
    observableEvidence := .unknown .third rfl }

def finiteRandomGapIntervention0 :=
  runWithGap finiteSystem state0 alternateGapThird0

def observationIntervenedGap0 : Gap observationIntervenedState0.agent :=
  { index := .first
    kind := .witnessedMismatch
    observableEvidence :=
      .excludedPrediction .first .red rfl rfl }

def finiteObservationOpenIntervention0 :=
  runWithGap finiteSystem observationIntervenedState0 observationIntervenedGap0

def droppedHistoryState2 : ClosedState :=
  { world := state2.world
    agent :=
      { candidate := state2.agent.candidate
        observation := state2.agent.observation
        history := [repair1.historyRecord] } }

def outcome : InterventionKind -> InterventionOutcome
  | .projection => .advanced finiteObservationIntervention0
  | .gapSuppress => .typedRefusal .gap
  | .gapPermute => .advanced finiteGapIntervention0.after
  | .useSuppress => .typedRefusal .use
  | .usePermute => .advanced finiteUseIntervention0.after
  | .transportSuppress => .typedRefusal .transport
  | .transportPermute => .advanced finiteTransportIntervention0.after
  | .queryNeutral => .typedRefusal .query
  | .queryAlternate => .advanced finiteConfirmQueryIntervention0.after
  | .responseCross => .advanced finiteCrossedResponseIntervention0.after
  | .responseNeutral => .typedRefusal .response
  | .repairNeutral => .typedRefusal .repair
  | .repairPermute => .typedRefusal .repair
  | .nextBypass => .typedRefusal .next
  | .historyDrop => .advanced droppedHistoryState2
  | .orderSwap => .typedRefusal .transport
  | .randomGap => .advanced finiteRandomGapIntervention0.after
  | .unusedGap => .typedRefusal .use

def suppressedGap0 : Option (Gap state0.agent) := none

theorem suppressedGap0_hasNoValue
    (gap : Gap state0.agent) :
    suppressedGap0 = some gap -> False := by
  intro equality
  cases equality

def suppressedUse0 : Option (AuthorizedUse state0.agent gap0) := none

theorem suppressedUse0_hasNoValue
    (use : AuthorizedUse state0.agent gap0) :
    suppressedUse0 = some use -> False := by
  intro equality
  cases equality

def suppressedTransport0 :
    Option (AuthorizedTransport state0.agent gap0 use0) := none

theorem suppressedTransport0_hasNoValue
    (transport : AuthorizedTransport state0.agent gap0 use0) :
    suppressedTransport0 = some transport -> False := by
  intro equality
  cases equality

def hiddenUse0 : Option (AuthorizedUse state0.agent gap0) := none

theorem hiddenUse0_hasNoValue
    (use : AuthorizedUse state0.agent gap0) :
    hiddenUse0 = some use -> False := by
  intro equality
  cases equality

theorem neutralQuery_not_admissible :
    QueryAdmissible state0.agent gap0 use0 transport0
      (.noInformation gap0.index) -> False :=
  noInformationQuery0_not_admissible

theorem neutralResponse_not_indexedByNaturalQuery :
    Query.noInformation gap0.index = query0 -> False := by
  intro equality
  cases equality

theorem everyNaturalRepair_not_keep
    (repair :
      IntrinsicRepair
        finiteData finiteGapLanguage finiteTransportLanguage
        finiteInteractionLanguage
        state0.agent gap0 use0 transport0 query0 response0)
    (neutral : repair.candidatePatch = .keep) : False := by
  have determined := finiteRepairPatch_determinedByResponse repair
  have impossible : repair0.candidatePatch = CandidatePatch.keep :=
    determined.symm.trans neutral
  cases impossible

theorem everyNaturalRepair_not_blue
    (repair :
      IntrinsicRepair
        finiteData finiteGapLanguage finiteTransportLanguage
        finiteInteractionLanguage
        state0.agent gap0 use0 transport0 query0 response0)
    (permuted : repair.candidatePatch = .set .first .blue) : False := by
  have determined := finiteRepairPatch_determinedByResponse repair
  have impossible : repair0.candidatePatch = CandidatePatch.set .first .blue :=
    determined.symm.trans permuted
  cases impossible

theorem nextBypass_not_executeRepair :
    state0 = ActiveSemanticClosureSystem.executeRepair state0 repair0 -> False := by
  intro equality
  exact state1_differs_from_state0 equality.symm

theorem droppedHistory_not_retained :
    state1.agent.history = droppedHistoryState2.agent.history -> False := by
  intro equality
  cases equality

theorem transportOrder_indicesSeparated :
    gap0.index = gap1.index -> False := by
  intro equality
  cases equality

theorem randomGap_isTyped :
    alternateGapThird0.index = .third ∧
      alternateGapThird0.kind = .unresolvedFiber :=
  ⟨rfl, rfl⟩

structure CompleteFiniteInterventionCertificate where
  projectionCompatible :
    knowledgeCompatible intervenedObservation0 canonicalWorld
  projectionChangesSuccessor :
    runNatural finiteSystem state0 = finiteObservationIntervention0 -> False
  gapSuppressionStops :
    ∀ gap, suppressedGap0 = some gap -> False
  gapPermutationChangesSuccessor :
    finiteNaturalOpenRun0.after = finiteGapIntervention0.after -> False
  useSuppressionStops :
    ∀ use, suppressedUse0 = some use -> False
  usePermutationChangesDirection :
    finiteNaturalOpenRun0.use.direction =
      finiteUseIntervention0.use.direction -> False
  transportSuppressionStops :
    ∀ transport, suppressedTransport0 = some transport -> False
  transportPermutationChangesQuery :
    finiteNaturalOpenRun0.query = finiteTransportIntervention0.query -> False
  neutralQueryRefused :
    QueryAdmissible state0.agent gap0 use0 transport0
      (.noInformation gap0.index) -> False
  alternateQueryChangesResponseKind :
    finiteResponseKind finiteNaturalOpenRun0.response =
      finiteResponseKind finiteConfirmQueryIntervention0.response -> False
  crossedResponseChangesSuccessor :
    finiteNaturalOpenRun0.after =
      finiteCrossedResponseIntervention0.after -> False
  neutralResponseRefused : Query.noInformation gap0.index = query0 -> False
  neutralRepairRefused :
    ∀ repair :
      IntrinsicRepair
        finiteData finiteGapLanguage finiteTransportLanguage
        finiteInteractionLanguage
        state0.agent gap0 use0 transport0 query0 response0,
      repair.candidatePatch = .keep -> False
  permutedRepairRefused :
    ∀ repair :
      IntrinsicRepair
        finiteData finiteGapLanguage finiteTransportLanguage
        finiteInteractionLanguage
        state0.agent gap0 use0 transport0 query0 response0,
      repair.candidatePatch = .set .first .blue -> False
  nextBypassRefused :
    state0 = ActiveSemanticClosureSystem.executeRepair state0 repair0 -> False
  historyDropDetected :
    state1.agent.history = droppedHistoryState2.agent.history -> False
  orderSwapRefused : gap0.index = gap1.index -> False
  randomGapTyped :
    alternateGapThird0.index = .third ∧
      alternateGapThird0.kind = .unresolvedFiber
  unusedGapStops : ∀ use, hiddenUse0 = some use -> False

def completeFiniteInterventionCertificate :
    CompleteFiniteInterventionCertificate where
  projectionCompatible := intervenedObservation0_compatible
  projectionChangesSuccessor := finiteObservationIntervention_changesSuccessor
  gapSuppressionStops := suppressedGap0_hasNoValue
  gapPermutationChangesSuccessor := finiteGapIntervention_changesSuccessor
  useSuppressionStops := suppressedUse0_hasNoValue
  usePermutationChangesDirection := finiteUseIntervention_changesDirection
  transportSuppressionStops := suppressedTransport0_hasNoValue
  transportPermutationChangesQuery := finiteTransportIntervention_changesQuery
  neutralQueryRefused := neutralQuery_not_admissible
  alternateQueryChangesResponseKind :=
    finiteQueryIntervention_changesResponseKind
  crossedResponseChangesSuccessor := finiteCrossedResponse_changesSuccessor
  neutralResponseRefused := neutralResponse_not_indexedByNaturalQuery
  neutralRepairRefused := everyNaturalRepair_not_keep
  permutedRepairRefused := everyNaturalRepair_not_blue
  nextBypassRefused := nextBypass_not_executeRepair
  historyDropDetected := droppedHistory_not_retained
  orderSwapRefused := transportOrder_indicesSeparated
  randomGapTyped := randomGap_isTyped
  unusedGapStops := hiddenUse0_hasNoValue

end FiniteInterventionMatrix
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.FiniteInterventionMatrix.outcome
#print axioms Meta.ActiveSemanticClosure.FiniteInterventionMatrix.everyNaturalRepair_not_keep
#print axioms Meta.ActiveSemanticClosure.FiniteInterventionMatrix.nextBypass_not_executeRepair
#print axioms Meta.ActiveSemanticClosure.FiniteInterventionMatrix.droppedHistory_not_retained
#print axioms Meta.ActiveSemanticClosure.FiniteInterventionMatrix.completeFiniteInterventionCertificate
/- AXIOM_AUDIT_END -/
