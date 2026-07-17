import Meta.AI.AIFoundationalValidation

/-!
# Certified repair of aliased latent continuations

This module closes the logical chain that motivates the publication artifact:

* a visible representation aliases two latent situations requiring separated
  continuations;
* no decision rule factored through that representation can be correct on both;
* an admissible selected query returns separated responses on compatible worlds;
* the resulting intrinsic repair strictly reduces the compatible-world fiber;
* certified gap closure restores local sufficiency, both epistemically and in
  the actual world;
* the finite instance terminates, while the open instance makes constructive
  progress at every finite stage.

All results are constructive.  The concrete certificates are computed from the
finite and open active-semantic-closure systems; no terminal oracle or external
closure bridge is assumed.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace LatentRepair

universe u v w

/-! ## Information necessity under continuation aliasing -/

/-- Two hidden situations are aliased when they have one visible code but
require separated decisions. -/
structure ContinuationAliasing
    (Hidden : Type u)
    (Visible : Type v)
    (Decision : Type w)
    (encode : Hidden -> Visible)
    (required : Hidden -> Decision) where
  left : Hidden
  right : Hidden
  sameVisible : encode left = encode right
  requiredSeparated : required left = required right -> False

/-- A decision rule that only sees the aliased representation cannot be
correct on both hidden situations. -/
theorem continuationAliasing_informationNecessity
    {Hidden : Type u}
    {Visible : Type v}
    {Decision : Type w}
    {encode : Hidden -> Visible}
    {required : Hidden -> Decision}
    (aliasing : ContinuationAliasing Hidden Visible Decision encode required)
    (rule : Visible -> Decision)
    (leftCorrect : rule (encode aliasing.left) = required aliasing.left)
    (rightCorrect : rule (encode aliasing.right) = required aliasing.right) :
    False :=
  aliasing.requiredSeparated
    (leftCorrect.symm.trans
      ((congrArg rule aliasing.sameVisible).trans rightCorrect))

/-! ## Semantic aliasing and restoration of local sufficiency -/

/-- A compatible-world fiber aliases a continuation at `index` when it
contains two worlds with separated semantic targets. -/
structure LatentAliasing
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I)
    (view : AgentClosureState D)
    (index : D.VisibleIndex) where
  leftWorld : D.SemanticWorld
  rightWorld : D.SemanticWorld
  leftCompatible : system.CompatibleWithViewHistory view leftWorld
  rightCompatible : system.CompatibleWithViewHistory view rightWorld
  targetsSeparated :
    D.evaluate leftWorld index = D.evaluate rightWorld index -> False

/-- Aliasing is exactly an obstruction to target determinacy on the current
compatible-world fiber. -/
theorem latentAliasing_refutesFiberDeterminacy
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    {view : AgentClosureState D}
    {index : D.VisibleIndex}
    (aliasing : LatentAliasing system view index)
    (determinate : FiberDeterminateAt system view index) : False :=
  aliasing.targetsSeparated
    (determinate aliasing.leftWorld aliasing.rightWorld
      aliasing.leftCompatible aliasing.rightCompatible)

/-- A candidate cannot be known correct at an aliased index.  This is the
semantic information-necessity theorem used by both concrete models. -/
theorem latentAliasing_informationNecessity
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    {view : AgentClosureState D}
    {candidate : D.Candidate}
    {index : D.VisibleIndex}
    (aliasing : LatentAliasing system view index)
    (knownCorrect : KnownCorrectAt system view candidate index) : False :=
  latentAliasing_refutesFiberDeterminacy aliasing
    (fiberDeterminateAt_of_knownCorrectAt knownCorrect)

/-- Local sufficiency after repair comprises epistemic correctness, target
determinacy, and correctness in the actual compatible world. -/
structure RestoredLocalSufficiency
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D)
    (index : D.VisibleIndex) : Prop where
  actualCompatible :
    system.CompatibleWithViewHistory state.agent state.world
  knownCorrect :
    KnownCorrectAt system state.agent state.agent.candidate index
  fiberDeterminate : FiberDeterminateAt system state.agent index
  actualCorrect : CorrectAt D state.world state.agent.candidate index

