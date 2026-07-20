import Carbone.CW0.Lean.FiniteKernel

/-!
# CW1-alpha: structural maintenance and material topology memory

This module adds the first layer above `CW0`.  It isolates two positive
contracts:

* maintenance preserves the organizational atom inventory and the complete
  environment at every admissible step;
* material memory is read only from the carbon organization, has an intrinsic
  finite code, and its update commutes with the world step.

The concrete witness uses the first bond endpoint to read one bit from the
two-phase topology.  It is a formal structural memory, not a claim about a
physical molecular memory, reproduction, heredity, or selection.
-/

namespace Meta
namespace Carbone
namespace CW1

open CW0

/-- Stepwise material invariants required of a maintained carbon world. -/
structure CarbonMaintenance (world : CarbonWorld) where
  environment_preserved :
    (point : world.Point) ->
      (world.step point).1.environment = point.1.environment
  organization_inventory_preserved :
    (point : world.Point) ->
      (world.step point).1.organization.configuration.inventory =
        point.1.organization.configuration.inventory

namespace CarbonMaintenance

/-- Maintenance of the organization and environment implies total balance. -/
theorem totalInventory_preserved
    {world : CarbonWorld}
    (maintenance : CarbonMaintenance world)
    (point : world.Point) :
    totalInventory (world.step point).1 = totalInventory point.1 := by
  change
    AtomInventory.add
        (world.step point).1.organization.configuration.inventory
        (world.step point).1.environment.resources =
      AtomInventory.add
        point.1.organization.configuration.inventory
        point.1.environment.resources
  rw [maintenance.organization_inventory_preserved point]
  rw [maintenance.environment_preserved point]

end CarbonMaintenance

/-!
`read` receives only the material organization.  The history and the
admissibility witness are therefore unavailable to the decoder.
-/
structure CarbonMaterialMemory
    (world : CarbonWorld)
    (Memory : Type) where
  read : CarbonOrganization -> Memory
  encode : Memory -> CarbonOrganization
  update : Memory -> Memory
  read_encode : (memory : Memory) -> read (encode memory) = memory
  organization_encoded :
    (point : world.Point) ->
      encode (read point.1.organization) = point.1.organization
  read_step :
    (point : world.Point) ->
      read (world.step point).1.organization =
        update (read point.1.organization)
  update_involutive :
    (memory : Memory) -> update (update memory) = memory

namespace CarbonMaterialMemory

/-- Two material updates restore the readable code when `update` is involutive. -/
theorem read_two_steps
    {world : CarbonWorld}
    {Memory : Type}
    (memory : CarbonMaterialMemory world Memory)
    (point : world.Point) :
    memory.read (world.step (world.step point)).1.organization =
      memory.read point.1.organization := by
  calc
    memory.read (world.step (world.step point)).1.organization =
        memory.update (memory.read (world.step point).1.organization) :=
      memory.read_step (world.step point)
    _ = memory.update (memory.update (memory.read point.1.organization)) :=
      congrArg memory.update (memory.read_step point)
    _ = memory.read point.1.organization :=
      memory.update_involutive (memory.read point.1.organization)

end CarbonMaterialMemory

/-- Read the concrete bit from the topology, without consulting phase or history. -/
def readTwoPhaseTopology (organization : CarbonOrganization) : TwoPhase :=
  match organization.configuration.bonds with
  | [] => .chain
  | bond :: _remaining =>
      match bond.right with
      | 2 => .bridged
      | _ => .chain

theorem readTwoPhaseTopology_organization
    (phase : TwoPhase) :
    readTwoPhaseTopology phase.organization = phase := by
  cases phase <;> rfl

/-- The concrete world maintains its atom inventory and complete environment. -/
def twoPhaseMaintenance : CarbonMaintenance twoPhaseWorld where
  environment_preserved := by
    intro point
    rcases point with ⟨source, admissible⟩
    cases admissible with
    | generated phase history =>
        cases phase <;> rfl
  organization_inventory_preserved := by
    intro point
    rcases point with ⟨source, admissible⟩
    cases admissible with
    | generated phase history =>
        cases phase <;> rfl

