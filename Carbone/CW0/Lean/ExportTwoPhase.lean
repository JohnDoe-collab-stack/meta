import Carbone.CW0.Lean.FiniteKernel

/-!
# CW0: canonical JSON export of the finite two-phase kernel

The JSON state fields are serialized from phase-indexed certified payloads,
and transition targets are computed from `twoPhaseKernelStep`.  This module is
an exporter, not a second state or transition implementation.
-/

namespace Meta
namespace Carbone
namespace CW0

/-- Closed vocabulary used by the JSON encoder. -/
def elementJsonName : Element -> String
  | .carbon => "carbon"
  | .hydrogen => "hydrogen"
  | .nitrogen => "nitrogen"
  | .oxygen => "oxygen"
  | .phosphorus => "phosphorus"
  | .sulfur => "sulfur"

def bondOrderJsonName : BondOrder -> String
  | .single => "single"
  | .double => "double"
  | .triple => "triple"

def writeNat (handle : IO.FS.Handle) (value : Nat) : IO Unit :=
  handle.putStr (toString value)

def writeElement
    (handle : IO.FS.Handle)
    (element : Element) : IO Unit := do
  handle.putStr "\""
  handle.putStr (elementJsonName element)
  handle.putStr "\""

def writeElementTail
    (handle : IO.FS.Handle) : List Element -> IO Unit
  | [] => pure ()
  | element :: remaining => do
      handle.putStr ","
      writeElement handle element
      writeElementTail handle remaining

def writeElements
    (handle : IO.FS.Handle) : List Element -> IO Unit
  | [] => handle.putStr "[]"
  | first :: remaining => do
      handle.putStr "["
      writeElement handle first
      writeElementTail handle remaining
      handle.putStr "]"

def writeBond
    (handle : IO.FS.Handle)
    (bond : BondRecord) : IO Unit := do
  handle.putStr "{\"left\":"
  writeNat handle bond.left
  handle.putStr ",\"right\":"
  writeNat handle bond.right
  handle.putStr ",\"order\":\""
  handle.putStr (bondOrderJsonName bond.order)
  handle.putStr "\"}"

def writeBondTail
    (handle : IO.FS.Handle) : List BondRecord -> IO Unit
  | [] => pure ()
  | bond :: remaining => do
      handle.putStr ","
      writeBond handle bond
      writeBondTail handle remaining

def writeBonds
    (handle : IO.FS.Handle) : List BondRecord -> IO Unit
  | [] => handle.putStr "[]"
  | first :: remaining => do
      handle.putStr "["
      writeBond handle first
      writeBondTail handle remaining
      handle.putStr "]"

def writeAtomInventory
    (handle : IO.FS.Handle)
    (inventory : AtomInventory) : IO Unit := do
  handle.putStr "{\"carbon\":"
  writeNat handle inventory.carbon
  handle.putStr ",\"hydrogen\":"
  writeNat handle inventory.hydrogen
  handle.putStr ",\"nitrogen\":"
  writeNat handle inventory.nitrogen
  handle.putStr ",\"oxygen\":"
  writeNat handle inventory.oxygen
  handle.putStr ",\"phosphorus\":"
  writeNat handle inventory.phosphorus
  handle.putStr ",\"sulfur\":"
  writeNat handle inventory.sulfur
  handle.putStr "}"

/--
A state payload can only be built together with proofs that every exported
field is the corresponding field of its Lean phase organization.
-/
structure CertifiedTwoPhaseStateExport (phase : TwoPhase) where
  id : Nat
  name : String
  configuration : CarbonConfiguration
  visibleInventory : AtomInventory
  id_eq : id = twoPhaseId phase
  name_eq : name = twoPhaseName phase
  configuration_eq : configuration = phase.organization.configuration
  visibleInventory_eq : visibleInventory = project phase.organization

namespace CertifiedTwoPhaseStateExport

/-- Every state field admitted by a certified payload equals its Lean source. -/
theorem fields_eq_lean
    {phase : TwoPhase}
    (exported : CertifiedTwoPhaseStateExport phase) :
    exported.id = twoPhaseId phase ∧
      exported.name = twoPhaseName phase ∧
      exported.configuration.atoms =
          phase.organization.configuration.atoms ∧
        exported.configuration.bonds =
          phase.organization.configuration.bonds ∧
        exported.visibleInventory = project phase.organization := by
  exact
    ⟨ exported.id_eq
    , exported.name_eq
    , congrArg CarbonConfiguration.atoms exported.configuration_eq
    , congrArg CarbonConfiguration.bonds exported.configuration_eq
    , exported.visibleInventory_eq ⟩

end CertifiedTwoPhaseStateExport

def certifiedTwoPhaseStateExport
    (phase : TwoPhase) : CertifiedTwoPhaseStateExport phase where
  id := twoPhaseId phase
  name := twoPhaseName phase
  configuration := phase.organization.configuration
  visibleInventory := project phase.organization
  id_eq := rfl
  name_eq := rfl
  configuration_eq := rfl
  visibleInventory_eq := rfl

/-- The canonical payload contains exactly every exported state field in Lean. -/
theorem certifiedTwoPhaseStateExport_exact
    (phase : TwoPhase) :
    let exported := certifiedTwoPhaseStateExport phase
    exported.id = twoPhaseId phase ∧
      exported.name = twoPhaseName phase ∧
      exported.configuration.atoms =
          phase.organization.configuration.atoms ∧
        exported.configuration.bonds =
          phase.organization.configuration.bonds ∧
        exported.visibleInventory = project phase.organization := by
  exact (certifiedTwoPhaseStateExport phase).fields_eq_lean

