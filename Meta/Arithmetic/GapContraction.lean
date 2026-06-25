import Meta.Arithmetic.DynamicGap
import Meta.Core.ReferentialLength

/-!
# Arithmetic gap contraction

This file is the arithmetic analogue of the Tarski and Bell gap layers.

It does not introduce a new arithmetic principle.  It names the already proved
enriched-Nat mechanism in the transverse vocabulary:

* a short arithmetic presentation would make the payload projection faithful;
* an arithmetic structural gap is the formed trace and its payload-only shadow
  over the same visible payload;
* an arithmetic operational gap is the same obstruction together with the
  local repair attached to the formed trace;
* the dynamic arithmetic rows are the same gap transported through repeated
  indices, trajectory collisions, bounded windows, post-peak windows, and the
  countdown instance.

The arithmetic gap is therefore the role distinction hidden by the visible
payload projection:

```text
excess k and value k have the same payload k,
but they are separated enriched interfaces.
```
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Arithmetic payload projection -/

/-- The enriched arithmetic interface is a trace of typed Nat atoms. -/
abbrev ArithmeticEnrichedInterface : Type :=
  List NatTraceAtom

/-- The visible arithmetic payload forgets the enriched Nat role. -/
abbrev ArithmeticVisiblePayload : Type :=
  List Nat

/-- The arithmetic visible projection is the payload projection. -/
abbrev arithmeticPayloadProjection :
    ArithmeticEnrichedInterface -> ArithmeticVisiblePayload :=
  tracePayloads

/--
The short arithmetic presentation: visible payload determines the enriched
trace role.
-/
abbrev ArithmeticShortPayloadPresentation : Prop :=
  ShortReferentialPresentation
    ArithmeticEnrichedInterface
    ArithmeticVisiblePayload
    arithmeticPayloadProjection

/-! ## Static arithmetic gap over one intersection -/

/--
The positive terminal excess carried by a primitive arithmetic intersection.
-/
def arithmeticGapTerminalExcessOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Nat :=
  formedPositiveExcessOfIntersection intersection

/-- The arithmetic terminal excess of an intersection is positive. -/
theorem arithmeticGapTerminalExcess_pos
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    0 < arithmeticGapTerminalExcessOfIntersection intersection :=
  formedPositiveExcessOfIntersection_pos intersection

/-- The formed side of an arithmetic gap. -/
def arithmeticGapFormedTrace
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ArithmeticEnrichedInterface :=
  formedTraceOfIntersection intersection

/-- The payload-only shadow side of an arithmetic gap. -/
def arithmeticGapPayloadShadow
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ArithmeticEnrichedInterface :=
  payloadOnlyTraceOfIntersection intersection

/-- The formed trace and its payload-only shadow share the visible payload. -/
theorem arithmeticGap_sameVisible
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticPayloadProjection (arithmeticGapFormedTrace intersection) =
      arithmeticPayloadProjection (arithmeticGapPayloadShadow intersection) :=
  formedTraceOfIntersection_same_payloadOnlyPayload intersection

/-- The formed trace is separated from its payload-only shadow. -/
theorem arithmeticGap_separated
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticGapFormedTrace intersection =
      arithmeticGapPayloadShadow intersection ->
        False :=
  formedTraceOfIntersection_ne_payloadOnlyTrace intersection

/--
The structural arithmetic gap of an intersection: one visible payload covers
two separated enriched traces.
-/
def arithmeticStructuralGapOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    EnrichedStructuralReferentialLength
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection :=
  payloadProjectionObstructionOfIntersection intersection

/--
The operational arithmetic gap of an intersection: the structural gap together
with the local repair attached to the formed trace.
-/
def arithmeticOperationalGapOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    EnrichedOperationalReferentialLength
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  localProjectiveRecoveryOfIntersection intersection

/-- The operational arithmetic gap exposes the structural arithmetic gap. -/
def arithmeticStructuralGapOfOperationalIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    EnrichedStructuralReferentialLength
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection :=
  structuralLengthOfOperationalLength
    (arithmeticOperationalGapOfIntersection intersection)

/-- A static arithmetic structural gap refutes the short payload presentation. -/
theorem arithmeticStructuralGap_refutes_shortPresentation
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (short : ArithmeticShortPayloadPresentation) :
    False :=
  structuralLength_refutes_shortPresentation
    (arithmeticStructuralGapOfIntersection intersection)
    short

