import Meta.Core.ClosedStabilityTheorem

/-!
# Beth implicit/explicit projection core

This file gives the internal Beth layer for the standalone meta package.

The Beth question is not fiber equality.  It is whether an enriched property is
already determined by the visible projection, and whether it can therefore be
read by a visible predicate.

The constructive content is:

```text
explicit visible definition of Property
-> Property is invariant on projection fibers
```

and a genuine Beth obstruction is:

```text
same visible projection
+ Property holds on the formed side
+ Property fails on the shadow side
```

Such a separation refutes both implicit visible determination and explicit
visible definition of the enriched property.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v

/-! ## Implicit determination and explicit visible definition -/

/--
Implicit determination of an enriched property by the visible projection.

This is the Beth-style implicit side: if two enriched interfaces have the same
visible projection, then the property cannot distinguish them.
-/
structure ImplicitlyDeterminedByVisible
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (Property : Interface -> Prop) :
    Prop where
  invariant :
    (left right : Interface) ->
      project left = project right ->
        (Property left ↔ Property right)

/--
Explicit definition of an enriched property on the visible projection.

The predicate lives on the visible side, and its pullback along `project`
recovers the enriched property.
-/
structure ExplicitDefinitionOnVisible
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (Property : Interface -> Prop) :
    Type (max u v) where
  visiblePredicate : Visible -> Prop
  correct :
    (interface : Interface) ->
      visiblePredicate (project interface) ↔ Property interface

/--
An explicit visible definition implies implicit visible determination.
-/
theorem implicitDetermination_of_explicitDefinitionOnVisible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {Property : Interface -> Prop}
    (explicit :
      ExplicitDefinitionOnVisible Interface Visible project Property) :
    ImplicitlyDeterminedByVisible Interface Visible project Property := by
  refine ⟨?_⟩
  intro left right sameProjection
  constructor
  · intro hLeft
    have hVisibleLeft :
        explicit.visiblePredicate (project left) :=
      (explicit.correct left).mpr hLeft
    have hVisibleRight :
        explicit.visiblePredicate (project right) := by
      rw [← sameProjection]
      exact hVisibleLeft
    exact (explicit.correct right).mp hVisibleRight
  · intro hRight
    have hVisibleRight :
        explicit.visiblePredicate (project right) :=
      (explicit.correct right).mpr hRight
    have hVisibleLeft :
        explicit.visiblePredicate (project left) := by
      rw [sameProjection]
      exact hVisibleRight
    exact (explicit.correct left).mp hVisibleLeft

/-! ## Beth separation -/

/--
A Beth separation is a property-level projection gap.

The two enriched interfaces have the same visible projection, but the enriched
property holds on the formed side and fails on the shadow side.
-/
structure BethSeparation
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (Property : Interface -> Prop) :
    Type (max u v) where
  formed : Interface
  shadow : Interface
  sameProjection :
    project formed = project shadow
  property_formed :
    Property formed
  shadow_not_property :
    Property shadow -> False

namespace BethSeparation

/-- A Beth separation carries the underlying diagonal certificate. -/
def diagonalCertificate
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {Property : Interface -> Prop}
    (separation :
      BethSeparation Interface Visible project Property) :
    DiagonalCertificate Interface Visible project where
  left := separation.formed
  right := separation.shadow
  sameProjection := separation.sameProjection
  separatedInterface := by
    intro hEq
    have hShadow :
        Property separation.shadow := by
      rw [← hEq]
      exact separation.property_formed
    exact separation.shadow_not_property hShadow

/-- A Beth separation carries the underlying projection obstruction. -/
def projectionObstruction
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {Property : Interface -> Prop}
    (separation :
      BethSeparation Interface Visible project Property) :
    ProjectionObstruction Interface Visible project :=
  projectionObstructionOfDiagonalCertificate
    separation.diagonalCertificate

end BethSeparation

/-! ## Refutations -/

/--
A Beth separation refutes implicit visible determination of the enriched
property.
-/
theorem bethSeparation_refutes_implicitDetermination
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {Property : Interface -> Prop}
    (separation :
      BethSeparation Interface Visible project Property)
    (implicit :
      ImplicitlyDeterminedByVisible Interface Visible project Property) :
    False := by
  have hShadow :
      Property separation.shadow :=
    (implicit.invariant
      separation.formed
      separation.shadow
      separation.sameProjection).mp
      separation.property_formed
  exact separation.shadow_not_property hShadow

/--
A Beth separation refutes explicit visible definition of the enriched property.
-/
theorem bethSeparation_refutes_explicitDefinition
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {Property : Interface -> Prop}
    (separation :
      BethSeparation Interface Visible project Property)
    (explicit :
      ExplicitDefinitionOnVisible Interface Visible project Property) :
    False :=
  bethSeparation_refutes_implicitDetermination
    separation
    (implicitDetermination_of_explicitDefinitionOnVisible explicit)

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.ImplicitlyDeterminedByVisible
#print axioms Meta.ClosedStabilityTheorem.ExplicitDefinitionOnVisible
#print axioms Meta.ClosedStabilityTheorem.implicitDetermination_of_explicitDefinitionOnVisible
#print axioms Meta.ClosedStabilityTheorem.BethSeparation
#print axioms Meta.ClosedStabilityTheorem.BethSeparation.diagonalCertificate
#print axioms Meta.ClosedStabilityTheorem.BethSeparation.projectionObstruction
#print axioms Meta.ClosedStabilityTheorem.bethSeparation_refutes_implicitDetermination
#print axioms Meta.ClosedStabilityTheorem.bethSeparation_refutes_explicitDefinition
/- AXIOM_AUDIT_END -/
