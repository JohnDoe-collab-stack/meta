import Meta.Tarski.ConstructivePatchModel

/-!
# Exact orbit of the closed constructive Tarski model

The finite syntax model already computes every transition.  This file proves
the global shape of that computation: at rank `n` the support is exactly
`[n, ..., 1]`, the current diagonal index is `atom (n + 1)`, every earlier
index remains repaired, and neither candidates nor indices can return.
-/

namespace Meta
namespace ConstructivePatchModel

open ClosedStabilityTheorem
open TarskiDynamicRelaxedUsage

/-! ## Canonical finite supports -/

/-- The exact support accumulated after `n` causal repairs. -/
def descendingSupport : Nat -> List Nat
  | 0 => []
  | Nat.succ n => Nat.succ n :: descendingSupport n

/-- The canonical support has exactly `n` entries. -/
theorem descendingSupport_length (n : Nat) :
    (descendingSupport n).length = n := by
  induction n with
  | zero =>
      rfl
  | succ n inductionHypothesis =>
      change Nat.succ (descendingSupport n).length = Nat.succ n
      rw [inductionHypothesis]

/-- The local maximum selects a successor against its predecessor. -/
theorem constructiveMaximum_succ_predecessor (n : Nat) :
    constructiveMaximum (Nat.succ n) n = Nat.succ n := by
  induction n with
  | zero =>
      rfl
  | succ n inductionHypothesis =>
      change
        Nat.succ (constructiveMaximum (Nat.succ n) n) =
          Nat.succ (Nat.succ n)
      rw [inductionHypothesis]

/-- The computed maximum of the canonical support is its rank. -/
theorem maximumAtom_descendingSupport (n : Nat) :
    maximumAtom (descendingSupport n) = n := by
  induction n with
  | zero =>
      rfl
  | succ n inductionHypothesis =>
      change
        constructiveMaximum
            (Nat.succ n)
            (maximumAtom (descendingSupport n)) =
          Nat.succ n
      rw [inductionHypothesis]
      exact constructiveMaximum_succ_predecessor n

/--
Exact membership in the canonical support: the accepted atoms are precisely
the positive atoms bounded by the current rank.
-/
theorem containsAtom_descendingSupport_iff
    (n atom : Nat) :
    containsAtom (descendingSupport n) atom = true ↔
      0 < atom ∧ atom <= n := by
  induction n with
  | zero =>
      constructor
      · intro impossible
        cases impossible
      · intro bounds
        have atom_eq_zero : atom = 0 :=
          Nat.eq_zero_of_le_zero bounds.2
        cases atom_eq_zero
        exact (Nat.lt_irrefl 0 bounds.1).elim
  | succ n inductionHypothesis =>
      change
        (if atom = Nat.succ n then true
          else containsAtom (descendingSupport n) atom) = true ↔
          0 < atom ∧ atom <= Nat.succ n
      split
      next same =>
        cases same
        constructor
        · intro _
          exact ⟨Nat.succ_pos n, Nat.le_refl (Nat.succ n)⟩
        · intro _
          rfl
      next different =>
        constructor
        · intro contained
          have bounds := inductionHypothesis.mp contained
          exact
            ⟨bounds.1,
              Nat.le_trans bounds.2 (Nat.le_succ n)⟩
        · intro bounds
          have atom_lt_succ : atom < Nat.succ n :=
            Nat.lt_of_le_of_ne bounds.2 different
          exact inductionHypothesis.mpr
            ⟨bounds.1, Nat.le_of_lt_succ atom_lt_succ⟩

/-- Every earlier challenge is present in every later support. -/
theorem containsAtom_descendingSupport_of_lt
    {k n : Nat}
    (earlier : k < n) :
    containsAtom (descendingSupport n) (Nat.succ k) = true :=
  (containsAtom_descendingSupport_iff n (Nat.succ k)).mpr
    ⟨Nat.succ_pos k, earlier⟩

/-- The current challenge is absent from the current support. -/
theorem containsAtom_descendingSupport_current_false (n : Nat) :
    containsAtom (descendingSupport n) (Nat.succ n) = false := by
  have freshAbsence :
      containsAtom
          (descendingSupport n)
          (Nat.succ (maximumAtom (descendingSupport n))) =
        false :=
    PatchCandidate.fresh_not_contained
      { acceptedAtoms := descendingSupport n }
  rw [maximumAtom_descendingSupport] at freshAbsence
  exact freshAbsence

