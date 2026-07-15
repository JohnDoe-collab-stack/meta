import Meta.Core.ClosedStabilityTheorem

/-!
# Tarski truth gap as a projective corollary

This file records the Tarski diagonal obstruction in the internal language of
the standalone meta layer.

The visible side is syntax.  The enriched side is the semantic/interface
carrier.  A Tarski diagonal gap is exactly the situation where the same visible
syntax is carried by two distinct interfaces, while truth separates the formed
interface from its syntactic shadow.

The corollary is therefore not a slogan: such a gap is a direct instance of the
projective obstruction already proved by the closed-stability package.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v

/-!
## Tarski diagonal obstruction
-/

/-!
## Tarski fixed-point core
-/

/--
The diagonal fixed point used by Tarski's undefinability argument.

`Holds` is the semantic predicate on sentences and `TruthAt` is the candidate
truth predicate living on the syntactic side.  The fixed point says that the
liar sentence holds exactly when its own truth predicate does not hold.
-/
structure TarskiDiagonalFixedPoint
    (Sentence : Type u)
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) where
  liar : Sentence
  liar_spec :
    Holds liar ↔ (TruthAt liar -> False)

/--
A syntactic truth definition for a semantic predicate.

This is the exact interface refuted by the diagonal fixed point: `TruthAt`
would define `Holds` sentence by sentence.
-/
structure TarskiTruthDefinition
    {Sentence : Type u}
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) :
    Prop where
  correct :
    (sentence : Sentence) ->
      TruthAt sentence ↔ Holds sentence

/--
Exact projective truth definition.

Unlike `ProjectedTruthDefinition` below, the visible truth predicate is fixed in
the type.  This is the form needed to compare the projective statement exactly
with Tarski's ordinary truth-definition statement.
-/
structure ExactProjectedTruthDefinition
    {Syntax : Type u}
    {Meaning : Type v}
    (project : Meaning -> Syntax)
    (Truth : Meaning -> Prop)
    (truthAt : Syntax -> Prop) :
    Prop where
  correct :
    (meaning : Meaning) ->
      truthAt (project meaning) ↔ Truth meaning

/--
The two-interface carrier used to read Tarski's theorem projectively.

`semantic sentence` is the enriched semantic/interface side.  `syntactic
sentence` is the visible truth-predicate shadow over the same syntactic code.
-/
inductive TarskiInterface
    (Sentence : Type u) :
    Type u where
  | semantic : Sentence -> TarskiInterface Sentence
  | syntactic : Sentence -> TarskiInterface Sentence

namespace TarskiInterface

/-- Forget the semantic/syntactic role and keep only the visible sentence. -/
def project
    {Sentence : Type u} :
    TarskiInterface Sentence -> Sentence
  | semantic sentence => sentence
  | syntactic sentence => sentence

/-- Truth on the enriched Tarski interface. -/
def truth
    {Sentence : Type u}
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) :
    TarskiInterface Sentence -> Prop
  | semantic sentence => Holds sentence
  | syntactic sentence => TruthAt sentence

end TarskiInterface

/--
Tarski's ordinary truth definition is exactly an exact projected truth
definition over the semantic/syntactic interface.
-/
theorem tarskiTruthDefinition_iff_exactProjectedTruthDefinition
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop} :
    TarskiTruthDefinition TruthAt Holds ↔
      ExactProjectedTruthDefinition
        (@TarskiInterface.project Sentence)
        (TarskiInterface.truth TruthAt Holds)
        TruthAt := by
  constructor
  · intro definition
    refine ⟨?_⟩
    intro interface
    cases interface with
    | semantic sentence =>
        exact definition.correct sentence
    | syntactic sentence =>
        exact Iff.rfl
  · intro definition
    refine ⟨?_⟩
    intro sentence
    exact
      definition.correct
        (TarskiInterface.semantic sentence)

/--
Tarski undefinability core, constructively.

If a sentence has the diagonal fixed-point property
`Holds liar ↔ ¬ TruthAt liar`, then `TruthAt` cannot define `Holds`.
-/
theorem tarski_undefinability_core
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (fixedPoint :
      TarskiDiagonalFixedPoint Sentence TruthAt Holds)
    (definition :
      TarskiTruthDefinition TruthAt Holds) :
    False := by
  have hNotTruth :
      TruthAt fixedPoint.liar -> False := by
    intro hTruth
    have hHolds :
        Holds fixedPoint.liar :=
      (definition.correct fixedPoint.liar).mp hTruth
    exact
      (fixedPoint.liar_spec.mp hHolds)
        hTruth
  have hHolds :
      Holds fixedPoint.liar :=
    fixedPoint.liar_spec.mpr hNotTruth
  have hTruth :
      TruthAt fixedPoint.liar :=
    (definition.correct fixedPoint.liar).mpr hHolds
  exact hNotTruth hTruth

