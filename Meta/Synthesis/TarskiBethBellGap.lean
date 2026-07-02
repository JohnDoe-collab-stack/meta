import Meta.Synthesis.TarskiBethGap
import Meta.Bell.AmalgamationGap
import Meta.Tarski.ReferentialOrder

/-!
# Tarski, Beth, and Bell gaps

This file assembles the established layers into their common comparison table:

* Tarski supplies an operational referential gap;
* Beth tests whether an enriched property is explicitly readable from the
  visible projection;
* Bell reads the classical CHSH bound as the result of short co-indexation,
  while an amalgamation obstruction is the corresponding pre-probabilistic gap.

The semantic principles remain in the source layers; this synthesis records
their shared gap/contraction shape.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v

/-! ## Tarski row: diagonal operational gap -/

/-- The Tarski row exposes the enriched operational referential length. -/
def tarskiBethBell_tarskiOperationalLength
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
  gap.operationalLength

/-- The Tarski operational row refutes the short presentation of the projection. -/
theorem tarskiBethBell_tarskiRefutesShortPresentation
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (short :
      ShortReferentialPresentation Meaning Syntax project) :
    False :=
  gap.refutesShortPresentation short

/-- The Tarski operational row survives the Beth-collapse test. -/
theorem tarskiBethBell_tarskiRefutesBethCollapse
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (beth :
      BethContractibleGap Meaning Syntax project Truth) :
    False :=
  gap.refutesBethCollapse beth

/-- The Tarski operational row refutes explicit visible definition of truth. -/
theorem tarskiBethBell_tarskiRefutesBethExplicitDefinition
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (explicit :
      ExplicitDefinitionOnVisible Meaning Syntax project Truth) :
    False :=
  gap.refutesBethExplicitDefinition explicit

/-! ## Beth row: property-level definability test -/

/--
An explicit visible definition gives the Beth collapse of the corresponding
enriched property.
-/
def tarskiBethBell_bethCollapseOfExplicitDefinition
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {Property : Interface -> Prop}
    (explicit :
      ExplicitDefinitionOnVisible Interface Visible project Property) :
    BethContractibleGap Interface Visible project Property :=
  bethCollapse_of_explicitDefinitionOnVisible explicit

/-- A Beth separation refutes the Beth collapse of its enriched property. -/
theorem tarskiBethBell_bethSeparationRefutesCollapse
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {Property : Interface -> Prop}
    (separation :
      BethSeparation Interface Visible project Property)
    (beth :
      BethContractibleGap Interface Visible project Property) :
    False :=
  bethSeparation_refutes_bethCollapse separation beth

/-! ## Bell row: short co-indexation and amalgamation gap -/

/-- The Bell short row: local contexts allow one global co-indexation. -/
abbrev TarskiBethBellBellShortRow
    (contexts : BellFourContextAssignments) :
    Type :=
  BellShortCoindexationOfContexts contexts

/-- The Bell gap row: local contexts do not allow one global co-indexation. -/
abbrev TarskiBethBellBellGapRow
    (contexts : BellFourContextAssignments) :
    Prop :=
  BellAmalgamationGap contexts

/-- Bell short co-indexation is equivalent to compatibility of repeated margins. -/
theorem tarskiBethBell_bellShort_iff_compatibility
    (contexts : BellFourContextAssignments) :
    Nonempty (TarskiBethBellBellShortRow contexts) ↔
      Nonempty (BellAmalgamationCompatibility contexts) :=
  bellShortCoindexation_iff_compatibility contexts

/-- The Bell short row yields the exact pointwise CHSH bound. -/
theorem tarskiBethBell_bellShort_givesPointwiseBound
    {contexts : BellFourContextAssignments}
    (short : TarskiBethBellBellShortRow contexts) :
    BellPointwiseCHSHBound
      (bellShortCoindexation_of_amalgamation short) :=
  bellPointwiseCHSHBound_of_shortCoindexedContexts short

/-- The Bell short row yields the standard classical CHSH bound. -/
theorem tarskiBethBell_bellShort_givesClassicalBound
    {contexts : BellFourContextAssignments}
    (short : TarskiBethBellBellShortRow contexts) :
    BellGlobalAssignment.BellClassicalBound
      (bellShortCoindexation_of_amalgamation short) :=
  bellClassicalBound_of_shortCoindexedContexts short

/-- The Bell gap row refutes short co-indexation of those contexts. -/
theorem tarskiBethBell_bellGap_refutesShort
    {contexts : BellFourContextAssignments}
    (gap : TarskiBethBellBellGapRow contexts)
    (short : TarskiBethBellBellShortRow contexts) :
    False :=
  bellAmalgamationGap_refutes_shortCoindexation gap short

/-- The Bell gap row refutes existence of short co-indexation of those contexts. -/
theorem tarskiBethBell_bellGap_refutesShortNonempty
    {contexts : BellFourContextAssignments}
    (gap : TarskiBethBellBellGapRow contexts)
    (short : Nonempty (TarskiBethBellBellShortRow contexts)) :
    False :=
  bellAmalgamationGap_refutes_shortCoindexation_nonempty gap short

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_tarskiOperationalLength
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_tarskiRefutesShortPresentation
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_tarskiRefutesBethCollapse
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_tarskiRefutesBethExplicitDefinition
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bethCollapseOfExplicitDefinition
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bethSeparationRefutesCollapse
#print axioms Meta.ClosedStabilityTheorem.TarskiBethBellBellShortRow
#print axioms Meta.ClosedStabilityTheorem.TarskiBethBellBellGapRow
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bellShort_iff_compatibility
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bellShort_givesPointwiseBound
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bellShort_givesClassicalBound
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bellGap_refutesShort
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bellGap_refutesShortNonempty
/- AXIOM_AUDIT_END -/
