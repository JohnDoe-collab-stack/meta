import Meta.Semantics.Soundness

/-!
# Conservativity of strict identity

Relaxed transport extends substitution without adding a new constructor for
strict identity.  Identity derivations embed into use derivations, but a
separated coordinated use is semantically refuted as an identity.
-/

namespace Meta
namespace RelaxedSemantics

universe u v s ta p q d h t r o sp cq w pd

/-- A strict-identity judgment can only be proved by strict identity syntax. -/
def strictIdentityDerivationOfProof
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {gamma : C.Ctx}
    {Hypothesis : RelaxedFormula signature gamma -> Type h}
    {A : signature.Ty}
    {x y : RelaxedTerm signature gamma A} :
    RelaxedProof Hypothesis (.strictIdentity x y) ->
    StrictIdentityDerivation x y
  | .strictIdentity proof => proof

/-- Every strict identity derivation remains a derivation in the full calculus. -/
def strictIdentityProofEmbedding
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {gamma : C.Ctx}
    {Hypothesis : RelaxedFormula signature gamma -> Type h}
    {A : signature.Ty}
    {x y : RelaxedTerm signature gamma A}
    (proof : StrictIdentityDerivation x y) :
    RelaxedProof Hypothesis (.strictIdentity x y) :=
  .strictIdentity proof

/-- Strict identity authorizes use, preserving the classical substitution case. -/
def strictIdentityUseEmbedding
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {gamma : C.Ctx}
    {A : signature.Ty}
    {x y : RelaxedTerm signature gamma A}
    (proof : StrictIdentityDerivation x y) :
    UseDerivation x y :=
  .ofStrictIdentity proof

/-- Positive package of separation, coordination, and the induced use. -/
structure SyntacticNoncontractiveUse
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {gamma : C.Ctx}
    {A : signature.Ty}
    (x y : RelaxedTerm signature gamma A) where
  separation : SeparationDerivation x y
  coordination : CoordinationDerivation x y

/-- The use authorized by a syntactic non-contractive package. -/
def SyntacticNoncontractiveUse.use
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {gamma : C.Ctx}
    {A : signature.Ty}
    {x y : RelaxedTerm signature gamma A}
    (noncontractive : SyntacticNoncontractiveUse x y) :
    UseDerivation x y :=
  .noncontractive noncontractive.separation noncontractive.coordination

/-- A separated use is available but cannot denote strict identity in a model. -/
theorem interpretedNoncontractiveUse_refutesIdentity
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (modelLaws : LawfulContextualRelaxedRegime M)
    (interpretation : RelaxedInterpretation signature L M D)
    {gamma : C.Ctx}
    {A : signature.Ty}
    {x y : RelaxedTerm signature gamma A}
    (noncontractive : SyntacticNoncontractiveUse x y) :
    interpretation.interpretTerm x = interpretation.interpretTerm y ->
    False :=
  modelLaws.separationRefutesIdentity
    (interpretation.interpretSeparation noncontractive.separation)

/-- The strict fragment is a retract of the strict judgments of the full system. -/
structure StrictIdentityConservativity
    {C : ContextCategory.{u, v}}
    (signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C) where
  embed :
    {gamma : C.Ctx} ->
    {Hypothesis : RelaxedFormula signature gamma -> Type h} ->
    {A : signature.Ty} ->
    {x y : RelaxedTerm signature gamma A} ->
    StrictIdentityDerivation x y ->
    RelaxedProof Hypothesis (.strictIdentity x y)
  extract :
    {gamma : C.Ctx} ->
    {Hypothesis : RelaxedFormula signature gamma -> Type h} ->
    {A : signature.Ty} ->
    {x y : RelaxedTerm signature gamma A} ->
    RelaxedProof Hypothesis (.strictIdentity x y) ->
    StrictIdentityDerivation x y
  extractEmbed :
    {gamma : C.Ctx} ->
    {Hypothesis : RelaxedFormula signature gamma -> Type h} ->
    {A : signature.Ty} ->
    {x y : RelaxedTerm signature gamma A} ->
    (proof : StrictIdentityDerivation x y) ->
      extract (Hypothesis := Hypothesis)
        (embed (Hypothesis := Hypothesis) proof) = proof

/-- Canonical constructive conservativity witness. -/
def strictIdentityConservativity
    {C : ContextCategory.{u, v}}
    (signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C) :
    StrictIdentityConservativity signature where
  embed := strictIdentityProofEmbedding
  extract := strictIdentityDerivationOfProof
  extractEmbed := fun _ => rfl

end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.strictIdentityDerivationOfProof
#print axioms Meta.RelaxedSemantics.strictIdentityUseEmbedding
#print axioms Meta.RelaxedSemantics.interpretedNoncontractiveUse_refutesIdentity
#print axioms Meta.RelaxedSemantics.StrictIdentityConservativity
#print axioms Meta.RelaxedSemantics.strictIdentityConservativity
/- AXIOM_AUDIT_END -/