/-! ## Exact candidates and indices -/

/-- The unique candidate reached at rank `n`. -/
def orbitCandidate (n : Nat) : PatchCandidate where
  acceptedAtoms := descendingSupport n

/-- The unique diagonal challenge generated at rank `n`. -/
def orbitIndex (n : Nat) : PatchSentence :=
  PatchSentence.atom (Nat.succ n)

/-- The empty initial syntax is the rank-zero orbit candidate. -/
theorem initialPatchCandidate_eq_orbitCandidate_zero :
    initialPatchCandidate = orbitCandidate 0 :=
  rfl

/-- The fresh atom of the rank-`n` candidate is exactly `n + 1`. -/
theorem orbitCandidate_fresh (n : Nat) :
    (orbitCandidate n).fresh = Nat.succ n := by
  unfold PatchCandidate.fresh orbitCandidate
  rw [maximumAtom_descendingSupport]

/-- The concrete diagonalizer computes the canonical orbit index. -/
theorem patchDiagonal_orbitCandidate (n : Nat) :
    patchDiagonal (orbitCandidate n) = orbitIndex n := by
  unfold patchDiagonal orbitIndex
  rw [orbitCandidate_fresh]

/-- Patching the current challenge constructs the next canonical candidate. -/
theorem patchCandidate_orbitIndex (n : Nat) :
    patchCandidate (orbitCandidate n) (orbitIndex n) =
      orbitCandidate (Nat.succ n) :=
  rfl

/-- The syntax-level transition computes the next canonical candidate. -/
theorem nextPredicate_orbitCandidate (n : Nat) :
    constructivePatchableTarskiContext.nextPredicate (orbitCandidate n) =
      orbitCandidate (Nat.succ n) := by
  unfold PatchableArithmeticTarskiContext.nextPredicate
  change
    patchCandidate (orbitCandidate n) (patchDiagonal (orbitCandidate n)) =
      orbitCandidate (Nat.succ n)
  rw [patchDiagonal_orbitCandidate]
  exact patchCandidate_orbitIndex n

/-- Exact closed form of every syntax-level iterate. -/
theorem iteratePredicate_initial_eq_orbitCandidate (n : Nat) :
    constructivePatchableTarskiContext.iteratePredicate
        n
        initialPatchCandidate =
      orbitCandidate n := by
  induction n with
  | zero =>
      exact initialPatchCandidate_eq_orbitCandidate_zero
  | succ n inductionHypothesis =>
      change
        constructivePatchableTarskiContext.nextPredicate
            (constructivePatchableTarskiContext.iteratePredicate
              n
              initialPatchCandidate) =
          orbitCandidate (Nat.succ n)
      rw [inductionHypothesis]
      exact nextPredicate_orbitCandidate n

/-- Exact closed form of every gap-driven dynamic iterate. -/
theorem dynamicIterate_initial_eq_orbitCandidate (n : Nat) :
    (tarskiPatchGapDrivenDynamicSystem
      constructivePatchableTarskiContext
      initialPatchCandidate).iterateSource
        n
        initialPatchCandidate =
      orbitCandidate n := by
  rw [constructive_dynamic_iterates_eq_patch_iterates]
  exact iteratePredicate_initial_eq_orbitCandidate n

/-! ## Cumulative agreement and moving mismatch -/

/-- Every canonical diagonal index is semantically true. -/
def orbitIndex_models (n : Nat) :
    patchModels (orbitIndex n) :=
  True.intro

/-- The current candidate computes `false` on its current challenge. -/
theorem orbitCandidate_current_application_false (n : Nat) :
    patchApplyQuote (orbitCandidate n) (orbitIndex n) =
      PatchSentence.literal false := by
  unfold patchApplyQuote PatchCandidate.accepts orbitIndex orbitCandidate
  change
    PatchSentence.literal
        (containsAtom (descendingSupport n) (Nat.succ n)) =
      PatchSentence.literal false
  rw [containsAtom_descendingSupport_current_false]

