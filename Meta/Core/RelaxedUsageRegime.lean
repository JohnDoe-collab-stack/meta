universe u c r o s k l m

namespace Meta
namespace RelaxedUsageRegime

/--
A totally relaxed interface regime.

The regime does not start from internal equality, projected equality, or global
substitution. It carries its own contexts, authorized readings, output types,
separation witnesses, coordination witnesses, use witnesses, and output
relations.

The `defaultRead` field makes the regime locally non-vacuous at every context:
there is always at least one authorized reading on which transport can act.
-/
structure RelaxedInterfaceRegime (X : Type u) where
  Ctx : Type c

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

  use_of_coord :
    forall {gamma : Ctx} {x y : X},
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
  I.use_of_coord h.coordination

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
Transport obtained directly from a coordination witness.
-/
def transportOfCoord
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (coord : I.Coord gamma x y)
    (rho : I.Read gamma) :
    I.OutRel gamma rho
      (I.read gamma rho x)
      (I.read gamma rho y) :=
  I.transport (I.use_of_coord coord) rho

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
#print axioms Meta.RelaxedUsageRegime.NonContractiveUse.use
#print axioms Meta.RelaxedUsageRegime.NonContractiveUse.transport
#print axioms Meta.RelaxedUsageRegime.NonContractiveUse.defaultTransport
#print axioms Meta.RelaxedUsageRegime.transportOfCoord
#print axioms Meta.RelaxedUsageRegime.transportOfUse
#print axioms Meta.RelaxedUsageRegime.localTransportChain
#print axioms Meta.RelaxedUsageRegime.defaultLocalTransportChain
#print axioms Meta.RelaxedUsageRegime.LocalTransportChain.transport
/- AXIOM_AUDIT_END -/
