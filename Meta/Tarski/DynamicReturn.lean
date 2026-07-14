import Meta.Core.OrderGap
import Meta.Tarski.ReferentialOrder

/-!
# Tarski diagonal dynamic return

This file internalizes the production of the Tarski diagonal gap as a formed
dynamic return.

The source is not the already-produced gap.  It is the pair of diagonal data
which produces the gap:

* a diagonal fixed point;
* an exact projected truth definition.

The typed intersection remembers that source and carries the obstruction
computed from it.  The resulting locally recovered dynamic return then consumes
the abstract dynamic Core.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u

/-! ## Diagonal source data -/

/--
Source data for the Tarski diagonal return.

This is the complete candidate datum refuted by Tarski: a diagonal fixed point
together with an exact projected truth definition.  Its purpose is not to be an
autonomous coherent state; it is the typed input from which the internal
obstruction is extracted.
-/
structure TarskiDiagonalReturnSource
    (Sentence : Type u)
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) where
  fixedPoint :
    TarskiDiagonalFixedPoint Sentence TruthAt Holds
  projectedDefinition :
    ExactProjectedTruthDefinition
      (@TarskiInterface.project Sentence)
      (TarskiInterface.truth TruthAt Holds)
      TruthAt

/--
The backward visible truth-definition datum as a genuine type.

`ExactProjectedTruthDefinition` is a proposition; the marker keeps this package
in `Type`, so it can serve as the `Backward` component of a dynamic
completeness structure.
-/
structure TarskiProjectedDefinitionData
    (Sentence : Type u)
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) where
  marker : Unit := ()
  projectedDefinition :
    ExactProjectedTruthDefinition
      (@TarskiInterface.project Sentence)
      (TarskiInterface.truth TruthAt Holds)
      TruthAt

/-! ## Diagonal branch and intersection -/

/-- The dynamic branch for a fixed Tarski diagonal context. -/
inductive TarskiDynamicBranch
    (Sentence : Type u)
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) where
  | diagonal : TarskiDynamicBranch Sentence TruthAt Holds

/-- The obstruction produced by a diagonal return source. -/
def tarskiProducedObstruction
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    TarskiDiagonalObstruction
      Sentence
      (TarskiInterface Sentence)
      (@TarskiInterface.project Sentence)
      (TarskiInterface.truth TruthAt Holds) :=
  TarskiDiagonalObstruction.ofFixedPointAndExactProjectedTruthDefinition
    source.fixedPoint
    source.projectedDefinition

/--
The complete Tarski return source is refuted by consuming the obstruction it
constructively produces.
-/
theorem tarskiDiagonalReturnSource_refuted
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    False :=
  TarskiDiagonalObstruction.exactProjectedTruthDefinition_refutedByProjectiveCorollary
    source.fixedPoint
    source.projectedDefinition

/-! ## Causal trace of the diagonal production -/

/--
The causal trace by which a complete candidate Tarski source produces its
oriented projective obstruction.

This is not a closed contradiction: it stores the local arrows and the produced
gap, while the refutation of the source is a separate theorem consuming
`obstruction`.
-/
structure TarskiCausalTrace
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) where
  index : Sentence
  index_eq_liar :
    index = source.fixedPoint.liar
  formed : TarskiInterface Sentence
  shadow : TarskiInterface Sentence
  formed_is_semantic :
    formed = TarskiInterface.semantic index
  shadow_is_syntactic :
    shadow = TarskiInterface.syntactic index
  formed_projects :
    (@TarskiInterface.project Sentence) formed = index
  shadow_projects :
    (@TarskiInterface.project Sentence) shadow = index
  sameSyntax :
    (@TarskiInterface.project Sentence) formed =
      (@TarskiInterface.project Sentence) shadow
  candidate_correct_at_formed :
    TruthAt index ↔ TarskiInterface.truth TruthAt Holds formed
  candidate_correct_at_shadow :
    TruthAt index ↔ TarskiInterface.truth TruthAt Holds shadow
  truth_to_holds :
    TruthAt index -> Holds index
  holds_to_not_truth :
    Holds index -> TruthAt index -> False
  shadow_not_truth :
    TarskiInterface.truth TruthAt Holds shadow -> False
  truth_formed :
    TarskiInterface.truth TruthAt Holds formed
  separated :
    formed = shadow -> False
  obstruction :
    TarskiDiagonalObstruction
      Sentence
      (TarskiInterface Sentence)
      (@TarskiInterface.project Sentence)
      (TarskiInterface.truth TruthAt Holds)
  obstruction_eq_reconstructed :
    obstruction =
      { formed := formed
        shadow := shadow
        sameSyntax := sameSyntax
        truth_formed := truth_formed
        shadow_not_truth := shadow_not_truth }
  obstruction_eq :
    obstruction = tarskiProducedObstruction source

