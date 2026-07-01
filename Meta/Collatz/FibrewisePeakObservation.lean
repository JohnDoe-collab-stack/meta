import Meta.Collatz.InitialIndexedFibre

/-!
# Collatz fibrewise peak observation

This file exposes the fibrewise peak as an operational visible trace
observation.

The observation does not use the conserved `activeHeight` field of the enriched
temporal state.  It uses the canonical countdown consumer already attached to
the initial index: the peak `H(n)` is the terminal excess of that consumer, and
the consumer's formed trace has terminal visible payload `H(n)`.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Canonical peak consumer -/

/--
The canonical countdown consumer of the fibrewise peak attached to the initial
index `n`.
-/
def collatzInitialIndexPeakConsumer
    (n : Nat) :
    PrimitiveMemoryReadingIntersection
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision (n + n))))) :=
  countdownTerminalIntersection (n + n)

/-- The terminal excess of the canonical consumer is the initial-index peak. -/
theorem collatzInitialIndexPeakConsumer_terminalExcess_eq_height
    (n : Nat) :
    formedPositiveExcessOfIntersection
        (collatzInitialIndexPeakConsumer n) =
      collatzInitialIndexFibreHeight n :=
  Eq.symm (collatzInitialIndexFibreHeight_eq_countdownTerminalExcess n)

/-! ## Operational visible observation -/

/--
The formed trace of the canonical countdown consumer of the initial-index
fibrewise peak.
-/
def collatzInitialIndexPeakObservationTrace
    (n : Nat) :
    List NatTraceAtom :=
  formedTraceOfIntersection
    (collatzInitialIndexPeakConsumer n)

/--
The peak observation trace ends with the formed excess atom at the fibrewise
peak `H(n)`.
-/
theorem collatzInitialIndexPeakObservationTrace_eq_prefix_append_excessHeight
    (n : Nat) :
    collatzInitialIndexPeakObservationTrace n =
      (collatzInitialIndexPeakConsumer n).forward.trace ++
        [NatTraceAtom.excess (collatzInitialIndexFibreHeight n)] := by
  unfold collatzInitialIndexPeakObservationTrace
  unfold formedTraceOfIntersection
  rw [collatzInitialIndexPeakConsumer_terminalExcess_eq_height]

/-- The fibrewise peak occurs as the final enriched atom of a canonical trace. -/
theorem collatzFibrewisePeakOccursAsFinalExcess
    (n : Nat) :
    Exists (fun (pref : List NatTraceAtom) =>
      collatzInitialIndexPeakObservationTrace n =
        pref ++ [NatTraceAtom.excess (collatzInitialIndexFibreHeight n)]) :=
  ⟨(collatzInitialIndexPeakConsumer n).forward.trace,
    collatzInitialIndexPeakObservationTrace_eq_prefix_append_excessHeight n⟩

/-- The peak observation trace reads as the closing role at the fibrewise peak. -/
theorem collatzInitialIndexPeakObservationTrace_role_eq_closingHeight
    (n : Nat) :
    terminalTraceRole (collatzInitialIndexPeakObservationTrace n) =
      NatEnrichedParityRole.closingExcess
        (collatzInitialIndexFibreHeight n) := by
  unfold collatzInitialIndexPeakObservationTrace
  rw [terminalTraceRole_formedTraceOfIntersection]
  rw [collatzInitialIndexPeakConsumer_terminalExcess_eq_height]

/--
The terminal visible payload of the peak observation trace is exactly the
fibrewise peak `H(n)`.
-/
theorem collatzInitialIndexPeakObservationTrace_terminalPayload_eq_height
    (n : Nat) :
    terminalPayload
        (tracePayloads (collatzInitialIndexPeakObservationTrace n)) =
      collatzInitialIndexFibreHeight n := by
  unfold collatzInitialIndexPeakObservationTrace
  rw [terminalPayload_formedTraceOfIntersection]
  rw [collatzInitialIndexPeakConsumer_terminalExcess_eq_height]

/-! ## Classical visible peak reading -/

/--
Classical visible reading of the initial-index peak.

This is definitionally the fibrewise height `H(n)`.
-/
def collatzClassicalVisiblePeakOfIndex
    (n : Nat) :
    Nat :=
  collatzInitialIndexFibreHeight n

/-- The classical visible peak reading is definitionally the fibrewise height. -/
theorem collatzClassicalVisiblePeakOfIndex_eq_height
    (n : Nat) :
    collatzClassicalVisiblePeakOfIndex n =
      collatzInitialIndexFibreHeight n :=
  rfl