/-- The current candidate cannot hold at its current semantic index. -/
theorem orbitCandidate_rejects_current (n : Nat) :
    constructivePatchableTarskiContext.truthAt
        (orbitCandidate n)
        (orbitIndex n) ->
      False := by
  intro currentTruth
  change
    patchModels
      (patchApplyQuote (orbitCandidate n) (orbitIndex n)) at currentTruth
  rw [orbitCandidate_current_application_false] at currentTruth
  exact Bool.noConfusion currentTruth

/-- The next candidate computes `true` on the challenge it repairs. -/
theorem orbitNext_current_application_true (n : Nat) :
    patchApplyQuote
        (orbitCandidate (Nat.succ n))
        (orbitIndex n) =
      PatchSentence.literal true := by
  unfold patchApplyQuote PatchCandidate.accepts orbitIndex orbitCandidate
  change
    PatchSentence.literal
        (containsAtom
          (Nat.succ n :: descendingSupport n)
          (Nat.succ n)) =
      PatchSentence.literal true
  rw [containsAtom_cons_self]

/-- The next candidate agrees with semantics at the repaired index. -/
theorem orbitNext_repairs_current (n : Nat) :
    constructivePatchableTarskiContext.truthAt
        (orbitCandidate (Nat.succ n))
        (orbitIndex n) ↔
      patchModels (orbitIndex n) := by
  change
    patchModels
        (patchApplyQuote
          (orbitCandidate (Nat.succ n))
          (orbitIndex n)) ↔
      patchModels (orbitIndex n)
  rw [orbitNext_current_application_true]
  constructor
  · intro _
    exact True.intro
  · intro _
    rfl

/-- A later candidate accepts every strictly earlier challenge. -/
theorem orbitCandidate_accepts_previous
    {k n : Nat}
    (earlier : k < n) :
    constructivePatchableTarskiContext.truthAt
      (orbitCandidate n)
      (orbitIndex k) := by
  change
    containsAtom (descendingSupport n) (Nat.succ k) = true
  exact containsAtom_descendingSupport_of_lt earlier

/-- A later candidate remains semantically correct at every repaired index. -/
theorem orbitCandidate_agrees_previous
    {k n : Nat}
    (earlier : k < n) :
    constructivePatchableTarskiContext.truthAt
        (orbitCandidate n)
        (orbitIndex k) ↔
      patchModels (orbitIndex k) := by
  constructor
  · intro _
    exact orbitIndex_models k
  · intro _
    exact orbitCandidate_accepts_previous earlier

/-- The positive local mismatch carried by the rank-`n` candidate. -/
def orbitLocalMismatch (n : Nat) :
    LocalTruthMismatch
      PatchSentence
      (constructivePatchableTarskiContext.truthAt (orbitCandidate n))
      patchModels :=
  (constructivePatchableTarskiContext.step (orbitCandidate n)).mismatch

/-- The mismatch at rank `n` is indexed by the canonical current challenge. -/
theorem orbitLocalMismatch_index_eq (n : Nat) :
    (orbitLocalMismatch n).index = orbitIndex n := by
  change patchDiagonal (orbitCandidate n) = orbitIndex n
  exact patchDiagonal_orbitCandidate n

/-! ## Global separation and absence of return -/

/-- Canonical indices determine their ranks. -/
theorem orbitIndex_injective
    {k n : Nat}
    (sameIndex : orbitIndex k = orbitIndex n) :
    k = n := by
  have sameSuccessor : Nat.succ k = Nat.succ n :=
    PatchSentence.atom.inj sameIndex
  exact Nat.succ.inj sameSuccessor

/-- Canonical candidates determine their ranks through support length. -/
theorem orbitCandidate_injective
    {k n : Nat}
    (sameCandidate : orbitCandidate k = orbitCandidate n) :
    k = n := by
  have sameSupport : descendingSupport k = descendingSupport n :=
    congrArg PatchCandidate.acceptedAtoms sameCandidate
  calc
    k = (descendingSupport k).length :=
      (descendingSupport_length k).symm
    _ = (descendingSupport n).length :=
      congrArg List.length sameSupport
    _ = n :=
      descendingSupport_length n

