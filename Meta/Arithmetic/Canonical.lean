import Meta.Arithmetic.Core

/-!
# Canonical
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Canonical concrete intersection -/

/-- Canonical closed branch at `n`. -/
def canonicalBranch (n : Nat) : MemoryBranch where
  memory := n
  source := n

/-- Canonical typed intersection at `n`, carried by the global trace. -/
def canonicalIntersection
    (n : Nat) :
    bidirectionalCompleteness.Intersection (canonicalBranch n) :=
  primitiveMemoryReadingIntersection_of_sharedTrace
    (branch := canonicalBranch n)
    (globalTrace n)
    rfl
    rfl
    0

/-- The canonical intersection generates the strong source-preserving cycle. -/
def enrichedNatStrongTerminalCycleFromIntersection
    (n : Nat) :
    StrongTerminalCycleFromIntersection
      bidirectionalCompleteness
      (canonicalBranch n) :=
  strongClosedStabilityFromIntersectionTheorem
    bidirectionalCompleteness
    enrichedNatRoundTripCoherence
    (canonicalIntersection n)


/-- Canonical formed interface witness at `n`. -/
def canonicalInterfaceWitness
    (n : Nat) :
    InterfaceWitness (List NatTraceAtom) NatInterfaceWitness where
  interface := formedTraceOfIntersection (canonicalIntersection n)
  witness :=
    { payload := tracePayloads (formedTraceOfIntersection (canonicalIntersection n))
      payload_eq := rfl }

/-- The canonical strong cycle realizes the canonical interface. -/
def canonicalInterfaceRealization
    (n : Nat) :
    NatInterfaceRealization
      (enrichedNatStrongTerminalCycleFromIntersection n)
      (formedTraceOfIntersection (canonicalIntersection n)) where
  interface_eq_formedTrace := rfl

/-- Concrete strong closed stability for the enriched Nat base instance. -/
def enrichedNatStrongClosedStabilityFromIntersection
    (n : Nat) :
    StrongClosedStabilityFromIntersection
      bidirectionalCompleteness
      (canonicalBranch n)
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization :=
  strongClosedStabilityFromIntersectionLinkedTheorem
    bidirectionalCompleteness
    enrichedNatRoundTripCoherence
    (canonicalIntersection n)
    (canonicalInterfaceWitness n)
    (canonicalInterfaceRealization n)


/-- Concrete non-projective closed stability preserving the source intersection. -/
def enrichedNatNonProjectiveStrongClosedStabilityFromIntersection
    (n : Nat) :
    NonProjectiveStrongClosedStabilityFromIntersection
      bidirectionalCompleteness
      (canonicalBranch n)
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads :=
  nonProjectiveStrongClosedStabilityFromIntersectionTheorem
    bidirectionalCompleteness
    enrichedNatRoundTripCoherence
    (canonicalIntersection n)
    (canonicalInterfaceWitness n)
    (canonicalInterfaceRealization n)
    (payloadProjectionObstructionOfIntersection (canonicalIntersection n))

/-- The concrete source-preserving stability excludes projective reconstruction. -/
def enrichedNatNoProjectiveReconstructionFromIntersection
    (n : Nat) :
    ((recover : List Nat -> List NatTraceAtom) ->
      ((interface : List NatTraceAtom) ->
        recover (tracePayloads interface) = interface) ->
          False) :=
  noProjectiveReconstructionOfStabilityFromIntersection
    (enrichedNatNonProjectiveStrongClosedStabilityFromIntersection n)

/-- Canonical recovery bundle at `n`. -/
def canonicalRecoveryBundle
    (n : Nat) :
    RecoveryBundle (List NatTraceAtom) NatInterfaceRepair where
  interface :=
    (localIntersectionRecoveryPackage (canonicalIntersection n)).recovery.interface
  repair :=
    (localIntersectionRecoveryPackage (canonicalIntersection n)).recovery.repair

/-- Canonical terminal payload projection at `n`. -/
def canonicalTerminalProjection
    (n : Nat) :
    TerminalProjection
      (List NatTraceAtom)
      (List Nat)
      tracePayloads where
  interface :=
    (localIntersectionRecoveryPackage (canonicalIntersection n)).projection.interface
  visible :=
    (localIntersectionRecoveryPackage (canonicalIntersection n)).projection.visible
  projected :=
    (localIntersectionRecoveryPackage (canonicalIntersection n)).projection.projected

/-- Canonical enriched Nat arithmetic instance. -/
def canonicalNatClosedStabilityArithmeticInstance
    (n : Nat) :
    NatClosedStabilityArithmeticInstance where
  branch := canonicalBranch n
  intersection := canonicalIntersection n
  formed := canonicalInterfaceWitness n
  formed_sameInterface := rfl
  realizes := canonicalInterfaceRealization n
  localPackage :=
    localIntersectionRecoveryPackage (canonicalIntersection n)

/-- Locally recovered package for the base enriched Nat intersection. -/
def enrichedNatLocallyRecoveredClosedStabilityInstance
    (n : Nat) :
    LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
      bidirectionalCompleteness
      (canonicalBranch n)
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads
      NatInterfaceRepair :=
  natClosedStability_of_arithmeticInstance
    (canonicalNatClosedStabilityArithmeticInstance n)

/--
The recovered non-projective closed-stability package for the base enriched Nat
intersection.
-/
def enrichedNatClosedStabilityInstance
    (n : Nat) :
    RecoveredNonProjectiveClosedStabilityFromIntersection
      bidirectionalCompleteness
      (canonicalBranch n)
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads
      NatInterfaceRepair :=
  (enrichedNatLocallyRecoveredClosedStabilityInstance n).recovered

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.canonicalIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.canonicalNatClosedStabilityArithmeticInstance
#print axioms Meta.EnrichedNatClosedStabilityInstance.enrichedNatLocallyRecoveredClosedStabilityInstance
#print axioms Meta.EnrichedNatClosedStabilityInstance.enrichedNatClosedStabilityInstance
/- AXIOM_AUDIT_END -/
