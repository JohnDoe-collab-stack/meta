# Collatz diagonal dynamic order plan

## Object

This document fixes how to extend `Meta/Collatz/DiagonalOrder.lean` with the
dynamic order already carried by the Collatz layer.

The current file has:

```text
1. index-level diagonal order, delegated to `Meta.Arithmetic.DiagonalOrder`;
2. intersection-level diagonal order, induced by `formedPositiveExcess`.
```

What is still missing is not the dynamic loop itself.  The loop already exists
in:

```lean
Meta.Collatz.DynamicClosureLoop
```

What is missing is the ordered reading of that loop inside
`Meta/Collatz/DiagonalOrder.lean`.

Precision:

```text
this is not a new global binary order on Collatz intersections.
```

It is a canonical ordered-closure predicate attached to one intersection:

```text
source intersection gap
<=
terminal excess of its canonical consumer
```

The existing binary order on intersections remains:

```lean
CollatzIntersectionDiagonalGapOrder
```

The new layer only reads the dynamic closure loop through the order already
defined on diagonal values.

## Existing dynamic data

For every Collatz operational intersection:

```lean
intersection : PrimitiveMemoryReadingIntersection branch
```

we already have:

```lean
collatzDynamicClosureLoop intersection
```

with fields:

```lean
formedIndex
positiveWitness
peak
consumer
consumed_as_terminal_excess
reenters_as_closing
```

The important equalities already proved are:

```lean
collatzIntersectionDiagonalGap_eq_positiveWitness
collatzIntersectionDiagonalGap_eq_countdownTerminalExcess
collatzIntersectionDiagonalGap_eq_dynamicClosureLoop_peak
collatzIntersectionDiagonalGap_consumed_as_terminal_excess
collatzIntersectionDiagonalGap_reenters_as_closing
```

Therefore the dynamic content is present.  It is just not yet packaged as an
ordered closure statement in the diagonal-order file.

## What must not be claimed

Do not claim:

```lean
collatzStep n < n
```

Do not claim:

```lean
Delta (collatzStep n) < Delta n
```

Do not claim a global Collatz bound or orbit termination.

Reason:

```text
on bare Nat indices, Delta-order calibrates to the usual Nat order;
Collatz may visibly increase;
therefore strict decrease cannot be a one-step visible-index theorem.
```

The dynamic order must be carried by the enriched structure:

```text
intersection
-> positive witness
-> peak
-> consumer
-> terminal excess
-> closingExcess reentry
```

## Predicate to define

Add a section in `Meta/Collatz/DiagonalOrder.lean` after the existing
intersection gap/consumption/reentry theorems:

```lean
/-! ## Dynamic order carried by the closure loop -/
```

Define:

```lean
def CollatzDynamicClosureOrder
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Prop :=
  collatzIntersectionDiagonalGap intersection <=
    formedPositiveExcessOfIntersection
      (collatzDynamicClosureLoop intersection).consumer
```

This says:

```text
the source diagonal gap is ordered against the terminal excess of its canonical
consumer.
```

This is not a strict descent.  It is not a binary order on all intersections.
It is the dynamic comparability predicate attached to the canonical loop of
one intersection.

Important:

```text
do not define this as

CollatzIntersectionDiagonalGapOrder intersection consumer

because that would compare the source gap to the consumer's full diagonal gap.
The loop gives equality between the source gap and the consumer terminal
excess, not automatically equality with the consumer's own next diagonal gap.
```

## Central theorem

Prove the canonical instance:

```lean
theorem collatzDynamicClosureOrder_of_intersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzDynamicClosureOrder intersection
```

Expected proof:

```lean
unfold CollatzDynamicClosureOrder
rw [collatzIntersectionDiagonalGap_consumed_as_terminal_excess intersection]
exact Nat.le_refl _
```

Meaning:

```text
the diagonal gap of the intersection is exactly the formed positive excess of
the loop consumer, hence the source is dynamically comparable to its consumer.
```

The theorem is deliberately unary:

```text
for this intersection, its canonical loop carries an ordered closure.
```

It does not say:

```text
for any two Collatz intersections, the first is dynamically below the second.
```

## Stronger equality package

Define a structure:

```lean
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
```

Then define:

```lean
def collatzDynamicOrderedClosure
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzDynamicOrderedClosure intersection
```

Expected constructor:

```lean
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
```

This structure packages:

```text
the loop,
the source diagonal gap,
the equality between the source gap and the loop peak,
the consumer terminal excess,
their equality,
the induced order,
the closingExcess reentry.
```

## Useful projections

Expose:

```lean
theorem collatzDynamicOrderedClosure_sourceGap_eq_consumerGap
theorem collatzDynamicOrderedClosure_sourceGap_eq_peak
theorem collatzDynamicOrderedClosure_ordered
theorem collatzDynamicOrderedClosure_reenters_as_closing
```

These make the dynamic order auditable without destructuring the package.

## Optional reverse comparability

Because the source gap equals the consumer terminal excess, one can also expose
the reverse comparison at the same terminal-excess level:

```lean
def CollatzDynamicClosureEquivalentOrder
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Prop :=
  collatzIntersectionDiagonalGap intersection <=
    formedPositiveExcessOfIntersection
      (collatzDynamicClosureLoop intersection).consumer
  /\
  formedPositiveExcessOfIntersection
      (collatzDynamicClosureLoop intersection).consumer <=
    collatzIntersectionDiagonalGap intersection
```

This is equivalent order at the consumed terminal-excess level.

Do not confuse it with:

```lean
CollatzIntersectionDiagonalGapOrder consumer intersection
```

which compares the consumer's full diagonal gap to the source gap.

Important:

```text
if implemented, call it terminal-excess equivalence, not intersection diagonal
gap equivalence.
```

If in doubt, implement only the forward ordered closure package.

## Why this belongs in `DiagonalOrder.lean`

The dynamic loop itself belongs in:

```lean
Meta.Collatz.DynamicClosureLoop
```

But the ordered reading of that loop belongs in:

```lean
Meta.Collatz.DiagonalOrder
```

because it uses:

```text
collatzIntersectionDiagonalGap
formedPositiveExcessOfIntersection
collatzDynamicClosureLoop
```

This keeps the architecture:

```text
DynamicClosureLoop
= produces the loop

DiagonalOrder
= reads the loop through the diagonal order
```

## Audit additions

Add the following declarations to the audit of
`Meta/Collatz/DiagonalOrder.lean`:

```lean
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzDynamicClosureOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicClosureOrder_of_intersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzDynamicOrderedClosure
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicOrderedClosure
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicOrderedClosure_sourceGap_eq_consumerGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicOrderedClosure_sourceGap_eq_peak
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicOrderedClosure_ordered
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzDynamicOrderedClosure_reenters_as_closing
```

## Validation

Run:

```text
lake build Meta.Collatz.DiagonalOrder
lake env lean Meta.lean
```

The audit must show:

```text
does not depend on any axioms
```

and must not mention:

```text
Classical
propext
Quot.sound
sorryAx
```

## Expected result

After implementation, the file will contain three layers:

```text
1. Collatz-facing aliases for pure enriched Nat diagonal order;
2. intersection-level diagonal order;
3. dynamic ordered closure of an intersection through its consumer.
```

This will still not prove orbit termination.

It will prove that the existing Collatz dynamic closure loop has an ordered
reading in the diagonal order layer:

```text
intersection gap
= consumer terminal excess
-> ordered closure
-> closingExcess reentry
```

It will not prove:

```text
source intersection diagonal gap <= consumer intersection diagonal gap
```

unless an additional theorem relates the consumer's own diagonal gap to its
terminal excess in the required direction.
