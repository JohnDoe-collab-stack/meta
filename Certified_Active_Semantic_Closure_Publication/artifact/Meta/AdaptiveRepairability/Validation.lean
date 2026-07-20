import Meta.AdaptiveRepairability.Countermodels

namespace Meta.AdaptiveRepairability

/-!
Single integration certificate for the adaptive-repairability characterization.
It aggregates the independently audited measure, no-go, operational equivalence,
constructive synthesis, exact-posterior law, and hypothesis countermodels without
changing any quantifier of the component results.
-/

structure AdaptiveRepairabilityFormalValidation where
  conflictMeasureCriterion :
    ∀ (E : FiniteActionModel) (s : E.State) (g : E.Obligation),
      actionConflictMeasure E s g = 0 ↔ ActionSufficientAt E s g
  conflictMeasureMonotone :
    ∀ (E : FiniteActionModel)
      (before after : E.State)
      (g : E.Obligation),
      FiberIncluded E after before →
      actionConflictMeasure E after g ≤ actionConflictMeasure E before g
  conflictMeasureStrictDecrease :
    ∀ (E : FiniteActionModel)
      (before after : E.State)
      (g : E.Obligation)
      (w₁ w₂ : E.World),
      FiberIncluded E after before →
      ActionConflict E before g w₁ w₂ →
      ¬ (Compatible E after w₁ ∧ Compatible E after w₂) →
      actionConflictMeasure E after g < actionConflictMeasure E before g
  adaptiveNoGo :
    ∀ (E : FinitePublicEnvironment)
      (D : PublicDecisionDoctrine E)
      (s : E.actionModel.State)
      (g : E.actionModel.Obligation)
      (w₁ w₂ : E.actionModel.World),
      ActionConflict E.actionModel s g w₁ w₂ →
      PubliclyIndistinguishable E s g w₁ w₂ →
      ¬ CertifiedRepairableAt D s g
  operationalCharacterization :
    ∀ (E : FinitePublicEnvironment)
      (D : PublicDecisionDoctrine E)
      (_complete : DecisionRealizationComplete D)
      (s : E.actionModel.State)
      (g : E.actionModel.Obligation),
      CertifiedRepairableAt D s g ↔ UniformlyActionResolvableAt E s g
  constructiveSynthesis :
    ∀ (E : FinitePublicEnvironment)
      (D : PublicDecisionDoctrine E)
      (_complete : DecisionRealizationComplete D)
      (Invariant : E.actionModel.State → E.actionModel.Obligation → Prop)
      (g : E.actionModel.Obligation)
      (_separable : ComposableAdaptivePairSeparability E Invariant g)
      (s : E.actionModel.State),
      Invariant s g →
      PublicFiberNonempty E s →
      CertifiedRepairableAt D s g
  exactLeafPosterior :
    ∀ (E : FinitePublicEnvironment)
      (complete : ExactPosteriorRepairComplete E)
      (s : E.actionModel.State)
      (g : E.actionModel.Obligation)
      (tree : PublicRepairTree E g s),
      GeneratedByExactCompiler complete tree →
      ∀ (leaf : Leaf tree) (w : E.actionModel.World),
        Compatible E.actionModel (leafState tree leaf) w ↔
          ReachesLeaf tree w leaf
  nonComposableCountermodel : Countermodels.NonComposable.Witness
  nonExpressiveCandidateCountermodel : Countermodels.NonExpressiveCandidate.Witness
  privateWorldLeakCountermodel : Countermodels.PrivateWorldLeak.Witness
  frameRegressionCountermodel : Countermodels.RegressionOutsideFrame.Witness

def adaptiveRepairabilityFormalValidation : AdaptiveRepairabilityFormalValidation :=
  {
    conflictMeasureCriterion := actionConflictMeasure_eq_zero_iff
    conflictMeasureMonotone := actionConflictMeasure_monotone
    conflictMeasureStrictDecrease := actionConflictMeasure_strictly_decreases
    adaptiveNoGo := fun _E D _s _g _w₁ _w₂ => adaptivePublicNoGo D
    operationalCharacterization :=
      fun _E D complete s g =>
        certifiedRepairable_iff_uniformlyActionResolvable D complete s g
    constructiveSynthesis :=
      fun _E D complete Invariant g separable s =>
        composableSeparability_implies_certifiedRepairable
          D complete Invariant g separable s
    exactLeafPosterior :=
      fun _E complete _s _g tree => exactGeneratedTree_leafPosterior complete tree
    nonComposableCountermodel :=
      Countermodels.NonComposable.nonComposableSeparabilityCountermodel
    nonExpressiveCandidateCountermodel :=
      Countermodels.NonExpressiveCandidate.nonExpressiveCandidateCountermodel
    privateWorldLeakCountermodel :=
      Countermodels.PrivateWorldLeak.privateWorldRepairCountermodel
    frameRegressionCountermodel :=
      Countermodels.RegressionOutsideFrame.fiberMonotonicityDoesNotPreserveFrame
  }

/- AXIOM_AUDIT_BEGIN -/
#print axioms adaptiveRepairabilityFormalValidation
/- AXIOM_AUDIT_END -/
