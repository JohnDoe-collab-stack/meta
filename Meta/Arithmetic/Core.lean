import Meta.Core.ClosedStabilityTheorem

/-!
# Enriched Nat closed-stability core

This file rebuilds the enriched-`Nat` data needed to instantiate the
standalone closed-stability package without importing the heavier enriched Nat
or relational trace layers.  The main autonomous instance is driven by an
intrinsic countdown dynamics, a constructive bounded-window collision, explicit
recomposition evidence, and a positive-excess non-projective obstruction.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Enriched Nat traces -/

/-- Roles visible in the enriched Nat trace. -/
inductive NatTraceRole where
  | value
  | quote
  | marginal
  | global
  | excess

/-- Atoms of the enriched Nat trace. -/
inductive NatTraceAtom where
  | value : Nat -> NatTraceAtom
  | quote : Nat -> NatTraceAtom
  | marginal : Nat -> NatTraceAtom
  | global : Nat -> NatTraceAtom
  | excess : Nat -> NatTraceAtom

/-- Numeric payload projection of a Nat trace atom. -/
def atomPayload : NatTraceAtom -> Nat
  | NatTraceAtom.value n => n
  | NatTraceAtom.quote n => n
  | NatTraceAtom.marginal n => n
  | NatTraceAtom.global n => n
  | NatTraceAtom.excess n => n

/-- Structured global trace of a natural number. -/
def globalTrace (n : Nat) : List NatTraceAtom :=
  [NatTraceAtom.global n, NatTraceAtom.value n, NatTraceAtom.quote n]

/-- Isolated marginal reconstruction of a natural number payload. -/
def marginalTrace (_source payload : Nat) : List NatTraceAtom :=
  [NatTraceAtom.marginal payload, NatTraceAtom.value payload,
    NatTraceAtom.quote payload]

/-- Payload sequence of a structured trace. -/
def tracePayloads (trace : List NatTraceAtom) : List Nat :=
  trace.map atomPayload

/-- Positive excess carried by formed trace atoms and invisible as a role. -/
def traceExcess : List NatTraceAtom -> Nat
  | [] => 0
  | NatTraceAtom.value _ :: rest => traceExcess rest
  | NatTraceAtom.quote _ :: rest => traceExcess rest
  | NatTraceAtom.marginal _ :: rest => traceExcess rest
  | NatTraceAtom.global _ :: rest => traceExcess rest
  | NatTraceAtom.excess n :: rest => n + traceExcess rest

/-- A marginal reconstruction is not the global trace at the same source. -/
theorem marginalTrace_ne_globalTrace
    (source payload : Nat) :
    marginalTrace source payload = globalTrace source -> False := by
  intro h
  cases h

/-! ## Minimal bidirectional memory branch -/

/-- A memory branch with a memory endpoint and a source endpoint. -/
structure MemoryBranch where
  memory : Nat
  source : Nat

/-- Forward reading of the memory endpoint. -/
structure PrimitiveMemoryForwardReading
    (branch : MemoryBranch) where
  trace : List NatTraceAtom
  reads_memory : trace = globalTrace branch.memory

/-- Backward reading of the source endpoint. -/
structure PrimitiveMemoryBackwardReading
    (branch : MemoryBranch) where
  trace : List NatTraceAtom
  reads_source : trace = globalTrace branch.source

/-- Typed intersection of the two primitive readings, with an internal excess witness. -/
structure PrimitiveMemoryReadingIntersection
    (branch : MemoryBranch) where
  forward : PrimitiveMemoryForwardReading branch
  backward : PrimitiveMemoryBackwardReading branch
  common_trace : forward.trace = backward.trace
  excess : Nat

/-- Positive formed excess carried by an intersection. -/
def formedPositiveExcessOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Nat :=
  intersection.excess + 1

/-- The formed excess carried by an intersection is strictly positive. -/
theorem formedPositiveExcessOfIntersection_pos
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    0 < formedPositiveExcessOfIntersection intersection :=
  Nat.succ_pos intersection.excess

