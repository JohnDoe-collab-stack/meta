import Meta.Tarski.DynamicRelaxedUsage

/-!
# Closed constructive syntax model for dynamic Tarski repair

Candidates are finite syntax objects, not semantic predicates.  A candidate
stores the atoms it currently accepts.  Its diagonal challenge is a freshly
computed atom outside that finite support, and patching adds the challenged
atom to the syntax.  This gives a closed, infinite, executable instance of the
patchable Tarski interface and of the dynamic relaxed usage synthesis.
-/

namespace Meta
namespace ConstructivePatchModel

open ClosedStabilityTheorem
open DynamicRelaxedUsage
open RelaxedUsageRegime
open TarskiDynamicRelaxedUsage

/-! ## Concrete syntax and finite candidates -/

/-- Sentences distinguish semantic atoms from Boolean syntax literals. -/
inductive PatchSentence where
  | atom : Nat -> PatchSentence
  | literal : Bool -> PatchSentence
deriving DecidableEq

/-- A candidate is finite syntax: the list of atoms it currently accepts. -/
structure PatchCandidate where
  acceptedAtoms : List Nat

/-- Executable membership in a finite candidate. -/
def containsAtom : List Nat -> Nat -> Bool
  | [], _ => false
  | head :: tail, atom =>
      if atom = head then true else containsAtom tail atom

/-- Structural maximum used locally, with no imported arithmetic theorem. -/
def constructiveMaximum : Nat -> Nat -> Nat
  | 0, b => b
  | Nat.succ a, 0 => Nat.succ a
  | Nat.succ a, Nat.succ b =>
      Nat.succ (constructiveMaximum a b)

/-- Maximum atom occurring in a finite list. -/
def maximumAtom : List Nat -> Nat
  | [] => 0
  | head :: tail =>
      constructiveMaximum head (maximumAtom tail)

/-- Constructive left bound for the local structural maximum. -/
theorem nat_le_max_left_constructive (a b : Nat) :
    a <= constructiveMaximum a b := by
  induction a generalizing b with
  | zero =>
      exact Nat.zero_le b
  | succ a inductionHypothesis =>
      cases b with
      | zero =>
          exact Nat.le_refl (Nat.succ a)
      | succ b =>
          exact Nat.succ_le_succ (inductionHypothesis b)

/-- Constructive right bound for the local structural maximum. -/
theorem nat_le_max_right_constructive (a b : Nat) :
    b <= constructiveMaximum a b := by
  induction a generalizing b with
  | zero =>
      exact Nat.le_refl b
  | succ a inductionHypothesis =>
      cases b with
      | zero =>
          exact Nat.zero_le (Nat.succ a)
      | succ b =>
          exact Nat.succ_le_succ (inductionHypothesis b)

/-- Every accepted atom is bounded by the computed maximum. -/
theorem containsAtom_true_le_maximum
    (atoms : List Nat)
    (atom : Nat)
    (contained : containsAtom atoms atom = true) :
    atom <= maximumAtom atoms := by
  induction atoms with
  | nil =>
      cases contained
  | cons head tail inductionHypothesis =>
      unfold containsAtom at contained
      unfold maximumAtom
      split at contained
      next same =>
        cases same
        exact nat_le_max_left_constructive atom (maximumAtom tail)
      next different =>
        exact
          Nat.le_trans
            (inductionHypothesis contained)
            (nat_le_max_right_constructive head (maximumAtom tail))

/-- A successor cannot be below its predecessor. -/
theorem nat_succ_not_le_self (n : Nat) :
    Nat.succ n <= n -> False := by
  induction n with
  | zero =>
      intro impossible
      cases impossible
  | succ n inductionHypothesis =>
      intro impossible
      exact
        inductionHypothesis
          (Nat.le_of_succ_le_succ impossible)

/-- The fresh atom is strictly beyond every atom in the support. -/
def PatchCandidate.fresh (candidate : PatchCandidate) : Nat :=
  Nat.succ (maximumAtom candidate.acceptedAtoms)

