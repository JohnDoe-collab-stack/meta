import Meta.Core.DynamicRelaxedUsage
import Meta.Core.TransportCoherence
import Meta.Tarski.TruthGap

/-!
# Dynamic relaxed usage for patchable Tarski candidates

This module connects the positive, syntax-level patch algorithm already
defined in `TruthGap` to the intrinsic gap-driven dynamic usage system.  It does
not replace the refutable `TarskiDiagonalReturnSource`: the latter factors a
globally exact truth claim, while this module evolves arbitrary syntactic
candidates from their local diagonal mismatch.
-/

namespace Meta
namespace TarskiDynamicRelaxedUsage

universe u v

open ClosedStabilityTheorem
open DynamicRelaxedUsage
open RelaxedUsageRegime

/-- The single processing branch is named and distinct from the source type. -/
inductive TarskiPatchBranch where
  | causal

/-! ## Four distinct bilateral packages -/

/-- Complete data retain the whole canonical algorithmic step. -/
structure TarskiPatchComplete
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (_branch : TarskiPatchBranch) where
  current : patchable.context.Predicate
  step : patchable.AlgorithmStep current

/-- Forward data expose the diagonal challenge and fixed point. -/
structure TarskiPatchForward
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (_branch : TarskiPatchBranch) where
  current : patchable.context.Predicate
  diagonalSentence : patchable.context.Sentence
  fixedPoint :
    TarskiDiagonalFixedPoint
      patchable.context.Sentence
      (patchable.truthAt current)
      patchable.context.models
  diagonalSentence_eq :
    diagonalSentence = patchable.diagonalSentence current

/-- Backward data expose the internal syntax-level repair. -/
structure TarskiPatchBackward
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (_branch : TarskiPatchBranch) where
  current : patchable.context.Predicate
  diagonalSentence : patchable.context.Sentence
  nextPredicate : patchable.context.Predicate
  nextPredicate_eq :
    nextPredicate = patchable.patchPredicate current diagonalSentence
  repaired_index_agreement :
    patchable.truthAt nextPredicate diagonalSentence ↔
      patchable.context.models diagonalSentence

/-- The typed intersection retains mismatch, repair, and the next candidate. -/
structure TarskiPatchIntersection
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (_branch : TarskiPatchBranch) where
  current : patchable.context.Predicate
  step : patchable.AlgorithmStep current

/-- Bilateral views of one patch step, with no aliasing of the four families. -/
def tarskiPatchCompleteness
    (patchable : PatchableArithmeticTarskiContext.{u, v}) :
    BidirectionalCompleteness TarskiPatchBranch where
  Complete := TarskiPatchComplete patchable
  Forward := TarskiPatchForward patchable
  Backward := TarskiPatchBackward patchable
  Intersection := TarskiPatchIntersection patchable
  forwardOfComplete := by
    intro branch complete
    exact
      { current := complete.current
        diagonalSentence := complete.step.diagonalSentence
        fixedPoint := complete.step.fixedPoint
        diagonalSentence_eq := complete.step.diagonalSentence_eq }
  backwardOfComplete := by
    intro branch complete
    exact
      { current := complete.current
        diagonalSentence := complete.step.diagonalSentence
        nextPredicate := complete.step.nextPredicate
        nextPredicate_eq := complete.step.nextPredicate_eq_patch
        repaired_index_agreement :=
          complete.step.repaired_index_agreement }
  intersectionOfComplete := fun _ complete =>
    { current := complete.current
      step := complete.step }
  completeOfIntersection := fun _ intersection =>
    { current := intersection.current
      step := intersection.step }

/-- Both round trips preserve the complete proof-relevant step. -/
def tarskiPatchRoundTripCoherence
    (patchable : PatchableArithmeticTarskiContext.{u, v}) :
    RoundTripCoherence (tarskiPatchCompleteness patchable) where
  completeRoundTrip :=
    { complete_stable := by
        intro branch complete
        cases complete
        rfl }
  intersectionRoundTrip :=
    { intersection_stable := by
        intro branch intersection
        cases intersection
        rfl }

/-! ## Witness and executable repair -/