/-- Recomposition adds the positive excess atom to the shared formed trace. -/
def formedTraceOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    List NatTraceAtom :=
  intersection.forward.trace ++
    [NatTraceAtom.excess (formedPositiveExcessOfIntersection intersection)]

/-- Visible payload of a recomposed formed trace. -/
def formedPayloadOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    List Nat :=
  tracePayloads (formedTraceOfIntersection intersection)

/-- Indexed recomposition evidence for the formed trace and visible payload. -/
inductive PrimitiveRecompositionEvidence
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    List NatTraceAtom -> List Nat -> Type where
  | formed :
      PrimitiveRecompositionEvidence
        intersection
        (formedTraceOfIntersection intersection)
        (formedPayloadOfIntersection intersection)

/-- Closed bidirectional memory formation with explicit recomposed structure. -/
structure PrimitiveBidirectionalMemoryFormation
    (branch : MemoryBranch) where
  intersection : PrimitiveMemoryReadingIntersection branch
  formedTrace : List NatTraceAtom
  formedPayload : List Nat
  recomposed :
    PrimitiveRecompositionEvidence intersection formedTrace formedPayload

/-- A shared trace forms the primitive bidirectional intersection. -/
def primitiveMemoryReadingIntersection_of_sharedTrace
    {branch : MemoryBranch}
    (trace : List NatTraceAtom)
    (hMemory : trace = globalTrace branch.memory)
    (hSource : trace = globalTrace branch.source)
    (excess : Nat) :
    PrimitiveMemoryReadingIntersection branch where
  forward :=
    { trace := trace
      reads_memory := hMemory }
  backward :=
    { trace := trace
      reads_source := hSource }
  common_trace := rfl
  excess := excess

/-- Complete data recomposed from a typed intersection. -/
def primitiveCompleteOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    PrimitiveBidirectionalMemoryFormation branch where
  intersection := intersection
  formedTrace := formedTraceOfIntersection intersection
  formedPayload := formedPayloadOfIntersection intersection
  recomposed := PrimitiveRecompositionEvidence.formed

/-- Enriched Nat bidirectional completeness with explicit recomposition. -/
def bidirectionalCompleteness :
    BidirectionalCompleteness MemoryBranch where
  Complete := fun branch =>
    PrimitiveBidirectionalMemoryFormation branch
  Forward := fun branch =>
    PrimitiveMemoryForwardReading branch
  Backward := fun branch =>
    PrimitiveMemoryBackwardReading branch
  Intersection := fun branch =>
    PrimitiveMemoryReadingIntersection branch
  forwardOfComplete := by
    intro _branch complete
    exact complete.intersection.forward
  backwardOfComplete := by
    intro _branch complete
    exact complete.intersection.backward
  intersectionOfComplete := by
    intro _branch complete
    exact complete.intersection
  completeOfIntersection := by
    intro _branch intersection
    exact primitiveCompleteOfIntersection intersection

/-- The enriched Nat completion preserves both recomposition round trips. -/
def enrichedNatRoundTripCoherence :
    RoundTripCoherence bidirectionalCompleteness where
  completeRoundTrip :=
    { complete_stable := by
        intro _branch closed
        cases closed with
        | mk intersection formedTrace formedPayload recomposed =>
            cases recomposed
            change primitiveCompleteOfIntersection intersection =
              { intersection := intersection
                formedTrace := formedTraceOfIntersection intersection
                formedPayload := formedPayloadOfIntersection intersection
                recomposed := PrimitiveRecompositionEvidence.formed }
            rfl }
  intersectionRoundTrip :=
    { intersection_stable := by
        intro _branch _intersection
        rfl }

/-! ## Interface realization and witness -/

/-- A concrete interface realization records that the interface is the recomposed formed trace. -/
structure NatInterfaceRealization
    {branch : MemoryBranch}
    (cycle :
      StrongTerminalCycleFromIntersection bidirectionalCompleteness branch)
    (interface : List NatTraceAtom) : Type where
  interface_eq_formedTrace :
    interface = formedTraceOfIntersection cycle.sourceIntersection

/-- Dependent witness carried by a formed trace interface. -/
structure NatInterfaceWitness
    (interface : List NatTraceAtom) where
  payload : List Nat
  payload_eq : payload = tracePayloads interface

