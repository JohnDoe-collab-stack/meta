# Core refactor plan

## Purpose

This document prepares a refactor of the Core architecture without changing the
mathematical content or weakening the constructive discipline.

The aim is to make the project easier to read:

```text
primitive Core
-> Core views
-> dynamic Core carriers
-> canonical instances
-> domain instances
```

The refactor must preserve compilation at every phase.

## Phase 1: dependency map

Current Core import chain:

```text
ClosedStabilityTheorem
-> Gap
-> ReferentialLength
-> TwoPole
-> DynamicStability
-> DynamicTwoPole
-> DynamicRoleCarrier
```

Canonical instance layer currently still inside `Meta.Core`:

```text
ParitySeparation
-> DynamicParitySeparation
-> OperationalParityRoles

OrderGap
```

External/domain layers depending on Core:

```text
Arithmetic
Dynamics
Tarski
Beth
Bell
Synthesis
```

Important current dependencies:

- `Meta.Arithmetic.ParityRoles` depends on `Meta.Core.OperationalParityRoles`.
- `Meta.Tarski.ReferentialOrder` and `Meta.Tarski.DynamicReturn` depend on
  `Meta.Core.OrderGap`.
- `Meta.Beth.GapContraction`, `Meta.Bell.GapContraction`, and
  `Meta.Tarski.GapContraction` depend on `Meta.Core.Gap`.

## Phase 2: classify Core files

### Primitive Core

These files carry the base machinery and should remain in `Meta.Core`:

```text
ClosedStabilityTheorem.lean
Gap.lean
ReferentialLength.lean
DynamicStability.lean
```

### Core views

These files re-express primitive Core data in a more operational vocabulary:

```text
TwoPole.lean
DynamicTwoPole.lean
DynamicRoleCarrier.lean
```

They should remain in `Meta.Core`.

### Canonical Core instances

These files are more instance-like:

```text
ParitySeparation.lean
DynamicParitySeparation.lean
OperationalParityRoles.lean
OrderGap.lean
```

They are correct in Core today, but conceptually they are not the same kind of
file as `Gap`, `TwoPole`, or `DynamicRoleCarrier`.

## Phase 3: parity decision

There are two possible architectures.

### Option A: keep parity in Core

Use this if parity is considered the canonical minimal separated role
realization of the Core.

Pros:

- minimal disruption;
- current imports stay simple;
- arithmetic parity keeps a direct route to Core.

Cons:

- Core contains a named canonical instance;
- users may read parity as arithmetic too early.

### Option B: move parity to `Meta.Parity`

New layout:

```text
Meta/Parity/Separation.lean
Meta/Parity/DynamicSeparation.lean
Meta/Parity/OperationalRoles.lean
```

Pros:

- Core becomes purely abstract;
- parity becomes visibly an instance of `DynamicRoleCarrier`;
- arithmetic parity can depend on `Meta.Parity` instead of importing a
  specialized Core file.

Cons:

- more imports to rewrite;
- docs must explain that `Meta.Parity` is not merely arithmetic parity.

Recommended path:

Do not move parity immediately.  First add compatibility wrappers or aliases if
needed, then move only after `OrderGap` has been separated.  The current code is
stable and should not be churned before the boundaries are clearer.

## Phase 4: clean `OrderGap`

`OrderGap.lean` currently contains four layers:

```text
visible order data
order-contractiveness
structural / operational order consequences
dynamic order consequences
```

Recommended split:

```text
Meta/Core/VisibleOrder.lean
Meta/Core/OrderContraction.lean
Meta/Core/OrderGapStructural.lean
Meta/Core/DynamicOrderGap.lean
Meta/Core/OrderGap.lean
```

During the first implementation pass, `Meta.Core.OrderGap` should remain the
public module imported by downstream files.  It may import the new split files
and expose the same declarations.  Downstream imports should be changed only
after the split has compiled cleanly.

Proposed responsibilities:

### `VisibleOrder.lean`

Contains only:

```text
VisiblePreorder
VisiblePartialOrder
VisibleTotalOrder
VisibleOrder
VisibleOrderEquivalent
visibleOrderEquivalent_refl
visible_eq_of_visibleOrderEquivalent
```

### `OrderContraction.lean`

Contains:

```text
OrderContractiveProjection
projectionFiberFaithful_of_orderContractive
orderContractive_of_projectionFiberFaithful
orderContractive_iff_projectionFiberFaithful
orderContractive_iff_contractibleReferentialGap
orderContractive_iff_shortReferentialPresentation
orderContractive_of_informationConserving
```

### `OrderGapStructural.lean`

Contains structural and operational order consequences only:

```text
structuralGap_...
structuralLength_...
operationalGap_...
operationalLength_...
```

### `DynamicOrderGap.lean`

Contains dynamic-return order consequences:

```text
dynamicReturn_visible_le_formed_shadow
dynamicReturn_visible_le_shadow_formed
dynamicReturn_visibleOrderEquivalent
dynamicReturn_visible_eq_of_partialOrder
dynamicReturn_partialOrder_visible_eq_not_interface_eq
dynamicReturn_not_orderContractive
```

This split would make the order layer read as a test over visibles, not as the
central explanation of the framework.

### `OrderGap.lean`

Remains a compatibility entry point importing `DynamicOrderGap.lean`.  This
keeps existing downstream imports valid during the first pass.

## Phase 5: move only after stabilizing wrappers

Before moving files or changing module names:

1. Add the new split files.
2. Make old files import and re-export the new organization when possible.
3. Run `lake build`.
4. Only then update downstream imports.
5. Remove compatibility files only after a separate commit.

This avoids a large semantic and path-level change in one step.

## Non-negotiable constraints

Every modified or created Lean file must remain:

- constructive;
- axiom-free;
- free of `Classical`;
- free of `propext`;
- free of `Quot.sound`;
- equipped with exactly one final `AXIOM_AUDIT` block.

No theorem should be weakened into a conditional bridge merely to make the
refactor compile.

## Recommended execution order

1. Implement the `OrderGap` split first.
2. Keep `ParitySeparation` in Core for the moment.
3. Keep `Meta.Core.OrderGap` as the compatibility entry point during the first
   split.
4. Update `Meta.lean` order to show:

```text
Core primitives
Core views
Core canonical instances
Arithmetic
Dynamics
Tarski / Beth / Bell
Synthesis
```

5. Run full build.
6. Re-evaluate whether parity should move to `Meta.Parity`.

## Expected benefit

After this refactor, the reader should see the architecture as:

```text
closed stability
-> projection gap
-> operational two-pole
-> dynamic role carrier
-> parity and order as canonical readings
-> arithmetic, Tarski, Beth, Bell as domain realizations
```

That is the clean version of the current framework.
