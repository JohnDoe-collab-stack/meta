import Carbone.CW1.Lean.MaintenanceMemory

/-!
# CW1-beta: intrinsic open energy throughput

`CW1-alpha` preserves structure and carries a topology bit.  This module adds
a positive gate for resource-coupled maintenance, then crosses its energy
branch with an explicit stationary throughput: one energy token enters, is
requested and dissipated, while one available token remains in the local
environment.

This establishes an active flow inside the formal model.  It does not identify
the abstract tokens with a physical energy scale or chemical mechanism.
-/

namespace Meta
namespace Carbone
namespace CW1

open CW0

namespace AtomInventory

/-- Positive evidence that at least one requested atomic resource is nonzero. -/
inductive HasPositive : AtomInventory -> Type where
  | carbon {inventory : AtomInventory} :
      0 < inventory.carbon -> HasPositive inventory
  | hydrogen {inventory : AtomInventory} :
      0 < inventory.hydrogen -> HasPositive inventory
  | nitrogen {inventory : AtomInventory} :
      0 < inventory.nitrogen -> HasPositive inventory
  | oxygen {inventory : AtomInventory} :
      0 < inventory.oxygen -> HasPositive inventory
  | phosphorus {inventory : AtomInventory} :
      0 < inventory.phosphorus -> HasPositive inventory
  | sulfur {inventory : AtomInventory} :
      0 < inventory.sulfur -> HasPositive inventory

/-- The zero inventory carries no positive resource witness. -/
def zero_not_hasPositive : HasPositive AtomInventory.zero -> False
  | .carbon positive => Nat.not_lt_zero 0 positive
  | .hydrogen positive => Nat.not_lt_zero 0 positive
  | .nitrogen positive => Nat.not_lt_zero 0 positive
  | .oxygen positive => Nat.not_lt_zero 0 positive
  | .phosphorus positive => Nat.not_lt_zero 0 positive
  | .sulfur positive => Nat.not_lt_zero 0 positive

end AtomInventory

namespace CarbonWorld

/-- Resource demand read directly from the intrinsic causal interaction. -/
def requestedResourcesAt
    (world : CarbonWorld)
    (point : world.Point) : AtomInventory :=
  (world.causalStepAt point.1 point.2).interaction.requestedResources

/-- Energy demand read directly from the intrinsic causal interaction. -/
def requestedEnergyAt
    (world : CarbonWorld)
    (point : world.Point) : Nat :=
  (world.causalStepAt point.1 point.2).interaction.requestedEnergy

end CarbonWorld

/-!
This is a necessary gate, not a sufficient definition of active physical
maintenance.  The witness is indexed by the actual point and can only be
constructed from the interaction already carried by the world.
-/
inductive NonzeroMaintenanceDemand
    (world : CarbonWorld)
    (point : world.Point) : Type where
  | energy :
      0 < CarbonWorld.requestedEnergyAt world point ->
        NonzeroMaintenanceDemand world point
  | resources :
      Meta.Carbone.CW1.AtomInventory.HasPositive
          (CarbonWorld.requestedResourcesAt world point) ->
        NonzeroMaintenanceDemand world point

/-- Maintenance coupled at every admissible step to an intrinsic nonzero demand. -/
structure ResourceCoupledMaintenance (world : CarbonWorld)
    extends CarbonMaintenance world where
  demandAt : (point : world.Point) -> NonzeroMaintenanceDemand world point

/-!
The energy branch is stronger: its positive inflow is stored in the repair,
whose balance and equality between dissipation and causal demand are already
intrinsic fields of `CarbonWorld`.
-/
structure EnergyThroughputMaintenance (world : CarbonWorld)
    extends CarbonMaintenance world where
  requestedEnergyPositive :
    (point : world.Point) ->
      0 < CarbonWorld.requestedEnergyAt world point
  energyInflowPositive :
    (point : world.Point) -> 0 < (world.repairAt point).energyInflow

namespace EnergyThroughputMaintenance

/-- Every positive energy throughput crosses the general demand gate. -/
def toResourceCoupledMaintenance
    {world : CarbonWorld}
    (throughput : EnergyThroughputMaintenance world) :
    ResourceCoupledMaintenance world where
  toCarbonMaintenance := throughput.toCarbonMaintenance
  demandAt := fun point =>
    NonzeroMaintenanceDemand.energy
      (throughput.requestedEnergyPositive point)

