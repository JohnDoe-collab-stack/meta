import Repairability.Depth

namespace Repairability.PublicGame

/--
Executable bounded verdict.  `open` means only that the declared depth was
insufficient; it is deliberately not exposed as a global impossibility proof.
-/
inductive BoundedSolveResult
    (E : PublicGame) (g : E.Goal) (fuel : Nat) (s : E.State) : Type
  | win : PublicTreeWithin E g fuel s → BoundedSolveResult E g fuel s
  | open : winningWithinB E g fuel s = false → BoundedSolveResult E g fuel s

def solveWithin
    (E : PublicGame) (g : E.Goal) (fuel : Nat) (s : E.State) :
    BoundedSolveResult E g fuel s := by
  cases h : winningWithinB E g fuel s with
  | false => exact BoundedSolveResult.open h
  | true => exact BoundedSolveResult.win (winningWithinB_build E g fuel s h)

theorem solveWithin_complete_at_fuel
    (E : PublicGame) (g : E.Goal) (fuel : Nat) (s : E.State) :
    winningWithinB E g fuel s = true ↔
      Nonempty (PublicTreeWithin E g fuel s) :=
  winningWithinB_iff_tree E g fuel s

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.solveWithin
#print axioms Repairability.PublicGame.solveWithin_complete_at_fuel
/- AXIOM_AUDIT_END -/
