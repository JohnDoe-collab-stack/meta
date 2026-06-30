import Meta.Collatz.DynamicClosureLoop

/-!
# Collatz diagonal order

This file exposes the order induced by the positive diagonal gap.

Definitionally, the comparison is introduced through the positive diagonal gap
carried by enriched Nat indices and by Collatz operational intersections.
Extensionally, on bare Nat indices, this order calibrates to the usual Nat
order.  On intersections, the order is induced by the formed positive excess
activated by each intersection, without collapsing intersections themselves.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Index order induced by the diagonal gap -/

/-- The positive diagonal gap carried by an enriched Nat index in the Collatz layer. -/
def collatzDiagonalGap
    (index : Nat) :
    Nat :=
  natEnrichedParityFibrewiseStructuralPeak index

/-- The Collatz diagonal gap is the enriched Nat fibrewise structural peak. -/
theorem collatzDiagonalGap_eq_fibrewiseStructuralPeak
    (index : Nat) :
    collatzDiagonalGap index =
      natEnrichedParityFibrewiseStructuralPeak index :=
  rfl

/-- The Collatz diagonal gap is the maximal relaxed divergence at the index. -/
theorem collatzDiagonalGap_eq_maximalRelaxedDivergence
    (index : Nat) :
    collatzDiagonalGap index =
      natEnrichedParityMaximalRelaxedDivergence index :=
  natEnrichedParityFibrewiseStructuralPeak_eq_maximalDivergence index

/-- The Collatz diagonal gap has the countdown-consumable form `(index + index) + 2`. -/
theorem collatzDiagonalGap_eq_double_add_two
    (index : Nat) :
    collatzDiagonalGap index = (index + index) + 2 :=
  natEnrichedParityFibrewiseStructuralPeak_eq_double_add_two index

/-- The Collatz diagonal gap is strictly positive at every index. -/
theorem collatzDiagonalGap_pos
    (index : Nat) :
    0 < collatzDiagonalGap index :=
  natEnrichedParityFibrewiseStructuralPeak_pos index

/--
Diagonal-gap order on indices.

`left` is below `right` when the positive diagonal gap carried by `left` is
below the positive diagonal gap carried by `right`.
-/
def CollatzDiagonalGapOrder
    (left right : Nat) :
    Prop :=
  collatzDiagonalGap left <= collatzDiagonalGap right

/-- The diagonal-gap order is reflexive. -/
theorem collatzDiagonalGapOrder_refl
    (index : Nat) :
    CollatzDiagonalGapOrder index index :=
  Nat.le_refl (collatzDiagonalGap index)

/-- The diagonal-gap order is transitive. -/
theorem collatzDiagonalGapOrder_trans
    {left middle right : Nat}
    (left_middle : CollatzDiagonalGapOrder left middle)
    (middle_right : CollatzDiagonalGapOrder middle right) :
    CollatzDiagonalGapOrder left right :=
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

/-- The diagonal-gap order is antisymmetric on indices. -/
theorem collatzDiagonalGapOrder_antisymm
    {left right : Nat}
    (left_right : CollatzDiagonalGapOrder left right)
    (right_left : CollatzDiagonalGapOrder right left) :
    left = right := by
  have sameGap :
      collatzDiagonalGap left = collatzDiagonalGap right :=
    Nat.le_antisymm left_right right_left
  unfold collatzDiagonalGap at sameGap
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

/-- The diagonal-gap order as visible preorder data. -/
def collatzDiagonalGapPreorder :
    VisiblePreorder Nat where
  le := CollatzDiagonalGapOrder
  refl := collatzDiagonalGapOrder_refl
  trans := by
    intro left middle right left_middle middle_right
    exact collatzDiagonalGapOrder_trans left_middle middle_right

/-- The diagonal-gap order as visible partial order data on indices. -/
def collatzDiagonalGapPartialOrder :
    VisiblePartialOrder Nat where
  le := CollatzDiagonalGapOrder
  refl := collatzDiagonalGapOrder_refl
  trans := by
    intro left middle right left_middle middle_right
    exact collatzDiagonalGapOrder_trans left_middle middle_right
  antisymm := by
    intro left right left_right right_left
    exact collatzDiagonalGapOrder_antisymm left_right right_left

/--
The diagonal-gap order is the comparison induced by the fibrewise structural
peak, not a primitive comparison of visible index values.
-/
theorem collatzDiagonalGapOrder_iff_peak_le
    (left right : Nat) :
    CollatzDiagonalGapOrder left right <->
      natEnrichedParityFibrewiseStructuralPeak left <=
        natEnrichedParityFibrewiseStructuralPeak right :=
  Iff.rfl

