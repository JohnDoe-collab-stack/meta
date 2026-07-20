import Meta.Core.StrictRelaxation

/-!
# Directional specialization of strict relaxed usage

This module contains the concrete directional countermodel witnessing that
relaxed use is strictly more expressive than transport induced by equality.
The generic representation and asymmetry theorems remain in
`Meta.Core.StrictRelaxation`.
-/

namespace Meta
namespace RelaxedUsageRegime

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

/-- Directional use composition satisfies identity and associativity laws. -/
def directionalLawfulCompositionalUse :
    LawfulCompositionalUse
      directionalRelaxedRegime
      directionalCompositionalUse where
  leftIdentity := by
    intro gamma x y use
    cases use <;> rfl
  rightIdentity := by
    intro gamma x y use
    cases use <;> rfl
  associativity := by
    intro gamma w x y z first second third
    cases first <;> cases second <;> cases third <;> rfl

/-- Directional transport is a lawful image of directional use. -/
def directionalCompositionalTransport :
    CompositionalTransport
      directionalRelaxedRegime
      directionalCompositionalUse where
  useLaws := directionalLawfulCompositionalUse
  outIdentity := by
    intro gamma rho phase
    cases phase with
    | before => exact PhaseUse.reflBefore
    | after => exact PhaseUse.reflAfter
  outCompose := by
    intro gamma rho x y z first second
    exact first.compose second
  outLeftIdentity := by
    intro gamma rho x y relation
    cases relation <;> rfl
  outRightIdentity := by
    intro gamma rho x y relation
    cases relation <;> rfl
  outAssociativity := by
    intro gamma rho w x y z first second third
    cases first <;> cases second <;> cases third <;> rfl
  transportIdentity := by
    intro gamma rho x
    cases x <;> rfl
  transportComposition := by
    intro gamma rho x y z first second
    rfl

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
  not_exactProjective_of_asymmetric_use
    directional_hasUse_forward
    directional_not_hasUse_backward
    representation

/-- The directional regime is not projectively representable. -/
theorem directionalRelaxedRegime_not_projectivelyRepresentable
    (represented : ProjectivelyRepresentable directionalRelaxedRegime) :
    False :=
  not_projectivelyRepresentable_of_asymmetric_use
    directional_hasUse_forward
    directional_not_hasUse_backward
    represented

/-- Class-level strictness on the concrete directional countermodel. -/
theorem projectedRepresentability_strict :
    ProjectivelyRepresentable.{0, 0}
        (relaxedRegimeOfProjection (fun phase : Phase => phase)) /\
      (ProjectivelyRepresentable.{0, 0} directionalRelaxedRegime -> False) :=
  And.intro
    (relaxedRegimeOfProjection_projectivelyRepresentable
      (fun phase : Phase => phase))
    directionalRelaxedRegime_not_projectivelyRepresentable

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
#print axioms Meta.RelaxedUsageRegime.Phase
#print axioms Meta.RelaxedUsageRegime.PhaseUse
#print axioms Meta.RelaxedUsageRegime.directionalRelaxedRegime
#print axioms Meta.RelaxedUsageRegime.directionalCompositionalUse
#print axioms Meta.RelaxedUsageRegime.directionalLawfulCompositionalUse
#print axioms Meta.RelaxedUsageRegime.directionalCompositionalTransport
#print axioms Meta.RelaxedUsageRegime.directionalTransportChain_forward
#print axioms Meta.RelaxedUsageRegime.directionalRelaxedRegime_not_exactProjective
#print axioms Meta.RelaxedUsageRegime.directionalRelaxedRegime_not_projectivelyRepresentable
#print axioms Meta.RelaxedUsageRegime.projectedRepresentability_strict
#print axioms Meta.RelaxedUsageRegime.strictRelaxationOfIdentity
#print axioms Meta.RelaxedUsageRegime.projectedIdentityTransport_strictlyIncludedIn_relaxedUsageTransport
/- AXIOM_AUDIT_END -/