/-- The computed fresh atom is not accepted by the current syntax. -/
theorem PatchCandidate.fresh_not_contained
    (candidate : PatchCandidate) :
    containsAtom candidate.acceptedAtoms candidate.fresh = false := by
  cases equality :
      containsAtom candidate.acceptedAtoms candidate.fresh with
  | false => rfl
  | true =>
      have bounded :
          candidate.fresh <= maximumAtom candidate.acceptedAtoms :=
        containsAtom_true_le_maximum
          candidate.acceptedAtoms
          candidate.fresh
          equality
      exact
        (nat_succ_not_le_self
          (maximumAtom candidate.acceptedAtoms)
          bounded).elim

/-- Evaluate a finite candidate on the concrete sentence syntax. -/
def PatchCandidate.accepts
    (candidate : PatchCandidate) :
    PatchSentence -> Bool
  | PatchSentence.atom atom =>
      containsAtom candidate.acceptedAtoms atom
  | PatchSentence.literal value =>
      value

/-- Semantic holding is distinct from candidate acceptance. -/
def patchModels : PatchSentence -> Prop
  | PatchSentence.atom _ => True
  | PatchSentence.literal value => value = true

/-- Apply a syntactic candidate and reify its Boolean output as a sentence. -/
def patchApplyQuote
    (candidate : PatchCandidate)
    (sentence : PatchSentence) :
    PatchSentence :=
  PatchSentence.literal (candidate.accepts sentence)

/-- The diagonal sentence is the freshly computed semantic atom. -/
def patchDiagonal (candidate : PatchCandidate) : PatchSentence :=
  PatchSentence.atom candidate.fresh

/-- The finite candidate is false at its own fresh diagonal atom. -/
theorem patchApplyQuote_diagonal_false
    (candidate : PatchCandidate) :
    patchApplyQuote candidate (patchDiagonal candidate) =
      PatchSentence.literal false := by
  unfold patchApplyQuote patchDiagonal PatchCandidate.accepts
  change
    PatchSentence.literal
        (containsAtom candidate.acceptedAtoms candidate.fresh) =
      PatchSentence.literal false
  rw [candidate.fresh_not_contained]

/-- The concrete diagonal satisfies the constructive Tarski fixed point. -/
theorem patchDiagonal_spec
    (candidate : PatchCandidate) :
    patchModels (patchDiagonal candidate) ↔
      (patchModels
        (patchApplyQuote candidate (patchDiagonal candidate)) -> False) := by
  rw [patchApplyQuote_diagonal_false]
  constructor
  · intro semanticTruth candidateTruth
    exact Bool.noConfusion candidateTruth
  · intro notCandidateTruth
    exact True.intro

/-! ## Internal syntax patch -/

/-- Patch a candidate at an arbitrary sentence while staying in syntax. -/
def patchCandidate
    (candidate : PatchCandidate)
    (index : PatchSentence) :
    PatchCandidate :=
  match index with
  | PatchSentence.atom atom =>
      { acceptedAtoms := atom :: candidate.acceptedAtoms }
  | PatchSentence.literal _ =>
      candidate

/-- A newly added atom is accepted. -/
theorem containsAtom_cons_self
    (atom : Nat)
    (atoms : List Nat) :
    containsAtom (atom :: atoms) atom = true := by
  change (if atom = atom then true else containsAtom atoms atom) = true
  rw [if_pos rfl]

/-- Adding another atom preserves membership away from that atom. -/
theorem containsAtom_cons_of_ne
    {added queried : Nat}
    (different : queried = added -> False)
    (atoms : List Nat) :
    containsAtom (added :: atoms) queried =
      containsAtom atoms queried := by
  change
    (if queried = added then true else containsAtom atoms queried) =
      containsAtom atoms queried
  split
  · next same => exact (different same).elim
  · rfl

