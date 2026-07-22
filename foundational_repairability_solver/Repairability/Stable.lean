import Repairability.BoundedSolver

namespace Repairability.PublicGame

def StableAt (E : PublicGame) (g : E.Goal) (fuel : Nat) : Prop :=
  ∀ s, winningWithinB E g fuel s = winningWithinB E g (fuel + 1) s

def stableB (E : PublicGame) (g : E.Goal) (fuel : Nat) : Bool :=
  allList
    (fun s =>
      decideWith
        (inferInstance : Decidable
          (winningWithinB E g fuel s = winningWithinB E g (fuel + 1) s)))
    E.states.elements

theorem stableB_eq_true_iff
    (E : PublicGame) (g : E.Goal) (fuel : Nat) :
    stableB E g fuel = true ↔ StableAt E g fuel := by
  constructor
  · intro h s
    have hpoint := (allList_eq_true_iff
      (fun s =>
        decideWith
          (inferInstance : Decidable
            (winningWithinB E g fuel s = winningWithinB E g (fuel + 1) s)))
      E.states.elements).mp h s (E.states.complete s)
    exact (decideWith_eq_true_iff
      (inferInstance : Decidable
        (winningWithinB E g fuel s = winningWithinB E g (fuel + 1) s))).mp hpoint
  · intro h
    apply (allList_eq_true_iff
      (fun s =>
        decideWith
          (inferInstance : Decidable
            (winningWithinB E g fuel s = winningWithinB E g (fuel + 1) s)))
      E.states.elements).mpr
    intro s _
    exact (decideWith_eq_true_iff
      (inferInstance : Decidable
        (winningWithinB E g fuel s = winningWithinB E g (fuel + 1) s))).mpr (h s)

theorem cpreB_false_has_escape
    (E : PublicGame) (g : E.Goal) (inside : E.State → Bool) (s : E.State)
    (hcpre : cpreB E g inside s = false)
    (q : E.Query) (hplay : Playable E s g q) :
    ∃ r, Realizable E s q r ∧ inside (E.advance s g q r) = false := by
  cases hany : anyList
      (fun r =>
        realizableB E s q r && (!inside (E.advance s g q r)))
      E.responses.elements with
  | true =>
      rcases (anyList_eq_true_iff
        (fun r =>
          realizableB E s q r && (!inside (E.advance s g q r)))
        E.responses.elements).mp hany with ⟨r, _, hescape⟩
      have hparts := (boolAnd_eq_true_iff
        (realizableB E s q r)
        (!inside (E.advance s g q r))).mp hescape
      exact ⟨r,
        (realizableB_eq_true_iff E s q r).mp hparts.1,
        (boolNot_eq_true_iff (inside (E.advance s g q r))).mp hparts.2⟩
  | false =>
      have hnone := (anyList_eq_false_iff
        (fun r =>
          realizableB E s q r && (!inside (E.advance s g q r)))
        E.responses.elements).mp hany
      have hall :
          ∀ r, Realizable E s q r → inside (E.advance s g q r) = true := by
        intro r hr
        have hreal : realizableB E s q r = true :=
          (realizableB_eq_true_iff E s q r).mpr hr
        have hescapeFalse := hnone r (E.responses.complete r)
        cases hinside : inside (E.advance s g q r) with
        | true => rfl
        | false =>
            have hnot : (!inside (E.advance s g q r)) = true := by
              rw [hinside]
              rfl
            have hescapeTrue :
                (realizableB E s q r && (!inside (E.advance s g q r))) = true :=
              (boolAnd_eq_true_iff
                (realizableB E s q r)
                (!inside (E.advance s g q r))).mpr ⟨hreal, hnot⟩
            rw [hescapeTrue] at hescapeFalse
            exact Bool.noConfusion hescapeFalse
      have hcpreTrue : cpreB E g inside s = true :=
        (cpreB_eq_true_iff E g inside s).mpr ⟨q, hplay, hall⟩
      rw [hcpreTrue] at hcpre
      exact Bool.noConfusion hcpre

