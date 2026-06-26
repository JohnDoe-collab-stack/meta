import Meta.Synthesis.TarskiBethGap
import Meta.Bell.AmalgamationGap

/-!
# Tarski, Beth, and Bell gaps

This file assembles the established layers into their common comparison table:

* Tarski supplies an operational referential gap;
* Beth tests contractibility of that gap as a short presentation;
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
  gap.operationalGap

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
  operationalLength_refutes_shortPresentation
    (tarskiBethBell_tarskiOperationalLength gap)
    short

/-- The Tarski operational row survives the Beth-collapse test. -/
theorem tarskiBethBell_tarskiRefutesBethCollapse
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (beth :
      BethContractibleGap Meaning Syntax project) :
    False :=
  gap.refutesBethCollapse beth

/-- The Tarski operational row refutes explicit recovery on realized fibers. -/
theorem tarskiBethBell_tarskiRefutesBethExplicitDefinition
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (explicit :
      ExplicitDefinitionOnRealizedVisible Meaning Syntax project) :
    False :=
  gap.refutesBethExplicitDefinition explicit

/-! ## Beth row: contractibility test -/

/--
The Beth-collapse row is exactly the short referential presentation of the same
projection.
-/
theorem tarskiBethBell_bethCollapse_iff_shortPresentation
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible} :
    BethContractibleGap Interface Visible project ↔
      ShortReferentialPresentation Interface Visible project := by
  constructor
  · intro beth
    exact beth
  · intro short
    exact short

/-- The Beth row is also the explicit-recovery test on realized visible fibers. -/
theorem tarskiBethBell_bethCollapse_iff_explicitRecovery
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible} :
    BethContractibleGap Interface Visible project ↔
      Nonempty
        (ExplicitDefinitionOnRealizedVisible Interface Visible project) :=
  bethCollapse_iff_explicitDefinitionOnRealizedVisible

/-! ## Bell row: short co-indexation and amalgamation gap -/

/-- The Bell short row: local contexts admit one global co-indexation. -/
abbrev TarskiBethBellBellShortRow
    (contexts : BellFourContextAssignments) :
    Type :=
  BellShortCoindexationOfContexts contexts

/-- The Bell gap row: local contexts fail to admit one global co-indexation. -/
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
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bethCollapse_iff_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bethCollapse_iff_explicitRecovery
#print axioms Meta.ClosedStabilityTheorem.TarskiBethBellBellShortRow
#print axioms Meta.ClosedStabilityTheorem.TarskiBethBellBellGapRow
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bellShort_iff_compatibility
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bellShort_givesPointwiseBound
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bellShort_givesClassicalBound
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bellGap_refutesShort
#print axioms Meta.ClosedStabilityTheorem.tarskiBethBell_bellGap_refutesShortNonempty
/- AXIOM_AUDIT_END -/
