# Presentation of the Gap Operator

## Introduction

This document presents the gap operator as a formal structure of mediation
between referentials. The starting point is not equality between two poles, nor
the failure of an identification, but the constructive passage that relates a
projected visible object to a formed interface.

In the dynamic reading, this mediation is produced by a return. An observable
coincidence is not contracted into a bare equality: it is formed as a dynamic
source, typed intersection, formed interface, operational gap, and then
recovered closed stability. This passage from observed return to formed
closure gives the framework its dynamic content.

The presentation notation:

```text
1 + gap + 1
```

denotes this explicit mediation. It should not be read as an arithmetic of
lengths, but as a decomposition of roles: a visible pole, a typable mediation,
and a formed pole. Equality, or the short presentation, then corresponds to a
contracted case of this mediation.

The Lean core formalizes this reading through `LocalProjectiveRecovery` and
through the abstract dynamic scheme `FormedDynamicReturn` /
`LocallyRecoveredDynamicReturn`. The following sections specify these
definitions, the derived operations they support, and their readings in the
Tarski, Beth, Bell, Tsirelson, enriched arithmetic, and arithmetic dynamic
layers.

From this perspective, the Tarski case is not taken as the starting point: it
appears as a particular diagonal case of a more general mediation scheme.

## Formal Status

The gap operator is formalized in the abstract Lean core under the technical
name:

```lean
LocalProjectiveRecovery
```

Reference Lean files:

```text
Meta/Core/ClosedStabilityTheorem.lean
Meta/Core/DynamicStability.lean
```

Central Lean declaration:

```lean
structure LocalProjectiveRecovery
    (Interface : Type x)
    (Visible : Type y)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max x y s) where
  formed : Interface
  shadow : Interface
  sameProjection : project formed = project shadow
  separated : formed = shadow -> False
  repair : RepairOf formed
  recovered : Interface
  recovered_eq_formed : recovered = formed
```

The name `gap operator` is the presentation name of this structure in the
framework:

```text
1 + gap + 1
```

Thus it is not an object absent from the code. It is the conceptual reading of
`LocalProjectiveRecovery`.

The abstract dynamic reading is formalized by:

```lean
FormedDynamicReturn
LocallyRecoveredDynamicReturn
locallyRecoveredClosedStabilityOfDynamicReturn
```

It encodes the passage:

```text
dynamic source
-> typed intersection
-> formed interface
-> local recovery
-> recovered closed stability
```

The observed layers instantiate this scheme through:

```lean
observedFormedDynamicReturn
observedLocallyRecoveredDynamicReturn
observedDynamicClosedStabilityRow
observedBoundedWindowFormedDynamicReturn
observedBoundedWindowLocallyRecoveredDynamicReturn
observedBoundedWindowDynamicClosedStabilityRow
```

## Mathematical Definition

Let:

```text
I : type of enriched interfaces
V : type of visible objects
p : I -> V
R : I -> Type
```

A local gap operator above `p` is a tuple:

```text
G = (f, s, h, sep, r, rec, eta)
```

with:

```text
f   : I
s   : I
h   : p(f) = p(s)
sep : f = s -> False
r   : R(f)
rec : I
eta : rec = f
```

Lean correspondence:

```text
f   = formed
s   = shadow
h   = sameProjection
sep = separated
r   = repair
rec = recovered
eta = recovered_eq_formed
```

So the code directly encodes:

```text
formed interface
+ visible shadow
+ same projection
+ enriched separation
+ local repair
+ recovery of the formed interface
```

## Structural Reading

The gap carries the constructive mediation between referentials.

The framework does not start from equality as the primary norm. It starts from
a formed passage:

```text
 visible referential
+ typable mediation
+ formed referential
```

In this passage, equality is a particular case: the case where the mediation
contracts. The short presentation is therefore not the starting point of the
framework; it is a derived regime, obtained when the visible fiber is faithful.

The gap operator gives the mediation a positive form:

```text
formed
+ shared projection
+ enriched separation
+ local repair
+ recovery of the formed interface
```

Non-contractibility statements do not define the gap. They appear only when
this mediation is tested against a short reading.