/--
Local Tarski mismatch, obtained from the fixed point alone.

No global truth definition is assumed here.  The fixed point already refutes
agreement between the candidate truth predicate and semantic holding at the
liar sentence.
-/
theorem tarski_local_mismatch
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (fixedPoint :
      TarskiDiagonalFixedPoint Sentence TruthAt Holds) :
    (TruthAt fixedPoint.liar ↔ Holds fixedPoint.liar) ->
      False := by
  intro correct
  have hNotTruth :
      TruthAt fixedPoint.liar -> False := by
    intro hTruth
    have hHolds :
        Holds fixedPoint.liar :=
      correct.mp hTruth
    exact
      (fixedPoint.liar_spec.mp hHolds)
        hTruth
  have hHolds :
      Holds fixedPoint.liar :=
    fixedPoint.liar_spec.mpr hNotTruth
  have hTruth :
      TruthAt fixedPoint.liar :=
    correct.mpr hHolds
  exact hNotTruth hTruth

/--
Positive Tarski diagonal data.

This is the inhabited object extracted from a fixed point alone: an explicit
visible index, semantic and syntactic poles over that index, their separation,
the fixed-point specification, and the local mismatch certificate.
-/
structure TarskiPositiveDiagonal
    (Sentence : Type u)
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) where
  index : Sentence
  formed : TarskiInterface Sentence
  shadow : TarskiInterface Sentence
  formed_is_semantic :
    formed = TarskiInterface.semantic index
  shadow_is_syntactic :
    shadow = TarskiInterface.syntactic index
  formed_projects :
    (@TarskiInterface.project Sentence) formed = index
  shadow_projects :
    (@TarskiInterface.project Sentence) shadow = index
  separated :
    formed = shadow -> False
  fixedPointSpec :
    Holds index ↔ (TruthAt index -> False)
  mismatch :
    (TruthAt index ↔ Holds index) -> False

/-- The positive diagonal produced by a Tarski fixed point. -/
def tarskiPositiveDiagonalOfFixedPoint
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (fixedPoint :
      TarskiDiagonalFixedPoint Sentence TruthAt Holds) :
    TarskiPositiveDiagonal Sentence TruthAt Holds where
  index := fixedPoint.liar
  formed := TarskiInterface.semantic fixedPoint.liar
  shadow := TarskiInterface.syntactic fixedPoint.liar
  formed_is_semantic := rfl
  shadow_is_syntactic := rfl
  formed_projects := rfl
  shadow_projects := rfl
  separated := by
    intro h
    cases h
  fixedPointSpec := fixedPoint.liar_spec
  mismatch := tarski_local_mismatch fixedPoint

/--
Local truth mismatch over the two Tarski interfaces.

Unlike `TarskiDiagonalObstruction`, this does not orient the local truth values
as `formed true` and `shadow false`; it only stores the constructive failure of
agreement, which is exactly what the fixed point provides without extra
decidability.
-/
structure LocalTruthMismatch
    (Sentence : Type u)
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) where
  index : Sentence
  semantic : TarskiInterface Sentence
  syntactic : TarskiInterface Sentence
  sameSyntax :
    (@TarskiInterface.project Sentence) semantic =
      (@TarskiInterface.project Sentence) syntactic
  semantic_projects :
    (@TarskiInterface.project Sentence) semantic = index
  syntactic_projects :
    (@TarskiInterface.project Sentence) syntactic = index
  separated :
    semantic = syntactic -> False
  noAgreement :
    (TarskiInterface.truth TruthAt Holds syntactic ↔
      TarskiInterface.truth TruthAt Holds semantic) ->
        False

/-- A positive diagonal exposes its local truth mismatch. -/
def TarskiPositiveDiagonal.localTruthMismatch
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (diagonal :
      TarskiPositiveDiagonal Sentence TruthAt Holds) :
    LocalTruthMismatch Sentence TruthAt Holds where
  index := diagonal.index
  semantic := diagonal.formed
  syntactic := diagonal.shadow
  sameSyntax :=
    diagonal.formed_projects.trans
      diagonal.shadow_projects.symm
  semantic_projects := diagonal.formed_projects
  syntactic_projects := diagonal.shadow_projects
  separated := diagonal.separated
  noAgreement := by
    intro agreement
    rw [diagonal.shadow_is_syntactic, diagonal.formed_is_semantic] at agreement
    exact diagonal.mismatch agreement

