import Meta.Arithmetic.DiagonalOrder
import Meta.Collatz.DynamicClosureLoop

/-!
# Collatz diagonal order

This file specializes the enriched-Nat diagonal order to Collatz operational
intersections.

The pure index order is owned by `Meta.Arithmetic.DiagonalOrder`.  This file
keeps Collatz-facing compatibility names and proves the intersection-specific
facts:

```text
Collatz intersection
-> formedPositiveExcessOfIntersection
-> enriched Nat diagonal gap
```

Mutual comparison of intersections contracts only to equality of formed
positive excess.  It does not collapse enriched intersections themselves.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Collatz-facing aliases for the pure enriched-Nat diagonal order -/

/-- Collatz-facing name for the enriched Nat diagonal gap. -/
abbrev collatzDiagonalGap
    (index : Nat) :
    Nat :=
  natEnrichedDiagonalGap index

/-- The Collatz diagonal gap is the enriched Nat fibrewise structural peak. -/
theorem collatzDiagonalGap_eq_fibrewiseStructuralPeak
    (index : Nat) :
    collatzDiagonalGap index =
      natEnrichedParityFibrewiseStructuralPeak index :=
  natEnrichedDiagonalGap_eq_fibrewiseStructuralPeak index

/-- The Collatz diagonal gap is the maximal relaxed divergence at the index. -/
theorem collatzDiagonalGap_eq_maximalRelaxedDivergence
    (index : Nat) :
    collatzDiagonalGap index =
      natEnrichedParityMaximalRelaxedDivergence index :=
  natEnrichedDiagonalGap_eq_maximalRelaxedDivergence index

/-- The Collatz diagonal gap has the countdown-consumable form `(index + index) + 2`. -/
theorem collatzDiagonalGap_eq_double_add_two
    (index : Nat) :
    collatzDiagonalGap index = (index + index) + 2 :=
  natEnrichedDiagonalGap_eq_double_add_two index

/-- The Collatz diagonal gap is strictly positive at every index. -/
theorem collatzDiagonalGap_pos
    (index : Nat) :
    0 < collatzDiagonalGap index :=
  natEnrichedDiagonalGap_pos index

/-- Collatz-facing name for the enriched Nat diagonal-gap order. -/
abbrev CollatzDiagonalGapOrder
    (left right : Nat) :
    Prop :=
  NatEnrichedDiagonalGapOrder left right

/-- The Collatz-facing diagonal-gap order is reflexive. -/
theorem collatzDiagonalGapOrder_refl
    (index : Nat) :
    CollatzDiagonalGapOrder index index :=
  natEnrichedDiagonalGapOrder_refl index

/-- The Collatz-facing diagonal-gap order is transitive. -/
theorem collatzDiagonalGapOrder_trans
    {left middle right : Nat}
    (left_middle : CollatzDiagonalGapOrder left middle)
    (middle_right : CollatzDiagonalGapOrder middle right) :
    CollatzDiagonalGapOrder left right :=
  natEnrichedDiagonalGapOrder_trans left_middle middle_right

/-- The Collatz-facing diagonal-gap order is antisymmetric on bare indices. -/
theorem collatzDiagonalGapOrder_antisymm
    {left right : Nat}
    (left_right : CollatzDiagonalGapOrder left right)
    (right_left : CollatzDiagonalGapOrder right left) :
    left = right :=
  natEnrichedDiagonalGapOrder_antisymm left_right right_left

/-- The Collatz-facing diagonal-gap order as visible preorder data. -/
def collatzDiagonalGapPreorder :
    VisiblePreorder Nat :=
  natEnrichedDiagonalGapPreorder

/-- The Collatz-facing diagonal-gap order as visible partial order data. -/
def collatzDiagonalGapPartialOrder :
    VisiblePartialOrder Nat :=
  natEnrichedDiagonalGapPartialOrder

/--
The Collatz-facing diagonal-gap order is the comparison induced by the
fibrewise structural peak.
-/
theorem collatzDiagonalGapOrder_iff_peak_le
    (left right : Nat) :
    CollatzDiagonalGapOrder left right <->
      natEnrichedParityFibrewiseStructuralPeak left <=
        natEnrichedParityFibrewiseStructuralPeak right :=
  natEnrichedDiagonalGapOrder_iff_peak_le left right

/--
On bare Nat indices, the Collatz-facing diagonal-gap order calibrates to the
usual Nat order.
-/
theorem collatzDiagonalGapOrder_iff_nat_le
    (left right : Nat) :
    CollatzDiagonalGapOrder left right <-> left <= right :=
  natEnrichedDiagonalGapOrder_iff_nat_le left right

/-- Equality of Collatz-facing diagonal gaps is exactly equality of indices. -/
theorem collatzDiagonalGap_eq_iff
    (left right : Nat) :
    collatzDiagonalGap left = collatzDiagonalGap right <-> left = right :=
  natEnrichedDiagonalGap_eq_iff left right

/-- The Collatz-facing diagonal gap map is injective on bare indices. -/
theorem collatzDiagonalGap_injective
    {left right : Nat}
    (sameGap : collatzDiagonalGap left = collatzDiagonalGap right) :
    left = right :=
  natEnrichedDiagonalGap_injective sameGap

/-- The Collatz-facing diagonal-gap order is total on bare indices. -/
theorem collatzDiagonalGapOrder_total
    (left right : Nat) :
    Or
      (CollatzDiagonalGapOrder left right)
      (CollatzDiagonalGapOrder right left) :=
  natEnrichedDiagonalGapOrder_total left right

