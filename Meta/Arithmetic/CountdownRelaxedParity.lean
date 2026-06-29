import Meta.Arithmetic.CountdownGapContraction

/-!
# Countdown relaxed parity

This file exposes the relaxed enriched-Nat parity diagonal carried by the
terminal countdown intersection.

The import of `CountdownGapContraction` is used only for the enriched terminal
facts: terminal intersection, terminal excess, and terminal roles.  This file
does not use the non-relaxed arithmetic parity code.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Relaxed diagonal at the countdown terminal index -/

/--
The terminal countdown intersection instantiates the positive internal
diagonal witness already carried by the maximally relaxed enriched-Nat parity
gap.
-/
def countdownRelaxedPositiveInternalDiagonalWitness
    (n : Nat) :
    NatEnrichedParityPositiveInternalDiagonalWitness
      (formedPositiveExcessOfIntersection
        (countdownTerminalIntersection n)) :=
  natEnrichedParityPositiveInternalDiagonalWitnessOfMaximallyRelaxedGap
    (formedPositiveExcessOfIntersection
      (countdownTerminalIntersection n))

/-- The relaxed parity gap carried by the terminal countdown intersection. -/
def countdownRelaxedGap
    (n : Nat) :
    NatEnrichedParityRelaxedBilateralGap
      (formedPositiveExcessOfIntersection
        (countdownTerminalIntersection n)) :=
  (countdownRelaxedPositiveInternalDiagonalWitness n).relaxedGap

/-- The core diagonal certificate carried by the relaxed countdown gap. -/
def countdownRelaxedDiagonalCertificate
    (n : Nat) :
    DiagonalCertificate
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload :=
  (countdownRelaxedPositiveInternalDiagonalWitness n).diagonalCertificate

/-- The projection obstruction carried by the relaxed countdown diagonal. -/
def countdownRelaxedProjectionObstruction
    (n : Nat) :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload :=
  (countdownRelaxedPositiveInternalDiagonalWitness n).projectionObstruction

/-- The positive diagonal value carried by the relaxed countdown diagonal. -/
def countdownRelaxedPositiveDiagonalValue
    (n : Nat) :
    Nat :=
  (countdownRelaxedPositiveInternalDiagonalWitness n).witness

/-- The relaxed countdown diagonal value is strictly positive. -/
theorem countdownRelaxedPositiveDiagonalValue_pos
    (n : Nat) :
    0 < countdownRelaxedPositiveDiagonalValue n :=
  (countdownRelaxedPositiveInternalDiagonalWitness n).witness_pos

/--
The relaxed countdown diagonal value is the maximal relaxed divergence at the
terminal countdown index.
-/
theorem countdownRelaxedPositiveDiagonalValue_eq_maximalDivergence
    (n : Nat) :
    countdownRelaxedPositiveDiagonalValue n =
      natEnrichedParityMaximalRelaxedDivergence
        (formedPositiveExcessOfIntersection
          (countdownTerminalIntersection n)) :=
  (countdownRelaxedPositiveInternalDiagonalWitness n).witness_eq_maximal

/-- The same maximal relaxed divergence, expressed at the public index `n + 2`. -/
theorem countdownRelaxedPositiveDiagonalValue_eq_maximalDivergence_n_plus_two
    (n : Nat) :
    countdownRelaxedPositiveDiagonalValue n =
      natEnrichedParityMaximalRelaxedDivergence (n + 2) := by
  rw [countdownRelaxedPositiveDiagonalValue_eq_maximalDivergence]
  rw [countdownArithmeticGapTerminalExcess_eq_n_plus_two]

/-! ## Raccord with terminal countdown roles -/

/-- The left side of the relaxed countdown diagonal is the terminal closing role. -/
theorem countdownRelaxedDiagonalCertificate_left_eq_closingRole
    (n : Nat) :
    (countdownRelaxedDiagonalCertificate n).left =
      arithmeticClosingRoleOfIntersection
        (countdownTerminalIntersection n) := by
  rw [arithmeticClosingRoleOfIntersection_eq]
  rfl

/-- The right side of the relaxed countdown diagonal is the terminal mediating role. -/
theorem countdownRelaxedDiagonalCertificate_right_eq_mediatingRole
    (n : Nat) :
    (countdownRelaxedDiagonalCertificate n).right =
      arithmeticMediatingRoleOfIntersection
        (countdownTerminalIntersection n) := by
  rw [arithmeticMediatingRoleOfIntersection_eq]
  rfl

/-- The left side of the relaxed countdown diagonal is indexed by `n + 2`. -/
theorem countdownRelaxedDiagonalCertificate_left_eq_closing_n_plus_two
    (n : Nat) :
    (countdownRelaxedDiagonalCertificate n).left =
      NatEnrichedParityRole.closingExcess (n + 2) := by
  rw [countdownRelaxedDiagonalCertificate_left_eq_closingRole]
  rw [countdownTerminalClosingRole_eq_n_plus_two]

/-- The right side of the relaxed countdown diagonal is indexed by `n + 2`. -/
theorem countdownRelaxedDiagonalCertificate_right_eq_mediating_n_plus_two
    (n : Nat) :
    (countdownRelaxedDiagonalCertificate n).right =
      NatEnrichedParityRole.mediatingValue (n + 2) := by
  rw [countdownRelaxedDiagonalCertificate_right_eq_mediatingRole]
  rw [countdownTerminalMediatingRole_eq_n_plus_two]

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedPositiveInternalDiagonalWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedDiagonalCertificate
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedProjectionObstruction
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedPositiveDiagonalValue
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedPositiveDiagonalValue_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedPositiveDiagonalValue_eq_maximalDivergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedPositiveDiagonalValue_eq_maximalDivergence_n_plus_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedDiagonalCertificate_left_eq_closingRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedDiagonalCertificate_right_eq_mediatingRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedDiagonalCertificate_left_eq_closing_n_plus_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownRelaxedDiagonalCertificate_right_eq_mediating_n_plus_two
/- AXIOM_AUDIT_END -/
