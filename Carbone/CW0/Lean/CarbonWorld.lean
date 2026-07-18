import Meta.Core.ProjectiveCore

/-!
# CW0: positive finite substrate for a carbon world

This file introduces only the finite substrate needed by a later instance of
the dynamic Core.  It provides no chemical oracle and no empirical claim.
The successor of a `CarbonWorld` point is derived from its causal response and
repair; no independent next-state field is present.
-/

namespace Meta
namespace Carbone
namespace CW0

inductive Element where
  | carbon
  | hydrogen
  | nitrogen
  | oxygen
  | phosphorus
  | sulfur
deriving DecidableEq, Repr

structure AtomInventory where
  carbon : Nat
  hydrogen : Nat
  nitrogen : Nat
  oxygen : Nat
  phosphorus : Nat
  sulfur : Nat
deriving DecidableEq, Repr

namespace AtomInventory

def zero : AtomInventory where
  carbon := 0
  hydrogen := 0
  nitrogen := 0
  oxygen := 0
  phosphorus := 0
  sulfur := 0

def add (left right : AtomInventory) : AtomInventory where
  carbon := left.carbon + right.carbon
  hydrogen := left.hydrogen + right.hydrogen
  nitrogen := left.nitrogen + right.nitrogen
  oxygen := left.oxygen + right.oxygen
  phosphorus := left.phosphorus + right.phosphorus
  sulfur := left.sulfur + right.sulfur

def increment (inventory : AtomInventory) : Element -> AtomInventory
  | .carbon => { inventory with carbon := inventory.carbon + 1 }
  | .hydrogen => { inventory with hydrogen := inventory.hydrogen + 1 }
  | .nitrogen => { inventory with nitrogen := inventory.nitrogen + 1 }
  | .oxygen => { inventory with oxygen := inventory.oxygen + 1 }
  | .phosphorus => { inventory with phosphorus := inventory.phosphorus + 1 }
  | .sulfur => { inventory with sulfur := inventory.sulfur + 1 }

def ofElements : List Element -> AtomInventory
  | [] => zero
  | element :: tail => increment (ofElements tail) element

def Le (left right : AtomInventory) : Prop :=
  left.carbon <= right.carbon ∧
  left.hydrogen <= right.hydrogen ∧
  left.nitrogen <= right.nitrogen ∧
  left.oxygen <= right.oxygen ∧
  left.phosphorus <= right.phosphorus ∧
  left.sulfur <= right.sulfur

end AtomInventory

inductive BondOrder where
  | single
  | double
  | triple
deriving DecidableEq, Repr

structure BondRecord where
  left : Nat
  right : Nat
  order : BondOrder
deriving DecidableEq, Repr

structure CarbonConfiguration where
  atoms : List Element
  bonds : List BondRecord
deriving DecidableEq, Repr

namespace CarbonConfiguration

def inventory (configuration : CarbonConfiguration) : AtomInventory :=
  AtomInventory.ofElements configuration.atoms

def ContainsCarbon (configuration : CarbonConfiguration) : Prop :=
  0 < configuration.inventory.carbon

def BondWellFormed
    (configuration : CarbonConfiguration)
    (bond : BondRecord) : Prop :=
  bond.left < configuration.atoms.length ∧
  bond.right < configuration.atoms.length ∧
  (bond.left = bond.right -> False)

/-- Every stored bond has two distinct endpoints inside the atom list. -/
def BondsWellFormed
    (configuration : CarbonConfiguration) : Prop :=
  (bond : BondRecord) ->
    bond ∈ configuration.bonds ->
      configuration.BondWellFormed bond

end CarbonConfiguration

structure CarbonOrganization where
  configuration : CarbonConfiguration
  carbonPresent : configuration.ContainsCarbon
  bondsWellFormed : configuration.BondsWellFormed

abbrev CarbonVisible := AtomInventory

def project (organization : CarbonOrganization) : CarbonVisible :=
  organization.configuration.inventory

