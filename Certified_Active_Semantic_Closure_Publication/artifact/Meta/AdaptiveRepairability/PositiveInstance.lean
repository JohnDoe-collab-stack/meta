import Meta.AdaptiveRepairability.Validation

namespace Meta.AdaptiveRepairability.PositiveInstance

/-!
An inhabited end-to-end instance.  A public query reveals which of two worlds is
actual; the public step represents the exact posterior; the synthesized tree is
then closed by a candidate carrying the unique action of its terminal fiber.
-/

inductive World where
  | left
  | right

inductive State where
  | initial
  | observedLeft
  | observedRight

def worldEq (w₁ w₂ : World) : Decidable (w₁ = w₂) :=
  match w₁, w₂ with
  | .left, .left => isTrue rfl
  | .right, .right => isTrue rfl
  | .left, .right => isFalse (fun h => World.noConfusion h)
  | .right, .left => isFalse (fun h => World.noConfusion h)

theorem worlds_nodup : ([World.left, World.right] : List World).Nodup := by
  unfold List.Nodup
  apply List.Pairwise.cons
  · intro w hmem heq
    cases hmem with
    | head => exact World.noConfusion heq
    | tail _ htail => exact nomatch htail
  · apply List.Pairwise.cons
    · intro w hmem
      exact nomatch hmem
    · exact List.Pairwise.nil

theorem worlds_complete : ∀ w : World, w ∈ [World.left, World.right] := by
  intro w
  cases w with
  | left => exact List.Mem.head [World.right]
  | right => exact List.Mem.tail World.left (List.Mem.head [])

def compatible : State → World → Bool
  | .initial, _ => true
  | .observedLeft, .left => true
  | .observedLeft, .right => false
  | .observedRight, .left => false
  | .observedRight, .right => true

def required (_ : Unit) (w : World) : World := w

def actionModel : FiniteActionModel :=
  {
    World := World
    State := State
    Obligation := Unit
    Action := World
    worlds := [World.left, World.right]
    worlds_nodup := worlds_nodup
    worlds_complete := worlds_complete
    worldEq := worldEq
    compatible := compatible
    required := required
    actionEq := worldEq
  }

def respond (w : World) (_ : Unit) : World := w

def stateFor : World → State
  | .left => .observedLeft
  | .right => .observedRight

theorem stateFor_compatible_implies_eq
    {r w : World}
    (hcompatible : compatible (stateFor r) w = true) : w = r := by
  cases r <;> cases w
  · rfl
  · exact False.elim (Bool.noConfusion hcompatible)
  · exact False.elim (Bool.noConfusion hcompatible)
  · rfl

theorem stateFor_retains_response
    {r w : World} (hresponse : respond w () = r) :
    compatible (stateFor r) w = true := by
  cases w <;> cases r
  · rfl
  · exact False.elim (World.noConfusion hresponse)
  · exact False.elim (World.noConfusion hresponse)
  · rfl

def publicEnvironment : FinitePublicEnvironment :=
  {
    actionModel := actionModel
    Query := Unit
    Response := World
    Patch := Unit
    Observation := World
    MemoryEntry := World
    Provenance := World
    respond := respond
    responses := [World.left, World.right]
    responses_nodup := worlds_nodup
    responses_complete := worlds_complete
    responseEq := worldEq
    authorized := fun _ _ _ => True
    ResponseDerived := fun _ _ _ r _ observation memory provenance =>
      observation = r ∧ memory = r ∧ provenance = r
    FramePreserved := fun _ _ => True
    StrictIdentityConservative := fun _ _ => True
    TransportCoherent := fun _ _ => True
    ConsistentUpdate := fun _ _ => True
  }

theorem realizableResponse_compatible
    {s : State} {q : Unit}
    (rr : RealizableResponse publicEnvironment s q) :
    Compatible actionModel s rr.1 := by
  rcases rr.2 with ⟨w, hw, hresponse⟩
  change w = rr.1 at hresponse
  cases hresponse
  exact hw

def publicStep
    (s : State)
    (g : Unit)
    (q : Unit)
    (rr : RealizableResponse publicEnvironment s q) :
    PublicRepairStep publicEnvironment s g q rr.1 :=
  {
    after := stateFor rr.1
    patch := ()
    observation := rr.1
    memoryEntry := rr.1
    provenance := rr.1
    posteriorSound := by
      intro w hw
      have heq := stateFor_compatible_implies_eq hw
      cases heq
      exact realizableResponse_compatible rr
    observedWorldRetained := by
      intro w hw hresponse
      exact stateFor_retains_response hresponse
    responseDerived := ⟨rfl, rfl, rfl⟩
    framePreserved := True.intro
    strictIdentityConservative := True.intro
    transportCoherent := True.intro
    consistentUpdate := True.intro
  }

theorem publicStep_exactPosterior
    (s : State)
    (g : Unit)
    (q : Unit)
    (rr : RealizableResponse publicEnvironment s q)
    (w : World) :
    Compatible actionModel (publicStep s g q rr).after w ↔
      (Compatible actionModel s w ∧ respond w q = rr.1) := by
  constructor
  · intro hafter
    exact ⟨(publicStep s g q rr).posteriorSound w hafter,
      stateFor_compatible_implies_eq hafter⟩
  · rintro ⟨hbefore, hresponse⟩
    exact (publicStep s g q rr).observedWorldRetained w hbefore hresponse