/-- The local truth mismatch produced by a fixed point. -/
def localTruthMismatchOfFixedPoint
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (fixedPoint :
      TarskiDiagonalFixedPoint Sentence TruthAt Holds) :
    LocalTruthMismatch Sentence TruthAt Holds :=
  (tarskiPositiveDiagonalOfFixedPoint fixedPoint).localTruthMismatch

/-! ## Positive refutation from the local diagonal -/

/--
A positive diagonal refutes any exact projected truth definition.

The contradiction is introduced only when a global projected definition is
confronted with the already inhabited local mismatch.
-/
theorem TarskiPositiveDiagonal.refutesExactProjectedTruthDefinition
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (diagonal :
      TarskiPositiveDiagonal Sentence TruthAt Holds)
    (definition :
      ExactProjectedTruthDefinition
        (@TarskiInterface.project Sentence)
        (TarskiInterface.truth TruthAt Holds)
        TruthAt) :
    False :=
  diagonal.mismatch
    (definition.correct
      (TarskiInterface.semantic diagonal.index))

/-- A positive diagonal refutes an ordinary Tarski truth definition. -/
theorem TarskiPositiveDiagonal.refutesTruthDefinition
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (diagonal :
      TarskiPositiveDiagonal Sentence TruthAt Holds)
    (definition :
      TarskiTruthDefinition TruthAt Holds) :
    False :=
  diagonal.mismatch
    (definition.correct diagonal.index)

/--
The ordinary Tarski refutation is equivalent to the exact projective
refutation over the semantic/syntactic interface.
-/
theorem tarski_undefinability_equiv_exact_projective
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop} :
    ((definition : TarskiTruthDefinition TruthAt Holds) ->
      False)
    ↔
    ((definition :
      ExactProjectedTruthDefinition
        (@TarskiInterface.project Sentence)
        (TarskiInterface.truth TruthAt Holds)
        TruthAt) ->
      False) := by
  constructor
  · intro refutesTarski definition
    exact
      refutesTarski
        ((tarskiTruthDefinition_iff_exactProjectedTruthDefinition).mpr
          definition)
  · intro refutesProjective definition
    exact
      refutesProjective
        ((tarskiTruthDefinition_iff_exactProjectedTruthDefinition).mp
          definition)

/-!
## Arithmetic Tarski form
-/

/--
Internal arithmetic Tarski context.

This is the exact shape of the formalized arithmetic statement:

* `Sentence` is the sentence type;
* `Predicate` is the type of unary arithmetical predicates;
* `applyQuote τ σ` is the sentence written externally as `τ/[⌜σ⌝]`;
* `models` is truth in the intended model;
* `diagonal τ` is the fixed point for `τ`.
-/
structure ArithmeticTarskiContext :
    Type (max (u + 1) (v + 1)) where
  Sentence : Type u
  Predicate : Type v
  applyQuote : Predicate -> Sentence -> Sentence
  models : Sentence -> Prop
  diagonal : Predicate -> Sentence
  diagonal_spec :
    (tau : Predicate) ->
      models (diagonal tau) ↔
        (models (applyQuote tau (diagonal tau)) -> False)

namespace ArithmeticTarskiContext

/-- The candidate truth predicate induced by an arithmetical predicate. -/
def truthAt
    (context : ArithmeticTarskiContext.{u, v})
    (tau : context.Predicate) :
    context.Sentence -> Prop :=
  fun sentence =>
    context.models (context.applyQuote tau sentence)

/-- The diagonal fixed point generated by an arithmetical predicate. -/
def fixedPoint
    (context : ArithmeticTarskiContext.{u, v})
    (tau : context.Predicate) :
    TarskiDiagonalFixedPoint
      context.Sentence
      (context.truthAt tau)
      context.models where
  liar := context.diagonal tau
  liar_spec := context.diagonal_spec tau

/--
An arithmetical predicate satisfying the usual truth-definition equation gives
the ordinary Tarski truth-definition interface.
-/
def truthDefinitionOfPredicate
    (context : ArithmeticTarskiContext.{u, v})
    (tau : context.Predicate)
    (definesTruth :
      (sentence : context.Sentence) ->
        context.models sentence ↔
          context.models (context.applyQuote tau sentence)) :
    TarskiTruthDefinition
      (context.truthAt tau)
      context.models where
  correct := by
    intro sentence
    exact (definesTruth sentence).symm

