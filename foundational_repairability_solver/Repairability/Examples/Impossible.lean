import Repairability.FixedPoint
import Repairability.Examples.OneStep

namespace Repairability.Examples.Impossible

def game : PublicGame where
  World := Bool
  State := Unit
  Goal := Unit
  Action := Bool
  Query := Unit
  Response := Unit
  worlds := OneStep.boolCarrier
  states := OneStep.unitCarrier
  goals := OneStep.unitCarrier
  actions := OneStep.boolCarrier
  queries := OneStep.unitCarrier
  responses := OneStep.unitCarrier
  actionEq := fun x y => inferInstance
  responseEq := fun x y => inferInstance
  compatible := fun _ _ => true
  required := fun _ w => w
  authorized := fun _ _ _ => true
  respond := fun _ _ => ()
  advance := fun _ _ _ _ => ()
  decision? := fun _ _ => none
  stateSafe := fun _ _ => true
  priorClosuresRetained := fun _ _ => true
  queryCost := fun _ _ _ => 1
  posteriorContains := by
    intro s g q r w ha hc hr
    rfl
  fiberMonotone := by
    intro s g q r w ha hreal hc
    rfl
  closuresRetained := by
    intro s g q r ha hreal
    rfl

theorem root_outside_initial :
    PublicGame.winningWithinB game () 0 () = false := by
  rfl

theorem initial_layer_stable :
    PublicGame.stableB game () 0 = true := by
  rfl

def loseCertificate :
    PublicGame.StableLoseCertificate game () 0 () :=
  ⟨initial_layer_stable, root_outside_initial⟩

theorem no_finite_public_repair :
    ∀ depth,
      ¬ Nonempty (PublicGame.PublicTreeWithin game () depth ()) :=
  PublicGame.stableLoseCertificate_no_tree game () 0 () loseCertificate

def computedVerdict :
    PublicGame.CheckedSolveResult game () 0 () :=
  PublicGame.solveChecked game () 0 ()

def computedTotalVerdict :
    PublicGame.TotalSolveResult game () () :=
  PublicGame.solveTotal game () ()

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.Examples.Impossible.loseCertificate
#print axioms Repairability.Examples.Impossible.no_finite_public_repair
#print axioms Repairability.Examples.Impossible.computedVerdict
#print axioms Repairability.Examples.Impossible.computedTotalVerdict
/- AXIOM_AUDIT_END -/