end EnergyThroughputMaintenance

/-- The concrete two-phase interaction requests no atomic resource. -/
theorem twoPhase_requestedResourcesAt_zero
    (point : twoPhaseWorld.Point) :
    CarbonWorld.requestedResourcesAt twoPhaseWorld point =
      AtomInventory.zero := by
  rcases point with ⟨source, admissible⟩
  cases admissible with
  | generated phase history =>
      cases phase <;> rfl

/-- Every concrete two-phase interaction requests one energy token. -/
theorem twoPhase_requestedEnergyAt_one
    (point : twoPhaseWorld.Point) :
    CarbonWorld.requestedEnergyAt twoPhaseWorld point = 1 := by
  rcases point with ⟨source, admissible⟩
  cases admissible with
  | generated phase history =>
      cases phase <;> rfl

/-- Every repair receives one explicit energy token from the open boundary. -/
theorem twoPhase_energyInflow_one
    (point : twoPhaseWorld.Point) :
    (twoPhaseWorld.repairAt point).energyInflow = 1 := by
  rcases point with ⟨source, admissible⟩
  cases admissible with
  | generated phase history =>
      cases phase <;> rfl

/-- Every repair dissipates the one token requested by its interaction. -/
theorem twoPhase_energyDissipated_one
    (point : twoPhaseWorld.Point) :
    (twoPhaseWorld.repairAt point).energyDissipated = 1 := by
  rcases point with ⟨source, admissible⟩
  cases admissible with
  | generated phase history =>
      cases phase <;> rfl

/-- The concrete witness has positive, balanced energy throughput at every step. -/
def twoPhaseEnergyThroughputMaintenance :
    EnergyThroughputMaintenance twoPhaseWorld where
  toCarbonMaintenance := twoPhaseMaintenance
  requestedEnergyPositive := by
    intro point
    rw [twoPhase_requestedEnergyAt_one point]
    exact Nat.zero_lt_succ 0
  energyInflowPositive := by
    intro point
    rw [twoPhase_energyInflow_one point]
    exact Nat.zero_lt_succ 0

def twoPhaseResourceCoupledMaintenance :
    ResourceCoupledMaintenance twoPhaseWorld :=
  twoPhaseEnergyThroughputMaintenance.toResourceCoupledMaintenance

/-- The executed world step satisfies the stationary open-energy ledger. -/
theorem twoPhase_step_energyBalance
    (point : twoPhaseWorld.Point) :
    point.1.environment.energyTokens +
          (twoPhaseWorld.repairAt point).energyInflow =
      (twoPhaseWorld.step point).1.environment.energyTokens +
        (twoPhaseWorld.repairAt point).energyDissipated :=
  twoPhaseWorld.step_energyBalance point

/-- Dissipation is definitionally tied to the causal interaction demand. -/
theorem twoPhase_energyDissipated_eq_requested
    (point : twoPhaseWorld.Point) :
    (twoPhaseWorld.repairAt point).energyDissipated =
      CarbonWorld.requestedEnergyAt twoPhaseWorld point :=
  twoPhaseWorld.repairAt_energyDissipated_eq_requested point

end CW1
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CW1.AtomInventory.zero_not_hasPositive
#print axioms Meta.Carbone.CW1.CarbonWorld.requestedResourcesAt
#print axioms Meta.Carbone.CW1.CarbonWorld.requestedEnergyAt
#print axioms Meta.Carbone.CW1.EnergyThroughputMaintenance.toResourceCoupledMaintenance
#print axioms Meta.Carbone.CW1.twoPhase_requestedResourcesAt_zero
#print axioms Meta.Carbone.CW1.twoPhase_requestedEnergyAt_one
#print axioms Meta.Carbone.CW1.twoPhase_energyInflow_one
#print axioms Meta.Carbone.CW1.twoPhase_energyDissipated_one
#print axioms Meta.Carbone.CW1.twoPhaseEnergyThroughputMaintenance
#print axioms Meta.Carbone.CW1.twoPhaseResourceCoupledMaintenance
#print axioms Meta.Carbone.CW1.twoPhase_step_energyBalance
#print axioms Meta.Carbone.CW1.twoPhase_energyDissipated_eq_requested
/- AXIOM_AUDIT_END -/
