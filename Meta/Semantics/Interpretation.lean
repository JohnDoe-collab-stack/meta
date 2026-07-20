import Meta.Semantics.AdmissiblePredicateDoctrine
import Meta.Semantics.RelaxedSyntax

/-!
# Interpretation of the independent relaxed syntax

Only atoms are assigned by an interpretation.  Composite terms, uses,
predicates, formulas, and judgments are evaluated recursively by the model.
-/

namespace Meta
namespace RelaxedSemantics

universe u v s t ta p q d r o sp cq w pd

/-- Constructive, proof-relevant evidence for an ambient proposition. -/
structure PropositionEvidence (proposition : Prop) : Type where
  evidence : proposition

/-- Assignment of syntax atoms to a contextual model and its doctrine. -/
structure RelaxedInterpretation
    {C : ContextCategory.{u, v}}
    (signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C)
    (L : IndexedTermLanguage.{u, v, s, t} C signature.Ty)
    (M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L)
    (D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M) where
  substitutionAtom :
    {delta gamma : C.Ctx} ->
    signature.SubstitutionAtom delta gamma ->
    C.Sub delta gamma
  termAtom :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    signature.TermAtom gamma A ->
    L.Term gamma A
  separationAtom :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    {left right : signature.TermAtom gamma A} ->
    signature.SeparationAtom left right ->
    M.Sep (termAtom left) (termAtom right)
  coordinationAtom :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    {left right : signature.TermAtom gamma A} ->
    signature.CoordinationAtom left right ->
    M.Coord (termAtom left) (termAtom right)
  predicateAtom :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    signature.PredicateAtom gamma A ->
    D.Pred gamma A

/-- Recursive interpretation of the freely generated substitutions. -/
def RelaxedInterpretation.interpretSubstitution
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D) :
    {delta gamma : C.Ctx} ->
    RelaxedSubstitution signature delta gamma ->
    C.Sub delta gamma
  | _, _, .identity gamma => C.identity gamma
  | _, _, .atom atom => interpretation.substitutionAtom atom
  | _, _, .compose first second =>
      C.compose
        (interpretation.interpretSubstitution first)
        (interpretation.interpretSubstitution second)

/-- Recursive interpretation of independent terms. -/
def RelaxedInterpretation.interpretTerm
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D) :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    RelaxedTerm signature gamma A ->
    L.Term gamma A
  | _, _, .atom atom => interpretation.termAtom atom
  | _, _, .reindex sigma term =>
      L.reindexTerm
        (interpretation.interpretSubstitution sigma)
        (interpretation.interpretTerm term)

/-- Strict syntax identity is interpreted as strict model-term equality. -/
def RelaxedInterpretation.interpretStrictIdentity
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D) :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    {x y : RelaxedTerm signature gamma A} ->
    StrictIdentityDerivation x y ->
    interpretation.interpretTerm x = interpretation.interpretTerm y
  | _, _, _, _, .refl _ => rfl
  | _, _, _, _, .symm proof =>
      (interpretation.interpretStrictIdentity proof).symm
  | _, _, _, _, .trans first second =>
      (interpretation.interpretStrictIdentity first).trans
        (interpretation.interpretStrictIdentity second)
  | _, _, _, _, .reindex sigma proof =>
      congrArg
        (L.reindexTerm (interpretation.interpretSubstitution sigma))
        (interpretation.interpretStrictIdentity proof)

/-- Recursive interpretation of separation derivations. -/
def RelaxedInterpretation.interpretSeparation
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D) :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    {x y : RelaxedTerm signature gamma A} ->
    SeparationDerivation x y ->
    M.Sep (interpretation.interpretTerm x) (interpretation.interpretTerm y)
  | _, _, _, _, .atom witness => interpretation.separationAtom witness
  | _, _, _, _, .reindex sigma proof =>
      M.reindexSep
        (interpretation.interpretSubstitution sigma)
        (interpretation.interpretSeparation proof)