/--
The fixed-point law transported to the explicit index of a causal trace.
-/
def TarskiCausalTrace.fixedPointSpec
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds}
    (trace : TarskiCausalTrace source) :
    Holds trace.index ↔ (TruthAt trace.index -> False) := by
  rw [trace.index_eq_liar]
  exact source.fixedPoint.liar_spec

/-- The trace as a fixed point located at its explicit index. -/
def TarskiCausalTrace.fixedPoint
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds}
    (trace : TarskiCausalTrace source) :
    TarskiDiagonalFixedPoint Sentence TruthAt Holds where
  liar := trace.index
  liar_spec := trace.fixedPointSpec

/-- The obstruction carried by the trace. -/
def TarskiCausalTrace.toObstruction
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds}
    (trace : TarskiCausalTrace source) :
    TarskiDiagonalObstruction
      Sentence
      (TarskiInterface Sentence)
      (@TarskiInterface.project Sentence)
      (TarskiInterface.truth TruthAt Holds) :=
  trace.obstruction

/--
The trace obstruction is reconstructed from the trace's own local fields.
-/
theorem TarskiCausalTrace.toObstruction_eq_reconstructed
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds}
    (trace : TarskiCausalTrace source) :
    trace.toObstruction =
      { formed := trace.formed
        shadow := trace.shadow
        sameSyntax := trace.sameSyntax
        truth_formed := trace.truth_formed
        shadow_not_truth := trace.shadow_not_truth } :=
  trace.obstruction_eq_reconstructed

/-- The trace obstruction is the canonical obstruction produced by the source. -/
theorem TarskiCausalTrace.toObstruction_eq_produced
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds}
    (trace : TarskiCausalTrace source) :
    trace.toObstruction = tarskiProducedObstruction source :=
  trace.obstruction_eq

/-- The positive diagonal view carried by a causal trace. -/
def TarskiCausalTrace.toPositiveDiagonal
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds}
    (trace : TarskiCausalTrace source) :
    TarskiPositiveDiagonal Sentence TruthAt Holds where
  index := trace.index
  formed := trace.formed
  shadow := trace.shadow
  formed_is_semantic := trace.formed_is_semantic
  shadow_is_syntactic := trace.shadow_is_syntactic
  formed_projects := trace.formed_projects
  shadow_projects := trace.shadow_projects
  separated := trace.separated
  fixedPointSpec := trace.fixedPointSpec
  mismatch := tarski_local_mismatch trace.fixedPoint

/-- The local mismatch obtained by forgetting the oriented truth gap. -/
def TarskiCausalTrace.toLocalTruthMismatch
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds}
    (trace : TarskiCausalTrace source) :
    LocalTruthMismatch Sentence TruthAt Holds :=
  trace.toPositiveDiagonal.localTruthMismatch

/--
Canonical causal trace produced by a complete Tarski return source.

