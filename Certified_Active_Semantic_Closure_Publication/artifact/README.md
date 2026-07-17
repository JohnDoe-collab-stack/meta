# Standalone verification artifact

This directory is an independent Lean 4 project. Its entry point is
`Meta/LatentRepair/CertifiedLatentRepair.lean`; `Meta.lean` imports that entry
point for whole-library builds.

The proof artifact has three layers:

1. `Meta/Core` and `Meta/Semantics`: constructive non-identitarian transport,
   soundness, conservativity, dynamic repair, and non-reduction results.
2. `Meta/AI`: active semantic closure, finite and open realizations,
   interventions, no-go theorems, and the quantized five-head implementation.
3. `Meta/LatentRepair`: the publication-specific bridge from continuation
   aliasing to information necessity and from certified closure to restored
   local sufficiency, with exact finite/open certificates.

Build from this directory:

```bash
lake build Meta.LatentRepair.CertifiedLatentRepair
```

Lean version: `leanprover/lean4:v4.29.0`.

The `Empirical` directory contains the frozen development checkpoint and the
pre-registered scientific protocol. The checkpoint is supporting development
material; it is not presented as an independently replicated benchmark result.