/-- Recursive interpretation of coordination derivations. -/
def RelaxedInterpretation.interpretCoordination
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D) :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    {x y : RelaxedTerm signature gamma A} ->
    CoordinationDerivation x y ->
    M.Coord (interpretation.interpretTerm x) (interpretation.interpretTerm y)
  | _, _, _, _, .atom witness => interpretation.coordinationAtom witness
  | _, _, _, _, .reindex sigma proof =>
      M.reindexCoord
        (interpretation.interpretSubstitution sigma)
        (interpretation.interpretCoordination proof)

/-- Strict equality induces a model use without identifying the two notions. -/
def ContextualRelaxedRegime.useOfIdentity
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L)
    {gamma : C.Ctx}
    {A : Ty}
    {x y : L.Term gamma A}
    (identity : x = y) :
    M.Use x y := by
  cases identity
  exact M.identityUse x

/-- Every syntactic use computes a model-internal use witness. -/
def RelaxedInterpretation.interpretUse
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D) :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    {x y : RelaxedTerm signature gamma A} ->
    UseDerivation x y ->
    M.Use (interpretation.interpretTerm x) (interpretation.interpretTerm y)
  | _, _, _, _, .identity x => M.identityUse (interpretation.interpretTerm x)
  | _, _, _, _, .ofStrictIdentity proof =>
      M.useOfIdentity (interpretation.interpretStrictIdentity proof)
  | _, _, _, _, .noncontractive separation coordination =>
      M.useOfNoncontractive
        (interpretation.interpretSeparation separation)
        (interpretation.interpretCoordination coordination)
  | _, _, _, _, .compose first second =>
      M.composeUse
        (interpretation.interpretUse first)
        (interpretation.interpretUse second)
  | _, _, _, _, .reindex sigma use =>
      M.reindexUse
        (interpretation.interpretSubstitution sigma)
        (interpretation.interpretUse use)

/--
An evaluator for use derivations is lawful when it preserves every primitive
constructor of the independent syntax.  No semantic action on derivations is
stored in `RelaxedInterpretation`; this algebra is supplied only when stating
the universal property of `UseDerivation`.
-/
structure UseInterpretationAlgebra
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D) where
  evaluate :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    {x y : RelaxedTerm signature gamma A} ->
    UseDerivation x y ->
    M.Use (interpretation.interpretTerm x) (interpretation.interpretTerm y)
  preservesIdentity :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    (x : RelaxedTerm signature gamma A) ->
      evaluate (.identity x) =
        M.identityUse (interpretation.interpretTerm x)
  preservesStrictIdentity :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    {x y : RelaxedTerm signature gamma A} ->
    (proof : StrictIdentityDerivation x y) ->
      evaluate (.ofStrictIdentity proof) =
        M.useOfIdentity (interpretation.interpretStrictIdentity proof)
  preservesNoncontractive :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    {x y : RelaxedTerm signature gamma A} ->
    (separation : SeparationDerivation x y) ->
    (coordination : CoordinationDerivation x y) ->
      evaluate (.noncontractive separation coordination) =
        M.useOfNoncontractive
          (interpretation.interpretSeparation separation)
          (interpretation.interpretCoordination coordination)
  preservesComposition :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    {x y z : RelaxedTerm signature gamma A} ->
    (first : UseDerivation x y) ->
    (second : UseDerivation y z) ->
      evaluate (.compose first second) =
        M.composeUse (evaluate first) (evaluate second)
  preservesReindexing :
    {delta gamma : C.Ctx} ->
    (sigma : RelaxedSubstitution signature delta gamma) ->
    {A : signature.Ty} ->
    {x y : RelaxedTerm signature gamma A} ->
    (use : UseDerivation x y) ->
      evaluate (.reindex sigma use) =
        M.reindexUse
          (interpretation.interpretSubstitution sigma)
          (evaluate use)

/-- The recursive interpretation is itself a lawful use evaluator. -/
def RelaxedInterpretation.canonicalUseAlgebra
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D) :
    UseInterpretationAlgebra interpretation where
  evaluate := interpretation.interpretUse
  preservesIdentity := fun _ => rfl
  preservesStrictIdentity := fun _ => rfl
  preservesNoncontractive := fun _ _ => rfl
  preservesComposition := fun _ _ => rfl
  preservesReindexing := by
    intro delta gamma sigma A x y use
    rfl