/-- Certified closure of a gap constructively restores local sufficiency at
the exact index carried by that gap. -/
def closureRestoresLocalSufficiency
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    {before after : ActiveSemanticClosureState D}
    {gap : OperationalGap D G before.agent}
    (closure : GapClosedBy system before gap after) :
    RestoredLocalSufficiency system after gap.index where
  actualCompatible := closure.actualCompatible
  knownCorrect := closure.knownCorrect
  fiberDeterminate := fiberDeterminateAt_of_knownCorrectAt closure.knownCorrect
  actualCorrect :=
    correctAt_of_knownCorrectAt closure.knownCorrect closure.actualCompatible

/-- Once the gap is closed, the repaired fiber can no longer alias the target
at the repaired index. -/
theorem closureRefutesPostRepairAliasing
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    {system : ActiveSemanticClosureSystem D G T I}
    {before after : ActiveSemanticClosureState D}
    {gap : OperationalGap D G before.agent}
    (closure : GapClosedBy system before gap after)
    (aliasingAfter : LatentAliasing system after.agent gap.index) : False :=
  latentAliasing_informationNecessity aliasingAfter closure.knownCorrect

/-! ## Informative queries and strict fiber reduction -/

/-- The query selected by the system is strictly informative when two worlds
compatible with the same current view produce separated responses. -/
structure SelectedQueryInformative
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I)
    (state : ActiveSemanticClosureState D)
    (gap : OperationalGap D G state.agent) where
  leftWorld : D.SemanticWorld
  rightWorld : D.SemanticWorld
  leftCompatible :
    system.CompatibleWithViewHistory state.agent leftWorld
  rightCompatible :
    system.CompatibleWithViewHistory state.agent rightWorld
  responsesSeparated :
    system.respond leftWorld
        (system.selectQuery
          (system.executeTransport state.agent gap
            (system.authorize state.agent gap))) =
      system.respond rightWorld
        (system.selectQuery
          (system.executeTransport state.agent gap
            (system.authorize state.agent gap))) -> False

/-- A strict reduction is inclusion of the later compatible fiber in the
earlier fiber together with a constructive witness eliminated by the repair. -/
structure CompatibleFiberStrictlyReduces
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I)
    (before after : ActiveSemanticClosureState D) where
  laterImpliesEarlier :
    ∀ world,
      system.CompatibleWithViewHistory after.agent world ->
      system.CompatibleWithViewHistory before.agent world
  eliminatedWorld : D.SemanticWorld
  compatibleBefore :
    system.CompatibleWithViewHistory before.agent eliminatedWorld
  incompatibleAfter :
    system.CompatibleWithViewHistory after.agent eliminatedWorld -> False

/-- One complete certified repair step, from alias detection through restored
local sufficiency. -/
structure CertifiedLatentRepairStep
    {D : ActiveClosureData.{u}}
    {G : ActiveClosureGapLanguage.{u, v} D}
    {T : ActiveClosureTransportLanguage.{u, v} D G}
    {I : ActiveClosureInteractionLanguage.{u, v} D G T}
    (system : ActiveSemanticClosureSystem D G T I)
    (realization : GapEvidenceRealization system)
    (before after : ActiveSemanticClosureState D)
    (gap : OperationalGap D G before.agent) where
  detected : system.detectGap before.agent = .open gap
  typedGap : TypedSemanticGap system realization before gap
  aliasingBefore : LatentAliasing system before.agent gap.index
  selectedQueryInformative : SelectedQueryInformative system before gap
  successorIntrinsic : after = system.nextState before
  strictFiberReduction : CompatibleFiberStrictlyReduces system before after
  gapClosed : GapClosedBy system before gap after
  restoredSufficiency : RestoredLocalSufficiency system after gap.index
  postRepairAliasingImpossible :
    LatentAliasing system after.agent gap.index -> False

