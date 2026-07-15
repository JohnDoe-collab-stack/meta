import Meta.Core.RelaxedUsageRegime
import Meta.Core.ProjectedIdentity

/-!
# Strict relaxation of projected identity

An exact projective representation makes the propositional use relation
`HasUse` reflexive, symmetric, and transitive because it identifies use with an
equality in a visible type.

Every projected identity has a canonical realization as a composable relaxed
regime. The converse fails: the proof-relevant directional regime below admits
the intrinsic transition `before -> after`, composes its uses, and has no use
from `after` back to `before`. It therefore cannot be represented exactly by
any projected equality.

The strictness result concerns `HasUse`; it is not a comparison of the total
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

/-- Projected uses carry identity and composition intrinsically. -/
def compositionalUseOfProjection
    {X : Type u}
    {Visible : Type v}
    (project : X -> Visible) :
    CompositionalUse (relaxedRegimeOfProjection project) where
  identity := fun _ _ => PLift.up rfl
  compose := fun useXY useYZ => PLift.up (useXY.down.trans useYZ.down)

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

/-! ## A composable directional regime -/

/-- Two phases used by the minimal directional countermodel. -/
inductive Phase where
  | before
  | after

/--
Proof-relevant directed use on phases.

There are reflexive uses and a forward use, but no constructor for a backward
use.
-/
inductive PhaseUse : Phase -> Phase -> Type where
  | reflBefore : PhaseUse Phase.before Phase.before
  | advance : PhaseUse Phase.before Phase.after
  | reflAfter : PhaseUse Phase.after Phase.after

/-- The two phases are internally distinct. -/
theorem phase_before_ne_after :
    Phase.before = Phase.after -> False := by
  intro equality
  cases equality

/-- Composition of all possible directional uses. -/
def PhaseUse.compose
    {x y z : Phase}
    (useXY : PhaseUse x y)
    (useYZ : PhaseUse y z) :
    PhaseUse x z := by
  cases useXY with
  | reflBefore =>
      exact useYZ
  | advance =>
      cases useYZ with
      | reflAfter =>
          exact PhaseUse.advance
  | reflAfter =>
      exact useYZ

/--
The minimal relaxed regime whose use relation is genuinely directional.
-/
def directionalRelaxedRegime :
    RelaxedInterfaceRegime.{0, 0, 0, 0, 0, 0, 0, 0} Phase where
  Ctx := Unit
  defaultCtx := ()
  Read := fun _ => Unit
  defaultRead := fun _ => ()
  Out := fun _ _ => Phase
  read := fun _ _ phase => phase
  Sep := fun _ left right => PLift (left = right -> False)
  Coord := fun _ left right => PhaseUse left right
  Use := fun _ left right => PhaseUse left right
  OutRel := fun _ _ left right => PhaseUse left right
  use_of_noncontractive := fun _ coordination => coordination
  transport := fun use _ => use

/-- The directional regime has intrinsic identities and composition. -/
def directionalCompositionalUse :
    CompositionalUse directionalRelaxedRegime where
  identity := by
    intro gamma phase
    cases phase with
    | before => exact PhaseUse.reflBefore
    | after => exact PhaseUse.reflAfter
  compose := fun useXY useYZ => useXY.compose useYZ

/-- The forward transition is non-contractive, not merely postulated as use. -/
def directionalNonContractiveUse_forward :
    NonContractiveUse
      directionalRelaxedRegime
      ()
      Phase.before
      Phase.after where
  separation := PLift.up phase_before_ne_after
  coordination := PhaseUse.advance

/-- The full intrinsic transport chain for the forward transition. -/
def directionalTransportChain_forward :
    LocalTransportChain
      directionalRelaxedRegime
      ()
      Phase.before
      Phase.after
      () :=
  defaultLocalTransportChain directionalNonContractiveUse_forward

/-- Use is available from `before` to `before`. -/
theorem directional_hasUse_reflBefore :
    HasUse
      directionalRelaxedRegime
      ()
      Phase.before
      Phase.before :=
  Nonempty.intro PhaseUse.reflBefore

/-- Use is available from `before` to `after`. -/
theorem directional_hasUse_forward :
    HasUse
      directionalRelaxedRegime
      ()
      Phase.before
      Phase.after :=
  Nonempty.intro
    (NonContractiveUse.use directionalNonContractiveUse_forward)

