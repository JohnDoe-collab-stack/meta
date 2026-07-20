import Meta.Semantics.IdentityConservativity

/-!
# Use graphs do not determine transport semantics

The graph records availability of uses and deliberately forgets the transport
witness computed by each use.  Concrete non-reduction requires two lawful
models with the same proof-relevant use family and distinguishable transport
outputs; that witness is supplied by the finite specialization.
-/

namespace Meta
namespace RelaxedSemantics

universe u v s t r₁ o₁ p₁ q₁ w₁ r₂ o₂ p₂ q₂ w₂ d₁ d₂

/-- Propositional edge relation underlying a contextual use family. -/
def HasContextualUse
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (M : ContextualRelaxedRegime.{u, v, s, t, r₁, o₁, p₁, q₁, w₁} C L)
    {gamma : C.Ctx}
    {A : Ty}
    (x y : L.Term gamma A) :
    Prop :=
  Nonempty (M.Use x y)

/-- Directed graph obtained by forgetting every witness and transport datum. -/
structure ContextIndexedDirectedGraph
    (C : ContextCategory.{u, v})
    {Ty : Type s}
    (L : IndexedTermLanguage.{u, v, s, t} C Ty) where
  Edge :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    L.Term gamma A ->
    L.Term gamma A ->
    Prop

/-- Forget a contextual semantics down to mere availability of uses. -/
def underlyingUseGraph
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (M : ContextualRelaxedRegime.{u, v, s, t, r₁, o₁, p₁, q₁, w₁} C L) :
    ContextIndexedDirectedGraph C L where
  Edge := fun x y => HasContextualUse M x y

/-- Proof-relevant equivalence of the complete contextual use graphs. -/
structure SameContextualUseGraph
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (left : ContextualRelaxedRegime.{u, v, s, t, r₁, o₁, p₁, q₁, w₁} C L)
    (right : ContextualRelaxedRegime.{u, v, s, t, r₂, o₂, p₂, q₂, w₂} C L) where
  forward :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    left.Use x y ->
    right.Use x y
  backward :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    right.Use x y ->
    left.Use x y
  backwardForward :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    (use : left.Use x y) ->
      backward (forward use) = use
  forwardBackward :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    (use : right.Use x y) ->
      forward (backward use) = use

/-- A proof-relevant graph equivalence induces equivalence of edge existence. -/
theorem SameContextualUseGraph.hasUse_iff
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    {left : ContextualRelaxedRegime.{u, v, s, t, r₁, o₁, p₁, q₁, w₁} C L}
    {right : ContextualRelaxedRegime.{u, v, s, t, r₂, o₂, p₂, q₂, w₂} C L}
    (same : SameContextualUseGraph left right)
    {gamma : C.Ctx}
    {A : Ty}
    {x y : L.Term gamma A} :
    HasContextualUse left x y <->
      HasContextualUse right x y := by
  constructor
  · intro available
    cases available with
    | intro use => exact ⟨same.forward use⟩
  · intro available
    cases available with
    | intro use => exact ⟨same.backward use⟩

/--
Observable difference between two transports carried by one shared edge.
The observations are applied to the concrete proof-relevant transport results,
not to the regimes as functions.
-/
structure TransportSemanticDistinction
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (left : ContextualRelaxedRegime.{u, v, s, t, r₁, o₁, p₁, q₁, w₁} C L)
    (right : ContextualRelaxedRegime.{u, v, s, t, r₂, o₂, p₂, q₂, w₂} C L) where
  context : C.Ctx
  sort : Ty
  source : L.Term context sort
  target : L.Term context sort
  leftUse : left.Use source target
  rightUse : right.Use source target
  leftReading : left.Read context sort
  rightReading : right.Read context sort
  observeLeft :
    left.OutRel leftReading
      (left.read leftReading source)
      (left.read leftReading target) ->
    Bool
  observeRight :
    right.OutRel rightReading
      (right.read rightReading source)
      (right.read rightReading target) ->
    Bool
  leftObserved :
    observeLeft (left.transport leftUse leftReading) = true
  rightObserved :
    observeRight (right.transport rightUse rightReading) = false

/-- Difference in logical meaning over a common term and context. -/
structure PredicateSemanticDistinction
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    {left : ContextualRelaxedRegime.{u, v, s, t, r₁, o₁, p₁, q₁, w₁} C L}
    {right : ContextualRelaxedRegime.{u, v, s, t, r₂, o₂, p₂, q₂, w₂} C L}
    (leftDoctrine :
      AdmissiblePredicateDoctrine.{u, v, s, t, r₁, o₁, p₁, q₁, w₁, d₁}
        left)
    (rightDoctrine :
      AdmissiblePredicateDoctrine.{u, v, s, t, r₂, o₂, p₂, q₂, w₂, d₂}
        right) where
  context : C.Ctx
  sort : Ty
  term : L.Term context sort
  leftPredicate : leftDoctrine.Pred context sort
  rightPredicate : rightDoctrine.Pred context sort
  leftHolds : leftDoctrine.Holds leftPredicate term
  rightRefuted : rightDoctrine.Holds rightPredicate term -> False

/--
Positive non-reduction package: identical directed use graphs coexist with
distinguishable transport and predicate semantics.
-/
structure UseGraphSemanticNonReduction
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (left : ContextualRelaxedRegime.{u, v, s, t, r₁, o₁, p₁, q₁, w₁} C L)
    (right : ContextualRelaxedRegime.{u, v, s, t, r₂, o₂, p₂, q₂, w₂} C L)
    (leftDoctrine :
      AdmissiblePredicateDoctrine.{u, v, s, t, r₁, o₁, p₁, q₁, w₁, d₁}
        left)
    (rightDoctrine :
      AdmissiblePredicateDoctrine.{u, v, s, t, r₂, o₂, p₂, q₂, w₂, d₂}
        right) where
  sameGraph : SameContextualUseGraph left right
  transportDistinction : TransportSemanticDistinction left right
  predicateDistinction :
    PredicateSemanticDistinction leftDoctrine rightDoctrine

end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.HasContextualUse
#print axioms Meta.RelaxedSemantics.underlyingUseGraph
#print axioms Meta.RelaxedSemantics.SameContextualUseGraph
#print axioms Meta.RelaxedSemantics.SameContextualUseGraph.hasUse_iff
#print axioms Meta.RelaxedSemantics.TransportSemanticDistinction
#print axioms Meta.RelaxedSemantics.PredicateSemanticDistinction
#print axioms Meta.RelaxedSemantics.UseGraphSemanticNonReduction
/- AXIOM_AUDIT_END -/
