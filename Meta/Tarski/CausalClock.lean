import Meta.Core.CausalFinite
import Meta.Tarski.CausalAccumulatingSystem

/-!
# Intrinsic Tarski clock and exact positive memory without `Nat`

The indexed causal memory already stores the complete chain of repair events.
This module reads its causal word structurally, defines positive positions in
that memory, proves that those positions represent exactly the extensional
`Remembers` predicate, and identifies their finite type with the causal time.

The canonical Tarski evaluation is a section of the intrinsic clock.  Thus
the clock is decoded from the complete state; it is not an added counter.
-/

namespace Meta
namespace ClosedStabilityTheorem
namespace PatchableArithmeticTarskiContext

universe u v

namespace CausalMemory

/-! ## Structural causal time -/

/-- The exact causal word carried by the inductive shape of a memory. -/
def causalTime
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    {current : patchable.context.Predicate} ->
      CausalMemory patchable initial current ->
      CausalAdditive.CausalWord
  | _, CausalMemory.root =>
      CausalAdditive.CausalWord.zero
  | _, CausalMemory.extend previous _ =>
      CausalAdditive.CausalWord.succ
        (causalTime patchable initial previous)

/-! ## Positive memory positions -/

/-- Universe-polymorphic empty type used by the positive position family. -/
inductive PositionEmpty.{w} : Type w

/-- A positive position in a causal memory.  The newest event is `none` and
an inherited position is `some previousPosition`. -/
def Position
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    {current : patchable.context.Predicate} ->
      CausalMemory patchable initial current ->
      Type (max u v)
  | _, CausalMemory.root => PositionEmpty.{max u v}
  | _, CausalMemory.extend previous _ =>
      Option (Position patchable initial previous)

/-- The diagonal sentence stored at a positive memory position. -/
def sentenceAt
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    {current : patchable.context.Predicate} ->
    (memory : CausalMemory patchable initial current) ->
      Position patchable initial memory ->
        patchable.context.Sentence
  | _, CausalMemory.root => fun position => nomatch position
  | _, CausalMemory.extend previous event => fun position =>
      match position with
      | none => event.diagonalSentence
      | some inherited =>
          sentenceAt patchable initial previous inherited

/-- Every positive position supplies extensional remembrance. -/
theorem position_remembered
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    {current : patchable.context.Predicate}
    (memory : CausalMemory patchable initial current)
    (position : Position patchable initial memory) :
    Remembers
      patchable
      initial
      memory
      (sentenceAt patchable initial memory position) := by
  induction memory with
  | root => nomatch position
  | extend previous event inductionHypothesis =>
      change Option (Position patchable initial previous) at position
      cases position with
      | none => exact Or.inl rfl
      | some inherited =>
          exact Or.inr (inductionHypothesis inherited)

/-- Every extensionally remembered sentence is represented by a positive
position.  The result remains in `Prop`, so no witness is extracted by choice. -/
theorem remembers_has_position
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    {current : patchable.context.Predicate}
    (memory : CausalMemory patchable initial current)
    (sentence : patchable.context.Sentence)
    (remembered : Remembers patchable initial memory sentence) :
    Exists fun position : Position patchable initial memory =>
      sentenceAt patchable initial memory position = sentence := by
  induction memory with
  | root => exact remembered.elim
  | extend previous event inductionHypothesis =>
      cases remembered with
      | inl newest =>
          exact Exists.intro none newest.symm
      | inr inherited =>
          cases inductionHypothesis inherited with
          | intro position same =>
              exact Exists.intro (some position) same

/-- Positive positions and extensional remembrance have exactly the same
sentences. -/
theorem remembers_iff_position
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    {current : patchable.context.Predicate}
    (memory : CausalMemory patchable initial current)
    (sentence : patchable.context.Sentence) :
    Remembers patchable initial memory sentence ↔
      Exists fun position : Position patchable initial memory =>
        sentenceAt patchable initial memory position = sentence := by
  constructor
  · exact remembers_has_position patchable initial memory sentence
  · intro represented
    cases represented with
    | intro position same =>
        rw [← same]
        exact position_remembered patchable initial memory position

/-- Distinct positive positions store distinct diagonal sentences.  The
newest/oldest collision is refuted by the intrinsic Tarski mismatch. -/
theorem sentenceAt_injective
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    {current : patchable.context.Predicate}
    (memory : CausalMemory patchable initial current)
    {left right : Position patchable initial memory}
    (same :
      sentenceAt patchable initial memory left =
        sentenceAt patchable initial memory right) :
    left = right := by
  induction memory with
  | root => nomatch left
  | @extend previousCurrent previous event inductionHypothesis =>
      change Option (Position patchable initial previous) at left right
      cases left with
      | none =>
          cases right with
          | none => rfl
          | some inherited =>
              exfalso
              apply current_not_remembered patchable initial previous
              rw [← event.diagonalSentence_eq]
              change
                event.diagonalSentence =
                  sentenceAt
                    patchable initial previous inherited at same
              rw [same]
              exact
                position_remembered
                  patchable initial previous inherited
      | some leftInherited =>
          cases right with
          | none =>
              exfalso
              apply current_not_remembered patchable initial previous
              rw [← event.diagonalSentence_eq]
              change
                sentenceAt
                    patchable initial previous leftInherited =
                  event.diagonalSentence at same
              rw [← same]
              exact
                position_remembered
                  patchable initial previous leftInherited
          | some rightInherited =>
              exact congrArg Option.some (inductionHypothesis same)

