import Meta.Core.ReferentialLength
import Meta.Core.DynamicTwoPole

/-!
# Ordered projection gaps

This file is the Core factor for the ordered visible test of a gap.

It contains, in one place:

* visible order data;
* order-contractive projections;
* structural and operational order consequences;
* dynamic-return order consequences.

The order layer is not a separate theory of order.  It is the visible-order
test of the gap framework.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s a

/-! ## Visible order data -/

/--
Visible preorder data.

This avoids importing a concrete order library into the core.  The only
intended role is structural: comparison lives on the visible referential.
-/
structure VisiblePreorder (Visible : Type v) : Type v where
  le : Visible -> Visible -> Prop
  refl : forall visible : Visible, le visible visible
  trans :
    forall left middle right : Visible,
      le left middle ->
      le middle right ->
        le left right

/-- Visible partial order data. -/
structure VisiblePartialOrder (Visible : Type v) extends
    VisiblePreorder Visible where
  antisymm :
    forall left right : Visible,
      le left right ->
      le right left ->
        left = right

/-- Visible total order data. -/
structure VisibleTotalOrder (Visible : Type v) extends
    VisiblePartialOrder Visible where
  total :
    forall left right : Visible,
      Or (le left right) (le right left)

/-- Compatibility name for the visible order layer. -/
abbrev VisibleOrder (Visible : Type v) : Type v :=
  VisiblePreorder Visible

/-! ## Visible order equivalence -/

/-- Mutual comparability in a visible preorder. -/
def VisibleOrderEquivalent
    {Visible : Type v}
    (order : VisiblePreorder Visible)
    (left right : Visible) :
    Prop :=
  And (order.le left right) (order.le right left)

/-- Visible order equivalence is reflexive. -/
theorem visibleOrderEquivalent_refl
    {Visible : Type v}
    (order : VisiblePreorder Visible)
    (visible : Visible) :
    VisibleOrderEquivalent order visible visible :=
  And.intro (order.refl visible) (order.refl visible)

/-- A visible partial order contracts mutual comparability to visible equality. -/
theorem visible_eq_of_visibleOrderEquivalent
    {Visible : Type v}
    (order : VisiblePartialOrder Visible)
    {left right : Visible}
    (equivalent :
      VisibleOrderEquivalent order.toVisiblePreorder left right) :
    left = right :=
  order.antisymm left right equivalent.left equivalent.right

/-! ## Order-contractive projections -/

/--
An order-contractive projection.

This is the short ordered reading: if two interfaces have projected values that
are mutually comparable in the visible preorder, then the interfaces are
identified.
-/
abbrev OrderContractiveProjection
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (order : VisiblePreorder Visible) :
    Prop :=
  forall left right : Interface,
    order.le (project left) (project right) ->
    order.le (project right) (project left) ->
      left = right

/--
An order-contractive projection is projection-fiber faithful.

This is the first bridge back to the core: if mutual visible comparison is
already enough to identify interfaces, then equal visible projection is enough
too.
-/
theorem projectionFiberFaithful_of_orderContractive
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePreorder Visible)
    (contractive :
      OrderContractiveProjection Interface Visible project order) :
    ProjectionFiberFaithful Interface Visible project := by
  refine { preserves := ?_ }
  intro left right sameProjection
  exact
    contractive
      left
      right
      (by
        rw [sameProjection]
        exact order.refl (project right))
      (by
        rw [<- sameProjection]
        exact order.refl (project left))

/--
Over a visible partial order, projection-fiber faithfulness is order
contractiveness.

Mutual visible comparison contracts to visible equality, and fiber faithfulness
lifts that visible equality back to interface equality.
-/
theorem orderContractive_of_projectionFiberFaithful
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePartialOrder Visible)
    (faithful :
      ProjectionFiberFaithful Interface Visible project) :
    OrderContractiveProjection
      Interface
      Visible
      project
      order.toVisiblePreorder := by
  intro left right left_le_right right_le_left
  exact
    faithful.preserves
      left
      right
      (order.antisymm
        (project left)
        (project right)
        left_le_right
        right_le_left)

/--
Over a visible partial order, order contractiveness and projection-fiber
faithfulness are equivalent.
-/
theorem orderContractive_iff_projectionFiberFaithful
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePartialOrder Visible) :
    OrderContractiveProjection
      Interface
      Visible
      project
      order.toVisiblePreorder
      <->
    ProjectionFiberFaithful Interface Visible project :=
  Iff.intro
    (projectionFiberFaithful_of_orderContractive order.toVisiblePreorder)
    (orderContractive_of_projectionFiberFaithful order)

/--
Over a visible partial order, order contractiveness is exactly the
contractible-gap regime.

