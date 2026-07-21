import Meta.Core.CausalAdditiveNat
import Meta.Tarski.CausalClock

/-!
# Final comparison of exact causal memory with `Fin` and `Nat`

The intrinsic clock, memory positions, and causal finite cardinality are
already complete before this module.  Standard `Nat` and `Fin` are introduced
only as final coordinates.  Every realized word has exactly `toNat word`
positive memory positions, and the classical orbit at `n` has exactly `n`.
-/

namespace Meta
namespace CausalAdditive

namespace CausalFin

/-! ## Constructive comparison with `Fin` -/

/-- Read a causal finite position as a standard finite ordinal. -/
def toFin :
    (word : CausalWord) ->
      CausalFin word ->
        Fin (CausalWord.toNat word)
  | CausalWord.zero, position => nomatch position
  | CausalWord.succ previous, none =>
      ⟨0, Nat.succ_pos (CausalWord.toNat previous)⟩
  | CausalWord.succ previous, some position =>
      Fin.succ (toFin previous position)

/-- Rebuild a causal finite position from a standard finite ordinal. -/
def ofFin :
    (word : CausalWord) ->
      Fin (CausalWord.toNat word) ->
        CausalFin word
  | CausalWord.zero, position => Fin.elim0 position
  | CausalWord.succ _, ⟨0, _⟩ => none
  | CausalWord.succ previous, ⟨Nat.succ value, bounded⟩ =>
      some
        (ofFin previous
          ⟨value, Nat.lt_of_succ_lt_succ bounded⟩)

/-- Rebuilding after reading a causal finite position is identity. -/
theorem ofFin_toFin
    (word : CausalWord)
    (position : CausalFin word) :
    ofFin word (toFin word position) = position := by
  induction word with
  | zero => nomatch position
  | succ previous inductionHypothesis =>
      cases position with
      | none => rfl
      | some inherited =>
          exact congrArg Option.some (inductionHypothesis inherited)

/-- Reading after rebuilding a standard finite ordinal is identity. -/
theorem toFin_ofFin
    (word : CausalWord)
    (position : Fin (CausalWord.toNat word)) :
    toFin word (ofFin word position) = position := by
  induction word with
  | zero => exact Fin.elim0 position
  | succ previous inductionHypothesis =>
      cases position with
      | mk value bounded =>
          cases value with
          | zero =>
              apply Fin.eq_of_val_eq
              rfl
          | succ value =>
              have previousBound :
                  value < CausalWord.toNat previous :=
                Nat.lt_of_succ_lt_succ bounded
              have previousSame :=
                inductionHypothesis ⟨value, previousBound⟩
              apply Fin.eq_of_val_eq
              exact
                congrArg Nat.succ
                  (Fin.val_eq_of_eq previousSame)

/-- Final constructive equivalence between causal finite positions and the
standard finite ordinal of the same causal size. -/
def finEquivalence
    (word : CausalWord) :
    CausalWord.ConstructiveEquivalence
      (CausalFin word)
      (Fin (CausalWord.toNat word)) where
  toFun := toFin word
  invFun := ofFin word
  left_inv := ofFin_toFin word
  right_inv := toFin_ofFin word

end CausalFin

namespace Fin

/-- Reindex standard finite ordinals along equality of their sizes. -/
def castEquivalence
    {left right : Nat}
    (same : left = right) :
    CausalWord.ConstructiveEquivalence
      (Fin left)
      (Fin right) := by
  cases same
  exact CausalWord.ConstructiveEquivalence.refl (Fin left)

end Fin
end CausalAdditive

namespace ClosedStabilityTheorem
namespace PatchableArithmeticTarskiContext

universe u v

/-! ## Exact standard cardinality of realized memory -/

/-- The positive memory positions of a realized causal word are exactly the
standard finite ordinal indexed by its final natural coordinate. -/
def stagePositionFinEquivalence
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    (word : CausalAdditive.CausalWord) :
    let state :=
      (tarskiAccumulatingCausalSystem patchable initial).eval
        (initialCausalState patchable initial)
        word
    CausalAdditive.CausalWord.ConstructiveEquivalence
      (CausalState.MemoryPosition patchable initial state)
      (Fin (CausalAdditive.CausalWord.toNat word)) :=
  CausalAdditive.CausalWord.ConstructiveEquivalence.trans
    (stagePositionEquivalence patchable initial word)
    (CausalAdditive.CausalFin.finEquivalence word)

/-- The standard natural time decoded from the complete state's positive
memory, introduced only in this final comparison layer. -/
def CausalState.intrinsicNaturalTime
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    (state : CausalState patchable initial) :
    Nat :=
  CausalAdditive.CausalWord.toNat
    (CausalState.intrinsicTime patchable initial state)

