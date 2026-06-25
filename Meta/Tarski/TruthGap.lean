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
  rcases candidate with ⟨tau, definesTruth⟩
  exact
    tarski_undefinability_core
      (context.fixedPoint tau)
      (context.truthDefinitionOfPredicate tau definesTruth)

end ArithmeticTarskiContext

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
#print axioms Meta.ClosedStabilityTheorem.tarski_undefinability_equiv_exact_projective
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.truthAt
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.fixedPoint
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.truthDefinitionOfPredicate
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.exactProjectedTruthDefinitionOfPredicate
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.undefinability_of_truth
#print axioms Meta.ClosedStabilityTheorem.ArithmeticTarskiContext.undefinability_of_truth_via_projective_corollary
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
