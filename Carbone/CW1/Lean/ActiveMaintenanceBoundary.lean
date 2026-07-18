import Carbone.CW1.Lean.MaintenanceMemory

/-!
# CW1-beta boundary: nonzero intrinsic maintenance demand

`CW1-alpha` preserves structure and carries a topology bit, but its concrete
interaction requests no resource and no energy.  This module makes that limit
formal.  It defines a positive necessary gate for resource-coupled maintenance
and proves that the current two-phase witness cannot cross it.

Crossing the gate would still not establish physical maintenance: an extended
world must also represent effective uptake, dissipation and replenishment.
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

/-- The concrete two-phase interaction requests no atomic resource. -/
theorem twoPhase_requestedResourcesAt_zero
    (point : twoPhaseWorld.Point) :
    CarbonWorld.requestedResourcesAt twoPhaseWorld point =
      AtomInventory.zero := by
  rcases point with ⟨source, admissible⟩
  cases admissible with
  | generated phase history =>
      cases phase <;> rfl

/-- The concrete two-phase interaction requests no energy. -/
theorem twoPhase_requestedEnergyAt_zero
    (point : twoPhaseWorld.Point) :
    CarbonWorld.requestedEnergyAt twoPhaseWorld point = 0 := by
  rcases point with ⟨source, admissible⟩
  cases admissible with
  | generated phase history =>
      cases phase <;> rfl

/-- No admissible point of the current witness has a nonzero maintenance demand. -/
theorem twoPhase_no_nonzeroMaintenanceDemand
    (point : twoPhaseWorld.Point) :
    NonzeroMaintenanceDemand twoPhaseWorld point -> False := by
  intro demand
  cases demand with
  | energy positive =>
      rw [twoPhase_requestedEnergyAt_zero point] at positive
      exact Nat.not_lt_zero 0 positive
  | resources positive =>
      rw [twoPhase_requestedResourcesAt_zero point] at positive
      exact AtomInventory.zero_not_hasPositive positive

/-- `CW0`/`CW1-alpha` cannot be mislabeled as resource-coupled maintenance. -/
theorem twoPhase_not_resourceCoupledMaintenance :
    ResourceCoupledMaintenance twoPhaseWorld -> False := by
  intro maintenance
  exact
    twoPhase_no_nonzeroMaintenanceDemand
      twoPhaseWorld.initialPoint
      (maintenance.demandAt twoPhaseWorld.initialPoint)

end CW1
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CW1.AtomInventory.zero_not_hasPositive
#print axioms Meta.Carbone.CW1.CarbonWorld.requestedResourcesAt
#print axioms Meta.Carbone.CW1.CarbonWorld.requestedEnergyAt
#print axioms Meta.Carbone.CW1.twoPhase_requestedResourcesAt_zero
#print axioms Meta.Carbone.CW1.twoPhase_requestedEnergyAt_zero
#print axioms Meta.Carbone.CW1.twoPhase_no_nonzeroMaintenanceDemand
#print axioms Meta.Carbone.CW1.twoPhase_not_resourceCoupledMaintenance
/- AXIOM_AUDIT_END -/