The construction follows the internal causal order: candidate correctness gives
`TruthAt -> Holds`; the fixed point turns `Holds` into `not TruthAt`; this
produces the oriented gap.  No terminal refutation theorem is used here.
-/
def tarskiCausalTraceOfSource
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    TarskiCausalTrace source := by
  let index := source.fixedPoint.liar
  let formed := TarskiInterface.semantic index
  let shadow := TarskiInterface.syntactic index
  have candidate_correct_at_formed :
      TruthAt index ↔ TarskiInterface.truth TruthAt Holds formed :=
    source.projectedDefinition.correct formed
  have candidate_correct_at_shadow :
      TruthAt index ↔ TarskiInterface.truth TruthAt Holds shadow :=
    source.projectedDefinition.correct shadow
  have truth_to_holds :
      TruthAt index -> Holds index :=
    candidate_correct_at_formed.mp
  have holds_to_not_truth :
      Holds index -> TruthAt index -> False :=
    source.fixedPoint.liar_spec.mp
  have shadow_not_truth :
      TarskiInterface.truth TruthAt Holds shadow -> False := by
    intro hTruth
    exact holds_to_not_truth (truth_to_holds hTruth) hTruth
  have truth_formed :
      TarskiInterface.truth TruthAt Holds formed :=
    source.fixedPoint.liar_spec.mpr shadow_not_truth
  exact
    { index := index
      index_eq_liar := rfl
      formed := formed
      shadow := shadow
      formed_is_semantic := rfl
      shadow_is_syntactic := rfl
      formed_projects := rfl
      shadow_projects := rfl
      sameSyntax := rfl
      candidate_correct_at_formed := candidate_correct_at_formed
      candidate_correct_at_shadow := candidate_correct_at_shadow
      truth_to_holds := truth_to_holds
      holds_to_not_truth := holds_to_not_truth
      shadow_not_truth := shadow_not_truth
      truth_formed := truth_formed
      separated := by
        change TarskiInterface.semantic index = TarskiInterface.syntactic index ->
          False
        intro hEq
        cases hEq
      obstruction :=
        { formed := formed
          shadow := shadow
          sameSyntax := rfl
          truth_formed := truth_formed
          shadow_not_truth := shadow_not_truth }
      obstruction_eq_reconstructed := rfl
      obstruction_eq := rfl }

/--
The causal refutation of a Tarski source consumes the obstruction carried by
the trace.  This is the terminal step; it is not used to construct the trace.
-/
theorem tarskiCausalTrace_refutesSource
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds}
    (trace : TarskiCausalTrace source) :
    False :=
  TarskiDiagonalObstruction.notProjectedTruthDefinable
    trace.obstruction
    { truthAt := TruthAt
      correct := source.projectedDefinition.correct }

/--
Typed diagonal intersection.

It carries the obstruction together with the certificate that this obstruction
is the one produced by the source.
-/
structure TarskiDiagonalIntersection
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) where
  obstruction :
    TarskiDiagonalObstruction
      Sentence
      (TarskiInterface Sentence)
      (@TarskiInterface.project Sentence)
      (TarskiInterface.truth TruthAt Holds)
  obstruction_eq :
    obstruction = tarskiProducedObstruction source

/-- The canonical intersection produced by a diagonal return source. -/
def tarskiDiagonalIntersectionOfSource
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    TarskiDiagonalIntersection source where
  obstruction := tarskiProducedObstruction source
  obstruction_eq := rfl

/--
Any intersection over the same source is propositionally the canonical
intersection produced from that source.
-/
theorem tarskiIntersectionCanonical
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds}
    (intersection : TarskiDiagonalIntersection source) :
    tarskiDiagonalIntersectionOfSource source = intersection := by
  cases intersection with
  | mk obstruction obstruction_eq =>
      cases obstruction_eq
      rfl

/-! ## Dynamic completeness for the diagonal return -/

