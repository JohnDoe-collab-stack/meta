# Implementation plan: positive diagonal witness and Collatz

## Objective

Formalize the fact that the Collatz layer should not merely consume an indexed
diagonal parity package.  It should also be able to consume the positive
diagonal witness already present in the enriched Nat trajectory layer.

The target statement is structural:

```text
finite trajectory height witness
-> positive diagonal witness
-> indexed diagonal parity of enriched Nat
-> Collatz operational diagonal step
```

This must not be formulated as a downstream Collatz convergence theorem.  The
point is to expose how the internal geometry of `n` is indexed, diagonalized,
and then read by the Collatz action.

## Existing formal sources

The positive witness already exists in:

```text
Meta/Arithmetic/HeightDiagonal.lean
```

Main objects:

```text
NatTrajectoryFinitePrefixHeightCertificate
NatTrajectoryPositiveDiagonalHeightWitness
natTrajectoryPositiveDiagonalHeightWitness
NatTrajectoryFinitePrefixHeightWithPositiveDiagonalWitness
NatTrajectoryPostPeakClosedStabilityHeightPackage
```

The witness carries:

```text
support = cert.height
peakTime = cert.peakTime
peak realizes support
diagonalBranch = canonicalBranch support
diagonalIntersection = canonicalIntersection support
positiveWitness = formedPositiveExcessOfIntersection diagonalIntersection
positiveWitness_pos : 0 < positiveWitness
```

The indexed diagonal parity now exists in:

```text
Meta/Arithmetic/Parity.lean
```

Main object:

```text
ArithmeticIndexedDiagonalParity
arithmeticIndexedDiagonalParityOfIntersection
```

It carries:

```text
diagonalCertificateOfIntersection
terminalTime
formedExcess = terminalTime + 1
closingRole
mediatingRole
same projection
separation
local repair
```

The Collatz consumer now exists in:

```text
Meta/Collatz/OperationalParity.lean
```

Main object:

```text
CollatzOperationalDiagonalStep
collatzOperationalDiagonalStepOfIntersection
```

It consumes:

```text
ArithmeticIndexedDiagonalParity
```

and adds:

```text
closingPayload = terminalTime + 1
shadowReturnRole = closingExcess (3 * (terminalTime + 1) + 2)
```

## Required arithmetic raccord

The next implementation should happen inside existing files only.

No new Lean file should be created.

After rereading the imports, the first raccord must belong in:

```text
Meta/Arithmetic/Parity.lean
```

It must not be placed in:

```text
Meta/Arithmetic/HeightDiagonal.lean
```

Reason:

```text
HeightDiagonal.lean
-> Window
-> Trajectory / RepeatedIndex
-> arithmetic closure sources

Parity.lean
-> TwoPole
-> GapContraction
-> DynamicGap
-> HeightDiagonal
```

So `Parity.lean` is already above `HeightDiagonal.lean` in the import graph.
Putting parity-indexed data back into `HeightDiagonal.lean` would mix levels
and risk an import cycle.  The correct rule is:

```text
HeightDiagonal.lean creates the positive witness.
Parity.lean connects that witness to indexed diagonal parity.
Collatz consumes the parity-level connection.
```

The direct but wrong implementation would be:

```text
positiveDiagonal.diagonalIntersection
-> arithmeticIndexedDiagonalParityOfIntersection
```

This is too weak for Collatz.  The reason is formal:

```text
positiveDiagonal.diagonalIntersection = canonicalIntersection support
formedPositiveExcessOfIntersection (canonicalIntersection support) = 1
```

So the positive diagonal witness proves that a positive diagonal exists at the
realized support, but its own canonical intersection is not the terminal
trajectory intersection that carries the later `n+2` countdown excess.

The required arithmetic structure should therefore connect three pieces, not
two:

```text
positive height witness
+ post-peak window
+ repeated-index/window intersection
```

Suggested name:

```text
ArithmeticPositiveWindowIndexedDiagonalParity
```

for:

```text
cert : NatTrajectoryFinitePrefixHeightCertificate step start
window : NatTrajectoryPostPeakWindow cert
```

It should carry:

```text
positiveDiagonal : NatTrajectoryPositiveDiagonalHeightWitness cert
positiveWitness_pos : 0 < positiveDiagonal.positiveWitness

boundedWindow :
  NatTrajectoryBoundedWindow step start cert.peakTime cert.height

boundedWindow_eq :
  boundedWindow = boundedWindow_of_postPeakWindow window

windowCollision :
  NatTrajectoryWindowCollision step start cert.peakTime (cert.height + 2)

windowCollision_eq :
  windowCollision = windowCollision_of_boundedWindow boundedWindow

trajectoryCollision :
  NatTrajectoryRepeatedIndexCollision step start

trajectoryCollision_eq :
  trajectoryCollision = trajectoryCollision_of_windowCollision windowCollision

repeatedIndexCollision :
  RepeatedIndexCollision

repeatedIndexCollision_eq :
  repeatedIndexCollision =
    repeatedIndexCollision_of_trajectoryCollision trajectoryCollision

terminalIntersection :
  PrimitiveMemoryReadingIntersection
    (repeatedIndexBranch repeatedIndexCollision)

terminalIntersection_eq :
  terminalIntersection = repeatedIndexIntersection repeatedIndexCollision

indexedParity :
  ArithmeticIndexedDiagonalParity terminalIntersection

indexedParity.diagonal =
  diagonalCertificateOfIntersection terminalIntersection
```