This is the gap-level reading of the order test: forcing mutual visible
comparison to identify interfaces is precisely the short `gap = 0` regime.
-/
theorem orderContractive_iff_contractibleReferentialGap
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePartialOrder Visible) :
    OrderContractiveProjection
      Interface
      Visible
      project
      order.toVisiblePreorder
      <->
    ContractibleReferentialGap Interface Visible project :=
  orderContractive_iff_projectionFiberFaithful order

/--
Over a visible partial order, order contractiveness is exactly the short
referential presentation.

This exposes the same fact at the referential-length level: an order that
identifies interfaces from mutual visible comparison is precisely the short
`1 + 1` regime.
-/
theorem orderContractive_iff_shortReferentialPresentation
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePartialOrder Visible) :
    OrderContractiveProjection
      Interface
      Visible
      project
      order.toVisiblePreorder
      <->
    ShortReferentialPresentation Interface Visible project :=
  orderContractive_iff_projectionFiberFaithful order

/--
Global information conservation by projection implies order contractiveness
over every visible partial order.
-/
theorem orderContractive_of_informationConserving
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePartialOrder Visible)
    (conserving :
      ProjectionInformationConserving Interface Visible project) :
    OrderContractiveProjection
      Interface
      Visible
      project
      order.toVisiblePreorder :=
  orderContractive_of_projectionFiberFaithful
    order
    (projectionFiberFaithful_of_informationConserving conserving)

/-! ## Structural gaps over ordered visibles -/

/-- A structural gap has mutually comparable visible projections. -/
theorem structuralGap_visible_le_left_right
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePreorder Visible)
    (gap :
      StructuralReferentialGap Interface Visible project) :
    order.le (project gap.left) (project gap.right) := by
  rw [gap.sameProjection]
  exact order.refl (project gap.right)

/-- A structural gap has mutually comparable visible projections. -/
theorem structuralGap_visible_le_right_left
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePreorder Visible)
    (gap :
      StructuralReferentialGap Interface Visible project) :
    order.le (project gap.right) (project gap.left) := by
  rw [<- gap.sameProjection]
  exact order.refl (project gap.left)

/-- A structural gap yields mutual comparability in the visible preorder. -/
theorem structuralGap_visibleOrderEquivalent
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePreorder Visible)
    (gap :
      StructuralReferentialGap Interface Visible project) :
    VisibleOrderEquivalent
      order
      (project gap.left)
      (project gap.right) :=
  And.intro
    (structuralGap_visible_le_left_right order gap)
    (structuralGap_visible_le_right_left order gap)

/--
In a visible partial order, a structural gap collapses to equality only after
projection.
-/
theorem structuralGap_visible_eq_of_partialOrder
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePartialOrder Visible)
    (gap :
      StructuralReferentialGap Interface Visible project) :
    project gap.left = project gap.right :=
  visible_eq_of_visibleOrderEquivalent
    order
    (structuralGap_visibleOrderEquivalent order.toVisiblePreorder gap)

/--
A visible partial order can identify the projected values while the enriched
interfaces remain separated.
-/
theorem structuralGap_partialOrder_visible_eq_not_interface_eq
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePartialOrder Visible)
    (gap :
      StructuralReferentialGap Interface Visible project) :
    And
      (project gap.left = project gap.right)
      (gap.left = gap.right -> False) :=
  And.intro
    (structuralGap_visible_eq_of_partialOrder order gap)
    gap.separatedInterface

/-- A visible total order compares any two projected interfaces. -/
theorem visibleTotalOrder_project_comparable
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisibleTotalOrder Visible)
    (left right : Interface) :
    Or
      (order.le (project left) (project right))
      (order.le (project right) (project left)) :=
  order.total (project left) (project right)

/--
A structural gap refutes the short ordered reading.

The visible preorder can compare the two projections in both directions, but
the enriched interfaces remain separated.
-/
theorem structuralGap_not_orderContractive
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {order : VisiblePreorder Visible}
    (gap :
      StructuralReferentialGap Interface Visible project)
    (contractive :
      OrderContractiveProjection Interface Visible project order) :
    False :=
  structuralGap_not_contractible
    gap
    (projectionFiberFaithful_of_orderContractive order contractive)

/-- A structural enriched length refutes the short ordered presentation. -/
theorem structuralLength_not_orderContractive
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {order : VisiblePreorder Visible}
    (gap :
      EnrichedStructuralReferentialLength Interface Visible project)
    (contractive :
      OrderContractiveProjection Interface Visible project order) :
    False :=
  structuralGap_not_orderContractive gap contractive

/-! ## Operational gaps over ordered visibles -/

