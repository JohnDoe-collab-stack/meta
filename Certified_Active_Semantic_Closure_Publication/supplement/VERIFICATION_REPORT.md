# Release verification report

Release: 1.2.0
Verification date: 2026-07-18
Environment: x86_64 Linux/WSL

## Toolchain

```text
Lean 4.29.0
commit 98dc76e3c0a9b856c9b98726b713fb04fab16740
release build
```

## Independent build results

Working directory:

```text
Certified_Active_Semantic_Closure_Publication/artifact
```

Publication target:

```text
lake build Meta
Build completed successfully (231 jobs).
```

The manifest has an empty package list. Every project import begins with
`Meta.` and resolves to a source file inside this artifact.

## Axiom audit result

The established publication module contains exactly one `AXIOM_AUDIT` block. Its ten
declarations all report “does not depend on any axioms”:

```text
continuationAliasing_informationNecessity
latentAliasing_informationNecessity
closureRestoresLocalSufficiency
closureRefutesPostRepairAliasing
finiteCertifiedLatentRepair0
finiteCertifiedLatentRepair1
finiteCertifiedLatentRepair2
openStrictFiberReductionAt
openCertifiedLatentRepairAt
certifiedLatentRepairPublication
```

The independent `Meta.lean` entry point also has exactly one audit block and
reports:

```text
certifiedActiveSemanticClosurePublication does not depend on any axioms.
certifiedAdaptiveClosurePublicationValidation does not depend on any axioms.
```

The independent problem-resolution audit has exactly one audit block and
reports:

```text
plannedProblemResolutionAudit does not depend on any axioms.
```

Each of the nine modules under `Meta/AdaptiveRepairability` contains exactly
one final `AXIOM_AUDIT` block. Their audited declarations include:

```text
actionConflictMeasure_eq_zero_iff
actionConflictMeasure_monotone
actionConflictMeasure_strictly_decreases
adaptivePublicNoGo
certifiedRepairable_iff_uniformlyActionResolvable
synthesizeActionResolvedTree
composableSeparability_implies_certifiedRepairable
exactGeneratedTree_leafPosterior
adaptiveRepairabilityFormalValidation
synthesizedCertifiedRepairability
exactInstanceCertifiedRepairable
alternateState1_rightCompatible
alternateState2_rightCompatible
alternateState3_rightCompatible
finiteCompatibilityExact
finiteLegacyAdapter0
finiteLegacyAdapter1
finiteLegacyAdapter2
openCompatibilityExact
openLegacyAdapterAt
legacyAdaptiveIntegration
```

All report “does not depend on any axioms.” The four countermodel aggregates
report the same result.

The final source scan found no `sorry`, `admit`, introduced `axiom`,
`Classical`, `propext`, or `Quot.sound` dependency in the adaptive modules or
the whole-package entry point. It also found no external `rank`, `windowFor`,
or `actualReducts` termination bridge.

## Release hashes

```text
bf407d7fb9a7a80fa63423e3ac8c4cce85ac8512d28983a62fdc348c0c64ac72  artifact/Meta/LatentRepair/CertifiedLatentRepair.lean
72f0486e07f9334f59269d82f29b89b5737385cd55d635fc8b2a0790ca19c50c  artifact/Meta/LatentRepair/ProblemResolutionAudit.lean
83dc79d237a0d765e8ce110947c2d1f34df7ca172cbb580948a88f7f3281d291  artifact/Meta/AdaptiveRepairability/FiniteMeasure.lean
2d4b3865333cf02b3b5a31f1d81341e24b237d2b368148aba843e0e1d082f8f5  artifact/Meta/AdaptiveRepairability/PublicTree.lean
388d8cfa6aa007a8f3adcdf20b6896b10f7c4089cf19ed27631b0485066d488d  artifact/Meta/AdaptiveRepairability/OperationalCharacterization.lean
f82805f5fe0c2dbc79b6d6e517cfdd373730d0f1624cad50dfca73b428a41853  artifact/Meta/AdaptiveRepairability/Synthesis.lean
c1ffd7382f5e02206e2ee81c5e4fabc918381a7254ec33bdc61610e1e8b3628f  artifact/Meta/AdaptiveRepairability/ExactPosterior.lean
1b1d4170629eab37f205fb2730efff8497dbd4c8cb2427946420d785fc70c43f  artifact/Meta/AdaptiveRepairability/Countermodels.lean
209a77fd211598bb8576a02e15cc204c5267c337975e128f17c10d7ea7db0d85  artifact/Meta/AdaptiveRepairability/Validation.lean
aa30259cdedc1e56c2aae0e0b31c20e16a021e987cded73b5221827fd79f7692  artifact/Meta/AdaptiveRepairability/PositiveInstance.lean
0349cbb5d67cec466c5ee9377fd046871a825d953283d789fc61596dd0f1df11  artifact/Meta/AdaptiveRepairability/LegacyInstanceAdapters.lean
60174b45913987883b7c82b2344adbb75d3dcfc999cce03cc57cb7418b5f0ed8  artifact/Meta.lean
52a542d4b5f29b3cdf93d524a044d3137f9e2383b8ef70fe244b0b9cdbfc53c4  artifact/lakefile.toml
651c8accb402b0c071cd336e9d3dc0a55516b1bfb434ddc4801f14936785b1d2  artifact/lean-toolchain
fa349e748a580c71c4ab4259a74bfc457b5db819be8581002707c380dcd47c46  manuscript/MAIN_PAPER.md
16a625dc3638bda0fb24f7ed61b8c7c294c706591dccd160d74e2181f0d344c0  artifact/Empirical/v23_gap_driven_active_semantic_closure/artifacts/development/quantized_checkpoint_v23.json
```

## Inventory result

The release contains 298 source/documentation/configuration files when `.lake`
build products are excluded, including 246 Lean modules below `artifact/Meta`,
88 numerical batches, 88 semantic-alignment batches, and 22 frozen Python
files. Source size excluding `.lake` is approximately 2.80 MiB.

## Verdict

Accepted for anonymous formal-artifact submission as release 1.2.0. The formal
claims in the normative claim–evidence matrix, adaptive characterization, and
problem-resolution audit are build-verified.
This verdict is for the exact generic/exact scope stated there, not for the
unproved universal, robustness, minimality, or external-benchmark objectives.
Empirical claims remain restricted to the finite reified catalogue and the
explicitly labeled development checkpoint.