/-! ## Exact finite certificates -/

open Finite

def finiteAliasing0 : LatentAliasing finiteSystem state0.agent gap0.index where
  leftWorld := canonicalWorld
  rightWorld := firstEliminatedWorld
  leftCompatible := state0_actualCompatible
  rightCompatible := state0_to_state1_strictFiberReduction.compatibleBefore
  targetsSeparated := by
    intro equality
    cases equality

def finiteAliasing1 : LatentAliasing finiteSystem state1.agent gap1.index where
  leftWorld := canonicalWorld
  rightWorld := secondFiberAlternative
  leftCompatible := state1_actualCompatible
  rightCompatible := secondFiberAlternative_compatible
  targetsSeparated := by
    intro equality
    cases equality

def finiteAliasing2 : LatentAliasing finiteSystem state2.agent gap2.index where
  leftWorld := canonicalWorld
  rightWorld := thirdFiberAlternative
  leftCompatible := state2_actualCompatible
  rightCompatible := thirdFiberAlternative_compatible
  targetsSeparated := by
    intro equality
    cases equality

def finiteSelectedQueryInformative0 :
    SelectedQueryInformative finiteSystem state0 gap0 where
  leftWorld := selectedQuery0_splitsCompatibleFiber.leftWorld
  rightWorld := selectedQuery0_splitsCompatibleFiber.rightWorld
  leftCompatible := selectedQuery0_splitsCompatibleFiber.leftCompatible
  rightCompatible := selectedQuery0_splitsCompatibleFiber.rightCompatible
  responsesSeparated := selectedQuery0_splitsCompatibleFiber.responsesSeparated

def finiteSelectedQueryInformative1 :
    SelectedQueryInformative finiteSystem state1 gap1 where
  leftWorld := selectedQuery1_splitsCompatibleFiber.leftWorld
  rightWorld := selectedQuery1_splitsCompatibleFiber.rightWorld
  leftCompatible := selectedQuery1_splitsCompatibleFiber.leftCompatible
  rightCompatible := selectedQuery1_splitsCompatibleFiber.rightCompatible
  responsesSeparated := selectedQuery1_splitsCompatibleFiber.responsesSeparated

def finiteSelectedQueryInformative2 :
    SelectedQueryInformative finiteSystem state2 gap2 where
  leftWorld := selectedQuery2_splitsCompatibleFiber.leftWorld
  rightWorld := selectedQuery2_splitsCompatibleFiber.rightWorld
  leftCompatible := selectedQuery2_splitsCompatibleFiber.leftCompatible
  rightCompatible := selectedQuery2_splitsCompatibleFiber.rightCompatible
  responsesSeparated := selectedQuery2_splitsCompatibleFiber.responsesSeparated

def finiteStrictReduction0 :
    CompatibleFiberStrictlyReduces finiteSystem state0 state1 where
  laterImpliesEarlier :=
    state0_to_state1_strictFiberReduction.laterImpliesEarlier
  eliminatedWorld :=
    state0_to_state1_strictFiberReduction.eliminatedWorld
  compatibleBefore :=
    state0_to_state1_strictFiberReduction.compatibleBefore
  incompatibleAfter :=
    state0_to_state1_strictFiberReduction.incompatibleAfter

def finiteStrictReduction1 :
    CompatibleFiberStrictlyReduces finiteSystem state1 state2 where
  laterImpliesEarlier :=
    state1_to_state2_strictFiberReduction.laterImpliesEarlier
  eliminatedWorld :=
    state1_to_state2_strictFiberReduction.eliminatedWorld
  compatibleBefore :=
    state1_to_state2_strictFiberReduction.compatibleBefore
  incompatibleAfter :=
    state1_to_state2_strictFiberReduction.incompatibleAfter

