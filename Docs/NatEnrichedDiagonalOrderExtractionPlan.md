# Nat enriched diagonal order extraction plan

## Object

This document fixes the extraction of the pure enriched-Nat diagonal order from
the Collatz layer.

The current `Meta/Collatz/DiagonalOrder.lean` contains two different levels:

```text
1. pure enriched Nat index level;
2. Collatz operational intersection level.
```

The first level does not depend on Collatz.  It should live in the arithmetic
layer.  The Collatz file should then become a specialization:

```text
Collatz intersection
-> formedPositiveExcessOfIntersection
-> Nat enriched diagonal order
```

The goal is architectural precision, not a new theorem about Collatz
termination.

## Target file

Create:

```text
Meta/Arithmetic/DiagonalOrder.lean
```

This file must import only what it needs:

```lean
import Meta.Arithmetic.Parity
```

Reason: the pure order needs:

```text
natEnrichedParityFibrewiseStructuralPeak
natEnrichedParityMaximalRelaxedDivergence
natEnrichedParityFibrewiseStructuralPeak_eq_double_add_two
VisiblePreorder / VisiblePartialOrder / VisibleTotalOrder
```

These are already available through the arithmetic stack.

Do not import:

```lean
Meta.Arithmetic.CountdownRelaxedParity
Meta.Collatz.DynamicClosureLoop
```

from the pure arithmetic file.  Countdown consumption is downstream of the
pure diagonal order.  The arithmetic diagonal order only needs the
countdown-consumable shape `(k + k) + 2`, already proved in `Parity.lean`.

## Names to introduce

Use Nat-enriched names, not Collatz names:

```lean
natEnrichedDiagonalGap
NatEnrichedDiagonalGapOrder
natEnrichedDiagonalGapOrder_refl
natEnrichedDiagonalGapOrder_trans
natEnrichedDiagonalGapOrder_antisymm
natEnrichedDiagonalGapPreorder
natEnrichedDiagonalGapPartialOrder
natEnrichedDiagonalGapTotalOrder
NatEnrichedDiagonalGapStrictOrder
```

## Pure gap value facades

Expose:

```lean
natEnrichedDiagonalGap_eq_fibrewiseStructuralPeak
natEnrichedDiagonalGap_eq_maximalRelaxedDivergence
natEnrichedDiagonalGap_eq_double_add_two
natEnrichedDiagonalGap_pos
```

Meaning:

```text
Delta(k) is the fibrewise structural peak.
Delta(k) is the maximal non-contracted relaxed divergence.
Delta(k) has countdown-consumable form (k + k) + 2.
Delta(k) is positive.
```

## Constructive cancellation helpers

Move the constructive cancellation helpers into the arithmetic file:

```lean
nat_add_self_eq_add_self_cancel
nat_add_succ_self_le_cancel
```

These must remain directly constructive.

After extraction, remove these declarations from
`Meta/Collatz/DiagonalOrder.lean`.  There must be only one owner for these
helper names in the namespace:

```text
Meta.EnrichedNatClosedStabilityInstance
```

Otherwise the Collatz file will try to redeclare names already imported from
the arithmetic file.

Do not use:

```text
Nat.mul_left_cancel
Nat.add_left_cancel
Nat.add_right_cancel
```

Those lemmas can pull forbidden dependencies in the audit path.  The direct
recursive proofs are the safe route.

## Order calibration on bare Nat indices

Prove:

```lean
natEnrichedDiagonalGapOrder_iff_peak_le
natEnrichedDiagonalGapOrder_iff_nat_le
natEnrichedDiagonalGapStrictOrder_iff_nat_lt
```

Meaning:

```text
Definitionally, the order is induced by Delta.
Extensionally, on bare Nat indices, it calibrates to <=.
Strictly, it calibrates to <.
```

This is not a dynamic bound.  It is a calibration theorem.

## Gap injectivity

Prove:

```lean
natEnrichedDiagonalGap_eq_iff
natEnrichedDiagonalGap_injective
```

Meaning:

```text
Delta does not identify two distinct bare Nat indices.
```

This belongs to arithmetic, not Collatz.

## Order structures

Expose:

```lean
natEnrichedDiagonalGapPreorder
natEnrichedDiagonalGapPartialOrder
natEnrichedDiagonalGapOrder_total
natEnrichedDiagonalGapTotalOrder
```

These structures are only for bare `Nat` indices.  They must not be used to
collapse operational intersections.

## Compatibility facades in Collatz

In `Meta/Collatz/DiagonalOrder.lean`, avoid duplicating the pure theory.
Replace the pure Collatz definitions by typed aliases:

```lean
abbrev collatzDiagonalGap
    (index : Nat) :
    Nat :=
  natEnrichedDiagonalGap index

abbrev CollatzDiagonalGapOrder
    (left right : Nat) :
    Prop :=
  NatEnrichedDiagonalGapOrder left right

abbrev CollatzDiagonalGapStrictOrder
    (left right : Nat) :
    Prop :=
  NatEnrichedDiagonalGapStrictOrder left right
```

Then keep Collatz-facing theorem names as compatibility facades, for example:

```lean
theorem collatzDiagonalGapOrder_iff_nat_le
    (left right : Nat) :
    CollatzDiagonalGapOrder left right <-> left <= right :=
  natEnrichedDiagonalGapOrder_iff_nat_le
```