In the dynamic layer, this reading becomes a construction of stability: a
return to the same observable is not contracted into a bare equality, but
formed as a repeated collision, an intersection, an enriched trace, and a local
recovery.

Dynamic stability therefore comes from the formation of the return. The visible
coincidence supplies the entry point; the typed intersection and local recovery
carry the closure.

## Derived Operations

From `LocalProjectiveRecovery`, the code extracts several projective
operations.

### Extraction of a Projective Obstruction

Declaration:

```lean
localProjectiveRecovery_obstruction
```

Conceptual statement:

```text
LocalProjectiveRecovery I V p R
-> ProjectionObstruction I V p
```

The field `formed` becomes the left side of the obstruction, `shadow` becomes
the right side, `sameProjection` gives the visible coincidence, and `separated`
gives the enriched separation.

### Fiber Contraction Test

Declaration:

```lean
localProjectiveRecovery_notFiberFaithful
```

Conceptual statement:

```text
LocalProjectiveRecovery I V p R
-> ProjectionFiberFaithful I V p
-> False
```

Thus, if one attempts to contract the mediation into a short presentation, the
operational gap refutes:

```text
same visible -> same interface
```

### Global Projective Reconstruction Test

Declaration:

```lean
noProjectiveReconstructionOfLocalProjectiveRecovery
```

Conceptual statement:

```text
LocalProjectiveRecovery I V p R
-> no recover : V -> I uniformly reconstructs all interfaces
```

### Consumption by the Abstract Theorem

Declaration:

```lean
locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem
```

This theorem explicitly takes as input:

```lean
(localRecovery :
  LocalProjectiveRecovery Interface Visible project RepairOf)
```

Then it extracts:

```lean
localProjectiveRecovery_obstruction localRecovery
recoveryBundleOfLocalProjectiveRecovery localRecovery
terminalProjectionOfLocalProjectiveRecovery localRecovery
```

Thus the gap operator has an operational role: it is consumed by the abstract
theorem as formed mediation, repair, and terminal projection.

## Lean Reference Table

| Role | Lean declaration | File |
|---|---|---|
| Formal definition of the gap operator | `LocalProjectiveRecovery` | [ClosedStabilityTheorem.lean](Meta/Core/ClosedStabilityTheorem.lean) |
| Extracted obstruction | `localProjectiveRecovery_obstruction` | [ClosedStabilityTheorem.lean](Meta/Core/ClosedStabilityTheorem.lean) |
| Refutation of faithfulness | `localProjectiveRecovery_notFiberFaithful` | [ClosedStabilityTheorem.lean](Meta/Core/ClosedStabilityTheorem.lean) |
| Refutation of global reconstruction | `noProjectiveReconstructionOfLocalProjectiveRecovery` | [ClosedStabilityTheorem.lean](Meta/Core/ClosedStabilityTheorem.lean) |
| Consumption by the abstract theorem | `locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem` | [ClosedStabilityTheorem.lean](Meta/Core/ClosedStabilityTheorem.lean) |
| Formed dynamic return | `FormedDynamicReturn` | [DynamicStability.lean](Meta/Core/DynamicStability.lean) |
| Locally recovered dynamic return | `LocallyRecoveredDynamicReturn` | [DynamicStability.lean](Meta/Core/DynamicStability.lean) |
| Stability from dynamic return | `locallyRecoveredClosedStabilityOfDynamicReturn` | [DynamicStability.lean](Meta/Core/DynamicStability.lean) |
| Short regime | `ShortReferentialPresentation` | [ReferentialLength.lean](Meta/Core/ReferentialLength.lean) |
| Structural gap | `EnrichedStructuralReferentialLength` | [ReferentialLength.lean](Meta/Core/ReferentialLength.lean) |
| Operational gap | `EnrichedOperationalReferentialLength` | [ReferentialLength.lean](Meta/Core/ReferentialLength.lean) |

## Constructive Audit

The file [ClosedStabilityTheorem.lean](Meta/Core/ClosedStabilityTheorem.lean)
contains an `AXIOM_AUDIT` block at the end of the file. This block audits in
particular:

