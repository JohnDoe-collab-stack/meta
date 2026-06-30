import Meta.Arithmetic.Parity

/-!
# Enriched Nat diagonal order

This file exposes the pure enriched-Nat order induced by the positive
diagonal gap.

Definitionally, the comparison is introduced through the positive diagonal gap
carried by one enriched Nat index.  Extensionally, on bare Nat indices, this
order calibrates to the usual Nat order.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Index gap induced by enriched Nat diagonalization -/

/-- The positive diagonal gap carried by one enriched Nat index. -/
def natEnrichedDiagonalGap
    (index : Nat) :
    Nat :=
  natEnrichedParityFibrewiseStructuralPeak index

/-- The enriched diagonal gap is the enriched Nat fibrewise structural peak. -/
theorem natEnrichedDiagonalGap_eq_fibrewiseStructuralPeak
    (index : Nat) :
    natEnrichedDiagonalGap index =
      natEnrichedParityFibrewiseStructuralPeak index :=
  rfl

/-- The enriched diagonal gap is the maximal relaxed divergence at the index. -/
theorem natEnrichedDiagonalGap_eq_maximalRelaxedDivergence
    (index : Nat) :
    natEnrichedDiagonalGap index =
      natEnrichedParityMaximalRelaxedDivergence index :=
  natEnrichedParityFibrewiseStructuralPeak_eq_maximalDivergence index

/-- The enriched diagonal gap has the countdown-consumable form `(index + index) + 2`. -/
theorem natEnrichedDiagonalGap_eq_double_add_two
    (index : Nat) :
    natEnrichedDiagonalGap index = (index + index) + 2 :=
  natEnrichedParityFibrewiseStructuralPeak_eq_double_add_two index

/-- The enriched diagonal gap is strictly positive at every index. -/
theorem natEnrichedDiagonalGap_pos
    (index : Nat) :
    0 < natEnrichedDiagonalGap index :=
  natEnrichedParityFibrewiseStructuralPeak_pos index

/-! ## Index order induced by the diagonal gap -/

/--
Diagonal-gap order on enriched Nat indices.

`left` is below `right` when the positive diagonal gap carried by `left` is
below the positive diagonal gap carried by `right`.
-/
def NatEnrichedDiagonalGapOrder
    (left right : Nat) :
    Prop :=
  natEnrichedDiagonalGap left <= natEnrichedDiagonalGap right

/-- The enriched diagonal-gap order is reflexive. -/
theorem natEnrichedDiagonalGapOrder_refl
    (index : Nat) :
    NatEnrichedDiagonalGapOrder index index :=
  Nat.le_refl (natEnrichedDiagonalGap index)

/-- The enriched diagonal-gap order is transitive. -/
theorem natEnrichedDiagonalGapOrder_trans
    {left middle right : Nat}
    (left_middle : NatEnrichedDiagonalGapOrder left middle)
    (middle_right : NatEnrichedDiagonalGapOrder middle right) :
    NatEnrichedDiagonalGapOrder left right :=
  Nat.le_trans left_middle middle_right

/--
Cancellation for doubled natural numbers, proved directly to avoid importing
non-constructive cancellation lemmas into the audit path.
-/
theorem nat_add_self_eq_add_self_cancel :
    forall left right : Nat,
      left + left = right + right ->
        left = right
  | 0, 0, _ => rfl
  | 0, Nat.succ right, sameDouble => by
      rw [Nat.zero_add] at sameDouble
      cases sameDouble
  | Nat.succ left, 0, sameDouble => by
      rw [Nat.zero_add] at sameDouble
      cases sameDouble
  | Nat.succ left, Nat.succ right, sameDouble => by
      rw [Nat.succ_add, Nat.add_succ, Nat.succ_add, Nat.add_succ] at sameDouble
      have coreDouble :
          left + left = right + right :=
        Nat.succ.inj (Nat.succ.inj sameDouble)
      exact
        congrArg Nat.succ
          (nat_add_self_eq_add_self_cancel left right coreDouble)

