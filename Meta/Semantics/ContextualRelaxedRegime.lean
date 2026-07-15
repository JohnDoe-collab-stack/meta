import Meta.Core.TransportCoherence
import Meta.Semantics.ContextCategory

/-!
# Context-indexed relaxed regimes

This layer adds genuine context substitution to the fiberwise Core regime.
Separation is normalized by a law refuting strict identity, and transport is
required to commute with reindexing.
-/

namespace Meta
namespace RelaxedSemantics

open RelaxedUsageRegime

universe u v s t r o p q w

/-- A many-sorted family of terms reindexed along context substitutions. -/
structure IndexedTermLanguage
    (C : ContextCategory.{u, v})
    (Ty : Type s) where
  Term : C.Ctx -> Ty -> Type t
  reindexTerm :
    {delta gamma : C.Ctx} ->
      C.Sub delta gamma ->
      {A : Ty} ->
      Term gamma A ->
      Term delta A

/-- Strict functoriality of contextual terms. -/
structure LawfulIndexedTermLanguage
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    (L : IndexedTermLanguage.{u, v, s, t} C Ty) where
  reindexIdentity :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (x : L.Term gamma A) ->
      L.reindexTerm (C.identity gamma) x = x
  reindexComposition :
    {theta delta gamma : C.Ctx} ->
    (tau : C.Sub theta delta) ->
    (sigma : C.Sub delta gamma) ->
    {A : Ty} ->
    (x : L.Term gamma A) ->
      L.reindexTerm (C.compose tau sigma) x =
        L.reindexTerm tau (L.reindexTerm sigma x)

/--
Raw contextual relaxed transport data.

The output relation is internal to each authorized reading. Term endpoints
remain explicit in use witnesses and in the transport operation.
-/
structure ContextualRelaxedRegime
    (C : ContextCategory.{u, v})
    {Ty : Type s}
    (L : IndexedTermLanguage.{u, v, s, t} C Ty) where
  Read : (gamma : C.Ctx) -> (A : Ty) -> Type r
  defaultRead : (gamma : C.Ctx) -> (A : Ty) -> Read gamma A
  Out :
    (gamma : C.Ctx) ->
    (A : Ty) ->
    Read gamma A ->
    Type o
  read :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (rho : Read gamma A) ->
    L.Term gamma A ->
    Out gamma A rho
  Sep :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    L.Term gamma A ->
    L.Term gamma A ->
    Type p
  Coord :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    L.Term gamma A ->
    L.Term gamma A ->
    Type q
  Use :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    L.Term gamma A ->
    L.Term gamma A ->
    Type w
  OutRel :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (rho : Read gamma A) ->
    Out gamma A rho ->
    Out gamma A rho ->
    Type w
  identityUse :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (x : L.Term gamma A) ->
    Use x x
  composeUse :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y z : L.Term gamma A} ->
    Use x y ->
    Use y z ->
    Use x z
  useOfNoncontractive :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    Sep x y ->
    Coord x y ->
    Use x y
  transport :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    Use x y ->
    (rho : Read gamma A) ->
    OutRel rho (read rho x) (read rho y)
  outIdentity :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (rho : Read gamma A) ->
    (x : L.Term gamma A) ->
    OutRel rho (read rho x) (read rho x)
  outCompose :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (rho : Read gamma A) ->
    {x y z : L.Term gamma A} ->
    OutRel rho (read rho x) (read rho y) ->
    OutRel rho (read rho y) (read rho z) ->
    OutRel rho (read rho x) (read rho z)
  reindexRead :
    {delta gamma : C.Ctx} ->
    C.Sub delta gamma ->
    {A : Ty} ->
    Read gamma A ->
    Read delta A
  reindexSep :
    {delta gamma : C.Ctx} ->
    (sigma : C.Sub delta gamma) ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    Sep x y ->
    Sep (L.reindexTerm sigma x) (L.reindexTerm sigma y)
  reindexCoord :
    {delta gamma : C.Ctx} ->
    (sigma : C.Sub delta gamma) ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    Coord x y ->
    Coord (L.reindexTerm sigma x) (L.reindexTerm sigma y)
  reindexUse :
    {delta gamma : C.Ctx} ->
    (sigma : C.Sub delta gamma) ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    Use x y ->
    Use (L.reindexTerm sigma x) (L.reindexTerm sigma y)
  reindexOutRel :
    {delta gamma : C.Ctx} ->
    (sigma : C.Sub delta gamma) ->
    {A : Ty} ->
    (rho : Read gamma A) ->
    {x y : L.Term gamma A} ->
    OutRel rho (read rho x) (read rho y) ->
    OutRel (reindexRead sigma rho)
      (read (reindexRead sigma rho) (L.reindexTerm sigma x))
      (read (reindexRead sigma rho) (L.reindexTerm sigma y))