def finiteStrictReduction2 :
    CompatibleFiberStrictlyReduces finiteSystem state2 state3 where
  laterImpliesEarlier :=
    state2_to_state3_strictFiberReduction.laterImpliesEarlier
  eliminatedWorld :=
    state2_to_state3_strictFiberReduction.eliminatedWorld
  compatibleBefore :=
    state2_to_state3_strictFiberReduction.compatibleBefore
  incompatibleAfter :=
    state2_to_state3_strictFiberReduction.incompatibleAfter

def finiteCertifiedLatentRepair0 :
    CertifiedLatentRepairStep
      finiteSystem finiteEvidenceRealization state0 state1 gap0 where
  detected := state0_detects_gap0
  typedGap := typedGap0
  aliasingBefore := finiteAliasing0
  selectedQueryInformative := finiteSelectedQueryInformative0
  successorIntrinsic := rfl
  strictFiberReduction := finiteStrictReduction0
  gapClosed := gap0ClosedByState1
  restoredSufficiency := closureRestoresLocalSufficiency gap0ClosedByState1
  postRepairAliasingImpossible :=
    closureRefutesPostRepairAliasing gap0ClosedByState1

def finiteCertifiedLatentRepair1 :
    CertifiedLatentRepairStep
      finiteSystem finiteEvidenceRealization state1 state2 gap1 where
  detected := state1_detects_gap1
  typedGap := typedGap1
  aliasingBefore := finiteAliasing1
  selectedQueryInformative := finiteSelectedQueryInformative1
  successorIntrinsic := rfl
  strictFiberReduction := finiteStrictReduction1
  gapClosed := gap1ClosedByState2
  restoredSufficiency := closureRestoresLocalSufficiency gap1ClosedByState2
  postRepairAliasingImpossible :=
    closureRefutesPostRepairAliasing gap1ClosedByState2

def finiteCertifiedLatentRepair2 :
    CertifiedLatentRepairStep
      finiteSystem finiteEvidenceRealization state2 state3 gap2 where
  detected := state2_detects_gap2
  typedGap := typedGap2
  aliasingBefore := finiteAliasing2
  selectedQueryInformative := finiteSelectedQueryInformative2
  successorIntrinsic := rfl
  strictFiberReduction := finiteStrictReduction2
  gapClosed := gap2ClosedByState3
  restoredSufficiency := closureRestoresLocalSufficiency gap2ClosedByState3
  postRepairAliasingImpossible :=
    closureRefutesPostRepairAliasing gap2ClosedByState3

/-! ## Exact open-orbit certificates -/

open Open

/-- Boolean payload of an open response, used to expose response separation
without any classical constructor reasoning. -/
def openResponseValue
    {index : Nat}
    {query : OpenQuery index} : OpenResponse query -> Bool
  | .revealed value => value

def openAliasingAt (stage : Nat) :
    LatentAliasing openSystem
      (openStateAt stage).agent
      (freshGap (openStateAt stage).agent).index where
  leftWorld := completionWorld (openStateAt stage).agent.candidate false
  rightWorld := completionWorld (openStateAt stage).agent.candidate true
  leftCompatible := completionCompatibleWithView (openStateAt stage).agent false
  rightCompatible := completionCompatibleWithView (openStateAt stage).agent true
  targetsSeparated :=
    completionWorlds_separatedAtFresh (openStateAt stage).agent.candidate

def openSelectedQueryInformativeAt (stage : Nat) :
    SelectedQueryInformative openSystem
      (openStateAt stage) (freshGap (openStateAt stage).agent) where
  leftWorld := completionWorld (openStateAt stage).agent.candidate false
  rightWorld := completionWorld (openStateAt stage).agent.candidate true
  leftCompatible := completionCompatibleWithView (openStateAt stage).agent false
  rightCompatible := completionCompatibleWithView (openStateAt stage).agent true
  responsesSeparated := by
    intro equality
    have responseValueEquality := congrArg openResponseValue equality
    have targetEquality :
        openEvaluate
            (completionWorld (openStateAt stage).agent.candidate false)
            (openStateAt stage).agent.candidate.values.length =
          openEvaluate
            (completionWorld (openStateAt stage).agent.candidate true)
            (openStateAt stage).agent.candidate.values.length := by
      exact responseValueEquality
    exact
      completionWorlds_separatedAtFresh
        (openStateAt stage).agent.candidate targetEquality