/-- Bidirectional completeness for the Tarski diagonal return. -/
def tarskiBidirectionalCompleteness
    (Sentence : Type u)
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) :
    BidirectionalCompleteness
      (TarskiDynamicBranch Sentence TruthAt Holds) where
  Complete _ :=
    TarskiDiagonalReturnSource Sentence TruthAt Holds
  Forward _ :=
    TarskiDiagonalFixedPoint Sentence TruthAt Holds
  Backward _ :=
    ULift.{u, 0}
      (TarskiProjectedDefinitionData Sentence TruthAt Holds)
  Intersection _ :=
    Sigma fun source =>
      TarskiDiagonalIntersection source
  forwardOfComplete _ source :=
    source.fixedPoint
  backwardOfComplete _ source :=
    ULift.up
      { marker := ()
        projectedDefinition := source.projectedDefinition }
  intersectionOfComplete _ source :=
    ⟨source, tarskiDiagonalIntersectionOfSource source⟩
  completeOfIntersection _ intersection :=
    intersection.1

/-- Round-trip coherence for the Tarski diagonal return. -/
def tarskiRoundTripCoherence
    (Sentence : Type u)
    (TruthAt : Sentence -> Prop)
    (Holds : Sentence -> Prop) :
    RoundTripCoherence
      (tarskiBidirectionalCompleteness Sentence TruthAt Holds) where
  completeRoundTrip := {
    complete_stable := by
      intro _branch _source
      rfl
  }
  intersectionRoundTrip := {
    intersection_stable := by
      intro _branch intersection
      cases intersection with
      | mk source intersection =>
          change
            (⟨source, tarskiDiagonalIntersectionOfSource source⟩ :
              Sigma fun source =>
                TarskiDiagonalIntersection source) =
              ⟨source, intersection⟩
          cases tarskiIntersectionCanonical intersection
          rfl
  }

/-! ## Formed diagonal interface -/

/-- Minimal witness family for the formed Tarski dynamic interface. -/
def TarskiDynamicWitness
    {Sentence : Type u}
    (_interface : TarskiInterface Sentence) :
    Type :=
  Unit

/-- The formed semantic interface extracted from a diagonal source. -/
def tarskiDynamicInterfaceWitness
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    InterfaceWitness
      (TarskiInterface Sentence)
      (@TarskiDynamicWitness Sentence) where
  interface := TarskiInterface.semantic source.fixedPoint.liar
  witness := ()

/--
The dynamic cycle realizes the semantic liar interface of its source
intersection.

The equality is packaged as data so it can inhabit the typed
`RealizesInterface` slot used by the dynamic core.
-/
structure TarskiDynamicInterfaceRealization
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (cycle :
      StrongTerminalCycleFromIntersection
        (tarskiBidirectionalCompleteness Sentence TruthAt Holds)
        TarskiDynamicBranch.diagonal)
    (interface : TarskiInterface Sentence) :
    Type where
  marker : Unit := ()
  realizes :
    interface =
    TarskiInterface.semantic cycle.sourceIntersection.1.fixedPoint.liar

/-! ## Causal witness and repair -/

/--
Non-trivial dynamic witness for the causal Tarski interface.

It carries the whole causal trace and identifies the witnessed interface with
the trace's formed semantic pole.
-/
structure TarskiCausalDynamicWitness
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds)
    (interface : TarskiInterface Sentence) :
    Type u where
  trace : TarskiCausalTrace source
  interface_eq_formed :
    interface = trace.formed

/-- The formed semantic interface with its causal witness. -/
def tarskiCausalDynamicInterfaceWitness
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    InterfaceWitness
      (TarskiInterface Sentence)
      (TarskiCausalDynamicWitness source) :=
  let trace := tarskiCausalTraceOfSource source
  { interface := trace.formed
    witness :=
      { trace := trace
        interface_eq_formed := rfl } }

/--
Non-trivial local repair for the causal Tarski return.

This is not a global patch of `TruthAt`.  It records that the recovered local
interface is the formed semantic pole produced by the trace, and carries the
formed truth already produced by that trace.
-/
structure TarskiCausalRepair
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds)
    (interface : TarskiInterface Sentence) :
    Type u where
  trace : TarskiCausalTrace source
  repairs_formed :
    interface = trace.formed
  recovered : TarskiInterface Sentence
  recovered_eq_formed :
    recovered = trace.formed
  carries_truth_formed :
    TarskiInterface.truth TruthAt Holds recovered

