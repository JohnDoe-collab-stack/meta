import Meta.Core.TwoPole
import Meta.Arithmetic.GapContraction

/-!
# Arithmetic two-pole reading

This file exposes arithmetic gap rows in the positive two-pole vocabulary.  It
is a view over the existing arithmetic structural and operational gaps.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Arithmetic dynamic rows as two-poles -/

/-- The structural two-pole interface carried by an arithmetic dynamic row. -/
def arithmeticDynamicRowStructuralTwoPole
    (row : ArithmeticDynamicGapRow) :
    StructuralTwoPole
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection :=
  arithmeticDynamicRowStructuralGap row

/-- The operational two-pole interface carried by an arithmetic dynamic row. -/
def arithmeticDynamicRowOperationalTwoPole
    (row : ArithmeticDynamicGapRow) :
    OperationalTwoPole
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  arithmeticDynamicRowOperationalGap row

/-- An arithmetic dynamic row refutes the short payload presentation in two-pole vocabulary. -/
theorem arithmeticDynamicRowTwoPole_refutes_shortPresentation
    (row : ArithmeticDynamicGapRow)
    (short : ArithmeticShortPayloadPresentation) :
    False :=
  operationalTwoPole_refutes_shortPresentation
    (arithmeticDynamicRowOperationalTwoPole row)
    short

/-! ## Repeated-index and trajectory two-poles -/

/-- A repeated-index collision carries an arithmetic operational two-pole interface. -/
def repeatedIndexArithmeticOperationalTwoPole
    (collision : RepeatedIndexCollision) :
    OperationalTwoPole
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  arithmeticDynamicRowOperationalTwoPole
    (repeatedIndexDynamicGapRow collision)

/-- A trajectory collision carries an arithmetic operational two-pole interface. -/
def trajectoryArithmeticOperationalTwoPole
    {step : Nat -> Nat}
    {start : Nat}
    (collision : NatTrajectoryRepeatedIndexCollision step start) :
    OperationalTwoPole
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  arithmeticDynamicRowOperationalTwoPole
    (trajectoryDynamicGapRow collision)

/-- A bounded trajectory window carries an arithmetic operational two-pole interface. -/
def boundedWindowArithmeticOperationalTwoPole
    {step : Nat -> Nat}
    {start windowStart B : Nat}
    (window : NatTrajectoryBoundedWindow step start windowStart B) :
    OperationalTwoPole
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  arithmeticDynamicRowOperationalTwoPole
    (boundedWindowDynamicGapRow window)

/-- A post-peak window carries an arithmetic operational two-pole interface. -/
def postPeakWindowArithmeticOperationalTwoPole
    {step : Nat -> Nat}
    {start : Nat}
    {cert : NatTrajectoryFinitePrefixHeightCertificate step start}
    (window : NatTrajectoryPostPeakWindow cert) :
    OperationalTwoPole
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  arithmeticDynamicRowOperationalTwoPole
    (postPeakWindowDynamicGapRow window)

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRowStructuralTwoPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRowOperationalTwoPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRowTwoPole_refutes_shortPresentation
#print axioms Meta.EnrichedNatClosedStabilityInstance.repeatedIndexArithmeticOperationalTwoPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.trajectoryArithmeticOperationalTwoPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.boundedWindowArithmeticOperationalTwoPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.postPeakWindowArithmeticOperationalTwoPole
/- AXIOM_AUDIT_END -/