/-- An operational gap has mutually comparable visible projections. -/
theorem operationalGap_visible_le_formed_shadow
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePreorder Visible)
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf) :
    order.le (project gap.formed) (project gap.shadow) :=
  structuralGap_visible_le_left_right
    order
    (structuralGapOfOperationalGap gap)

/-- An operational gap has mutually comparable visible projections. -/
theorem operationalGap_visible_le_shadow_formed
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePreorder Visible)
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf) :
    order.le (project gap.shadow) (project gap.formed) :=
  structuralGap_visible_le_right_left
    order
    (structuralGapOfOperationalGap gap)

/-- An operational gap yields mutual comparability in the visible preorder. -/
theorem operationalGap_visibleOrderEquivalent
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePreorder Visible)
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf) :
    VisibleOrderEquivalent
      order
      (project gap.formed)
      (project gap.shadow) :=
  structuralGap_visibleOrderEquivalent
    order
    (structuralGapOfOperationalGap gap)

/--
In a visible partial order, an operational gap collapses to equality only after
projection.
-/
theorem operationalGap_visible_eq_of_partialOrder
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePartialOrder Visible)
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf) :
    project gap.formed = project gap.shadow :=
  visible_eq_of_visibleOrderEquivalent
    order
    (operationalGap_visibleOrderEquivalent order.toVisiblePreorder gap)

/--
A visible partial order can identify the projected values while the operational
formed side and shadow remain separated.
-/
theorem operationalGap_partialOrder_visible_eq_not_interface_eq
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (order : VisiblePartialOrder Visible)
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf) :
    And
      (project gap.formed = project gap.shadow)
      (gap.formed = gap.shadow -> False) :=
  And.intro
    (operationalGap_visible_eq_of_partialOrder order gap)
    gap.separated

/--
An operational gap refutes the short ordered reading.

The visible preorder contracts the formed side and its shadow into mutual
comparability, but the operational gap keeps their separation and local repair.
-/
theorem operationalGap_not_orderContractive
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {order : VisiblePreorder Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf)
    (contractive :
      OrderContractiveProjection Interface Visible project order) :
    False :=
  operationalGap_not_contractible
    gap
    (projectionFiberFaithful_of_orderContractive order contractive)

/-- An operational enriched length refutes the short ordered presentation. -/
theorem operationalLength_not_orderContractive
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {order : VisiblePreorder Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      EnrichedOperationalReferentialLength
        Interface
        Visible
        project
        RepairOf)
    (contractive :
      OrderContractiveProjection Interface Visible project order) :
    False :=
  operationalGap_not_orderContractive gap contractive

/-! ## Dynamic returns over ordered visibles -/

/--
The formed interface of a locally recovered dynamic return has a visible
projection mutually comparable with its shadow.
-/
theorem dynamicReturn_visible_le_formed_shadow
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (order : VisiblePreorder Visible)
    (dynamicReturn :
      LocallyRecoveredDynamicReturn
        complete
        coherence
        branch
        Source
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project
        RepairOf) :
    order.le
      (project dynamicReturn.localRecovery.formed)
      (project dynamicReturn.localRecovery.shadow) :=
  operationalGap_visible_le_formed_shadow
    order
    (dynamicReturn_operationalGap dynamicReturn)

/--
The shadow of a locally recovered dynamic return has a visible projection
mutually comparable with the formed interface.
-/
theorem dynamicReturn_visible_le_shadow_formed
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (order : VisiblePreorder Visible)
    (dynamicReturn :
      LocallyRecoveredDynamicReturn
        complete
        coherence
        branch
        Source
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project
        RepairOf) :
    order.le
      (project dynamicReturn.localRecovery.shadow)
      (project dynamicReturn.localRecovery.formed) :=
  operationalGap_visible_le_shadow_formed
    order
    (dynamicReturn_operationalGap dynamicReturn)

/--
A locally recovered dynamic return gives mutual comparability in the visible
preorder.
-/
theorem dynamicReturn_visibleOrderEquivalent
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (order : VisiblePreorder Visible)
    (dynamicReturn :
      LocallyRecoveredDynamicReturn
        complete
        coherence
        branch
        Source
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project
        RepairOf) :
    VisibleOrderEquivalent
      order
      (project dynamicReturn.localRecovery.formed)
      (project dynamicReturn.localRecovery.shadow) :=
  operationalGap_visibleOrderEquivalent
    order
    (dynamicReturn_operationalGap dynamicReturn)