This preserves public Collatz names while making the source of the pure theory
correct.

The Collatz file should not keep independent proofs of:

```lean
collatzDiagonalGapPreorder
collatzDiagonalGapPartialOrder
collatzDiagonalGapTotalOrder
collatzDiagonalGapOrder_antisymm
collatzDiagonalGapOrder_iff_nat_le
collatzDiagonalGapStrictOrder_iff_nat_lt
collatzDiagonalGap_eq_iff
```

Those must become aliases or direct wrappers around the arithmetic theorems.

If the public Collatz API should remain stable, keep wrappers for every current
public index-level Collatz name:

```lean
collatzDiagonalGap_eq_fibrewiseStructuralPeak
collatzDiagonalGap_eq_maximalRelaxedDivergence
collatzDiagonalGap_eq_double_add_two
collatzDiagonalGap_pos
collatzDiagonalGapOrder_refl
collatzDiagonalGapOrder_trans
collatzDiagonalGapOrder_antisymm
collatzDiagonalGapPreorder
collatzDiagonalGapPartialOrder
collatzDiagonalGapOrder_iff_peak_le
collatzDiagonalGapOrder_iff_nat_le
collatzDiagonalGap_eq_iff
collatzDiagonalGap_injective
collatzDiagonalGapOrder_total
collatzDiagonalGapTotalOrder
collatzDiagonalGapStrictOrder_iff_nat_lt
```

Each of these wrappers should be one line or a direct field alias to the
corresponding arithmetic theorem.

## Collatz-specific content that must remain in Collatz

Keep in `Meta/Collatz/DiagonalOrder.lean`:

```lean
collatzIntersectionDiagonalGap
CollatzIntersectionDiagonalGapOrder
collatzIntersectionDiagonalGap_eq_indexGap
collatzIntersectionDiagonalGapOrder_iff_formedPositiveExcess_le
collatzIntersectionDiagonalGapOrder_mutual_formedPositiveExcess_eq
collatzIntersectionDiagonalGap_eq_positiveWitness
collatzIntersectionDiagonalGap_pos
collatzIntersectionDiagonalGap_eq_countdownTerminalExcess
collatzIntersectionDiagonalGap_eq_dynamicClosureLoop_peak
collatzIntersectionDiagonalGap_consumed_as_terminal_excess
collatzIntersectionDiagonalGap_reenters_as_closing
```

Reason:

```text
these theorems mention Collatz operational intersections,
formedPositiveExcessOfIntersection from those intersections,
Collatz countdown consumers,
and the Collatz dynamic closure loop.
```

They are not pure arithmetic.

## Non-collapse rule for intersections

The Collatz file must continue to prove only:

```lean
mutual intersection comparison
-> same formedPositiveExcessOfIntersection
```

It must not prove:

```lean
left = right
```

from mutual comparison of intersections.

That would erase the enriched interface level.

## Imports to update

Update `Meta.lean`:

```lean
import Meta.Arithmetic.DiagonalOrder
import Meta.Collatz.DiagonalOrder
```

The arithmetic import should appear after `Meta.Arithmetic.Parity` and before
`Meta.Arithmetic.CountdownRelaxedParity` or any Collatz import that uses it.
This reflects the intended dependency direction:

```text
Parity
-> Arithmetic.DiagonalOrder
-> CountdownRelaxedParity / Collatz.DiagonalOrder
```

Update `Meta/Collatz/DiagonalOrder.lean` to import:

```lean
import Meta.Arithmetic.DiagonalOrder
import Meta.Collatz.DynamicClosureLoop
```

If `DynamicClosureLoop` already imports the necessary Collatz stack, do not add
more Collatz imports.

## Audit requirements

`Meta/Arithmetic/DiagonalOrder.lean` must end with exactly one audit block.

The audit must include at least:

```lean
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedDiagonalGapOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_add_self_eq_add_self_cancel
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_add_succ_self_le_cancel
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapOrder_antisymm
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapPreorder
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapPartialOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapOrder_iff_nat_le
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGap_eq_iff
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGap_injective
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapOrder_total
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapTotalOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedDiagonalGapStrictOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedDiagonalGapStrictOrder_iff_nat_lt
```

`Meta/Collatz/DiagonalOrder.lean` must keep exactly one audit block and audit
only:

```text
1. Collatz-facing compatibility aliases/wrappers;
2. intersection-specific theorems.
```

It must no longer audit arithmetic-owned helper proofs as Collatz content.

`Meta.lean` must update its audit to include the new arithmetic declarations
and the Collatz declarations that remain central.

## Validation commands

Run:

```text
lake build Meta.Arithmetic.DiagonalOrder
lake build Meta.Collatz.DiagonalOrder
lake env lean Meta.lean
```

All audits must report:

```text
does not depend on any axioms
```

There must be no mention of:

```text
Classical
propext
Quot.sound
sorryAx
```

## Acceptance criteria

The extraction is complete only if:

1. the pure index order lives in `Meta/Arithmetic/DiagonalOrder.lean`;
2. `Meta/Collatz/DiagonalOrder.lean` no longer owns the pure Nat theory;
3. Collatz still exposes its public names as typed facades;
4. the intersection order still calibrates through formed positive excess;
5. mutual comparison of intersections still contracts only to same formed
   positive excess, not equality of intersections;
6. the cancellation helpers have only one owner;
7. all Lean audits are constructive and axiom-free.