The key point is not:

```text
positiveWitness = indexedParity.formedExcess
```

That equality is generally false for the current height witness, because the
positive witness is canonical and the indexed parity must be read on the
terminal/window intersection.

The key point is instead:

```text
positiveDiagonal.support
controls the post-peak window length
which produces the repeated-index intersection
which carries the indexed diagonal parity consumed by Collatz
```

This is what connects the positive diagonal witness to the indexed diagonal
parity without pretending that both live on the same intersection.

Expected constructor:

```text
arithmeticPositiveWindowIndexedDiagonalParityOfPostPeakWindow
```

Expected theorems:

```text
arithmeticPositiveWindowIndexedDiagonalParity_carries_positiveWitness
arithmeticPositiveWindowIndexedDiagonalParity_carries_boundedWindow
arithmeticPositiveWindowIndexedDiagonalParity_carries_windowCollision
arithmeticPositiveWindowIndexedDiagonalParity_carries_indexedParity
arithmeticPositiveWindowIndexedDiagonalParity_terminalParity_carries_diagonal
```

Lean feasibility notes:

```text
boundedWindow
  := boundedWindow_of_postPeakWindow window

windowCollision
  := windowCollision_of_boundedWindow boundedWindow

trajectoryCollision
  := trajectoryCollision_of_windowCollision windowCollision

repeatedIndexCollision
  := repeatedIndexCollision_of_trajectoryCollision trajectoryCollision

terminalIntersection
  := repeatedIndexIntersection repeatedIndexCollision

indexedParity
  := arithmeticIndexedDiagonalParityOfIntersection terminalIntersection
```

With these definitions, the structural equalities above should be definitional
equalities in the canonical constructor.  The implementation should therefore
prefer exact definitional witnesses over propositional reconstruction.

The generic arithmetic package should expose terminal facts only in the form:

```text
terminalTimeOfIntersection terminalIntersection =
  cert.peakTime + windowCollision.rightOffset

formedPositiveExcessOfIntersection terminalIntersection =
  cert.peakTime + windowCollision.rightOffset + 1
```

using the already existing theorems:

```text
windowCollision_terminalTime_eq
windowCollision_terminalExcess_eq
```

It must not introduce a stronger numerical claim unless the collision itself
is specialized.

## Required Collatz raccord

The Collatz specialization belongs in:

```text
Meta/Collatz/OperationalParity.lean
```

It should not recreate the positive witness.

It should consume the arithmetic package:

```text
ArithmeticPositiveWindowIndexedDiagonalParity
```

and produce a Collatz package:

```text
CollatzPositiveOperationalDiagonalStep
```

carrying:

```text
positiveIndexedParity
collatzStep :
  CollatzOperationalDiagonalStep
    positiveIndexedParity.terminalIntersection
collatzStep.arithmeticIndexedParity =
  positiveIndexedParity.indexedParity
collatzStep.closingPayload =
  positiveIndexedParity.indexedParity.formedExcess
collatzStep.shadowReturnRole =
  closingExcess
    (3 * positiveIndexedParity.indexedParity.formedExcess + 2)
```

This is the precise Collatz-specific statement:

```text
Collatz creates its own operational diagonal from the positive indexed
diagonal witness through the terminal/window indexed parity, and this diagonal
is limited by the index carried by that terminal parity.
```

## Countdown specialization

There are two countdown paths, and the implementation must not confuse them.

### Generic post-peak path

The generic post-peak path specializes:

```text
Meta/Collatz/Countdown.lean
```

```text
countdownPrefixHeightCertificate n
-> countdownPrefixHeightWithPositiveDiagonalWitness n
-> countdownPostPeakWindow n
-> arithmeticPositiveWindowIndexedDiagonalParityOfPostPeakWindow
     (countdownPostPeakWindow n)
-> CollatzPositiveOperationalDiagonalStep
```

This path should only claim the generic facts supplied by the bounded-window
pipeline.  It must not claim:

```text
terminalTime = n + 1
terminal formedExcess = n + 2
```

unless an additional theorem proves that the constructed pigeonhole collision
is the explicit terminal collision.

Expected generic countdown declaration:

```text
countdownPostPeakPositiveWindowIndexedDiagonalParity
```

This declaration should be a direct specialization of:

```text
arithmeticPositiveWindowIndexedDiagonalParityOfPostPeakWindow
```

at:

