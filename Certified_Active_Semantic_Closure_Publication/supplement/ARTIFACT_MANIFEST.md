# Artifact manifest

Release: 1.0.0
Release date: 2026-07-17
Packaging mode: standalone anonymous-review artifact

## Source inventory

| Component | Count | Role |
|---|---:|---|
| Lean source files under `artifact/Meta` | 236 | Complete formal artifact |
| Core Lean modules | 22 | Relaxed use, projection, transport, dynamics |
| Semantic Lean modules | 13 | Interpretation, soundness, conservativity, stability |
| AI Lean modules | 200 | Closure systems, instances, no-go, quantized execution |
| Numerical certificate batches | 88 | Exact quantized traces |
| Semantic-alignment batches | 88 | Dependent-semantic input coverage |
| Python files | 22 | Frozen development and experimental tooling |
| Publication-specific Lean module | 1 | Aliasing-to-sufficiency solution and aggregate |

The top-level `Meta.lean` entry point and project configuration are additional
to the 236 files counted below `Meta/`.

## Entrypoints

- Formal publication theorem:
  `artifact/Meta/LatentRepair/CertifiedLatentRepair.lean`
- Whole-library import:
  `artifact/Meta.lean`
- Manuscript: `manuscript/MAIN_PAPER.md`
- Normative claim map: `supplement/CLAIM_EVIDENCE_MATRIX.md`
- Reproduction instructions: `supplement/REPRODUCIBILITY.md`

## External dependencies

None at the Lake-package level. `lake-manifest.json` contains an empty package
list. The only pinned toolchain dependency is Lean 4.29.0 through `elan`.

## Key supporting checksum

```text
quantized_checkpoint_v23.json
SHA-256 16a625dc3638bda0fb24f7ed61b8c7c294c706591dccd160d74e2181f0d344c0
```

This checksum identifies a supporting development checkpoint. Formal validity
is established by reified Lean data and kernel-checked proofs, not by trusting
the JSON file.

## Excluded build products

The `.lake` directory is a local build cache and is not part of the source
inventory or scientific release content. A recipient may remove it and run the
clean build specified in `REPRODUCIBILITY.md`.