/-! ## Payload diagonal obstruction localized on the formed intersection -/

/--
Payload-only shadow of the formed intersection trace.

It keeps the exact same prefix and payload as `formedTraceOfIntersection`, but
replaces the formed excess atom by a payload value atom.
-/
def payloadOnlyTraceOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    List NatTraceAtom :=
  intersection.forward.trace ++
    [NatTraceAtom.value (formedPositiveExcessOfIntersection intersection)]

/-- Replacing a final excess atom by a value atom preserves visible payload. -/
theorem tracePayloads_append_excess_eq_value
    (pref : List NatTraceAtom)
    (excess : Nat) :
    tracePayloads (pref ++ [NatTraceAtom.excess excess]) =
      tracePayloads (pref ++ [NatTraceAtom.value excess]) := by
  induction pref with
  | nil => rfl
  | cons atom rest ih =>
      change
        atomPayload atom ::
          tracePayloads (rest ++ [NatTraceAtom.excess excess]) =
        atomPayload atom ::
          tracePayloads (rest ++ [NatTraceAtom.value excess])
      rw [ih]

/-- The payload projection forgets the formed excess role on the exact interface. -/
theorem formedTraceOfIntersection_same_payloadOnlyPayload
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    tracePayloads (formedTraceOfIntersection intersection) =
      tracePayloads (payloadOnlyTraceOfIntersection intersection) := by
  exact
    tracePayloads_append_excess_eq_value
      intersection.forward.trace
      (formedPositiveExcessOfIntersection intersection)

/-- Dropping the length of a prefix from a one-atom extension returns that atom. -/
theorem drop_length_append_singleton_natTraceAtom
    (pref : List NatTraceAtom)
    (atom : NatTraceAtom) :
    (pref ++ [atom]).drop pref.length = [atom] := by
  induction pref with
  | nil => rfl
  | cons _ rest ih =>
      exact ih

/-- The exact formed interface is separated from its payload-only shadow. -/
theorem formedTraceOfIntersection_ne_payloadOnlyTrace
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    formedTraceOfIntersection intersection =
      payloadOnlyTraceOfIntersection intersection →
        False := by
  intro h
  have hDrop :=
    congrArg
      (fun trace => trace.drop intersection.forward.trace.length)
      h
  unfold formedTraceOfIntersection payloadOnlyTraceOfIntersection at hDrop
  change
    (intersection.forward.trace ++
        [NatTraceAtom.excess
          (formedPositiveExcessOfIntersection intersection)]).drop
        intersection.forward.trace.length =
      (intersection.forward.trace ++
        [NatTraceAtom.value
          (formedPositiveExcessOfIntersection intersection)]).drop
        intersection.forward.trace.length at hDrop
  rw [drop_length_append_singleton_natTraceAtom,
    drop_length_append_singleton_natTraceAtom] at hDrop
  cases hDrop

/--
Diagonal certificate attached to the exact formed intersection interface.

The left side is precisely `formedTraceOfIntersection intersection`; the right
side is its payload-only shadow.
-/
def diagonalCertificateOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    DiagonalCertificate
      (List NatTraceAtom)
      (List Nat)
      tracePayloads where
  left := formedTraceOfIntersection intersection
  right := payloadOnlyTraceOfIntersection intersection
  sameProjection :=
    formedTraceOfIntersection_same_payloadOnlyPayload intersection
  separatedInterface :=
    formedTraceOfIntersection_ne_payloadOnlyTrace intersection

/-- Projection obstruction carried by the exact formed intersection interface. -/
def payloadProjectionObstructionOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ProjectionObstruction
      (List NatTraceAtom)
      (List Nat)
      tracePayloads :=
  projectionObstructionOfDiagonalCertificate
    (diagonalCertificateOfIntersection intersection)


/-! ## Recovery and terminal projection -/

/-- Indexed evidence that recovery restores the hidden formed interface and excess. -/
inductive NatInterfaceRepairEvidence
    (interface : List NatTraceAtom) :
    List Nat -> Nat -> List NatTraceAtom -> Type where
  | repaired :
      NatInterfaceRepairEvidence
        interface
        (tracePayloads interface)
        (traceExcess interface)
        interface