/-- Use is available from `after` to `after`. -/
theorem directional_hasUse_reflAfter :
    HasUse
      directionalRelaxedRegime
      ()
      Phase.after
      Phase.after :=
  Nonempty.intro PhaseUse.reflAfter

/-- No use witness exists from `after` back to `before`. -/
theorem directional_not_hasUse_backward :
    HasUse
      directionalRelaxedRegime
      ()
      Phase.after
      Phase.before -> False := by
  intro use
  exact Nonempty.elim use (fun impossible => by cases impossible)

/-- First required composition test: `before -> before -> after`. -/
theorem directional_compose_reflBefore_advance :
    PhaseUse.compose PhaseUse.reflBefore PhaseUse.advance =
      PhaseUse.advance :=
  rfl

/-- Second required composition test: `before -> after -> after`. -/
theorem directional_compose_advance_reflAfter :
    PhaseUse.compose PhaseUse.advance PhaseUse.reflAfter =
      PhaseUse.advance :=
  rfl

/--
The directional regime has no exact projective representation.

Any projected equality would turn its forward use into a backward use by
symmetry, contradicting the inductive shape of `PhaseUse`.
-/
theorem directionalRelaxedRegime_not_exactProjective
    (representation :
      ExactProjectiveRepresentation directionalRelaxedRegime) :
    False :=
  directional_not_hasUse_backward
    (hasUse_symm_of_exactProjectiveRepresentation
      representation
      directional_hasUse_forward)

/-! ## Strict inclusion -/

/--
Intrinsic witness that relaxed use is strictly broader than exact projected
identity at the level of `HasUse`.
-/
structure StrictRelaxationOfIdentity where
  directionalComposition :
    CompositionalUse directionalRelaxedRegime

  forwardNonContractive :
    NonContractiveUse
      directionalRelaxedRegime
      ()
      Phase.before
      Phase.after

  forwardTransportChain :
    LocalTransportChain
      directionalRelaxedRegime
      ()
      Phase.before
      Phase.after
      ()

  forwardUse :
    HasUse
      directionalRelaxedRegime
      ()
      Phase.before
      Phase.after

  backwardUseRefuted :
    HasUse
      directionalRelaxedRegime
      ()
      Phase.after
      Phase.before -> False

/-- Canonical strictness witness carried entirely by the relaxed regime. -/
def strictRelaxationOfIdentity :
    StrictRelaxationOfIdentity where
  directionalComposition := directionalCompositionalUse
  forwardNonContractive := directionalNonContractiveUse_forward
  forwardTransportChain := directionalTransportChain_forward
  forwardUse := directional_hasUse_forward
  backwardUseRefuted := directional_not_hasUse_backward

/--
Final strict-inclusion theorem.

The generic constructor `projectedIdentityTransport_in_relaxedUsageTransport`
is the inclusion direction. This inhabitant supplies a composable relaxed use
relation outside the exactly projective class.
-/
theorem projectedIdentityTransport_strictlyIncludedIn_relaxedUsageTransport :
    Nonempty StrictRelaxationOfIdentity /\
      (ExactProjectiveRepresentation directionalRelaxedRegime -> False) :=
  And.intro
    (Nonempty.intro strictRelaxationOfIdentity)
    directionalRelaxedRegime_not_exactProjective

end RelaxedUsageRegime
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedUsageRegime.ExactProjectiveRepresentation
#print axioms Meta.RelaxedUsageRegime.hasUse_symm_of_exactProjectiveRepresentation
#print axioms Meta.RelaxedUsageRegime.projectedIdentityTransport_in_relaxedUsageTransport
#print axioms Meta.RelaxedUsageRegime.internalIdentityTransport_in_projectedIdentityTransport
#print axioms Meta.RelaxedUsageRegime.directionalRelaxedRegime
#print axioms Meta.RelaxedUsageRegime.directionalCompositionalUse
#print axioms Meta.RelaxedUsageRegime.directionalTransportChain_forward
#print axioms Meta.RelaxedUsageRegime.directionalRelaxedRegime_not_exactProjective
#print axioms Meta.RelaxedUsageRegime.strictRelaxationOfIdentity
#print axioms Meta.RelaxedUsageRegime.projectedIdentityTransport_strictlyIncludedIn_relaxedUsageTransport
/- AXIOM_AUDIT_END -/