/-- A static arithmetic operational gap refutes the short payload presentation. -/
theorem arithmeticOperationalGap_refutes_shortPresentation
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (short : ArithmeticShortPayloadPresentation) :
    False :=
  operationalLength_refutes_shortPresentation
    (arithmeticOperationalGapOfIntersection intersection)
    short

/-- The truth-gap recovery carried by the arithmetic referential gap. -/
def arithmeticTruthGapRecoveryOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    LocalTruthGapRecovery
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair
      (NatEnrichedReferentialTruth intersection) :=
  (natEnrichedReferentialGapOfIntersection intersection).truthGapRecovery

/-! ## Dynamic arithmetic gap rows -/

/--
The structural gap carried by an arithmetic dynamic row.
-/
def arithmeticDynamicRowStructuralGap
    (row : ArithmeticDynamicGapRow) :
    EnrichedStructuralReferentialLength
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection :=
  row.obstruction

/--
The operational gap carried by an arithmetic dynamic row.
-/
def arithmeticDynamicRowOperationalGap
    (row : ArithmeticDynamicGapRow) :
    EnrichedOperationalReferentialLength
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  row.recovery

/-- A dynamic arithmetic row refutes the short payload presentation. -/
theorem arithmeticDynamicRow_refutes_shortPresentation
    (row : ArithmeticDynamicGapRow)
    (short : ArithmeticShortPayloadPresentation) :
    False :=
  operationalLength_refutes_shortPresentation
    (arithmeticDynamicRowOperationalGap row)
    short

/-- A repeated-index collision carries an arithmetic operational gap. -/
def repeatedIndexArithmeticOperationalGap
    (collision : RepeatedIndexCollision) :
    EnrichedOperationalReferentialLength
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  arithmeticDynamicRowOperationalGap
    (repeatedIndexDynamicGapRow collision)

/-- A trajectory collision carries an arithmetic operational gap. -/
def trajectoryArithmeticOperationalGap
    {step : Nat -> Nat}
    {start : Nat}
    (collision : NatTrajectoryRepeatedIndexCollision step start) :
    EnrichedOperationalReferentialLength
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  arithmeticDynamicRowOperationalGap
    (trajectoryDynamicGapRow collision)

/-- A bounded trajectory window carries an arithmetic operational gap. -/
def boundedWindowArithmeticOperationalGap
    {step : Nat -> Nat}
    {start windowStart B : Nat}
    (window : NatTrajectoryBoundedWindow step start windowStart B) :
    EnrichedOperationalReferentialLength
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  arithmeticDynamicRowOperationalGap
    (boundedWindowDynamicGapRow window)

/-- A post-peak window carries an arithmetic operational gap. -/
def postPeakWindowArithmeticOperationalGap
    {step : Nat -> Nat}
    {start : Nat}
    {cert : NatTrajectoryFinitePrefixHeightCertificate step start}
    (window : NatTrajectoryPostPeakWindow cert) :
    EnrichedOperationalReferentialLength
      ArithmeticEnrichedInterface
      ArithmeticVisiblePayload
      arithmeticPayloadProjection
      NatInterfaceRepair :=
  arithmeticDynamicRowOperationalGap
    (postPeakWindowDynamicGapRow window)

/-- The canonical positive diagonal arithmetic gap has terminal excess `1`. -/
theorem canonicalArithmeticGapTerminalExcess_eq_one
    (height : Nat) :
    arithmeticGapTerminalExcessOfIntersection
      (canonicalIntersection height) = 1 :=
  canonicalPositiveDiagonalTerminalExcess_eq_one height

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

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.ArithmeticShortPayloadPresentation
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticGapTerminalExcessOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticGapTerminalExcess_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticGap_sameVisible
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticGap_separated
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticStructuralGapOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticOperationalGapOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticStructuralGapOfOperationalIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticStructuralGap_refutes_shortPresentation
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticOperationalGap_refutes_shortPresentation
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticTruthGapRecoveryOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRowStructuralGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRowOperationalGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_refutes_shortPresentation
#print axioms Meta.EnrichedNatClosedStabilityInstance.repeatedIndexArithmeticOperationalGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.trajectoryArithmeticOperationalGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.boundedWindowArithmeticOperationalGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.postPeakWindowArithmeticOperationalGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.canonicalArithmeticGapTerminalExcess_eq_one
#print axioms Meta.EnrichedNatClosedStabilityInstance.countdownArithmeticGapTerminalExcess_eq_n_plus_two
/- AXIOM_AUDIT_END -/
