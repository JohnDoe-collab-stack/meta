# Implementation status

This file states the implemented boundary conservatively.  A checked box means
that the corresponding declaration is compiled by the default `lake build`
and included in the constructive audit.

## Decidability and fixed point

- [x] complete finite carriers and Boolean reflection lemmas;
- [x] exact target and realizable-response checkers;
- [x] controllable predecessor soundness, completeness, and monotonicity;
- [x] intrinsic stabilization after at most the number of public states;
- [x] least closed winning predicate;
- [x] total `WIN`/`LOSE` result with no external horizon;
- [x] exclusivity of positive and negative certificates;
- [x] equivalence between finite public trees and winning-layer membership;
- [x] stable-complement counter-strategy against every finite tree.

## Repair semantics

- [x] actual-world retention on every authorized realized branch;
- [x] fiber monotonicity and explicit closure retention in the game contract;
- [x] exact posterior as an independently supplied completeness law;
- [x] exact posterior over arbitrary finite certified transcripts;
- [x] exact action-conflict count, zero iff the fiber is action-sufficient;
- [x] adaptive preparatory-query example: depth one loses, depth two wins;
- [x] first-winning-depth extraction and proof of depth minimality.

## Cost, learning, and abstraction

- [x] proof-relevant execution-cost recomputation;
- [x] finite Boolean checker for adversarial cost lower potentials;
- [x] attained worst-case cost certificate;
- [x] global lower bound against every other finite certified public tree;
- [x] compiled globally optimal cost instance;
- [x] learned-packet checker, concrete-world transfer, and safe abstention;
- [x] accepted and forged/rejected learned-packet instances;
- [x] proof-relevant forward simulation and abstract-win transfer.

## Verification boundary

The Lean kernel proves finite constructive theorems. It does not claim that a
neural model will produce accepted packets frequently, generalize out of
distribution, or improve empirical query cost. Those are empirical hypotheses
for the separate preregistered campaign. No empirical result is inferred from
`lake build`.

The present cost layer verifies global optimality from an attained candidate
and a checked lower potential. It does not yet synthesize the optimal potential
for every arbitrary weighted game. Consequently the formal claim is
"globally verified optimum when the certificate is accepted", not yet
"automatic optimal synthesis for every input game".

Run:

```bash
lake build
bash scripts/audit_constructive.sh
```