def openStrictFiberReductionAt (stage : Nat) :
    CompatibleFiberStrictlyReduces openSystem
      (openStateAt stage) (openStateAt (stage + 1)) where
  laterImpliesEarlier := by
    intro world later index value found
    apply later index value
    change
      lookupBool
          (openSystem.nextState (openStateAt stage)).agent.candidate.values
          index = some value
    rw [openSystem_next_candidate]
    exact lookupBool_append_existing found _
  eliminatedWorld :=
    completionWorld (openStateAt stage).agent.candidate true
  compatibleBefore :=
    completionCompatibleWithView (openStateAt stage).agent true
  incompatibleAfter := by
    intro compatible
    let freshIndex := (openStateAt stage).agent.candidate.values.length
    have learnedLookup :
        lookupBool (openStateAt (stage + 1)).agent.candidate.values
            freshIndex = some false := by
      change
        lookupBool
            (openSystem.nextState (openStateAt stage)).agent.candidate.values
            freshIndex = some false
      rw [openSystem_next_candidate, openStateAt_world]
      exact lookupBool_append_new _ false
    have forcedFalse :
        (completionWorld (openStateAt stage).agent.candidate true).valueAt
            freshIndex = false :=
      compatible freshIndex false learnedLookup
    have actuallyTrue :
        (completionWorld (openStateAt stage).agent.candidate true).valueAt
            freshIndex = true := by
      dsimp [freshIndex]
      unfold completionWorld
      change
        (match
            lookupBool (openStateAt stage).agent.candidate.values
              (openStateAt stage).agent.candidate.values.length with
          | some value => value
          | none =>
              if
                (openStateAt stage).agent.candidate.values.length =
                  (openStateAt stage).agent.candidate.values.length
              then true
              else false) = true
      rw [lookupBool_length, if_pos rfl]
    have impossible : true = false := actuallyTrue.symm.trans forcedFalse
    cases impossible

def openCertifiedLatentRepairAt (stage : Nat) :
    CertifiedLatentRepairStep
      openSystem openEvidenceRealization
      (openStateAt stage) (openStateAt (stage + 1))
      (freshGap (openStateAt stage).agent) where
  detected := openOrbit_hasFreshGap stage
  typedGap := openTypedGapAt stage
  aliasingBefore := openAliasingAt stage
  selectedQueryInformative := openSelectedQueryInformativeAt stage
  successorIntrinsic := rfl
  strictFiberReduction := openStrictFiberReductionAt stage
  gapClosed := openGapClosedByNext stage
  restoredSufficiency :=
    closureRestoresLocalSufficiency (openGapClosedByNext stage)
  postRepairAliasingImpossible :=
    closureRefutesPostRepairAliasing (openGapClosedByNext stage)

/-! ## Publication-level aggregate -/

open Certified
open Validation

