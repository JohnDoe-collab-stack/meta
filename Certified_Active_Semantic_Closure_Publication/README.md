# Certified Online Repair of Action-Sufficient Latent Representations

This is a self-contained anonymous-submission package. It formalizes and
constructively verifies a complete repair chain for action-relevant latent
aliasing:

```text
aliased compatible worlds
→ information is necessary
→ a typed semantic gap is detected
→ the selected query separates compatible worlds
→ the intrinsic response-derived repair strictly reduces the fiber
→ previous certified facts are preserved
→ local sufficiency is restored
→ finite termination or open-world progress
```

The central publication theorem is
`Meta.ActiveSemanticClosure.LatentRepair.certifiedLatentRepairPublication` in
[`artifact/Meta/LatentRepair/CertifiedLatentRepair.lean`](artifact/Meta/LatentRepair/CertifiedLatentRepair.lean).
It combines the new generic aliasing-to-sufficiency theorems with exact finite
and open realizations, the visible/passive no-go results, conservative
foundational semantics, and the five-head quantized certificate.

The finite adaptive characterization is aggregated by
`certifiedAdaptiveClosurePublicationValidation` in
[`artifact/Meta.lean`](artifact/Meta.lean). It adds an adaptive public no-go, an
operational characterization by global repair trees, constructive synthesis
from composable pair separators, exact leaf posteriors for compiler-generated
trees, four hypothesis countermodels, and an inhabited two-world exact instance.
The same binary interface is now connected constructively to all three
published finite repairs and to every natural stage of the published open
orbit by exact public-fiber adapters.

The stricter release verdict is the independently typed checklist
`plannedProblemResolutionAudit` in
[`artifact/Meta/LatentRepair/ProblemResolutionAudit.lean`](artifact/Meta/LatentRepair/ProblemResolutionAudit.lean).
Its clause-by-clause interpretation, including the exact non-claims, is in
[`supplement/PROBLEM_RESOLUTION_AUDIT.md`](supplement/PROBLEM_RESOLUTION_AUDIT.md).

## What is proved

- A generic visible-factored rule cannot be correct on two hidden situations
  with the same visible code and separated required continuations.
- In the declared finite deterministic public class, certified repairability is
  equivalent to a global action-resolving public tree, and composable local
  separators synthesize such a tree by a strictly decreasing internal conflict
  measure.
- Adaptive public indistinguishability of an action-conflicting pair rules out
  certified repairability; canonical exact-response trees represent their leaf
  posteriors exactly.
- Compatible-world target aliasing refutes fiber determinacy and known local
  correctness.
- `GapClosedBy` constructively restores epistemic correctness, actual-world
  correctness, and fiber determinacy at the repaired index.
- Each of the three finite repairs uses an informative selected query, strictly
  reduces the compatible-world fiber, closes its exact gap, and preserves the
  repaired prefix; the third state is closed and stable.
- At every natural-number stage, the open realization has a typed aliasing gap,
  makes a strictly informative query, eliminates a compatible completion,
  closes the current gap, preserves all learned entries, and makes an effective
  transition. No finite stage is globally closed.
- The two-world public protocol represents exactly the certified aliasing pair
  before and after each published finite repair and every open repair stage;
  response, required action, actual successor, legacy closure, and sequential
  linkage are carried by `legacyAdaptiveIntegration`.
- A five-head Int8/Int32 agent is exhaustively checked on 697 reified semantic
  obligations in 88 batches with exact arithmetic and strict winning margins.

The neural certificate is exhaustive for its explicit finite catalogue. It is
not a theorem of generalization to arbitrary learned inputs, noise, or large
external environments.

## Layout

```text
manuscript/MAIN_PAPER.md              anonymous paper
manuscript/RESUME_FRANCAIS.md         precise French summary
specification/TARGET_PROBLEM.md        normative independent specification
specification/ADAPTIVE_REPAIRABILITY_CHARACTERIZATION.md
                                        finite characterization and proof map
supplement/TECHNICAL_APPENDIX.md      definitions and theorem map
supplement/CLAIM_EVIDENCE_MATRIX.md   every publication claim and its evidence
supplement/PROBLEM_RESOLUTION_AUDIT.md source-problem clause-by-clause verdict
supplement/RELATED_WORK_MATRIX.md     structural positioning and priority limit
supplement/REPRODUCIBILITY.md         clean-room build and audit protocol
supplement/VERIFICATION_REPORT.md     recorded release build and axiom verdict
supplement/SCOPE_AND_LIMITATIONS.md   explicit claim boundary
artifact/                             standalone Lean and empirical materials
```

The `artifact` directory has its own `lakefile.toml` and `lean-toolchain`; it
does not import the surrounding repository or any project-local dependency.

## Verify

```bash
cd artifact
lake build Meta
```

For the shorter structural check, excluding the expensive 88-batch quantized
aggregate, follow the staged commands in
[`supplement/REPRODUCIBILITY.md`](supplement/REPRODUCIBILITY.md).

Successful output for every final `#print axioms` line must state that the
declaration does not depend on any axioms. The source audit must also find no
`sorry`, `admit`, `axiom`, `Classical`, `propext`, or `Quot.sound` dependency.

## Submission status

The scientific content is frozen as version 1.2.0 for anonymous review. Author,
affiliation, venue formatting, and archival DOI are intentionally absent from
this blind package and can be added without changing any theorem or claim.
