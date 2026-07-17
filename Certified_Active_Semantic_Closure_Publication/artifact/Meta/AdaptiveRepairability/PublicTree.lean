import Meta.AdaptiveRepairability.FiniteMeasure

namespace Meta.AdaptiveRepairability

/-!
Public repair protocols and their finite adaptive trees.

Every operational constructor receives only public data.  A semantic world is
introduced only by `run`, where it determines the response to the public query.
-/

structure FinitePublicEnvironment where
  actionModel : FiniteActionModel
  Query : Type
  Response : Type
  Patch : Type
  Observation : Type
  MemoryEntry : Type
  Provenance : Type
  respond : actionModel.World → Query → Response
  responses : List Response
  responses_nodup : responses.Nodup
  responses_complete : ∀ r, r ∈ responses
  responseEq : (r₁ r₂ : Response) → Decidable (r₁ = r₂)
  authorized : actionModel.State → actionModel.Obligation → Query → Prop
  ResponseDerived :
    actionModel.State → actionModel.Obligation → Query → Response →
      Patch → Observation → MemoryEntry → Provenance → Prop
  FramePreserved : actionModel.State → actionModel.State → Prop
  StrictIdentityConservative : actionModel.State → actionModel.State → Prop
  TransportCoherent : actionModel.State → actionModel.State → Prop
  ConsistentUpdate : actionModel.State → actionModel.State → Prop

def fiberWorlds
    (E : FinitePublicEnvironment) (s : E.actionModel.State) :
    List E.actionModel.World :=
  E.actionModel.worlds.filter (E.actionModel.compatible s)

def PublicFiberNonempty
    (E : FinitePublicEnvironment) (s : E.actionModel.State) : Prop :=
  fiberWorlds E s ≠ []

theorem publicFiberNonempty_iff_exists_compatible
    (E : FinitePublicEnvironment) (s : E.actionModel.State) :
    PublicFiberNonempty E s ↔
      ∃ w : E.actionModel.World, Compatible E.actionModel s w := by
  constructor
  · intro hnonempty
    cases hfiber : fiberWorlds E s with
    | nil => exact False.elim (hnonempty hfiber)
    | cons w tail =>
        have hmem : w ∈ fiberWorlds E s := by
          rw [hfiber]
          exact List.Mem.head tail
        exact ⟨w, filterMemberPredicateTrue (E.actionModel.compatible s) hmem⟩
  · rintro ⟨w, hw⟩ hempty
    have hmem : w ∈ fiberWorlds E s :=
      memFilterOfMemOfTrue
        (E.actionModel.compatible s)
        (E.actionModel.worlds_complete w)
        hw
    rw [hempty] at hmem
    exact nomatch hmem

def IsRealizableResponse
    (E : FinitePublicEnvironment)
    (s : E.actionModel.State)
    (q : E.Query)
    (r : E.Response) : Prop :=
  ∃ w : E.actionModel.World,
    Compatible E.actionModel s w ∧ E.respond w q = r