```lean
#print axioms Meta.ClosedStabilityTheorem.LocalProjectiveRecovery
#print axioms Meta.ClosedStabilityTheorem.localProjectiveRecovery_obstruction
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstructionOfLocalProjectiveRecovery
#print axioms Meta.ClosedStabilityTheorem.localProjectiveRecovery_notFiberFaithful
#print axioms Meta.ClosedStabilityTheorem.localProjectiveRecovery_notInformationConserving
#print axioms Meta.ClosedStabilityTheorem.locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem
```

The expected validation is:

```text
does not depend on any axioms
```

for each of these declarations.

## Central Idea

The operator gives an explicit form to the passage between referentials:

```text
1 + gap + 1 >= 2
```

The short presentation is the contracted case:

```text
1 + 1 <= 2
```

This is not about adding a number between two numbers. It is about making the
constructive mediation explicit, where it becomes:

```text
typable
indexable
transportable
refutable by contraction
locally repairable
```

The operator gives the gap a constructive use: the separation becomes a formed
datum, indexed by `formed`, carrying its own repair and consumable by the
stability theorems. Failures of contraction are consequences of this structure,
not its starting point.

The general form is:

```text
left visible
+ referential gap
+ right formed interface
```

or equivalently:

```text
visible projection
+ enriched separation
+ local recovery
```

## Abstract Form

In its strict projective form, the operator works around a projection:

```lean
project : Interface -> Visible
```

The short presentation corresponds to the case where the visible object
determines the interface:

```lean
ProjectionFiberFaithful
```

Reading:

```text
same visible
-> same enriched interface
```

In the transverse vocabulary:

```lean
ShortReferentialPresentation
```

The structural gap appears when two separated interfaces share the same visible
object:

```lean
ProjectionObstruction
StructuralReferentialGap
EnrichedStructuralReferentialLength
```

Reading:

```text
same visible
+ separated enriched interfaces
```

The operational gap appears when this obstruction also carries a local repair
attached to the formed interface:

```lean
LocalProjectiveRecovery
OperationalReferentialGap
EnrichedOperationalReferentialLength
```

Reading:

```text
obstruction
+ formed interface
+ visible shadow
+ indexed local recovery
```

This structure is the formal gap operator.

The transverse theorems provide the discipline:

```lean
structuralLength_refutes_shortPresentation
operationalLength_refutes_shortPresentation
structuralLengthOfOperationalLength
```

Thus the gap operator can be read as:

```text
Gap(project)
=
status of the visible fiber of project
```

This line is a transverse reading. In the code, there is no single declaration
`Gap(project)`: the status is distributed among `ProjectionFiberFaithful`,
`ProjectionObstruction`, and `LocalProjectiveRecovery`, then named by the
regimes of `ReferentialLength`.

with three regimes:

```text
contractible gap : the visible fiber is faithful
structural gap   : the visible fiber contains a separation
operational gap  : the separation carries a local recovery
```

## What the Operator Does

The gap operator gives explicit form to a passage:

```text
A + gap + B
```

The compressed relation is the case where this mediation is contracted:

```text
A -> B
```

It exposes the seven data of `LocalProjectiveRecovery`:

```text
1. formed
2. shadow
3. sameProjection
4. separated
5. repair
6. recovered
7. recovered_eq_formed
```

In the projective, arithmetic, and dynamic layers, this appears through the
same pattern:

```text
formed side
shadow side
sameVisible
separated
localRecovery
```

The projection preserves the visible payload. The formed side preserves the
enriched role. The gap is the operator that makes this passage explicit and
usable: it does not remain an external obstruction, it carries the local repair
of the formed interface.

## Reading `1 + gap + 1`

The formula should be read by roles:

```text
left 1
= visible pole, code, context, state, occurrence, source

gap
= mediation contracted by the short presentation

right 1
= formed pole, assertion, co-indexation, return, closure, bound
```

The first `1` and the second `1` do not always have the same role. The point of
the framework is precisely that the gap carries their constructive mediation.
The visible projection may then contract this mediation into a short reading,
but this contraction is only a particular regime.

## Tarski

Short presentation:

```text
True(code(phi)) <-> phi
```

Reading through the operator:

```text
syntactic code
+ diagonal gap
+ semantic assertion
```

The diagonal gap appears when projected syntax is not sufficient to contract
the enriched semantic interface.

In the code:

