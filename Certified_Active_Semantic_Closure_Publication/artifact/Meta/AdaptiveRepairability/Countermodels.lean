import Meta.AdaptiveRepairability.ExactPosterior

namespace Meta.AdaptiveRepairability.Countermodels

/-!
Four finite constructive countermodels isolating the hypotheses that cannot be
removed from the characterization theorem.
-/

namespace NonComposable

inductive Three where
  | zero
  | one
  | two

def response : Three → Three → Bool
  | .zero, .zero => true
  | .zero, .one => false
  | .zero, .two => false
  | .one, .zero => false
  | .one, .one => true
  | .one, .two => false
  | .two, .zero => false
  | .two, .one => false
  | .two, .two => true

def Different (x y : Three) : Prop := x ≠ y

structure LocalPairSeparator (x y : Three) where
  query : Three
  separated : response query x ≠ response query y

def localPairSeparation :
    ∀ x y : Three, Different x y → LocalPairSeparator x y := by
  intro x y hdifferent
  cases x <;> cases y
  · exact False.elim (hdifferent rfl)
  · exact ⟨Three.zero, fun heq => Bool.noConfusion heq⟩
  · exact ⟨Three.zero, fun heq => Bool.noConfusion heq⟩
  · exact ⟨Three.one, fun heq => Bool.noConfusion heq⟩
  · exact False.elim (hdifferent rfl)
  · exact ⟨Three.one, fun heq => Bool.noConfusion heq⟩
  · exact ⟨Three.two, fun heq => Bool.noConfusion heq⟩
  · exact ⟨Three.two, fun heq => Bool.noConfusion heq⟩
  · exact False.elim (hdifferent rfl)

def SingleQueryActionResolving (q : Three) : Prop :=
  ∀ x y : Three, response q x = response q y → x = y

theorem noSingleQueryActionResolving :
    ∀ q : Three, ¬ SingleQueryActionResolving q := by
  intro q hresolving
  cases q with
  | zero =>
      have heq := hresolving Three.one Three.two rfl
      exact Three.noConfusion heq
  | one =>
      have heq := hresolving Three.zero Three.two rfl
      exact Three.noConfusion heq
  | two =>
      have heq := hresolving Three.zero Three.one rfl
      exact Three.noConfusion heq

structure Witness where
  everyPairInitiallySeparable :
    ∀ x y : Three, Different x y → LocalPairSeparator x y
  noOneShotGlobalResolution :
    ∀ q : Three, ¬ SingleQueryActionResolving q

def nonComposableSeparabilityCountermodel : Witness :=
  {
    everyPairInitiallySeparable := localPairSeparation
    noOneShotGlobalResolution := noSingleQueryActionResolving
  }

end NonComposable

namespace NonExpressiveCandidate

def required (_ : Unit) : Bool := true

def interpret (_ : Unit) : Bool := false

theorem homogeneousWorldFiber :
    ∀ w₁ w₂ : Unit, required w₁ = required w₂ := by
  intro w₁ w₂
  cases w₁
  cases w₂
  rfl

theorem noCandidateRealizesHomogeneousAction :
    ¬ (∃ candidate : Unit,
      ∀ w : Unit, interpret candidate = required w) := by
  rintro ⟨candidate, hcorrect⟩
  cases candidate
  have himpossible := hcorrect ()
  exact Bool.noConfusion himpossible

structure Witness where
  informationClosed : ∀ w₁ w₂ : Unit, required w₁ = required w₂
  decisionLanguageIncomplete :
    ¬ (∃ candidate : Unit,
      ∀ w : Unit, interpret candidate = required w)

def nonExpressiveCandidateCountermodel : Witness :=
  {
    informationClosed := homogeneousWorldFiber
    decisionLanguageIncomplete := noCandidateRealizesHomogeneousAction
  }

end NonExpressiveCandidate

namespace PrivateWorldLeak

def privatePolicy (world : Bool) : Bool := world

theorem privatePolicyCorrect : ∀ world, privatePolicy world = world := by
  intro world
  rfl

theorem noPublicPolicyClosesBoth :
    ¬ (∃ publicPolicy : Unit → Bool,
      ∀ world : Bool, publicPolicy () = world) := by
  rintro ⟨publicPolicy, hcorrect⟩
  have hfalse := hcorrect false
  have htrue := hcorrect true
  have himpossible : false = true := hfalse.symm.trans htrue
  exact Bool.noConfusion himpossible

structure Witness where
  privateSolver : Bool → Bool
  privateSolverCorrect : ∀ world, privateSolver world = world
  noPublicSolver :
    ¬ (∃ publicPolicy : Unit → Bool,
      ∀ world : Bool, publicPolicy () = world)

def privateWorldRepairCountermodel : Witness :=
  {
    privateSolver := privatePolicy
    privateSolverCorrect := privatePolicyCorrect
    noPublicSolver := noPublicPolicyClosesBoth
  }

end PrivateWorldLeak

namespace RegressionOutsideFrame

structure State where
  protectedSnapshot : Bool

def before : State := ⟨false⟩

def after : State := ⟨true⟩

def compatible (_ : State) (_ : Unit) : Prop := True

theorem fiberMonotone :
    ∀ w : Unit, compatible after w → compatible before w := by
  intro w _
  exact True.intro

theorem protectedFrameRegresses :
    before.protectedSnapshot ≠ after.protectedSnapshot := by
  intro heq
  exact Bool.noConfusion heq

structure Witness where
  posteriorIncluded :
    ∀ w : Unit, compatible after w → compatible before w
  protectedStateChanged :
    before.protectedSnapshot ≠ after.protectedSnapshot

def fiberMonotonicityDoesNotPreserveFrame : Witness :=
  {
    posteriorIncluded := fiberMonotone
    protectedStateChanged := protectedFrameRegresses
  }

end RegressionOutsideFrame

/- AXIOM_AUDIT_BEGIN -/
#print axioms NonComposable.nonComposableSeparabilityCountermodel
#print axioms NonExpressiveCandidate.nonExpressiveCandidateCountermodel
#print axioms PrivateWorldLeak.privateWorldRepairCountermodel
#print axioms RegressionOutsideFrame.fiberMonotonicityDoesNotPreserveFrame
/- AXIOM_AUDIT_END -/
