import Repairability.Stable
import Repairability.Cardinality

namespace Repairability.PublicGame

theorem winningWithinB_mono
    (E : PublicGame) (g : E.Goal) :
    ∀ fuel s,
      winningWithinB E g fuel s = true →
      winningWithinB E g (fuel + 1) s = true := by
  intro fuel
  induction fuel with
  | zero =>
      intro s h
      apply (boolOr_eq_true_iff
        (targetB E s g)
        (cpreB E g (winningWithinB E g 0) s)).mpr
      exact Or.inl h
  | succ fuel ih =>
      intro s h
      have hor := (boolOr_eq_true_iff
        (targetB E s g)
        (cpreB E g (winningWithinB E g fuel) s)).mp h
      apply (boolOr_eq_true_iff
        (targetB E s g)
        (cpreB E g (winningWithinB E g (fuel + 1)) s)).mpr
      cases hor with
      | inl htarget => exact Or.inl htarget
      | inr hcpre =>
          apply Or.inr
          apply (cpreB_eq_true_iff E g (winningWithinB E g (fuel + 1)) s).mpr
          rcases (cpreB_eq_true_iff E g (winningWithinB E g fuel) s).mp hcpre with
            ⟨q, hplay, hall⟩
          refine ⟨q, hplay, ?_⟩
          intro r hr
          exact ih _ (hall r hr)

theorem stableAt_next
    (E : PublicGame) (g : E.Goal) (fuel : Nat)
    (hstable : StableAt E g fuel) :
    StableAt E g (fuel + 1) := by
  intro s
  change
    (targetB E s g || cpreB E g (winningWithinB E g fuel) s) =
    (targetB E s g || cpreB E g (winningWithinB E g (fuel + 1)) s)
  have hcpre := cpreB_congr E g
    (winningWithinB E g fuel)
    (winningWithinB E g (fuel + 1)) hstable s
  rw [hcpre]

theorem stableAt_forward
    (E : PublicGame) (g : E.Goal) (fuel : Nat)
    (hstable : StableAt E g fuel) :
    ∀ delta, StableAt E g (fuel + delta) := by
  intro delta
  induction delta with
  | zero =>
      rw [Nat.add_zero]
      exact hstable
  | succ delta ih =>
      rw [Nat.add_succ]
      exact stableAt_next E g (fuel + delta) ih

def layerCount (E : PublicGame) (g : E.Goal) (fuel : Nat) : Nat :=
  trueCount (winningWithinB E g fuel) E.states.elements

theorem layerCount_le_stateCount
    (E : PublicGame) (g : E.Goal) (fuel : Nat) :
    layerCount E g fuel ≤ E.states.elements.length :=
  trueCount_le_length (winningWithinB E g fuel) E.states.elements

theorem unstable_has_new_state
    (E : PublicGame) (g : E.Goal) (fuel : Nat)
    (hunstable : stableB E g fuel = false) :
    ∃ s,
      winningWithinB E g fuel s = false ∧
      winningWithinB E g (fuel + 1) s = true := by
  have hwitness := (allList_eq_false_iff
    (fun s =>
      decideWith
        (inferInstance : Decidable
          (winningWithinB E g fuel s = winningWithinB E g (fuel + 1) s)))
    E.states.elements).mp hunstable
  rcases hwitness with ⟨s, _, hdecide⟩
  have hneq :
      winningWithinB E g fuel s ≠ winningWithinB E g (fuel + 1) s := by
    intro heq
    have htrue := (decideWith_eq_true_iff
      (inferInstance : Decidable
        (winningWithinB E g fuel s = winningWithinB E g (fuel + 1) s))).mpr heq
    rw [htrue] at hdecide
    exact Bool.noConfusion hdecide
  have hmono := winningWithinB_mono E g fuel s
  cases hold : winningWithinB E g fuel s with
  | false =>
      cases hnew : winningWithinB E g (fuel + 1) s with
      | false => exact False.elim (hneq (hold.trans hnew.symm))
      | true => exact ⟨s, hold, hnew⟩
  | true =>
      have hnewTrue := hmono hold
      cases hnew : winningWithinB E g (fuel + 1) s with
      | false =>
          rw [hnew] at hnewTrue
          exact Bool.noConfusion hnewTrue
      | true => exact False.elim (hneq (hold.trans hnew.symm))

theorem layerCount_strict_of_unstable
    (E : PublicGame) (g : E.Goal) (fuel : Nat)
    (hunstable : stableB E g fuel = false) :
    layerCount E g fuel < layerCount E g (fuel + 1) := by
  rcases unstable_has_new_state E g fuel hunstable with
    ⟨s, hold, hnew⟩
  exact trueCount_lt_of_witness
    (winningWithinB E g fuel)
    (winningWithinB E g (fuel + 1))
    E.states.elements
    (fun t _ ht => winningWithinB_mono E g fuel t ht)
    s (E.states.complete s) hold hnew

