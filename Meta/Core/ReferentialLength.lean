import Meta.Tarski.GapContraction

/-!
# Referential length

This file records the transverse vocabulary behind the gap layers.

The informal contrast

```text
short presentation: 1 + 1 <= 2
enriched reading:   1 + gap + 1 >= 2
```

is not encoded as an artificial numeric length.  It is encoded by the status of
the projection fiber:

* contractible gap: the visible projection determines the enriched interface;
* structural gap: two separated enriched interfaces share one visible value;
* operational gap: the structural gap carries a local repair indexed by the
  formed interface.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v s

/-! ## Referential length regimes -/

/-- The short regime: the visible projection has contractible fibers. -/
abbrev ShortReferentialPresentation
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Prop :=
  ContractibleReferentialGap Interface Visible project

/-- The enriched structural regime: one visible value can cover separated interfaces. -/
abbrev EnrichedStructuralReferentialLength
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Type (max u v) :=
  StructuralReferentialGap Interface Visible project

/--
The enriched operational regime: a structural gap plus local repair of the
formed interface.
-/
abbrev EnrichedOperationalReferentialLength
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max u v s) :=
  OperationalReferentialGap Interface Visible project RepairOf

/-- A structural enriched length refutes the short presentation. -/
theorem structuralLength_refutes_shortPresentation
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (gap :
      EnrichedStructuralReferentialLength Interface Visible project)
    (short :
      ShortReferentialPresentation Interface Visible project) :
    False :=
  structuralGap_not_contractible gap short

/-- An operational enriched length refutes the short presentation. -/
theorem operationalLength_refutes_shortPresentation
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      EnrichedOperationalReferentialLength
        Interface
        Visible
        project
        RepairOf)
    (short :
      ShortReferentialPresentation Interface Visible project) :
    False :=
  operationalGap_not_contractible gap short

/-- An operational enriched length exposes the structural enriched length it carries. -/
def structuralLengthOfOperationalLength
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      EnrichedOperationalReferentialLength
        Interface
        Visible
        project
        RepairOf) :
    EnrichedStructuralReferentialLength Interface Visible project :=
  structuralGapOfOperationalGap gap

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.ShortReferentialPresentation
#print axioms Meta.ClosedStabilityTheorem.EnrichedStructuralReferentialLength
#print axioms Meta.ClosedStabilityTheorem.EnrichedOperationalReferentialLength
#print axioms Meta.ClosedStabilityTheorem.structuralLength_refutes_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.operationalLength_refutes_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.structuralLengthOfOperationalLength
/- AXIOM_AUDIT_END -/
