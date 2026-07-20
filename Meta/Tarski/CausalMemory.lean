import Meta.Tarski.GenericPatchOrbit

/-!
# Intrinsic causal memory for patchable Tarski steps

This module turns the proof-level cumulative invariant of the generic patch
orbit into positive internal data.  A memory is indexed by the candidate it
has actually reached, and every extension stores the complete
`AlgorithmStep` that caused that transition.

No external counter, freshness oracle, decidable sentence equality, or
independent transition is stored.  Soundness of remembered challenges is
derived from local repair, preservation away from the repaired index, and the
next diagonal mismatch.
-/

namespace Meta
namespace ClosedStabilityTheorem
namespace PatchableArithmeticTarskiContext

universe u v

/-! ## Positive memory and intrinsic membership -/

/--
A coherent causal history from `initial` to its indexed current candidate.

Every extension retains the complete syntax-level event.  The result type is
indexed by `event.nextPredicate`, so an unrelated target candidate cannot be
inserted into the history.
-/
inductive CausalMemory
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    patchable.context.Predicate -> Type (max u v) where
  | root :
      CausalMemory patchable initial initial
  | extend
      {current : patchable.context.Predicate}
      (previous : CausalMemory patchable initial current)
      (event : patchable.AlgorithmStep current) :
      CausalMemory patchable initial event.nextPredicate

namespace CausalMemory

/--
Positive evidence that a diagonal challenge occurs in a causal memory.

Membership is defined by structural recursion as the disjunction between the
new event and the preceding memory.  It requires neither decidable equality
on sentences nor a search procedure over a list.
-/
def Remembers
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    {current : patchable.context.Predicate} ->
      CausalMemory patchable initial current ->
      patchable.context.Sentence ->
      Prop
  | _, CausalMemory.root, _ =>
      False
  | _, CausalMemory.extend previous event, sentence =>
      sentence = event.diagonalSentence ∨
        Remembers patchable initial previous sentence

/-- Every remembered challenge remains semantically repaired. -/
theorem correctAt_of_remembers
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    {current : patchable.context.Predicate}
    (memory : CausalMemory patchable initial current)
    {sentence : patchable.context.Sentence}
    (remembered : Remembers patchable initial memory sentence) :
    CorrectAt patchable current sentence := by
  induction memory with
  | root =>
      exact remembered.elim
  | @extend previousCurrent previous event inductionHypothesis =>
      cases remembered with
      | inl sameSentence =>
          rw [sameSentence]
          exact event.repaired_index_agreement
      | inr previousRemembered =>
          have previousCorrect :
              CorrectAt patchable previousCurrent sentence :=
            inductionHypothesis previousRemembered
          have offCurrentIndex :
              sentence = event.diagonalSentence -> False := by
            intro sameSentence
            have eventDiagonalCorrect :
                CorrectAt
                  patchable
                  previousCurrent
                  event.diagonalSentence := by
              rw [← sameSentence]
              exact previousCorrect
            have canonicalDiagonalCorrect :
                CorrectAt
                  patchable
                  previousCurrent
                  (patchable.diagonalSentence previousCurrent) := by
              rw [← event.diagonalSentence_eq]
              exact eventDiagonalCorrect
            exact
              tarski_local_mismatch
                (patchable.context.fixedPoint previousCurrent)
                canonicalDiagonalCorrect
          exact
            (event.preserves_off_index sentence offCurrentIndex).trans
              previousCorrect

/--
The current diagonal challenge cannot already occur in the causal memory.

If it did, memory soundness would make the current candidate correct at its
own fixed point, contradicting the local Tarski mismatch.
-/
theorem current_not_remembered
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    {current : patchable.context.Predicate}
    (memory : CausalMemory patchable initial current) :
    Remembers
        patchable
        initial
        memory
        (patchable.diagonalSentence current) ->
      False := by
  intro remembered
  exact
    tarski_local_mismatch
      (patchable.context.fixedPoint current)
      (correctAt_of_remembers
        patchable
        initial
        memory
        remembered)

/-! ## Adapter to the existing bilateral usage packages -/

/-- A stored algorithmic event exposes the existing complete bilateral view. -/
def completeOfEvent
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    {current : patchable.context.Predicate}
    (event : patchable.AlgorithmStep current) :
    TarskiDynamicRelaxedUsage.TarskiPatchComplete
      patchable
      TarskiDynamicRelaxedUsage.TarskiPatchBranch.causal where
  current := current
  step := event

/-- The forward diagonal view derived from a stored causal event. -/
def forwardOfEvent
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    {current : patchable.context.Predicate}
    (event : patchable.AlgorithmStep current) :
    TarskiDynamicRelaxedUsage.TarskiPatchForward
      patchable
      TarskiDynamicRelaxedUsage.TarskiPatchBranch.causal :=
  (TarskiDynamicRelaxedUsage.tarskiPatchCompleteness patchable)
    |>.forwardOfComplete
      TarskiDynamicRelaxedUsage.TarskiPatchBranch.causal
      (completeOfEvent patchable event)

/-- The backward repair view derived from a stored causal event. -/
def backwardOfEvent
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    {current : patchable.context.Predicate}
    (event : patchable.AlgorithmStep current) :
    TarskiDynamicRelaxedUsage.TarskiPatchBackward
      patchable
      TarskiDynamicRelaxedUsage.TarskiPatchBranch.causal :=
  (TarskiDynamicRelaxedUsage.tarskiPatchCompleteness patchable)
    |>.backwardOfComplete
      TarskiDynamicRelaxedUsage.TarskiPatchBranch.causal
      (completeOfEvent patchable event)

/-- The typed intersection view derived from a stored causal event. -/
def intersectionOfEvent
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    {current : patchable.context.Predicate}
    (event : patchable.AlgorithmStep current) :
    TarskiDynamicRelaxedUsage.TarskiPatchIntersection
      patchable
      TarskiDynamicRelaxedUsage.TarskiPatchBranch.causal :=
  (TarskiDynamicRelaxedUsage.tarskiPatchCompleteness patchable)
    |>.intersectionOfComplete
      TarskiDynamicRelaxedUsage.TarskiPatchBranch.causal
      (completeOfEvent patchable event)

end CausalMemory
end PatchableArithmeticTarskiContext
end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.CausalMemory
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.CausalMemory.Remembers
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.CausalMemory.correctAt_of_remembers
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.CausalMemory.current_not_remembered
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.CausalMemory.completeOfEvent
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.CausalMemory.forwardOfEvent
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.CausalMemory.backwardOfEvent
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.CausalMemory.intersectionOfEvent
/- AXIOM_AUDIT_END -/