/-- Recovery data for repairing a formed trace after projective loss. -/
structure NatInterfaceRepair
    (interface : List NatTraceAtom) where
  visible : List Nat
  hiddenExcess : Nat
  recovered : List NatTraceAtom
  evidence : NatInterfaceRepairEvidence interface visible hiddenExcess recovered

/--
Intersection-indexed repair evidence.

It records the exact payload-only shadow repaired, the aggregate hidden excess
of the formed interface, the positive terminal excess atom introduced by the
intersection, and the recovered formed interface.
-/
inductive NatIntersectionRepairEvidence
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    List Nat -> Nat -> Nat -> List NatTraceAtom -> List NatTraceAtom -> Type where
  | repaired :
      NatIntersectionRepairEvidence
        intersection
        (tracePayloads (payloadOnlyTraceOfIntersection intersection))
        (traceExcess (formedTraceOfIntersection intersection))
        (formedPositiveExcessOfIntersection intersection)
        (payloadOnlyTraceOfIntersection intersection)
        (formedTraceOfIntersection intersection)

/-- Recovery data tied to the exact formed intersection. -/
structure NatIntersectionRepair
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  visible : List Nat
  hiddenExcess : Nat
  terminalExcess : Nat
  shadow : List NatTraceAtom
  recovered : List NatTraceAtom
  evidence :
    NatIntersectionRepairEvidence
      intersection
      visible
      hiddenExcess
      terminalExcess
      shadow
      recovered

/-- Exact repair of the payload-only shadow back into the formed interface. -/
def natIntersectionRepairOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatIntersectionRepair intersection where
  visible := tracePayloads (payloadOnlyTraceOfIntersection intersection)
  hiddenExcess := traceExcess (formedTraceOfIntersection intersection)
  terminalExcess := formedPositiveExcessOfIntersection intersection
  shadow := payloadOnlyTraceOfIntersection intersection
  recovered := formedTraceOfIntersection intersection
  evidence := NatIntersectionRepairEvidence.repaired

/-- Interface-level repair induced by an exact intersection repair. -/
def natInterfaceRepairOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatInterfaceRepair (formedTraceOfIntersection intersection) where
  visible := tracePayloads (formedTraceOfIntersection intersection)
  hiddenExcess := traceExcess (formedTraceOfIntersection intersection)
  recovered := formedTraceOfIntersection intersection
  evidence := NatInterfaceRepairEvidence.repaired

/-- Abstract local projective recovery instantiated by an exact intersection. -/
def localProjectiveRecoveryOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    LocalProjectiveRecovery
      (List NatTraceAtom)
      (List Nat)
      tracePayloads
      NatInterfaceRepair where
  formed := formedTraceOfIntersection intersection
  shadow := payloadOnlyTraceOfIntersection intersection
  sameProjection :=
    formedTraceOfIntersection_same_payloadOnlyPayload intersection
  separated :=
    formedTraceOfIntersection_ne_payloadOnlyTrace intersection
  repair := natInterfaceRepairOfIntersection intersection
  recovered := formedTraceOfIntersection intersection
  recovered_eq_formed := rfl

/-! ## Referential gap exposed at the Nat-enriched layer -/

/--
The Nat-enriched referential gap generated by a primitive intersection.

It exposes the exact formed interface, its payload-only shadow, the projection
gap between them, and the local repair attached to the formed interface.
Projection obstruction and conservation rejections are derived from this same
local recovery.
-/
structure NatEnrichedReferentialGap
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  localProjectiveRecovery :
    LocalProjectiveRecovery
      (List NatTraceAtom)
      (List Nat)
      tracePayloads
    NatInterfaceRepair
  localProjectiveRecovery_sameInterface :
    localProjectiveRecovery.formed =
      formedTraceOfIntersection intersection
  intersectionRepair :
    NatIntersectionRepair intersection