/-- The terminal payload of the enriched peak trace is the classical visible peak. -/
theorem collatzInitialIndexPeakObservationTrace_terminalPayload_eq_classicalVisiblePeak
    (n : Nat) :
    terminalPayload
        (tracePayloads (collatzInitialIndexPeakObservationTrace n)) =
      collatzClassicalVisiblePeakOfIndex n :=
  collatzInitialIndexPeakObservationTrace_terminalPayload_eq_height n

/--
The final enriched excess atom is indexed by the classical visible peak.
-/
theorem collatzFibrewisePeakOccursAsFinalExcess_classicalVisiblePeak
    (n : Nat) :
    Exists (fun (pref : List NatTraceAtom) =>
      collatzInitialIndexPeakObservationTrace n =
        pref ++
          [NatTraceAtom.excess
            (collatzClassicalVisiblePeakOfIndex n)]) := by
  change
    Exists (fun (pref : List NatTraceAtom) =>
      collatzInitialIndexPeakObservationTrace n =
        pref ++
          [NatTraceAtom.excess
            (collatzInitialIndexFibreHeight n)])
  exact collatzFibrewisePeakOccursAsFinalExcess n

/--
The operational role through which the initial-index fibrewise peak is observed.

It is the closing/forming role of the canonical countdown consumer.
-/
def collatzInitialIndexPeakObservationRole
    (n : Nat) :
    NatEnrichedParityRole :=
  arithmeticClosingRoleOfIntersection
    (collatzInitialIndexPeakConsumer n)

/-- The peak observation role is the closing role at the fibrewise peak. -/
theorem collatzInitialIndexPeakObservationRole_eq_closingHeight
    (n : Nat) :
    collatzInitialIndexPeakObservationRole n =
      NatEnrichedParityRole.closingExcess
        (collatzInitialIndexFibreHeight n) := by
  unfold collatzInitialIndexPeakObservationRole
  rw [arithmeticClosingRoleOfIntersection_eq]
  rw [collatzInitialIndexPeakConsumer_terminalExcess_eq_height]

/-- The visible value observed from the peak role. -/
def collatzInitialIndexPeakObservationValue
    (n : Nat) :
    Nat :=
  natEnrichedParityRolePayload
    (collatzInitialIndexPeakObservationRole n)

/--
The operational visible observation of the peak is exactly the fibrewise peak
`H(n)`.
-/
theorem collatzInitialIndexPeakObservationValue_eq_height
    (n : Nat) :
    collatzInitialIndexPeakObservationValue n =
      collatzInitialIndexFibreHeight n := by
  unfold collatzInitialIndexPeakObservationValue
  rw [collatzInitialIndexPeakObservationRole_eq_closingHeight]
  rfl

/-- The observed peak value is strictly positive. -/
theorem collatzInitialIndexPeakObservationValue_pos
    (n : Nat) :
    0 < collatzInitialIndexPeakObservationValue n := by
  rw [collatzInitialIndexPeakObservationValue_eq_height]
  exact collatzInitialIndexFibreHeight_pos n

/--
The initial-index fibrewise peak is reached as the terminal visible payload of
an operational formed trace of the framework.
-/
theorem collatzFibrewisePeakReached
    (n : Nat) :
    Exists (fun trace : List NatTraceAtom =>
      terminalPayload (tracePayloads trace) =
        collatzInitialIndexFibreHeight n) :=
  ⟨collatzInitialIndexPeakObservationTrace n,
    collatzInitialIndexPeakObservationTrace_terminalPayload_eq_height n⟩

/-! ## Observation package -/

/--
Canonical package witnessing the operational observation of the fibrewise peak.
-/
structure CollatzFibrewisePeakObservation
    (n : Nat) where
  consumer :
    PrimitiveMemoryReadingIntersection
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (countdownTerminalWindowCollision (n + n)))))
  consumer_eq :
    consumer = collatzInitialIndexPeakConsumer n
  peak : Nat
  peak_eq_height :
    peak = collatzInitialIndexFibreHeight n
  terminalExcess_eq_peak :
    formedPositiveExcessOfIntersection consumer = peak
  observedTrace : List NatTraceAtom
  observedTrace_eq :
    observedTrace = formedTraceOfIntersection consumer
  observedTrace_final_excess :
    observedTrace =
      consumer.forward.trace ++ [NatTraceAtom.excess peak]
  observedTrace_role_eq_closingPeak :
    terminalTraceRole observedTrace =
      NatEnrichedParityRole.closingExcess peak
  observedTrace_terminalPayload_eq_peak :
    terminalPayload (tracePayloads observedTrace) = peak
  classicalVisiblePeak : Nat
  classicalVisiblePeak_eq :
    classicalVisiblePeak = collatzClassicalVisiblePeakOfIndex n
  classicalVisiblePeak_eq_peak :
    classicalVisiblePeak = peak
  observedTrace_terminalPayload_eq_classicalVisiblePeak :
    terminalPayload (tracePayloads observedTrace) = classicalVisiblePeak
  observedTrace_final_excess_classicalVisiblePeak :
    observedTrace =
      consumer.forward.trace ++ [NatTraceAtom.excess classicalVisiblePeak]
  observedRole : NatEnrichedParityRole
  observedRole_eq :
    observedRole = arithmeticClosingRoleOfIntersection consumer
  observedRole_eq_closingPeak :
    observedRole = NatEnrichedParityRole.closingExcess peak
  observed : Nat
  observed_eq_payload :
    observed = natEnrichedParityRolePayload observedRole
  observed_eq_peak :
    observed = peak
  witness :
    NatEnrichedParityPositiveInternalDiagonalWitness n
  witness_value_eq_peak :
    witness.witness = peak

