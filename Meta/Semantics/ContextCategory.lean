/-!
# Constructive categories of contexts

The orientation `Sub delta gamma` means that data in `gamma` can be
reindexed along a substitution whose domain is `delta`.
-/

namespace Meta
namespace RelaxedSemantics

universe u v

/-- Raw proof-relevant substitutions between contexts. -/
structure ContextCategory where
  Ctx : Type u
  Sub : Ctx -> Ctx -> Type v
  identity : (gamma : Ctx) -> Sub gamma gamma
  compose :
    {theta delta gamma : Ctx} ->
      Sub theta delta ->
      Sub delta gamma ->
      Sub theta gamma

/-- Category laws on the substitution witnesses themselves. -/
structure LawfulContextCategory (C : ContextCategory.{u, v}) where
  leftIdentity :
    {delta gamma : C.Ctx} ->
    (sigma : C.Sub delta gamma) ->
      C.compose (C.identity delta) sigma = sigma
  rightIdentity :
    {delta gamma : C.Ctx} ->
    (sigma : C.Sub delta gamma) ->
      C.compose sigma (C.identity gamma) = sigma
  associativity :
    {omega theta delta gamma : C.Ctx} ->
    (tau : C.Sub omega theta) ->
    (sigma : C.Sub theta delta) ->
    (rho : C.Sub delta gamma) ->
      C.compose (C.compose tau sigma) rho =
        C.compose tau (C.compose sigma rho)

/-- A positive witness that a context category has a non-identity arrow. -/
structure NontrivialContextChange
    (C : ContextCategory.{u, v}) where
  source : C.Ctx
  target : C.Ctx
  substitution : C.Sub source target
  contextsSeparated : source = target -> False

end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.ContextCategory
#print axioms Meta.RelaxedSemantics.LawfulContextCategory
#print axioms Meta.RelaxedSemantics.NontrivialContextChange
/- AXIOM_AUDIT_END -/