/-- The natural clock of a realized causal word is exactly its final natural
coordinate. -/
theorem intrinsicNaturalTime_eval
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    (word : CausalAdditive.CausalWord) :
    CausalState.intrinsicNaturalTime
        patchable
        initial
        ((tarskiAccumulatingCausalSystem patchable initial).eval
          (initialCausalState patchable initial)
          word) =
      CausalAdditive.CausalWord.toNat word :=
  congrArg
    CausalAdditive.CausalWord.toNat
    (intrinsicTime_eval patchable initial word)

/-- The intrinsic causal word of the classical orbit at `n` is `ofNat n`. -/
theorem intrinsicTime_causalOrbit
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    (number : Nat) :
    CausalState.intrinsicTime
        patchable initial (causalOrbit patchable initial number) =
      CausalAdditive.CausalWord.ofNat number := by
  induction number with
  | zero => rfl
  | succ previous inductionHypothesis =>
      exact
        congrArg
          CausalAdditive.CausalWord.succ
          inductionHypothesis

/-- The complete classical orbit state decodes its own exact natural time. -/
theorem intrinsicNaturalTime_causalOrbit
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    (number : Nat) :
    CausalState.intrinsicNaturalTime
        patchable initial (causalOrbit patchable initial number) =
      number := by
  calc
    CausalState.intrinsicNaturalTime
          patchable initial (causalOrbit patchable initial number) =
        CausalAdditive.CausalWord.toNat
          (CausalAdditive.CausalWord.ofNat number) :=
      congrArg
        CausalAdditive.CausalWord.toNat
        (intrinsicTime_causalOrbit patchable initial number)
    _ = number := CausalAdditive.CausalWord.toNat_ofNat number

/-- The classical orbit memory at `n` has exactly `Fin n` positive positions. -/
def causalOrbitPositionFinEquivalence
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate)
    (number : Nat) :
    CausalAdditive.CausalWord.ConstructiveEquivalence
      (CausalState.MemoryPosition
        patchable initial (causalOrbit patchable initial number))
      (Fin number) :=
  CausalAdditive.CausalWord.ConstructiveEquivalence.trans
    (CausalMemory.positionEquivalence
      patchable initial (causalOrbit patchable initial number).memory)
    (CausalAdditive.CausalWord.ConstructiveEquivalence.trans
      (CausalAdditive.CausalFin.finEquivalence
        (CausalState.intrinsicTime
          patchable initial (causalOrbit patchable initial number)))
      (CausalAdditive.Fin.castEquivalence
        (intrinsicNaturalTime_causalOrbit
          patchable initial number)))

/-! ## Closed final theorem package -/

/-- Exact finite cardinality of intrinsic Tarski memory after the final
comparison with `Nat` and `Fin`. -/
structure TarskiExactFiniteMemoryTheorem
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    Type (max u v) where
  intrinsicClock : TarskiIntrinsicClockTheorem patchable initial
  wordStageExact :
    (word : CausalAdditive.CausalWord) ->
      let state :=
        (tarskiAccumulatingCausalSystem patchable initial).eval
          (initialCausalState patchable initial)
          word
      CausalAdditive.CausalWord.ConstructiveEquivalence
        (CausalState.MemoryPosition patchable initial state)
        (Fin (CausalAdditive.CausalWord.toNat word))
  orbitStageExact :
    (number : Nat) ->
      CausalAdditive.CausalWord.ConstructiveEquivalence
        (CausalState.MemoryPosition
          patchable initial (causalOrbit patchable initial number))
        (Fin number)
  orbitDecodesTime :
    (number : Nat) ->
      CausalState.intrinsicNaturalTime
          patchable initial (causalOrbit patchable initial number) =
        number

/-- Canonical exact finite-memory theorem. -/
def tarskiExactFiniteMemoryTheorem
    (patchable : PatchableArithmeticTarskiContext.{u, v})
    (initial : patchable.context.Predicate) :
    TarskiExactFiniteMemoryTheorem patchable initial where
  intrinsicClock := tarskiIntrinsicClockTheorem patchable initial
  wordStageExact := stagePositionFinEquivalence patchable initial
  orbitStageExact := causalOrbitPositionFinEquivalence patchable initial
  orbitDecodesTime := intrinsicNaturalTime_causalOrbit patchable initial

end PatchableArithmeticTarskiContext
end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.CausalAdditive.CausalFin.finEquivalence
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.intrinsicNaturalTime_eval
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.intrinsicNaturalTime_causalOrbit
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.causalOrbitPositionFinEquivalence
#print axioms Meta.ClosedStabilityTheorem.PatchableArithmeticTarskiContext.tarskiExactFiniteMemoryTheorem
/- AXIOM_AUDIT_END -/
