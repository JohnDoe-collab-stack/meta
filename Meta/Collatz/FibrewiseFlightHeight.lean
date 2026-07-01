import Meta.Arithmetic.CountdownRelaxedParity

/-!
# Collatz fibrewise flight height

This file exposes the Collatz-facing entry point from an initial index `n` to
the fibrewise height already carried by enriched Nat.

The index `n` is not a time. It names the fibre opened by the initial Collatz
value. The height exposed here is the enriched-Nat fibrewise structural peak at
that index.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Initial-index fibre height -/

/--
The fibrewise flight height attached to the Collatz fibre named by its initial
index `n`.

This is not reconstructed from a classical trajectory. It is the enriched-Nat
fibrewise structural peak already carried by the initial index.
-/
def collatzInitialIndexFibreHeight
    (n : Nat) :
    Nat :=
  natEnrichedParityFibrewiseStructuralPeak n

/-- The initial-index height is the maximal relaxed divergence at that index. -/
theorem collatzInitialIndexFibreHeight_eq_maximalRelaxedDivergence
    (n : Nat) :
    collatzInitialIndexFibreHeight n =
      natEnrichedParityMaximalRelaxedDivergence n :=
  natEnrichedParityFibrewiseStructuralPeak_eq_maximalDivergence n

/-- The initial-index height has the internal countdown-consumable shape. -/
theorem collatzInitialIndexFibreHeight_eq_double_add_two
    (n : Nat) :
    collatzInitialIndexFibreHeight n = (n + n) + 2 :=
  natEnrichedParityFibrewiseStructuralPeak_eq_double_add_two n

/-- The initial-index height is strictly positive. -/
theorem collatzInitialIndexFibreHeight_pos
    (n : Nat) :
    0 < collatzInitialIndexFibreHeight n :=
  natEnrichedParityFibrewiseStructuralPeak_pos n

/--
The initial-index height carries the positive internal diagonal witness already
provided by enriched Nat.
-/
def collatzInitialIndexFibreHeightWitness
    (n : Nat) :
    NatEnrichedParityPositiveInternalDiagonalWitness n :=
  natEnrichedParityFibrewiseStructuralPeakWitness n

/-- The witness value of the initial-index height is that same height. -/
theorem collatzInitialIndexFibreHeightWitness_witness_eq_height
    (n : Nat) :
    (collatzInitialIndexFibreHeightWitness n).witness =
      collatzInitialIndexFibreHeight n :=
  natEnrichedParityFibrewiseStructuralPeakWitness_witness_eq_peak n

/-- The witness carried by the initial-index height is strictly positive. -/
theorem collatzInitialIndexFibreHeightWitness_witness_pos
    (n : Nat) :
    0 < (collatzInitialIndexFibreHeightWitness n).witness :=
  natEnrichedParityFibrewiseStructuralPeakWitness_witness_pos n

/--
The initial-index height is consumed as terminal excess by the canonical
countdown consumer at the doubled initial index.
-/
theorem collatzInitialIndexFibreHeight_eq_countdownTerminalExcess
    (n : Nat) :
    collatzInitialIndexFibreHeight n =
      formedPositiveExcessOfIntersection
        (countdownTerminalIntersection (n + n)) :=
  natEnrichedParityFibrewiseStructuralPeak_eq_countdownTerminalExcess n

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexFibreHeight
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexFibreHeight_eq_maximalRelaxedDivergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexFibreHeight_eq_double_add_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexFibreHeight_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexFibreHeightWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexFibreHeightWitness_witness_eq_height
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexFibreHeightWitness_witness_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexFibreHeight_eq_countdownTerminalExcess
/- AXIOM_AUDIT_END -/
