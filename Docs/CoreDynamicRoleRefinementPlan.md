# Core dynamic role refinement plan

## Objective

Extract from the current Core the positive pattern that has appeared in the
dynamic, parity, order, and arithmetic developments:

```text
formed interface
+ shadow interface
+ same visible reading
+ separated roles
+ local repair
+ no global visible reconstruction
```

The purpose is not to strengthen the framework by assumption.  The purpose is
to name the reusable Core structure already present in the code.

## Current situation

The pattern is currently distributed across several files:

- `DynamicTwoPole.lean` exposes a locally recovered dynamic return as an
  operational two-pole.
- `DynamicParitySeparation.lean` connects that dynamic two-pole to the minimal
  parity separation.
- `DynamicParitySeparation.lean` also names the closing and mediating roles
  once the parity raccord is fixed.

This is correct, but the generic structure is still hidden inside the parity
specialization.

## Implementation

Add a new Core file:

```text
Meta/Core/DynamicRoleCarrier.lean
```

It introduces two layers.

### 1. `DynamicRoleCarrier`

A dynamic return equipped with a reading into an arbitrary operational role
two-pole:

```text
dynamic formed/shadow interfaces
-> abstract roles
-> abstract role-visible values
```

It carries:

- `roleOf : Interface -> Role`
- `visibleRoleOf : Visible -> RoleVisible`
- an operational two-pole on the role side
- compatibility of the formed and shadow dynamic sides with that role two-pole

This extracts the generic form currently specialized by
`DynamicParitySeparation`.

### 2. `MediatedDynamicRoles`

A role-level package extracted from a `DynamicRoleCarrier`.

It records:

- the closing role;
- the mediating role;
- the fact that they are the formed and shadow role readings;
- equality of their role-visible projections;
- separation of the two roles;
- the dynamic repair carried by the formed side;
- the role-side repair;
- failure of uniform reconstruction from role-visible data.

This is the generic parent of `OperationalParityRoles`.

## Raccord with parity

`DynamicParitySeparation.lean` should expose:

```text
dynamicParitySeparation_roleCarrier
```

so that every dynamic parity separation is visibly an instance of
`DynamicRoleCarrier`.

`DynamicParitySeparation.lean` should expose:

```text
operationalParityRoles_mediatedDynamicRoles
```

so that the closing/mediating parity roles are visibly an instance of the
generic mediated-role package.

## Validation

The phase is acceptable only if:

- the new Lean file is constructive;
- it has exactly one final `AXIOM_AUDIT` block;
- no `Classical`, `propext`, `Quot.sound`, `axiom`, `sorry`, or `admit` occurs;
- `DynamicParitySeparation.lean` still builds;
- `lake build` succeeds.
