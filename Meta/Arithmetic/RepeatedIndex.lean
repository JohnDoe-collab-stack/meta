import Meta.Arithmetic.Canonical

/-!
# RepeatedIndex
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Repeated-index collision data -/

/--
A repeated-index collision carries two positions and two observed Nat values.

The endpoint equality is data produced outside the bidirectional completion
interface; the completion consumes it only through the shared trace it induces.
-/
structure RepeatedIndexCollision where
  firstTime : Nat
  secondTime : Nat
  left : Nat
  right : Nat
  first_lt_second : firstTime < secondTime
  same_index : left = right

/-- The memory/source branch exposed by a repeated-index collision. -/
def repeatedIndexBranch
    (collision : RepeatedIndexCollision) :
    MemoryBranch where
  memory := collision.left
  source := collision.right

/-- The collision proves that the branch endpoints coincide. -/
theorem repeatedIndexBranch_memory_eq_source
    (collision : RepeatedIndexCollision) :
    (repeatedIndexBranch collision).memory =
      (repeatedIndexBranch collision).source :=
  collision.same_index

/-! ## Dynamic typed intersection -/

/--
The repeated-index equality supplies the shared trace required by the typed
intersection.  This is the non-canonical counterpart of `canonicalIntersection`.
-/
def repeatedIndexIntersection
    (collision : RepeatedIndexCollision) :
    bidirectionalCompleteness.Intersection
      (repeatedIndexBranch collision) :=
  primitiveMemoryReadingIntersection_of_sharedTrace
    (branch := repeatedIndexBranch collision)
    (globalTrace collision.left)
    rfl
    (congrArg globalTrace collision.same_index)
    collision.secondTime

/-- The repeated-index intersection generates a source-preserving strong cycle. -/
def repeatedIndexStrongTerminalCycleFromIntersection
    (collision : RepeatedIndexCollision) :
    StrongTerminalCycleFromIntersection
      bidirectionalCompleteness
      (repeatedIndexBranch collision) :=
  strongClosedStabilityFromIntersectionTheorem
    bidirectionalCompleteness
    enrichedNatRoundTripCoherence
    (repeatedIndexIntersection collision)

/-! ## Interface realization -/

/-- Formed interface witness for the repeated-index trace. -/
def repeatedIndexInterfaceWitness
    (collision : RepeatedIndexCollision) :
    InterfaceWitness (List NatTraceAtom) NatInterfaceWitness where
  interface := formedTraceOfIntersection (repeatedIndexIntersection collision)
  witness :=
    { payload :=
        tracePayloads (formedTraceOfIntersection (repeatedIndexIntersection collision))
      payload_eq := rfl }

/-- The repeated-index strong cycle realizes its trace interface. -/
def repeatedIndexInterfaceRealization
    (collision : RepeatedIndexCollision) :
    NatInterfaceRealization
      (repeatedIndexStrongTerminalCycleFromIntersection collision)
      (formedTraceOfIntersection (repeatedIndexIntersection collision)) where
  interface_eq_formedTrace := rfl

/-- Strong closed stability generated from a repeated-index collision. -/
def repeatedIndexStrongClosedStabilityFromIntersection
    (collision : RepeatedIndexCollision) :
    StrongClosedStabilityFromIntersection
      bidirectionalCompleteness
      (repeatedIndexBranch collision)
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization :=
  strongClosedStabilityFromIntersectionLinkedTheorem
    bidirectionalCompleteness
    enrichedNatRoundTripCoherence
    (repeatedIndexIntersection collision)
    (repeatedIndexInterfaceWitness collision)
    (repeatedIndexInterfaceRealization collision)

/-! ## Non-projective repeated-index stability -/

/-- Payload projection obstruction at the left endpoint of the collision. -/
def repeatedIndexPayloadProjectionObstruction
    (collision : RepeatedIndexCollision) :
    ProjectionObstruction
      (List NatTraceAtom)
      (List Nat)
      tracePayloads :=
  payloadProjectionObstructionOfIntersection
    (repeatedIndexIntersection collision)

