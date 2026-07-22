import Repairability.FixedPoint

namespace Repairability.Examples.OneStep

inductive State where
  | start
  | sawFalse
  | sawTrue
deriving DecidableEq, Repr

def boolCarrier : FiniteCarrier Bool where
  elements := [false, true]
  nodup := by decide
  complete := by
    intro b
    cases b
    · exact List.Mem.head [true]
    · exact List.Mem.tail false (List.Mem.head [])
  eqDec := fun x y => inferInstance

def unitCarrier : FiniteCarrier Unit where
  elements := [()]
  nodup := by decide
  complete := by
    intro x
    cases x
    exact List.Mem.head []
  eqDec := fun x y => inferInstance

def stateCarrier : FiniteCarrier State where
  elements := [State.start, State.sawFalse, State.sawTrue]
  nodup := by decide
  complete := by
    intro s
    cases s
    · exact List.Mem.head [State.sawFalse, State.sawTrue]
    · exact List.Mem.tail State.start (List.Mem.head [State.sawTrue])
    · exact List.Mem.tail State.start
        (List.Mem.tail State.sawFalse (List.Mem.head []))
  eqDec := fun x y => inferInstance

def compatible : State → Bool → Bool
  | State.start, _ => true
  | State.sawFalse, false => true
  | State.sawFalse, true => false
  | State.sawTrue, false => false
  | State.sawTrue, true => true

def advance : State → Unit → Unit → Bool → State
  | _, _, _, false => State.sawFalse
  | _, _, _, true => State.sawTrue

def decision : State → Unit → Option Bool
  | State.start, _ => none
  | State.sawFalse, _ => some false
  | State.sawTrue, _ => some true

def game : PublicGame where
  World := Bool
  State := State
  Goal := Unit
  Action := Bool
  Query := Unit
  Response := Bool
  worlds := boolCarrier
  states := stateCarrier
  goals := unitCarrier
  actions := boolCarrier
  queries := unitCarrier
  responses := boolCarrier
  actionEq := fun x y => inferInstance
  responseEq := fun x y => inferInstance
  compatible := compatible
  required := fun _ w => w
  authorized := fun _ _ _ => true
  respond := fun w _ => w
  advance := advance
  decision? := decision
  stateSafe := fun _ _ => true
  priorClosuresRetained := fun _ _ => true
  queryCost := fun _ _ _ => 1
  posteriorContains := by
    intro s g q r w ha hc hr
    cases g
    cases q
    cases s <;> cases w <;> cases r <;> cases hr <;> cases hc <;> rfl
  fiberMonotone := by
    intro s g q r w ha hreal hc
    rcases hreal with ⟨actual, hactual, hresponse⟩
    cases g
    cases q
    cases s <;> cases w <;> cases r <;> cases actual <;>
      cases hresponse <;> cases hactual <;> cases hc <;> rfl
  closuresRetained := by
    intro s g q r ha hreal
    rfl

theorem start_not_target :
    PublicGame.targetB game State.start () = false := by
  rfl

theorem start_wins_in_one :
    PublicGame.winningWithinB game () 1 State.start = true := by
  rfl

def extractedStrategy :
    PublicGame.PublicTreeWithin game () 1 State.start :=
  PublicGame.winningWithinB_build game () 1 State.start start_wins_in_one

def computedVerdict :
    PublicGame.BoundedSolveResult game () 1 State.start :=
  PublicGame.solveWithin game () 1 State.start

def computedTotalVerdict :
    PublicGame.TotalSolveResult game () State.start :=
  PublicGame.solveTotal game () State.start

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.Examples.OneStep.start_wins_in_one
#print axioms Repairability.Examples.OneStep.extractedStrategy
#print axioms Repairability.Examples.OneStep.computedVerdict
#print axioms Repairability.Examples.OneStep.computedTotalVerdict
/- AXIOM_AUDIT_END -/