/-- Applying a patched candidate at its index agrees with semantic holding. -/
theorem patchCandidate_agrees_at
    (candidate : PatchCandidate)
    (index : PatchSentence) :
    patchModels
        (patchApplyQuote (patchCandidate candidate index) index) ↔
      patchModels index := by
  cases index with
  | atom atom =>
      unfold patchCandidate patchApplyQuote PatchCandidate.accepts patchModels
      change
        (containsAtom (atom :: candidate.acceptedAtoms) atom = true) ↔
          True
      constructor
      · intro _
        exact True.intro
      · intro _
        exact containsAtom_cons_self atom candidate.acceptedAtoms
  | literal value =>
      cases value <;> rfl

/-- Patching preserves the old candidate away from the patched sentence. -/
theorem patchCandidate_preserves_off_index
    (candidate : PatchCandidate)
    (index sentence : PatchSentence)
    (offIndex : sentence = index -> False) :
    patchModels
        (patchApplyQuote (patchCandidate candidate index) sentence) ↔
      patchModels (patchApplyQuote candidate sentence) := by
  cases index with
  | atom added =>
      cases sentence with
      | atom queried =>
          have different : queried = added -> False := by
            intro same
            exact offIndex (congrArg PatchSentence.atom same)
          unfold patchCandidate patchApplyQuote PatchCandidate.accepts patchModels
          change
            (containsAtom (added :: candidate.acceptedAtoms) queried = true) ↔
              (containsAtom candidate.acceptedAtoms queried = true)
          rw [containsAtom_cons_of_ne different]
      | literal value =>
          cases value <;> rfl
  | literal indexValue =>
      rfl

/-! ## Closed patchable Tarski context -/

/-- The arithmetic-shaped context of the concrete syntax model. -/
def constructiveArithmeticTarskiContext : ArithmeticTarskiContext where
  Sentence := PatchSentence
  Predicate := PatchCandidate
  applyQuote := patchApplyQuote
  models := patchModels
  diagonal := patchDiagonal
  diagonal_spec := patchDiagonal_spec

/-- The concrete candidate syntax is internally closed under local patching. -/
def constructivePatchableTarskiContext :
    PatchableArithmeticTarskiContext where
  context := constructiveArithmeticTarskiContext
  patchPredicate := patchCandidate
  patch_agrees_at := patchCandidate_agrees_at
  patch_preserves_off_index := patchCandidate_preserves_off_index

/-- Empty initial candidate. -/
def initialPatchCandidate : PatchCandidate where
  acceptedAtoms := []

/-- The concrete dynamic Tarski synthesis, with no external parameter. -/
def constructiveTarskiDynamicRelaxedUsageSynthesis :
    TarskiDynamicRelaxedUsageSynthesis
      constructivePatchableTarskiContext
      initialPatchCandidate :=
  tarskiDynamicRelaxedUsageSynthesis
    constructivePatchableTarskiContext
    initialPatchCandidate

/-! ## Explicit non-triviality and iteration -/

/-- Semantic truth has a concrete positive sentence. -/
def patchModels_true : patchModels (PatchSentence.atom 0) :=
  True.intro

/-- Semantic truth has a concrete negative sentence. -/
theorem patchModels_false :
    patchModels (PatchSentence.literal false) -> False := by
  intro impossible
  cases impossible

/-- The projection used by Tarski is globally nonconstant. -/
theorem tarskiPatchProjection_nonconstant :
    (@TarskiInterface.project PatchSentence)
        (TarskiInterface.semantic (PatchSentence.atom 0)) =
      (@TarskiInterface.project PatchSentence)
        (TarskiInterface.semantic (PatchSentence.literal false)) ->
      False := by
  intro equality
  cases equality

/-- The first candidate produced by causal repair. -/
def firstPatchCandidate : PatchCandidate :=
  constructivePatchableTarskiContext.nextPredicate initialPatchCandidate

/-- The second candidate is computed from the first candidate's new gap. -/
def secondPatchCandidate : PatchCandidate :=
  constructivePatchableTarskiContext.nextPredicate firstPatchCandidate

/-- The initial candidate rejects its own diagonal challenge. -/
theorem initialPatch_applyQuote_diagonal_false :
    patchApplyQuote initialPatchCandidate
        (patchDiagonal initialPatchCandidate) =
      PatchSentence.literal false :=
  patchApplyQuote_diagonal_false initialPatchCandidate

