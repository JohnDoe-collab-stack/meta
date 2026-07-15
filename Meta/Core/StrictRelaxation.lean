import Meta.Core.TransportCoherence
import Meta.Core.ProjectedIdentity

/-!
# Strict relaxation of projected identity

An exact projective representation makes the propositional use relation
`HasUse` reflexive, symmetric, and transitive because it identifies use with an
equality in a visible type.

Every projected identity has a canonical realization as a composable relaxed
regime. The generic asymmetry obstruction proves that any one-way use lies
outside exact projective representation. Concrete witnesses of that
obstruction belong to `Meta.Core.Specialization`; the minimal one is defined
in `Meta.Core.Specialization.DirectionalRelaxation`.

The generic result concerns `HasUse`; it is not a comparison of the total
expressive power of unrelated formalisms.
-/

namespace Meta
namespace RelaxedUsageRegime

universe u v

/-! ## Exact projective representations -/

/--
An exact projective representation of a relaxed use relation.

The visible type and projection may depend on the regime context. Exactness is
the bidirectional statement that use is available precisely when the two
projected values are equal.
-/
structure ExactProjectiveRepresentation
    {X : Type u}
    (I : RelaxedInterfaceRegime X) where
  Visible :
    I.Ctx -> Type v

  project :
    (gamma : I.Ctx) ->
      X -> Visible gamma

  use_iff_projectedIdentity :
    (gamma : I.Ctx) ->
    (x y : X) ->
      HasUse I gamma x y <->
        project gamma x = project gamma y

/-- Propositional existence of an exact projective representation. -/
def ProjectivelyRepresentable
    {X : Type u}
    (I : RelaxedInterfaceRegime X) :
    Prop :=
  Nonempty (ExactProjectiveRepresentation.{u, v} I)

/-- Exact projective use is reflexive. -/
theorem hasUse_refl_of_exactProjectiveRepresentation
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    (representation : ExactProjectiveRepresentation I)
    (gamma : I.Ctx)
    (x : X) :
    HasUse I gamma x x :=
  (representation.use_iff_projectedIdentity gamma x x).mpr rfl

/-- Exact projective use is symmetric. -/
theorem hasUse_symm_of_exactProjectiveRepresentation
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    (representation : ExactProjectiveRepresentation I)
    {gamma : I.Ctx}
    {x y : X}
    (use : HasUse I gamma x y) :
    HasUse I gamma y x :=
  (representation.use_iff_projectedIdentity gamma y x).mpr
    ((representation.use_iff_projectedIdentity gamma x y).mp use).symm

/-- Any asymmetric use refutes every exact projective representation. -/
theorem not_exactProjective_of_asymmetric_use
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (forward : HasUse I gamma x y)
    (noBackward : HasUse I gamma y x -> False)
    (representation : ExactProjectiveRepresentation I) :
    False :=
  noBackward
    (hasUse_symm_of_exactProjectiveRepresentation
      representation
      forward)

/-- Asymmetric use also refutes propositional projective representability. -/
theorem not_projectivelyRepresentable_of_asymmetric_use
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    {gamma : I.Ctx}
    {x y : X}
    (forward : HasUse I gamma x y)
    (noBackward : HasUse I gamma y x -> False)
    (represented : ProjectivelyRepresentable I) :
    False :=
  Nonempty.elim represented
    (not_exactProjective_of_asymmetric_use forward noBackward)

/-- Exact projective use is transitive. -/
theorem hasUse_trans_of_exactProjectiveRepresentation
    {X : Type u}
    {I : RelaxedInterfaceRegime X}
    (representation : ExactProjectiveRepresentation I)
    {gamma : I.Ctx}
    {x y z : X}
    (useXY : HasUse I gamma x y)
    (useYZ : HasUse I gamma y z) :
    HasUse I gamma x z :=
  (representation.use_iff_projectedIdentity gamma x z).mpr
    (((representation.use_iff_projectedIdentity gamma x y).mp useXY).trans
      ((representation.use_iff_projectedIdentity gamma y z).mp useYZ))

/-! ## Canonical embedding of projected identity -/

/--
The relaxed regime canonically induced by a projection.

Its uses and output relations are the projected equalities themselves.
Separation remains independent data, so a non-contractive use still records
both internal distinction and visible coordination.
-/
def relaxedRegimeOfProjection
    {X : Type u}
    {Visible : Type v}
    (project : X -> Visible) :
    RelaxedInterfaceRegime.{u, 0, 0, v, 0, 0, 0, 0} X where
  Ctx := Unit
  defaultCtx := ()
  Read := fun _ => Unit
  defaultRead := fun _ => ()
  Out := fun _ _ => Visible
  read := fun _ _ x => project x
  Sep := fun _ x y => PLift (x = y -> False)
  Coord := fun _ x y => PLift (project x = project y)
  Use := fun _ x y => PLift (project x = project y)
  OutRel := fun _ _ left right => PLift (left = right)
  use_of_noncontractive := fun _ coordination => coordination
  transport := fun use _ => use

