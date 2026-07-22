import Repairability.Predecessor

namespace Repairability.PublicGame

def winningWithinB
    (E : PublicGame) (g : E.Goal) : Nat → E.State → Bool
  | 0, s => targetB E s g
  | n + 1, s => targetB E s g || cpreB E g (winningWithinB E g n) s

/-- A public repair tree whose query depth is at most `fuel`. -/
inductive PublicTreeWithin (E : PublicGame) (g : E.Goal) : Nat → E.State → Type
  | leaf {fuel s} : CertifiedTarget E s g → PublicTreeWithin E g fuel s
  | query {fuel s} (q : E.Query) :
      Playable E s g q →
      (∀ r, Realizable E s q r →
        PublicTreeWithin E g fuel (E.advance s g q r)) →
      PublicTreeWithin E g (fuel + 1) s

theorem target_winningWithinB
    (E : PublicGame) (g : E.Goal) (s : E.State) (n : Nat)
    (h : targetB E s g = true) :
    winningWithinB E g n s = true := by
  cases n with
  | zero => exact h
  | succ n =>
      apply (boolOr_eq_true_iff
        (targetB E s g)
        (cpreB E g (winningWithinB E g n) s)).mpr
      exact Or.inl h

def winningWithinB_build
    (E : PublicGame) (g : E.Goal) :
    (n : Nat) → (s : E.State) → winningWithinB E g n s = true →
      PublicTreeWithin E g n s
  | 0, s, h =>
      PublicTreeWithin.leaf ((targetB_eq_true_iff E s g).mp h)
  | n + 1, s, h => by
      cases htarget : targetB E s g with
      | true =>
          exact PublicTreeWithin.leaf
            ((targetB_eq_true_iff E s g).mp htarget)
      | false =>
          have hcpre : cpreB E g (winningWithinB E g n) s = true := by
            rw [winningWithinB, htarget] at h
            exact h
          cases hchoice : cpreChoice? E g (winningWithinB E g n) s with
          | none =>
              have himpossible : False := by
                unfold cpreB at hcpre
                rw [hchoice] at hcpre
                exact Bool.noConfusion hcpre
              exact False.elim himpossible
          | some q =>
              have hfound :
                  q ∈ E.queries.elements ∧
                    cpreQueryB E g (winningWithinB E g n) s q = true := by
                apply findList?_some_sound
                exact hchoice
              have hquery := hfound.2
              unfold cpreQueryB at hquery
              have hparts := (boolAnd_eq_true_iff
                (playableB E s g q)
                (allList
                  (fun r =>
                    (!realizableB E s q r) ||
                      winningWithinB E g n (E.advance s g q r))
                  E.responses.elements)).mp hquery
              refine PublicTreeWithin.query q
                ((playableB_eq_true_iff E s g q).mp hparts.1) ?_
              intro r hr
              have hpoint := (allList_eq_true_iff
                (fun r =>
                  (!realizableB E s q r) ||
                    winningWithinB E g n (E.advance s g q r))
                E.responses.elements).mp hparts.2 r (E.responses.complete r)
              have hchild := (boolNotOr_eq_true_iff
                (realizableB E s q r)
                (winningWithinB E g n (E.advance s g q r))).mp hpoint
                ((realizableB_eq_true_iff E s q r).mpr hr)
              exact winningWithinB_build E g n (E.advance s g q r) hchild

theorem winningWithinB_sound
    (E : PublicGame) (g : E.Goal) (n : Nat) (s : E.State)
    (h : winningWithinB E g n s = true) :
    Nonempty (PublicTreeWithin E g n s) :=
  ⟨winningWithinB_build E g n s h⟩

theorem publicTreeWithin_complete
    (E : PublicGame) (g : E.Goal) :
    ∀ {n s}, PublicTreeWithin E g n s → winningWithinB E g n s = true := by
  intro n s tree
  induction tree with
  | leaf htarget =>
      exact target_winningWithinB E g _ _
        ((targetB_eq_true_iff E _ g).mpr htarget)
  | @query fuel s q hplay children ih =>
      have hcpre : cpreB E g (winningWithinB E g fuel) s = true := by
        apply (cpreB_eq_true_iff E g (winningWithinB E g fuel) s).mpr
        refine ⟨q, hplay, ?_⟩
        intro r hr
        exact ih r hr
      exact (boolOr_eq_true_iff
        (targetB E s g)
        (cpreB E g (winningWithinB E g fuel) s)).mpr (Or.inr hcpre)

theorem winningWithinB_iff_tree
    (E : PublicGame) (g : E.Goal) (n : Nat) (s : E.State) :
    winningWithinB E g n s = true ↔
      Nonempty (PublicTreeWithin E g n s) := by
  constructor
  · exact winningWithinB_sound E g n s
  · rintro ⟨tree⟩
    exact publicTreeWithin_complete E g tree

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.winningWithinB_iff_tree
#print axioms Repairability.PublicGame.winningWithinB_build
#print axioms Repairability.PublicGame.winningWithinB_sound
#print axioms Repairability.PublicGame.publicTreeWithin_complete
/- AXIOM_AUDIT_END -/