/--
The same arithmetical truth-definition equation, read as an exact projective
truth definition over the semantic/syntactic Tarski interface.
-/
def exactProjectedTruthDefinitionOfPredicate
    (context : ArithmeticTarskiContext.{u, v})
    (tau : context.Predicate)
    (definesTruth :
      (sentence : context.Sentence) ->
        context.models sentence ↔
          context.models (context.applyQuote tau sentence)) :
    ExactProjectedTruthDefinition
      (@TarskiInterface.project context.Sentence)
      (TarskiInterface.truth (context.truthAt tau) context.models)
      (context.truthAt tau) :=
  (tarskiTruthDefinition_iff_exactProjectedTruthDefinition).mp
    (context.truthDefinitionOfPredicate tau definesTruth)

/--
Positive arithmetic Tarski counterexample extractor.

For every candidate predicate `tau`, it returns the diagonal sentence on which
the intended truth equation fails.  The usual negative undefinability theorem
is recovered by applying a globally correct candidate to this explicit
counterexample.
-/
def explicitTruthCounterexample
    (context : ArithmeticTarskiContext.{u, v})
    (tau : context.Predicate) :
    { sentence : context.Sentence //
        (context.models sentence ↔
          context.models (context.applyQuote tau sentence)) ->
            False } :=
  ⟨ context.diagonal tau
  , fun agreement =>
      tarski_local_mismatch
        (context.fixedPoint tau)
        (Iff.symm agreement)
  ⟩

/--
Tarski's undefinability theorem in the arithmetic shape:
there is no arithmetical predicate `tau` such that every sentence has the same
truth value as `tau/[⌜sentence⌝]`.
-/
theorem undefinability_of_truth
    (context : ArithmeticTarskiContext.{u, v}) :
    (∃ tau : context.Predicate,
      (sentence : context.Sentence) ->
        context.models sentence ↔
          context.models (context.applyQuote tau sentence)) ->
      False := by
  intro candidate
  cases candidate with
  | intro tau definesTruth =>
      exact
        (context.explicitTruthCounterexample tau).property
          (definesTruth
            (context.explicitTruthCounterexample tau).val)

/-- The negative arithmetic theorem obtained from the positive extractor. -/
theorem undefinability_of_truth_via_explicitCounterexample
    (context : ArithmeticTarskiContext.{u, v}) :
    (∃ tau : context.Predicate,
      (sentence : context.Sentence) ->
        context.models sentence ↔
          context.models (context.applyQuote tau sentence)) ->
      False := by
  intro candidate
  cases candidate with
  | intro tau definesTruth =>
      exact
        (context.explicitTruthCounterexample tau).property
          (definesTruth
            (context.explicitTruthCounterexample tau).val)

/-- Compatibility proof: the original core still follows directly. -/
theorem undefinability_of_truth_via_truthDefinition
    (context : ArithmeticTarskiContext.{u, v}) :
    (∃ tau : context.Predicate,
      (sentence : context.Sentence) ->
        context.models sentence ↔
          context.models (context.applyQuote tau sentence)) ->
      False := by
  intro candidate
  cases candidate with
  | intro tau definesTruth =>
      exact
        tarski_undefinability_core
          (context.fixedPoint tau)
          (context.truthDefinitionOfPredicate tau definesTruth)

end ArithmeticTarskiContext

/-! ## Syntax-level patchable Tarski dynamics -/

/--
An arithmetic Tarski context whose syntactic predicate regime is internally
closed under local diagonal repair.

The patch operation stays inside `Predicate`: it is not an external semantic
replacement of the candidate.  At the patched sentence it agrees with
`models`; away from that sentence it preserves the previous candidate.
-/
structure PatchableArithmeticTarskiContext :
    Type (max (u + 1) (v + 1)) where
  context : ArithmeticTarskiContext.{u, v}
  patchPredicate :
    context.Predicate -> context.Sentence -> context.Predicate
  patch_agrees_at :
    (tau : context.Predicate) ->
      (index : context.Sentence) ->
        context.models
          (context.applyQuote (patchPredicate tau index) index) ↔
            context.models index
  patch_preserves_off_index :
    (tau : context.Predicate) ->
      (index sentence : context.Sentence) ->
        (sentence = index -> False) ->
          (context.models
            (context.applyQuote (patchPredicate tau index) sentence) ↔
              context.models (context.applyQuote tau sentence))

namespace PatchableArithmeticTarskiContext

/-- The candidate truth predicate induced by a syntactic predicate. -/
def truthAt
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (tau : patchable.context.Predicate) :
    patchable.context.Sentence -> Prop :=
  patchable.context.truthAt tau

/-- The current diagonal challenge for a syntactic candidate. -/
def diagonalSentence
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (tau : patchable.context.Predicate) :
    patchable.context.Sentence :=
  patchable.context.diagonal tau