/-- The causal repair attached to the formed pole of a trace. -/
def tarskiCausalRepairOfTrace
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds}
    (trace : TarskiCausalTrace source) :
    TarskiCausalRepair source trace.formed where
  trace := trace
  repairs_formed := rfl
  recovered := trace.formed
  recovered_eq_formed := rfl
  carries_truth_formed := trace.truth_formed

/-- The local projective recovery carried by the causal trace. -/
def tarskiCausalLocalRecovery
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    LocalProjectiveRecovery
      (TarskiInterface Sentence)
      Sentence
      (@TarskiInterface.project Sentence)
      (TarskiCausalRepair source) :=
  let trace := tarskiCausalTraceOfSource source
  { formed := trace.formed
    shadow := trace.shadow
    sameProjection := trace.sameSyntax
    separated := trace.separated
    repair := tarskiCausalRepairOfTrace trace
    recovered := trace.formed
    recovered_eq_formed := rfl }

/-! ## Formed and locally recovered dynamic returns -/

/-- The Tarski diagonal source as a formed dynamic return. -/
def tarskiFormedDynamicReturn
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    FormedDynamicReturn
      (tarskiBidirectionalCompleteness Sentence TruthAt Holds)
      TarskiDynamicBranch.diagonal
      (TarskiDiagonalReturnSource Sentence TruthAt Holds) where
  source := source
  intersection := ⟨source, tarskiDiagonalIntersectionOfSource source⟩

/-- The Tarski diagonal source as a locally recovered dynamic return. -/
def tarskiLocallyRecoveredDynamicReturn
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    LocallyRecoveredDynamicReturn
      (tarskiBidirectionalCompleteness Sentence TruthAt Holds)
      (tarskiRoundTripCoherence Sentence TruthAt Holds)
      TarskiDynamicBranch.diagonal
      (TarskiDiagonalReturnSource Sentence TruthAt Holds)
      (TarskiInterface Sentence)
      (@TarskiDynamicWitness Sentence)
      TarskiDynamicInterfaceRealization
      Sentence
      (@TarskiInterface.project Sentence)
      (@TarskiTruthRepair (TarskiInterface Sentence)) where
  formedReturn := tarskiFormedDynamicReturn source
  formed := tarskiDynamicInterfaceWitness source
  realizes := { marker := (), realizes := rfl }
  localRecovery := (tarskiProducedObstruction source).localRecovery
  localRecovery_sameInterface := rfl

/-- The closed-stability package recovered from the Tarski dynamic return. -/
def tarskiLocallyRecoveredClosedStabilityOfDynamicReturn
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
      (tarskiBidirectionalCompleteness Sentence TruthAt Holds)
      TarskiDynamicBranch.diagonal
      (TarskiInterface Sentence)
      (@TarskiDynamicWitness Sentence)
      TarskiDynamicInterfaceRealization
      Sentence
      (@TarskiInterface.project Sentence)
      (@TarskiTruthRepair (TarskiInterface Sentence)) :=
  locallyRecoveredClosedStabilityOfDynamicReturn
    (tarskiLocallyRecoveredDynamicReturn source)

/--
The Tarski diagonal source as a causally recovered dynamic return.

Unlike the compatibility return above, the witness and repair here both carry
the causal trace that produces the oriented Tarski gap.
-/
def tarskiCausalLocallyRecoveredDynamicReturn
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    LocallyRecoveredDynamicReturn
      (tarskiBidirectionalCompleteness Sentence TruthAt Holds)
      (tarskiRoundTripCoherence Sentence TruthAt Holds)
      TarskiDynamicBranch.diagonal
      (TarskiDiagonalReturnSource Sentence TruthAt Holds)
      (TarskiInterface Sentence)
      (TarskiCausalDynamicWitness source)
      TarskiDynamicInterfaceRealization
      Sentence
      (@TarskiInterface.project Sentence)
      (TarskiCausalRepair source) where
  formedReturn := tarskiFormedDynamicReturn source
  formed := tarskiCausalDynamicInterfaceWitness source
  realizes := { marker := (), realizes := rfl }
  localRecovery := tarskiCausalLocalRecovery source
  localRecovery_sameInterface := rfl