/-- A formed-interface witness retains the candidate and diagonal step. -/
structure TarskiPatchInterfaceWitness
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (interface : TarskiInterface patchable.context.Sentence) where
  current : patchable.context.Predicate
  step : patchable.AlgorithmStep current
  interface_eq :
    interface = TarskiInterface.semantic step.diagonalSentence

/-- Realization ties the cycle intersection to its semantic diagonal pole. -/
structure TarskiPatchRealizesInterface
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (cycle :
      StrongTerminalCycleFromIntersection
        (tarskiPatchCompleteness patchable)
        TarskiPatchBranch.causal)
    (interface : TarskiInterface patchable.context.Sentence) :
    Type (max u v) where
  interface_eq :
    interface =
      TarskiInterface.semantic
        cycle.sourceIntersection.step.diagonalSentence

/--
An indexed repair carries both local interface recovery and the next syntactic
candidate generated by the mismatch.
-/
structure TarskiPatchRepair
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (interface : TarskiInterface patchable.context.Sentence) where
  current : patchable.context.Predicate
  step : patchable.AlgorithmStep current
  interface_eq :
    interface = TarskiInterface.semantic step.diagonalSentence

/-- Execute the local interface side of a Tarski patch repair. -/
def TarskiPatchRepair.applyInterface
    {patchable : PatchableArithmeticTarskiContext.{u, v}}
    {interface : TarskiInterface patchable.context.Sentence}
    (repair : TarskiPatchRepair patchable interface) :
    TarskiInterface patchable.context.Sentence :=
  TarskiInterface.semantic repair.step.diagonalSentence

/-- Local repair returns exactly its indexed semantic interface. -/
theorem TarskiPatchRepair.applyInterface_correct
    {patchable : PatchableArithmeticTarskiContext.{u, v}}
    {interface : TarskiInterface patchable.context.Sentence}
    (repair : TarskiPatchRepair patchable interface) :
    repair.applyInterface = interface :=
  repair.interface_eq.symm

/-- Execute the causal syntax-level side of the same repair. -/
def TarskiPatchRepair.applyCandidate
    {patchable : PatchableArithmeticTarskiContext.{u, v}}
    {interface : TarskiInterface patchable.context.Sentence}
    (repair : TarskiPatchRepair patchable interface) :
    patchable.context.Predicate :=
  repair.step.nextPredicate

/-- Candidate repair is exactly the patch calculated by the stored step. -/
theorem TarskiPatchRepair.applyCandidate_eq_patch
    {patchable : PatchableArithmeticTarskiContext.{u, v}}
    {interface : TarskiInterface patchable.context.Sentence}
    (repair : TarskiPatchRepair patchable interface) :
    repair.applyCandidate =
      patchable.patchPredicate
        repair.current
        repair.step.diagonalSentence :=
  repair.step.nextPredicate_eq_patch

/-! ## Positive dynamic return at every candidate -/

/-- Canonical complete package for one candidate. -/
def tarskiPatchCompleteAt
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (current : patchable.context.Predicate) :
    TarskiPatchComplete patchable TarskiPatchBranch.causal where
  current := current
  step := patchable.step current

/-- Canonical local recovery of the two Tarski interfaces. -/
def tarskiPatchLocalRecovery
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (current : patchable.context.Predicate) :
    LocalProjectiveRecovery
      (TarskiInterface patchable.context.Sentence)
      patchable.context.Sentence
      TarskiInterface.project
      (TarskiPatchRepair patchable) :=
  let step := patchable.step current
  let repair :
      TarskiPatchRepair
        patchable
        (TarskiInterface.semantic step.diagonalSentence) :=
    { current := current
      step := step
      interface_eq := rfl }
  { formed := TarskiInterface.semantic step.diagonalSentence
    shadow := TarskiInterface.syntactic step.diagonalSentence
    sameProjection := rfl
    separated := by
      intro equality
      cases equality
    repair := repair
    recovered := repair.applyInterface
    recovered_eq_formed := repair.applyInterface_correct }

/-- The local recovery executes the interface component of its repair. -/
theorem tarskiPatchLocalRecovery_recovered_eq_apply
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (current : patchable.context.Predicate) :
    (tarskiPatchLocalRecovery patchable current).recovered =
      (tarskiPatchLocalRecovery patchable current).repair.applyInterface :=
  rfl

