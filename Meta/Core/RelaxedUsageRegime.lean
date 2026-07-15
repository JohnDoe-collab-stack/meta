universe u c r o s k l m

namespace Meta
namespace RelaxedUsageRegime

/--
A relaxed interface regime separates individuation from authorized transport.

The regime does not start from internal equality, projected equality, or global
substitution. It carries its own contexts, authorized readings, output types,
separation witnesses, coordination witnesses, use witnesses, and output
relations.

Its primitive constructive chain is:

`Sep + Coord -> Use -> transport`.

The `defaultCtx` and `defaultRead` fields ensure that a context and an
authorized reading are always available. Concrete elements and uses remain
positive data of an instance.
-/
structure RelaxedInterfaceRegime (X : Type u) where
  Ctx : Type c

  defaultCtx :
    Ctx

  Read :
    Ctx -> Type r

  defaultRead :
    forall gamma : Ctx, Read gamma

  Out :
    forall gamma : Ctx, Read gamma -> Type o

  read :
    forall gamma : Ctx, forall rho : Read gamma, X -> Out gamma rho

  Sep :
    Ctx -> X -> X -> Type s

  Coord :
    Ctx -> X -> X -> Type k

  Use :
    Ctx -> X -> X -> Type l

  OutRel :
    forall gamma : Ctx,
    forall rho : Read gamma,
      Out gamma rho -> Out gamma rho -> Type m

  use_of_noncontractive :
    forall {gamma : Ctx} {x y : X},
      Sep gamma x y ->
      Coord gamma x y ->
      Use gamma x y

  transport :
    forall {gamma : Ctx} {x y : X},
      Use gamma x y ->
      forall rho : Read gamma,
        OutRel gamma rho
          (read gamma rho x)
          (read gamma rho y)

/--
Propositional availability of a regime-internal use witness.

This deliberately forgets only the particular proof-relevant witness stored in
`Use`; it does not replace the regime's use relation by equality.
-/
def HasUse
    {X : Type u}
    (I : RelaxedInterfaceRegime X)
    (gamma : I.Ctx)
    (x y : X) :
    Prop :=
  Nonempty (I.Use gamma x y)

/--
Intrinsic identity and composition operations for the proof-relevant use
witnesses of a relaxed regime.
-/
structure CompositionalUse
    {X : Type u}
    (I : RelaxedInterfaceRegime X) where
  identity :
    (gamma : I.Ctx) ->
    (x : X) ->
      I.Use gamma x x

  compose :
    {gamma : I.Ctx} ->
    {x y z : X} ->
      I.Use gamma x y ->
      I.Use gamma y z ->
      I.Use gamma x z

/--
The globally available default context of a regime.
-/
def RelaxedInterfaceRegime.defaultContext
    {X : Type u}
    (I : RelaxedInterfaceRegime X) :
    I.Ctx :=
  I.defaultCtx

/--
The default reading at the globally available default context.
-/
def RelaxedInterfaceRegime.defaultContextRead
    {X : Type u}
    (I : RelaxedInterfaceRegime X) :
    I.Read I.defaultCtx :=
  I.defaultRead I.defaultCtx

/--
Non-contractive use is not defined by `x != y`.

It is the simultaneous presence of a regime-internal separation witness and a
regime-internal coordination witness.
-/
structure NonContractiveUse
    {X : Type u}
    (I : RelaxedInterfaceRegime X)
    (gamma : I.Ctx)
    (x y : X) where
  separation :
    I.Sep gamma x y

  coordination :
    I.Coord gamma x y

/--
The local use witness authorized by a non-contractive use.
-/
def NonContractiveUse.use
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y) :
    I.Use gamma x y :=
  I.use_of_noncontractive h.separation h.coordination

/--
The only eliminator exposed by a non-contractive use: transport through an
authorized reading.
-/
def NonContractiveUse.transport
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y)
    (rho : I.Read gamma) :
    I.OutRel gamma rho
      (I.read gamma rho x)
      (I.read gamma rho y) :=
  I.transport (NonContractiveUse.use h) rho

