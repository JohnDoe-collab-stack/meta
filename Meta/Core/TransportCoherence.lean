import Meta.Core.RelaxedUsageRegime

/-!
# Coherent composition of relaxed transport

This module adds laws to the operations already carried by
`CompositionalUse`.  It does not change the primitive relaxed regime.  A
`CompositionalTransport` supplies lawful composition on every output relation
and proves that the regime transport preserves identities and composition.
-/

namespace Meta
namespace RelaxedUsageRegime

universe u c r o s k l m

/-- Identity and composition laws for proof-relevant use witnesses. -/
structure LawfulCompositionalUse
    {X : Type u}
    (I : RelaxedInterfaceRegime.{u, c, r, o, s, k, l, m} X)
    (uses : CompositionalUse I) where
  leftIdentity :
    ∀ {gamma : I.Ctx} {x y : X} (use : I.Use gamma x y),
      uses.compose (uses.identity gamma x) use = use
  rightIdentity :
    ∀ {gamma : I.Ctx} {x y : X} (use : I.Use gamma x y),
      uses.compose use (uses.identity gamma y) = use
  associativity :
    ∀ {gamma : I.Ctx} {w x y z : X}
      (first : I.Use gamma w x)
      (second : I.Use gamma x y)
      (third : I.Use gamma y z),
      uses.compose (uses.compose first second) third =
        uses.compose first (uses.compose second third)

/--
Lawful output composition together with functoriality of relaxed transport.

The laws compare proof-relevant witnesses themselves.  They do not merely
state propositional availability of the corresponding relations.
-/
structure CompositionalTransport
    {X : Type u}
    (I : RelaxedInterfaceRegime.{u, c, r, o, s, k, l, m} X)
    (uses : CompositionalUse I) where
  useLaws :
    LawfulCompositionalUse I uses
  outIdentity :
    ∀ (gamma : I.Ctx) (rho : I.Read gamma) (x : X),
      I.OutRel gamma rho
        (I.read gamma rho x)
        (I.read gamma rho x)
  outCompose :
    ∀ {gamma : I.Ctx} (rho : I.Read gamma) {x y z : X},
      I.OutRel gamma rho
          (I.read gamma rho x)
          (I.read gamma rho y) ->
        I.OutRel gamma rho
          (I.read gamma rho y)
          (I.read gamma rho z) ->
        I.OutRel gamma rho
          (I.read gamma rho x)
          (I.read gamma rho z)
  outLeftIdentity :
    ∀ {gamma : I.Ctx} (rho : I.Read gamma) {x y : X}
      (relation :
        I.OutRel gamma rho
          (I.read gamma rho x)
          (I.read gamma rho y)),
      outCompose rho (outIdentity gamma rho x) relation = relation
  outRightIdentity :
    ∀ {gamma : I.Ctx} (rho : I.Read gamma) {x y : X}
      (relation :
        I.OutRel gamma rho
          (I.read gamma rho x)
          (I.read gamma rho y)),
      outCompose rho relation (outIdentity gamma rho y) = relation
  outAssociativity :
    ∀ {gamma : I.Ctx} (rho : I.Read gamma) {w x y z : X}
      (first :
        I.OutRel gamma rho
          (I.read gamma rho w)
          (I.read gamma rho x))
      (second :
        I.OutRel gamma rho
          (I.read gamma rho x)
          (I.read gamma rho y))
      (third :
        I.OutRel gamma rho
          (I.read gamma rho y)
          (I.read gamma rho z)),
      outCompose rho (outCompose rho first second) third =
        outCompose rho first (outCompose rho second third)
  transportIdentity :
    ∀ (gamma : I.Ctx) (rho : I.Read gamma) (x : X),
      I.transport (uses.identity gamma x) rho =
        outIdentity gamma rho x
  transportComposition :
    ∀ {gamma : I.Ctx} (rho : I.Read gamma) {x y z : X}
      (first : I.Use gamma x y)
      (second : I.Use gamma y z),
      I.transport (uses.compose first second) rho =
        outCompose rho
          (I.transport first rho)
          (I.transport second rho)

end RelaxedUsageRegime
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedUsageRegime.LawfulCompositionalUse
#print axioms Meta.RelaxedUsageRegime.CompositionalTransport
/- AXIOM_AUDIT_END -/
