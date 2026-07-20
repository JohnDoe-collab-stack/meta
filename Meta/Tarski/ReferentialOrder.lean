import Meta.Core.Specialization.OrderGap
import Meta.Tarski.GapContraction

/-!
# Tarski referential length and visible order

This file exposes the Tarski diagonal obstruction through two additional
abstract Core layers:

* enriched referential length;
* visible-order contraction tests and their refutation.

The diagonal content stays in `Meta.Tarski.TruthGap`.  This layer only consumes
the already established operational Tarski gap.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v

/-! ## Tarski as enriched referential length -/

/-- A Tarski diagonal obstruction exposes an enriched operational length. -/
def TarskiDiagonalObstruction.operationalLength
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    EnrichedOperationalReferentialLength
      Meaning
      Syntax
      project
      (@TarskiTruthRepair Meaning) :=
  gap.operationalGap

/-- A Tarski diagonal obstruction exposes the structural length it carries. -/
def TarskiDiagonalObstruction.structuralLength
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    EnrichedStructuralReferentialLength Meaning Syntax project :=
  structuralLengthOfOperationalLength gap.operationalLength

/--
The Tarski diagonal obstruction refutes the short referential presentation of
the syntactic projection.
-/
theorem TarskiDiagonalObstruction.refutesShortPresentation
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (short :
      ShortReferentialPresentation Meaning Syntax project) :
    False :=
  operationalLength_refutes_shortPresentation
    gap.operationalLength
    short

/-! ## Tarski over visible orders -/

/-- The formed side projects below its shadow in any visible preorder. -/
theorem TarskiDiagonalObstruction.visible_le_formed_shadow
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (order : VisiblePreorder Syntax)
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    order.le (project gap.formed) (project gap.shadow) :=
  operationalGap_visible_le_formed_shadow
    order
    gap.operationalGap

/-- The shadow projects below the formed side in any visible preorder. -/
theorem TarskiDiagonalObstruction.visible_le_shadow_formed
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (order : VisiblePreorder Syntax)
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    order.le (project gap.shadow) (project gap.formed) :=
  operationalGap_visible_le_shadow_formed
    order
    gap.operationalGap

/-- A Tarski diagonal obstruction yields visible-order equivalence. -/
theorem TarskiDiagonalObstruction.visibleOrderEquivalent
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (order : VisiblePreorder Syntax)
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    VisibleOrderEquivalent
      order
      (project gap.formed)
      (project gap.shadow) :=
  operationalGap_visibleOrderEquivalent
    order
    gap.operationalGap

/--
In a visible partial order, the Tarski formed side and shadow have equal
projected syntax.
-/
theorem TarskiDiagonalObstruction.visible_eq_of_partialOrder
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (order : VisiblePartialOrder Syntax)
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    project gap.formed = project gap.shadow :=
  operationalGap_visible_eq_of_partialOrder
    order
    gap.operationalGap

/--
A visible partial order identifies the projected syntax while the enriched
Tarski interfaces remain separated.
-/
theorem TarskiDiagonalObstruction.partialOrder_visible_eq_not_interface_eq
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (order : VisiblePartialOrder Syntax)
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    project gap.formed = project gap.shadow ∧
      (gap.formed = gap.shadow -> False) :=
  operationalGap_partialOrder_visible_eq_not_interface_eq
    order
    gap.operationalGap

/-! ## Tarski against ordered contraction -/

/-- A Tarski diagonal obstruction refutes the ordered contraction reading. -/
theorem TarskiDiagonalObstruction.notOrderContractive
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    {order : VisiblePreorder Syntax}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (contractive :
      OrderContractiveProjection Meaning Syntax project order) :
    False :=
  operationalGap_not_orderContractive
    gap.operationalGap
    contractive

/--
The enriched operational length carried by a Tarski diagonal obstruction refutes
the ordered contraction presentation.
-/
theorem TarskiDiagonalObstruction.operationalLength_notOrderContractive
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    {order : VisiblePreorder Syntax}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (contractive :
      OrderContractiveProjection Meaning Syntax project order) :
    False :=
  operationalLength_not_orderContractive
    gap.operationalLength
    contractive

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.operationalLength
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.structuralLength
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.refutesShortPresentation
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.visible_le_formed_shadow
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.visible_le_shadow_formed
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.visibleOrderEquivalent
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.visible_eq_of_partialOrder
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.partialOrder_visible_eq_not_interface_eq
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.notOrderContractive
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.operationalLength_notOrderContractive
/- AXIOM_AUDIT_END -/
