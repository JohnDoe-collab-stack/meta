import Meta.AdaptiveRepairability.PublicTree

namespace Meta.AdaptiveRepairability

/-!
Certified decision realization, adaptive indistinguishability, the public no-go,
and the operational characterization of repairability.
-/

structure PublicDecisionDoctrine (E : FinitePublicEnvironment) where
  Candidate : Type
  candidate : E.actionModel.State → Candidate
  interpret : Candidate → E.actionModel.Obligation → E.actionModel.Action
  DecisionDerivedFromPublicFiber :
    E.actionModel.State → E.actionModel.Obligation →
      E.actionModel.State → Candidate → Prop
  DecisionClosureProvenance :
    E.actionModel.State → E.actionModel.Obligation → E.actionModel.State → Prop
  DecisionFramePreserved :
    E.actionModel.State → E.actionModel.Obligation → E.actionModel.State → Prop
  CurrentCertificateAdded :
    E.actionModel.State → E.actionModel.Obligation → E.actionModel.State → Prop
  StrictIdentityConservative : E.actionModel.State → E.actionModel.State → Prop
  TransportCoherent : E.actionModel.State → E.actionModel.State → Prop
  ConsistentUpdate : E.actionModel.State → E.actionModel.State → Prop

structure CertifiedLocalClosure
    {E : FinitePublicEnvironment}
    (D : PublicDecisionDoctrine E)
    (before : E.actionModel.State)
    (g : E.actionModel.Obligation) where
  inputSufficient : ActionSufficientAt E.actionModel before g
  after : E.actionModel.State
  chosenAction : E.actionModel.Action
  repairedCandidate : D.Candidate
  afterCarriesCandidate : D.candidate after = repairedCandidate
  candidateRealizesAction : D.interpret repairedCandidate g = chosenAction
  fiberPreservedForward :
    ∀ w, Compatible E.actionModel after w → Compatible E.actionModel before w
  fiberPreservedBackward :
    ∀ w, Compatible E.actionModel before w → Compatible E.actionModel after w
  knownCorrect :
    ∀ w,
      Compatible E.actionModel after w →
      D.interpret repairedCandidate g = E.actionModel.required g w
  publicDerivation :
    D.DecisionDerivedFromPublicFiber before g after repairedCandidate
  provenanceComplete : D.DecisionClosureProvenance before g after
  framePreserved : D.DecisionFramePreserved before g after
  currentCertificateAdded : D.CurrentCertificateAdded before g after
  strictIdentityConservative : D.StrictIdentityConservative before after
  transportCoherent : D.TransportCoherent before after
  consistentUpdate : D.ConsistentUpdate before after

structure DecisionRealizationComplete
    {E : FinitePublicEnvironment}
    (D : PublicDecisionDoctrine E) where
  realizeHomogeneousDecision :
    ∀ (s : E.actionModel.State) (g : E.actionModel.Obligation),
      PublicFiberNonempty E s →
      ActionSufficientAt E.actionModel s g →
      CertifiedLocalClosure D s g

structure CertifiedWinningTree
    {E : FinitePublicEnvironment}
    (D : PublicDecisionDoctrine E)
    (s : E.actionModel.State)
    (g : E.actionModel.Obligation)
    (tree : PublicRepairTree E g s) where
  closeLeaf : ∀ leaf : Leaf tree, CertifiedLocalClosure D (leafState tree leaf) g

structure CertifiedRepairabilityWitness
    {E : FinitePublicEnvironment}
    (D : PublicDecisionDoctrine E)
    (s : E.actionModel.State)
    (g : E.actionModel.Obligation) where
  initialFiberNonempty : PublicFiberNonempty E s
  tree : PublicRepairTree E g s
  winning : CertifiedWinningTree D s g tree

def CertifiedRepairableAt
    {E : FinitePublicEnvironment}
    (D : PublicDecisionDoctrine E)
    (s : E.actionModel.State)
    (g : E.actionModel.Obligation) : Prop :=
  Nonempty (CertifiedRepairabilityWitness D s g)

structure UniformResolutionWitness
    (E : FinitePublicEnvironment)
    (s : E.actionModel.State)
    (g : E.actionModel.Obligation) where
  initialFiberNonempty : PublicFiberNonempty E s
  tree : PublicRepairTree E g s
  leafSufficient :
    ∀ leaf : Leaf tree,
      ActionSufficientAt E.actionModel (leafState tree leaf) g

def UniformlyActionResolvableAt
    (E : FinitePublicEnvironment)
    (s : E.actionModel.State)
    (g : E.actionModel.Obligation) : Prop :=
  Nonempty (UniformResolutionWitness E s g)

def forgetCertifiedRepairability
    {E : FinitePublicEnvironment}
    {D : PublicDecisionDoctrine E}
    {s : E.actionModel.State}
    {g : E.actionModel.Obligation}
    (certified : CertifiedRepairabilityWitness D s g) :
    UniformResolutionWitness E s g :=
  {
    initialFiberNonempty := certified.initialFiberNonempty
    tree := certified.tree
    leafSufficient := fun leaf => (certified.winning.closeLeaf leaf).inputSufficient
  }

