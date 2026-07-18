import Carbone.CW1.Lean.ExportEnergyThroughput

def main (arguments : List String) : IO UInt32 := do
  match arguments with
  | path :: _remaining =>
      Meta.Carbone.CW1.writeTwoPhaseEnergyKernel path
      pure 0
  | [] => pure 2

/- AXIOM_AUDIT_BEGIN -/
#print axioms main
/- AXIOM_AUDIT_END -/
