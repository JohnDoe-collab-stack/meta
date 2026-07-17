import Meta.Semantics.ContextualRelaxedRegime

/-!
# Independent syntax for relaxed substitution

This syntax is not defined from a semantic regime.  It has its own atoms and
derivations.  Strict identity and relaxed use are distinct judgments; only the
latter authorizes transport of admissible predicates.
-/

namespace Meta
namespace RelaxedSemantics

universe u v s t p q d h

/-- Atomic signature interpreted by contextual relaxed models. -/
structure RelaxedTransportSignature
    (C : ContextCategory.{u, v}) where
  Ty : Type s
  SubstitutionAtom : C.Ctx -> C.Ctx -> Type v
  TermAtom : C.Ctx -> Ty -> Type t
  SeparationAtom :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    TermAtom gamma A ->
    TermAtom gamma A ->
    Type p
  CoordinationAtom :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    TermAtom gamma A ->
    TermAtom gamma A ->
    Type q
  PredicateAtom : C.Ctx -> Ty -> Type d

/-- Free substitutions generated independently from semantic composition. -/
inductive RelaxedSubstitution
    {C : ContextCategory.{u, v}}
    (signature : RelaxedTransportSignature.{u, v, s, t, p, q, d} C) :
    C.Ctx -> C.Ctx -> Type (max u v)
  | identity (gamma : C.Ctx) :
      RelaxedSubstitution signature gamma gamma
  | atom :
      signature.SubstitutionAtom delta gamma ->
      RelaxedSubstitution signature delta gamma
  | compose :
      RelaxedSubstitution signature theta delta ->
      RelaxedSubstitution signature delta gamma ->
      RelaxedSubstitution signature theta gamma

/-- Context-indexed terms generated independently of any model. -/
inductive RelaxedTerm
    {C : ContextCategory.{u, v}}
    (signature : RelaxedTransportSignature.{u, v, s, t, p, q, d} C) :
    (gamma : C.Ctx) -> signature.Ty -> Type (max u v s t)
  | atom :
      {gamma : C.Ctx} ->
      {A : signature.Ty} ->
      signature.TermAtom gamma A ->
      RelaxedTerm signature gamma A
  | reindex :
      {delta gamma : C.Ctx} ->
      RelaxedSubstitution signature delta gamma ->
      {A : signature.Ty} ->
      RelaxedTerm signature gamma A ->
      RelaxedTerm signature delta A

/-- Proof-relevant strict identity derivations. -/
inductive StrictIdentityDerivation
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, t, p, q, d} C} :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    RelaxedTerm signature gamma A ->
    RelaxedTerm signature gamma A ->
    Type (max u v s t)
  | refl (x : RelaxedTerm signature gamma A) :
      StrictIdentityDerivation x x
  | symm :
      StrictIdentityDerivation x y ->
      StrictIdentityDerivation y x
  | trans :
      StrictIdentityDerivation x y ->
      StrictIdentityDerivation y z ->
      StrictIdentityDerivation x z
  | reindex (sigma : RelaxedSubstitution signature delta gamma) :
      StrictIdentityDerivation x y ->
      StrictIdentityDerivation
        (RelaxedTerm.reindex sigma x)
        (RelaxedTerm.reindex sigma y)

/-- Derivations of explicit internal separation. -/
inductive SeparationDerivation
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, t, p, q, d} C} :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    RelaxedTerm signature gamma A ->
    RelaxedTerm signature gamma A ->
    Type (max u v s t p)
  | atom {left right : signature.TermAtom gamma A} :
      signature.SeparationAtom left right ->
      SeparationDerivation
        (RelaxedTerm.atom left)
        (RelaxedTerm.atom right)
  | reindex (sigma : RelaxedSubstitution signature delta gamma) :
      SeparationDerivation x y ->
      SeparationDerivation
        (RelaxedTerm.reindex sigma x)
        (RelaxedTerm.reindex sigma y)

/-- Derivations of explicit coordination without contraction. -/
inductive CoordinationDerivation
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, t, p, q, d} C} :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    RelaxedTerm signature gamma A ->
    RelaxedTerm signature gamma A ->
    Type (max u v s t q)
  | atom {left right : signature.TermAtom gamma A} :
      signature.CoordinationAtom left right ->
      CoordinationDerivation
        (RelaxedTerm.atom left)
        (RelaxedTerm.atom right)
  | reindex (sigma : RelaxedSubstitution signature delta gamma) :
      CoordinationDerivation x y ->
      CoordinationDerivation
        (RelaxedTerm.reindex sigma x)
        (RelaxedTerm.reindex sigma y)

/-- Relaxed uses form a category and contain strict identities as a subtheory. -/
inductive UseDerivation
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, t, p, q, d} C} :
    {gamma : C.Ctx} ->
    {A : signature.Ty} ->
    RelaxedTerm signature gamma A ->
    RelaxedTerm signature gamma A ->
    Type (max u v s t p q)
  | identity (x : RelaxedTerm signature gamma A) :
      UseDerivation x x
  | ofStrictIdentity :
      StrictIdentityDerivation x y ->
      UseDerivation x y
  | noncontractive :
      SeparationDerivation x y ->
      CoordinationDerivation x y ->
      UseDerivation x y
  | compose :
      UseDerivation x y ->
      UseDerivation y z ->
      UseDerivation x z
  | reindex (sigma : RelaxedSubstitution signature delta gamma) :
      UseDerivation x y ->
      UseDerivation
        (RelaxedTerm.reindex sigma x)
        (RelaxedTerm.reindex sigma y)

