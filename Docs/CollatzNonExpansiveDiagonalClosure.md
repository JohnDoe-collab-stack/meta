# Collatz non-expansive diagonal closure

## Object

This document records the exact reading of the dynamic diagonal-order layer in
`Meta/Collatz/DiagonalOrder.lean`.

The important point is:

```text
the dynamic closure is not a strict descent,
and it is not a strict ascent.
```

It is a non-expansive closure by exact conservation of the diagonal witness.

Precision:

```text
non-expansive here means non-expansive at the level of the activated diagonal
witness.
```

It does not mean:

```text
the visible Collatz orbit is non-expansive.
```

## Formal shape

For a Collatz operational intersection:

```lean
intersection : PrimitiveMemoryReadingIntersection branch
```

the file defines:

```lean
CollatzDynamicClosureOrder intersection
```

as:

```lean
collatzIntersectionDiagonalGap intersection <=
  formedPositiveExcessOfIntersection
    (collatzDynamicClosureLoop intersection).consumer
```

The proof is:

```lean
rw [collatzIntersectionDiagonalGap_consumed_as_terminal_excess intersection]
exact Nat.le_refl _
```

So the order is carried by equality:

```text
source diagonal gap
=
terminal excess of the canonical consumer
```

not by strict growth.

## Package reading

The package:

```lean
CollatzDynamicOrderedClosure intersection
```

records:

```text
sourceGap = collatzIntersectionDiagonalGap intersection
sourceGap = loop.peak
consumerGap = formedPositiveExcessOfIntersection loop.consumer
sourceGap = consumerGap
sourceGap <= consumerGap
consumer reenters as closingExcess sourceGap
```

The compressed chain is:

```text
Delta(intersection)
=
loop.peak
=
terminal excess of the consumer
-> closingExcess(Delta(intersection))
```

## Correct interpretation

This is not:

```text
Collatz decreases at every visible step.
```

It is not:

```text
the diagonal witness strictly increases through the consumer.
```

It is:

```text
the diagonal witness activated by the intersection is transported exactly,
consumed as terminal excess, and reinserted as a closing/forming role.
```

So the closure is non-expansive:

```text
sourceGap = consumerGap
```

and therefore:

```text
sourceGap <= consumerGap
```

## Why this matters for Collatz

The visible Collatz dynamics can increase.

Therefore a direct visible descent proof is not the right object at this level.

The diagonal-order layer shifts the question:

```text
is the produced divergence left naked,
or is it caught by an internal consumption/reinsertion loop?
```

The current formal layer proves the second statement for the activated
diagonal witness:

```text
the witness is conserved exactly,
consumed by the canonical countdown consumer,
and reinserted as closingExcess.
```

This is why the result is structurally important for the closure of the
Collatz problem inside the Meta framework.

It does not yet prove:

```text
every visible orbit reaches 1.
```

It proves, at the local witness level:

```text
the activated diagonal witness is not an uncontrolled growth value.
```

More precisely, the activated witness is not left bare inside this layer.  It
is internalized as:

```text
gap
-> peak
-> terminal excess
-> closingExcess
```

## Guiding phrase

```text
The activated Collatz divergence is not handled here by visible descent.
It is handled at witness level by exact conservation and closing reinsertion.
```
