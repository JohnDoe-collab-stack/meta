import Repairability.FixedPoint

namespace Repairability.PublicGame

def firstWinningUpTo? (E : PublicGame)
    (g : E.Goal) (s : E.State) : Nat → Option Nat
  | 0 =>
      match winningWithinB E g 0 s with
      | true => some 0
      | false => none
  | n + 1 =>
      match firstWinningUpTo? E g s n with
      | some k => some k
      | none =>
          match winningWithinB E g (n + 1) s with
          | true => some (n + 1)
          | false => none

def FirstWinningSpec (E : PublicGame)
    (g : E.Goal) (s : E.State) (bound : Nat) : Option Nat → Prop
  | none =>
      ∀ j, j ≤ bound → winningWithinB E g j s = false
  | some k =>
      k ≤ bound ∧
      winningWithinB E g k s = true ∧
      ∀ j, j < k → winningWithinB E g j s = false

theorem firstWinningUpTo_spec
    (E : PublicGame) (g : E.Goal) (s : E.State) :
    ∀ bound,
      FirstWinningSpec E g s bound (firstWinningUpTo? E g s bound) := by
  intro bound
  induction bound with
  | zero =>
      cases hwin : winningWithinB E g 0 s with
      | false =>
          rw [firstWinningUpTo?, hwin]
          unfold FirstWinningSpec
          intro j hj
          have hj0 : j = 0 := Nat.eq_zero_of_le_zero hj
          cases hj0
          exact hwin
      | true =>
          rw [firstWinningUpTo?, hwin]
          unfold FirstWinningSpec
          constructor
          · exact Nat.le_refl 0
          constructor
          · exact hwin
          · intro j hj
            exact False.elim (Nat.not_lt_zero j hj)
  | succ n ih =>
      cases hprevious : firstWinningUpTo? E g s n with
      | some k =>
          have hspec := ih
          rw [hprevious] at hspec
          rw [firstWinningUpTo?, hprevious]
          unfold FirstWinningSpec
          constructor
          · exact Nat.le_trans hspec.1 (Nat.le_succ n)
          exact hspec.2
      | none =>
          have hspec := ih
          rw [hprevious] at hspec
          cases hlast : winningWithinB E g (n + 1) s with
          | false =>
              rw [firstWinningUpTo?, hprevious, hlast]
              unfold FirstWinningSpec
              intro j hj
              have hcases : j ≤ n ∨ j = n + 1 :=
                Nat.le_succ_iff.mp hj
              cases hcases with
              | inl hle => exact hspec j hle
              | inr heq =>
                  cases heq
                  exact hlast
          | true =>
              rw [firstWinningUpTo?, hprevious, hlast]
              unfold FirstWinningSpec
              constructor
              · exact Nat.le_refl (n + 1)
              constructor
              · exact hlast
              · intro j hj
                have hle : j ≤ n := Nat.le_of_lt_succ hj
                exact hspec j hle

structure DepthOptimalCertificate
    (E : PublicGame) (g : E.Goal) (s : E.State) where
  depth : Nat
  depth_le_intrinsic : depth ≤ intrinsicFuel E
  tree : PublicTreeWithin E g depth s
  allEarlierLose :
    ∀ j, j < depth → winningWithinB E g j s = false

inductive OptimalDepthSolveResult
    (E : PublicGame) (g : E.Goal) (s : E.State) where
  | win (certificate : DepthOptimalCertificate E g s)
  | lose (certificate : StableLoseCertificate E g (intrinsicFuel E) s)

def solveDepthOptimal
    (E : PublicGame) (g : E.Goal) (s : E.State) :
    OptimalDepthSolveResult E g s := by
  let fuel := intrinsicFuel E
  cases hroot : winningWithinB E g fuel s with
  | false =>
      exact .lose {
        stable := (stableB_eq_true_iff E g fuel).mpr
          (intrinsic_stabilization E g)
        rootOutside := hroot
      }
  | true =>
      cases hfirst : firstWinningUpTo? E g s fuel with
      | none =>
          have hspec := firstWinningUpTo_spec E g s fuel
          rw [hfirst] at hspec
          have hfalse := hspec fuel (Nat.le_refl fuel)
          rw [hroot] at hfalse
          contradiction
      | some k =>
          have hspec := firstWinningUpTo_spec E g s fuel
          rw [hfirst] at hspec
          exact .win {
            depth := k
            depth_le_intrinsic := hspec.1
            tree := winningWithinB_build E g k s hspec.2.1
            allEarlierLose := hspec.2.2
          }

theorem depthOptimal_minimal
    {E : PublicGame} {g : E.Goal} {s : E.State}
    (certificate : DepthOptimalCertificate E g s)
    {otherDepth : Nat} (other : PublicTreeWithin E g otherDepth s) :
    certificate.depth ≤ otherDepth := by
  apply Nat.le_of_not_gt
  intro hlt
  have hearlier := certificate.allEarlierLose otherDepth hlt
  have hwins : winningWithinB E g otherDepth s = true :=
    publicTreeWithin_complete E g other
  rw [hwins] at hearlier
  contradiction

theorem solveDepthOptimal_total
    (E : PublicGame) (g : E.Goal) (s : E.State) :
    (∃ certificate, solveDepthOptimal E g s = .win certificate) ∨
    (∃ certificate, solveDepthOptimal E g s = .lose certificate) := by
  cases hresult : solveDepthOptimal E g s with
  | win certificate => exact Or.inl ⟨certificate, rfl⟩
  | lose certificate => exact Or.inr ⟨certificate, rfl⟩

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.firstWinningUpTo_spec
#print axioms Repairability.PublicGame.solveDepthOptimal
#print axioms Repairability.PublicGame.depthOptimal_minimal
#print axioms Repairability.PublicGame.solveDepthOptimal_total
/- AXIOM_AUDIT_END -/