/-- Syntax of predicates admitted for relaxed substitution. -/
inductive RelaxedPredicate
    {C : ContextCategory.{u, v}}
    (signature : RelaxedTransportSignature.{u, v, s, t, p, q, d} C) :
    (gamma : C.Ctx) -> signature.Ty -> Type (max u v s d)
  | atom :
      {gamma : C.Ctx} ->
      {A : signature.Ty} ->
      signature.PredicateAtom gamma A ->
      RelaxedPredicate signature gamma A
  | top : RelaxedPredicate signature gamma A
  | bottom : RelaxedPredicate signature gamma A
  | conjunction :
      RelaxedPredicate signature gamma A ->
      RelaxedPredicate signature gamma A ->
      RelaxedPredicate signature gamma A
  | reindex :
      {delta gamma : C.Ctx} ->
      RelaxedSubstitution signature delta gamma ->
      {A : signature.Ty} ->
      RelaxedPredicate signature gamma A ->
      RelaxedPredicate signature delta A

/-- Propositional formulas over independent terms and predicates. -/
inductive RelaxedFormula
    {C : ContextCategory.{u, v}}
    (signature : RelaxedTransportSignature.{u, v, s, t, p, q, d} C)
    (gamma : C.Ctx) :
    Type (max u v s t d)
  | top : RelaxedFormula signature gamma
  | bottom : RelaxedFormula signature gamma
  | conjunction :
      RelaxedFormula signature gamma ->
      RelaxedFormula signature gamma ->
      RelaxedFormula signature gamma
  | holds :
      {A : signature.Ty} ->
      RelaxedPredicate signature gamma A ->
      RelaxedTerm signature gamma A ->
      RelaxedFormula signature gamma

/-- Strict identity is a separate judgment, not a consequence of transport. -/
inductive RelaxedJudgment
    {C : ContextCategory.{u, v}}
    (signature : RelaxedTransportSignature.{u, v, s, t, p, q, d} C)
    (gamma : C.Ctx) :
    Type (max u v s t d)
  | formula : RelaxedFormula signature gamma -> RelaxedJudgment signature gamma
  | strictIdentity :
      {A : signature.Ty} ->
      RelaxedTerm signature gamma A ->
      RelaxedTerm signature gamma A ->
      RelaxedJudgment signature gamma

/-- Natural deduction for the relaxed calculus. -/
inductive RelaxedProof
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, t, p, q, d} C}
    {gamma : C.Ctx}
    (Hypothesis : RelaxedFormula signature gamma -> Type h) :
    RelaxedJudgment signature gamma ->
    Type (max u v s h t p q d)
  | assumption {formula : RelaxedFormula signature gamma} :
      Hypothesis formula ->
      RelaxedProof Hypothesis (.formula formula)
  | topIntro :
      RelaxedProof Hypothesis (.formula .top)
  | conjunctionIntro :
      RelaxedProof Hypothesis (.formula left) ->
      RelaxedProof Hypothesis (.formula right) ->
      RelaxedProof Hypothesis (.formula (.conjunction left right))
  | conjunctionLeft :
      RelaxedProof Hypothesis (.formula (.conjunction left right)) ->
      RelaxedProof Hypothesis (.formula left)
  | conjunctionRight :
      RelaxedProof Hypothesis (.formula (.conjunction left right)) ->
      RelaxedProof Hypothesis (.formula right)
  | strictIdentity :
      StrictIdentityDerivation x y ->
      RelaxedProof Hypothesis (.strictIdentity x y)
  | transport :
      UseDerivation x y ->
      RelaxedProof Hypothesis (.formula (.holds P x)) ->
      RelaxedProof Hypothesis (.formula (.holds P y))

/-- The empty family of assumptions. -/
def NoRelaxedHypotheses
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, t, p, q, d} C}
    {gamma : C.Ctx} :
    RelaxedFormula signature gamma ->
    Type :=
  fun _ => Empty

/-- A closed contradiction is a closed proof of the bottom formula. -/
def ClosedRelaxedContradiction
    {C : ContextCategory.{u, v}}
    (signature : RelaxedTransportSignature.{u, v, s, t, p, q, d} C)
    (gamma : C.Ctx) :
    Prop :=
  Nonempty
    (RelaxedProof
      (NoRelaxedHypotheses (signature := signature) (gamma := gamma))
      (.formula (.bottom : RelaxedFormula signature gamma)))

end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.RelaxedTransportSignature
#print axioms Meta.RelaxedSemantics.RelaxedSubstitution
#print axioms Meta.RelaxedSemantics.RelaxedTerm
#print axioms Meta.RelaxedSemantics.StrictIdentityDerivation
#print axioms Meta.RelaxedSemantics.SeparationDerivation
#print axioms Meta.RelaxedSemantics.CoordinationDerivation
#print axioms Meta.RelaxedSemantics.UseDerivation
#print axioms Meta.RelaxedSemantics.RelaxedPredicate
#print axioms Meta.RelaxedSemantics.RelaxedFormula
#print axioms Meta.RelaxedSemantics.RelaxedJudgment
#print axioms Meta.RelaxedSemantics.RelaxedProof
#print axioms Meta.RelaxedSemantics.ClosedRelaxedContradiction
/- AXIOM_AUDIT_END -/