```lean
TarskiDiagonalObstruction
TarskiSyntaxFiberContractible
TarskiDiagonalObstruction.notContractible
TarskiDiagonalObstruction.structuralGap
TarskiDiagonalObstruction.operationalGap
TarskiDiagonalObstruction.operationalLength
TarskiDiagonalObstruction.refutesShortPresentation
TarskiDiagonalObstruction.visibleOrderEquivalent
TarskiDiagonalObstruction.visible_eq_of_partialOrder
TarskiDiagonalObstruction.partialOrder_visible_eq_not_interface_eq
TarskiDiagonalObstruction.notOrderContractive
TarskiDiagonalReturnSource
TarskiDiagonalIntersection
tarskiFormedDynamicReturn
tarskiLocallyRecoveredDynamicReturn
tarskiLocallyRecoveredClosedStabilityOfDynamicReturn
tarskiDynamicReturn_operationalGap
tarskiDynamicReturn_visibleOrderEquivalent
tarskiDynamicReturn_visible_eq_of_partialOrder
tarskiDynamicReturn_partialOrder_visible_eq_not_interface_eq
tarskiDynamicReturn_notOrderContractive
tarskiDynamicReturn_refutesShortPresentation
```

Reading:

```text
Tarski provides an operational diagonal gap.
It also exposes an enriched referential-length row and a visible-order row
refuting contraction.
It finally exposes the diagonal process as a formed dynamic return:
diagonal source, typed intersection, formed semantic interface,
local recovery, and recovered closed stability.
```

In this presentation, Tarski is not the starting point of the framework. It is
a derived instance: the case where the constructive mediation between syntactic
code and semantic assertion is forced into a short presentation. The dynamic
layer states this positively: it does not start from the already-produced
obstruction, but from the productive diagonal data, then forms the intersection
where the return becomes recoverable.

The reading hierarchy is therefore:

```text
gap operator
-> constructive mediation between referentials
-> contraction or non-contraction regimes
-> Tarski as a particular diagonal gap
-> Tarski over visible orders: same projected syntax, separated interface
-> Tarski as a formed diagonal return: source, intersection, recovery
```

## Beth

Beth gives the contractibility test for the gap.

In the short reading:

```text
the visible object implicitly determines the enriched object
```

In the enriched reading:

```text
gap = 0
<-> visible fiber faithful
<-> explicit definition on realized visible fibers
```

In the code:

```lean
ImplicitlyDeterminedByVisible
ExplicitDefinitionOnRealizedVisible
BethContractibleGap
bethCollapse_iff_implicitDetermination
bethCollapse_iff_explicitDefinitionOnRealizedVisible
```

Structural and operational gaps refute the Beth collapse:

```lean
structuralGap_refutes_bethCollapse
operationalGap_refutes_bethCollapse
```

Reading:

```text
Beth measures whether the gap operator contracts.
```

## Bell

Bell gives a pre-probabilistic instance of the operator.

Short presentation:

```text
A0, A1, B0, B1
in the same global index
```

This regime produces the pointwise bound:

```text
S = +/- 2
```

Enriched reading:

```text
local contexts
+ amalgamation gap
+ global co-indexation
```

In the code:

```lean
BellContextAmalgamation
BellAmalgamationCompatibility
BellShortCoindexationOfContexts
BellAmalgamationGap
bellAmalgamationGap_refutes_shortCoindexation
```

Reading:

```text
Classical Bell measures the possibility of short co-indexation.
The Bell gap measures the pre-probabilistic obstruction to that co-indexation.
```

## Tsirelson

Tsirelson is the case where the gap vocabulary is taken up as a structured gap
certified by a bound. This layer is supported by the code as
`BellTsirelsonStructuredGap`, but it is not yet encoded as an
`EnrichedOperationalReferentialLength` arising from a projection
`Interface -> Visible`.

Classical presentation:

```text
classical bound : 2
quantum bound   : 2 sqrt(2)
algebraic bound : 4
```

Enriched reading, at the presentation level:

```text
short co-indexation
+ structured quantum gap
+ certified bound
```

In the code, the bound comes from an internal positive certificate:

```lean
BellTsirelsonObservableTuple
BellTsirelsonSumOfSquaresCertificate
BellTsirelsonStructuredGap
BellTsirelsonRow
BellTsirelsonRow.tsirelson_bound
```

