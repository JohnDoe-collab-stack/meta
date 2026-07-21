import Meta.Core.CausalTotality

/-!
# Final identification of causal words with `Nat`

The causal-word algebra is already complete before this file is imported.
This module introduces `Nat` only as a final comparison object and proves that
the comparison preserves zero, successor, and addition in both directions.
-/

namespace Meta
namespace CausalAdditive
namespace CausalWord

universe u v

/-! ## Comparison maps -/

/-- A fully constructive two-sided equivalence, kept local to the final
comparison layer so the causal-word core remains import-free. -/
structure ConstructiveEquivalence
    (Source : Type u)
    (Target : Type v) :
    Type (max u v) where
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

/-! ## Final natural indexing of historical gaps -/

namespace AccumulatingCausalSystem

variable {State : Type u}
variable {Gap : Type v}

/-- Realize a standard natural number as a positive historical gap only after
the causal historical totality has already been constructed. -/
def naturalHistoricalGap
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    (number : Nat) :
    system.HistoricalGap initial :=
  system.realizedHistoricalGap initial (CausalWord.ofNat number)

/-- Standard naturals inject into the already realized historical-gap
totality. -/
theorem naturalHistoricalGap_injective
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    {left right : Nat}
    (same :
      system.naturalHistoricalGap initial left =
        system.naturalHistoricalGap initial right) :
    left = right := by
  have sameWord :
      CausalWord.ofNat left = CausalWord.ofNat right :=
    system.realizedHistoricalGap_injective initial same
  calc
    left = CausalWord.toNat (CausalWord.ofNat left) :=
      (CausalWord.toNat_ofNat left).symm
    _ = CausalWord.toNat (CausalWord.ofNat right) :=
      congrArg CausalWord.toNat sameWord
    _ = right := CausalWord.toNat_ofNat right

end AccumulatingCausalSystem

/-! ## Canonical natural coordinate of the realized causal object -/

namespace AccumulatingCausalSystem.RealizedCausalNat

variable {State : Type u}
variable {Gap : Type v}
variable {system : AccumulatingCausalSystem State Gap}
variable {initial : State}

/-- Read the canonical additive natural coordinate carried by the causal word
of a realized object. -/
def naturalCoordinate
    (realizedNat : RealizedCausalNat system initial) :
    Nat :=
  CausalWord.toNat realizedNat.word

/-- Rebuild the canonical realized causal object carrying a natural value. -/
def naturalEmbedding
    (number : Nat) :
    RealizedCausalNat system initial :=
  embed (CausalWord.ofNat number)

/-- The canonical natural coordinate preserves realized zero. -/
theorem naturalCoordinate_zero :
    naturalCoordinate (zero : RealizedCausalNat system initial) = 0 :=
  rfl

/-- The canonical natural coordinate preserves realized successor. -/
theorem naturalCoordinate_succ
    (realizedNat : RealizedCausalNat system initial) :
    naturalCoordinate (succ realizedNat) =
      Nat.succ (naturalCoordinate realizedNat) :=
  rfl

/-- The canonical natural coordinate preserves realized addition. -/
theorem naturalCoordinate_add
    (left right : RealizedCausalNat system initial) :
    naturalCoordinate (add left right) =
      naturalCoordinate left + naturalCoordinate right :=
  CausalWord.toNat_add left.word right.word

/-- Reading the coordinate of a canonically embedded natural returns it. -/
theorem naturalCoordinate_naturalEmbedding
    (number : Nat) :
    naturalCoordinate
        (naturalEmbedding number : RealizedCausalNat system initial) =
      number :=
  CausalWord.toNat_ofNat number

/-- Re-embedding the natural coordinate recovers the complete realized
object, so the coordinate identifies no two realized orbit elements. -/
theorem naturalEmbedding_naturalCoordinate
    (realizedNat : RealizedCausalNat system initial) :
    naturalEmbedding (naturalCoordinate realizedNat) = realizedNat := by
  calc
    naturalEmbedding (naturalCoordinate realizedNat) =
        embed (CausalWord.ofNat (CausalWord.toNat realizedNat.word)) := rfl
    _ = embed realizedNat.word :=
      congrArg embed (CausalWord.ofNat_toNat realizedNat.word)
    _ = realizedNat := embed_word realizedNat

/-- The canonical natural coordinate is a constructive equivalence on the
realized additive carrier. -/
def naturalEquivalence :
    CausalWord.ConstructiveEquivalence
      (RealizedCausalNat system initial)
      Nat where
  toFun := naturalCoordinate
  invFun := naturalEmbedding
  left_inv := naturalEmbedding_naturalCoordinate
  right_inv := naturalCoordinate_naturalEmbedding

end AccumulatingCausalSystem.RealizedCausalNat
end CausalAdditive
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.CausalAdditive.CausalWord.equivalence
#print axioms Meta.CausalAdditive.CausalWord.toNat_add
#print axioms Meta.CausalAdditive.CausalWord.ofNat_add
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.naturalHistoricalGap_injective
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.RealizedCausalNat.naturalCoordinate
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.RealizedCausalNat.naturalCoordinate_add
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.RealizedCausalNat.naturalEquivalence
/- AXIOM_AUDIT_END -/
