import Meta.Core.ReferentialLength
import Meta.Core.VisibleOrder

/-!
# Order-contractive projections

This file contains the bridge between visible-order comparison and the short
projective reading.  It does not contain structural, operational, or dynamic
gap consequences.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v

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

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.OrderContractiveProjection
#print axioms Meta.ClosedStabilityTheorem.projectionFiberFaithful_of_orderContractive
#print axioms Meta.ClosedStabilityTheorem.orderContractive_of_projectionFiberFaithful
#print axioms Meta.ClosedStabilityTheorem.orderContractive_iff_projectionFiberFaithful
#print axioms Meta.ClosedStabilityTheorem.orderContractive_iff_contractibleReferentialGap
#print axioms Meta.ClosedStabilityTheorem.orderContractive_iff_shortReferentialPresentation
#print axioms Meta.ClosedStabilityTheorem.orderContractive_of_informationConserving
/- AXIOM_AUDIT_END -/
