import Repairability.CostOptimality
import Repairability.Examples.OneStep

namespace Repairability.Examples.CostOptimal

open OneStep

def exactPosterior : PublicGame.ExactPosteriorCompiler game where
  responseExact := by
    intro s g q r w ha hr hc
    rcases hr with ⟨actual, hactual, hresponse⟩
    change OneStep.compatible s actual = true at hactual
    change actual = r at hresponse
    change OneStep.compatible (OneStep.advance s g q r) w = true at hc
    change w = r
    cases g
    cases q
    cases s <;> cases r <;> cases w <;> cases actual <;>
      cases hactual <;> cases hresponse <;> cases hc <;> rfl

def targetFalse : PublicGame.CertifiedTarget game State.sawFalse () :=
  (PublicGame.targetB_eq_true_iff game State.sawFalse ()).mp rfl

def targetTrue : PublicGame.CertifiedTarget game State.sawTrue () :=
  (PublicGame.targetB_eq_true_iff game State.sawTrue ()).mp rfl

def startPlayable : PublicGame.Playable game State.start () () :=
  (PublicGame.playableB_eq_true_iff game State.start () ()).mp rfl

def childStrategy :
    ∀ r, PublicGame.Realizable game State.start () r →
      PublicGame.PublicTreeWithin game () 0 (game.advance State.start () () r)
  | false, _ => PublicGame.PublicTreeWithin.leaf targetFalse
  | true, _ => PublicGame.PublicTreeWithin.leaf targetTrue

def optimalTree : PublicGame.PublicTreeWithin game () 1 State.start :=
  PublicGame.PublicTreeWithin.query () startPlayable childStrategy

def potential : State → Nat
  | State.start => 1
  | State.sawFalse => 0
  | State.sawTrue => 0

theorem potential_checked :
    PublicGame.costLowerPotentialB game () potential = true := by
  rfl

theorem every_execution_costs_at_most_one
    {w : Bool} {cost : Nat}
    (execution : PublicGame.PublicExecutionCost game () optimalTree w cost) :
    cost ≤ 1 :=
  PublicGame.publicExecutionCost_le_depth_of_unitCost game ()
    (by intro s q; exact Nat.le_refl 1) execution

def falseExecution :
    PublicGame.PublicExecutionCost game () optimalTree false 1 := by
  have hw : PublicGame.Compatible game State.start false := by rfl
  have hchild :
      PublicGame.PublicExecutionCost game ()
        (childStrategy false ⟨false, hw, rfl⟩) false 0 :=
    PublicGame.PublicExecutionCost.leaf targetFalse false (by rfl)
  exact @PublicGame.PublicExecutionCost.query
    game () 0 State.start () startPlayable childStrategy false hw 0 hchild

def exactWorstCase :
    PublicGame.CertifiedWorstCaseCost game () optimalTree 1 where
  upper := by
    intro w cost execution
    exact every_execution_costs_at_most_one execution
  attained := ⟨false, falseExecution⟩

def optimalCertificate :
    PublicGame.OptimalCostCertificate game exactPosterior () State.start where
  depth := 1
  tree := optimalTree
  announcedCost := 1
  exactWorstCase := exactWorstCase
  potential := potential
  potentialChecked := potential_checked
  attainedPotential := rfl

theorem globally_minimal_against_every_finite_tree :
    ∀ {depth} (other : PublicGame.PublicTreeWithin game () depth State.start)
      {otherCost : Nat},
      PublicGame.CertifiedWorstCaseCost game () other otherCost →
      PublicGame.emittedCost optimalCertificate ≤ otherCost :=
  PublicGame.optimal_lower_bound optimalCertificate

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.Examples.CostOptimal.exactPosterior
#print axioms Repairability.Examples.CostOptimal.every_execution_costs_at_most_one
#print axioms Repairability.Examples.CostOptimal.falseExecution
#print axioms Repairability.Examples.CostOptimal.exactWorstCase
#print axioms Repairability.Examples.CostOptimal.optimalCertificate
#print axioms Repairability.Examples.CostOptimal.globally_minimal_against_every_finite_tree
/- AXIOM_AUDIT_END -/