/-- Laws making the raw contextual data a stable transport semantics. -/
structure LawfulContextualRelaxedRegime
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L) where
  contextLaws : LawfulContextCategory C
  termLaws : LawfulIndexedTermLanguage L
  separationRefutesIdentity :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    M.Sep x y ->
    x = y ->
    False
  useLeftIdentity :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    (use : M.Use x y) ->
      M.composeUse (M.identityUse x) use = use
  useRightIdentity :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y : L.Term gamma A} ->
    (use : M.Use x y) ->
      M.composeUse use (M.identityUse y) = use
  useAssociativity :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    {x y z v : L.Term gamma A} ->
    (first : M.Use x y) ->
    (second : M.Use y z) ->
    (third : M.Use z v) ->
      M.composeUse (M.composeUse first second) third =
        M.composeUse first (M.composeUse second third)
  outLeftIdentity :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (rho : M.Read gamma A) ->
    {x y : L.Term gamma A} ->
    (relation :
      M.OutRel rho (M.read rho x) (M.read rho y)) ->
      M.outCompose rho (M.outIdentity rho x) relation = relation
  outRightIdentity :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (rho : M.Read gamma A) ->
    {x y : L.Term gamma A} ->
    (relation :
      M.OutRel rho (M.read rho x) (M.read rho y)) ->
      M.outCompose rho relation (M.outIdentity rho y) = relation
  outAssociativity :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (rho : M.Read gamma A) ->
    {x y z v : L.Term gamma A} ->
    (first :
      M.OutRel rho (M.read rho x) (M.read rho y)) ->
    (second :
      M.OutRel rho (M.read rho y) (M.read rho z)) ->
    (third :
      M.OutRel rho (M.read rho z) (M.read rho v)) ->
      M.outCompose rho (M.outCompose rho first second) third =
        M.outCompose rho first (M.outCompose rho second third)
  transportIdentity :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (rho : M.Read gamma A) ->
    (x : L.Term gamma A) ->
      M.transport (M.identityUse x) rho = M.outIdentity rho x
  transportComposition :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (rho : M.Read gamma A) ->
    {x y z : L.Term gamma A} ->
    (first : M.Use x y) ->
    (second : M.Use y z) ->
      M.transport (M.composeUse first second) rho =
        M.outCompose rho (M.transport first rho) (M.transport second rho)
  reindexReadIdentity :
    {gamma : C.Ctx} ->
    {A : Ty} ->
    (rho : M.Read gamma A) ->
      M.reindexRead (C.identity gamma) rho = rho
  reindexReadComposition :
    {theta delta gamma : C.Ctx} ->
    (tau : C.Sub theta delta) ->
    (sigma : C.Sub delta gamma) ->
    {A : Ty} ->
    (rho : M.Read gamma A) ->
      M.reindexRead (C.compose tau sigma) rho =
        M.reindexRead tau (M.reindexRead sigma rho)
  transportReindexing :
    {delta gamma : C.Ctx} ->
    (sigma : C.Sub delta gamma) ->
    {A : Ty} ->
    (rho : M.Read gamma A) ->
    {x y : L.Term gamma A} ->
    (use : M.Use x y) ->
      M.reindexOutRel sigma rho (M.transport use rho) =
        M.transport (M.reindexUse sigma use) (M.reindexRead sigma rho)

/-- Reindexing of an authorized use is itself an authorized contextual use. -/
def contextualUse_reindex
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L)
    {delta gamma : C.Ctx}
    (sigma : C.Sub delta gamma)
    {A : Ty}
    {x y : L.Term gamma A}
    (use : M.Use x y) :
    M.Use (L.reindexTerm sigma x) (L.reindexTerm sigma y) :=
  M.reindexUse sigma use

/-- Transport of identity computes the output identity. -/
theorem contextualTransport_identity
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L}
    (laws : LawfulContextualRelaxedRegime M)
    {gamma : C.Ctx}
    {A : Ty}
    (rho : M.Read gamma A)
    (x : L.Term gamma A) :
    M.transport (M.identityUse x) rho = M.outIdentity rho x :=
  laws.transportIdentity rho x

/-- Transport respects composition of authorized uses. -/
theorem contextualTransport_composition
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L}
    (laws : LawfulContextualRelaxedRegime M)
    {gamma : C.Ctx}
    {A : Ty}
    (rho : M.Read gamma A)
    {x y z : L.Term gamma A}
    (first : M.Use x y)
    (second : M.Use y z) :
    M.transport (M.composeUse first second) rho =
      M.outCompose rho (M.transport first rho) (M.transport second rho) :=
  laws.transportComposition rho first second

/-- Transport commutes with change of context. -/
theorem contextualTransport_reindex
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L}
    (laws : LawfulContextualRelaxedRegime M)
    {delta gamma : C.Ctx}
    (sigma : C.Sub delta gamma)
    {A : Ty}
    (rho : M.Read gamma A)
    {x y : L.Term gamma A}
    (use : M.Use x y) :
    M.reindexOutRel sigma rho (M.transport use rho) =
      M.transport (M.reindexUse sigma use) (M.reindexRead sigma rho) :=
  laws.transportReindexing sigma rho use