/-! ## Exact intrinsic cardinality -/

/-- Read a positive memory position as a causal finite position. -/
def positionToCausalFin
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    {current : patchable.context.Predicate} ->
    (memory : CausalMemory patchable initial current) ->
      Position patchable initial memory ->
        CausalAdditive.CausalFin
          (causalTime patchable initial memory)
  | _, CausalMemory.root => fun position => nomatch position
  | _, CausalMemory.extend previous _ => fun position =>
      match position with
      | none => none
      | some inherited =>
          some
            (positionToCausalFin
              patchable initial previous inherited)

/-- Rebuild a positive memory position from its causal finite coordinate. -/
def positionOfCausalFin
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    {current : patchable.context.Predicate} ->
    (memory : CausalMemory patchable initial current) ->
      CausalAdditive.CausalFin
          (causalTime patchable initial memory) ->
        Position patchable initial memory
  | _, CausalMemory.root, position => nomatch position
  | _, CausalMemory.extend previous _, position =>
      match position with
      | none => none
      | some inherited =>
          some
            (positionOfCausalFin
              patchable initial previous inherited)

/-- Rebuilding a position after reading it returns that position. -/
theorem positionOfCausalFin_positionToCausalFin
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    {current : patchable.context.Predicate}
    (memory : CausalMemory patchable initial current)
    (position : Position patchable initial memory) :
    positionOfCausalFin
        patchable initial memory
        (positionToCausalFin patchable initial memory position) =
      position := by
  induction memory with
  | root => nomatch position
  | extend previous event inductionHypothesis =>
      change Option (Position patchable initial previous) at position
      cases position with
      | none => rfl
      | some inherited =>
          exact congrArg Option.some (inductionHypothesis inherited)

/-- Reading a rebuilt causal finite position returns its coordinate. -/
theorem positionToCausalFin_positionOfCausalFin
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    {current : patchable.context.Predicate}
    (memory : CausalMemory patchable initial current)
    (position :
      CausalAdditive.CausalFin
        (causalTime patchable initial memory)) :
    positionToCausalFin
        patchable initial memory
        (positionOfCausalFin patchable initial memory position) =
      position := by
  induction memory with
  | root => nomatch position
  | extend previous event inductionHypothesis =>
      cases position with
      | none => rfl
      | some inherited =>
          exact congrArg Option.some (inductionHypothesis inherited)

/-- The positions of any coherent Tarski memory have exactly its intrinsic
causal finite cardinality. -/
def positionEquivalence
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    {current : patchable.context.Predicate}
    (memory : CausalMemory patchable initial current) :
    CausalAdditive.CausalWord.ConstructiveEquivalence
      (Position patchable initial memory)
      (CausalAdditive.CausalFin
        (causalTime patchable initial memory)) where
  toFun := positionToCausalFin patchable initial memory
  invFun := positionOfCausalFin patchable initial memory
  left_inv :=
    positionOfCausalFin_positionToCausalFin
      patchable initial memory
  right_inv :=
    positionToCausalFin_positionOfCausalFin
      patchable initial memory

end CausalMemory

namespace CausalState

/-! ## The state decodes its own causal time -/

/-- The intrinsic causal time decoded from a complete state's memory. -/
def intrinsicTime
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    (state : CausalState patchable initial) :
    CausalAdditive.CausalWord :=
  CausalMemory.causalTime patchable initial state.memory

/-- The positive positions carried by a complete causal state. -/
def MemoryPosition
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    (state : CausalState patchable initial) :
    Type (max u v) :=
  CausalMemory.Position patchable initial state.memory

/-- Advancing a state advances its decoded causal time exactly once. -/
theorem intrinsicTime_advance
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    (state : CausalState patchable initial) :
    intrinsicTime
        patchable initial (CausalState.advance patchable initial state) =
      CausalAdditive.CausalWord.succ
        (intrinsicTime patchable initial state) :=
  rfl

end CausalState

/-! ## Retraction of canonical evaluation -/

/-- The intrinsic initial state has empty causal time. -/
theorem intrinsicTime_initialCausalState
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    CausalState.intrinsicTime
        patchable initial (initialCausalState patchable initial) =
      CausalAdditive.CausalWord.zero :=
  rfl

