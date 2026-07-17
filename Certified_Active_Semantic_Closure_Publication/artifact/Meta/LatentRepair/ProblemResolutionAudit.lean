import Meta.LatentRepair.CertifiedLatentRepair

/-!
# Machine-checked audit of the planned latent-repair problem

This module restates the publication obligations as one independent typed
checklist.  Its inhabitant is assembled only from the generic bridge theorems
and the exact finite/open certificates.  It makes the scope boundary explicit:
generic information necessity and closure-to-sufficiency, plus complete
certificates for every stage of the two published trajectories.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace LatentRepair

universe u v w

open Finite
open Open
open Certified
open Validation

/-- Exact formal checklist corresponding to the problem statement shipped with
the publication artifact. -/
structure PlannedProblemResolutionAudit where
  genericVisibleInformationNecessity :
    {Hidden : Type u} ->
    {Visible : Type v} ->
    {Decision : Type w} ->
    {encode : Hidden -> Visible} ->
    {required : Hidden -> Decision} ->
    (aliasing :
      ContinuationAliasing Hidden Visible Decision encode required) ->
    (rule : Visible -> Decision) ->
    rule (encode aliasing.left) = required aliasing.left ->
    rule (encode aliasing.right) = required aliasing.right ->
    False
  genericSemanticInformationNecessity :
    {D : ActiveClosureData.{u}} ->
    {G : ActiveClosureGapLanguage.{u, v} D} ->
    {T : ActiveClosureTransportLanguage.{u, v} D G} ->
    {I : ActiveClosureInteractionLanguage.{u, v} D G T} ->
    {system : ActiveSemanticClosureSystem D G T I} ->
    {view : AgentClosureState D} ->
    {candidate : D.Candidate} ->
    {index : D.VisibleIndex} ->
    LatentAliasing system view index ->
    KnownCorrectAt system view candidate index ->
    False
  genericClosureRestoresSufficiency :
    {D : ActiveClosureData.{u}} ->
    {G : ActiveClosureGapLanguage.{u, v} D} ->
    {T : ActiveClosureTransportLanguage.{u, v} D G} ->
    {I : ActiveClosureInteractionLanguage.{u, v} D G T} ->
    {system : ActiveSemanticClosureSystem D G T I} ->
    {before after : ActiveSemanticClosureState D} ->
    {gap : OperationalGap D G before.agent} ->
    GapClosedBy system before gap after ->
    RestoredLocalSufficiency system after gap.index
  finiteFirstComplete :
    CertifiedLatentRepairStep
      finiteSystem finiteEvidenceRealization state0 state1 gap0
  finiteSecondComplete :
    CertifiedLatentRepairStep
      finiteSystem finiteEvidenceRealization state1 state2 gap1
  finiteThirdComplete :
    CertifiedLatentRepairStep
      finiteSystem finiteEvidenceRealization state2 state3 gap2
  finiteCumulativeNonRegression : RepairPrefixCertificate
  finiteReachesActionSufficiency : KnownClosedOnAll state3.agent
  finiteReachesActualClosure : ClosedOnAll state3.world state3.agent.candidate
  finiteTerminalDetector : finiteSystem.detectGap state3.agent = .closed
  finiteTerminalStasis : finiteSystem.nextState state3 = state3
  finiteInternalDecrease : LeanValidation.FiniteMeasureClosureCertificate
  openEveryStageComplete :
    ∀ stage,
      CertifiedLatentRepairStep
        openSystem openEvidenceRealization
        (openStateAt stage) (openStateAt (stage + 1))
        (freshGap (openStateAt stage).agent)
  openEveryCurrentGapClosed :
    ∀ stage,
      GapClosedBy openSystem
        (openStateAt stage)
        (freshGap (openStateAt stage).agent)
        (openStateAt (stage + 1))
  openCumulativeNonRegression :
    ∀ stage index value,
      lookupBool (openStateAt stage).agent.candidate.values index = some value ->
      lookupBool
          (openStateAt (stage + 1)).agent.candidate.values index = some value ∧
        KnownCorrectAt openSystem
          (openStateAt (stage + 1)).agent
          (openStateAt (stage + 1)).agent.candidate index
  openEveryTransitionEffective :
    ∀ stage,
      openSystem.nextState (openStateAt stage) = openStateAt stage -> False
  openNoFalseFiniteTerminal :
    ∀ stage,
      GloballyClosed openData
          (openStateAt stage).world
          (openStateAt stage).agent.candidate -> False
  visibleAndPassiveInformationNoGo : NoGo.AIClosureNoGoCertificate
  foundationalConservativityAndSoundness : AIFoundationalValidation
  quantizedCatalogueSemanticRefinement :
    QuantizedCertified.SemanticallyClosedCertifiedRun

/-- Kernel-checked verdict for the exact problem scope claimed by the paper. -/
def plannedProblemResolutionAudit : PlannedProblemResolutionAudit where
  genericVisibleInformationNecessity :=
    continuationAliasing_informationNecessity
  genericSemanticInformationNecessity :=
    latentAliasing_informationNecessity
  genericClosureRestoresSufficiency :=
    closureRestoresLocalSufficiency
  finiteFirstComplete := finiteCertifiedLatentRepair0
  finiteSecondComplete := finiteCertifiedLatentRepair1
  finiteThirdComplete := finiteCertifiedLatentRepair2
  finiteCumulativeNonRegression := repair_preserves_closedPrefix
  finiteReachesActionSufficiency := state3_knownClosed
  finiteReachesActualClosure := state3_actualClosed
  finiteTerminalDetector := state3_is_closed
  finiteTerminalStasis := state3_is_stable
  finiteInternalDecrease := LeanValidation.finiteMeasureClosureCertificate
  openEveryStageComplete := openCertifiedLatentRepairAt
  openEveryCurrentGapClosed := openGapClosedByNext
  openCumulativeNonRegression := openRepair_preservesKnownPrefix
  openEveryTransitionEffective := openOrbit_transitionEffective
  openNoFalseFiniteTerminal := openOrbit_notGloballyClosed
  visibleAndPassiveInformationNoGo := NoGo.aiClosureNoGoCertificate
  foundationalConservativityAndSoundness := aiFoundationalValidation
  quantizedCatalogueSemanticRefinement :=
    QuantizedCertified.semanticallyClosedCertifiedRun

end LatentRepair
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.LatentRepair.plannedProblemResolutionAudit
/- AXIOM_AUDIT_END -/