/--
On bare Nat indices, the diagonal-gap order is extensionally the usual Nat
order.  The important point is that the order is introduced through the
positive diagonal gap; this theorem calibrates that index-level order against
the ordinary visible order.
-/
theorem collatzDiagonalGapOrder_iff_nat_le
    (left right : Nat) :
    CollatzDiagonalGapOrder left right <-> left <= right := by
  apply Iff.intro
  · intro diagonalLe
    unfold CollatzDiagonalGapOrder at diagonalLe
    unfold collatzDiagonalGap at diagonalLe
    unfold natEnrichedParityFibrewiseStructuralPeak at diagonalLe
    unfold natEnrichedParityMaximalRelaxedDivergence at diagonalLe
    exact
      nat_add_succ_self_le_cancel
        left
        right
        (Nat.le_of_succ_le_succ diagonalLe)
  · intro visibleLe
    unfold CollatzDiagonalGapOrder
    unfold collatzDiagonalGap
    unfold natEnrichedParityFibrewiseStructuralPeak
    unfold natEnrichedParityMaximalRelaxedDivergence
    exact
      Nat.succ_le_succ
        (Nat.add_le_add visibleLe (Nat.succ_le_succ visibleLe))

/-- Equality of diagonal gaps on bare indices is exactly equality of indices. -/
theorem collatzDiagonalGap_eq_iff
    (left right : Nat) :
    collatzDiagonalGap left = collatzDiagonalGap right <-> left = right := by
  apply Iff.intro
  · intro sameGap
    exact
      collatzDiagonalGapOrder_antisymm
        (by
          unfold CollatzDiagonalGapOrder
          rw [sameGap]
          exact Nat.le_refl (collatzDiagonalGap right))
        (by
          unfold CollatzDiagonalGapOrder
          rw [sameGap]
          exact Nat.le_refl (collatzDiagonalGap right))
  · intro sameIndex
    rw [sameIndex]

/-- The diagonal gap map is injective on bare indices. -/
theorem collatzDiagonalGap_injective
    {left right : Nat}
    (sameGap : collatzDiagonalGap left = collatzDiagonalGap right) :
    left = right :=
  (collatzDiagonalGap_eq_iff left right).mp sameGap

/-- The diagonal-gap order is total on bare indices. -/
theorem collatzDiagonalGapOrder_total
    (left right : Nat) :
    Or
      (CollatzDiagonalGapOrder left right)
      (CollatzDiagonalGapOrder right left) := by
  cases Nat.le_total left right with
  | inl left_le_right =>
      exact Or.inl
        ((collatzDiagonalGapOrder_iff_nat_le left right).mpr
          left_le_right)
  | inr right_le_left =>
      exact Or.inr
        ((collatzDiagonalGapOrder_iff_nat_le right left).mpr
          right_le_left)

/-- The diagonal-gap order as visible total order data on bare indices. -/
def collatzDiagonalGapTotalOrder :
    VisibleTotalOrder Nat where
  le := CollatzDiagonalGapOrder
  refl := collatzDiagonalGapOrder_refl
  trans := by
    intro left middle right left_middle middle_right
    exact collatzDiagonalGapOrder_trans left_middle middle_right
  antisymm := by
    intro left right left_right right_left
    exact collatzDiagonalGapOrder_antisymm left_right right_left
  total := collatzDiagonalGapOrder_total

/-! ## Strict index order induced by the diagonal gap -/

/-- Strict diagonal-gap order on bare indices. -/
def CollatzDiagonalGapStrictOrder
    (left right : Nat) :
    Prop :=
  collatzDiagonalGap left < collatzDiagonalGap right

/--
On bare Nat indices, strict diagonal-gap comparison calibrates to the usual
strict Nat order.
-/
theorem collatzDiagonalGapStrictOrder_iff_nat_lt
    (left right : Nat) :
    CollatzDiagonalGapStrictOrder left right <-> left < right := by
  apply Iff.intro
  · intro strictGap
    have left_le_right :
        left <= right :=
      (collatzDiagonalGapOrder_iff_nat_le left right).mp
        (Nat.le_of_lt strictGap)
    have left_ne_right :
        left ≠ right := by
      intro sameIndex
      rw [sameIndex] at strictGap
      exact Nat.lt_irrefl (collatzDiagonalGap right) strictGap
    exact Nat.lt_of_le_of_ne left_le_right left_ne_right
  · intro strictIndex
    unfold CollatzDiagonalGapStrictOrder
    unfold collatzDiagonalGap
    unfold natEnrichedParityFibrewiseStructuralPeak
    unfold natEnrichedParityMaximalRelaxedDivergence
    exact
      Nat.succ_lt_succ
        (Nat.add_lt_add strictIndex (Nat.succ_lt_succ strictIndex))

