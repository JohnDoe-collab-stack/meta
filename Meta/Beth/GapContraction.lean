import Meta.Beth.ImplicitExplicit
import Meta.Core.Gap

/-!
# Beth gap contraction

This file is the gap-reading layer over the internal Beth core.

The Beth collapse is now property-level, not merely fiber-level.  It says that
an enriched property is both invariant on visible fibers and explicitly read by
a visible predicate.  A Beth separation refutes that collapse by exhibiting two
separated enriched interfaces with the same visible projection but different
property status.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v s

/-! ## Beth collapse -/

/--
Beth-contractible gap for an enriched property.

The visible projection carries the enriched property exactly when:

* the property is invariant on projection fibers;
* the property is explicitly readable on the visible side.
-/
structure BethContractibleGap
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (Property : Interface -> Prop) :
    Type (max u v) where
  implicitDetermination :
    ImplicitlyDeterminedByVisible Interface Visible project Property
  explicitDefinition :
    ExplicitDefinitionOnVisible Interface Visible project Property

/-- An explicit visible definition gives the Beth collapse it determines. -/
def bethCollapse_of_explicitDefinitionOnVisible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {Property : Interface -> Prop}
    (explicit :
      ExplicitDefinitionOnVisible Interface Visible project Property) :
    BethContractibleGap Interface Visible project Property where
  implicitDetermination :=
    implicitDetermination_of_explicitDefinitionOnVisible explicit
  explicitDefinition := explicit

/-! ## Anti-collapse gaps -/

/-- A Beth separation refutes Beth collapse. -/
theorem bethSeparation_refutes_bethCollapse
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {Property : Interface -> Prop}
    (separation :
      BethSeparation Interface Visible project Property)
    (beth :
      BethContractibleGap Interface Visible project Property) :
    False :=
  bethSeparation_refutes_implicitDetermination
    separation
    beth.implicitDetermination

/--
A structural referential gap refutes Beth collapse when its two poles are also
separated by the enriched property.
-/
theorem structuralGap_refutes_bethCollapse
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {Property : Interface -> Prop}
    (gap :
      StructuralReferentialGap Interface Visible project)
    (property_left :
      Property gap.left)
    (property_right_not :
      Property gap.right -> False)
    (beth :
      BethContractibleGap Interface Visible project Property) :
    False :=
  bethSeparation_refutes_bethCollapse
    { formed := gap.left
      shadow := gap.right
      sameProjection := gap.sameProjection
      property_formed := property_left
      shadow_not_property := property_right_not }
    beth

/--
An operational referential gap refutes Beth collapse when its formed side and
shadow are separated by the enriched property.
-/
theorem operationalGap_refutes_bethCollapse
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {Property : Interface -> Prop}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf)
    (property_formed :
      Property gap.formed)
    (shadow_not_property :
      Property gap.shadow -> False)
    (beth :
      BethContractibleGap Interface Visible project Property) :
    False :=
  structuralGap_refutes_bethCollapse
    (structuralGapOfOperationalGap gap)
    property_formed
    shadow_not_property
    beth

/--
A structural referential gap refutes the explicit-definition side of Beth when
its two poles are separated by the enriched property.
-/
theorem structuralGap_refutes_bethExplicitDefinition
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {Property : Interface -> Prop}
    (gap :
      StructuralReferentialGap Interface Visible project)
    (property_left :
      Property gap.left)
    (property_right_not :
      Property gap.right -> False)
    (explicit :
      ExplicitDefinitionOnVisible Interface Visible project Property) :
    False :=
  bethSeparation_refutes_explicitDefinition
    { formed := gap.left
      shadow := gap.right
      sameProjection := gap.sameProjection
      property_formed := property_left
      shadow_not_property := property_right_not }
    explicit

/--
An operational referential gap refutes the explicit-definition side of Beth when
its formed side and shadow are separated by the enriched property.
-/
theorem operationalGap_refutes_bethExplicitDefinition
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {Property : Interface -> Prop}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf)
    (property_formed :
      Property gap.formed)
    (shadow_not_property :
      Property gap.shadow -> False)
    (explicit :
      ExplicitDefinitionOnVisible Interface Visible project Property) :
    False :=
  structuralGap_refutes_bethExplicitDefinition
    (structuralGapOfOperationalGap gap)
    property_formed
    shadow_not_property
    explicit

/--
Operational gaps survive the Beth test when their formed side and shadow are
separated by the enriched property while still carrying local repair of the
formed interface.
-/
structure BethSurvivingOperationalGap
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s)
    (Property : Interface -> Prop) :
    Type (max u v s) where
  operationalGap :
    OperationalReferentialGap Interface Visible project RepairOf
  property_formed :
    Property operationalGap.formed
  shadow_not_property :
    Property operationalGap.shadow -> False
  refutes_beth :
    BethContractibleGap Interface Visible project Property -> False
  refutes_explicit :
    ExplicitDefinitionOnVisible Interface Visible project Property -> False

/-- Every property-separated operational gap gives a Beth-surviving gap. -/
def bethSurvivingOperationalGap
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {Property : Interface -> Prop}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf)
    (property_formed :
      Property gap.formed)
    (shadow_not_property :
      Property gap.shadow -> False) :
    BethSurvivingOperationalGap Interface Visible project RepairOf Property where
  operationalGap := gap
  property_formed := property_formed
  shadow_not_property := shadow_not_property
  refutes_beth :=
    operationalGap_refutes_bethCollapse
      gap
      property_formed
      shadow_not_property
  refutes_explicit :=
    operationalGap_refutes_bethExplicitDefinition
      gap
      property_formed
      shadow_not_property

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.BethContractibleGap
#print axioms Meta.ClosedStabilityTheorem.bethCollapse_of_explicitDefinitionOnVisible
#print axioms Meta.ClosedStabilityTheorem.bethSeparation_refutes_bethCollapse
#print axioms Meta.ClosedStabilityTheorem.structuralGap_refutes_bethCollapse
#print axioms Meta.ClosedStabilityTheorem.operationalGap_refutes_bethCollapse
#print axioms Meta.ClosedStabilityTheorem.structuralGap_refutes_bethExplicitDefinition
#print axioms Meta.ClosedStabilityTheorem.operationalGap_refutes_bethExplicitDefinition
#print axioms Meta.ClosedStabilityTheorem.BethSurvivingOperationalGap
#print axioms Meta.ClosedStabilityTheorem.bethSurvivingOperationalGap
/- AXIOM_AUDIT_END -/
