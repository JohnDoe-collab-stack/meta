import Carbone.CW0.Lean.ExportTwoPhase
import Carbone.CW1.Lean.ActiveMaintenanceBoundary

/-!
# CW1-beta: certified JSON export of the open energy throughput

This module depends on the stable `CW0` exporter for state serialization and
adds only the phase-indexed energy-flow payload.  `CW0` never imports `CW1`.
-/

namespace Meta
namespace Carbone
namespace CW1

open CW0

def canonicalTwoPhasePoint
    (phase : TwoPhase) : twoPhaseWorld.Point :=
  ⟨ twoPhaseState phase []
  , TwoPhaseAdmissible.generated phase [] ⟩

/-- Certified energy fields for one canonical finite phase representative. -/
structure CertifiedTwoPhaseEnergyFlowExport (phase : TwoPhase) where
  requestedEnergy : Nat
  energyInflow : Nat
  energyDissipated : Nat
  availableBefore : Nat
  availableAfter : Nat
  requestedEnergy_eq :
    requestedEnergy =
      CarbonWorld.requestedEnergyAt
        twoPhaseWorld
        (canonicalTwoPhasePoint phase)
  energyInflow_eq :
    energyInflow =
      (twoPhaseWorld.repairAt
        (canonicalTwoPhasePoint phase)).energyInflow
  energyDissipated_eq :
    energyDissipated =
      (twoPhaseWorld.repairAt
        (canonicalTwoPhasePoint phase)).energyDissipated
  availableBefore_eq :
    availableBefore =
      (canonicalTwoPhasePoint phase).1.environment.energyTokens
  availableAfter_eq :
    availableAfter =
      (twoPhaseWorld.step
        (canonicalTwoPhasePoint phase)).1.environment.energyTokens

namespace CertifiedTwoPhaseEnergyFlowExport

/-- Every energy field admitted by the payload equals its Lean computation. -/
theorem fields_eq_lean
    {phase : TwoPhase}
    (exported : CertifiedTwoPhaseEnergyFlowExport phase) :
    exported.requestedEnergy =
        CarbonWorld.requestedEnergyAt
          twoPhaseWorld
          (canonicalTwoPhasePoint phase) ∧
      exported.energyInflow =
        (twoPhaseWorld.repairAt
          (canonicalTwoPhasePoint phase)).energyInflow ∧
      exported.energyDissipated =
        (twoPhaseWorld.repairAt
          (canonicalTwoPhasePoint phase)).energyDissipated ∧
      exported.availableBefore =
        (canonicalTwoPhasePoint phase).1.environment.energyTokens ∧
      exported.availableAfter =
        (twoPhaseWorld.step
          (canonicalTwoPhasePoint phase)).1.environment.energyTokens := by
  exact
    ⟨ exported.requestedEnergy_eq
    , exported.energyInflow_eq
    , exported.energyDissipated_eq
    , exported.availableBefore_eq
    , exported.availableAfter_eq ⟩

end CertifiedTwoPhaseEnergyFlowExport

def certifiedTwoPhaseEnergyFlowExport
    (phase : TwoPhase) : CertifiedTwoPhaseEnergyFlowExport phase where
  requestedEnergy :=
    CarbonWorld.requestedEnergyAt
      twoPhaseWorld
      (canonicalTwoPhasePoint phase)
  energyInflow :=
    (twoPhaseWorld.repairAt
      (canonicalTwoPhasePoint phase)).energyInflow
  energyDissipated :=
    (twoPhaseWorld.repairAt
      (canonicalTwoPhasePoint phase)).energyDissipated
  availableBefore :=
    (canonicalTwoPhasePoint phase).1.environment.energyTokens
  availableAfter :=
    (twoPhaseWorld.step
      (canonicalTwoPhasePoint phase)).1.environment.energyTokens
  requestedEnergy_eq := rfl
  energyInflow_eq := rfl
  energyDissipated_eq := rfl
  availableBefore_eq := rfl
  availableAfter_eq := rfl

/-- Serialize one transition entirely from its phase-indexed certified payload. -/
def writeTwoPhaseEnergyTransition
    (handle : IO.FS.Handle)
    (phase : TwoPhase) : IO Unit := do
  let exported := certifiedTwoPhaseEnergyFlowExport phase
  handle.putStr "{\"source_id\":"
  CW0.writeNat handle (twoPhaseId phase)
  handle.putStr ",\"target_id\":"
  CW0.writeNat handle (twoPhaseId phase.other)
  handle.putStr ",\"requested_energy\":"
  CW0.writeNat handle exported.requestedEnergy
  handle.putStr ",\"energy_inflow\":"
  CW0.writeNat handle exported.energyInflow
  handle.putStr ",\"energy_dissipated\":"
  CW0.writeNat handle exported.energyDissipated
  handle.putStr ",\"available_before\":"
  CW0.writeNat handle exported.availableBefore
  handle.putStr ",\"available_after\":"
  CW0.writeNat handle exported.availableAfter
  handle.putStr "}"

/-- Separate CW1 artifact; the historical CW0 export remains byte-stable. -/
def writeTwoPhaseEnergyKernel (path : System.FilePath) : IO Unit := do
  let handle <- IO.FS.Handle.mk path IO.FS.Mode.write
  handle.putStr
    "{\"schema_version\":\"cw1-energy-throughput-v1\",\"status\":\"formal_open_energy_flow_not_chemistry\",\"authority\":{\"lean_module\":\"Carbone.CW1.Lean.ActiveMaintenanceBoundary\",\"balance_theorem\":\"Meta.Carbone.CW1.twoPhase_step_energyBalance\",\"coupling_instance\":\"Meta.Carbone.CW1.twoPhaseEnergyThroughputMaintenance\"},\"scope\":{\"exported\":\"finite_phase_energy_throughput\",\"omitted\":[\"physical_energy_scale\",\"kinetics\",\"thermodynamics\",\"empirical_parameters\"]},\"environment\":"
  CW0.writeCarbonEnvironment handle twoPhaseEnvironment
  handle.putStr ",\"states\":["
  CW0.writeTwoPhaseState handle .chain
  handle.putStr ","
  CW0.writeTwoPhaseState handle .bridged
  handle.putStr "],\"transitions\":["
  writeTwoPhaseEnergyTransition handle .chain
  handle.putStr ","
  writeTwoPhaseEnergyTransition handle .bridged
  handle.putStr "]}\n"

end CW1
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CW1.CertifiedTwoPhaseEnergyFlowExport.fields_eq_lean
#print axioms Meta.Carbone.CW1.certifiedTwoPhaseEnergyFlowExport
#print axioms Meta.Carbone.CW1.writeTwoPhaseEnergyTransition
#print axioms Meta.Carbone.CW1.writeTwoPhaseEnergyKernel
/- AXIOM_AUDIT_END -/
