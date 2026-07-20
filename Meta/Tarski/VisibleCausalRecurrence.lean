import Meta.Tarski.CausalOrbit

/-!
# Visible recurrence with causal non-return

An authorized visible observation selects a sentence that is genuinely
remembered by a causal state.  Two later states can therefore expose exactly
the same past diagonal sentence and agree pointwise on its truth response,
while their complete causal memories remain extensionally different.

The visible response is compared with `Iff`, not equality of propositions.
The exact projection equality is ordinary equality of the observed syntactic
sentence.  No constant projection or decidability of semantic truth is used.
-/

namespace Meta
namespace ClosedStabilityTheorem
namespace PatchableArithmeticTarskiContext

universe u v

/-! ## Authorized observations and pointwise visible sameness -/

/-- A visible sentence backed by an actual obligation in the state's memory. -/
structure AuthorizedVisibleObservation
    {patchable : PatchableArithmeticTarskiContext.{u, v}}
    {initial : patchable.context.Predicate}
    (state : CausalState patchable initial) :
    Type (max u v) where
  sentence : patchable.context.Sentence
  remembered :
    CausalMemory.Remembers
      patchable
      initial
      state.memory
      sentence

namespace AuthorizedVisibleObservation

/-- Forget the causal authorization and retain the observed syntax. -/
def project
    {patchable : PatchableArithmeticTarskiContext.{u, v}}
    {initial : patchable.context.Predicate}
    {state : CausalState patchable initial}
    (observation : AuthorizedVisibleObservation state) :
    patchable.context.Sentence :=
  observation.sentence

/-- Every authorized visible observation is correct at its owning state. -/
theorem correctAt
    {patchable : PatchableArithmeticTarskiContext.{u, v}}
    {initial : patchable.context.Predicate}
    {state : CausalState patchable initial}
    (observation : AuthorizedVisibleObservation state) :
    CorrectAt patchable state.current observation.sentence :=
  CausalMemory.correctAt_of_remembers
    patchable
    initial
    state.memory
    observation.remembered

end AuthorizedVisibleObservation

/-- Pointwise visible equivalence of two candidates at a selected sentence. -/
def VisibleSameAt
    {patchable : PatchableArithmeticTarskiContext.{u, v}}
    {initial : patchable.context.Predicate}
    (sentence : patchable.context.Sentence)
    (left right : CausalState patchable initial) :
    Prop :=
  patchable.truthAt left.current sentence ↔
    patchable.truthAt right.current sentence

/-- A challenge remembered by both states has the same visible response. -/
theorem visibleSameAt_of_remembered
    {patchable : PatchableArithmeticTarskiContext.{u, v}}
    {initial : patchable.context.Predicate}
    {left right : CausalState patchable initial}
    {sentence : patchable.context.Sentence}
    (leftRemembers :
      CausalMemory.Remembers
        patchable initial left.memory sentence)
    (rightRemembers :
      CausalMemory.Remembers
        patchable initial right.memory sentence) :
    VisibleSameAt sentence left right :=
  (CausalMemory.correctAt_of_remembers
      patchable initial left.memory leftRemembers).trans
    (CausalMemory.correctAt_of_remembers
      patchable initial right.memory rightRemembers).symm

/-! ## Recurrent observations along the causal orbit -/

/-- Every strict past challenge gives an authorized current observation. -/
def causalOrbitPastObservation
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    {k n : Nat}
    (earlier : k < n) :
    AuthorizedVisibleObservation (causalOrbit patchable initial n) where
  sentence := genericOrbitIndex patchable initial k
  remembered := causalOrbit_remembers_of_lt patchable initial earlier

/-- A past observation projects to the exact historical diagonal sentence. -/
theorem causalOrbitPastObservation_projects
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    {k n : Nat}
    (earlier : k < n) :
    (causalOrbitPastObservation patchable initial earlier).project =
      genericOrbitIndex patchable initial k :=
  rfl

/--
Positive package witnessing exact visible recurrence and causal separation for
the same two states.
-/
structure VisibleRecurrenceWithCausalSeparation
    {patchable : PatchableArithmeticTarskiContext.{u, v}}
    {initial : patchable.context.Predicate}
    (left right : CausalState patchable initial) :
    Type (max u v) where
  sentence : patchable.context.Sentence
  leftObservation : AuthorizedVisibleObservation left
  rightObservation : AuthorizedVisibleObservation right
  leftProjectsToSentence : leftObservation.project = sentence
  rightProjectsToSentence : rightObservation.project = sentence
  sameSentence :
    leftObservation.project = rightObservation.project
  sameVisibleResponse : VisibleSameAt sentence left right
  memorySeparated : MemoryEquivalent left right -> False
  causallySeparated : CausallyEquivalent left right -> False

