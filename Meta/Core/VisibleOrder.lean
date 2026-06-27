/-!
# Visible order data

This file contains only the order data that live on the visible referential.
It does not mention gaps, dynamic returns, or contractibility.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe v

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
/- AXIOM_AUDIT_END -/
