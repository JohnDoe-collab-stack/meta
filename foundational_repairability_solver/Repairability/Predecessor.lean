import Repairability.Game

namespace Repairability.PublicGame

def ControllablePre
    (E : PublicGame) (g : E.Goal) (inside : E.State → Prop) (s : E.State) : Prop :=
  ∃ q, Playable E s g q ∧
    ∀ r, Realizable E s q r → inside (E.advance s g q r)

def cpreQueryB
    (E : PublicGame) (g : E.Goal) (inside : E.State → Bool) (s : E.State) :
    E.Query → Bool :=
  fun q =>
    playableB E s g q &&
    allList
      (fun r => (!realizableB E s q r) || inside (E.advance s g q r))
      E.responses.elements

def cpreChoice?
    (E : PublicGame) (g : E.Goal) (inside : E.State → Bool) (s : E.State) :
    Option E.Query :=
  findList? (cpreQueryB E g inside s) E.queries.elements

def cpreB
    (E : PublicGame) (g : E.Goal) (inside : E.State → Bool) (s : E.State) : Bool :=
  match cpreChoice? E g inside s with
  | none => false
  | some _ => true

theorem cpreB_eq_true_iff
    (E : PublicGame) (g : E.Goal) (inside : E.State → Bool) (s : E.State) :
    cpreB E g inside s = true ↔
      ControllablePre E g (fun t => inside t = true) s := by
  constructor
  · intro h
    unfold cpreB at h
    cases hchoice : cpreChoice? E g inside s with
    | none =>
        rw [hchoice] at h
        exact Bool.noConfusion h
    | some q =>
      have hfound : q ∈ E.queries.elements ∧ cpreQueryB E g inside s q = true := by
        apply findList?_some_sound
        exact hchoice
      have hq := hfound.2
      unfold cpreQueryB at hq
      have hparts := (boolAnd_eq_true_iff
        (playableB E s g q)
        (allList
          (fun r => (!realizableB E s q r) || inside (E.advance s g q r))
          E.responses.elements)).mp hq
      refine ⟨q, (playableB_eq_true_iff E s g q).mp hparts.1, ?_⟩
      intro r hr
      have hpoint := (allList_eq_true_iff
        (fun r => (!realizableB E s q r) || inside (E.advance s g q r))
        E.responses.elements).mp hparts.2 r (E.responses.complete r)
      exact (boolNotOr_eq_true_iff
        (realizableB E s q r)
        (inside (E.advance s g q r))).mp hpoint
        ((realizableB_eq_true_iff E s q r).mpr hr)
  · rintro ⟨q, hplay, hall⟩
    have hquery : cpreQueryB E g inside s q = true := by
      unfold cpreQueryB
      apply (boolAnd_eq_true_iff
        (playableB E s g q)
        (allList
          (fun r => (!realizableB E s q r) || inside (E.advance s g q r))
          E.responses.elements)).mpr
      constructor
      · exact (playableB_eq_true_iff E s g q).mpr hplay
      · apply (allList_eq_true_iff
          (fun r => (!realizableB E s q r) || inside (E.advance s g q r))
          E.responses.elements).mpr
        intro r _
        apply (boolNotOr_eq_true_iff
          (realizableB E s q r)
          (inside (E.advance s g q r))).mpr
        intro hr
        exact hall r ((realizableB_eq_true_iff E s q r).mp hr)
    unfold cpreB
    cases hchoice : cpreChoice? E g inside s with
    | some found => rfl
    | none =>
        have hnone :
            ∀ x, x ∈ E.queries.elements → cpreQueryB E g inside s x = false := by
          apply (findList?_none_iff
            (cpreQueryB E g inside s) E.queries.elements).mp
          exact hchoice
        have hfalse := hnone q (E.queries.complete q)
        rw [hquery] at hfalse
        exact Bool.noConfusion hfalse

theorem controllablePre_mono
    (E : PublicGame) (g : E.Goal)
    {inside₁ inside₂ : E.State → Prop}
    (hsub : ∀ s, inside₁ s → inside₂ s) :
    ∀ s, ControllablePre E g inside₁ s → ControllablePre E g inside₂ s := by
  intro s h
  rcases h with ⟨q, hplay, hall⟩
  exact ⟨q, hplay, fun r hr => hsub _ (hall r hr)⟩

theorem cpreB_congr
    (E : PublicGame) (g : E.Goal)
    (inside₁ inside₂ : E.State → Bool)
    (hinside : ∀ s, inside₁ s = inside₂ s) (s : E.State) :
    cpreB E g inside₁ s = cpreB E g inside₂ s := by
  cases h₁ : cpreB E g inside₁ s with
  | false =>
      cases h₂ : cpreB E g inside₂ s with
      | false => rfl
      | true =>
          have hp₂ := (cpreB_eq_true_iff E g inside₂ s).mp h₂
          have hp₁ : ControllablePre E g (fun t => inside₁ t = true) s := by
            rcases hp₂ with ⟨q, hplay, hall⟩
            refine ⟨q, hplay, ?_⟩
            intro r hr
            have hi := hall r hr
            rw [hinside (E.advance s g q r)]
            exact hi
          have htrue := (cpreB_eq_true_iff E g inside₁ s).mpr hp₁
          rw [htrue] at h₁
          exact Bool.noConfusion h₁
  | true =>
      cases h₂ : cpreB E g inside₂ s with
      | true => rfl
      | false =>
          have hp₁ := (cpreB_eq_true_iff E g inside₁ s).mp h₁
          have hp₂ : ControllablePre E g (fun t => inside₂ t = true) s := by
            rcases hp₁ with ⟨q, hplay, hall⟩
            refine ⟨q, hplay, ?_⟩
            intro r hr
            have hi := hall r hr
            rw [← hinside (E.advance s g q r)]
            exact hi
          have htrue := (cpreB_eq_true_iff E g inside₂ s).mpr hp₂
          rw [htrue] at h₂
          exact Bool.noConfusion h₂

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.cpreB_eq_true_iff
#print axioms Repairability.PublicGame.controllablePre_mono
#print axioms Repairability.PublicGame.cpreB_congr
/- AXIOM_AUDIT_END -/