/--
Initiality of the use syntax, stated pointwise: every evaluator preserving all
five constructors computes the canonical interpretation on every derivation.
-/
theorem RelaxedInterpretation.interpretUse_unique
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D)
    (other : UseInterpretationAlgebra interpretation) :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    {x y : RelaxedTerm signature gamma A} ->
    (use : UseDerivation x y) ->
      other.evaluate use = interpretation.interpretUse use := by
  intro gamma A x y use
  induction use with
  | identity term => exact other.preservesIdentity term
  | ofStrictIdentity proof => exact other.preservesStrictIdentity proof
  | noncontractive separation coordination =>
      exact other.preservesNoncontractive separation coordination
  | compose first second firstUnique secondUnique =>
      rw [other.preservesComposition, firstUnique, secondUnique]
      rfl
  | reindex sigma use useUnique =>
      rw [other.preservesReindexing, useUnique]
      rfl

/-- Recursive interpretation of admissible predicate syntax. -/
def RelaxedInterpretation.interpretPredicate
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D) :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    RelaxedPredicate signature gamma A ->
    D.Pred gamma A
  | _, _, .atom atom => interpretation.predicateAtom atom
  | gamma, A, .top => D.top gamma A
  | gamma, A, .bottom => D.bottom gamma A
  | _, _, .conjunction left right =>
      D.conjunction
        (interpretation.interpretPredicate left)
        (interpretation.interpretPredicate right)
  | _, _, .reindex sigma predicate =>
      D.reindexPred
        (interpretation.interpretSubstitution sigma)
        (interpretation.interpretPredicate predicate)

/-- Proof-relevant meaning of formulas. -/
def RelaxedInterpretation.interpretFormula
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D) :
    {gamma : C.Ctx} ->
    RelaxedFormula signature gamma ->
    Type :=
  fun {_} formula =>
    RelaxedFormula.rec
      (motive := fun _ => Type)
      Unit
      Empty
      (fun _ _ leftEvidence rightEvidence =>
        leftEvidence × rightEvidence)
      (fun predicate term =>
        PropositionEvidence
          (D.Holds
            (interpretation.interpretPredicate predicate)
            (interpretation.interpretTerm term)))
      formula

/-- Proof-relevant meaning of judgments. -/
def RelaxedInterpretation.interpretJudgment
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D) :
    {gamma : C.Ctx} ->
    RelaxedJudgment signature gamma ->
    Type :=
  fun {_} judgment =>
    RelaxedJudgment.rec
      (motive := fun _ => Type)
      (fun formula => interpretation.interpretFormula formula)
      (fun left right =>
        PropositionEvidence
          (interpretation.interpretTerm left =
            interpretation.interpretTerm right))
      judgment

/-- Semantic realization of every open formula hypothesis. -/
def RelaxedInterpretation.RealizesHypotheses
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (interpretation : RelaxedInterpretation signature L M D)
    {gamma : C.Ctx}
    (Hypothesis : RelaxedFormula signature gamma -> Type h) :
    Type (max u v s ta d h) :=
  forall formula,
    Hypothesis formula ->
    interpretation.interpretFormula formula

end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.RelaxedInterpretation
#print axioms Meta.RelaxedSemantics.RelaxedInterpretation.interpretSubstitution
#print axioms Meta.RelaxedSemantics.RelaxedInterpretation.interpretTerm
#print axioms Meta.RelaxedSemantics.RelaxedInterpretation.interpretStrictIdentity
#print axioms Meta.RelaxedSemantics.RelaxedInterpretation.interpretSeparation
#print axioms Meta.RelaxedSemantics.RelaxedInterpretation.interpretCoordination
#print axioms Meta.RelaxedSemantics.RelaxedInterpretation.interpretUse
#print axioms Meta.RelaxedSemantics.UseInterpretationAlgebra
#print axioms Meta.RelaxedSemantics.RelaxedInterpretation.interpretUse_unique
#print axioms Meta.RelaxedSemantics.RelaxedInterpretation.interpretPredicate
#print axioms Meta.RelaxedSemantics.RelaxedInterpretation.interpretFormula
#print axioms Meta.RelaxedSemantics.RelaxedInterpretation.interpretJudgment
/- AXIOM_AUDIT_END -/