/-- Non-projective closed stability generated from a repeated-index collision. -/
def repeatedIndexNonProjectiveStrongClosedStabilityFromIntersection
    (collision : RepeatedIndexCollision) :
    NonProjectiveStrongClosedStabilityFromIntersection
      bidirectionalCompleteness
      (repeatedIndexBranch collision)
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads :=
  nonProjectiveStrongClosedStabilityFromIntersectionTheorem
    bidirectionalCompleteness
    enrichedNatRoundTripCoherence
    (repeatedIndexIntersection collision)
    (repeatedIndexInterfaceWitness collision)
    (repeatedIndexInterfaceRealization collision)
    (repeatedIndexPayloadProjectionObstruction collision)

/-- The repeated-index stability excludes payload-only reconstruction. -/
def repeatedIndexNoProjectiveReconstructionFromIntersection
    (collision : RepeatedIndexCollision) :
    ((recover : List Nat -> List NatTraceAtom) ->
      ((interface : List NatTraceAtom) ->
        recover (tracePayloads interface) = interface) ->
          False) :=
  noProjectiveReconstructionOfStabilityFromIntersection
    (repeatedIndexNonProjectiveStrongClosedStabilityFromIntersection collision)

/-! ## Recovery and terminal projection -/

/-- Recovery bundle attached to the repeated-index formed trace interface. -/
def repeatedIndexRecoveryBundle
    (collision : RepeatedIndexCollision) :
    RecoveryBundle (List NatTraceAtom) NatInterfaceRepair where
  interface :=
    (localIntersectionRecoveryPackage
      (repeatedIndexIntersection collision)).recovery.interface
  repair :=
    (localIntersectionRecoveryPackage
      (repeatedIndexIntersection collision)).recovery.repair

/-- Terminal payload projection of the repeated-index formed trace interface. -/
def repeatedIndexTerminalProjection
    (collision : RepeatedIndexCollision) :
    TerminalProjection
      (List NatTraceAtom)
      (List Nat)
      tracePayloads where
  interface :=
    (localIntersectionRecoveryPackage
      (repeatedIndexIntersection collision)).projection.interface
  visible :=
    (localIntersectionRecoveryPackage
      (repeatedIndexIntersection collision)).projection.visible
  projected :=
    (localIntersectionRecoveryPackage
      (repeatedIndexIntersection collision)).projection.projected

/-- Repeated-index enriched Nat arithmetic instance. -/
def repeatedIndexNatClosedStabilityArithmeticInstance
    (collision : RepeatedIndexCollision) :
    NatClosedStabilityArithmeticInstance where
  branch := repeatedIndexBranch collision
  intersection := repeatedIndexIntersection collision
  formed := repeatedIndexInterfaceWitness collision
  formed_sameInterface := rfl
  realizes := repeatedIndexInterfaceRealization collision
  localPackage :=
    localIntersectionRecoveryPackage
      (repeatedIndexIntersection collision)

/-- Locally recovered package generated from a repeated-index collision. -/
def repeatedIndexLocallyRecoveredClosedStabilityInstance
    (collision : RepeatedIndexCollision) :
    LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
      bidirectionalCompleteness
      (repeatedIndexBranch collision)
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads
      NatInterfaceRepair :=
  natClosedStability_of_arithmeticInstance
    (repeatedIndexNatClosedStabilityArithmeticInstance collision)

/--
The full recovered non-projective closed-stability instance generated from a
repeated-index collision.
-/
def repeatedIndexClosedStabilityInstance
    (collision : RepeatedIndexCollision) :
    RecoveredNonProjectiveClosedStabilityFromIntersection
      bidirectionalCompleteness
      (repeatedIndexBranch collision)
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads
      NatInterfaceRepair :=
  (repeatedIndexLocallyRecoveredClosedStabilityInstance collision).recovered


end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.RepeatedIndexCollision
#print axioms Meta.EnrichedNatClosedStabilityInstance.repeatedIndexIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.repeatedIndexNatClosedStabilityArithmeticInstance
#print axioms Meta.EnrichedNatClosedStabilityInstance.repeatedIndexLocallyRecoveredClosedStabilityInstance
#print axioms Meta.EnrichedNatClosedStabilityInstance.repeatedIndexClosedStabilityInstance
/- AXIOM_AUDIT_END -/