theorem unstable_before
    (E : PublicGame) (g : E.Goal) {earlier later : Nat}
    (hle : earlier ≤ later)
    (hlater : stableB E g later = false) :
    stableB E g earlier = false := by
  cases hearlier : stableB E g earlier with
  | false => rfl
  | true =>
      have hsEarly := (stableB_eq_true_iff E g earlier).mp hearlier
      rcases Nat.le.dest hle with ⟨delta, hdelta⟩
      have hsLater : StableAt E g later := by
        rw [← hdelta]
        exact stableAt_forward E g earlier hsEarly delta
      have htrue := (stableB_eq_true_iff E g later).mpr hsLater
      rw [htrue] at hlater
      exact Bool.noConfusion hlater

theorem layerCount_growth
    (E : PublicGame) (g : E.Goal) :
    ∀ steps,
      (∀ k, k < steps → layerCount E g k < layerCount E g (k + 1)) →
      steps ≤ layerCount E g steps := by
  intro steps
  induction steps with
  | zero =>
      intro _
      exact Nat.zero_le _
  | succ steps ih =>
      intro hstrict
      have hprior : steps ≤ layerCount E g steps := by
        apply ih
        intro k hk
        exact hstrict k (Nat.lt_trans hk (Nat.lt_succ_self steps))
      have hstep : layerCount E g steps < layerCount E g (steps + 1) :=
        hstrict steps (Nat.lt_succ_self steps)
      exact Nat.le_trans (Nat.succ_le_succ hprior) (Nat.succ_le_of_lt hstep)

theorem intrinsic_stabilization
    (E : PublicGame) (g : E.Goal) :
    StableAt E g E.states.elements.length := by
  let stateCount := E.states.elements.length
  cases hstable : stableB E g stateCount with
  | true => exact (stableB_eq_true_iff E g stateCount).mp hstable
  | false =>
      have hstrict :
          ∀ k, k < stateCount + 1 →
            layerCount E g k < layerCount E g (k + 1) := by
        intro k hk
        have hle : k ≤ stateCount := by
          change k < Nat.succ stateCount at hk
          exact Nat.le_of_lt_succ hk
        exact layerCount_strict_of_unstable E g k
          (unstable_before E g hle hstable)
      have hgrowth : stateCount + 1 ≤ layerCount E g (stateCount + 1) :=
        layerCount_growth E g (stateCount + 1) hstrict
      have hbound : layerCount E g (stateCount + 1) ≤ stateCount :=
        layerCount_le_stateCount E g (stateCount + 1)
      have himpossible : stateCount + 1 ≤ stateCount :=
        Nat.le_trans hgrowth hbound
      exact False.elim ((Nat.not_succ_le_self stateCount) himpossible)

def intrinsicFuel (E : PublicGame) : Nat :=
  E.states.elements.length

def CertifiedRepairableAt
    (E : PublicGame) (s : E.State) (g : E.Goal) : Prop :=
  ∃ depth, Nonempty (PublicTreeWithin E g depth s)

inductive TotalSolveResult
    (E : PublicGame) (g : E.Goal) (s : E.State) : Type
  | win :
      PublicTreeWithin E g (intrinsicFuel E) s →
      TotalSolveResult E g s
  | lose :
      StableLoseCertificate E g (intrinsicFuel E) s →
      TotalSolveResult E g s

def solveTotal
    (E : PublicGame) (g : E.Goal) (s : E.State) :
    TotalSolveResult E g s := by
  have hstable : stableB E g (intrinsicFuel E) = true :=
    (stableB_eq_true_iff E g (intrinsicFuel E)).mpr
      (intrinsic_stabilization E g)
  cases hwin : winningWithinB E g (intrinsicFuel E) s with
  | true =>
      exact TotalSolveResult.win
        (winningWithinB_build E g (intrinsicFuel E) s hwin)
  | false =>
      exact TotalSolveResult.lose ⟨hstable, hwin⟩

theorem certifiedRepairable_iff_intrinsic_tree
    (E : PublicGame) (s : E.State) (g : E.Goal) :
    CertifiedRepairableAt E s g ↔
      Nonempty (PublicTreeWithin E g (intrinsicFuel E) s) := by
  constructor
  · rintro ⟨depth, htree⟩
    cases hwin : winningWithinB E g (intrinsicFuel E) s with
    | true => exact winningWithinB_sound E g (intrinsicFuel E) s hwin
    | false =>
        rcases htree with ⟨tree⟩
        exact False.elim (stableOutside_no_tree E g (intrinsicFuel E)
          (intrinsic_stabilization E g) hwin tree)
  · intro htree
    exact ⟨intrinsicFuel E, htree⟩

theorem certifiedRepairable_decidable
    (E : PublicGame) (s : E.State) (g : E.Goal) :
    CertifiedRepairableAt E s g ∨ ¬ CertifiedRepairableAt E s g := by
  cases hsolve : solveTotal E g s with
  | win tree => exact Or.inl ⟨intrinsicFuel E, ⟨tree⟩⟩
  | lose cert =>
      apply Or.inr
      intro hrepair
      have htree := (certifiedRepairable_iff_intrinsic_tree E s g).mp hrepair
      exact stableLoseCertificate_no_tree E g (intrinsicFuel E) s cert
        (intrinsicFuel E) htree

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.intrinsic_stabilization
#print axioms Repairability.PublicGame.solveTotal
#print axioms Repairability.PublicGame.certifiedRepairable_iff_intrinsic_tree
#print axioms Repairability.PublicGame.certifiedRepairable_decidable
/- AXIOM_AUDIT_END -/
