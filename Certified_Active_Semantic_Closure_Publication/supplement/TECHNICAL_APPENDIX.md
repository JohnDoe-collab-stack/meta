# Technical appendix

## A. Exact resolution of the target problem

The source problem asks for the following chain:

```text
1. action-relevant aliasing is detected as an open gap;
2. the gap is semantically correct;
3. the selected query is informative;
4. the response produces a sound intrinsic repair;
5. the compatible-world fiber strictly shrinks;
6. previous closures are preserved;
7. local sufficiency is restored;
8. the process terminates finitely or makes open progress;
9. visible-only and passive systems cannot guarantee the same outcome.
```

The publication-specific module closes this chain with
`CertifiedLatentRepairStep` and `CertifiedLatentRepairPublication`. The
independent `PlannedProblemResolutionAudit` structure restates the full claimed
scope as a kernel-checked checklist.

| Obligation | Formal object | Status |
|---|---|---|
| Generic continuation aliasing | `ContinuationAliasing` | Definition |
| Visible information necessity | `continuationAliasing_informationNecessity` | Generic theorem |
| Compatible-world aliasing | `LatentAliasing` | Definition |
| Aliasing contradicts determinacy | `latentAliasing_refutesFiberDeterminacy` | Generic theorem |
| Aliasing contradicts known correctness | `latentAliasing_informationNecessity` | Generic theorem |
| Query separates compatible worlds | `SelectedQueryInformative` | Exact finite/open certificates |
| Strict fiber reduction | `CompatibleFiberStrictlyReduces` | Exact finite/open certificates |
| Response-derived repair | `IntrinsicRepair.responseUsed` | Kernel interface |
| Complete provenance | `IntrinsicRepair.provenance` | Kernel interface |
| Intrinsic successor | `CertifiedLatentRepairStep.successorIntrinsic` | Every certified step |
| Gap closed | `CertifiedLatentRepairStep.gapClosed` | Every certified step |
| Sufficiency restored | `closureRestoresLocalSufficiency` | Generic theorem |
| Residual aliasing impossible | `closureRefutesPostRepairAliasing` | Generic theorem |
| Finite non-regression | `repair_preserves_closedPrefix` | Exact certificate |
| Open non-regression | `openRepair_preservesKnownPrefix` | Theorem for every stage |
| Finite termination | `finiteMeasureClosureCertificate` | Exact measure certificate |
| Open progress | `openCertifiedLatentRepairAt` | Theorem for every `Nat` stage |
| Visible/passive obstruction | `aiClosureNoGoCertificate` | Constructive no-go package |
| Final aggregation | `certifiedLatentRepairPublication` | Publication theorem |
| Independent problem verdict | `plannedProblemResolutionAudit` | Axiom-free typed checklist |

## B. Core definitions

Let `D` be active-closure data and `S` an active-semantic-closure system.

### B.1 Pointwise correctness

```text
CorrectAt(D,w,c,i)
  := D.Agrees (D.interpret c i) (D.evaluate w i).
```

### B.2 Known correctness

```text
KnownCorrectAt(S,v,c,i)
  := ∀ w, S.CompatibleWithViewHistory v w → CorrectAt(D,w,c,i).
```

### B.3 Fiber determinacy

```text
FiberDeterminateAt(S,v,i)
  := ∀ w₁ w₂,
       Compatible(v,w₁) → Compatible(v,w₂) →
       evaluate(w₁,i) = evaluate(w₂,i).
```

### B.4 Latent aliasing

```text
LatentAliasing(S,v,i)
  := ∃ w₁ w₂,
       Compatible(v,w₁) ∧ Compatible(v,w₂) ∧
       evaluate(w₁,i) ≠ evaluate(w₂,i).
```

Lean stores the witnesses and the separation proof positively; no classical
negation-to-witness conversion is used.

### B.5 Gap closure

`GapClosedBy(S,before,gap,after)` contains:

```text
after.world = before.world
Compatible(after.agent,after.world)
KnownCorrectAt(S,after.agent,after.candidate,gap.index).
```

### B.6 Restored local sufficiency

The publication definition strengthens closure into a single interface:

```text
actual compatible
∧ known correct
∧ fiber determinate
∧ actual correct.
```

The last two fields are derived, not separately postulated.

## C. Proof sketches

### C.1 Generic visible no-go

For a visible rule `f`, `encode(left) = encode(right)` implies
`f(encode(left)) = f(encode(right))`. If the rule were correct on both, this
equality would imply `required(left) = required(right)`, contradicting the
separation witness. The proof uses equality congruence and transitivity only.

### C.2 Semantic information necessity

Suppose a candidate were known correct at an aliased index. Its single
prediction would agree with the left target and the right target. The
`agrees_target_unique` law would identify those targets, contradicting the
aliasing witness. Consequently information that separates the target must be
preserved, acquired, or simultaneous correctness must be abandoned.

### C.3 Closure-to-sufficiency bridge

Known correctness supplied by `GapClosedBy` gives target determinacy through
`fiberDeterminateAt_of_knownCorrectAt`. Applying known correctness to the actual
compatible world gives actual correctness. Hence the remaining fiber is locally
action-sufficient at the repaired index.

### C.4 Open strict reduction

At stage `n`, the candidate contains a Boolean prefix. A completion assigning
`true` at the fresh index is compatible with that prefix. The actual baseline
response assigns `false`; after append, compatibility forces every remaining
world to assign `false` at that index. The `true` completion is therefore an
explicit eliminated witness. Earlier compatibility follows from the list
append preservation theorem.

## D. Finite trajectory

The exact certificate table is:

| Before | Gap kind | Index | Alternative eliminated | After | Open-gap count |
|---|---|---|---|---|---:|
| `state0` | witnessed mismatch | first | `firstEliminatedWorld` | `state1` | 2 |
| `state1` | unresolved fiber | second | `secondFiberAlternative` | `state2` | 1 |
| `state2` | unresolved fiber | third | `thirdFiberAlternative` | `state3` | 0 |

Each alternative is compatible before its query and incompatible afterward.
Each exact selected query returns a response distinct from the response in the
canonical world. Crossed responses fail `GapClosedBy`, so the observed answer
is causally relevant rather than an unused annotation.

The finite closure bound is the length of the canonical domain, namely three.
At that bound, actual closure, known closure, detector closure, and transition
stasis all hold.

## E. Open trajectory

At stage `n`:

```text
candidate.length = n
freshGap.index = n
candidate = falsePrefix(n)
state(n+1) = openSystem.nextState(state(n)).
```

The fresh completion pair differs at index `n`. Querying this index appends one
bit. Existing lookup results survive append, so every earlier known-correct
entry remains known correct. List length increases, which proves transition
effectiveness and injectivity of the orbit. The next fresh lookup is `none`,
which refutes global closure at every finite stage.

## F. Provenance and update soundness

The repair language prevents an arbitrary successor from being attached after
the fact. `IntrinsicRepair` is indexed by the exact view, gap, use, transport,
query, and response. Its fields certify:

- the candidate patch comes from the response;
- the observation update comes from the same response;
- the history record comes from the same response;
- provenance connects all upstream and downstream objects.

`executeAgentRepair` applies the patch, applies the observation update, and
appends exactly the history record. `executeRepair` preserves the semantic
world. `nextState` constructs and executes that repair definitionally.

## G. Constructive audit discipline

Every modified publication Lean file ends with exactly one `AXIOM_AUDIT` block.
The audit prints all major declarations, including the final aggregate. The
acceptance condition is that every print says “does not depend on any axioms.”
The build is additionally scanned for forbidden tokens. See
`REPRODUCIBILITY.md` for exact commands.

## H. What is not hidden in the statement

The theorem does not use an external rank, a supplied terminal window, a list
of “actual reducts,” or a conditional terminal bridge. The finite model carries
an internal, computed open-gap count. The open model consumes the nonterminal
branch by its intrinsic fresh index and response-derived append operation.

Generic detection completeness is not falsely asserted for an arbitrary
malicious implementation of `detectGap`. Instead, detection and the whole
repair step are proved at every reachable stage in the two concrete published
systems, while the information-necessity and closure-sufficiency bridges are
fully generic.