/-- A complete locally recovered dynamic return for every candidate. -/
def tarskiPatchLocallyRecoveredDynamicReturn
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (current : patchable.context.Predicate) :
    LocallyRecoveredDynamicReturn
      (tarskiPatchCompleteness patchable)
      (tarskiPatchRoundTripCoherence patchable)
      TarskiPatchBranch.causal
      patchable.context.Predicate
      (TarskiInterface patchable.context.Sentence)
      (TarskiPatchInterfaceWitness patchable)
      (TarskiPatchRealizesInterface patchable)
      patchable.context.Sentence
      TarskiInterface.project
      (TarskiPatchRepair patchable) :=
  let step := patchable.step current
  { formedReturn :=
      { source := current
        intersection :=
          { current := current
            step := step } }
    formed :=
      { interface := TarskiInterface.semantic step.diagonalSentence
        witness :=
          { current := current
            step := step
            interface_eq := rfl } }
    realizes :=
      { interface_eq := rfl }
    localRecovery := tarskiPatchLocalRecovery patchable current
    localRecovery_sameInterface := rfl }

/-- The return source is definitionally the current candidate. -/
theorem tarskiPatchReturn_source
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (current : patchable.context.Predicate) :
    (tarskiPatchLocallyRecoveredDynamicReturn patchable current).formedReturn.source =
      current :=
  rfl

/-- Closed return atlas generated from one initial syntactic candidate. -/
def tarskiPatchIntrinsicDynamicReturnFamily
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    IntrinsicDynamicReturnFamily
      (tarskiPatchCompleteness patchable)
      (tarskiPatchRoundTripCoherence patchable)
      TarskiPatchBranch.causal
      patchable.context.Predicate
      (TarskiInterface patchable.context.Sentence)
      (TarskiPatchInterfaceWitness patchable)
      (TarskiPatchRealizesInterface patchable)
      patchable.context.Sentence
      TarskiInterface.project
      (TarskiPatchRepair patchable) where
  initial := initial
  returnAt := tarskiPatchLocallyRecoveredDynamicReturn patchable
  returnAt_source := tarskiPatchReturn_source patchable

/-! ## Gap-driven candidate transition -/

/--
The transition must inspect the current authorized use, then execute the repair
stored by the current return.  It never receives an independent `next` map.
-/
def tarskiPatchAdvance
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    (Σ current : patchable.context.Predicate,
      DynamicGapCausalState
        (tarskiPatchIntrinsicDynamicReturnFamily patchable initial)
        current) ->
      patchable.context.Predicate := by
  intro input
  cases input with
  | mk current causalState =>
      cases causalState.memory.use.classify with
      | inl reflexive =>
          exact
            ((tarskiPatchIntrinsicDynamicReturnFamily
              patchable initial).separatedAt current reflexive.down).elim
      | inr causes =>
          cases causes.2
          exact
            ((tarskiPatchIntrinsicDynamicReturnFamily
              patchable initial).repairAt current).applyCandidate

/-- The complete gap-driven Tarski candidate system. -/
def tarskiPatchGapDrivenDynamicSystem
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    GapDrivenDynamicSystem
      (tarskiPatchIntrinsicDynamicReturnFamily patchable initial) where
  advance := tarskiPatchAdvance patchable initial

/-- The derived successor is exactly the syntax-level patch algorithm. -/
theorem tarskiPatchNext_eq_nextPredicate
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial current : patchable.context.Predicate) :
    (tarskiPatchGapDrivenDynamicSystem patchable initial).next current =
      patchable.nextPredicate current :=
  rfl

