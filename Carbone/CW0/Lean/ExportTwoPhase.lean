import Carbone.CW0.Lean.FiniteKernel

/-!
# CW0: canonical JSON export of the finite two-phase kernel

The JSON transition targets are computed from `twoPhaseKernelStep`.  This
module is an exporter, not a second transition implementation.
-/

namespace Meta
namespace Carbone
namespace CW0

def writeTwoPhaseState
    (handle : IO.FS.Handle) : TwoPhase -> IO Unit
  | .chain =>
      handle.putStr
        "{\"id\":0,\"name\":\"chain\",\"atoms\":[\"carbon\",\"carbon\",\"oxygen\"],\"bonds\":[{\"left\":0,\"right\":1,\"order\":\"single\"},{\"left\":1,\"right\":2,\"order\":\"single\"}],\"visible_inventory\":{\"carbon\":2,\"hydrogen\":0,\"nitrogen\":0,\"oxygen\":1,\"phosphorus\":0,\"sulfur\":0}}"
  | .bridged =>
      handle.putStr
        "{\"id\":1,\"name\":\"bridged\",\"atoms\":[\"carbon\",\"carbon\",\"oxygen\"],\"bonds\":[{\"left\":0,\"right\":2,\"order\":\"single\"},{\"left\":1,\"right\":2,\"order\":\"single\"}],\"visible_inventory\":{\"carbon\":2,\"hydrogen\":0,\"nitrogen\":0,\"oxygen\":1,\"phosphorus\":0,\"sulfur\":0}}"

/-- Serialize a transition only after inspecting the transition computed in Lean. -/
def writeTwoPhaseTransition
    (handle : IO.FS.Handle)
    (transition : TwoPhaseKernelTransition) : IO Unit :=
  match transition.source with
  | .chain =>
      match transition.target with
      | .bridged =>
          handle.putStr
            "{\"source_id\":0,\"gap_id\":0,\"interaction_id\":0,\"response_id\":0,\"repair_id\":0,\"target_id\":1,\"inventory_before\":{\"carbon\":2,\"hydrogen\":0,\"nitrogen\":0,\"oxygen\":1,\"phosphorus\":0,\"sulfur\":0},\"inventory_after\":{\"carbon\":2,\"hydrogen\":0,\"nitrogen\":0,\"oxygen\":1,\"phosphorus\":0,\"sulfur\":0}}"
      | .chain =>
          throw (IO.userError "finite kernel contains a noncanonical transition")
  | .bridged =>
      match transition.target with
      | .chain =>
          handle.putStr
            "{\"source_id\":1,\"gap_id\":1,\"interaction_id\":1,\"response_id\":1,\"repair_id\":1,\"target_id\":0,\"inventory_before\":{\"carbon\":2,\"hydrogen\":0,\"nitrogen\":0,\"oxygen\":1,\"phosphorus\":0,\"sulfur\":0},\"inventory_after\":{\"carbon\":2,\"hydrogen\":0,\"nitrogen\":0,\"oxygen\":1,\"phosphorus\":0,\"sulfur\":0}}"
      | .bridged =>
          throw (IO.userError "finite kernel contains a noncanonical transition")

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
    "{\"schema_version\":\"cw0-two-phase-v1\",\"status\":\"structural_witness_not_chemistry\",\"authority\":{\"lean_module\":\"Carbone.CW0.Lean.FiniteKernel\",\"commutation_theorem\":\"Meta.Carbone.CW0.twoPhaseKernel_commutes\"},\"scope\":{\"exported\":\"finite_phase_quotient\",\"omitted\":[\"unbounded_history\",\"physical_time\",\"kinetics\",\"empirical_parameters\"]},\"environment\":{\"energy_tokens\":1,\"compartment_capacity\":1,\"resources\":{\"carbon\":0,\"hydrogen\":0,\"nitrogen\":0,\"oxygen\":0,\"phosphorus\":0,\"sulfur\":0}},\"states\":["
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
#print axioms Meta.Carbone.CW0.writeTwoPhaseTransition
#print axioms Meta.Carbone.CW0.writeTwoPhaseTransitionTail
#print axioms Meta.Carbone.CW0.writeTwoPhaseTransitions
#print axioms Meta.Carbone.CW0.writeTwoPhaseKernel
#print axioms main
/- AXIOM_AUDIT_END -/