def exactCompiler : ExactPosteriorRepairComplete publicEnvironment :=
  {
    realizeResponse := fun s g q _authorization rr => publicStep s g q rr
    exactPosterior := fun s g q _authorization rr w =>
      publicStep_exactPosterior s g q rr w
  }

def oneQueryTree (s : State) (g : Unit) :
    PublicRepairTree publicEnvironment g s :=
  PublicRepairTree.ask
    ()
    True.intro
    (fun rr => publicStep s g () rr)
    (fun _ => PublicRepairTree.stop)

theorem oneQueryTree_generated
    (s : State) (g : Unit) :
    GeneratedByExactCompiler exactCompiler (oneQueryTree s g) := by
  constructor
  · intro rr
    rfl
  · intro rr
    exact True.intro

def invariant (_ : State) (_ : Unit) : Prop := True

def composableSeparability :
    ComposableAdaptivePairSeparability publicEnvironment invariant () := by
  intro s hinvariant w₁ w₂ hconflict
  exact {
    episode := oneQueryTree s ()
    separated := by
      rintro ⟨rr, tail⟩ hcoexist
      have hw₁ : w₁ = rr.1 := stateFor_compatible_implies_eq hcoexist.1
      have hw₂ : w₂ = rr.1 := stateFor_compatible_implies_eq hcoexist.2
      exact hconflict.2.2 (hw₁.trans hw₂.symm)
    invariantPreserved := by
      intro leaf
      exact True.intro
  }

def exactComposableSeparability :
    ExactComposableAdaptivePairSeparability
      publicEnvironment exactCompiler invariant () := by
  intro s hinvariant w₁ w₂ hconflict
  exact {
    composable := composableSeparability s hinvariant w₁ w₂ hconflict
    generated := oneQueryTree_generated s ()
  }

def decisionDoctrine : PublicDecisionDoctrine publicEnvironment :=
  {
    Candidate := World
    candidate := fun s =>
      match s with
      | .initial => .left
      | .observedLeft => .left
      | .observedRight => .right
    interpret := fun candidate _ => candidate
    DecisionDerivedFromPublicFiber := fun _ _ _ _ => True
    DecisionClosureProvenance := fun _ _ _ => True
    DecisionFramePreserved := fun _ _ _ => True
    CurrentCertificateAdded := fun _ _ _ => True
    StrictIdentityConservative := fun _ _ => True
    TransportCoherent := fun _ _ => True
    ConsistentUpdate := fun _ _ => True
  }

def decisionComplete : DecisionRealizationComplete decisionDoctrine :=
  {
    realizeHomogeneousDecision := by
      intro s g hnonempty hsufficient
      cases s with
      | initial =>
          have hequal := hsufficient World.left World.right rfl rfl
          exact False.elim (World.noConfusion hequal)
      | observedLeft =>
          exact {
            inputSufficient := hsufficient
            after := State.observedLeft
            chosenAction := World.left
            repairedCandidate := World.left
            afterCarriesCandidate := rfl
            candidateRealizesAction := rfl
            fiberPreservedForward := fun w hw => hw
            fiberPreservedBackward := fun w hw => hw
            knownCorrect := by
              intro w hw
              have heq : w = World.left :=
                stateFor_compatible_implies_eq (r := World.left) hw
              cases heq
              rfl
            publicDerivation := True.intro
            provenanceComplete := True.intro
            framePreserved := True.intro
            currentCertificateAdded := True.intro
            strictIdentityConservative := True.intro
            transportCoherent := True.intro
            consistentUpdate := True.intro
          }
      | observedRight =>
          exact {
            inputSufficient := hsufficient
            after := State.observedRight
            chosenAction := World.right
            repairedCandidate := World.right
            afterCarriesCandidate := rfl
            candidateRealizesAction := rfl
            fiberPreservedForward := fun w hw => hw
            fiberPreservedBackward := fun w hw => hw
            knownCorrect := by
              intro w hw
              have heq : w = World.right :=
                stateFor_compatible_implies_eq (r := World.right) hw
              cases heq
              rfl
            publicDerivation := True.intro
            provenanceComplete := True.intro
            framePreserved := True.intro
            currentCertificateAdded := True.intro
            strictIdentityConservative := True.intro
            transportCoherent := True.intro
            consistentUpdate := True.intro
          }
  }

theorem initialFiberNonempty :
    PublicFiberNonempty publicEnvironment State.initial := by
  apply (publicFiberNonempty_iff_exists_compatible
    publicEnvironment State.initial).mpr
  exact ⟨World.left, rfl⟩

def synthesizedCertifiedRepairability :
    CertifiedRepairabilityWitness
      decisionDoctrine State.initial () :=
  synthesizeCertifiedRepairability
    decisionDoctrine
    decisionComplete
    invariant
    ()
    composableSeparability
    State.initial
    True.intro
    initialFiberNonempty

theorem exactInstanceCertifiedRepairable :
    CertifiedRepairableAt decisionDoctrine State.initial () :=
  exactComposableSeparability_implies_certifiedRepairable
    decisionDoctrine
    decisionComplete
    exactCompiler
    invariant
    ()
    exactComposableSeparability
    State.initial
    True.intro
    initialFiberNonempty

/- AXIOM_AUDIT_BEGIN -/
#print axioms publicStep_exactPosterior
#print axioms synthesizedCertifiedRepairability
#print axioms exactInstanceCertifiedRepairable
/- AXIOM_AUDIT_END -/