/-- The next syntactic candidate produced by local diagonal repair. -/
def nextPredicate
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (tau : patchable.context.Predicate) :
    patchable.context.Predicate :=
  patchable.patchPredicate tau (patchable.diagonalSentence tau)

/--
One syntax-level algorithmic Tarski step.

The step remains inside the syntactic predicate type.  It records the current
diagonal challenge, performs the internal patch, proves local repair at the
challenged sentence, proves preservation away from it, and exposes the next
diagonal challenge.
-/
structure AlgorithmStep
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (tau : patchable.context.Predicate) :
    Type (max u v) where
  diagonalSentence :
    patchable.context.Sentence
  diagonalSentence_eq :
    diagonalSentence = patchable.diagonalSentence tau
  fixedPoint :
    TarskiDiagonalFixedPoint
      patchable.context.Sentence
      (patchable.truthAt tau)
      patchable.context.models
  mismatch :
    LocalTruthMismatch
      patchable.context.Sentence
      (patchable.truthAt tau)
      patchable.context.models
  nextPredicate :
    patchable.context.Predicate
  nextPredicate_eq_patch :
    nextPredicate =
      patchable.patchPredicate tau diagonalSentence
  repaired_index_agreement :
    patchable.truthAt nextPredicate diagonalSentence ↔
      patchable.context.models diagonalSentence
  preserves_off_index :
    (sentence : patchable.context.Sentence) ->
      (sentence = diagonalSentence -> False) ->
        (patchable.truthAt nextPredicate sentence ↔
          patchable.truthAt tau sentence)
  nextFixedPoint :
    TarskiDiagonalFixedPoint
      patchable.context.Sentence
      (patchable.truthAt nextPredicate)
      patchable.context.models
  nextMismatch :
    LocalTruthMismatch
      patchable.context.Sentence
      (patchable.truthAt nextPredicate)
      patchable.context.models

/-- The canonical syntax-level algorithmic step. -/
def step
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (tau : patchable.context.Predicate) :
    patchable.AlgorithmStep tau :=
  let index := patchable.diagonalSentence tau
  let next := patchable.nextPredicate tau
  let nextFixedPoint := patchable.context.fixedPoint next
  { diagonalSentence := index
    diagonalSentence_eq := rfl
    fixedPoint := patchable.context.fixedPoint tau
    mismatch :=
      localTruthMismatchOfFixedPoint
        (patchable.context.fixedPoint tau)
    nextPredicate := next
    nextPredicate_eq_patch := rfl
    repaired_index_agreement :=
      patchable.patch_agrees_at tau index
    preserves_off_index := by
      intro sentence offIndex
      exact
        patchable.patch_preserves_off_index
          tau
          index
          sentence
          offIndex
    nextFixedPoint := nextFixedPoint
    nextMismatch :=
      localTruthMismatchOfFixedPoint nextFixedPoint }

/-- Iterate the syntax-level repair algorithm on syntactic predicates. -/
def iteratePredicate
    (patchable : PatchableArithmeticTarskiContext.{u, v}) :
    Nat -> patchable.context.Predicate -> patchable.context.Predicate
  | 0, tau =>
      tau
  | Nat.succ n, tau =>
      patchable.nextPredicate
        (patchable.iteratePredicate n tau)

/-- The syntax-level step at a chosen iteration. -/
def iterationStep
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initialPredicate : patchable.context.Predicate)
    (n : Nat) :
    patchable.AlgorithmStep
      (patchable.iteratePredicate n initialPredicate) :=
  patchable.step
    (patchable.iteratePredicate n initialPredicate)

/-- Each syntax-level iteration locally repairs its current diagonal sentence. -/
theorem iterationStep_repairs_current_index
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initialPredicate : patchable.context.Predicate)
    (n : Nat) :
    let step := patchable.iterationStep initialPredicate n
    patchable.truthAt step.nextPredicate step.diagonalSentence ↔
      patchable.context.models step.diagonalSentence := by
  exact
    (patchable.iterationStep initialPredicate n).repaired_index_agreement

/--
Each syntax-level iteration preserves the previous predicate away from the
current diagonal sentence.
-/
theorem iterationStep_preserves_off_current_index
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initialPredicate : patchable.context.Predicate)
    (n : Nat)
    (sentence : patchable.context.Sentence) :
    (sentence =
      (patchable.iterationStep initialPredicate n).diagonalSentence ->
        False) ->
      (patchable.truthAt
        (patchable.iterationStep initialPredicate n).nextPredicate
        sentence ↔
          patchable.truthAt
            (patchable.iteratePredicate n initialPredicate)
            sentence) :=
  PatchableArithmeticTarskiContext.AlgorithmStep.preserves_off_index
    (patchable.iterationStep initialPredicate n)
    sentence

