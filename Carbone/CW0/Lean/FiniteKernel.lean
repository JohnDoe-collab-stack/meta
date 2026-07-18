import Carbone.CW0.Lean.ConcreteTwoPhase

/-!
# CW0: finite observational kernel of the concrete two-phase witness

The full admissible source retains an unbounded list of history records.  This
file does not truncate it.  Instead it defines a positive finite observation
of the current structural phase and proves that the repair-driven Core step
commutes with the finite phase transition.
-/

namespace Meta
namespace Carbone
namespace CW0

open RelaxedSemantics

def twoPhaseOfAdmissible
    {source : WorldState}
    (admissible : TwoPhaseAdmissible source) : TwoPhase :=
  match admissible with
  | .generated phase _history => phase

def twoPhaseOfPoint
    (point : twoPhaseWorld.Point) : TwoPhase :=
  twoPhaseOfAdmissible point.2

def twoPhaseKernelStep (phase : TwoPhase) : TwoPhase :=
  phase.other

theorem twoPhaseOfPoint_generated
    (phase : TwoPhase)
    (history : List HistoryRecord) :
    twoPhaseOfPoint
        ⟨ twoPhaseState phase history
        , TwoPhaseAdmissible.generated phase history ⟩ =
      phase :=
  rfl

/-- Every full Core step commutes with the finite phase observation. -/
theorem twoPhaseKernel_commutes
    (point : twoPhaseWorld.Point) :
    twoPhaseOfPoint (twoPhaseGapRepairAlgebra.next point) =
      twoPhaseKernelStep (twoPhaseOfPoint point) := by
  rcases point with ⟨source, admissible⟩
  cases admissible with
  | generated phase history =>
      cases phase <;> rfl

def twoPhaseId : TwoPhase -> Nat
  | .chain => 0
  | .bridged => 1

def twoPhaseName : TwoPhase -> String
  | .chain => "chain"
  | .bridged => "bridged"

structure TwoPhaseKernelTransition where
  source : TwoPhase
  target : TwoPhase
deriving DecidableEq, Repr

def twoPhaseKernelTransitionAt
    (phase : TwoPhase) : TwoPhaseKernelTransition where
  source := phase
  target := twoPhaseKernelStep phase

/-- The complete finite domain exported for exhaustive phase conformance. -/
def twoPhaseKernelTransitions : List TwoPhaseKernelTransition :=
  [ twoPhaseKernelTransitionAt .chain
  , twoPhaseKernelTransitionAt .bridged ]

theorem twoPhaseKernelTransitionAt_target
    (phase : TwoPhase) :
    (twoPhaseKernelTransitionAt phase).target = twoPhaseKernelStep phase :=
  rfl

theorem twoPhaseKernel_chain_target :
    (twoPhaseKernelTransitionAt .chain).target = .bridged :=
  rfl

theorem twoPhaseKernel_bridged_target :
    (twoPhaseKernelTransitionAt .bridged).target = .chain :=
  rfl

theorem twoPhaseKernel_two_steps
    (phase : TwoPhase) :
    twoPhaseKernelStep (twoPhaseKernelStep phase) = phase := by
  cases phase <;> rfl

end CW0
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CW0.twoPhaseKernelTransitions
#print axioms Meta.Carbone.CW0.twoPhaseKernel_commutes
#print axioms Meta.Carbone.CW0.twoPhaseKernel_two_steps
/- AXIOM_AUDIT_END -/