/-- The first repaired candidate accepts the preceding diagonal challenge. -/
theorem firstPatch_applyQuote_initialDiagonal_true :
    patchApplyQuote firstPatchCandidate
        (patchDiagonal initialPatchCandidate) =
      PatchSentence.literal true :=
  rfl

/-- Candidate application is observably sensitive to the candidate syntax. -/
theorem patchApplyQuote_depends_on_candidate :
    patchApplyQuote initialPatchCandidate
        (patchDiagonal initialPatchCandidate) =
        patchApplyQuote firstPatchCandidate
          (patchDiagonal initialPatchCandidate) ->
      False := by
  intro equality
  have impossible :
      PatchSentence.literal false = PatchSentence.literal true :=
    initialPatch_applyQuote_diagonal_false.symm.trans
      (equality.trans firstPatch_applyQuote_initialDiagonal_true)
  cases impossible

/-- The first causal repair changes the candidate. -/
theorem initialPatchCandidate_ne_first :
    initialPatchCandidate = firstPatchCandidate -> False :=
  tarskiPatch_current_ne_next
    constructivePatchableTarskiContext
    initialPatchCandidate
    initialPatchCandidate

/-- The second causal repair also changes its current candidate. -/
theorem firstPatchCandidate_ne_second :
    firstPatchCandidate = secondPatchCandidate -> False :=
  tarskiPatch_current_ne_next
    constructivePatchableTarskiContext
    initialPatchCandidate
    firstPatchCandidate

/-- The two first dynamic successors are the two syntax-level patches. -/
theorem constructive_two_steps_eq_second :
    (tarskiPatchGapDrivenDynamicSystem
      constructivePatchableTarskiContext
      initialPatchCandidate).iterateSource
        2
        initialPatchCandidate =
      secondPatchCandidate :=
  rfl

/-- The first successor is produced by the causal dynamic system. -/
theorem constructive_first_step_eq_first :
    (tarskiPatchGapDrivenDynamicSystem
      constructivePatchableTarskiContext
      initialPatchCandidate).next initialPatchCandidate =
      firstPatchCandidate :=
  rfl

/-- The second successor consumes the gap generated at the first candidate. -/
theorem constructive_second_step_eq_second :
    (tarskiPatchGapDrivenDynamicSystem
      constructivePatchableTarskiContext
      initialPatchCandidate).next firstPatchCandidate =
      secondPatchCandidate :=
  rfl

/-- Dynamic iteration and syntax-level iteration coincide at every depth. -/
theorem constructive_dynamic_iterates_eq_patch_iterates
    (n : Nat) :
    (tarskiPatchGapDrivenDynamicSystem
      constructivePatchableTarskiContext
      initialPatchCandidate).iterateSource
        n
        initialPatchCandidate =
      constructivePatchableTarskiContext.iteratePredicate
        n
        initialPatchCandidate :=
  tarskiPatchIterate_eq_iteratePredicate
    constructivePatchableTarskiContext
    initialPatchCandidate
    initialPatchCandidate
    n

/-- The first patch repairs exactly the first diagonal sentence. -/
theorem firstPatch_repairs_initial_diagonal :
    constructivePatchableTarskiContext.truthAt
        firstPatchCandidate
        (constructivePatchableTarskiContext.diagonalSentence
          initialPatchCandidate) ↔
      constructivePatchableTarskiContext.context.models
        (constructivePatchableTarskiContext.diagonalSentence
          initialPatchCandidate) :=
  (constructivePatchableTarskiContext.step
    initialPatchCandidate).repaired_index_agreement

/-- The repaired candidate immediately receives a new local mismatch. -/
def firstPatch_nextMismatch :
    LocalTruthMismatch
      PatchSentence
      (constructivePatchableTarskiContext.truthAt firstPatchCandidate)
      patchModels :=
  (constructivePatchableTarskiContext.step initialPatchCandidate).nextMismatch