/--
Order cancellation for the diagonal core `n + succ n`, proved directly to keep
the diagonal-order calibration constructive.
-/
theorem nat_add_succ_self_le_cancel :
    forall left right : Nat,
      left + Nat.succ left <= right + Nat.succ right ->
        left <= right
  | 0, right, _ => Nat.zero_le right
  | Nat.succ left, 0, diagonalLe => by
      rw [Nat.zero_add] at diagonalLe
      rw [Nat.succ_add] at diagonalLe
      have impossible :
          left + Nat.succ (Nat.succ left) <= 0 :=
        Nat.le_of_succ_le_succ diagonalLe
      rw [Nat.add_succ] at impossible
      exact
        False.elim
          ((Nat.not_succ_le_zero (left + Nat.succ left)) impossible)
  | Nat.succ left, Nat.succ right, diagonalLe => by
      rw [Nat.succ_add, Nat.add_succ, Nat.succ_add, Nat.add_succ] at diagonalLe
      have coreLe :
          left + Nat.succ left <= right + Nat.succ right :=
        Nat.le_of_succ_le_succ (Nat.le_of_succ_le_succ diagonalLe)
      exact
        Nat.succ_le_succ
          (nat_add_succ_self_le_cancel left right coreLe)

/-- The enriched diagonal-gap order is antisymmetric on bare indices. -/
theorem natEnrichedDiagonalGapOrder_antisymm
    {left right : Nat}
    (left_right : NatEnrichedDiagonalGapOrder left right)
    (right_left : NatEnrichedDiagonalGapOrder right left) :
    left = right := by
  have sameGap :
      natEnrichedDiagonalGap left = natEnrichedDiagonalGap right :=
    Nat.le_antisymm left_right right_left
  unfold natEnrichedDiagonalGap at sameGap
  unfold natEnrichedParityFibrewiseStructuralPeak at sameGap
  unfold natEnrichedParityMaximalRelaxedDivergence at sameGap
  have gapCore :
      left + Nat.succ left = right + Nat.succ right :=
    Nat.succ.inj sameGap
  rw [Nat.add_succ, Nat.add_succ] at gapCore
  have doubleEq :
      left + left = right + right :=
    Nat.succ.inj gapCore
  exact nat_add_self_eq_add_self_cancel left right doubleEq

/-- The enriched diagonal-gap order as visible preorder data. -/
def natEnrichedDiagonalGapPreorder :
    VisiblePreorder Nat where
  le := NatEnrichedDiagonalGapOrder
  refl := natEnrichedDiagonalGapOrder_refl
  trans := by
    intro left middle right left_middle middle_right
    exact natEnrichedDiagonalGapOrder_trans left_middle middle_right

/-- The enriched diagonal-gap order as visible partial order data on indices. -/
def natEnrichedDiagonalGapPartialOrder :
    VisiblePartialOrder Nat where
  le := NatEnrichedDiagonalGapOrder
  refl := natEnrichedDiagonalGapOrder_refl
  trans := by
    intro left middle right left_middle middle_right
    exact natEnrichedDiagonalGapOrder_trans left_middle middle_right
  antisymm := by
    intro left right left_right right_left
    exact natEnrichedDiagonalGapOrder_antisymm left_right right_left

/--
The enriched diagonal-gap order is the comparison induced by the fibrewise
structural peak, not a primitive comparison of visible index values.
-/
theorem natEnrichedDiagonalGapOrder_iff_peak_le
    (left right : Nat) :
    NatEnrichedDiagonalGapOrder left right <->
      natEnrichedParityFibrewiseStructuralPeak left <=
        natEnrichedParityFibrewiseStructuralPeak right :=
  Iff.rfl