/-- The canonical projective regime is exactly represented by its projection. -/
def exactProjectiveRepresentationOfProjection
    {X : Type u}
    {Visible : Type v}
    (project : X -> Visible) :
    ExactProjectiveRepresentation
      (relaxedRegimeOfProjection project) where
  Visible := fun _ => Visible
  project := fun _ => project
  use_iff_projectedIdentity := by
    intro gamma x y
    constructor
    · intro use
      exact Nonempty.elim use (fun projectedIdentity => projectedIdentity.down)
    · intro projectedIdentity
      exact Nonempty.intro (PLift.up projectedIdentity)

/-- Every projection-induced relaxed regime is projectively representable. -/
theorem relaxedRegimeOfProjection_projectivelyRepresentable
    {X : Type u}
    {Visible : Type v}
    (project : X -> Visible) :
    ProjectivelyRepresentable.{u, v}
      (relaxedRegimeOfProjection project) :=
  Nonempty.intro (exactProjectiveRepresentationOfProjection project)

/-- Projected uses carry identity and composition intrinsically. -/
def compositionalUseOfProjection
    {X : Type u}
    {Visible : Type v}
    (project : X -> Visible) :
    CompositionalUse (relaxedRegimeOfProjection project) where
  identity := fun _ _ => PLift.up rfl
  compose := fun useXY useYZ => PLift.up (useXY.down.trans useYZ.down)

/-- Projected use composition satisfies the category laws on witnesses. -/
def lawfulCompositionalUseOfProjection
    {X : Type u}
    {Visible : Type v}
    (project : X -> Visible) :
    LawfulCompositionalUse
      (relaxedRegimeOfProjection project)
      (compositionalUseOfProjection project) where
  leftIdentity := by
    intro gamma x y use
    cases use
    rfl
  rightIdentity := by
    intro gamma x y use
    cases use
    rfl
  associativity := by
    intro gamma w x y z first second third
    cases first
    cases second
    cases third
    rfl

/-- Projected equality transport preserves identity and composition. -/
def compositionalTransportOfProjection
    {X : Type u}
    {Visible : Type v}
    (project : X -> Visible) :
    CompositionalTransport
      (relaxedRegimeOfProjection project)
      (compositionalUseOfProjection project) where
  useLaws := lawfulCompositionalUseOfProjection project
  outIdentity := fun _ _ _ => PLift.up rfl
  outCompose := by
    intro gamma rho x y z first second
    exact PLift.up (first.down.trans second.down)
  outLeftIdentity := by
    intro gamma rho x y relation
    cases relation
    rfl
  outRightIdentity := by
    intro gamma rho x y relation
    cases relation
    rfl
  outAssociativity := by
    intro gamma rho w x y z first second third
    cases first
    cases second
    cases third
    rfl
  transportIdentity := by
    intro gamma rho x
    rfl
  transportComposition := by
    intro gamma rho x y z first second
    rfl

/--
Data-level inclusion of projected identity transport in relaxed use transport.
-/
structure ProjectedIdentityRelaxedEmbedding
    {X : Type u}
    {Visible : Type v}
    (project : X -> Visible) where
  hasUse_iff_projectedIdentity :
    (x y : X) ->
      HasUse (relaxedRegimeOfProjection project) () x y <->
        ClosedStabilityTheorem.ProjectedIdentity project x y

  compositional :
    CompositionalUse (relaxedRegimeOfProjection project)

/-- Every projection has a canonical exact embedding into relaxed use. -/
def projectedIdentityTransport_in_relaxedUsageTransport
    {X : Type u}
    {Visible : Type v}
    (project : X -> Visible) :
    ProjectedIdentityRelaxedEmbedding project where
  hasUse_iff_projectedIdentity := by
    intro x y
    exact
      (exactProjectiveRepresentationOfProjection project).use_iff_projectedIdentity
        () x y
  compositional := compositionalUseOfProjection project

/-- Internal identity is the identity-projection instance of the embedding. -/
def internalIdentityTransport_in_projectedIdentityTransport
    (X : Type u) :
    ProjectedIdentityRelaxedEmbedding (fun x : X => x) :=
  projectedIdentityTransport_in_relaxedUsageTransport (fun x : X => x)
end RelaxedUsageRegime
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedUsageRegime.ExactProjectiveRepresentation
#print axioms Meta.RelaxedUsageRegime.ProjectivelyRepresentable
#print axioms Meta.RelaxedUsageRegime.hasUse_symm_of_exactProjectiveRepresentation
#print axioms Meta.RelaxedUsageRegime.not_exactProjective_of_asymmetric_use
#print axioms Meta.RelaxedUsageRegime.not_projectivelyRepresentable_of_asymmetric_use
#print axioms Meta.RelaxedUsageRegime.relaxedRegimeOfProjection
#print axioms Meta.RelaxedUsageRegime.exactProjectiveRepresentationOfProjection
#print axioms Meta.RelaxedUsageRegime.projectedIdentityTransport_in_relaxedUsageTransport
#print axioms Meta.RelaxedUsageRegime.internalIdentityTransport_in_projectedIdentityTransport
#print axioms Meta.RelaxedUsageRegime.compositionalTransportOfProjection
/- AXIOM_AUDIT_END -/