/-- No finite concrete candidate can be globally correct. -/
theorem patchCandidate_notGloballyCorrect
    (candidate : PatchCandidate)
    (definition :
      TarskiTruthDefinition
        (constructivePatchableTarskiContext.truthAt candidate)
        patchModels) :
    False :=
  constructivePatchableTarskiContext.truthAt_notGloballyCorrect
    candidate
    definition

/-- Every concrete iteration remains globally incomplete. -/
theorem iteratedPatchCandidate_notGloballyCorrect
    (n : Nat)
    (definition :
      TarskiTruthDefinition
        (constructivePatchableTarskiContext.truthAt
          (constructivePatchableTarskiContext.iteratePredicate
            n
            initialPatchCandidate))
        patchModels) :
    False :=
  constructivePatchableTarskiContext.truthAt_notGloballyCorrect
    (constructivePatchableTarskiContext.iteratePredicate
      n
      initialPatchCandidate)
    definition

/-- No candidate reached by the gap-driven dynamics is globally correct. -/
theorem dynamicIteratedPatchCandidate_notGloballyCorrect
    (n : Nat)
    (definition :
      TarskiTruthDefinition
        (constructivePatchableTarskiContext.truthAt
          ((tarskiPatchGapDrivenDynamicSystem
            constructivePatchableTarskiContext
            initialPatchCandidate).iterateSource
              n
              initialPatchCandidate))
        patchModels) :
    False :=
  patchCandidate_notGloballyCorrect
    ((tarskiPatchGapDrivenDynamicSystem
      constructivePatchableTarskiContext
      initialPatchCandidate).iterateSource
        n
        initialPatchCandidate)
    definition

/-! ## Closed nontrivial synthesis package -/

/--
The final concrete package retains the algorithm, two causal transitions, and
all non-triviality certificates.  It has no external algorithmic parameter.
-/
structure ConstructiveTarskiClosedSystem where
  synthesis :
    TarskiDynamicRelaxedUsageSynthesis
      constructivePatchableTarskiContext
      initialPatchCandidate
  synthesis_eq :
    synthesis = constructiveTarskiDynamicRelaxedUsageSynthesis
  initialFresh :
    containsAtom
        initialPatchCandidate.acceptedAtoms
        initialPatchCandidate.fresh =
      false
  semanticPositive : patchModels (PatchSentence.atom 0)
  semanticNegative : patchModels (PatchSentence.literal false) -> False
  projectionNonconstant :
    (@TarskiInterface.project PatchSentence)
        (TarskiInterface.semantic (PatchSentence.atom 0)) =
        (@TarskiInterface.project PatchSentence)
          (TarskiInterface.semantic (PatchSentence.literal false)) ->
      False
  candidateSensitive :
    patchApplyQuote initialPatchCandidate
        (patchDiagonal initialPatchCandidate) =
        patchApplyQuote firstPatchCandidate
          (patchDiagonal initialPatchCandidate) ->
      False
  firstChange : initialPatchCandidate = firstPatchCandidate -> False
  secondChange : firstPatchCandidate = secondPatchCandidate -> False
  firstStep :
    (tarskiPatchGapDrivenDynamicSystem
      constructivePatchableTarskiContext
      initialPatchCandidate).next initialPatchCandidate =
      firstPatchCandidate
  secondStep :
    (tarskiPatchGapDrivenDynamicSystem
      constructivePatchableTarskiContext
      initialPatchCandidate).next firstPatchCandidate =
      secondPatchCandidate
  twoSteps :
    (tarskiPatchGapDrivenDynamicSystem
      constructivePatchableTarskiContext
      initialPatchCandidate).iterateSource
        2
        initialPatchCandidate =
      secondPatchCandidate
  dynamicIteration_eq_syntaxIteration :
    ∀ n : Nat,
      (tarskiPatchGapDrivenDynamicSystem
        constructivePatchableTarskiContext
        initialPatchCandidate).iterateSource
          n
          initialPatchCandidate =
        constructivePatchableTarskiContext.iteratePredicate
          n
          initialPatchCandidate
  everyIterateIncomplete :
    ∀ n : Nat,
      TarskiTruthDefinition
          (constructivePatchableTarskiContext.truthAt
            ((tarskiPatchGapDrivenDynamicSystem
              constructivePatchableTarskiContext
              initialPatchCandidate).iterateSource
                n
                initialPatchCandidate))
          patchModels ->
        False