/-- Serialize only fields carried by a phase-indexed certified payload. -/
def writeCertifiedTwoPhaseState
    (handle : IO.FS.Handle)
    {phase : TwoPhase}
    (exported : CertifiedTwoPhaseStateExport phase) : IO Unit := do
  handle.putStr "{\"id\":"
  writeNat handle exported.id
  handle.putStr ",\"name\":\""
  handle.putStr exported.name
  handle.putStr "\",\"atoms\":"
  writeElements handle exported.configuration.atoms
  handle.putStr ",\"bonds\":"
  writeBonds handle exported.configuration.bonds
  handle.putStr ",\"visible_inventory\":"
  writeAtomInventory handle exported.visibleInventory
  handle.putStr "}"

def writeTwoPhaseState
    (handle : IO.FS.Handle)
    (phase : TwoPhase) : IO Unit :=
  writeCertifiedTwoPhaseState handle (certifiedTwoPhaseStateExport phase)

/-- State writing is definitionally routed through the certified Lean payload. -/
theorem writeTwoPhaseState_eq_certifiedWriter
    (handle : IO.FS.Handle)
    (phase : TwoPhase) :
    writeTwoPhaseState handle phase =
      writeCertifiedTwoPhaseState
        handle
        (certifiedTwoPhaseStateExport phase) :=
  rfl

def writeCarbonEnvironment
    (handle : IO.FS.Handle)
    (environment : CarbonEnvironment) : IO Unit := do
  handle.putStr "{\"energy_tokens\":"
  writeNat handle environment.energyTokens
  handle.putStr ",\"compartment_capacity\":"
  writeNat handle environment.compartmentCapacity
  handle.putStr ",\"resources\":"
  writeAtomInventory handle environment.resources
  handle.putStr "}"

/-- Every transition field is computed from the typed finite-kernel transition. -/
def writeTwoPhaseTransition
    (handle : IO.FS.Handle)
    (transition : TwoPhaseKernelTransition) : IO Unit := do
  let source := transition.source
  let target := transition.target
  handle.putStr "{\"source_id\":"
  writeNat handle (twoPhaseId source)
  handle.putStr ",\"gap_id\":"
  writeNat handle (twoPhaseTag source)
  handle.putStr ",\"interaction_id\":"
  writeNat handle (twoPhaseTag source)
  handle.putStr ",\"response_id\":"
  writeNat handle (twoPhaseTag source)
  handle.putStr ",\"repair_id\":"
  writeNat handle (twoPhaseTag source)
  handle.putStr ",\"target_id\":"
  writeNat handle (twoPhaseId target)
  handle.putStr ",\"inventory_before\":"
  writeAtomInventory handle (project source.organization)
  handle.putStr ",\"inventory_after\":"
  writeAtomInventory handle (project target.organization)
  handle.putStr "}"

/-- Write the remaining computed transitions, each preceded by a comma. -/
def writeTwoPhaseTransitionTail
    (handle : IO.FS.Handle) :
    List TwoPhaseKernelTransition -> IO Unit
  | [] => pure ()
  | transition :: remaining => do
      handle.putStr ","
      writeTwoPhaseTransition handle transition
      writeTwoPhaseTransitionTail handle remaining

/-- Write the complete finite transition list computed by `FiniteKernel`. -/
def writeTwoPhaseTransitions
    (handle : IO.FS.Handle) :
    List TwoPhaseKernelTransition -> IO Unit
  | [] => pure ()
  | first :: remaining => do
      writeTwoPhaseTransition handle first
      writeTwoPhaseTransitionTail handle remaining

def writeTwoPhaseKernel (path : System.FilePath) : IO Unit := do
  let handle <- IO.FS.Handle.mk path IO.FS.Mode.write
  handle.putStr
    "{\"schema_version\":\"cw0-two-phase-v1\",\"status\":\"structural_witness_not_chemistry\",\"authority\":{\"lean_module\":\"Carbone.CW0.Lean.FiniteKernel\",\"commutation_theorem\":\"Meta.Carbone.CW0.twoPhaseKernel_commutes\"},\"scope\":{\"exported\":\"finite_phase_quotient\",\"omitted\":[\"unbounded_history\",\"physical_time\",\"kinetics\",\"empirical_parameters\"]},\"environment\":"
  writeCarbonEnvironment handle twoPhaseEnvironment
  handle.putStr ",\"states\":["
  writeTwoPhaseState handle .chain
  handle.putStr ","
  writeTwoPhaseState handle .bridged
  handle.putStr "],\"transitions\":["
  writeTwoPhaseTransitions handle twoPhaseKernelTransitions
  handle.putStr "]}\n"

end CW0
end Carbone
end Meta

def main (arguments : List String) : IO UInt32 := do
  match arguments with
  | path :: _remaining =>
      Meta.Carbone.CW0.writeTwoPhaseKernel path
      pure 0
  | [] => pure 2

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CW0.elementJsonName
#print axioms Meta.Carbone.CW0.writeNat
#print axioms Meta.Carbone.CW0.writeAtomInventory
#print axioms Meta.Carbone.CW0.CertifiedTwoPhaseStateExport.fields_eq_lean
#print axioms Meta.Carbone.CW0.certifiedTwoPhaseStateExport_exact
#print axioms Meta.Carbone.CW0.writeTwoPhaseState_eq_certifiedWriter
#print axioms Meta.Carbone.CW0.writeTwoPhaseTransition
#print axioms Meta.Carbone.CW0.writeTwoPhaseTransitionTail
#print axioms Meta.Carbone.CW0.writeTwoPhaseTransitions
#print axioms Meta.Carbone.CW0.writeTwoPhaseKernel
#print axioms main
/- AXIOM_AUDIT_END -/