/-- Explicit separation cannot be interpreted as internal identity. -/
theorem separation_refutes_internalIdentity
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L}
    (laws : LawfulContextualRelaxedRegime M)
    {gamma : C.Ctx}
    {A : Ty}
    {x y : L.Term gamma A}
    (separation : M.Sep x y) :
    x = y -> False :=
  laws.separationRefutesIdentity separation

/-- The existing Core regime obtained by fixing one context and one sort. -/
def ContextualRelaxedRegime.fiberRegime
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L)
    (gamma : C.Ctx)
    (A : Ty) :
    RelaxedInterfaceRegime (L.Term gamma A) where
  Ctx := Unit
  defaultCtx := ()
  Read := fun _ => M.Read gamma A
  defaultRead := fun _ => M.defaultRead gamma A
  Out := fun _ rho => M.Out gamma A rho
  read := fun _ rho x => M.read rho x
  Sep := fun _ x y => M.Sep x y
  Coord := fun _ x y => M.Coord x y
  Use := fun _ x y => M.Use x y
  OutRel := fun _ rho left right => M.OutRel rho left right
  use_of_noncontractive := fun separation coordination =>
    M.useOfNoncontractive separation coordination
  transport := fun use rho => M.transport use rho

/-- Fiberwise use is definitionally the contextual use family. -/
theorem ContextualRelaxedRegime.fiberUse_eq
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L)
    (gamma : C.Ctx)
    (A : Ty)
    (x y : L.Term gamma A) :
    (M.fiberRegime gamma A).Use () x y = M.Use x y :=
  rfl

/-- Fiberwise transport is definitionally contextual transport. -/
theorem ContextualRelaxedRegime.fiberTransport_eq
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L)
    {gamma : C.Ctx}
    {A : Ty}
    {x y : L.Term gamma A}
    (use : M.Use x y)
    (rho : M.Read gamma A) :
    (M.fiberRegime gamma A).transport (gamma := ()) use rho =
      M.transport use rho :=
  rfl

/-- Contextual identities and composition induce Core compositional use. -/
def ContextualRelaxedRegime.fiberCompositionalUse
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    (M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L)
    (gamma : C.Ctx)
    (A : Ty) :
    CompositionalUse (M.fiberRegime gamma A) where
  identity := fun _ x => M.identityUse x
  compose := fun first second => M.composeUse first second

/-- Every lawful contextual fiber carries coherent Core transport. -/
def LawfulContextualRelaxedRegime.fiberCompositionalTransport
    {C : ContextCategory.{u, v}}
    {Ty : Type s}
    {L : IndexedTermLanguage.{u, v, s, t} C Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, p, q, w} C L}
    (laws : LawfulContextualRelaxedRegime M)
    (gamma : C.Ctx)
    (A : Ty) :
    CompositionalTransport
      (M.fiberRegime gamma A)
      (M.fiberCompositionalUse gamma A) where
  useLaws :=
    { leftIdentity := fun use => laws.useLeftIdentity use
      rightIdentity := fun use => laws.useRightIdentity use
      associativity := fun first second third =>
        laws.useAssociativity first second third }
  outIdentity := fun _ rho x => M.outIdentity rho x
  outCompose := fun {_} rho {_ _ _} first second =>
    M.outCompose rho first second
  outLeftIdentity := fun {_} rho {_ _} relation =>
    laws.outLeftIdentity rho relation
  outRightIdentity := fun {_} rho {_ _} relation =>
    laws.outRightIdentity rho relation
  outAssociativity := fun {_} rho {_ _ _ _} first second third =>
    laws.outAssociativity rho first second third
  transportIdentity := fun _ rho x => laws.transportIdentity rho x
  transportComposition := fun {_} rho {_ _ _} first second =>
    laws.transportComposition rho first second

end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.IndexedTermLanguage
#print axioms Meta.RelaxedSemantics.ContextualRelaxedRegime
#print axioms Meta.RelaxedSemantics.LawfulContextualRelaxedRegime
#print axioms Meta.RelaxedSemantics.contextualUse_reindex
#print axioms Meta.RelaxedSemantics.contextualTransport_identity
#print axioms Meta.RelaxedSemantics.contextualTransport_composition
#print axioms Meta.RelaxedSemantics.contextualTransport_reindex
#print axioms Meta.RelaxedSemantics.separation_refutes_internalIdentity
#print axioms Meta.RelaxedSemantics.ContextualRelaxedRegime.fiberRegime
#print axioms Meta.RelaxedSemantics.ContextualRelaxedRegime.fiberCompositionalUse
#print axioms Meta.RelaxedSemantics.LawfulContextualRelaxedRegime.fiberCompositionalTransport
/- AXIOM_AUDIT_END -/