/--
Every triple `k < n < m` exhibits a past diagonal observation that recurs
visibly between `S_n` and `S_m`, although their causal memories cannot be
identified.
-/
def genericVisibleRecurrenceWithCausalNonReturn
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    {k n m : Nat}
    (first : k < n)
    (second : n < m) :
    VisibleRecurrenceWithCausalSeparation
      (causalOrbit patchable initial n)
      (causalOrbit patchable initial m) := by
  let leftObservation :=
    causalOrbitPastObservation patchable initial first
  let rightObservation :=
    causalOrbitPastObservation
      patchable
      initial
      (Nat.lt_trans first second)
  exact
    { sentence := genericOrbitIndex patchable initial k
      leftObservation := leftObservation
      rightObservation := rightObservation
      leftProjectsToSentence := rfl
      rightProjectsToSentence := rfl
      sameSentence := rfl
      sameVisibleResponse :=
        visibleSameAt_of_remembered
          leftObservation.remembered
          rightObservation.remembered
      memorySeparated :=
        causalOrbit_memory_notEquivalent_of_lt
          patchable
          initial
          second
      causallySeparated :=
        causalOrbit_not_causallyEquivalent_of_lt
          patchable
          initial
          second }

/--
Canonical recurrence witness for every patchable context: the challenge from
`S_0` is visibly repeated at `S_1` and `S_2`, whose memories are causally
separated.
-/
def canonicalVisibleRecurrenceWithCausalNonReturn
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    VisibleRecurrenceWithCausalSeparation
      (causalOrbit patchable initial 1)
      (causalOrbit patchable initial 2) :=
  genericVisibleRecurrenceWithCausalNonReturn
    patchable
    initial
    (Nat.zero_lt_succ 0)
    (Nat.lt_succ_self 1)

/-! ## Closed generic theorem package -/

/--
All causal and visible consequences of intrinsic patching, uniformly over a
patchable syntax and without any additional freshness or non-return premise.
-/
structure GenericVisibleCausalNonRecurrenceTheorem
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    Type (max u v) where
  memorySound :
    {current : patchable.context.Predicate} ->
      (memory : CausalMemory patchable initial current) ->
      {sentence : patchable.context.Sentence} ->
      CausalMemory.Remembers patchable initial memory sentence ->
        CorrectAt patchable current sentence
  currentGapAbsent :
    (state : CausalState patchable initial) ->
      CausalMemory.Remembers
          patchable
          initial
          state.memory
          (patchable.diagonalSentence state.current) ->
        False
  oldGapsAccumulated :
    {k n : Nat} ->
      k < n ->
        CausalMemory.Remembers
          patchable
          initial
          (causalOrbit patchable initial n).memory
          (genericOrbitIndex patchable initial k)
  memorySeparated :
    {n m : Nat} ->
      n < m ->
        MemoryEquivalent
            (causalOrbit patchable initial n)
            (causalOrbit patchable initial m) ->
          False
  noCausalReturn :
    {n m : Nat} ->
      n < m ->
        CausallyEquivalent
            (causalOrbit patchable initial n)
            (causalOrbit patchable initial m) ->
          False
  noPositivePeriod :
    (n period : Nat) ->
      0 < period ->
        CausallyEquivalent
            (causalOrbit patchable initial n)
            (causalOrbit patchable initial (n + period)) ->
          False
  visibleRecurrence :
    {k n m : Nat} ->
      k < n ->
      n < m ->
        VisibleRecurrenceWithCausalSeparation
          (causalOrbit patchable initial n)
          (causalOrbit patchable initial m)
  canonicalRecurrence :
    VisibleRecurrenceWithCausalSeparation
      (causalOrbit patchable initial 1)
      (causalOrbit patchable initial 2)
  everyCandidateIncomplete :
    (n : Nat) ->
      TarskiTruthDefinition
          (patchable.truthAt (causalOrbit patchable initial n).current)
          patchable.context.models ->
        False

/-- Canonical generic visible/causal non-recurrence theorem. -/
def genericVisibleCausalNonRecurrenceTheorem
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    GenericVisibleCausalNonRecurrenceTheorem patchable initial where
  memorySound := CausalMemory.correctAt_of_remembers patchable initial
  currentGapAbsent := CausalState.currentGap_not_remembered patchable initial
  oldGapsAccumulated := causalOrbit_remembers_of_lt patchable initial
  memorySeparated := causalOrbit_memory_notEquivalent_of_lt patchable initial
  noCausalReturn :=
    causalOrbit_not_causallyEquivalent_of_lt patchable initial
  noPositivePeriod := causalOrbit_noPositivePeriod patchable initial
  visibleRecurrence :=
    genericVisibleRecurrenceWithCausalNonReturn patchable initial
  canonicalRecurrence :=
    canonicalVisibleRecurrenceWithCausalNonReturn patchable initial
  everyCandidateIncomplete := by
    intro n definition
    exact
      patchable.truthAt_notGloballyCorrect
        (causalOrbit patchable initial n).current
        definition

end PatchableArithmeticTarskiContext
end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.AuthorizedVisibleObservation
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.VisibleSameAt
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.visibleSameAt_of_remembered
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.VisibleRecurrenceWithCausalSeparation
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.genericVisibleRecurrenceWithCausalNonReturn
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.canonicalVisibleRecurrenceWithCausalNonReturn
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.GenericVisibleCausalNonRecurrenceTheorem
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.genericVisibleCausalNonRecurrenceTheorem
/- AXIOM_AUDIT_END -/