def RealizableResponse
    (E : FinitePublicEnvironment)
    (s : E.actionModel.State)
    (q : E.Query) : Type :=
  { r : E.Response // IsRealizableResponse E s q r }

structure PublicRepairStep
    (E : FinitePublicEnvironment)
    (before : E.actionModel.State)
    (g : E.actionModel.Obligation)
    (q : E.Query)
    (r : E.Response) where
  after : E.actionModel.State
  patch : E.Patch
  observation : E.Observation
  memoryEntry : E.MemoryEntry
  provenance : E.Provenance
  posteriorSound :
    ∀ w, Compatible E.actionModel after w → Compatible E.actionModel before w
  observedWorldRetained :
    ∀ w,
      Compatible E.actionModel before w →
      E.respond w q = r →
      Compatible E.actionModel after w
  responseDerived :
    E.ResponseDerived before g q r patch observation memoryEntry provenance
  framePreserved : E.FramePreserved before after
  strictIdentityConservative : E.StrictIdentityConservative before after
  transportCoherent : E.TransportCoherent before after
  consistentUpdate : E.ConsistentUpdate before after

inductive PublicRepairTree
    (E : FinitePublicEnvironment)
    (g : E.actionModel.Obligation) : E.actionModel.State → Type where
  | stop {s : E.actionModel.State} : PublicRepairTree E g s
  | ask {s : E.actionModel.State}
      (q : E.Query)
      (authorization : E.authorized s g q)
      (step : ∀ rr : RealizableResponse E s q, PublicRepairStep E s g q rr.1)
      (next : ∀ rr, PublicRepairTree E g (step rr).after) :
      PublicRepairTree E g s

def Leaf
    {E : FinitePublicEnvironment}
    {g : E.actionModel.Obligation}
    {s : E.actionModel.State}
    (tree : PublicRepairTree E g s) : Type :=
  match tree with
  | .stop => Unit
  | .ask q _authorization _step next =>
      Σ rr : RealizableResponse E s q, Leaf (next rr)

def leafState
    {E : FinitePublicEnvironment}
    {g : E.actionModel.Obligation}
    {s : E.actionModel.State}
    (tree : PublicRepairTree E g s)
    (leaf : Leaf tree) : E.actionModel.State :=
  match tree, leaf with
  | .stop, _ => s
  | .ask _q _authorization _step next, ⟨rr, tail⟩ =>
      leafState (next rr) tail

def PublicEvent (E : FinitePublicEnvironment) : Type := E.Query × E.Response

structure Transcript (E : FinitePublicEnvironment) where
  terminalState : E.actionModel.State
  events : List (PublicEvent E)

def observedResponse
    {E : FinitePublicEnvironment}
    {s : E.actionModel.State}
    (q : E.Query)
    (w : E.actionModel.World)
    (compatible : Compatible E.actionModel s w) : RealizableResponse E s q :=
  ⟨E.respond w q, ⟨w, compatible, rfl⟩⟩

def terminalLeaf
    {E : FinitePublicEnvironment}
    {g : E.actionModel.Obligation}
    {s : E.actionModel.State}
    (tree : PublicRepairTree E g s)
    (w : E.actionModel.World)
    (compatible : Compatible E.actionModel s w) : Leaf tree :=
  match tree with
  | .stop => ()
  | .ask q _authorization step next =>
      let rr := observedResponse q w compatible
      let hafter := (step rr).observedWorldRetained w compatible rfl
      ⟨rr, terminalLeaf (next rr) w hafter⟩

def terminalPublicState
    {E : FinitePublicEnvironment}
    {g : E.actionModel.Obligation}
    {s : E.actionModel.State}
    (tree : PublicRepairTree E g s)
    (w : E.actionModel.World)
    (compatible : Compatible E.actionModel s w) : E.actionModel.State :=
  leafState tree (terminalLeaf tree w compatible)

def runEvents
    {E : FinitePublicEnvironment}
    {g : E.actionModel.Obligation}
    {s : E.actionModel.State}
    (tree : PublicRepairTree E g s)
    (w : E.actionModel.World)
    (compatible : Compatible E.actionModel s w) : List (PublicEvent E) :=
  match tree with
  | .stop => []
  | .ask q _authorization step next =>
      let rr := observedResponse q w compatible
      let hafter := (step rr).observedWorldRetained w compatible rfl
      (q, rr.1) :: runEvents (next rr) w hafter

def runTranscript
    {E : FinitePublicEnvironment}
    {g : E.actionModel.Obligation}
    {s : E.actionModel.State}
    (tree : PublicRepairTree E g s)
    (w : E.actionModel.World)
    (compatible : Compatible E.actionModel s w) : Transcript E :=
  {
    terminalState := terminalPublicState tree w compatible
    events := runEvents tree w compatible
  }

theorem run_retains_world
    {E : FinitePublicEnvironment}
    {g : E.actionModel.Obligation}
    {s : E.actionModel.State}
    (tree : PublicRepairTree E g s)
    (w : E.actionModel.World)
    (compatible : Compatible E.actionModel s w) :
    Compatible E.actionModel (terminalPublicState tree w compatible) w := by
  induction tree with
  | stop => exact compatible
  | @ask state q authorization step next ih =>
      let rr := observedResponse q w compatible
      have hafter : Compatible E.actionModel (step rr).after w :=
        (step rr).observedWorldRetained w compatible rfl
      exact ih rr hafter

theorem leaf_fiberIncluded
    {E : FinitePublicEnvironment}
    {g : E.actionModel.Obligation}
    {s : E.actionModel.State}
    (tree : PublicRepairTree E g s)
    (leaf : Leaf tree) :
    FiberIncluded E.actionModel (leafState tree leaf) s := by
  induction tree with
  | stop =>
      intro w hw
      exact hw
  | @ask state q authorization step next ih =>
      rcases leaf with ⟨rr, tail⟩
      intro w hw
      exact (step rr).posteriorSound w (ih rr tail w hw)

theorem leaf_publicFiberNonempty
    {E : FinitePublicEnvironment}
    {g : E.actionModel.Obligation}
    {s : E.actionModel.State}
    (tree : PublicRepairTree E g s)
    (leaf : Leaf tree)
    (initialNonempty : PublicFiberNonempty E s) :
    PublicFiberNonempty E (leafState tree leaf) := by
  induction tree with
  | stop => exact initialNonempty
  | @ask state q authorization step next ih =>
      rcases leaf with ⟨rr, tail⟩
      rcases rr.2 with ⟨w, hw, hresponse⟩
      have hafter := (step rr).observedWorldRetained w hw hresponse
      have hafterNonempty : PublicFiberNonempty E (step rr).after :=
        (publicFiberNonempty_iff_exists_compatible E (step rr).after).mpr ⟨w, hafter⟩
      exact ih rr tail hafterNonempty

theorem sameTranscript_samePublicState
    {E : FinitePublicEnvironment}
    {g : E.actionModel.Obligation}
    {s : E.actionModel.State}
    (tree : PublicRepairTree E g s)
    (w₁ w₂ : E.actionModel.World)
    (compatible₁ : Compatible E.actionModel s w₁)
    (compatible₂ : Compatible E.actionModel s w₂)
    (hsame : runTranscript tree w₁ compatible₁ = runTranscript tree w₂ compatible₂) :
    terminalPublicState tree w₁ compatible₁ =
      terminalPublicState tree w₂ compatible₂ := by
  exact congrArg Transcript.terminalState hsame

/- AXIOM_AUDIT_BEGIN -/
#print axioms publicFiberNonempty_iff_exists_compatible
#print axioms leaf_fiberIncluded
#print axioms sameTranscript_samePublicState
/- AXIOM_AUDIT_END -/
