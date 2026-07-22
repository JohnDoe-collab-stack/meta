import Repairability.Finite

namespace Repairability

universe u

/--
Effective finite public repair game.  All semantic choices are explicit data;
the transition laws are required only on authorized, realizable branches.
-/
structure PublicGame where
  World : Type u
  State : Type u
  Goal : Type u
  Action : Type u
  Query : Type u
  Response : Type u
  worlds : FiniteCarrier World
  states : FiniteCarrier State
  goals : FiniteCarrier Goal
  actions : FiniteCarrier Action
  queries : FiniteCarrier Query
  responses : FiniteCarrier Response
  actionEq : (a b : Action) → Decidable (a = b)
  responseEq : (r₁ r₂ : Response) → Decidable (r₁ = r₂)
  compatible : State → World → Bool
  required : Goal → World → Action
  authorized : State → Goal → Query → Bool
  respond : World → Query → Response
  advance : State → Goal → Query → Response → State
  decision? : State → Goal → Option Action
  stateSafe : State → Goal → Bool
  priorClosuresRetained : State → State → Bool
  queryCost : State → Goal → Query → Nat
  posteriorContains :
    ∀ s g q r w,
      authorized s g q = true →
      compatible s w = true →
      respond w q = r →
      compatible (advance s g q r) w = true
  fiberMonotone :
    ∀ s g q r w,
      authorized s g q = true →
      (∃ actual, compatible s actual = true ∧ respond actual q = r) →
      compatible (advance s g q r) w = true →
      compatible s w = true
  closuresRetained :
    ∀ s g q r,
      authorized s g q = true →
      (∃ w, compatible s w = true ∧ respond w q = r) →
      priorClosuresRetained s (advance s g q r) = true

namespace PublicGame

def Compatible (E : PublicGame) (s : E.State) (w : E.World) : Prop :=
  E.compatible s w = true

def Authorized
    (E : PublicGame) (s : E.State) (g : E.Goal) (q : E.Query) : Prop :=
  E.authorized s g q = true

def Realizable
    (E : PublicGame) (s : E.State) (q : E.Query) (r : E.Response) : Prop :=
  ∃ w, Compatible E s w ∧ E.respond w q = r

def fiberNonemptyB (E : PublicGame) (s : E.State) : Bool :=
  anyList (E.compatible s) E.worlds.elements

def realizableB
    (E : PublicGame) (s : E.State) (q : E.Query) (r : E.Response) : Bool :=
  anyList
    (fun w =>
      E.compatible s w && decideWith (E.responseEq (E.respond w q) r))
    E.worlds.elements

def Playable
    (E : PublicGame) (s : E.State) (g : E.Goal) (q : E.Query) : Prop :=
  Authorized E s g q ∧ ∃ r, Realizable E s q r

def playableB
    (E : PublicGame) (s : E.State) (g : E.Goal) (q : E.Query) : Bool :=
  E.authorized s g q &&
    anyList (fun r => realizableB E s q r) E.responses.elements

def ActionSufficient
    (E : PublicGame) (s : E.State) (g : E.Goal) : Prop :=
  ∀ w₁ w₂,
    Compatible E s w₁ →
    Compatible E s w₂ →
    E.required g w₁ = E.required g w₂

def DecisionCorrect
    (E : PublicGame) (s : E.State) (g : E.Goal) (a : E.Action) : Prop :=
  ∀ w, Compatible E s w → E.required g w = a

def CertifiedTarget
    (E : PublicGame) (s : E.State) (g : E.Goal) : Prop :=
  E.stateSafe s g = true ∧
  (∃ w, Compatible E s w) ∧
  ∃ a, E.decision? s g = some a ∧ DecisionCorrect E s g a

def targetB (E : PublicGame) (s : E.State) (g : E.Goal) : Bool :=
  (E.stateSafe s g && fiberNonemptyB E s) &&
    match E.decision? s g with
    | none => false
    | some a =>
        allList
          (fun w =>
            (!E.compatible s w) || decideWith (E.actionEq (E.required g w) a))
          E.worlds.elements

theorem fiberNonemptyB_eq_true_iff
    (E : PublicGame) (s : E.State) :
    fiberNonemptyB E s = true ↔ ∃ w, Compatible E s w := by
  constructor
  · intro h
    rcases (anyList_eq_true_iff (E.compatible s) E.worlds.elements).mp h with
      ⟨w, _, hw⟩
    exact ⟨w, hw⟩
  · rintro ⟨w, hw⟩
    apply (anyList_eq_true_iff (E.compatible s) E.worlds.elements).mpr
    exact ⟨w, E.worlds.complete w, hw⟩