/-- Syntax-level iteration is injective in the iteration rank. -/
theorem syntaxOrbit_injective
    {k n : Nat}
    (sameIterate :
      constructivePatchableTarskiContext.iteratePredicate
          k
          initialPatchCandidate =
        constructivePatchableTarskiContext.iteratePredicate
          n
          initialPatchCandidate) :
    k = n := by
  apply orbitCandidate_injective
  rw [← iteratePredicate_initial_eq_orbitCandidate k]
  rw [← iteratePredicate_initial_eq_orbitCandidate n]
  exact sameIterate

/-- Gap-driven dynamic iteration is injective in the iteration rank. -/
theorem dynamicOrbit_injective
    {k n : Nat}
    (sameIterate :
      (tarskiPatchGapDrivenDynamicSystem
        constructivePatchableTarskiContext
        initialPatchCandidate).iterateSource
          k
          initialPatchCandidate =
        (tarskiPatchGapDrivenDynamicSystem
          constructivePatchableTarskiContext
          initialPatchCandidate).iterateSource
            n
            initialPatchCandidate) :
    k = n := by
  apply orbitCandidate_injective
  rw [← dynamicIterate_initial_eq_orbitCandidate k]
  rw [← dynamicIterate_initial_eq_orbitCandidate n]
  exact sameIterate

/-- Left cancellation for addition, proved here without algebraic typeclasses. -/
theorem nat_add_left_cancel_constructive
    {base left right : Nat}
    (sameSum : base + left = base + right) :
    left = right := by
  induction base with
  | zero =>
      rw [Nat.zero_add, Nat.zero_add] at sameSum
      exact sameSum
  | succ base inductionHypothesis =>
      rw [Nat.succ_add, Nat.succ_add] at sameSum
      exact inductionHypothesis (Nat.succ.inj sameSum)

/-- This concrete orbit has no positive exact period. -/
theorem dynamicOrbit_noExactReturn
    (n period : Nat)
    (positivePeriod : 0 < period)
    (sameState :
      (tarskiPatchGapDrivenDynamicSystem
        constructivePatchableTarskiContext
        initialPatchCandidate).iterateSource
          (n + period)
          initialPatchCandidate =
        (tarskiPatchGapDrivenDynamicSystem
          constructivePatchableTarskiContext
          initialPatchCandidate).iterateSource
            n
            initialPatchCandidate) :
    False := by
  have sameRank : n + period = n :=
    dynamicOrbit_injective sameState
  have period_eq_zero : period = 0 := by
    apply nat_add_left_cancel_constructive (base := n)
    exact sameRank.trans (Nat.add_zero n).symm
  cases period_eq_zero
  exact Nat.lt_irrefl 0 positivePeriod

/-! ## Closed orbit theorem -/

