# Specializations of `Meta/Core`

This directory contains concrete models and domain-specific extensions of the
generic structures defined directly under `Meta/Core`.

The dependency rule is one-way:

```text
Meta/Core generic modules
  -> Meta/Core/Specialization modules
```

No generic Core module may import this directory.

The current specializations are:

- `DirectionalRelaxation.lean`: the directional countermodel proving strict
  non-projective representability;
- `TransportCoherenceModel.lean`: the nontrivial three-phase transport model;
- `DynamicRelaxedUsageModel.lean`: the finite switching dynamic model;
- `Parity.lean`: the minimal parity model and its dynamic role reading;
- `OrderGap.lean`: the ordered-visible extension of projective gaps;
- `ParitySeparation.lean` and `DynamicParitySeparation.lean`: compatibility
  entry points for the parity specialization.