/-- Canonical evaluation is a section of the intrinsic clock. -/
theorem intrinsicTime_eval
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    (word : CausalAdditive.CausalWord) :
    CausalState.intrinsicTime
        patchable
        initial
        ((tarskiAccumulatingCausalSystem patchable initial).eval
          (initialCausalState patchable initial)
          word) =
      word := by
  induction word with
  | zero => rfl
  | succ previous inductionHypothesis =>
      exact
        congrArg
          CausalAdditive.CausalWord.succ
          inductionHypothesis

/-- The positive positions of a realized stage have exactly the causal finite
cardinality of the word that realizes it. -/
def stagePositionEquivalence
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    (word : CausalAdditive.CausalWord) :
    let state :=
      (tarskiAccumulatingCausalSystem patchable initial).eval
        (initialCausalState patchable initial)
        word
    CausalAdditive.CausalWord.ConstructiveEquivalence
      (CausalState.MemoryPosition patchable initial state)
      (CausalAdditive.CausalFin word) :=
  CausalAdditive.CausalWord.ConstructiveEquivalence.trans
    (CausalMemory.positionEquivalence
      patchable
      initial
      ((tarskiAccumulatingCausalSystem patchable initial).eval
        (initialCausalState patchable initial)
        word).memory)
    (CausalAdditive.CausalFin.castEquivalence
      (intrinsicTime_eval patchable initial word))

/-! ## Closed theorem package -/

/-- Intrinsic clock, exact positive memory, exact causal cardinality, and
causal order for every patchable Tarski context, before comparison with
standard naturals. -/
structure TarskiIntrinsicClockTheorem
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    Type (max u v) where
  clockRetractsEvaluation :
    (word : CausalAdditive.CausalWord) ->
      CausalState.intrinsicTime
          patchable
          initial
          ((tarskiAccumulatingCausalSystem patchable initial).eval
            (initialCausalState patchable initial)
            word) =
        word
  memoryIsExactlyPositioned :
    {current : patchable.context.Predicate} ->
    (memory : CausalMemory patchable initial current) ->
    (sentence : patchable.context.Sentence) ->
      CausalMemory.Remembers patchable initial memory sentence ↔
        Exists fun position :
            CausalMemory.Position patchable initial memory =>
          CausalMemory.sentenceAt
              patchable initial memory position =
            sentence
  positionsAreSentenceFaithful :
    {current : patchable.context.Predicate} ->
    (memory : CausalMemory patchable initial current) ->
    {left right : CausalMemory.Position patchable initial memory} ->
      CausalMemory.sentenceAt patchable initial memory left =
          CausalMemory.sentenceAt patchable initial memory right ->
        left = right
  memoryHasExactCausalCardinality :
    {current : patchable.context.Predicate} ->
    (memory : CausalMemory patchable initial current) ->
      CausalAdditive.CausalWord.ConstructiveEquivalence
        (CausalMemory.Position patchable initial memory)
        (CausalAdditive.CausalFin
          (CausalMemory.causalTime patchable initial memory))
  stageHasExactCausalCardinality :
    (word : CausalAdditive.CausalWord) ->
      let state :=
        (tarskiAccumulatingCausalSystem patchable initial).eval
          (initialCausalState patchable initial)
          word
      CausalAdditive.CausalWord.ConstructiveEquivalence
        (CausalState.MemoryPosition patchable initial state)
        (CausalAdditive.CausalFin word)
  reachabilityIsPrecedence :
    (source target : CausalAdditive.CausalWord) ->
      (tarskiAccumulatingCausalSystem patchable initial).Reachable
          ((tarskiAccumulatingCausalSystem patchable initial).eval
            (initialCausalState patchable initial)
            source)
          ((tarskiAccumulatingCausalSystem patchable initial).eval
            (initialCausalState patchable initial)
            target) ↔
        CausalAdditive.CausalWord.Precedes source target

/-- Canonical closed intrinsic-clock theorem. -/
def tarskiIntrinsicClockTheorem
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    TarskiIntrinsicClockTheorem patchable initial where
  clockRetractsEvaluation := intrinsicTime_eval patchable initial
  memoryIsExactlyPositioned :=
    CausalMemory.remembers_iff_position patchable initial
  positionsAreSentenceFaithful :=
    CausalMemory.sentenceAt_injective patchable initial
  memoryHasExactCausalCardinality :=
    CausalMemory.positionEquivalence patchable initial
  stageHasExactCausalCardinality :=
    stagePositionEquivalence patchable initial
  reachabilityIsPrecedence :=
    (tarskiAccumulatingCausalSystem patchable initial)
      |>.orbitReachable_iff_precedes
        (initialCausalState patchable initial)

end PatchableArithmeticTarskiContext
end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.CausalMemory.remembers_iff_position
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.CausalMemory.sentenceAt_injective
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.CausalMemory.positionEquivalence
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.intrinsicTime_eval
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.stagePositionEquivalence
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.tarskiIntrinsicClockTheorem
/- AXIOM_AUDIT_END -/