/-- The closed-stability package recovered from the causal Tarski return. -/
def tarskiCausalLocallyRecoveredClosedStabilityOfDynamicReturn
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
      (tarskiBidirectionalCompleteness Sentence TruthAt Holds)
      TarskiDynamicBranch.diagonal
      (TarskiInterface Sentence)
      (TarskiCausalDynamicWitness source)
      TarskiDynamicInterfaceRealization
      Sentence
      (@TarskiInterface.project Sentence)
      (TarskiCausalRepair source) :=
  locallyRecoveredClosedStabilityOfDynamicReturn
    (tarskiCausalLocallyRecoveredDynamicReturn source)

/-! ## Gap, order, and length consequences of the dynamic return -/

/-- The operational gap carried by the Tarski dynamic return. -/
def tarskiDynamicReturn_operationalGap
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    OperationalReferentialGap
      (TarskiInterface Sentence)
      Sentence
      (@TarskiInterface.project Sentence)
      (@TarskiTruthRepair (TarskiInterface Sentence)) :=
  dynamicReturn_operationalGap
    (tarskiLocallyRecoveredDynamicReturn source)

/-- The structural gap carried by the Tarski dynamic return. -/
def tarskiDynamicReturn_structuralGap
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    StructuralReferentialGap
      (TarskiInterface Sentence)
      Sentence
      (@TarskiInterface.project Sentence) :=
  dynamicReturn_structuralGap
    (tarskiLocallyRecoveredDynamicReturn source)

/-- The Tarski dynamic return yields visible-order equivalence. -/
theorem tarskiDynamicReturn_visibleOrderEquivalent
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (order : VisiblePreorder Sentence)
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    VisibleOrderEquivalent
      order
      ((@TarskiInterface.project Sentence)
        (tarskiLocallyRecoveredDynamicReturn source).localRecovery.formed)
      ((@TarskiInterface.project Sentence)
        (tarskiLocallyRecoveredDynamicReturn source).localRecovery.shadow) :=
  dynamicReturn_visibleOrderEquivalent
    order
    (tarskiLocallyRecoveredDynamicReturn source)

/-- In a visible partial order, the dynamic Tarski return has equal projections. -/
theorem tarskiDynamicReturn_visible_eq_of_partialOrder
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (order : VisiblePartialOrder Sentence)
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    (@TarskiInterface.project Sentence)
        (tarskiLocallyRecoveredDynamicReturn source).localRecovery.formed =
      (@TarskiInterface.project Sentence)
        (tarskiLocallyRecoveredDynamicReturn source).localRecovery.shadow :=
  dynamicReturn_visible_eq_of_partialOrder
    order
    (tarskiLocallyRecoveredDynamicReturn source)

/--
In a visible partial order, the dynamic Tarski return has equal projections
while its formed interface and shadow remain separated.
-/
theorem tarskiDynamicReturn_partialOrder_visible_eq_not_interface_eq
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (order : VisiblePartialOrder Sentence)
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    (@TarskiInterface.project Sentence)
        (tarskiLocallyRecoveredDynamicReturn source).localRecovery.formed =
        (@TarskiInterface.project Sentence)
          (tarskiLocallyRecoveredDynamicReturn source).localRecovery.shadow ∧
      ((tarskiLocallyRecoveredDynamicReturn source).localRecovery.formed =
          (tarskiLocallyRecoveredDynamicReturn source).localRecovery.shadow ->
            False) :=
  dynamicReturn_partialOrder_visible_eq_not_interface_eq
    order
    (tarskiLocallyRecoveredDynamicReturn source)

/-- The Tarski dynamic return refutes ordered contraction. -/
theorem tarskiDynamicReturn_notOrderContractive
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {order : VisiblePreorder Sentence}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds)
    (contractive :
      OrderContractiveProjection
        (TarskiInterface Sentence)
        Sentence
        (@TarskiInterface.project Sentence)
        order) :
    False :=
  dynamicReturn_not_orderContractive
    (tarskiLocallyRecoveredDynamicReturn source)
    contractive