def chainSkeleton : CarbonConfiguration where
  atoms := [.carbon, .carbon, .oxygen]
  bonds :=
    [ { left := 0, right := 1, order := .single }
    , { left := 1, right := 2, order := .single } ]

def bridgedSkeleton : CarbonConfiguration where
  atoms := [.carbon, .carbon, .oxygen]
  bonds :=
    [ { left := 0, right := 2, order := .single }
    , { left := 1, right := 2, order := .single } ]

def chainOrganization : CarbonOrganization where
  configuration := chainSkeleton
  carbonPresent := by
    change 0 < 2
    exact Nat.zero_lt_succ 1
  bondsWellFormed := by
    intro bond membership
    cases membership with
    | head =>
        exact
          ⟨ Nat.zero_lt_succ 2
          , Nat.succ_lt_succ (Nat.zero_lt_succ 1)
          , fun equality => Nat.noConfusion equality ⟩
    | tail _ membership =>
        cases membership with
        | head =>
            exact
              ⟨ Nat.succ_lt_succ (Nat.zero_lt_succ 1)
              , Nat.lt_succ_self 2
              , fun equality =>
                  Nat.noConfusion (Nat.succ.inj equality) ⟩
        | tail _ impossible => nomatch impossible

def bridgedOrganization : CarbonOrganization where
  configuration := bridgedSkeleton
  carbonPresent := by
    change 0 < 2
    exact Nat.zero_lt_succ 1
  bondsWellFormed := by
    intro bond membership
    cases membership with
    | head =>
        exact
          ⟨ Nat.zero_lt_succ 2
          , Nat.lt_succ_self 2
          , fun equality => Nat.noConfusion equality ⟩
    | tail _ membership =>
        cases membership with
        | head =>
            exact
              ⟨ Nat.succ_lt_succ (Nat.zero_lt_succ 1)
              , Nat.lt_succ_self 2
              , fun equality =>
                  Nat.noConfusion (Nat.succ.inj equality) ⟩
        | tail _ impossible => nomatch impossible

theorem chainOrganization_ne_bridgedOrganization :
    chainOrganization = bridgedOrganization -> False := by
  intro equality
  have bondEquality :
      chainOrganization.configuration.bonds =
        bridgedOrganization.configuration.bonds :=
    congrArg (fun organization : CarbonOrganization =>
      organization.configuration.bonds) equality
  have firstBondEquality :
      ({ left := 0, right := 1, order := .single } : BondRecord) =
        ({ left := 0, right := 2, order := .single } : BondRecord) :=
    (List.cons.inj bondEquality).1
  have rightEquality : (1 : Nat) = 2 :=
    congrArg BondRecord.right firstBondEquality
  exact (by decide : (1 : Nat) = 2 -> False) rightEquality

def carbonProjectionObstruction :
    ClosedStabilityTheorem.ProjectionObstruction
      CarbonOrganization CarbonVisible project where
  left := chainOrganization
  right := bridgedOrganization
  sameProjection := rfl
  separatedInterface := chainOrganization_ne_bridgedOrganization

structure CarbonEnvironment where
  resources : AtomInventory
  energyTokens : Nat
  compartmentCapacity : Nat
deriving DecidableEq, Repr

structure HistoryRecord where
  gapTag : Nat
  interactionTag : Nat
  responseTag : Nat
deriving DecidableEq, Repr

structure WorldState where
  organization : CarbonOrganization
  environment : CarbonEnvironment
  history : List HistoryRecord

def totalInventory (state : WorldState) : AtomInventory :=
  AtomInventory.add
    state.organization.configuration.inventory
    state.environment.resources

structure CarbonGap (source : WorldState) where
  tag : Nat
  shadow : CarbonOrganization
  sameProjection : project source.organization = project shadow
  separated : source.organization = shadow -> False

structure CarbonInteraction
    (source : WorldState)
    (_gap : CarbonGap source) where
  tag : Nat
  requestedResources : AtomInventory
  requestedEnergy : Nat
  resourcesAvailable : requestedResources.Le source.environment.resources
  energyAvailable : requestedEnergy <= source.environment.energyTokens