/--
In a visible partial order, a locally recovered dynamic return contracts only
after projection.
-/
theorem dynamicReturn_visible_eq_of_partialOrder
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (order : VisiblePartialOrder Visible)
    (dynamicReturn :
      LocallyRecoveredDynamicReturn
        complete
        coherence
        branch
        Source
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project
        RepairOf) :
    project dynamicReturn.localRecovery.formed =
      project dynamicReturn.localRecovery.shadow :=
  operationalGap_visible_eq_of_partialOrder
    order
    (dynamicReturn_operationalGap dynamicReturn)

/--
A visible partial order can identify the projected values of a dynamic return,
while the formed interface and its shadow remain separated.
-/
theorem dynamicReturn_partialOrder_visible_eq_not_interface_eq
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (order : VisiblePartialOrder Visible)
    (dynamicReturn :
      LocallyRecoveredDynamicReturn
        complete
        coherence
        branch
        Source
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project
        RepairOf) :
    And
      (project dynamicReturn.localRecovery.formed =
        project dynamicReturn.localRecovery.shadow)
      (dynamicReturn.localRecovery.formed =
        dynamicReturn.localRecovery.shadow -> False) :=
  operationalGap_partialOrder_visible_eq_not_interface_eq
    order
    (dynamicReturn_operationalGap dynamicReturn)

/--
A locally recovered dynamic return refutes the short ordered reading.

The visible preorder sees mutual comparability between the formed interface and
its shadow, but the dynamic return carries the local recovery separating them.
-/
theorem dynamicReturn_not_orderContractive
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {order : VisiblePreorder Visible}
    (dynamicReturn :
      LocallyRecoveredDynamicReturn
        complete
        coherence
        branch
        Source
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project
        RepairOf)
    (contractive :
      OrderContractiveProjection Interface Visible project order) :
    False :=
  operationalGap_not_orderContractive
    (dynamicReturn_operationalGap dynamicReturn)
    contractive

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.VisiblePreorder
#print axioms Meta.ClosedStabilityTheorem.VisiblePartialOrder
#print axioms Meta.ClosedStabilityTheorem.VisibleTotalOrder
#print axioms Meta.ClosedStabilityTheorem.VisibleOrder
#print axioms Meta.ClosedStabilityTheorem.VisibleOrderEquivalent
#print axioms Meta.ClosedStabilityTheorem.visibleOrderEquivalent_refl
#print axioms Meta.ClosedStabilityTheorem.visible_eq_of_visibleOrderEquivalent
#print axioms Meta.ClosedStabilityTheorem.OrderContractiveProjection
#print axioms Meta.ClosedStabilityTheorem.projectionFiberFaithful_of_orderContractive
#print axioms Meta.ClosedStabilityTheorem.orderContractive_of_projectionFiberFaithful
#print axioms Meta.ClosedStabilityTheorem.orderContractive_iff_projectionFiberFaithful
#print axioms Meta.ClosedStabilityTheorem.orderContractive_iff_contractibleReferentialGap
#print axioms Meta.ClosedStabilityTheorem.orderContractive_iff_shortReferentialPresentation
#print axioms Meta.ClosedStabilityTheorem.orderContractive_of_informationConserving
#print axioms Meta.ClosedStabilityTheorem.structuralGap_visible_le_left_right
#print axioms Meta.ClosedStabilityTheorem.structuralGap_visible_le_right_left
#print axioms Meta.ClosedStabilityTheorem.structuralGap_visibleOrderEquivalent
#print axioms Meta.ClosedStabilityTheorem.structuralGap_visible_eq_of_partialOrder
#print axioms Meta.ClosedStabilityTheorem.structuralGap_partialOrder_visible_eq_not_interface_eq
#print axioms Meta.ClosedStabilityTheorem.visibleTotalOrder_project_comparable
#print axioms Meta.ClosedStabilityTheorem.structuralGap_not_orderContractive
#print axioms Meta.ClosedStabilityTheorem.structuralLength_not_orderContractive
#print axioms Meta.ClosedStabilityTheorem.operationalGap_visible_le_formed_shadow
#print axioms Meta.ClosedStabilityTheorem.operationalGap_visible_le_shadow_formed
#print axioms Meta.ClosedStabilityTheorem.operationalGap_visibleOrderEquivalent
#print axioms Meta.ClosedStabilityTheorem.operationalGap_visible_eq_of_partialOrder
#print axioms Meta.ClosedStabilityTheorem.operationalGap_partialOrder_visible_eq_not_interface_eq
#print axioms Meta.ClosedStabilityTheorem.operationalGap_not_orderContractive
#print axioms Meta.ClosedStabilityTheorem.operationalLength_not_orderContractive
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_visible_le_formed_shadow
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_visible_le_shadow_formed
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_visibleOrderEquivalent
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_visible_eq_of_partialOrder
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_partialOrder_visible_eq_not_interface_eq
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_not_orderContractive
/- AXIOM_AUDIT_END -/