/-! ## Intersection order induced by the activated Collatz peak -/

/-- The positive diagonal gap activated by one Collatz operational intersection. -/
def collatzIntersectionDiagonalGap
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Nat :=
  collatzFibrewiseStructuralPeak intersection

/--
Diagonal-gap order on Collatz operational intersections.

One intersection is below another when its activated fibrewise peak is below
the activated fibrewise peak of the other.
-/
def CollatzIntersectionDiagonalGapOrder
    {leftBranch rightBranch : MemoryBranch}
    (left : PrimitiveMemoryReadingIntersection leftBranch)
    (right : PrimitiveMemoryReadingIntersection rightBranch) :
    Prop :=
  collatzIntersectionDiagonalGap left <= collatzIntersectionDiagonalGap right

/-- The intersection diagonal-gap order is reflexive. -/
theorem collatzIntersectionDiagonalGapOrder_refl
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzIntersectionDiagonalGapOrder intersection intersection :=
  Nat.le_refl (collatzIntersectionDiagonalGap intersection)

/-- The intersection diagonal-gap order is transitive across enriched intersections. -/
theorem collatzIntersectionDiagonalGapOrder_trans
    {leftBranch middleBranch rightBranch : MemoryBranch}
    {left : PrimitiveMemoryReadingIntersection leftBranch}
    {middle : PrimitiveMemoryReadingIntersection middleBranch}
    {right : PrimitiveMemoryReadingIntersection rightBranch}
    (left_middle : CollatzIntersectionDiagonalGapOrder left middle)
    (middle_right : CollatzIntersectionDiagonalGapOrder middle right) :
    CollatzIntersectionDiagonalGapOrder left right :=
  Nat.le_trans left_middle middle_right

/--
The intersection diagonal gap is the Nat diagonal gap of the formed index
activated by the intersection.
-/
theorem collatzIntersectionDiagonalGap_eq_indexGap
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzIntersectionDiagonalGap intersection =
      collatzDiagonalGap
        (formedPositiveExcessOfIntersection intersection) :=
  collatzFibrewiseStructuralPeak_eq_natPeak intersection

/--
The intersection diagonal-gap order is exactly the order induced by the formed
positive excess activated by each intersection.
-/
theorem collatzIntersectionDiagonalGapOrder_iff_formedPositiveExcess_le
    {leftBranch rightBranch : MemoryBranch}
    (left : PrimitiveMemoryReadingIntersection leftBranch)
    (right : PrimitiveMemoryReadingIntersection rightBranch) :
    CollatzIntersectionDiagonalGapOrder left right <->
      formedPositiveExcessOfIntersection left <=
        formedPositiveExcessOfIntersection right := by
  apply Iff.intro
  · intro gapOrder
    unfold CollatzIntersectionDiagonalGapOrder at gapOrder
    rw [collatzIntersectionDiagonalGap_eq_indexGap left] at gapOrder
    rw [collatzIntersectionDiagonalGap_eq_indexGap right] at gapOrder
    change
      CollatzDiagonalGapOrder
        (formedPositiveExcessOfIntersection left)
        (formedPositiveExcessOfIntersection right) at gapOrder
    exact
      (collatzDiagonalGapOrder_iff_nat_le
        (formedPositiveExcessOfIntersection left)
        (formedPositiveExcessOfIntersection right)).mp gapOrder
  · intro formedOrder
    unfold CollatzIntersectionDiagonalGapOrder
    rw [collatzIntersectionDiagonalGap_eq_indexGap left]
    rw [collatzIntersectionDiagonalGap_eq_indexGap right]
    change
      CollatzDiagonalGapOrder
        (formedPositiveExcessOfIntersection left)
        (formedPositiveExcessOfIntersection right)
    exact
      (collatzDiagonalGapOrder_iff_nat_le
        (formedPositiveExcessOfIntersection left)
        (formedPositiveExcessOfIntersection right)).mpr formedOrder