/--
No syntactic predicate in a patchable Tarski context can globally define
semantic truth.
-/
theorem truthAt_notGloballyCorrect
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (tau : patchable.context.Predicate)
    (definition :
      TarskiTruthDefinition
        (patchable.truthAt tau)
        patchable.context.models) :
    False :=
  tarski_undefinability_core
    (patchable.context.fixedPoint tau)
    definition

/--
The usual arithmetic equation form of global correctness is also refuted.
-/
theorem predicate_notGloballyCorrect
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (tau : patchable.context.Predicate)
    (definesTruth :
      (sentence : patchable.context.Sentence) ->
        patchable.context.models sentence ↔
          patchable.truthAt tau sentence) :
    False :=
  patchable.truthAt_notGloballyCorrect
    tau
    { correct := by
        intro sentence
        exact (definesTruth sentence).symm }

/--
No iterated syntactic candidate is globally correct.
-/
theorem iteratedPredicate_notGloballyCorrect
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initialPredicate : patchable.context.Predicate)
    (n : Nat)
    (definesTruth :
      (sentence : patchable.context.Sentence) ->
        patchable.context.models sentence ↔
          patchable.truthAt
            (patchable.iteratePredicate n initialPredicate)
            sentence) :
    False :=
  patchable.predicate_notGloballyCorrect
    (patchable.iteratePredicate n initialPredicate)
    definesTruth

/--
In particular, the next predicate produced by any step is not terminally
correct.
-/
theorem step_nextPredicate_notGloballyCorrect
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (tau : patchable.context.Predicate)
    (definesTruth :
      (sentence : patchable.context.Sentence) ->
        patchable.context.models sentence ↔
          patchable.truthAt (patchable.step tau).nextPredicate sentence) :
    False :=
  patchable.predicate_notGloballyCorrect
    (patchable.step tau).nextPredicate
    definesTruth

end PatchableArithmeticTarskiContext

/-- The unit repair carried by the pure Tarski corollary. -/
def TarskiTruthRepair
    {Meaning : Type v}
    (_interface : Meaning) :
    Type :=
  Unit

/--
Tarski's diagonal obstruction as projective gap data.

`Syntax` is the visible code layer, `Meaning` is the enriched semantic/interface
layer, and `project` forgets the semantic interface down to syntax.  The two
interfaces have the same visible syntax, but truth holds for the formed
interface and cannot hold for its syntactic shadow.
-/
structure TarskiDiagonalObstruction
    (Syntax : Type u)
    (Meaning : Type v)
    (project : Meaning -> Syntax)
    (Truth : Meaning -> Prop) where
  formed : Meaning
  shadow : Meaning
  sameSyntax :
    project formed = project shadow
  truth_formed :
    Truth formed
  shadow_not_truth :
    Truth shadow -> False

namespace TarskiDiagonalObstruction

/-!
## Syntactic truth definitions
-/

/--
A projected truth definition is a truth predicate living only on visible syntax,
whose pullback along `project` is supposed to define semantic/interface truth.
-/
structure ProjectedTruthDefinition
    {Syntax : Type u}
    {Meaning : Type v}
    (project : Meaning -> Syntax)
    (Truth : Meaning -> Prop) where
  truthAt : Syntax -> Prop
  correct :
    (meaning : Meaning) ->
      truthAt (project meaning) ↔ Truth meaning

/--
Tarski corollary in its direct truth-predicate form.

On a Tarski diagonal obstruction, no truth predicate living only on the visible
syntax can define the semantic/interface truth by pullback.
-/
theorem notProjectedTruthDefinable
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap : TarskiDiagonalObstruction Syntax Meaning project Truth)
    (definition : ProjectedTruthDefinition project Truth) :
    False := by
  have hSyntaxFormed :
      definition.truthAt (project gap.formed) :=
    (definition.correct gap.formed).mpr gap.truth_formed
  have hSyntaxShadow :
      definition.truthAt (project gap.shadow) := by
    rw [← gap.sameSyntax]
    exact hSyntaxFormed
  exact
    gap.shadow_not_truth
      ((definition.correct gap.shadow).mp hSyntaxShadow)

