import Meta.Core.ClosedStabilityTheorem

/-!
# Beth implicit/explicit projection core

This file gives the internal Beth layer for the standalone meta package.

The constructive content is deliberately image-indexed.  From the fact that a
visible value determines at most one enriched interface in its fiber, one gets
an explicit recovery on every visible value that is already realized by an
interface witness.  Conversely, such a unique explicit recovery on realized
visible values implies fiber faithfulness.

Thus this file proves the internal Beth equivalence:

```text
implicit determination by visible
↔
explicit definition on realized visible fibers
↔
fiber contractibility
```

No global choice of an interface for an arbitrary visible value is used.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v s

/-! ## Implicit determination and realized visible fibers -/

/--
Implicit determination by the visible projection.

This is the Beth-style implicit side: if two enriched interfaces have the same
visible projection, they are already the same interface.
-/
abbrev ImplicitlyDeterminedByVisible
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Prop :=
  ProjectionFiberFaithful Interface Visible project

/-- A visible value together with an enriched interface that realizes it. -/
structure VisibleRealization
    {Interface : Type u}
    {Visible : Type v}
    (project : Interface -> Visible)
    (visible : Visible) :
    Type (max u v) where
  interface : Interface
  projected : project interface = visible

/-- The realized visible value carried by an interface. -/
def visibleRealizationOfInterface
    {Interface : Type u}
    {Visible : Type v}
    (project : Interface -> Visible)
    (interface : Interface) :
    VisibleRealization project (project interface) where
  interface := interface
  projected := rfl

/-! ## Explicit definition on the realized image -/

/--
Explicit definition on realized visible fibers.

The recovery is not a choice over all visible values.  It receives a realization
witness for the visible value and returns the unique enriched interface in that
realized fiber.
-/
structure ExplicitDefinitionOnRealizedVisible
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Type (max u v) where
  recover :
    (visible : Visible) ->
      VisibleRealization project visible ->
        Interface
  recovers_projection :
    (visible : Visible) ->
      (realization : VisibleRealization project visible) ->
        project (recover visible realization) = visible
  unique_in_fiber :
    (visible : Visible) ->
      (realization : VisibleRealization project visible) ->
        (interface : Interface) ->
          project interface = visible ->
            recover visible realization = interface

/--
Implicit determination gives explicit recovery on each realized visible fiber.
-/
def explicitDefinitionOnRealizedVisible_of_implicitDetermination
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (implicit :
      ImplicitlyDeterminedByVisible Interface Visible project) :
    ExplicitDefinitionOnRealizedVisible Interface Visible project where
  recover := fun _visible realization =>
    realization.interface
  recovers_projection := fun _visible realization =>
    realization.projected
  unique_in_fiber := by
    intro _visible realization interface hProject
    exact
      implicit.preserves
        realization.interface
        interface
        (Eq.trans realization.projected hProject.symm)

/--
An explicit unique recovery on realized visible fibers implies implicit
determination by visible projection.
-/
theorem implicitDetermination_of_explicitDefinitionOnRealizedVisible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (explicit :
      ExplicitDefinitionOnRealizedVisible Interface Visible project) :
    ImplicitlyDeterminedByVisible Interface Visible project := by
  refine ⟨?_⟩
  intro left right sameProjection
  let realization := visibleRealizationOfInterface project left
  have hLeft :
      explicit.recover (project left) realization = left :=
    explicit.unique_in_fiber
      (project left)
      realization
      left
      rfl
  have hRight :
      explicit.recover (project left) realization = right :=
    explicit.unique_in_fiber
      (project left)
      realization
      right
      sameProjection.symm
  exact Eq.trans hLeft.symm hRight

/--
Internal Beth equivalence: implicit determination is equivalent to the
existence of an explicit unique recovery on realized visible fibers.
-/
theorem implicitDetermination_iff_explicitDefinitionOnRealizedVisible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible} :
    ImplicitlyDeterminedByVisible Interface Visible project ↔
      Nonempty
        (ExplicitDefinitionOnRealizedVisible Interface Visible project) := by
  constructor
  · intro implicit
    exact
      ⟨explicitDefinitionOnRealizedVisible_of_implicitDetermination
        implicit⟩
  · intro hExplicit
    cases hExplicit with
    | intro explicit =>
        exact
          implicitDetermination_of_explicitDefinitionOnRealizedVisible
            explicit

/-! ## Obstructions as anti-Beth data -/

/--
A structural projection gap refutes explicit definition on realized visible
fibers.
-/
theorem structuralGap_refutes_explicitDefinitionOnRealizedVisible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (gap :
      ProjectionObstruction Interface Visible project)
    (explicit :
      ExplicitDefinitionOnRealizedVisible Interface Visible project) :
    False :=
  projectionObstruction_notFiberFaithful
    gap
    (implicitDetermination_of_explicitDefinitionOnRealizedVisible explicit)

/--
A local operational recovery gap refutes explicit definition on realized
visible fibers.
-/
theorem localRecoveryGap_refutes_explicitDefinitionOnRealizedVisible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      LocalProjectiveRecovery Interface Visible project RepairOf)
    (explicit :
      ExplicitDefinitionOnRealizedVisible Interface Visible project) :
    False :=
  structuralGap_refutes_explicitDefinitionOnRealizedVisible
    (localProjectiveRecovery_obstruction gap)
    explicit

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.ImplicitlyDeterminedByVisible
#print axioms Meta.ClosedStabilityTheorem.VisibleRealization
#print axioms Meta.ClosedStabilityTheorem.visibleRealizationOfInterface
#print axioms Meta.ClosedStabilityTheorem.ExplicitDefinitionOnRealizedVisible
#print axioms Meta.ClosedStabilityTheorem.explicitDefinitionOnRealizedVisible_of_implicitDetermination
#print axioms Meta.ClosedStabilityTheorem.implicitDetermination_of_explicitDefinitionOnRealizedVisible
#print axioms Meta.ClosedStabilityTheorem.implicitDetermination_iff_explicitDefinitionOnRealizedVisible
#print axioms Meta.ClosedStabilityTheorem.structuralGap_refutes_explicitDefinitionOnRealizedVisible
#print axioms Meta.ClosedStabilityTheorem.localRecoveryGap_refutes_explicitDefinitionOnRealizedVisible
/- AXIOM_AUDIT_END -/