theorem stableOutside_components
    (E : PublicGame) (g : E.Goal) (fuel : Nat)
    (hstable : StableAt E g fuel) (s : E.State)
    (hout : winningWithinB E g fuel s = false) :
    targetB E s g = false ∧
      cpreB E g (winningWithinB E g fuel) s = false := by
  have hnext : winningWithinB E g (fuel + 1) s = false := by
    rw [← hstable s]
    exact hout
  change
    (targetB E s g || cpreB E g (winningWithinB E g fuel) s) = false
    at hnext
  exact (boolOr_eq_false_iff
    (targetB E s g)
    (cpreB E g (winningWithinB E g fuel) s)).mp hnext

theorem stableOutside_not_target
    (E : PublicGame) (g : E.Goal) (fuel : Nat)
    (hstable : StableAt E g fuel) (s : E.State)
    (hout : winningWithinB E g fuel s = false) :
    ¬ CertifiedTarget E s g := by
  intro htarget
  have hfalse := (stableOutside_components E g fuel hstable s hout).1
  have htrue := (targetB_eq_true_iff E s g).mpr htarget
  rw [htrue] at hfalse
  exact Bool.noConfusion hfalse

theorem stableOutside_closed
    (E : PublicGame) (g : E.Goal) (fuel : Nat)
    (hstable : StableAt E g fuel) (s : E.State)
    (hout : winningWithinB E g fuel s = false) :
    ∀ q, Playable E s g q →
      ∃ r, Realizable E s q r ∧
        winningWithinB E g fuel (E.advance s g q r) = false := by
  intro q hplay
  exact cpreB_false_has_escape E g (winningWithinB E g fuel) s
    (stableOutside_components E g fuel hstable s hout).2 q hplay

theorem stableOutside_no_tree
    (E : PublicGame) (g : E.Goal) (fuel : Nat)
    (hstable : StableAt E g fuel) :
    ∀ {depth s},
      winningWithinB E g fuel s = false →
      PublicTreeWithin E g depth s → False := by
  intro depth s hout tree
  induction tree with
  | leaf htarget =>
      exact stableOutside_not_target E g fuel hstable _ hout htarget
  | @query depth s q hplay children ih =>
      rcases stableOutside_closed E g fuel hstable _ hout q hplay with
        ⟨r, hr, hchild⟩
      exact ih r hr hchild

structure StableLoseCertificate
    (E : PublicGame) (g : E.Goal) (fuel : Nat) (s : E.State) where
  stable : stableB E g fuel = true
  rootOutside : winningWithinB E g fuel s = false

theorem stableLoseCertificate_no_tree
    (E : PublicGame) (g : E.Goal) (fuel : Nat) (s : E.State)
    (cert : StableLoseCertificate E g fuel s) :
    ∀ depth, ¬ Nonempty (PublicTreeWithin E g depth s) := by
  intro depth htree
  rcases htree with ⟨tree⟩
  exact stableOutside_no_tree E g fuel
    ((stableB_eq_true_iff E g fuel).mp cert.stable)
    cert.rootOutside tree

inductive CheckedSolveResult
    (E : PublicGame) (g : E.Goal) (fuel : Nat) (s : E.State) : Type
  | win : PublicTreeWithin E g fuel s → CheckedSolveResult E g fuel s
  | lose : StableLoseCertificate E g fuel s → CheckedSolveResult E g fuel s
  | open :
      winningWithinB E g fuel s = false →
      stableB E g fuel = false →
      CheckedSolveResult E g fuel s

def solveChecked
    (E : PublicGame) (g : E.Goal) (fuel : Nat) (s : E.State) :
    CheckedSolveResult E g fuel s := by
  cases hwin : winningWithinB E g fuel s with
  | true =>
      exact CheckedSolveResult.win (winningWithinB_build E g fuel s hwin)
  | false =>
      cases hstable : stableB E g fuel with
      | true => exact CheckedSolveResult.lose ⟨hstable, hwin⟩
      | false => exact CheckedSolveResult.open hwin hstable

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.stableOutside_closed
#print axioms Repairability.PublicGame.stableOutside_no_tree
#print axioms Repairability.PublicGame.stableLoseCertificate_no_tree
#print axioms Repairability.PublicGame.solveChecked
/- AXIOM_AUDIT_END -/