/--
Build the projective Tarski obstruction from the diagonal fixed point and the
exact projected truth definition.
-/
def ofFixedPointAndExactProjectedTruthDefinition
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (fixedPoint :
      TarskiDiagonalFixedPoint Sentence TruthAt Holds)
    (definition :
      ExactProjectedTruthDefinition
        (@TarskiInterface.project Sentence)
        (TarskiInterface.truth TruthAt Holds)
        TruthAt) :
    TarskiDiagonalObstruction
      Sentence
      (TarskiInterface Sentence)
      (@TarskiInterface.project Sentence)
      (TarskiInterface.truth TruthAt Holds) := by
  have hNotTruth :
      TruthAt fixedPoint.liar -> False := by
    intro hTruth
    have hHolds :
        Holds fixedPoint.liar :=
      (definition.correct
        (TarskiInterface.semantic fixedPoint.liar)).mp
        hTruth
    exact
      (fixedPoint.liar_spec.mp hHolds)
        hTruth
  have hHolds :
      Holds fixedPoint.liar :=
    fixedPoint.liar_spec.mpr hNotTruth
  exact
    { formed :=
        TarskiInterface.semantic fixedPoint.liar
      shadow :=
        TarskiInterface.syntactic fixedPoint.liar
      sameSyntax :=
        rfl
      truth_formed :=
        hHolds
      shadow_not_truth :=
        hNotTruth }

/--
Tarski's undefinability theorem as the projective corollary: the exact
projected truth definition produces the Tarski gap, and the projective
not-definability theorem consumes that gap.
-/
theorem exactProjectedTruthDefinition_refutedByProjectiveCorollary
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (fixedPoint :
      TarskiDiagonalFixedPoint Sentence TruthAt Holds)
    (definition :
      ExactProjectedTruthDefinition
        (@TarskiInterface.project Sentence)
        (TarskiInterface.truth TruthAt Holds)
        TruthAt) :
    False :=
  notProjectedTruthDefinable
    (ofFixedPointAndExactProjectedTruthDefinition
      fixedPoint
      definition)
    { truthAt :=
        TruthAt
      correct :=
        definition.correct }

/--
The usual Tarski core is obtained through the projective corollary after the
exact equivalence of truth-definition interfaces.
-/
theorem tarski_undefinability_core_via_projective_corollary
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (fixedPoint :
      TarskiDiagonalFixedPoint Sentence TruthAt Holds)
    (definition :
      TarskiTruthDefinition TruthAt Holds) :
    False :=
  exactProjectedTruthDefinition_refutedByProjectiveCorollary
    fixedPoint
    ((tarskiTruthDefinition_iff_exactProjectedTruthDefinition).mp
      definition)

/-- The Tarski diagonal obstruction is a local projective recovery gap. -/
def localRecovery
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap : TarskiDiagonalObstruction Syntax Meaning project Truth) :
    LocalProjectiveRecovery
      Meaning
      Syntax
      project
      (@TarskiTruthRepair Meaning) where
  formed := gap.formed
  shadow := gap.shadow
  sameProjection := gap.sameSyntax
  separated := by
    intro hEq
    have hShadowTruth : Truth gap.shadow := by
      rw [← hEq]
      exact gap.truth_formed
    exact gap.shadow_not_truth hShadowTruth
  repair := ()
  recovered := gap.formed
  recovered_eq_formed := rfl

/-- The same Tarski data as a local truth-gap recovery package. -/
def localTruthGapRecovery
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap : TarskiDiagonalObstruction Syntax Meaning project Truth) :
    LocalTruthGapRecovery
      Meaning
      Syntax
      project
      (@TarskiTruthRepair Meaning)
      Truth where
  localRecovery := gap.localRecovery
  formed_truth := gap.truth_formed
  shadow_not_truth := gap.shadow_not_truth

/--
Tarski corollary: a diagonal truth gap cannot be fiber-faithful after projection
to syntax.
-/
theorem notFiberFaithful
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap : TarskiDiagonalObstruction Syntax Meaning project Truth)
    (faithful : ProjectionFiberFaithful Meaning Syntax project) :
    False :=
  localProjectiveRecovery_notFiberFaithful
    gap.localRecovery
    faithful

/--
Tarski corollary: a diagonal truth gap cannot preserve all enriched information
through the syntactic projection.
-/
theorem notInformationConserving
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap : TarskiDiagonalObstruction Syntax Meaning project Truth)
    (conserving :
      ProjectionInformationConserving Meaning Syntax project) :
    False :=
  localProjectiveRecovery_notInformationConserving
    gap.localRecovery
    conserving

/--
The syntactic projection admits no projective reconstruction on the Tarski gap.
-/
def noProjectiveReconstruction
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap : TarskiDiagonalObstruction Syntax Meaning project Truth) :
    ((recover : Syntax -> Meaning) ->
      ((meaning : Meaning) ->
        recover (project meaning) = meaning) ->
          False) :=
  noProjectiveReconstructionOfLocalProjectiveRecovery
    gap.localRecovery