/-- The Tarski dynamic return refutes the short referential presentation. -/
theorem tarskiDynamicReturn_refutesShortPresentation
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds)
    (short :
      ShortReferentialPresentation
        (TarskiInterface Sentence)
        Sentence
        (@TarskiInterface.project Sentence)) :
    False :=
  dynamicReturn_refutes_shortReferentialPresentation
    (tarskiLocallyRecoveredDynamicReturn source)
    short

/-! ## Causal gap, order, and length consequences -/

/-- The operational gap carried by the causal Tarski dynamic return. -/
def tarskiCausalDynamicReturn_operationalGap
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    OperationalReferentialGap
      (TarskiInterface Sentence)
      Sentence
      (@TarskiInterface.project Sentence)
      (TarskiCausalRepair source) :=
  dynamicReturn_operationalGap
    (tarskiCausalLocallyRecoveredDynamicReturn source)

/-- The structural gap carried by the causal Tarski dynamic return. -/
def tarskiCausalDynamicReturn_structuralGap
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    StructuralReferentialGap
      (TarskiInterface Sentence)
      Sentence
      (@TarskiInterface.project Sentence) :=
  dynamicReturn_structuralGap
    (tarskiCausalLocallyRecoveredDynamicReturn source)

/-- The causal dynamic return yields visible-order equivalence. -/
theorem tarskiCausalDynamicReturn_visibleOrderEquivalent
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (order : VisiblePreorder Sentence)
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    VisibleOrderEquivalent
      order
      ((@TarskiInterface.project Sentence)
        (tarskiCausalLocallyRecoveredDynamicReturn source).localRecovery.formed)
      ((@TarskiInterface.project Sentence)
        (tarskiCausalLocallyRecoveredDynamicReturn source).localRecovery.shadow) :=
  dynamicReturn_visibleOrderEquivalent
    order
    (tarskiCausalLocallyRecoveredDynamicReturn source)

/-- In a visible partial order, the causal return has equal projections. -/
theorem tarskiCausalDynamicReturn_visible_eq_of_partialOrder
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (order : VisiblePartialOrder Sentence)
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    (@TarskiInterface.project Sentence)
        (tarskiCausalLocallyRecoveredDynamicReturn source).localRecovery.formed =
      (@TarskiInterface.project Sentence)
        (tarskiCausalLocallyRecoveredDynamicReturn source).localRecovery.shadow :=
  dynamicReturn_visible_eq_of_partialOrder
    order
    (tarskiCausalLocallyRecoveredDynamicReturn source)

/--
In a visible partial order, the causal return has equal projections while its
formed interface and shadow remain separated.
-/
theorem tarskiCausalDynamicReturn_partialOrder_visible_eq_not_interface_eq
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (order : VisiblePartialOrder Sentence)
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    (@TarskiInterface.project Sentence)
        (tarskiCausalLocallyRecoveredDynamicReturn source).localRecovery.formed =
        (@TarskiInterface.project Sentence)
          (tarskiCausalLocallyRecoveredDynamicReturn source).localRecovery.shadow ∧
      ((tarskiCausalLocallyRecoveredDynamicReturn source).localRecovery.formed =
          (tarskiCausalLocallyRecoveredDynamicReturn source).localRecovery.shadow ->
            False) :=
  dynamicReturn_partialOrder_visible_eq_not_interface_eq
    order
    (tarskiCausalLocallyRecoveredDynamicReturn source)

/-- The causal Tarski dynamic return refutes ordered contraction. -/
theorem tarskiCausalDynamicReturn_notOrderContractive
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    {order : VisiblePreorder Sentence}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds)
    (contractive :
      OrderContractiveProjection
        (TarskiInterface Sentence)
        Sentence
        (@TarskiInterface.project Sentence)
        order) :
    False :=
  dynamicReturn_not_orderContractive
    (tarskiCausalLocallyRecoveredDynamicReturn source)
    contractive