/-- Every dynamic iteration is exactly the intrinsic syntax patch iteration. -/
theorem tarskiPatchIterate_eq_iteratePredicate
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial current : patchable.context.Predicate)
    (n : Nat) :
    (tarskiPatchGapDrivenDynamicSystem patchable initial).iterateSource
        n
        current =
      patchable.iteratePredicate n current := by
  induction n with
  | zero =>
      rfl
  | succ n inductionHypothesis =>
      change
        (tarskiPatchGapDrivenDynamicSystem patchable initial).next
            ((tarskiPatchGapDrivenDynamicSystem patchable initial).iterateSource
              n
              current) =
          patchable.nextPredicate
            (patchable.iteratePredicate n current)
      exact
        (congrArg
          (tarskiPatchGapDrivenDynamicSystem patchable initial).next
          inductionHypothesis).trans
            (tarskiPatchNext_eq_nextPredicate
              patchable
              initial
              (patchable.iteratePredicate n current))

/-- The current mismatch forces the repaired candidate to be a new state. -/
theorem tarskiPatch_current_ne_next
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial current : patchable.context.Predicate) :
    current =
        (tarskiPatchGapDrivenDynamicSystem patchable initial).next current ->
      False := by
  intro current_eq_next
  let step := patchable.step current
  have current_eq_patched : current = step.nextPredicate :=
    current_eq_next.trans
      (tarskiPatchNext_eq_nextPredicate patchable initial current)
  have agreement :
      patchable.truthAt current step.diagonalSentence ↔
        patchable.context.models step.diagonalSentence := by
    have pointEquality :
        patchable.truthAt current step.diagonalSentence =
          patchable.truthAt step.nextPredicate step.diagonalSentence :=
      congrArg
        (fun candidate =>
          patchable.truthAt candidate step.diagonalSentence)
        current_eq_patched
    constructor
    · intro currentTruth
      exact
        step.repaired_index_agreement.mp
          (pointEquality.mp currentTruth)
    · intro semanticTruth
      exact
        pointEquality.mpr
          (step.repaired_index_agreement.mpr semanticTruth)
  exact tarski_local_mismatch step.fixedPoint agreement

/-- One intrinsic causal state change, not restricted to pole reversal. -/
structure TarskiIntrinsicGapDrivenStateChange
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial current : patchable.context.Predicate) :
    Type (max u v) where
  causalStep :
    DynamicUsageStep
      (tarskiPatchGapDrivenDynamicSystem patchable initial)
      current
  causalStep_eq :
    causalStep =
      dynamicUsageStep
        (tarskiPatchGapDrivenDynamicSystem patchable initial)
        current
  source_ne_next :
    current =
        (tarskiPatchGapDrivenDynamicSystem patchable initial).next current ->
      False
  next_eq_patch :
    (tarskiPatchGapDrivenDynamicSystem patchable initial).next current =
      patchable.nextPredicate current

/-- Canonical nonstationary Tarski change at every candidate. -/
def tarskiIntrinsicGapDrivenStateChange
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial current : patchable.context.Predicate) :
    TarskiIntrinsicGapDrivenStateChange patchable initial current where
  causalStep :=
    dynamicUsageStep
      (tarskiPatchGapDrivenDynamicSystem patchable initial)
      current
  causalStep_eq := rfl
  source_ne_next := tarskiPatch_current_ne_next patchable initial current
  next_eq_patch := tarskiPatchNext_eq_nextPredicate patchable initial current

/-! ## Closed generic synthesis over a patchable syntax -/

/--
The generic synthesis retains all causal components.  It is closed relative to
the positive patchable syntax supplied as its first parameter; a completely
closed inhabitant is constructed by `ConstructivePatchModel`.
-/
structure TarskiDynamicRelaxedUsageSynthesis
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    Type (max u v) where
  family :
    IntrinsicDynamicReturnFamily
      (tarskiPatchCompleteness patchable)
      (tarskiPatchRoundTripCoherence patchable)
      TarskiPatchBranch.causal
      patchable.context.Predicate
      (TarskiInterface patchable.context.Sentence)
      (TarskiPatchInterfaceWitness patchable)
      (TarskiPatchRealizesInterface patchable)
      patchable.context.Sentence
      TarskiInterface.project
      (TarskiPatchRepair patchable)
  family_eq :
    family = tarskiPatchIntrinsicDynamicReturnFamily patchable initial
  dynamics : GapDrivenDynamicSystem family
  initialChange :
    TarskiIntrinsicGapDrivenStateChange patchable initial initial
  coherentTransport :
    CompositionalTransport
      (dynamicRelaxedRegimeOfReturnFamily family)
      (dynamicCompositionalUseOfReturnFamily family)
  initialMismatch :
    LocalTruthMismatch
      patchable.context.Sentence
      (patchable.truthAt initial)
      patchable.context.models
  initialRepair :
    TarskiPatchRepair
      patchable
      (family.formedAt initial)
  initialNext : patchable.context.Predicate
  initialNext_eq :
    initialNext = patchable.nextPredicate initial
  nextMismatch :
    LocalTruthMismatch
      patchable.context.Sentence
      (patchable.truthAt initialNext)
      patchable.context.models
  notExactProjective :
    ExactProjectiveRepresentation.{u, max u v}
        (dynamicRelaxedRegimeOfReturnFamily family) ->
      False
  initialNotGloballyCorrect :
    TarskiTruthDefinition
        (patchable.truthAt initial)
        patchable.context.models ->
      False