/--
All global invariants of the concrete causal orbit, with no externally chosen
transition, rank certificate, freshness witness, or terminal bridge.
-/
structure ConstructiveTarskiOrbitTheorem where
  exactSyntaxOrbit :
    ∀ n : Nat,
      constructivePatchableTarskiContext.iteratePredicate
          n
          initialPatchCandidate =
        orbitCandidate n
  exactDynamicOrbit :
    ∀ n : Nat,
      (tarskiPatchGapDrivenDynamicSystem
        constructivePatchableTarskiContext
        initialPatchCandidate).iterateSource
          n
          initialPatchCandidate =
        orbitCandidate n
  exactIndex :
    ∀ n : Nat,
      patchDiagonal (orbitCandidate n) = orbitIndex n
  cumulativeAgreement :
    ∀ {k n : Nat},
      k < n ->
        (constructivePatchableTarskiContext.truthAt
            (orbitCandidate n)
            (orbitIndex k) ↔
          patchModels (orbitIndex k))
  currentRejected :
    ∀ n : Nat,
      constructivePatchableTarskiContext.truthAt
          (orbitCandidate n)
          (orbitIndex n) ->
        False
  nextRepairsCurrent :
    ∀ n : Nat,
      constructivePatchableTarskiContext.truthAt
          (orbitCandidate (Nat.succ n))
          (orbitIndex n) ↔
        patchModels (orbitIndex n)
  mismatchAt :
    ∀ n : Nat,
      LocalTruthMismatch
        PatchSentence
        (constructivePatchableTarskiContext.truthAt (orbitCandidate n))
        patchModels
  mismatchIndex :
    ∀ n : Nat,
      (mismatchAt n).index = orbitIndex n
  indicesSeparated :
    ∀ {k n : Nat}, orbitIndex k = orbitIndex n -> k = n
  candidatesSeparated :
    ∀ {k n : Nat}, orbitCandidate k = orbitCandidate n -> k = n
  syntaxOrbitSeparated :
    ∀ {k n : Nat},
      constructivePatchableTarskiContext.iteratePredicate
          k
          initialPatchCandidate =
        constructivePatchableTarskiContext.iteratePredicate
          n
          initialPatchCandidate ->
        k = n
  dynamicOrbitSeparated :
    ∀ {k n : Nat},
      (tarskiPatchGapDrivenDynamicSystem
        constructivePatchableTarskiContext
        initialPatchCandidate).iterateSource
          k
          initialPatchCandidate =
        (tarskiPatchGapDrivenDynamicSystem
          constructivePatchableTarskiContext
          initialPatchCandidate).iterateSource
            n
            initialPatchCandidate ->
        k = n
  noExactReturn :
    ∀ n period : Nat,
      0 < period ->
        (tarskiPatchGapDrivenDynamicSystem
          constructivePatchableTarskiContext
          initialPatchCandidate).iterateSource
            (n + period)
            initialPatchCandidate =
          (tarskiPatchGapDrivenDynamicSystem
            constructivePatchableTarskiContext
            initialPatchCandidate).iterateSource
              n
              initialPatchCandidate ->
          False
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

/-- Closed inhabitant of the exact orbit theorem. -/
def constructiveTarskiOrbitTheorem :
    ConstructiveTarskiOrbitTheorem where
  exactSyntaxOrbit := iteratePredicate_initial_eq_orbitCandidate
  exactDynamicOrbit := dynamicIterate_initial_eq_orbitCandidate
  exactIndex := patchDiagonal_orbitCandidate
  cumulativeAgreement := orbitCandidate_agrees_previous
  currentRejected := orbitCandidate_rejects_current
  nextRepairsCurrent := orbitNext_repairs_current
  mismatchAt := orbitLocalMismatch
  mismatchIndex := orbitLocalMismatch_index_eq
  indicesSeparated := orbitIndex_injective
  candidatesSeparated := orbitCandidate_injective
  syntaxOrbitSeparated := syntaxOrbit_injective
  dynamicOrbitSeparated := dynamicOrbit_injective
  noExactReturn := dynamicOrbit_noExactReturn
  everyIterateIncomplete :=
    dynamicIteratedPatchCandidate_notGloballyCorrect

end ConstructivePatchModel
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ConstructivePatchModel.descendingSupport
#print axioms Meta.ConstructivePatchModel.containsAtom_descendingSupport_iff
#print axioms Meta.ConstructivePatchModel.maximumAtom_descendingSupport
#print axioms Meta.ConstructivePatchModel.orbitCandidate
#print axioms Meta.ConstructivePatchModel.orbitIndex
#print axioms Meta.ConstructivePatchModel.iteratePredicate_initial_eq_orbitCandidate
#print axioms Meta.ConstructivePatchModel.dynamicIterate_initial_eq_orbitCandidate
#print axioms Meta.ConstructivePatchModel.orbitCandidate_agrees_previous
#print axioms Meta.ConstructivePatchModel.orbitLocalMismatch
#print axioms Meta.ConstructivePatchModel.orbitIndex_injective
#print axioms Meta.ConstructivePatchModel.orbitCandidate_injective
#print axioms Meta.ConstructivePatchModel.syntaxOrbit_injective
#print axioms Meta.ConstructivePatchModel.dynamicOrbit_injective
#print axioms Meta.ConstructivePatchModel.dynamicOrbit_noExactReturn
#print axioms Meta.ConstructivePatchModel.ConstructiveTarskiOrbitTheorem
#print axioms Meta.ConstructivePatchModel.constructiveTarskiOrbitTheorem
/- AXIOM_AUDIT_END -/