/--
On bare Nat indices, the enriched diagonal-gap order is extensionally the
usual Nat order.
-/
theorem natEnrichedDiagonalGapOrder_iff_nat_le
    (left right : Nat) :
    NatEnrichedDiagonalGapOrder left right <-> left <= right := by
  apply Iff.intro
  · intro diagonalLe
    unfold NatEnrichedDiagonalGapOrder at diagonalLe
    unfold natEnrichedDiagonalGap at diagonalLe
    unfold natEnrichedParityFibrewiseStructuralPeak at diagonalLe
    unfold natEnrichedParityMaximalRelaxedDivergence at diagonalLe
    exact
      nat_add_succ_self_le_cancel
        left
        right
        (Nat.le_of_succ_le_succ diagonalLe)
  · intro visibleLe
    unfold NatEnrichedDiagonalGapOrder
    unfold natEnrichedDiagonalGap
    unfold natEnrichedParityFibrewiseStructuralPeak
    unfold natEnrichedParityMaximalRelaxedDivergence
    exact
      Nat.succ_le_succ
        (Nat.add_le_add visibleLe (Nat.succ_le_succ visibleLe))

/-- Equality of diagonal gaps on bare indices is exactly equality of indices. -/
theorem natEnrichedDiagonalGap_eq_iff
    (left right : Nat) :
    natEnrichedDiagonalGap left = natEnrichedDiagonalGap right <->
      left = right := by
  apply Iff.intro
  · intro sameGap
    exact
      natEnrichedDiagonalGapOrder_antisymm
        (by
          unfold NatEnrichedDiagonalGapOrder
          rw [sameGap]
          exact Nat.le_refl (natEnrichedDiagonalGap right))
        (by
          unfold NatEnrichedDiagonalGapOrder
          rw [sameGap]
          exact Nat.le_refl (natEnrichedDiagonalGap right))
  · intro sameIndex
    rw [sameIndex]

/-- The enriched diagonal gap map is injective on bare indices. -/
theorem natEnrichedDiagonalGap_injective
    {left right : Nat}
    (sameGap :
      natEnrichedDiagonalGap left = natEnrichedDiagonalGap right) :
    left = right :=
  (natEnrichedDiagonalGap_eq_iff left right).mp sameGap

/-- The enriched diagonal-gap order is total on bare indices. -/
theorem natEnrichedDiagonalGapOrder_total
    (left right : Nat) :
    Or
      (NatEnrichedDiagonalGapOrder left right)
      (NatEnrichedDiagonalGapOrder right left) := by
  cases Nat.le_total left right with
  | inl left_le_right =>
      exact Or.inl
        ((natEnrichedDiagonalGapOrder_iff_nat_le left right).mpr
          left_le_right)
  | inr right_le_left =>
      exact Or.inr
        ((natEnrichedDiagonalGapOrder_iff_nat_le right left).mpr
          right_le_left)

/-- The enriched diagonal-gap order as visible total order data on bare indices. -/
def natEnrichedDiagonalGapTotalOrder :
    VisibleTotalOrder Nat where
  le := NatEnrichedDiagonalGapOrder
  refl := natEnrichedDiagonalGapOrder_refl
  trans := by
    intro left middle right left_middle middle_right
    exact natEnrichedDiagonalGapOrder_trans left_middle middle_right
  antisymm := by
    intro left right left_right right_left
    exact natEnrichedDiagonalGapOrder_antisymm left_right right_left
  total := natEnrichedDiagonalGapOrder_total

/-! ## Strict index order induced by the diagonal gap -/

/-- Strict diagonal-gap order on bare enriched Nat indices. -/
def NatEnrichedDiagonalGapStrictOrder
    (left right : Nat) :
    Prop :=
  natEnrichedDiagonalGap left < natEnrichedDiagonalGap right

/--
On bare Nat indices, strict enriched diagonal-gap comparison calibrates to the
usual strict Nat order.
-/
theorem natEnrichedDiagonalGapStrictOrder_iff_nat_lt
    (left right : Nat) :
    NatEnrichedDiagonalGapStrictOrder left right <-> left < right := by
  apply Iff.intro
  · intro strictGap
    have left_le_right :
        left <= right :=
      (natEnrichedDiagonalGapOrder_iff_nat_le left right).mp
        (Nat.le_of_lt strictGap)
    have left_ne_right :
        left ≠ right := by
      intro sameIndex
      rw [sameIndex] at strictGap
      exact Nat.lt_irrefl (natEnrichedDiagonalGap right) strictGap
    exact Nat.lt_of_le_of_ne left_le_right left_ne_right
  · intro strictIndex
    unfold NatEnrichedDiagonalGapStrictOrder
    unfold natEnrichedDiagonalGap
    unfold natEnrichedParityFibrewiseStructuralPeak
    unfold natEnrichedParityMaximalRelaxedDivergence
    exact
      Nat.succ_lt_succ
        (Nat.add_lt_add strictIndex (Nat.succ_lt_succ strictIndex))