theorem realizableB_eq_true_iff
    (E : PublicGame) (s : E.State) (q : E.Query) (r : E.Response) :
    realizableB E s q r = true ↔ Realizable E s q r := by
  constructor
  · intro h
    rcases (anyList_eq_true_iff
      (fun w => E.compatible s w && decideWith (E.responseEq (E.respond w q) r))
      E.worlds.elements).mp h with ⟨w, _, hw⟩
    have hparts := (boolAnd_eq_true_iff
      (E.compatible s w)
      (decideWith (E.responseEq (E.respond w q) r))).mp hw
    have hc : E.compatible s w = true := hparts.1
    have hr : E.respond w q = r :=
      (decideWith_eq_true_iff (E.responseEq (E.respond w q) r)).mp hparts.2
    exact ⟨w, hc, hr⟩
  · rintro ⟨w, hc, hr⟩
    apply (anyList_eq_true_iff
      (fun w => E.compatible s w && decideWith (E.responseEq (E.respond w q) r))
      E.worlds.elements).mpr
    refine ⟨w, E.worlds.complete w, ?_⟩
    apply (boolAnd_eq_true_iff
      (E.compatible s w)
      (decideWith (E.responseEq (E.respond w q) r))).mpr
    exact ⟨hc, (decideWith_eq_true_iff (E.responseEq (E.respond w q) r)).mpr hr⟩

theorem playableB_eq_true_iff
    (E : PublicGame) (s : E.State) (g : E.Goal) (q : E.Query) :
    playableB E s g q = true ↔ Playable E s g q := by
  constructor
  · intro h
    have hparts := (boolAnd_eq_true_iff
      (E.authorized s g q)
      (anyList (fun r => realizableB E s q r) E.responses.elements)).mp h
    rcases (anyList_eq_true_iff
      (fun r => realizableB E s q r) E.responses.elements).mp hparts.2 with
      ⟨r, _, hr⟩
    have ha : Authorized E s g q := hparts.1
    exact ⟨ha, ⟨r, (realizableB_eq_true_iff E s q r).mp hr⟩⟩
  · rintro ⟨ha, r, hr⟩
    apply (boolAnd_eq_true_iff
      (E.authorized s g q)
      (anyList (fun r => realizableB E s q r) E.responses.elements)).mpr
    constructor
    · exact ha
    · apply (anyList_eq_true_iff
        (fun r => realizableB E s q r) E.responses.elements).mpr
      exact ⟨r, E.responses.complete r,
        (realizableB_eq_true_iff E s q r).mpr hr⟩

theorem targetB_eq_true_iff
    (E : PublicGame) (s : E.State) (g : E.Goal) :
    targetB E s g = true ↔ CertifiedTarget E s g := by
  unfold targetB CertifiedTarget
  cases hdecision : E.decision? s g with
  | none =>
      constructor
      · intro h
        have hparts := (boolAnd_eq_true_iff
          (E.stateSafe s g && fiberNonemptyB E s) false).mp h
        exact Bool.noConfusion hparts.2
      · rintro ⟨_, _, a, ha, _⟩
        cases ha
  | some a =>
      constructor
      · intro h
        have houter := (boolAnd_eq_true_iff
          (E.stateSafe s g && fiberNonemptyB E s)
          (allList
            (fun w =>
              (!E.compatible s w) ||
                decideWith (E.actionEq (E.required g w) a))
            E.worlds.elements)).mp h
        have hinner := (boolAnd_eq_true_iff
          (E.stateSafe s g) (fiberNonemptyB E s)).mp houter.1
        have hnonempty := (fiberNonemptyB_eq_true_iff E s).mp hinner.2
        refine ⟨hinner.1, hnonempty, a, rfl, ?_⟩
        intro w hw
        have hpoint := (allList_eq_true_iff
          (fun w =>
            (!E.compatible s w) ||
              decideWith (E.actionEq (E.required g w) a))
          E.worlds.elements).mp houter.2 w (E.worlds.complete w)
        have hdecide := (boolNotOr_eq_true_iff
          (E.compatible s w)
          (decideWith (E.actionEq (E.required g w) a))).mp hpoint hw
        exact (decideWith_eq_true_iff (E.actionEq (E.required g w) a)).mp hdecide
      · rintro ⟨hsafe, hnonempty, a', ha', hall⟩
        cases ha'
        apply (boolAnd_eq_true_iff
          (E.stateSafe s g && fiberNonemptyB E s)
          (allList
            (fun w =>
              (!E.compatible s w) ||
                decideWith (E.actionEq (E.required g w) a))
            E.worlds.elements)).mpr
        constructor
        · apply (boolAnd_eq_true_iff
            (E.stateSafe s g) (fiberNonemptyB E s)).mpr
          exact ⟨hsafe, (fiberNonemptyB_eq_true_iff E s).mpr hnonempty⟩
        · apply (allList_eq_true_iff
            (fun w =>
              (!E.compatible s w) ||
                decideWith (E.actionEq (E.required g w) a))
            E.worlds.elements).mpr
          intro w _
          apply (boolNotOr_eq_true_iff
            (E.compatible s w)
            (decideWith (E.actionEq (E.required g w) a))).mpr
          intro hw
          apply (decideWith_eq_true_iff (E.actionEq (E.required g w) a)).mpr
          exact hall w hw

theorem certifiedTarget_actionSufficient
    (E : PublicGame) (s : E.State) (g : E.Goal)
    (h : CertifiedTarget E s g) :
    ActionSufficient E s g := by
  rcases h with ⟨_, _, a, _, hall⟩
  intro w₁ w₂ hw₁ hw₂
  exact (hall w₁ hw₁).trans (hall w₂ hw₂).symm

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.targetB_eq_true_iff
#print axioms Repairability.PublicGame.certifiedTarget_actionSufficient
#print axioms Repairability.PublicGame.playableB_eq_true_iff
/- AXIOM_AUDIT_END -/