/-- Projection obstruction carried by the Nat-enriched referential gap. -/
def NatEnrichedReferentialGap.obstruction
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (gap : NatEnrichedReferentialGap intersection) :
    ProjectionObstruction
      (List NatTraceAtom)
      (List Nat)
      tracePayloads :=
  localProjectiveRecovery_obstruction gap.localProjectiveRecovery

/-- The Nat-enriched referential gap refutes projection fiber faithfulness. -/
theorem NatEnrichedReferentialGap.notFiberFaithful
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (gap : NatEnrichedReferentialGap intersection)
    (faithful :
      ProjectionFiberFaithful
        (List NatTraceAtom)
        (List Nat)
        tracePayloads) :
    False :=
  localProjectiveRecovery_notFiberFaithful
    gap.localProjectiveRecovery
    faithful

/-- The Nat-enriched referential gap refutes global projection information conservation. -/
theorem NatEnrichedReferentialGap.notInformationConserving
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (gap : NatEnrichedReferentialGap intersection)
    (conserving :
      ProjectionInformationConserving
        (List NatTraceAtom)
        (List Nat)
        tracePayloads) :
    False :=
  localProjectiveRecovery_notInformationConserving
    gap.localProjectiveRecovery
    conserving

/-- Local truth for a Nat-enriched referential gap: the formed intersection trace. -/
def NatEnrichedReferentialTruth
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (interface : List NatTraceAtom) :
    Prop :=
  interface = formedTraceOfIntersection intersection

/--
The Nat-enriched referential gap is also a local projected-truth recovery: its
formed side is the exact formed intersection trace, while its payload-only
shadow cannot be.
-/
def NatEnrichedReferentialGap.truthGapRecovery
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (gap : NatEnrichedReferentialGap intersection) :
    LocalTruthGapRecovery
      (List NatTraceAtom)
      (List Nat)
      tracePayloads
      NatInterfaceRepair
      (NatEnrichedReferentialTruth intersection) where
  localRecovery := gap.localProjectiveRecovery
  formed_truth := gap.localProjectiveRecovery_sameInterface
  shadow_not_truth := by
    intro hTruth
    exact
      gap.localProjectiveRecovery.separated
        (Eq.trans
          gap.localProjectiveRecovery_sameInterface
          hTruth.symm)

/--
The Nat-enriched referential gap separates local formation from projected local
truth around the same exact formed intersection.
-/
theorem NatEnrichedReferentialGap.localFormationProjectedTruthIndependent
    {branch : MemoryBranch}
    {intersection : PrimitiveMemoryReadingIntersection branch}
    (gap : NatEnrichedReferentialGap intersection) :
    (∃ scene : ReferentialScene (List NatTraceAtom),
      GeometricFormation
        (NatEnrichedReferentialTruth intersection)
        scene ∧
        (ProjectedLocalTruth
          tracePayloads
          (NatEnrichedReferentialTruth intersection)
          scene -> False))
    ∧
    (∃ scene : ReferentialScene (List NatTraceAtom),
      ProjectedLocalTruth
        tracePayloads
        (NatEnrichedReferentialTruth intersection)
        scene ∧
        (GeometricFormation
          (NatEnrichedReferentialTruth intersection)
          scene -> False)) :=
  localTruthGapRecovery_localFormation_projectedTruth_independent
    gap.truthGapRecovery

/-- The exact Nat-enriched referential gap generated by a typed intersection. -/
def natEnrichedReferentialGapOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatEnrichedReferentialGap intersection where
  localProjectiveRecovery :=
    localProjectiveRecoveryOfIntersection intersection
  localProjectiveRecovery_sameInterface := rfl
  intersectionRepair :=
    natIntersectionRepairOfIntersection intersection

/-- Recovery bundle attached to the exact formed intersection interface. -/
def recoveryBundleOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    RecoveryBundle (List NatTraceAtom) NatInterfaceRepair where
  interface :=
    (localProjectiveRecoveryOfIntersection intersection).formed
  repair :=
    (localProjectiveRecoveryOfIntersection intersection).repair