/-! ## Audit-clean closing half fold for the diagonal peak shape -/

/--
Fuel irrelevance for `Nat.div.go`, reproved locally so the diagonal peak fold
does not depend on the audited `Nat.div_eq` family.
-/
theorem nat_div_go_fuel_congr
    (x y fuel1 fuel2 : Nat)
    (hy : 0 < y)
    (h1 : x < fuel1)
    (h2 : x < fuel2) :
    Nat.div.go y hy fuel1 x h1 =
      Nat.div.go y hy fuel2 x h2 := by
  match fuel1, fuel2 with
  | 0, _ => contradiction
  | _, 0 => contradiction
  | Nat.succ fuel1, Nat.succ fuel2 =>
      simp only [Nat.div.go]
      split
      next => rw [nat_div_go_fuel_congr]
      next => rfl
termination_by structural fuel1

/--
The internal `Nat.div.go` computation for the diagonal peak shape
`(k + k) + 2`, proved by direct recursion on the peak index.
-/
theorem nat_div_go_two_double_add_two
    (k : Nat) :
    Nat.div.go
        2
        (by decide)
        (((k + k) + 2).succ)
        ((k + k) + 2)
        (Nat.lt_succ_self _) =
      k + 1 := by
  induction k with
  | zero =>
      unfold Nat.div.go
      split
      next _ =>
        unfold Nat.div.go
        split
        next h => cases h
        next _ => rfl
      next h => cases h (by decide)
  | succ k ih =>
      unfold Nat.div.go
      split
      next _ =>
        simp only [Nat.succ_add, Nat.add_succ, Nat.add_zero] at ih ⊢
        change
          (Nat.div.go
              2
              (by decide)
              (k + k).succ.succ.succ.succ
              (k + k).succ.succ
              ?h).succ =
            k.succ.succ
        rw [
          nat_div_go_fuel_congr
            (k + k).succ.succ
            2
            (k + k).succ.succ.succ.succ
            (k + k).succ.succ.succ
            (by decide)
            (Nat.lt_succ_of_lt (Nat.lt_succ_self _))
            (Nat.lt_succ_self _)]
        exact congrArg Nat.succ ih
      next h =>
        apply False.elim
        apply h
        exact Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le _))

/--
The diagonal peak shape folds by the closing half-action to the successor of
the index.  This proof avoids the audited `Nat.div_eq` lemmas and computes via
`Nat.div.go` directly.
-/
theorem nat_double_add_two_div_two
    (k : Nat) :
    ((k + k) + 2) / 2 = k + 1 := by
  change Nat.div ((k + k) + 2) 2 = k + 1
  unfold Nat.div
  split
  next _ =>
    exact nat_div_go_two_double_add_two k
  next h =>
    apply False.elim
    apply h
    exact Nat.succ_pos 1

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGap_eq_fibrewiseStructuralPeak
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGap_eq_maximalRelaxedDivergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGap_eq_double_add_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGap_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedDiagonalGapOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapOrder_refl
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapOrder_trans
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_add_self_eq_add_self_cancel
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_add_succ_self_le_cancel
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapOrder_antisymm
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapPreorder
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapPartialOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapOrder_iff_peak_le
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapOrder_iff_nat_le
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGap_eq_iff
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGap_injective
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapOrder_total
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapTotalOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedDiagonalGapStrictOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapStrictOrder_iff_nat_lt
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_div_go_fuel_congr
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_div_go_two_double_add_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_double_add_two_div_two
/- AXIOM_AUDIT_END -/