/-- The aggregate theorem exposed by the standalone publication artifact.
It combines the new aliasing-to-sufficiency bridge with the exact finite run,
the constructive open orbit, foundational conservativity, no-go results, and
the exhaustive quantized semantic certificate. -/
structure CertifiedLatentRepairPublication where
  finiteFirst :
    CertifiedLatentRepairStep
      finiteSystem finiteEvidenceRealization state0 state1 gap0
  finiteSecond :
    CertifiedLatentRepairStep
      finiteSystem finiteEvidenceRealization state1 state2 gap1
  finiteThird :
    CertifiedLatentRepairStep
      finiteSystem finiteEvidenceRealization state2 state3 gap2
  finiteTerminalClosed : ClosedOnAll state3.world state3.agent.candidate
  finiteTerminalKnown : KnownClosedOnAll state3.agent
  finiteTerminalStable : finiteSystem.nextState state3 = state3
  finiteCumulativeNonRegression : RepairPrefixCertificate
  finiteStrictGapMeasure : LeanValidation.FiniteMeasureClosureCertificate
  openRepairAt :
    ∀ stage,
      CertifiedLatentRepairStep
        openSystem openEvidenceRealization
        (openStateAt stage) (openStateAt (stage + 1))
        (freshGap (openStateAt stage).agent)
  openProgressAt :
    ∀ stage,
      openSystem.nextState (openStateAt stage) = openStateAt stage -> False
  openCurrentGapClosed :
    ∀ stage,
      GapClosedBy openSystem (openStateAt stage)
        (freshGap (openStateAt stage).agent)
        (openStateAt (stage + 1))
  openNeverGloballyClosedAtFiniteStage :
    ∀ stage,
      GloballyClosed openData
          (openStateAt stage).world (openStateAt stage).agent.candidate -> False
  openCumulativeNonRegression :
    ∀ stage index value,
      lookupBool (openStateAt stage).agent.candidate.values index = some value ->
      lookupBool
          (openStateAt (stage + 1)).agent.candidate.values index = some value ∧
        KnownCorrectAt openSystem
          (openStateAt (stage + 1)).agent
          (openStateAt (stage + 1)).agent.candidate index
  visibleAndPassiveNoGo : NoGo.AIClosureNoGoCertificate
  foundationalValidation : AIFoundationalValidation
  quantizedSemanticExecution :
    QuantizedCertified.SemanticallyClosedCertifiedRun

def certifiedLatentRepairPublication : CertifiedLatentRepairPublication where
  finiteFirst := finiteCertifiedLatentRepair0
  finiteSecond := finiteCertifiedLatentRepair1
  finiteThird := finiteCertifiedLatentRepair2
  finiteTerminalClosed := state3_actualClosed
  finiteTerminalKnown := state3_knownClosed
  finiteTerminalStable := state3_is_stable
  finiteCumulativeNonRegression := repair_preserves_closedPrefix
  finiteStrictGapMeasure := LeanValidation.finiteMeasureClosureCertificate
  openRepairAt := openCertifiedLatentRepairAt
  openProgressAt := openOrbit_transitionEffective
  openCurrentGapClosed := openGapClosedByNext
  openNeverGloballyClosedAtFiniteStage := openOrbit_notGloballyClosed
  openCumulativeNonRegression := openRepair_preservesKnownPrefix
  visibleAndPassiveNoGo := NoGo.aiClosureNoGoCertificate
  foundationalValidation := aiFoundationalValidation
  quantizedSemanticExecution :=
    QuantizedCertified.semanticallyClosedCertifiedRun

end LatentRepair
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.LatentRepair.continuationAliasing_informationNecessity
#print axioms Meta.ActiveSemanticClosure.LatentRepair.latentAliasing_informationNecessity
#print axioms Meta.ActiveSemanticClosure.LatentRepair.closureRestoresLocalSufficiency
#print axioms Meta.ActiveSemanticClosure.LatentRepair.closureRefutesPostRepairAliasing
#print axioms Meta.ActiveSemanticClosure.LatentRepair.finiteCertifiedLatentRepair0
#print axioms Meta.ActiveSemanticClosure.LatentRepair.finiteCertifiedLatentRepair1
#print axioms Meta.ActiveSemanticClosure.LatentRepair.finiteCertifiedLatentRepair2
#print axioms Meta.ActiveSemanticClosure.LatentRepair.openStrictFiberReductionAt
#print axioms Meta.ActiveSemanticClosure.LatentRepair.openCertifiedLatentRepairAt
#print axioms Meta.ActiveSemanticClosure.LatentRepair.certifiedLatentRepairPublication
/- AXIOM_AUDIT_END -/