```text
countdownPostPeakWindow n
```

### Explicit terminal path

The explicit countdown path specializes the existing terminal collision:

```text
countdownPrefixHeightWithPositiveDiagonalWitness n
+ countdownTerminalWindowCollision n
-> countdownTerminalIntersection n
-> arithmeticIndexedDiagonalParityOfIntersection
     (countdownTerminalIntersection n)
-> CollatzOperationalDiagonalStep
     (countdownTerminalIntersection n)
```

This path is the one that may prove:

```text
support = n
positiveWitness = 1
terminalTime = n + 1
terminal formedExcess = n + 2
shadowReturnRole = closingExcess (3 * (n + 2) + 2)
```

This path should use the already existing countdown facts:

```text
countdownTerminalIntersection_terminalTime_eq
countdownArithmeticGapTerminalExcess_eq_terminalTime_succ
countdownArithmeticGapTerminalExcess_eq_n_plus_two
collatzCountdownClosingPayload_eq_terminalTime_succ
collatzCountdownShadowReturnRole_eq_terminalTime_succ
collatzCountdownClosingPayload_eq_n_plus_two
collatzCountdownShadowReturnRole_eq_n_plus_two
```

It should not route the `n+2` claim through
`windowCollision_of_boundedWindow (boundedWindow_of_postPeakWindow ...)`
unless a separate theorem identifies that constructed collision with
`countdownTerminalWindowCollision n`.

Expected explicit countdown declaration:

```text
CountdownPositiveTerminalCollatzDiagonalStep
```

It should carry:

```text
heightWithWitness :
  NatTrajectoryFinitePrefixHeightWithPositiveDiagonalWitness countdownStep n

heightWithWitness_eq :
  heightWithWitness = countdownPrefixHeightWithPositiveDiagonalWitness n

terminalIntersection :
  PrimitiveMemoryReadingIntersection
    (repeatedIndexBranch
      (repeatedIndexCollision_of_trajectoryCollision
        (trajectoryCollision_of_windowCollision
          (countdownTerminalWindowCollision n))))

terminalIntersection_eq :
  terminalIntersection = countdownTerminalIntersection n

terminalIndexedParity :
  ArithmeticIndexedDiagonalParity terminalIntersection

terminalIndexedParity_eq :
  terminalIndexedParity =
    arithmeticIndexedDiagonalParityOfIntersection terminalIntersection

collatzStep :
  CollatzOperationalDiagonalStep terminalIntersection

collatzStep_eq :
  collatzStep = collatzOperationalDiagonalStepOfIntersection terminalIntersection

positiveWitness_eq_one :
  heightWithWitness.positiveDiagonal.positiveWitness = 1

terminalFormedExcess_eq_n_plus_two :
  formedPositiveExcessOfIntersection terminalIntersection = n + 2

shadowReturnRole_eq_n_plus_two :
  collatzStep.shadowReturnRole =
    NatEnrichedParityRole.closingExcess (3 * (n + 2) + 2)
```

Important distinction:

```text
countdownPrefixHeightCertificate n
```

has positive witness:

```text
formedPositiveExcessOfIntersection (canonicalIntersection n) = 1
```

while the terminal countdown intersection used by the explicit terminal
collision has:

```text
terminalTime = n + 1
formedExcess = n + 2
```

The plan must not collapse these two witnesses.  They are related but they are
not the same intersection.  The relation is mediated by the post-peak window
and the repeated-index collision, not by equality of the two formed excesses.

The countdown layer must remain a specialization, not the source of the
concept.

## Validation criteria

The implementation is acceptable only if:

```text
1. No new Lean file is created.
2. The positive witness remains sourced in HeightDiagonal.
3. Arithmetic/Parity carries the positive-window indexed diagonal raccord before Collatz.
4. Collatz consumes the arithmetic raccord instead of recreating it.
5. The generic post-peak countdown path does not claim terminal `n+2` facts.
6. The explicit terminal countdown path is the only path claiming
   `terminalTime = n+1` and `formedExcess = n+2`.
7. All new Lean declarations have AXIOM_AUDIT entries.
8. lake build Meta passes.
9. The touched files contain no Classical, propext, Quot.sound, or axiom.
```

Expected touched Lean files, if implemented:

```text
Meta/Arithmetic/Parity.lean
Meta/Collatz/OperationalParity.lean
Meta/Collatz/Countdown.lean
```

No change should be required in:

```text
Meta/Arithmetic/HeightDiagonal.lean
```

unless a purely local helper about the existing positive witness is needed.
Such a helper must not import parity-level material back into HeightDiagonal.

## Conceptual summary

The intended theorem is not:

```text
Collatz proves convergence downstream.
```

It is:

```text
The positive diagonal witness of enriched Nat controls a post-peak window;
that window produces a repeated-index terminal intersection carrying indexed
diagonal parity; Collatz builds its own operational diagonal by acting on that
terminal indexed parity.
```
