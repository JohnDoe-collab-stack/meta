import Meta.Core.CausalAdditive

/-!
# Final identification of causal words with `Nat`

The causal-word algebra is already complete before this file is imported.
This module introduces `Nat` only as a final comparison object and proves that
the comparison preserves zero, successor, and addition in both directions.
-/

namespace Meta
namespace CausalAdditive
namespace CausalWord

/-! ## Comparison maps -/

/-- A fully constructive two-sided equivalence, kept local to the final
comparison layer so the causal-word core remains import-free. -/
structure ConstructiveEquivalence (Source Target : Type) where
  toFun : Source -> Target
  invFun : Target -> Source
  left_inv : (source : Source) -> invFun (toFun source) = source
  right_inv : (target : Target) -> toFun (invFun target) = target

/-- Read a causal word as a standard natural number. -/
def toNat : CausalWord -> Nat
  | CausalWord.zero => 0
  | CausalWord.succ previous => Nat.succ (toNat previous)

/-- Rebuild a causal word from a standard natural number. -/
def ofNat : Nat -> CausalWord
  | 0 => CausalWord.zero
  | Nat.succ previous => CausalWord.succ (ofNat previous)

/-- Rebuilding after reading returns the original causal word. -/
theorem ofNat_toNat (word : CausalWord) :
    ofNat (toNat word) = word := by
  induction word with
  | zero => rfl
  | succ previous inductionHypothesis =>
      exact congrArg CausalWord.succ inductionHypothesis

/-- Reading after rebuilding returns the original natural number. -/
theorem toNat_ofNat (number : Nat) :
    toNat (ofNat number) = number := by
  induction number with
  | zero => rfl
  | succ previous inductionHypothesis =>
      exact congrArg Nat.succ inductionHypothesis

/-! ## Additive compatibility -/

/-- Reading causal addition gives standard natural addition. -/
theorem toNat_add (left right : CausalWord) :
    toNat (add left right) = toNat left + toNat right := by
  induction right with
  | zero =>
      exact (Nat.add_zero (toNat left)).symm
  | succ previous inductionHypothesis =>
      calc
        toNat (add left (CausalWord.succ previous)) =
            Nat.succ (toNat (add left previous)) := rfl
        _ = Nat.succ (toNat left + toNat previous) :=
          congrArg Nat.succ inductionHypothesis
        _ = toNat left + Nat.succ (toNat previous) :=
          (Nat.add_succ (toNat left) (toNat previous)).symm

/-- Rebuilding standard addition gives causal addition. -/
theorem ofNat_add (left right : Nat) :
    ofNat (left + right) = add (ofNat left) (ofNat right) := by
  induction right with
  | zero =>
      exact congrArg ofNat (Nat.add_zero left)
  | succ previous inductionHypothesis =>
      calc
        ofNat (left + Nat.succ previous) =
            ofNat (Nat.succ (left + previous)) :=
          congrArg ofNat (Nat.add_succ left previous)
        _ = CausalWord.succ (ofNat (left + previous)) := rfl
        _ = CausalWord.succ (add (ofNat left) (ofNat previous)) :=
          congrArg CausalWord.succ inductionHypothesis
        _ = add (ofNat left) (ofNat (Nat.succ previous)) := rfl

/-- The final constructive equivalence between causal words and `Nat`. -/
def equivalence : ConstructiveEquivalence CausalWord Nat where
  toFun := toNat
  invFun := ofNat
  left_inv := ofNat_toNat
  right_inv := toNat_ofNat

end CausalWord
end CausalAdditive
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.CausalAdditive.CausalWord.equivalence
#print axioms Meta.CausalAdditive.CausalWord.toNat_add
#print axioms Meta.CausalAdditive.CausalWord.ofNat_add
/- AXIOM_AUDIT_END -/
