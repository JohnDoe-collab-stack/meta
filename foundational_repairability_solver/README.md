# Foundational Repairability Solver

Independent constructive Lean implementation of the finite public repair game specified in `../foundational_repairability_solver_program/`.

Implemented kernel:

- finite effective public games and exact Boolean/refinement lemmas;
- certified targets, posterior retention, safety and closure preservation;
- controllable predecessors and depth-indexed public repair trees;
- constructive extraction and completeness in both directions;
- intrinsic finite stabilization, leastness, and a total `WIN`/`LOSE` solver;
- stable-complement counter-strategies ruling out every finite public tree;
- exact action-conflict counting (`0` iff action sufficiency);
- first-winning-depth synthesis with a proof of depth optimality;
- exact one-step and full-transcript posterior theorems;
- a checked learned-packet boundary with safe abstention;
- proof-relevant worst-case cost certificates and global cost lower bounds;
- proof-relevant simulations transferring abstract wins to concrete games.

The compiled examples cover one-step discrimination, permanent aliasing,
global cost optimality, learned-packet acceptance, and a genuinely adaptive
two-step case in which the first authorized query returns the same response in
both worlds but unlocks the discriminating query.

```bash
lake build
bash scripts/audit_constructive.sh
```

`solveChecked` emits `LOSE` only when the computed layer is stable.  Its
certificate proves that the complement contains no target and that every
playable query has a realizable counter-response remaining in the complement;
therefore no finite public repair tree can win from its root.  It emits `open`
when the requested depth is insufficient and stability has not yet been shown.

`solveTotal` is the intrinsic solver: a constructive counting proof shows that
the winning iteration is stable after at most the number of explicitly
enumerated public states.  It therefore returns exactly one of `WIN` and
`LOSE`; it has no `open` branch and assumes no external rank or horizon.

`solveDepthOptimal` searches the first winning layer and returns either a tree
at the minimum possible public-query depth or the stable losing certificate.

Cost optimality is deliberately separated into two independently checkable
parts: `costLowerPotentialB` exhaustively checks a finite adversarial lower
potential, while `CertifiedWorstCaseCost` recomputes all concrete executions
of the candidate. `optimal_lower_bound` then compares the emitted cost against
every other finite certified public tree, without a depth restriction. The
one-step cost example compiles an attained global optimum.

The learned component is not trusted. `checkedLearnedAction?` emits an action
only when the finite checker accepts coverage, certified target status,
closure retention, and agreement with the certified decision. Rejection is
an explicit abstention; an emitted action is proved correct for every concrete
world consistent with the supplied trace.

No result in this directory is considered complete until `lake build` succeeds and every Lean file ends with a clean `AXIOM_AUDIT` block.