/-- Canonical operational observation of the initial-index fibrewise peak. -/
def collatzFibrewisePeakObservation
    (n : Nat) :
    CollatzFibrewisePeakObservation n where
  consumer := collatzInitialIndexPeakConsumer n
  consumer_eq := rfl
  peak := collatzInitialIndexFibreHeight n
  peak_eq_height := rfl
  terminalExcess_eq_peak :=
    collatzInitialIndexPeakConsumer_terminalExcess_eq_height n
  observedTrace := collatzInitialIndexPeakObservationTrace n
  observedTrace_eq := rfl
  observedTrace_final_excess :=
    collatzInitialIndexPeakObservationTrace_eq_prefix_append_excessHeight n
  observedTrace_role_eq_closingPeak :=
    collatzInitialIndexPeakObservationTrace_role_eq_closingHeight n
  observedTrace_terminalPayload_eq_peak :=
    collatzInitialIndexPeakObservationTrace_terminalPayload_eq_height n
  classicalVisiblePeak := collatzClassicalVisiblePeakOfIndex n
  classicalVisiblePeak_eq := rfl
  classicalVisiblePeak_eq_peak := rfl
  observedTrace_terminalPayload_eq_classicalVisiblePeak :=
    collatzInitialIndexPeakObservationTrace_terminalPayload_eq_classicalVisiblePeak n
  observedTrace_final_excess_classicalVisiblePeak :=
    collatzInitialIndexPeakObservationTrace_eq_prefix_append_excessHeight n
  observedRole := collatzInitialIndexPeakObservationRole n
  observedRole_eq := rfl
  observedRole_eq_closingPeak :=
    collatzInitialIndexPeakObservationRole_eq_closingHeight n
  observed := collatzInitialIndexPeakObservationValue n
  observed_eq_payload := rfl
  observed_eq_peak :=
    collatzInitialIndexPeakObservationValue_eq_height n
  witness := collatzInitialIndexFibreHeightWitness n
  witness_value_eq_peak :=
    collatzInitialIndexFibreHeightWitness_witness_eq_height n

/-- The canonical observation observes the fibrewise peak. -/
theorem collatzFibrewisePeakObservation_observed_eq_height
    (n : Nat) :
    (collatzFibrewisePeakObservation n).observed =
      collatzInitialIndexFibreHeight n :=
  collatzInitialIndexPeakObservationValue_eq_height n

/-- The canonical observation is positive. -/
theorem collatzFibrewisePeakObservation_observed_pos
    (n : Nat) :
    0 < (collatzFibrewisePeakObservation n).observed :=
  collatzInitialIndexPeakObservationValue_pos n

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexPeakConsumer
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexPeakConsumer_terminalExcess_eq_height
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexPeakObservationTrace
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexPeakObservationTrace_eq_prefix_append_excessHeight
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewisePeakOccursAsFinalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexPeakObservationTrace_role_eq_closingHeight
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexPeakObservationTrace_terminalPayload_eq_height
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzClassicalVisiblePeakOfIndex
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzClassicalVisiblePeakOfIndex_eq_height
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexPeakObservationTrace_terminalPayload_eq_classicalVisiblePeak
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewisePeakOccursAsFinalExcess_classicalVisiblePeak
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexPeakObservationRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexPeakObservationRole_eq_closingHeight
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexPeakObservationValue
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexPeakObservationValue_eq_height
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzInitialIndexPeakObservationValue_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewisePeakReached
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzFibrewisePeakObservation
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewisePeakObservation
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewisePeakObservation_observed_eq_height
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzFibrewisePeakObservation_observed_pos
/- AXIOM_AUDIT_END -/
