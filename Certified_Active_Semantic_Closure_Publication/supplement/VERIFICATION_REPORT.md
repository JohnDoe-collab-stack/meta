# Release verification report

Release: 1.0.0
Verification date: 2026-07-17
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
lake build Meta.LatentRepair.ProblemResolutionAudit Meta
Build completed successfully (222 jobs).
```

The manifest has an empty package list. Every project import begins with
`Meta.` and resolves to a source file inside this artifact.

## Axiom audit result

The publication module contains exactly one `AXIOM_AUDIT` block. Its ten
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
```

The independent problem-resolution audit has exactly one audit block and
reports:

```text
plannedProblemResolutionAudit does not depend on any axioms.
```

The final source scan found no `sorry`, `admit`, introduced `axiom`,
`Classical`, `propext`, or `Quot.sound` token in any of the three publication
entry modules.

## Release hashes

```text
bf407d7fb9a7a80fa63423e3ac8c4cce85ac8512d28983a62fdc348c0c64ac72  artifact/Meta/LatentRepair/CertifiedLatentRepair.lean
72f0486e07f9334f59269d82f29b89b5737385cd55d635fc8b2a0790ca19c50c  artifact/Meta/LatentRepair/ProblemResolutionAudit.lean
3e681a73ca9e4811e402d6bdf68c287c5693548cf7d1ec121a2f70a361bf0276  artifact/Meta.lean
4541183fb5f7814fed4413555d218386db0ce6c9d287bd7089c9ac6b5bf0a83b  artifact/lakefile.toml
a4c13fa8de6c2dd7a6b753bf30b146cfc02f3c203613885667e9e8ab9bd8bb95  artifact/lean-toolchain
aeb45ebbe4694bbe2af416b2e75052bfc6faee1f9eeb05a0a62df5cc7d0b50cd  manuscript/MAIN_PAPER.md
16a625dc3638bda0fb24f7ed61b8c7c294c706591dccd160d74e2181f0d344c0  artifact/Empirical/v23_gap_driven_active_semantic_closure/artifacts/development/quantized_checkpoint_v23.json
```

## Inventory result

The release contains 288 source/documentation/configuration files when `.lake`
build products are excluded, including 237 Lean modules below `artifact/Meta`, 88 numerical
batches, 88 semantic-alignment batches, and 22 frozen Python files. Source size
excluding `.lake` is approximately 3.4 MiB.

## Verdict

Accepted for anonymous formal-artifact submission. The formal claims in the
normative claim–evidence matrix and problem-resolution audit are build-verified.
This verdict is for the exact generic/exact scope stated there, not for the
unproved universal, robustness, minimality, or external-benchmark objectives.
Empirical claims remain restricted to the finite reified catalogue and the
explicitly labeled development checkpoint.
