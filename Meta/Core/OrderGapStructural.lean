import Meta.Core.OrderContraction

/-!
# Structural and operational ordered gaps

This file records the structural and operational order-theoretic test for the
gap framework.  Dynamic-return consequences are kept in `DynamicOrderGap.lean`.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v s

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

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
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
/- AXIOM_AUDIT_END -/
