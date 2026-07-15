import Meta.Core.ProjectiveCore
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

/-! ## Public projections of the arithmetic two-pole -/

/-- The formed pole of an arithmetic dynamic row. -/
def arithmeticDynamicRow_leftPole
    (row : ArithmeticDynamicGapRow) :
    ArithmeticEnrichedInterface :=
  operationalTwoPole_leftPole
    (arithmeticDynamicRowOperationalTwoPole row)

/-- The shadow pole of an arithmetic dynamic row. -/
def arithmeticDynamicRow_rightPole
    (row : ArithmeticDynamicGapRow) :
    ArithmeticEnrichedInterface :=
  operationalTwoPole_rightPole
    (arithmeticDynamicRowOperationalTwoPole row)

/-- The public formed pole is the row's formed trace. -/
theorem arithmeticDynamicRow_leftPole_eq_formed
    (row : ArithmeticDynamicGapRow) :
    arithmeticDynamicRow_leftPole row = row.formed :=
  row.recovery_formed

/-- The public shadow pole is the row's payload-only shadow. -/
theorem arithmeticDynamicRow_rightPole_eq_shadow
    (row : ArithmeticDynamicGapRow) :
    arithmeticDynamicRow_rightPole row = row.shadow :=
  row.recovery_shadow

/-- The arithmetic two-pole has the same visible payload on both poles. -/
theorem arithmeticDynamicRow_sameVisible
    (row : ArithmeticDynamicGapRow) :
    arithmeticPayloadProjection (arithmeticDynamicRow_leftPole row) =
      arithmeticPayloadProjection (arithmeticDynamicRow_rightPole row) :=
  operationalTwoPole_sameVisible
    (arithmeticDynamicRowOperationalTwoPole row)

/-- The arithmetic two-pole keeps the formed trace separated from the shadow. -/
theorem arithmeticDynamicRow_separatedPoles
    (row : ArithmeticDynamicGapRow) :
    arithmeticDynamicRow_leftPole row =
      arithmeticDynamicRow_rightPole row -> False :=
  operationalTwoPole_separatedPoles
    (arithmeticDynamicRowOperationalTwoPole row)

/-- The arithmetic two-pole carries the local repair on its formed pole. -/
def arithmeticDynamicRow_repair
    (row : ArithmeticDynamicGapRow) :
    NatInterfaceRepair (arithmeticDynamicRow_leftPole row) :=
  operationalTwoPole_repair
    (arithmeticDynamicRowOperationalTwoPole row)

/-- The arithmetic two-pole recovers the formed pole. -/
def arithmeticDynamicRow_recovered
    (row : ArithmeticDynamicGapRow) :
    ArithmeticEnrichedInterface :=
  operationalTwoPole_recovered
    (arithmeticDynamicRowOperationalTwoPole row)

/-- The arithmetic recovered pole is the formed pole. -/
theorem arithmeticDynamicRow_recovered_eq_leftPole
    (row : ArithmeticDynamicGapRow) :
    arithmeticDynamicRow_recovered row =
      arithmeticDynamicRow_leftPole row :=
  operationalTwoPole_recovered_eq_leftPole
    (arithmeticDynamicRowOperationalTwoPole row)

/-- The arithmetic structural two-pole refutes a short payload presentation. -/
theorem arithmeticDynamicRowStructuralTwoPole_refutes_shortPresentation
    (row : ArithmeticDynamicGapRow)
    (short : ArithmeticShortPayloadPresentation) :
    False :=
  structuralTwoPole_refutes_shortPresentation
    (arithmeticDynamicRowStructuralTwoPole row)
    short

/-- The arithmetic operational two-pole refutes contractibility. -/
theorem arithmeticDynamicRowTwoPole_not_contractible
    (row : ArithmeticDynamicGapRow)
    (contractible :
      ContractibleReferentialGap
        ArithmeticEnrichedInterface
        ArithmeticVisiblePayload
        arithmeticPayloadProjection) :
    False :=
  operationalTwoPole_not_contractible
    (arithmeticDynamicRowOperationalTwoPole row)
    contractible

/-- No global payload reconstruction can recover both arithmetic poles. -/
def arithmeticDynamicRow_noProjectiveReconstruction
    (row : ArithmeticDynamicGapRow) :
    ((recover : ArithmeticVisiblePayload -> ArithmeticEnrichedInterface) ->
      ((interface : ArithmeticEnrichedInterface) ->
        recover (arithmeticPayloadProjection interface) = interface) ->
      False) :=
  operationalTwoPole_noProjectiveReconstruction
    (arithmeticDynamicRowOperationalTwoPole row)

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
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_leftPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_rightPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_leftPole_eq_formed
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_rightPole_eq_shadow
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_sameVisible
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_separatedPoles
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_repair
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_recovered
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_recovered_eq_leftPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRowStructuralTwoPole_refutes_shortPresentation
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRowTwoPole_not_contractible
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_noProjectiveReconstruction
#print axioms Meta.EnrichedNatClosedStabilityInstance.repeatedIndexArithmeticOperationalTwoPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.trajectoryArithmeticOperationalTwoPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.boundedWindowArithmeticOperationalTwoPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.postPeakWindowArithmeticOperationalTwoPole
/- AXIOM_AUDIT_END -/
