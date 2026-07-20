# Standalone verification artifact

This directory is an independent Lean 4 project. Its entry point is
`Meta.lean`, which imports both the established latent-repair validation and the
finite adaptive-repairability characterization.

The proof artifact has three layers:

1. `Meta/Core` and `Meta/Semantics`: constructive non-identitarian transport,
   soundness, conservativity, dynamic repair, and non-reduction results.
2. `Meta/AI`: active semantic closure, finite and open realizations,
   interventions, no-go theorems, and the quantized five-head implementation.
3. `Meta/LatentRepair`: the publication-specific bridge from continuation
   aliasing to information necessity and from certified closure to restored
   local sufficiency, with exact finite/open certificates.
4. `Meta/AdaptiveRepairability`: the finite public-environment
   characterization: computable conflict measure, public repair trees,
   adaptive no-go, operational equivalence, well-founded synthesis from
   composable separators, exact-posterior compilation, four countermodels, and
   an inhabited end-to-end instance, followed by exact adapters for the
   previously published finite and open trajectories.

Build from this directory:

```bash
lake build Meta
```

The adaptive characterization can be checked alone with:

```bash
lake build Meta.AdaptiveRepairability.LegacyInstanceAdapters
```

Its module order is:

```text
FiniteMeasure
→ PublicTree
→ OperationalCharacterization
→ Synthesis
→ ExactPosterior
→ Countermodels
→ Validation
→ PositiveInstance
→ LegacyInstanceAdapters
```

Lean version: `leanprover/lean4:v4.29.0`.

The `Empirical` directory contains the frozen development checkpoint and the
pre-registered scientific protocol. The checkpoint is supporting development
material; it is not presented as an independently replicated benchmark result.