/-- The causal Tarski dynamic return refutes short presentation. -/
theorem tarskiCausalDynamicReturn_refutesShortPresentation
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds)
    (short :
      ShortReferentialPresentation
        (TarskiInterface Sentence)
        Sentence
        (@TarskiInterface.project Sentence)) :
    False :=
  dynamicReturn_refutes_shortReferentialPresentation
    (tarskiCausalLocallyRecoveredDynamicReturn source)
    short

/-- The causal operational gap rules out uniform syntactic reconstruction. -/
def tarskiCausalDynamicReturn_noProjectiveReconstruction
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    ((recover : Sentence -> TarskiInterface Sentence) ->
      ((interface : TarskiInterface Sentence) ->
        recover ((@TarskiInterface.project Sentence) interface) = interface) ->
          False) :=
  noProjectiveReconstructionOfOperationalGap
    (tarskiCausalDynamicReturn_operationalGap source)

/--
Terminal refutation of a source through the canonical causal trace it produces.
-/
theorem tarskiCausalDynamicReturn_refutesSource
    {Sentence : Type u}
    {TruthAt : Sentence -> Prop}
    {Holds : Sentence -> Prop}
    (source :
      TarskiDiagonalReturnSource Sentence TruthAt Holds) :
    False :=
  tarskiCausalTrace_refutesSource
    (tarskiCausalTraceOfSource source)

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalReturnSource
#print axioms Meta.ClosedStabilityTheorem.TarskiProjectedDefinitionData
#print axioms Meta.ClosedStabilityTheorem.tarskiProducedObstruction
#print axioms Meta.ClosedStabilityTheorem.tarskiDiagonalReturnSource_refuted
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalTrace
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalTrace.fixedPointSpec
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalTrace.fixedPoint
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalTrace.toObstruction
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalTrace.toObstruction_eq_reconstructed
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalTrace.toObstruction_eq_produced
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalTrace.toPositiveDiagonal
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalTrace.toLocalTruthMismatch
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalTraceOfSource
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalTrace_refutesSource
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalIntersection
#print axioms Meta.ClosedStabilityTheorem.tarskiDiagonalIntersectionOfSource
#print axioms Meta.ClosedStabilityTheorem.tarskiIntersectionCanonical
#print axioms Meta.ClosedStabilityTheorem.tarskiBidirectionalCompleteness
#print axioms Meta.ClosedStabilityTheorem.tarskiRoundTripCoherence
#print axioms Meta.ClosedStabilityTheorem.TarskiDynamicWitness
#print axioms Meta.ClosedStabilityTheorem.TarskiDynamicInterfaceRealization
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalDynamicWitness
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalDynamicInterfaceWitness
#print axioms Meta.ClosedStabilityTheorem.TarskiCausalRepair
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalRepairOfTrace
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalLocalRecovery
#print axioms Meta.ClosedStabilityTheorem.tarskiFormedDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.tarskiLocallyRecoveredDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.tarskiLocallyRecoveredClosedStabilityOfDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalLocallyRecoveredDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalLocallyRecoveredClosedStabilityOfDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_operationalGap
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_structuralGap
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_visibleOrderEquivalent
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_visible_eq_of_partialOrder
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_partialOrder_visible_eq_not_interface_eq
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_notOrderContractive
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_refutesShortPresentation
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalDynamicReturn_operationalGap
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalDynamicReturn_structuralGap
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalDynamicReturn_visibleOrderEquivalent
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalDynamicReturn_visible_eq_of_partialOrder
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalDynamicReturn_partialOrder_visible_eq_not_interface_eq
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalDynamicReturn_notOrderContractive
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalDynamicReturn_refutesShortPresentation
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalDynamicReturn_noProjectiveReconstruction
#print axioms Meta.ClosedStabilityTheorem.tarskiCausalDynamicReturn_refutesSource
/- AXIOM_AUDIT_END -/