/-- Closed inhabitant of the complete concrete dynamic Tarski package. -/
def constructiveTarskiClosedSystem : ConstructiveTarskiClosedSystem where
  synthesis := constructiveTarskiDynamicRelaxedUsageSynthesis
  synthesis_eq := rfl
  initialFresh := initialPatchCandidate.fresh_not_contained
  semanticPositive := patchModels_true
  semanticNegative := patchModels_false
  projectionNonconstant := tarskiPatchProjection_nonconstant
  candidateSensitive := patchApplyQuote_depends_on_candidate
  firstChange := initialPatchCandidate_ne_first
  secondChange := firstPatchCandidate_ne_second
  firstStep := constructive_first_step_eq_first
  secondStep := constructive_second_step_eq_second
  twoSteps := constructive_two_steps_eq_second
  dynamicIteration_eq_syntaxIteration :=
    constructive_dynamic_iterates_eq_patch_iterates
  everyIterateIncomplete :=
    dynamicIteratedPatchCandidate_notGloballyCorrect

end ConstructivePatchModel
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ConstructivePatchModel.PatchSentence
#print axioms Meta.ConstructivePatchModel.PatchCandidate
#print axioms Meta.ConstructivePatchModel.nat_le_max_left_constructive
#print axioms Meta.ConstructivePatchModel.nat_le_max_right_constructive
#print axioms Meta.ConstructivePatchModel.containsAtom_true_le_maximum
#print axioms Meta.ConstructivePatchModel.nat_succ_not_le_self
#print axioms Meta.ConstructivePatchModel.PatchCandidate.fresh_not_contained
#print axioms Meta.ConstructivePatchModel.patchDiagonal_spec
#print axioms Meta.ConstructivePatchModel.patchCandidate
#print axioms Meta.ConstructivePatchModel.containsAtom_cons_self
#print axioms Meta.ConstructivePatchModel.patchCandidate_agrees_at
#print axioms Meta.ConstructivePatchModel.patchCandidate_preserves_off_index
#print axioms Meta.ConstructivePatchModel.constructiveArithmeticTarskiContext
#print axioms Meta.ConstructivePatchModel.constructivePatchableTarskiContext
#print axioms Meta.ConstructivePatchModel.constructiveTarskiDynamicRelaxedUsageSynthesis
#print axioms Meta.ConstructivePatchModel.tarskiPatchProjection_nonconstant
#print axioms Meta.ConstructivePatchModel.patchApplyQuote_depends_on_candidate
#print axioms Meta.ConstructivePatchModel.initialPatchCandidate_ne_first
#print axioms Meta.ConstructivePatchModel.firstPatchCandidate_ne_second
#print axioms Meta.ConstructivePatchModel.constructive_first_step_eq_first
#print axioms Meta.ConstructivePatchModel.constructive_second_step_eq_second
#print axioms Meta.ConstructivePatchModel.constructive_two_steps_eq_second
#print axioms Meta.ConstructivePatchModel.constructive_dynamic_iterates_eq_patch_iterates
#print axioms Meta.ConstructivePatchModel.firstPatch_repairs_initial_diagonal
#print axioms Meta.ConstructivePatchModel.firstPatch_nextMismatch
#print axioms Meta.ConstructivePatchModel.patchCandidate_notGloballyCorrect
#print axioms Meta.ConstructivePatchModel.iteratedPatchCandidate_notGloballyCorrect
#print axioms Meta.ConstructivePatchModel.dynamicIteratedPatchCandidate_notGloballyCorrect
#print axioms Meta.ConstructivePatchModel.ConstructiveTarskiClosedSystem
#print axioms Meta.ConstructivePatchModel.constructiveTarskiClosedSystem
/- AXIOM_AUDIT_END -/