/--
The concrete transport obtained from the default reading of the context.
-/
def NonContractiveUse.defaultTransport
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y) :
    I.OutRel gamma (I.defaultRead gamma)
      (I.read gamma (I.defaultRead gamma) x)
      (I.read gamma (I.defaultRead gamma) y) :=
  NonContractiveUse.transport h (I.defaultRead gamma)

/--
Read the separation witness carried by a non-contractive use.
-/
def NonContractiveUse.separationWitness
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y) :
    I.Sep gamma x y :=
  h.separation

/--
Read the coordination witness carried by a non-contractive use.
-/
def NonContractiveUse.coordinationWitness
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y) :
    I.Coord gamma x y :=
  h.coordination

/--
Transport obtained directly from a use witness.
-/
def transportOfUse
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (use : I.Use gamma x y)
    (rho : I.Read gamma) :
    I.OutRel gamma rho
      (I.read gamma rho x)
      (I.read gamma rho y) :=
  I.transport use rho

/--
The constructive local chain exposed by the regime:

`Sep + Coord -> Use -> transport`.
-/
structure LocalTransportChain
    {X : Type u}
    (I : RelaxedInterfaceRegime X)
    (gamma : I.Ctx)
    (x y : X)
    (rho : I.Read gamma) where
  nonContractive :
    NonContractiveUse I gamma x y

  use :
    I.Use gamma x y

  use_eq :
    use = NonContractiveUse.use nonContractive

  transported :
    I.OutRel gamma rho
      (I.read gamma rho x)
      (I.read gamma rho y)

/--
Canonical chain for any authorized reading.
-/
def localTransportChain
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y)
    (rho : I.Read gamma) :
    LocalTransportChain I gamma x y rho where
  nonContractive := h
  use := NonContractiveUse.use h
  use_eq := rfl
  transported := NonContractiveUse.transport h rho

/--
Canonical non-vacuous chain at the default reading.
-/
def defaultLocalTransportChain
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (h : NonContractiveUse I gamma x y) :
    LocalTransportChain I gamma x y (I.defaultRead gamma) :=
  localTransportChain h (I.defaultRead gamma)

/--
Read the separation witness from a local transport chain.
-/
def LocalTransportChain.separation
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    {rho : I.Read gamma}
    (chain : LocalTransportChain I gamma x y rho) :
    I.Sep gamma x y :=
  chain.nonContractive.separation

/--
Read the coordination witness from a local transport chain.
-/
def LocalTransportChain.coordination
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    {rho : I.Read gamma}
    (chain : LocalTransportChain I gamma x y rho) :
    I.Coord gamma x y :=
  chain.nonContractive.coordination

/--
Read the transported output relation from a local transport chain.
-/
def LocalTransportChain.transport
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    {rho : I.Read gamma}
    (chain : LocalTransportChain I gamma x y rho) :
    I.OutRel gamma rho
      (I.read gamma rho x)
      (I.read gamma rho y) :=
  chain.transported

end RelaxedUsageRegime
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedUsageRegime.HasUse
#print axioms Meta.RelaxedUsageRegime.CompositionalUse
#print axioms Meta.RelaxedUsageRegime.NonContractiveUse.use
#print axioms Meta.RelaxedUsageRegime.NonContractiveUse.transport
#print axioms Meta.RelaxedUsageRegime.NonContractiveUse.defaultTransport
#print axioms Meta.RelaxedUsageRegime.RelaxedInterfaceRegime.defaultContext
#print axioms Meta.RelaxedUsageRegime.RelaxedInterfaceRegime.defaultContextRead
#print axioms Meta.RelaxedUsageRegime.transportOfUse
#print axioms Meta.RelaxedUsageRegime.localTransportChain
#print axioms Meta.RelaxedUsageRegime.defaultLocalTransportChain
#print axioms Meta.RelaxedUsageRegime.LocalTransportChain.transport
/- AXIOM_AUDIT_END -/
