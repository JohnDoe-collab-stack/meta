# Reproducibility protocol

## 1. Requirements

- Linux, macOS, or WSL with a POSIX shell;
- `elan` and `lake` available on `PATH`;
- enough memory for parallel checking of the quantized batches;
- no dependency on the parent repository.

The project pins Lean to `leanprover/lean4:v4.29.0`. There are no external Lake
packages.

## 2. Clean verification

From the package root:

```bash
cd artifact
lake build Meta.LatentRepair.ProblemResolutionAudit Meta
```

This rebuilds the complete import closure, including all 88 numerical batches
and all 88 semantic-alignment batches. The first clean build is intentionally
compute intensive; later builds use Lake’s content cache.

Whole-library entry-point check:

```bash
lake build Meta
```

## 3. Staged structural checks

The following targets verify the principal non-neural layers independently:

```bash
lake build Meta.AI.ActiveSemanticClosure
lake build Meta.AI.FiniteActiveSemanticClosure
lake build Meta.AI.OpenActiveSemanticClosure
lake build Meta.AI.VisibleFactoredClosureNoGo
lake build Meta.AI.CertifiedInference
lake build Meta.AI.LeanValidationCompleteness
```

The final problem-audit target must still be built before accepting the
artifact, because it checks the publication bridge, exact scope checklist, and
quantized aggregate jointly.

## 4. Source audit

Run from `artifact`:

```bash
test "$(rg -l 'AXIOM_AUDIT_BEGIN' Meta/LatentRepair/ProblemResolutionAudit.lean | wc -l)" -eq 1
tail -n 4 Meta/LatentRepair/ProblemResolutionAudit.lean
! rg -n '\b(sorry|admit|axiom)\b|Classical|propext|Quot\.sound' Meta/LatentRepair
```

Inspect the build output for the ten publication declarations, the independent
problem-audit object, and the `Meta.lean` entry point. Each must report that the
declaration does not depend on any axioms.

For the full copied source tree, distinguish comments/documentation from Lean
dependencies. The authoritative check is the output of `#print axioms` on the
aggregate declaration, whose transitive dependencies are kernel-traced.

## 5. Key declarations to inspect

```text
Meta.ActiveSemanticClosure.LatentRepair.continuationAliasing_informationNecessity
Meta.ActiveSemanticClosure.LatentRepair.latentAliasing_informationNecessity
Meta.ActiveSemanticClosure.LatentRepair.closureRestoresLocalSufficiency
Meta.ActiveSemanticClosure.LatentRepair.finiteCertifiedLatentRepair0
Meta.ActiveSemanticClosure.LatentRepair.openStrictFiberReductionAt
Meta.ActiveSemanticClosure.LatentRepair.openCertifiedLatentRepairAt
Meta.ActiveSemanticClosure.LatentRepair.certifiedLatentRepairPublication
Meta.ActiveSemanticClosure.LatentRepair.plannedProblemResolutionAudit
```

## 6. Quantized checkpoint identity

The included development checkpoint is:

```text
artifact/Empirical/v23_gap_driven_active_semantic_closure/
  artifacts/development/quantized_checkpoint_v23.json
```

Its SHA-256 in this release is:

```text
16a625dc3638bda0fb24f7ed61b8c7c294c706591dccd160d74e2181f0d344c0
```

Verify with:

```bash
sha256sum Empirical/v23_gap_driven_active_semantic_closure/artifacts/development/quantized_checkpoint_v23.json
```

The Lean propositions do not trust the JSON file. The network weights and
examples are reified in Lean, and the kernel recomputes the exact integer
inference traces.

## 7. Empirical protocol boundary

`Empirical/v23_gap_driven_active_semantic_closure/SCIENTIFIC_PROTOCOL.md` is the
pre-specified scientific campaign. No new empirical run is claimed by this
publication package. The included checkpoint and report are explicitly marked
development artifacts and must not be relabeled as independent replication.

If the campaign is executed later, follow its timestamp-plus-hash freezing
rules. Never overwrite a script after using it to produce a cited result; each
output filename must carry the exact frozen script suffix and the text report
must record the full command and script hash.

## 8. Expected acceptance result

Accept the formal artifact only if:

1. the publication target exits successfully;
2. every final axiom audit reports no axioms;
3. the aggregate declaration is present;
4. no forbidden proof placeholder occurs in the publication module;
5. the checkpoint hash matches when that supporting file is used;
6. claims are interpreted according to `CLAIM_EVIDENCE_MATRIX.md`.
