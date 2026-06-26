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

This is the productive diagonal datum, before the Tarski obstruction is
extracted from it.
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
          simp
            [ intersectionOfComplete
            , completeOfIntersection
            , tarskiBidirectionalCompleteness
            , tarskiIntersectionCanonical intersection ]
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

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalReturnSource
#print axioms Meta.ClosedStabilityTheorem.TarskiProjectedDefinitionData
#print axioms Meta.ClosedStabilityTheorem.tarskiProducedObstruction
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalIntersection
#print axioms Meta.ClosedStabilityTheorem.tarskiDiagonalIntersectionOfSource
#print axioms Meta.ClosedStabilityTheorem.tarskiIntersectionCanonical
#print axioms Meta.ClosedStabilityTheorem.tarskiBidirectionalCompleteness
#print axioms Meta.ClosedStabilityTheorem.tarskiRoundTripCoherence
#print axioms Meta.ClosedStabilityTheorem.TarskiDynamicWitness
#print axioms Meta.ClosedStabilityTheorem.TarskiDynamicInterfaceRealization
#print axioms Meta.ClosedStabilityTheorem.tarskiFormedDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.tarskiLocallyRecoveredDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.tarskiLocallyRecoveredClosedStabilityOfDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_operationalGap
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_structuralGap
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_visibleOrderEquivalent
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_visible_eq_of_partialOrder
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_partialOrder_visible_eq_not_interface_eq
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_notOrderContractive
#print axioms Meta.ClosedStabilityTheorem.tarskiDynamicReturn_refutesShortPresentation
/- AXIOM_AUDIT_END -/
