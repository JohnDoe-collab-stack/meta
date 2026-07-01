import Meta.Collatz.FibrewiseFlightHeight

/-!
# Collatz initial indexed fibre

This file packages the fibrewise height already exposed by the initial Collatz
index.  It does not introduce a temporal trajectory.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Initial indexed fibre package -/

/--
The fibre opened by the initial index `n`, together with its fibrewise height,
positive internal diagonal witness, and canonical countdown consumer.
-/
structure CollatzInitialIndexedFibreHeightPackage
    (n : Nat) where
  index : Nat
  index_eq_initial : index = n
  height : Nat
  height_eq :
    height = collatzInitialIndexFibreHeight index
  height_eq_double_add_two :
    height = (index + index) + 2
  witness :
    NatEnrichedParityPositiveInternalDiagonalWitness index
  witness_value_eq_height :
    witness.witness = height
  consumed_as_countdown_terminal_excess :
    height =
      formedPositiveExcessOfIntersection
        (countdownTerminalIntersection (index + index))

/-- Canonical package for the fibre opened by `n`. -/
def collatzInitialIndexedFibreHeightPackage
    (n : Nat) :
    CollatzInitialIndexedFibreHeightPackage n where
  index := n
  index_eq_initial := rfl
  height := collatzInitialIndexFibreHeight n
  height_eq := rfl
  height_eq_double_add_two :=
    collatzInitialIndexFibreHeight_eq_double_add_two n
  witness := collatzInitialIndexFibreHeightWitness n
  witness_value_eq_height :=
    collatzInitialIndexFibreHeightWitness_witness_eq_height n
  consumed_as_countdown_terminal_excess :=
    collatzInitialIndexFibreHeight_eq_countdownTerminalExcess n

/-! ## Public readings -/

/-- The packaged height is the initial-index fibre height. -/
theorem collatzInitialIndexedFibre_height_eq
    (n : Nat) :
    (collatzInitialIndexedFibreHeightPackage n).height =
      collatzInitialIndexFibreHeight n :=
  rfl

/-- The packaged height has the fibrewise structural peak shape. -/
theorem collatzInitialIndexedFibre_height_eq_double_add_two
    (n : Nat) :
    (collatzInitialIndexedFibreHeightPackage n).height =
      (n + n) + 2 :=
  collatzInitialIndexFibreHeight_eq_double_add_two n

/-- The packaged witness has the packaged height as value. -/
theorem collatzInitialIndexedFibre_witness_value_eq_height
    (n : Nat) :
    (collatzInitialIndexedFibreHeightPackage n).witness.witness =
      (collatzInitialIndexedFibreHeightPackage n).height :=
  collatzInitialIndexFibreHeightWitness_witness_eq_height n

/-- The packaged height is consumed by the canonical countdown at the doubled index. -/
theorem collatzInitialIndexedFibre_consumed_as_countdown_terminal_excess
    (n : Nat) :
    (collatzInitialIndexedFibreHeightPackage n).height =
      formedPositiveExcessOfIntersection
        (countdownTerminalIntersection (n + n)) :=
  collatzInitialIndexFibreHeight_eq_countdownTerminalExcess n

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzInitialIndexedFibreHeightPackage
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexedFibreHeightPackage
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexedFibre_height_eq_double_add_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexedFibre_consumed_as_countdown_terminal_excess
/- AXIOM_AUDIT_END -/
