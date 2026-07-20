import Meta.AdaptiveRepairability.OperationalCharacterization

namespace Meta.AdaptiveRepairability

/-!
Constructive synthesis from composable adaptive pair separators.

The only termination measure is the computed number of action-conflicting world
pairs.  Every recursive continuation is attached to a concrete leaf of the
chosen public episode, and strict decrease is derived from posterior soundness
and the episode's separation proof.
-/

structure ComposablePairSeparatingEpisode
    (E : FinitePublicEnvironment)
    (Invariant : E.actionModel.State → E.actionModel.Obligation → Prop)
    (s : E.actionModel.State)
    (g : E.actionModel.Obligation)
    (w₁ w₂ : E.actionModel.World) where
  episode : PublicRepairTree E g s
  separated :
    ∀ leaf : Leaf episode,
      ¬ (Compatible E.actionModel (leafState episode leaf) w₁ ∧
        Compatible E.actionModel (leafState episode leaf) w₂)
  invariantPreserved :
    ∀ leaf : Leaf episode, Invariant (leafState episode leaf) g

def ComposableAdaptivePairSeparability
    (E : FinitePublicEnvironment)
    (Invariant : E.actionModel.State → E.actionModel.Obligation → Prop)
    (g : E.actionModel.Obligation) : Type :=
  ∀ (s : E.actionModel.State),
    Invariant s g →
    ∀ w₁ w₂,
      ActionConflict E.actionModel s g w₁ w₂ →
      ComposablePairSeparatingEpisode E Invariant s g w₁ w₂

theorem separatingEpisode_strictlyDecreasesMeasure
    {E : FinitePublicEnvironment}
    {Invariant : E.actionModel.State → E.actionModel.Obligation → Prop}
    {s : E.actionModel.State}
    {g : E.actionModel.Obligation}
    {w₁ w₂ : E.actionModel.World}
    (hconflict : ActionConflict E.actionModel s g w₁ w₂)
    (composable : ComposablePairSeparatingEpisode E Invariant s g w₁ w₂)
    (leaf : Leaf composable.episode) :
    actionConflictMeasure E.actionModel
        (leafState composable.episode leaf) g <
      actionConflictMeasure E.actionModel s g := by
  exact actionConflictMeasure_strictly_decreases
    E.actionModel
    s
    (leafState composable.episode leaf)
    g
    w₁
    w₂
    (leaf_fiberIncluded composable.episode leaf)
    hconflict
    (composable.separated leaf)

structure ActionResolvedTree
    (E : FinitePublicEnvironment)
    (s : E.actionModel.State)
    (g : E.actionModel.Obligation) where
  tree : PublicRepairTree E g s
  leafSufficient :
    ∀ leaf : Leaf tree,
      ActionSufficientAt E.actionModel (leafState tree leaf) g

def graftResolvedLeaves
    {E : FinitePublicEnvironment}
    {s : E.actionModel.State}
    {g : E.actionModel.Obligation}
    (episode : PublicRepairTree E g s)
    (continuation :
      ∀ leaf : Leaf episode,
        ActionResolvedTree E (leafState episode leaf) g) :
    ActionResolvedTree E s g :=
  match episode with
  | .stop => continuation ()
  | .ask q authorization step next =>
      let tails : ∀ rr, ActionResolvedTree E (step rr).after g :=
        fun rr =>
          graftResolvedLeaves
            (next rr)
            (fun leaf => continuation ⟨rr, leaf⟩)
      {
        tree := PublicRepairTree.ask q authorization step (fun rr => (tails rr).tree)
        leafSufficient := by
          rintro ⟨rr, leaf⟩
          exact (tails rr).leafSufficient leaf
      }

def synthesizeActionResolvedTree
    {E : FinitePublicEnvironment}
    (Invariant : E.actionModel.State → E.actionModel.Obligation → Prop)
    (g : E.actionModel.Obligation)
    (separable : ComposableAdaptivePairSeparability E Invariant g)
    (s : E.actionModel.State)
    (hinvariant : Invariant s g) :
    ActionResolvedTree E s g :=
  match inspectActionSufficiency E.actionModel s g with
  | .sufficient hsufficient =>
      {
        tree := PublicRepairTree.stop
        leafSufficient := fun _ => hsufficient
      }
  | .conflict w₁ w₂ hconflict =>
      let composable := separable s hinvariant w₁ w₂ hconflict
      graftResolvedLeaves
        composable.episode
        (fun leaf =>
          synthesizeActionResolvedTree
            Invariant
            g
            separable
            (leafState composable.episode leaf)
            (composable.invariantPreserved leaf))
termination_by actionConflictMeasure E.actionModel s g
decreasing_by
  exact separatingEpisode_strictlyDecreasesMeasure hconflict composable leaf

def synthesizeUniformResolution
    {E : FinitePublicEnvironment}
    (Invariant : E.actionModel.State → E.actionModel.Obligation → Prop)
    (g : E.actionModel.Obligation)
    (separable : ComposableAdaptivePairSeparability E Invariant g)
    (s : E.actionModel.State)
    (hinvariant : Invariant s g)
    (hnonempty : PublicFiberNonempty E s) :
    UniformResolutionWitness E s g :=
  let resolved :=
    synthesizeActionResolvedTree Invariant g separable s hinvariant
  {
    initialFiberNonempty := hnonempty
    tree := resolved.tree
    leafSufficient := resolved.leafSufficient
  }

def synthesizeCertifiedRepairability
    {E : FinitePublicEnvironment}
    (D : PublicDecisionDoctrine E)
    (complete : DecisionRealizationComplete D)
    (Invariant : E.actionModel.State → E.actionModel.Obligation → Prop)
    (g : E.actionModel.Obligation)
    (separable : ComposableAdaptivePairSeparability E Invariant g)
    (s : E.actionModel.State)
    (hinvariant : Invariant s g)
    (hnonempty : PublicFiberNonempty E s) :
    CertifiedRepairabilityWitness D s g :=
  completeUniformResolution complete
    (synthesizeUniformResolution
      Invariant g separable s hinvariant hnonempty)

theorem composableSeparability_implies_certifiedRepairable
    {E : FinitePublicEnvironment}
    (D : PublicDecisionDoctrine E)
    (complete : DecisionRealizationComplete D)
    (Invariant : E.actionModel.State → E.actionModel.Obligation → Prop)
    (g : E.actionModel.Obligation)
    (separable : ComposableAdaptivePairSeparability E Invariant g)
    (s : E.actionModel.State)
    (hinvariant : Invariant s g)
    (hnonempty : PublicFiberNonempty E s) :
    CertifiedRepairableAt D s g :=
  ⟨synthesizeCertifiedRepairability
    D complete Invariant g separable s hinvariant hnonempty⟩

/- AXIOM_AUDIT_BEGIN -/
#print axioms separatingEpisode_strictlyDecreasesMeasure
#print axioms synthesizeActionResolvedTree
#print axioms composableSeparability_implies_certifiedRepairable
/- AXIOM_AUDIT_END -/