structure CarbonResponse
    (source : WorldState)
    {gap : CarbonGap source}
    (_interaction : CarbonInteraction source gap) where
  tag : Nat
  afterOrganization : CarbonOrganization
  afterEnvironment : CarbonEnvironment
  inventoryBalanced :
    totalInventory source =
      AtomInventory.add
        afterOrganization.configuration.inventory
        afterEnvironment.resources
  energyNonincreasing :
    afterEnvironment.energyTokens <= source.environment.energyTokens

structure CarbonCausalStep (source : WorldState) where
  gap : CarbonGap source
  interaction : CarbonInteraction source gap
  response : CarbonResponse source interaction
  record : HistoryRecord
  recordGap_eq : record.gapTag = gap.tag
  recordInteraction_eq : record.interactionTag = interaction.tag
  recordResponse_eq : record.responseTag = response.tag

structure CarbonRepair (source : WorldState) where
  afterOrganization : CarbonOrganization
  afterEnvironment : CarbonEnvironment
  record : HistoryRecord
  inventoryBalanced :
    totalInventory source =
      AtomInventory.add
        afterOrganization.configuration.inventory
        afterEnvironment.resources
  energyNonincreasing :
    afterEnvironment.energyTokens <= source.environment.energyTokens

def repairOfCausalStep
    {source : WorldState}
    (causalStep : CarbonCausalStep source) :
    CarbonRepair source where
  afterOrganization := causalStep.response.afterOrganization
  afterEnvironment := causalStep.response.afterEnvironment
  record := causalStep.record
  inventoryBalanced := causalStep.response.inventoryBalanced
  energyNonincreasing := causalStep.response.energyNonincreasing

def executeRepair
    (source : WorldState)
    (repair : CarbonRepair source) : WorldState where
  organization := repair.afterOrganization
  environment := repair.afterEnvironment
  history := source.history ++ [repair.record]

structure CarbonWorld where
  Admissible : WorldState -> Type
  initial : WorldState
  initialAdmissible : Admissible initial
  causalStepAt :
    (source : WorldState) ->
    Admissible source ->
    CarbonCausalStep source
  closedUnderRepair :
    (source : WorldState) ->
    (admissible : Admissible source) ->
    Admissible
      (executeRepair source (repairOfCausalStep (causalStepAt source admissible)))

namespace CarbonWorld

def Point (world : CarbonWorld) : Type :=
  (source : WorldState) × world.Admissible source

def initialPoint (world : CarbonWorld) : world.Point :=
  ⟨world.initial, world.initialAdmissible⟩

def repairAt
    (world : CarbonWorld)
    (point : world.Point) : CarbonRepair point.1 :=
  repairOfCausalStep (world.causalStepAt point.1 point.2)

def step
    (world : CarbonWorld)
    (point : world.Point) : world.Point :=
  ⟨ executeRepair point.1 (world.repairAt point)
  , world.closedUnderRepair point.1 point.2 ⟩

theorem step_eq_executeRepair
    (world : CarbonWorld)
    (point : world.Point) :
    (world.step point).1 = executeRepair point.1 (world.repairAt point) :=
  rfl

theorem step_totalInventory
    (world : CarbonWorld)
    (point : world.Point) :
    totalInventory (world.step point).1 = totalInventory point.1 := by
  exact (world.repairAt point).inventoryBalanced.symm

theorem step_history
    (world : CarbonWorld)
    (point : world.Point) :
    (world.step point).1.history =
      point.1.history ++ [(world.repairAt point).record] :=
  rfl

end CarbonWorld

end CW0
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CW0.chainOrganization
#print axioms Meta.Carbone.CW0.bridgedOrganization
#print axioms Meta.Carbone.CW0.carbonProjectionObstruction
#print axioms Meta.Carbone.CW0.CarbonWorld.step_eq_executeRepair
#print axioms Meta.Carbone.CW0.CarbonWorld.step_totalInventory
#print axioms Meta.Carbone.CW0.CarbonWorld.step_history
/- AXIOM_AUDIT_END -/