/-- The Collatz-facing diagonal-gap order as visible total order data. -/
def collatzDiagonalGapTotalOrder :
    VisibleTotalOrder Nat :=
  natEnrichedDiagonalGapTotalOrder

/-- Collatz-facing name for the strict enriched Nat diagonal-gap order. -/
abbrev CollatzDiagonalGapStrictOrder
    (left right : Nat) :
    Prop :=
  NatEnrichedDiagonalGapStrictOrder left right

/--
On bare Nat indices, strict Collatz-facing diagonal-gap comparison calibrates
to the usual strict Nat order.
-/
theorem collatzDiagonalGapStrictOrder_iff_nat_lt
    (left right : Nat) :
    CollatzDiagonalGapStrictOrder left right <-> left < right :=
  natEnrichedDiagonalGapStrictOrder_iff_nat_lt left right

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
The intersection diagonal gap is the enriched Nat diagonal gap of the formed
index activated by the intersection.
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

/-! ## Dynamic order carried by the closure loop -/

/--
Ordered closure predicate carried by the canonical Collatz dynamic loop.

This is not a binary order on all intersections.  It compares the source
intersection diagonal gap with the terminal excess of its own canonical
consumer.
-/
def CollatzDynamicClosureOrder
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Prop :=
  collatzIntersectionDiagonalGap intersection <=
    formedPositiveExcessOfIntersection
      (collatzDynamicClosureLoop intersection).consumer

/-- Every Collatz operational intersection carries its canonical ordered closure. -/
theorem collatzDynamicClosureOrder_of_intersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzDynamicClosureOrder intersection := by
  unfold CollatzDynamicClosureOrder
  rw [collatzIntersectionDiagonalGap_consumed_as_terminal_excess intersection]
  exact Nat.le_refl _

/--
The dynamic ordered closure package for one Collatz operational intersection.

It records the source diagonal gap, the peak of the dynamic loop, the terminal
excess of the canonical consumer, their equality, the induced order, and the
closing/forming reinsertion.
-/
structure CollatzDynamicOrderedClosure
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) where
  loop : CollatzDynamicClosureLoop intersection
  sourceGap : Nat
  sourceGap_eq :
    sourceGap = collatzIntersectionDiagonalGap intersection
  sourceGap_eq_peak :
    sourceGap = loop.peak
  consumerGap : Nat
  consumerGap_eq :
    consumerGap = formedPositiveExcessOfIntersection loop.consumer
  sourceGap_eq_consumerGap :
    sourceGap = consumerGap
  ordered :
    sourceGap <= consumerGap
  reenters_as_closing :
    arithmeticClosingRoleOfIntersection loop.consumer =
      NatEnrichedParityRole.closingExcess sourceGap

/-- The canonical dynamic ordered closure package for one Collatz intersection. -/
def collatzDynamicOrderedClosure
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzDynamicOrderedClosure intersection where
  loop := collatzDynamicClosureLoop intersection
  sourceGap := collatzIntersectionDiagonalGap intersection
  sourceGap_eq := rfl
  sourceGap_eq_peak :=
    collatzIntersectionDiagonalGap_eq_dynamicClosureLoop_peak intersection
  consumerGap :=
    formedPositiveExcessOfIntersection
      (collatzDynamicClosureLoop intersection).consumer
  consumerGap_eq := rfl
  sourceGap_eq_consumerGap :=
    collatzIntersectionDiagonalGap_consumed_as_terminal_excess intersection
  ordered := by
    rw [collatzIntersectionDiagonalGap_consumed_as_terminal_excess intersection]
    exact Nat.le_refl _
  reenters_as_closing :=
    collatzIntersectionDiagonalGap_reenters_as_closing intersection

/-- The canonical ordered closure identifies source gap and consumer terminal excess. -/
theorem collatzDynamicOrderedClosure_sourceGap_eq_consumerGap
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzDynamicOrderedClosure intersection).sourceGap =
      (collatzDynamicOrderedClosure intersection).consumerGap :=
  (collatzDynamicOrderedClosure intersection).sourceGap_eq_consumerGap

/-- The canonical ordered closure identifies the source gap with the loop peak. -/
theorem collatzDynamicOrderedClosure_sourceGap_eq_peak
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzDynamicOrderedClosure intersection).sourceGap =
      (collatzDynamicOrderedClosure intersection).loop.peak :=
  (collatzDynamicOrderedClosure intersection).sourceGap_eq_peak

/-- The canonical ordered closure exposes the induced comparison. -/
theorem collatzDynamicOrderedClosure_ordered
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzDynamicOrderedClosure intersection).sourceGap <=
      (collatzDynamicOrderedClosure intersection).consumerGap :=
  (collatzDynamicOrderedClosure intersection).ordered

/-- The canonical ordered closure reenters through a closing/forming role. -/
theorem collatzDynamicOrderedClosure_reenters_as_closing
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingRoleOfIntersection
        (collatzDynamicOrderedClosure intersection).loop.consumer =
      NatEnrichedParityRole.closingExcess
        (collatzDynamicOrderedClosure intersection).sourceGap :=
  (collatzDynamicOrderedClosure intersection).reenters_as_closing

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
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzDynamicClosureOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicClosureOrder_of_intersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzDynamicOrderedClosure
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicOrderedClosure
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicOrderedClosure_sourceGap_eq_consumerGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicOrderedClosure_sourceGap_eq_peak
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicOrderedClosure_ordered
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicOrderedClosure_reenters_as_closing
/- AXIOM_AUDIT_END -/
