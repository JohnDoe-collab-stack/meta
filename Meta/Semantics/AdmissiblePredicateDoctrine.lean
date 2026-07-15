import Meta.Semantics.ContextualRelaxedRegime

/-!
# Admissible predicates for relaxed transport

The doctrine names exactly the predicates on which a regime-authorized use may
act.  It does not identify admissibility with the ambient propositions of Lean.
Predicates and their validity are stable under context substitution.
-/

namespace Meta
namespace RelaxedSemantics

universe u v s t r o p q w d

/-- Predicates admitted by a contextual relaxed regime. -/
structure AdmissiblePredicateDoctrine
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L) where
  Pred : (gamma : C.Ctx) -> (A : Ty) -> Type d
  Holds :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    Pred gamma A ->
    L.Term gamma A ->
    Prop
  top : (gamma : C.Ctx) -> (A : Ty) -> Pred gamma A
  bottom : (gamma : C.Ctx) -> (A : Ty) -> Pred gamma A
  conjunction :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    Pred gamma A ->
    Pred gamma A ->
    Pred gamma A
  reindexPred :
    {delta gamma : C.Ctx} ->
    C.Sub delta gamma ->
    {A : Ty} ->
    Pred gamma A ->
    Pred delta A
  substituteUse :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    M.Use x y ->
    (P : Pred gamma A) ->
    Holds P x ->
    Holds P y

/-- Logical and contextual laws of an admissible predicate doctrine. -/
structure LawfulAdmissiblePredicateDoctrine
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L}
    (D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, p, q, w, d} M) where
  holdsTop :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (x : L.Term gamma A) ->
      D.Holds (D.top gamma A) x
  holdsBottomRefuted :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x : L.Term gamma A} ->
      D.Holds (D.bottom gamma A) x ->
      False
  holdsConjunctionLeft :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {P Q : D.Pred gamma A} ->
    {x : L.Term gamma A} ->
      D.Holds (D.conjunction P Q) x ->
      D.Holds P x
  holdsConjunctionRight :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {P Q : D.Pred gamma A} ->
    {x : L.Term gamma A} ->
      D.Holds (D.conjunction P Q) x ->
      D.Holds Q x
  holdsConjunction :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {P Q : D.Pred gamma A} ->
    {x : L.Term gamma A} ->
      D.Holds P x ->
      D.Holds Q x ->
      D.Holds (D.conjunction P Q) x
  reindexHolds :
    {delta gamma : C.Ctx} ->
    (sigma : C.Sub delta gamma) ->
    {A : Ty} ->
    {P : D.Pred gamma A} ->
    {x : L.Term gamma A} ->
      D.Holds P x ->
      D.Holds
        (D.reindexPred sigma P)
        (L.reindexTerm sigma x)
  reindexReflectsHolds :
    {delta gamma : C.Ctx} ->
    (sigma : C.Sub delta gamma) ->
    {A : Ty} ->
    {P : D.Pred gamma A} ->
    {x : L.Term gamma A} ->
      D.Holds
        (D.reindexPred sigma P)
        (L.reindexTerm sigma x) ->
      D.Holds P x
  substitutionIdentity :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (x : L.Term gamma A) ->
    (P : D.Pred gamma A) ->
    (proof : D.Holds P x) ->
      D.substituteUse (M.identityUse x) P proof = proof
  substitutionComposition :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y z : L.Term gamma A} ->
    (first : M.Use x y) ->
    (second : M.Use y z) ->
    (P : D.Pred gamma A) ->
    (proof : D.Holds P x) ->
      D.substituteUse (M.composeUse first second) P proof =
        D.substituteUse second P (D.substituteUse first P proof)

/-- Strict identity remains ordinary internal equality of terms. -/
def StrictIdentity
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    {gamma : C.Ctx}
    {A : Ty}
    (x y : L.Term gamma A) :
    Prop :=
  x = y

end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.AdmissiblePredicateDoctrine
#print axioms Meta.RelaxedSemantics.LawfulAdmissiblePredicateDoctrine
#print axioms Meta.RelaxedSemantics.StrictIdentity
/- AXIOM_AUDIT_END -/