/-- The two bond topologies form a closed, intrinsically updated one-bit memory. -/
def twoPhaseMaterialMemory :
    CarbonMaterialMemory twoPhaseWorld TwoPhase where
  read := readTwoPhaseTopology
  encode := TwoPhase.organization
  update := TwoPhase.other
  read_encode := readTwoPhaseTopology_organization
  organization_encoded := by
    intro point
    rcases point with ⟨source, admissible⟩
    cases admissible with
    | generated phase history =>
        cases phase <;> rfl
  read_step := by
    intro point
    rcases point with ⟨source, admissible⟩
    cases admissible with
    | generated phase history =>
        cases phase <;> rfl
  update_involutive := by
    intro phase
    cases phase <;> rfl

/-- The visible atom inventory does not expose the topology bit. -/
theorem twoPhaseMemory_sameProjection :
    project (twoPhaseMaterialMemory.encode .chain) =
      project (twoPhaseMaterialMemory.encode .bridged) :=
  rfl

/-- The two material codes remain constructively distinguishable when read. -/
theorem twoPhaseMemory_reads_separated :
    twoPhaseMaterialMemory.read (twoPhaseMaterialMemory.encode .chain) =
        twoPhaseMaterialMemory.read (twoPhaseMaterialMemory.encode .bridged) ->
      False := by
  intro equality
  change TwoPhase.chain = TwoPhase.bridged at equality
  nomatch equality

/-- The Core successor performs exactly the material-memory update. -/
theorem twoPhaseCore_read_updates
    (point : twoPhaseWorld.Point) :
    twoPhaseMaterialMemory.read
        (twoPhaseGapRepairAlgebra.next point).1.organization =
      twoPhaseMaterialMemory.update
        (twoPhaseMaterialMemory.read point.1.organization) := by
  calc
    twoPhaseMaterialMemory.read
        (twoPhaseGapRepairAlgebra.next point).1.organization =
        twoPhaseMaterialMemory.read
          (twoPhaseWorld.step point).1.organization :=
      congrArg
        (fun current : twoPhaseWorld.Point =>
          twoPhaseMaterialMemory.read current.1.organization)
        (twoPhaseCoreNext_eq_worldStep point)
    _ = twoPhaseMaterialMemory.update
          (twoPhaseMaterialMemory.read point.1.organization) :=
      twoPhaseMaterialMemory.read_step point

/-- After two Core steps the material organization itself is restored. -/
theorem twoPhaseCore_two_steps_organization
    (point : twoPhaseWorld.Point) :
    (twoPhaseGapRepairAlgebra.next
        (twoPhaseGapRepairAlgebra.next point)).1.organization =
      point.1.organization := by
  rcases point with ⟨source, admissible⟩
  cases admissible with
  | generated phase history =>
      cases phase <;> rfl

/-- Two Core steps restore the readable topology bit. -/
theorem twoPhaseCore_read_two_steps
    (point : twoPhaseWorld.Point) :
    twoPhaseMaterialMemory.read
        (twoPhaseGapRepairAlgebra.next
          (twoPhaseGapRepairAlgebra.next point)).1.organization =
      twoPhaseMaterialMemory.read point.1.organization := by
  exact congrArg twoPhaseMaterialMemory.read
    (twoPhaseCore_two_steps_organization point)

end CW1
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CW1.CarbonMaintenance.totalInventory_preserved
#print axioms Meta.Carbone.CW1.CarbonMaterialMemory.read_two_steps
#print axioms Meta.Carbone.CW1.readTwoPhaseTopology_organization
#print axioms Meta.Carbone.CW1.twoPhaseMaintenance
#print axioms Meta.Carbone.CW1.twoPhaseMaterialMemory
#print axioms Meta.Carbone.CW1.twoPhaseMemory_sameProjection
#print axioms Meta.Carbone.CW1.twoPhaseMemory_reads_separated
#print axioms Meta.Carbone.CW1.twoPhaseCore_read_updates
#print axioms Meta.Carbone.CW1.twoPhaseCore_two_steps_organization
#print axioms Meta.Carbone.CW1.twoPhaseCore_read_two_steps
/- AXIOM_AUDIT_END -/
