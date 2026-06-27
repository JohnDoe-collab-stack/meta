import Meta.Core.DynamicOrderGap

/-!
# Ordered projection gaps

This compatibility module keeps `Meta.Core.OrderGap` as the public order-gap
entry point while the implementation is split across:

* `VisibleOrder.lean`;
* `OrderContraction.lean`;
* `OrderGapStructural.lean`;
* `DynamicOrderGap.lean`.

Downstream files can continue importing `Meta.Core.OrderGap` during the
transition.
-/

namespace Meta
namespace ClosedStabilityTheorem

/-! ## Public compatibility audit -/

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