/-- Terminal payload projection attached to the exact formed intersection. -/
def terminalProjectionOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    TerminalProjection
      (List NatTraceAtom)
      (List Nat)
      tracePayloads where
  interface :=
    (localProjectiveRecoveryOfIntersection intersection).formed
  visible :=
    tracePayloads (localProjectiveRecoveryOfIntersection intersection).formed
  projected := rfl

/-- Local package tying obstruction, repair, and projection to one intersection. -/
structure LocalIntersectionRecoveryPackage
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  referentialGap :
    NatEnrichedReferentialGap intersection
  recovery :
    RecoveryBundle (List NatTraceAtom) NatInterfaceRepair
  recovery_sameInterface :
    recovery.interface = formedTraceOfIntersection intersection
  projection :
    TerminalProjection
      (List NatTraceAtom)
      (List Nat)
      tracePayloads
  projection_sameInterface :
    projection.interface = formedTraceOfIntersection intersection

/-- The exact local recovery package generated by a typed intersection. -/
def localIntersectionRecoveryPackage
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    LocalIntersectionRecoveryPackage intersection where
  referentialGap :=
    natEnrichedReferentialGapOfIntersection intersection
  recovery := recoveryBundleOfIntersection intersection
  recovery_sameInterface := rfl
  projection := terminalProjectionOfIntersection intersection
  projection_sameInterface := rfl

/-! ## Nat closed-stability arithmetic instance contract -/

/--
Contract for an arithmetic instance of the enriched Nat closed-stability
theorem.

The instance is not consumed as a raw trajectory.  It is consumed through a
typed branch, a typed intersection, an interface witness realized by the strong
cycle of that intersection, and a local projective recovery attached to the
same formed interface.
-/
structure NatClosedStabilityArithmeticInstance where
  branch : MemoryBranch
  intersection :
    bidirectionalCompleteness.Intersection branch
  formed :
    InterfaceWitness (List NatTraceAtom) NatInterfaceWitness
  formed_sameInterface :
    formed.interface = formedTraceOfIntersection intersection
  realizes :
    NatInterfaceRealization
      (strongClosedStabilityFromIntersectionTheorem
        bidirectionalCompleteness
        enrichedNatRoundTripCoherence
        intersection)
      formed.interface
  localPackage :
    LocalIntersectionRecoveryPackage intersection

/-- Consume an enriched Nat arithmetic instance through the abstract theorem. -/
def natClosedStability_of_arithmeticInstance
    (inst : NatClosedStabilityArithmeticInstance) :
    LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
      bidirectionalCompleteness
      inst.branch
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads
      NatInterfaceRepair :=
    locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem
      bidirectionalCompleteness
      enrichedNatRoundTripCoherence
      inst.intersection
      inst.formed
      inst.realizes
      inst.localPackage.referentialGap.localProjectiveRecovery
      (by
        calc
          inst.localPackage.referentialGap.localProjectiveRecovery.formed =
              formedTraceOfIntersection inst.intersection :=
            inst.localPackage.referentialGap.localProjectiveRecovery_sameInterface
          _ = inst.formed.interface :=
            inst.formed_sameInterface.symm)

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatTraceAtom
#print axioms Meta.EnrichedNatClosedStabilityInstance.MemoryBranch
#print axioms Meta.EnrichedNatClosedStabilityInstance.PrimitiveMemoryReadingIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.formedPositiveExcessOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.primitiveCompleteOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.bidirectionalCompleteness
#print axioms Meta.EnrichedNatClosedStabilityInstance.enrichedNatRoundTripCoherence
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatInterfaceRealization
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatInterfaceWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.payloadProjectionObstructionOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedReferentialGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedReferentialGap.obstruction
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedReferentialGap.notFiberFaithful
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedReferentialGap.notInformationConserving
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedReferentialTruth
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedReferentialGap.truthGapRecovery
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedReferentialGap.localFormationProjectedTruthIndependent
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedReferentialGapOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.LocalIntersectionRecoveryPackage
#print axioms Meta.EnrichedNatClosedStabilityInstance.localIntersectionRecoveryPackage
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatClosedStabilityArithmeticInstance
#print axioms Meta.EnrichedNatClosedStabilityInstance.natClosedStability_of_arithmeticInstance
/- AXIOM_AUDIT_END -/
