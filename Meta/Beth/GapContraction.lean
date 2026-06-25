import Meta.Beth.ImplicitExplicit
import Meta.Core.Gap

/-!
# Beth gap contraction

This file is the gap-reading layer over the internal Beth core.

`BethImplicitExplicit` proves the constructive content:

```text
implicit determination by visible
↔
explicit definition on realized visible fibers
```

This file names that equivalence as the Beth collapse of a referential gap, and
records that structural and operational gaps survive that collapse.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v s

/-! ## Beth collapse -/

/--
Beth-contractible gap.

This is the gap-contraction reading of implicit determination by visible
projection.
-/
abbrev BethContractibleGap
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Prop :=
  ContractibleReferentialGap Interface Visible project

/-- Implicit determination gives the Beth collapse of the gap. -/
theorem bethCollapse_of_implicitDetermination
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (implicit :
      ImplicitlyDeterminedByVisible Interface Visible project) :
    BethContractibleGap Interface Visible project :=
  implicit

/-- A Beth-collapsed gap is exactly implicit determination by visible. -/
theorem implicitDetermination_of_bethCollapse
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (beth :
      BethContractibleGap Interface Visible project) :
    ImplicitlyDeterminedByVisible Interface Visible project :=
  beth

/-- Beth collapse is equivalent to implicit determination by visible. -/
theorem bethCollapse_iff_implicitDetermination
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible} :
    BethContractibleGap Interface Visible project ↔
      ImplicitlyDeterminedByVisible Interface Visible project := by
  constructor
  · exact implicitDetermination_of_bethCollapse
  · exact bethCollapse_of_implicitDetermination

/--
Beth collapse gives explicit recovery on every already realized visible fiber.
-/
def explicitDefinitionOnRealizedVisible_of_bethCollapse
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (beth :
      BethContractibleGap Interface Visible project) :
    ExplicitDefinitionOnRealizedVisible Interface Visible project :=
  explicitDefinitionOnRealizedVisible_of_implicitDetermination
    (implicitDetermination_of_bethCollapse beth)

/--
Explicit unique recovery on realized visible fibers gives the Beth collapse of
the gap.
-/
theorem bethCollapse_of_explicitDefinitionOnRealizedVisible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (explicit :
      ExplicitDefinitionOnRealizedVisible Interface Visible project) :
    BethContractibleGap Interface Visible project :=
  bethCollapse_of_implicitDetermination
    (implicitDetermination_of_explicitDefinitionOnRealizedVisible explicit)

/--
Beth collapse is equivalent to the existence of explicit unique recovery on
realized visible fibers.
-/
theorem bethCollapse_iff_explicitDefinitionOnRealizedVisible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible} :
    BethContractibleGap Interface Visible project ↔
      Nonempty
        (ExplicitDefinitionOnRealizedVisible Interface Visible project) := by
  constructor
  · intro beth
    exact
      ⟨explicitDefinitionOnRealizedVisible_of_bethCollapse beth⟩
  · intro hExplicit
    cases hExplicit with
    | intro explicit =>
        exact bethCollapse_of_explicitDefinitionOnRealizedVisible explicit

/-! ## Anti-collapse gaps -/

/-- A structural referential gap refutes Beth collapse. -/
theorem structuralGap_refutes_bethCollapse
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (gap :
      StructuralReferentialGap Interface Visible project)
    (beth :
      BethContractibleGap Interface Visible project) :
    False :=
  structuralGap_not_contractible gap beth

/-- An operational referential gap refutes Beth collapse. -/
theorem operationalGap_refutes_bethCollapse
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf)
    (beth :
      BethContractibleGap Interface Visible project) :
    False :=
  operationalGap_not_contractible gap beth

/--
A structural referential gap refutes the explicit-definition side of the Beth
equivalence.
-/
theorem structuralGap_refutes_bethExplicitDefinition
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (gap :
      StructuralReferentialGap Interface Visible project)
    (explicit :
      ExplicitDefinitionOnRealizedVisible Interface Visible project) :
    False :=
  structuralGap_refutes_explicitDefinitionOnRealizedVisible gap explicit

/--
An operational referential gap refutes the explicit-definition side of the Beth
equivalence.
-/
theorem operationalGap_refutes_bethExplicitDefinition
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf)
    (explicit :
      ExplicitDefinitionOnRealizedVisible Interface Visible project) :
    False :=
  localRecoveryGap_refutes_explicitDefinitionOnRealizedVisible gap explicit

/--
Operational gaps survive the Beth test while still carrying local repair of the
formed interface.
-/
structure BethSurvivingOperationalGap
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max u v s) where
  operationalGap :
    OperationalReferentialGap Interface Visible project RepairOf
  refutes_beth :
    BethContractibleGap Interface Visible project -> False
  refutes_explicit :
    ExplicitDefinitionOnRealizedVisible Interface Visible project -> False

/-- Every operational gap gives a Beth-surviving operational gap. -/
def bethSurvivingOperationalGap
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf) :
    BethSurvivingOperationalGap Interface Visible project RepairOf where
  operationalGap := gap
  refutes_beth :=
    operationalGap_refutes_bethCollapse gap
  refutes_explicit :=
    operationalGap_refutes_bethExplicitDefinition gap

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.BethContractibleGap
#print axioms Meta.ClosedStabilityTheorem.bethCollapse_of_implicitDetermination
#print axioms Meta.ClosedStabilityTheorem.implicitDetermination_of_bethCollapse
#print axioms Meta.ClosedStabilityTheorem.bethCollapse_iff_implicitDetermination
#print axioms Meta.ClosedStabilityTheorem.explicitDefinitionOnRealizedVisible_of_bethCollapse
#print axioms Meta.ClosedStabilityTheorem.bethCollapse_of_explicitDefinitionOnRealizedVisible
#print axioms Meta.ClosedStabilityTheorem.bethCollapse_iff_explicitDefinitionOnRealizedVisible
#print axioms Meta.ClosedStabilityTheorem.structuralGap_refutes_bethCollapse
#print axioms Meta.ClosedStabilityTheorem.operationalGap_refutes_bethCollapse
#print axioms Meta.ClosedStabilityTheorem.structuralGap_refutes_bethExplicitDefinition
#print axioms Meta.ClosedStabilityTheorem.operationalGap_refutes_bethExplicitDefinition
#print axioms Meta.ClosedStabilityTheorem.BethSurvivingOperationalGap
#print axioms Meta.ClosedStabilityTheorem.bethSurvivingOperationalGap
/- AXIOM_AUDIT_END -/
