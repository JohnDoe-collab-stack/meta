import Meta.Arithmetic.GapContraction
import Meta.Arithmetic.CountdownDynamicGap
import Meta.Arithmetic.TwoPole

/-!
# Countdown arithmetic gap contraction

This file contains the countdown-specific arithmetic contraction row.  The
generic arithmetic contraction layer remains independent of the countdown
instance.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-- The intrinsic countdown dynamic arithmetic gap has terminal excess `n + 2`. -/
theorem countdownArithmeticGapTerminalExcess_eq_n_plus_two
    (n : Nat) :
    formedPositiveExcessOfIntersection
      (repeatedIndexIntersection
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision n)))) =
        n + 2 :=
  countdownTerminalExcess_eq_n_plus_two n

/-! ## Countdown two-pole realization -/

/-- The countdown terminal collision realizes an arithmetic operational two-pole interface. -/
def countdownTerminalOperationalTwoPole
    (n : Nat) :
    OperationalTwoPole
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  arithmeticDynamicRowOperationalTwoPole
    (countdownTerminalDynamicGapRow n)

/-- The countdown terminal collision realizes an arithmetic structural two-pole interface. -/
def countdownTerminalStructuralTwoPole
    (n : Nat) :
    StructuralTwoPole
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection :=
  operationalTwoPole_structural
    (countdownTerminalOperationalTwoPole n)

/-- The fully constructed countdown row realizes the same operational two-pole interface. -/
def fullyConstructedCountdownOperationalTwoPole
    (n : Nat) :
    OperationalTwoPole
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  arithmeticDynamicRowOperationalTwoPole
    (fullyConstructedCountdownDynamicGapRow n)

/-- The fully constructed countdown row realizes a structural two-pole interface. -/
def fullyConstructedCountdownStructuralTwoPole
    (n : Nat) :
    StructuralTwoPole
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection :=
  operationalTwoPole_structural
    (fullyConstructedCountdownOperationalTwoPole n)

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownArithmeticGapTerminalExcess_eq_n_plus_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownTerminalOperationalTwoPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownTerminalStructuralTwoPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.fullyConstructedCountdownOperationalTwoPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.fullyConstructedCountdownStructuralTwoPole
/- AXIOM_AUDIT_END -/