/--
The local truth profile forced by Tarski's gap: the formed scene has geometric
truth but not projected-local truth, while the shadow scene is projected-local
but not geometrically true.
-/
theorem localFormationProjectedTruthIndependent
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap : TarskiDiagonalObstruction Syntax Meaning project Truth) :
    (∃ scene : ReferentialScene Meaning,
      GeometricFormation Truth scene ∧
        (ProjectedLocalTruth project Truth scene -> False))
    ∧
    (∃ scene : ReferentialScene Meaning,
      ProjectedLocalTruth project Truth scene ∧
        (GeometricFormation Truth scene -> False)) :=
  localTruthGapRecovery_localFormation_projectedTruth_independent
    gap.localTruthGapRecovery

end TarskiDiagonalObstruction

namespace ArithmeticTarskiContext

/--
The same arithmetic undefinability theorem, explicitly routed through the
projective corollary.
-/
theorem undefinability_of_truth_via_projective_corollary
    (context : ArithmeticTarskiContext.{u, v}) :
    (∃ tau : context.Predicate,
      (sentence : context.Sentence) ->
        context.models sentence ↔
          context.models (context.applyQuote tau sentence)) ->
      False := by
  intro candidate
  rcases candidate with ⟨tau, definesTruth⟩
  exact
    TarskiDiagonalObstruction.exactProjectedTruthDefinition_refutedByProjectiveCorollary
      (context.fixedPoint tau)
      (context.exactProjectedTruthDefinitionOfPredicate tau definesTruth)

end ArithmeticTarskiContext

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalFixedPoint
#print axioms Meta.ClosedStabilityTheorem.TarskiTruthDefinition
#print axioms Meta.ClosedStabilityTheorem.ExactProjectedTruthDefinition
#print axioms Meta.ClosedStabilityTheorem.TarskiInterface
#print axioms Meta.ClosedStabilityTheorem.TarskiInterface.project
#print axioms Meta.ClosedStabilityTheorem.TarskiInterface.truth
#print axioms Meta.ClosedStabilityTheorem.tarskiTruthDefinition_iff_exactProjectedTruthDefinition
#print axioms Meta.ClosedStabilityTheorem.tarski_undefinability_core
#print axioms Meta.ClosedStabilityTheorem.tarski_local_mismatch
#print axioms Meta.ClosedStabilityTheorem.TarskiPositiveDiagonal
#print axioms Meta.ClosedStabilityTheorem.tarskiPositiveDiagonalOfFixedPoint
#print axioms Meta.ClosedStabilityTheorem.LocalTruthMismatch
#print axioms Meta.ClosedStabilityTheorem.TarskiPositiveDiagonal.localTruthMismatch
#print axioms Meta.ClosedStabilityTheorem.localTruthMismatchOfFixedPoint
#print axioms Meta.ClosedStabilityTheorem.TarskiPositiveDiagonal.refutesExactProjectedTruthDefinition
#print axioms Meta.ClosedStabilityTheorem.TarskiPositiveDiagonal.refutesTruthDefinition
#print axioms Meta.ClosedStabilityTheorem.tarski_undefinability_equiv_exact_projective
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.truthAt
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.fixedPoint
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.truthDefinitionOfPredicate
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.exactProjectedTruthDefinitionOfPredicate
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.explicitTruthCounterexample
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.undefinability_of_truth
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.undefinability_of_truth_via_explicitCounterexample
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.undefinability_of_truth_via_truthDefinition
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.undefinability_of_truth_via_projective_corollary
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.truthAt
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.diagonalSentence
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.nextPredicate
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.AlgorithmStep
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.step
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.iteratePredicate
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.iterationStep
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.iterationStep_repairs_current_index
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.iterationStep_preserves_off_current_index
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.truthAt_notGloballyCorrect
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.predicate_notGloballyCorrect
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.iteratedPredicate_notGloballyCorrect
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.step_nextPredicate_notGloballyCorrect
#print axioms Meta.ClosedStabilityTheorem.TarskiTruthRepair
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.ProjectedTruthDefinition
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.notProjectedTruthDefinable
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.ofFixedPointAndExactProjectedTruthDefinition
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.exactProjectedTruthDefinition_refutedByProjectiveCorollary
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.tarski_undefinability_core_via_projective_corollary
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.localRecovery
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.localTruthGapRecovery
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.notFiberFaithful
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.notInformationConserving
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.noProjectiveReconstruction
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.localFormationProjectedTruthIndependent
/- AXIOM_AUDIT_END -/
