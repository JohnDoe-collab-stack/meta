# Collatz diagonal order completion plan

## Object

This document fixes what must be added to
`Meta/Collatz/DiagonalOrder.lean` so the file is complete for the current
Meta/Collatz layer.

The goal is not to create a classical bound.  The goal is to expose the order
induced by the positive diagonal gap, calibrate it on bare `Nat` indices, and
then make the intersection-level order auditable without collapsing enriched
intersections into bare numbers.

## Current state

The file already defines:

```lean
collatzDiagonalGap
CollatzDiagonalGapOrder
collatzDiagonalGapPreorder
collatzDiagonalGapPartialOrder
collatzDiagonalGapOrder_iff_nat_le
collatzIntersectionDiagonalGap
CollatzIntersectionDiagonalGapOrder
collatzIntersectionDiagonalGap_eq_indexGap
```

The decisive existing calibration is:

```lean
CollatzDiagonalGapOrder left right <-> left <= right
```

This proves that on bare `Nat` indices, the diagonal-gap order is
extensionally the usual order.  This is a calibration theorem, not a dynamic
bound.

## Missing items

### 1. Header correction

The header must not say that the comparison is simply "not" the visible
comparison.  The precise statement is:

```text
definitionally, the order is introduced through the positive diagonal gap;
extensionally, on bare Nat indices, it calibrates to the usual Nat order.
```

### 2. Public gap value facades

Expose the value of the diagonal gap by named theorems:

```lean
collatzDiagonalGap_eq_fibrewiseStructuralPeak
collatzDiagonalGap_eq_maximalRelaxedDivergence
collatzDiagonalGap_eq_double_add_two
collatzDiagonalGap_pos
```

These names make explicit that the index gap is the fibrewise structural peak,
the maximal non-contracted relaxed divergence, and the countdown-consumable
form `(index + index) + 2`.

### 3. Injectivity of the index gap

Expose that the gap does not identify two distinct bare indices:

```lean
collatzDiagonalGap_eq_iff
collatzDiagonalGap_injective
```

This is stronger as a public reading than antisymmetry alone.

### 4. Total order on bare indices

Since the diagonal order calibrates to `<=` on bare `Nat`, expose:

```lean
collatzDiagonalGapOrder_total
collatzDiagonalGapTotalOrder
```

This is only for bare indices.  It must not be reused to collapse operational
intersections.

### 5. Strict diagonal order

Add:

```lean
CollatzDiagonalGapStrictOrder
collatzDiagonalGapStrictOrder_iff_nat_lt
```

This gives the strict comparison induced by the diagonal gap and calibrates it
on bare indices.

### 6. Intersection order calibration

The central missing theorem is:

```lean
CollatzIntersectionDiagonalGapOrder left right
<->
formedPositiveExcessOfIntersection left <=
  formedPositiveExcessOfIntersection right
```

This says the intersection order is induced by the formed index activated by
each intersection.

### 7. Mutual comparison of intersections

Do not prove:

```lean
left = right
```

from mutual comparison of intersections.  That would collapse enriched
interfaces incorrectly.

The correct theorem is:

```lean
mutual intersection comparison
-> same formed positive excess
```

This preserves the difference between enriched intersections and their formed
index.

### 8. Raccord to the positive witness, peak, consumption, and reentry

Expose:

```lean
collatzIntersectionDiagonalGap_eq_positiveWitness
collatzIntersectionDiagonalGap_pos
collatzIntersectionDiagonalGap_eq_countdownTerminalExcess
collatzIntersectionDiagonalGap_eq_dynamicClosureLoop_peak
collatzIntersectionDiagonalGap_consumed_as_terminal_excess
collatzIntersectionDiagonalGap_reenters_as_closing
```

This makes explicit that the intersection diagonal gap is not a free number:
it is the positive witness, the fibrewise peak, the consumed terminal excess,
and the value reinserted as `closingExcess`.

## Non-goals

This file must not prove a global Collatz bound.

This file must not prove orbit termination.

This file must not collapse two operational intersections to equality merely
because their diagonal gaps are mutually comparable.

This file must not use classical parity coding, conditional bridges, or
external producer data.

## Acceptance criteria

The implementation is acceptable only if:

1. every item above is implemented or explicitly represented by a theorem with
   the correct weaker conclusion;
2. the Lean file ends with exactly one `AXIOM_AUDIT` block;
3. the audit reports no axioms;
4. the audit reports no `Classical`, no `propext`, and no `Quot.sound`;
5. `lake build Meta.Collatz.DiagonalOrder` succeeds;
6. `lake env lean Meta.lean` succeeds.