/-- Canonical synthesis over any positive patchable syntax. -/
def tarskiDynamicRelaxedUsageSynthesis
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    TarskiDynamicRelaxedUsageSynthesis patchable initial :=
  let family := tarskiPatchIntrinsicDynamicReturnFamily patchable initial
  { family := family
    family_eq := rfl
    dynamics := tarskiPatchGapDrivenDynamicSystem patchable initial
    initialChange :=
      tarskiIntrinsicGapDrivenStateChange patchable initial initial
    coherentTransport :=
      dynamicCompositionalTransportOfReturnFamily family
    initialMismatch :=
      (patchable.step initial).mismatch
    initialRepair := family.repairAt initial
    initialNext := patchable.nextPredicate initial
    initialNext_eq := rfl
    nextMismatch := (patchable.step initial).nextMismatch
    notExactProjective :=
      dynamicRelaxedRegime_not_exactProjective family
    initialNotGloballyCorrect :=
      patchable.truthAt_notGloballyCorrect initial }

end TarskiDynamicRelaxedUsage
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.TarskiDynamicRelaxedUsage.TarskiPatchComplete
#print axioms Meta.TarskiDynamicRelaxedUsage.TarskiPatchForward
#print axioms Meta.TarskiDynamicRelaxedUsage.TarskiPatchBackward
#print axioms Meta.TarskiDynamicRelaxedUsage.TarskiPatchIntersection
#print axioms Meta.TarskiDynamicRelaxedUsage.tarskiPatchCompleteness
#print axioms Meta.TarskiDynamicRelaxedUsage.tarskiPatchRoundTripCoherence
#print axioms Meta.TarskiDynamicRelaxedUsage.TarskiPatchInterfaceWitness
#print axioms Meta.TarskiDynamicRelaxedUsage.TarskiPatchRepair
#print axioms Meta.TarskiDynamicRelaxedUsage.TarskiPatchRepair.applyCandidate_eq_patch
#print axioms Meta.TarskiDynamicRelaxedUsage.tarskiPatchLocallyRecoveredDynamicReturn
#print axioms Meta.TarskiDynamicRelaxedUsage.tarskiPatchIntrinsicDynamicReturnFamily
#print axioms Meta.TarskiDynamicRelaxedUsage.tarskiPatchAdvance
#print axioms Meta.TarskiDynamicRelaxedUsage.tarskiPatchGapDrivenDynamicSystem
#print axioms Meta.TarskiDynamicRelaxedUsage.tarskiPatchNext_eq_nextPredicate
#print axioms Meta.TarskiDynamicRelaxedUsage.tarskiPatchIterate_eq_iteratePredicate
#print axioms Meta.TarskiDynamicRelaxedUsage.tarskiPatch_current_ne_next
#print axioms Meta.TarskiDynamicRelaxedUsage.TarskiIntrinsicGapDrivenStateChange
#print axioms Meta.TarskiDynamicRelaxedUsage.tarskiIntrinsicGapDrivenStateChange
#print axioms Meta.TarskiDynamicRelaxedUsage.TarskiDynamicRelaxedUsageSynthesis
#print axioms Meta.TarskiDynamicRelaxedUsage.tarskiDynamicRelaxedUsageSynthesis
/- AXIOM_AUDIT_END -/
