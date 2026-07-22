import Repairability.FixedPoint

namespace Repairability.PublicGame

structure ClosedWinningPredicate
    (E : PublicGame) (g : E.Goal) (inside : E.State → Bool) : Prop where
  containsTargets :
    ∀ s, CertifiedTarget E s g → inside s = true
  containsPredecessors :
    ∀ s q, Playable E s g q →
      (∀ r, Realizable E s q r → inside (E.advance s g q r) = true) →
      inside s = true

theorem winningWithinB_le_closed
    (E : PublicGame) (g : E.Goal) (inside : E.State → Bool)
    (hclosed : ClosedWinningPredicate E g inside) :
    ∀ fuel s, winningWithinB E g fuel s = true → inside s = true := by
  intro fuel
  induction fuel with
  | zero =>
      intro s htarget
      exact hclosed.containsTargets s
        ((targetB_eq_true_iff E s g).mp htarget)
  | succ fuel ih =>
      intro s hwin
      have hcases := (boolOr_eq_true_iff
        (targetB E s g)
        (cpreB E g (winningWithinB E g fuel) s)).mp hwin
      cases hcases with
      | inl htarget =>
          exact hclosed.containsTargets s
            ((targetB_eq_true_iff E s g).mp htarget)
      | inr hcpre =>
          rcases (cpreB_eq_true_iff E g (winningWithinB E g fuel) s).mp
            hcpre with ⟨q, hplay, hall⟩
          apply hclosed.containsPredecessors s q hplay
          intro r hr
          exact ih _ (hall r hr)

theorem intrinsicWinning_least
    (E : PublicGame) (g : E.Goal) (inside : E.State → Bool)
    (hclosed : ClosedWinningPredicate E g inside) :
    ∀ s, winningWithinB E g (intrinsicFuel E) s = true → inside s = true :=
  winningWithinB_le_closed E g inside hclosed (intrinsicFuel E)

theorem totalWinLose_exclusive
    (E : PublicGame) (g : E.Goal) (s : E.State)
    (win : PublicTreeWithin E g (intrinsicFuel E) s)
    (lose : StableLoseCertificate E g (intrinsicFuel E) s) : False :=
  stableLoseCertificate_no_tree E g (intrinsicFuel E) s lose
    (intrinsicFuel E) ⟨win⟩

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.winningWithinB_le_closed
#print axioms Repairability.PublicGame.intrinsicWinning_least
#print axioms Repairability.PublicGame.totalWinLose_exclusive
/- AXIOM_AUDIT_END -/