def completeUniformResolution
    {E : FinitePublicEnvironment}
    {D : PublicDecisionDoctrine E}
    (complete : DecisionRealizationComplete D)
    {s : E.actionModel.State}
    {g : E.actionModel.Obligation}
    (resolvable : UniformResolutionWitness E s g) :
    CertifiedRepairabilityWitness D s g :=
  {
    initialFiberNonempty := resolvable.initialFiberNonempty
    tree := resolvable.tree
    winning := {
      closeLeaf := fun leaf =>
        complete.realizeHomogeneousDecision
          (leafState resolvable.tree leaf)
          g
          (leaf_publicFiberNonempty
            resolvable.tree leaf resolvable.initialFiberNonempty)
          (resolvable.leafSufficient leaf)
    }
  }

theorem certifiedRepairable_iff_uniformlyActionResolvable
    {E : FinitePublicEnvironment}
    (D : PublicDecisionDoctrine E)
    (complete : DecisionRealizationComplete D)
    (s : E.actionModel.State)
    (g : E.actionModel.Obligation) :
    CertifiedRepairableAt D s g ↔ UniformlyActionResolvableAt E s g := by
  constructor
  · rintro ⟨certified⟩
    exact ⟨forgetCertifiedRepairability certified⟩
  · rintro ⟨resolvable⟩
    exact ⟨completeUniformResolution complete resolvable⟩

def PubliclyIndistinguishable
    (E : FinitePublicEnvironment)
    (s : E.actionModel.State)
    (g : E.actionModel.Obligation)
    (w₁ w₂ : E.actionModel.World) : Prop :=
  ∀ (tree : PublicRepairTree E g s)
    (compatible₁ : Compatible E.actionModel s w₁)
    (compatible₂ : Compatible E.actionModel s w₂),
      runTranscript tree w₁ compatible₁ =
        runTranscript tree w₂ compatible₂

theorem adaptivePublicNoGo
    {E : FinitePublicEnvironment}
    (D : PublicDecisionDoctrine E)
    {s : E.actionModel.State}
    {g : E.actionModel.Obligation}
    {w₁ w₂ : E.actionModel.World}
    (hconflict : ActionConflict E.actionModel s g w₁ w₂)
    (hindistinguishable : PubliclyIndistinguishable E s g w₁ w₂) :
    ¬ CertifiedRepairableAt D s g := by
  rintro ⟨certified⟩
  let tree := certified.tree
  let leaf₁ := terminalLeaf tree w₁ hconflict.1
  have hsameTranscript :=
    hindistinguishable tree hconflict.1 hconflict.2.1
  have hsameState :=
    sameTranscript_samePublicState
      tree w₁ w₂ hconflict.1 hconflict.2.1 hsameTranscript
  have hw₁Terminal :
      Compatible E.actionModel
        (terminalPublicState tree w₁ hconflict.1) w₁ :=
    run_retains_world tree w₁ hconflict.1
  have hw₂Terminal :
      Compatible E.actionModel
        (terminalPublicState tree w₁ hconflict.1) w₂ := by
    rw [hsameState]
    exact run_retains_world tree w₂ hconflict.2.1
  have hsufficient := (certified.winning.closeLeaf leaf₁).inputSufficient
  have hequal := hsufficient w₁ w₂ hw₁Terminal hw₂Terminal
  exact hconflict.2.2 hequal

structure PairSeparatingEpisode
    (E : FinitePublicEnvironment)
    (s : E.actionModel.State)
    (g : E.actionModel.Obligation)
    (w₁ w₂ : E.actionModel.World) where
  episode : PublicRepairTree E g s
  separated :
    ∀ leaf : Leaf episode,
      ¬ (Compatible E.actionModel (leafState episode leaf) w₁ ∧
        Compatible E.actionModel (leafState episode leaf) w₂)

def AdaptivePairSeparability
    (E : FinitePublicEnvironment)
    (s : E.actionModel.State)
    (g : E.actionModel.Obligation) : Type :=
  ∀ w₁ w₂,
    ActionConflict E.actionModel s g w₁ w₂ →
    PairSeparatingEpisode E s g w₁ w₂

def uniformResolution_pairSeparability
    {E : FinitePublicEnvironment}
    {s : E.actionModel.State}
    {g : E.actionModel.Obligation}
    (resolvable : UniformResolutionWitness E s g) :
    AdaptivePairSeparability E s g := by
  intro w₁ w₂ hconflict
  exact {
    episode := resolvable.tree
    separated := by
      intro leaf hcoexist
      have hequal :=
        resolvable.leafSufficient leaf w₁ w₂ hcoexist.1 hcoexist.2
      exact hconflict.2.2 hequal
  }

/- AXIOM_AUDIT_BEGIN -/
#print axioms certifiedRepairable_iff_uniformlyActionResolvable
#print axioms adaptivePublicNoGo
#print axioms uniformResolution_pairSeparability
/- AXIOM_AUDIT_END -/