/--
Mutual intersection comparison contracts only to equality of the formed
positive excess.  It does not collapse the enriched intersections themselves.
-/
theorem collatzIntersectionDiagonalGapOrder_mutual_formedPositiveExcess_eq
    {leftBranch rightBranch : MemoryBranch}
    {left : PrimitiveMemoryReadingIntersection leftBranch}
    {right : PrimitiveMemoryReadingIntersection rightBranch}
    (left_right : CollatzIntersectionDiagonalGapOrder left right)
    (right_left : CollatzIntersectionDiagonalGapOrder right left) :
    formedPositiveExcessOfIntersection left =
      formedPositiveExcessOfIntersection right :=
  Nat.le_antisymm
    ((collatzIntersectionDiagonalGapOrder_iff_formedPositiveExcess_le
      left right).mp left_right)
    ((collatzIntersectionDiagonalGapOrder_iff_formedPositiveExcess_le
      right left).mp right_left)

/-- The intersection diagonal gap is the positive relaxed witness activated there. -/
theorem collatzIntersectionDiagonalGap_eq_positiveWitness
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzIntersectionDiagonalGap intersection =
      collatzRelaxedPositiveDiagonalValueOfIntersection intersection :=
  rfl

/-- The intersection diagonal gap is strictly positive. -/
theorem collatzIntersectionDiagonalGap_pos
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    0 < collatzIntersectionDiagonalGap intersection :=
  collatzRelaxedPositiveDiagonalValue_pos intersection

/-- The intersection diagonal gap is consumed as terminal excess by its countdown consumer. -/
theorem collatzIntersectionDiagonalGap_eq_countdownTerminalExcess
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzIntersectionDiagonalGap intersection =
      formedPositiveExcessOfIntersection
        (collatzRelaxedCountdownConsumerIntersection intersection) :=
  collatzFibrewiseStructuralPeak_eq_countdownTerminalExcess intersection

/-- The intersection diagonal gap is the peak field of the dynamic closure loop. -/
theorem collatzIntersectionDiagonalGap_eq_dynamicClosureLoop_peak
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzIntersectionDiagonalGap intersection =
      (collatzDynamicClosureLoop intersection).peak :=
  rfl

/-- Through the dynamic closure loop, the intersection diagonal gap is consumed. -/
theorem collatzIntersectionDiagonalGap_consumed_as_terminal_excess
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzIntersectionDiagonalGap intersection =
      formedPositiveExcessOfIntersection
        (collatzDynamicClosureLoop intersection).consumer :=
  collatzDynamicClosureLoop_consumed_as_terminal_excess intersection

/-- Through the dynamic closure loop, the intersection diagonal gap reenters as closing. -/
theorem collatzIntersectionDiagonalGap_reenters_as_closing
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingRoleOfIntersection
        (collatzDynamicClosureLoop intersection).consumer =
      NatEnrichedParityRole.closingExcess
        (collatzIntersectionDiagonalGap intersection) :=
  collatzDynamicClosureLoop_reenters_as_closing intersection

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGap_eq_fibrewiseStructuralPeak
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGap_eq_maximalRelaxedDivergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGap_eq_double_add_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGap_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzDiagonalGapOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGapOrder_refl
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGapOrder_trans
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_add_self_eq_add_self_cancel
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_add_succ_self_le_cancel
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGapOrder_antisymm
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGapPreorder
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGapPartialOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGapOrder_iff_peak_le
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGapOrder_iff_nat_le
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGap_eq_iff
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGap_injective
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGapOrder_total
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGapTotalOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzDiagonalGapStrictOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDiagonalGapStrictOrder_iff_nat_lt
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzIntersectionDiagonalGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzIntersectionDiagonalGapOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzIntersectionDiagonalGapOrder_refl
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzIntersectionDiagonalGapOrder_trans
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzIntersectionDiagonalGap_eq_indexGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzIntersectionDiagonalGapOrder_iff_formedPositiveExcess_le
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzIntersectionDiagonalGapOrder_mutual_formedPositiveExcess_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzIntersectionDiagonalGap_eq_positiveWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzIntersectionDiagonalGap_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzIntersectionDiagonalGap_eq_countdownTerminalExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzIntersectionDiagonalGap_eq_dynamicClosureLoop_peak
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzIntersectionDiagonalGap_consumed_as_terminal_excess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzIntersectionDiagonalGap_reenters_as_closing
/- AXIOM_AUDIT_END -/
