import Meta.Core.OrderGapStructural
import Meta.Core.DynamicTwoPole

/-!
# Dynamic ordered gaps

This file records the order consequences carried by locally recovered dynamic
returns.  Structural and operational order consequences are kept in
`OrderGapStructural.lean`.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s a

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
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_visible_le_formed_shadow
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_visible_le_shadow_formed
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_visibleOrderEquivalent
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_visible_eq_of_partialOrder
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_partialOrder_visible_eq_not_interface_eq
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_not_orderContractive
/- AXIOM_AUDIT_END -/