The standard layer fixes the constructive form:

```lean
StandardTsirelsonCertificateData
StandardTsirelsonIntrinsicPackage
standardTsirelsonRow
standardTsirelsonRow_bound
```

Strictly supported reading:

```text
Tsirelson provides a certified structured gap row:
structured CHSH tuple + positive sum-of-squares certificate + internal bound.
```

## Enriched Arithmetic

In enriched arithmetic, the gap operator acts on the payload projection:

```lean
tracePayloads : List NatTraceAtom -> List Nat
```

The visible projection forgets the role of the atom:

```text
payload(excess k) = k
payload(value k)  = k
```

but the enriched interface distinguishes:

```text
excess k
value k
```

The arithmetic gap is therefore:

```text
number as value
+ role gap
+ number as recomposition excess
```

In the code:

```lean
formedPositiveExcessOfIntersection
arithmeticGapFormedTrace
arithmeticGapPayloadShadow
arithmeticGap_sameVisible
arithmeticGap_separated
arithmeticOperationalGapOfIntersection
```

Canonical case:

```text
intersection.excess = 0
formedPositiveExcess = 1
```

Reading:

```text
the final `1` is the positive excess of closure.
```

## Arithmetic Dynamics

The dynamics is where an observable return is transformed into closed
stability. It carries the temporal index and converts a repetition into formed
data. At the abstract level, this conversion is the scheme:

```lean
FormedDynamicReturn
LocallyRecoveredDynamicReturn
locallyRecoveredClosedStabilityOfDynamicReturn
```

This scheme does not depend on `Nat`, on a particular trajectory, or on a
bounded window. The arithmetic and observed layers are concrete realizations
of it.

Short presentation:

```text
same observable Nat
```

Enriched reading:

```text
first occurrence
+ temporal return gap
+ second occurrence as closure
```

A repeated collision gives:

```lean
RepeatedIndexCollision
repeatedIndexIntersection
ArithmeticDynamicGapRow
ArithmeticDynamicClosedStabilityRow
```

The dynamic gap carries a terminal excess:

```text
secondTime + 1
```

Reading:

```text
the return to the same observable turns a visible coincidence
into an enriched dynamic index, then into recovered typed closure.
```

The observed bridge extends this construction to an arbitrary discrete system
equipped with a natural-number observation:

```lean
ObservedDiscreteSystem
ObservedRepeatedCollision
ObservedBoundedWindow
observedFormedDynamicReturn
observedLocallyRecoveredDynamicReturn
observedDynamicClosedStabilityRow
observedBoundedWindowFormedDynamicReturn
observedBoundedWindowLocallyRecoveredDynamicReturn
observedBoundedWindowDynamicClosedStabilityRow
```

Thus, a bounded observed window constructively produces a collision, and that
collision produces a closed-stability row. Stability does not come from a bare
equality, but from the return formed as dynamic mediation.

## Synthesis

The gap operator provides the transverse scheme:

```text
Tarski:
code + diagonal gap + assertion + formed diagonal return

Beth:
visible + contractibility test + explicit definition

Bell:
contexts + amalgamation gap + co-indexation

Tsirelson:
observables + certified structured gap + positive bound

Nat:
visible value + role gap + recomposition excess

Nat dynamics:
occurrence + return gap + closing occurrence
```

In the dynamic layers, this scheme has a precise function: transforming an
observable return into recovered closed stability. Dynamics therefore gives the
gap a positive reading: the return is not erased into visible equality; it is
formed, separated from its shadow, and locally recovered.

The framework does not reduce these cases to an analogy. For Tarski, Beth,
Bell, Nat, and Nat dynamics, it gives them directly a projective or operational
form in the current Lean tree:

```text
projection
+ fiber obstruction
+ local recovery
```

For Tsirelson, the current formal connection has a different precise status:

```text
structured tuple
+ positive certificate
+ certified bound
```

It therefore belongs to the same conceptual family of structured gaps, while
the current Lean layer keeps it outside the transverse projective type.

The final sentence is:

```text
The gap operator carries the constructive mediation between referentials:
it makes it typable, indexable, transportable, repairable, and consumable.
```
