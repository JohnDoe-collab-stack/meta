import Meta.Collatz.OperationalParity
import Meta.Arithmetic.CountdownGapContraction

/-!
# Countdown impact of Collatz operational parity

This file specializes the Collatz operational parity layer to the countdown
terminal intersection.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Countdown regime specialization -/

/-- The countdown closing regime is the formed dynamic regime. -/
theorem collatzCountdownClosingRegime_eq_formedRegime
    (n : Nat) :
    operationalParityRoles_closingRegime
        (arithmeticOperationalParityRolesOfIntersection
          (countdownTerminalIntersection n)) =
      dynamicParitySeparation_formedRegime
        (arithmeticDynamicParitySeparationOfIntersection
          (countdownTerminalIntersection n)) :=
  collatzClosingRegime_eq_formedRegime
    (countdownTerminalIntersection n)

/-- The countdown mediating regime is the shadow dynamic regime. -/
theorem collatzCountdownMediatingRegime_eq_shadowRegime
    (n : Nat) :
    operationalParityRoles_mediatingRegime
        (arithmeticOperationalParityRolesOfIntersection
          (countdownTerminalIntersection n)) =
      dynamicParitySeparation_shadowRegime
        (arithmeticDynamicParitySeparationOfIntersection
          (countdownTerminalIntersection n)) :=
  collatzMediatingRegime_eq_shadowRegime
    (countdownTerminalIntersection n)

/-- The countdown Collatz parity regimes keep the contracted parity projection. -/
theorem collatzCountdown_sameProjection
    (n : Nat) :
    parityProjection
        (operationalParityRoles_closingRegime
          (arithmeticOperationalParityRolesOfIntersection
            (countdownTerminalIntersection n))) =
      parityProjection
        (operationalParityRoles_mediatingRegime
          (arithmeticOperationalParityRolesOfIntersection
            (countdownTerminalIntersection n))) :=
  collatzOperationalParity_sameProjection
    (countdownTerminalIntersection n)

/-- The countdown Collatz parity regimes remain separated. -/
theorem collatzCountdown_separated
    (n : Nat) :
    operationalParityRoles_closingRegime
        (arithmeticOperationalParityRolesOfIntersection
          (countdownTerminalIntersection n)) =
      operationalParityRoles_mediatingRegime
        (arithmeticOperationalParityRolesOfIntersection
          (countdownTerminalIntersection n)) ->
        False :=
  collatzOperationalParity_separated
    (countdownTerminalIntersection n)

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzCountdownClosingRegime_eq_formedRegime
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzCountdownMediatingRegime_eq_shadowRegime
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzCountdown_sameProjection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzCountdown_separated
/- AXIOM_AUDIT_END -/
