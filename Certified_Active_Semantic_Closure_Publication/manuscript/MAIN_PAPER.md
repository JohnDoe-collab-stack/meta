---
title: "Certified Online Repair of Action-Sufficient Latent Representations"
subtitle: "Information Necessity, Adaptive Characterization, and Constructive Finite/Open Guarantees"
authors: "Anonymous authors"
date: "2026-07-18"
version: "1.2.0"
submission: "Anonymous manuscript"
bibliography: "../supplement/REFERENCES.bib"
reference-section-title: "References"
link-citations: true
---

# Abstract

Partial observability creates action-relevant aliasing when two latent
situations share the same accessible representation but require incompatible
continuations. Detecting this obstruction does not by itself repair it. We give
a constructive theory and an executable Lean 4 realization of the complete
cycle: typed detection, authorized use, reading-dependent transport, active
query, environmental response, provenance-carrying repair, cumulative state
update, and intrinsic successor execution. We first prove an
information-necessity theorem: no controller factored through an aliased visible
representation can be correct on both hidden situations. We then prove that
compatible-world aliasing obstructs local semantic sufficiency, whereas
certified gap closure restores target determinacy, epistemic correctness, and
correctness in the actual world. For explicitly finite deterministic public
environments, we additionally prove an adaptive public no-go, characterize
certified repairability by a global action-resolving public tree, and synthesize
such a tree from sequentially composable pair separators by recursion on the
computed number of action conflicts. Exact-posterior trees and four necessity
countermodels are formalized, and a complete two-world instance establishes
non-vacuity. Three exact finite repairs strictly shrink the
compatible-world fiber, preserve earlier closures, and reach stable closure.
An open realization over natural-number indices strictly reduces the current
fiber and closes the current gap at every finite stage while never reaching
global finite closure. Finally, a five-head Int8/Int32 agent is exhaustively
certified on 697 reified local obligations across 88 batches. All formal results
are constructive and audit as axiom-free. The result is a certified solution
for the specified class of finite and cumulative-open latent-repair systems,
not a claim of unrestricted neural generalization.

# 1. Introduction

An action-sufficient representation must preserve every distinction that can
change a required continuation. Let `encode : Hidden → Visible` and
`required : Hidden → Decision`. The critical obstruction is

```text
encode(left) = encode(right)
required(left) ≠ required(right).
```

Any controller `rule : Visible → Decision` must return the same decision on the
two hidden situations. Consequently it cannot be correct on both. This familiar
shape appears in perceptual aliasing, state abstraction, belief-state planning,
predictive-state representations, and refinement of coarse abstractions. The
harder question is constructive: how can an agent discover the lost
distinction, ask for exactly the missing information, modify its internal state
without invalidating established facts, and justify the next transition?

We answer that question for a typed active-semantic-closure architecture. The
agent-accessible state contains a candidate, an observation, and a repair
history. The semantic world remains outside this view. A detector returns
either certified stasis or an operational gap. A gap determines an authorized
use, a proof-relevant transport, and an admissible query. The world returns a
typed response. The response determines a candidate patch, an observation
update, and a history record, all joined by provenance. The successor is the
execution of this intrinsic repair; it is not an independent oracle.

The paper makes six bounded claims.

1. It proves generic information necessity under visible continuation aliasing.
2. It proves a generic semantic bridge from compatible-world aliasing to
   insufficiency, and from certified closure to restored local sufficiency.
3. It characterizes repairability in the declared finite deterministic public
   class and constructively synthesizes it from composable local separators.
4. It constructs a complete finite repair trajectory with strict fiber
   reduction, cumulative preservation, termination, and stable closure.
5. It constructs a cumulative open trajectory that closes every current gap,
   preserves the learned prefix, and makes progress at every finite stage.
6. It connects the symbolic decisions to an exactly evaluated quantized agent
   on a finite, explicitly reified catalogue.

# 2. Related problem families

POMDP theory makes the information state central to planning under partial
observability [@kaelbling1998planning]. Predictive-state representations model
state through predictions of future observations [@littman2001predictive]. MDP
homomorphisms, stochastic bisimulation, and bisimulation metrics characterize
when state aggregation preserves behavior [@givan2003equivalence;
@ferns2004metrics]. Counterexample-guided abstraction refinement demonstrates
how an inadequate abstraction can be refined from evidence of failure
[@clarke2000cegar]. Causal representation learning emphasizes latent variables
whose meaning and behavior persist under interventions
[@scholkopf2021causal; @ahuja2023interventional], while active causal learning
uses interaction to reveal causal factors [@sontakke2021causal]. Continual
learning studies preservation of previously acquired competence
[@kirkpatrick2017overcoming].

Our formal object intersects these traditions but is not identified with any
one of them. The distinctive contribution proved here is their typed
composition: an explicit aliasing obstruction is consumed by a causal chain
whose query is downstream of a gap and transport, whose repair carries response
provenance, whose successor is definitionally repair-driven, and whose
finite/open guarantees are machine checked constructively. We do not claim
historical priority for every component or an empirical advantage over these
families.

# 3. Formal setting

## 3.1 Active closure data

An `ActiveClosureData` instance supplies semantic worlds `W`, candidates `C`,
observations `O`, repair records `R`, visible indices `I`, predictions `P`,
targets `T`, candidate patches, and functions

```text
interpret : C → I → P
evaluate  : W → I → T
observe   : W → O
applyCandidatePatch : C → Patch → C.
```

The relation `Agrees : P → T → Prop` has unique targets: if one prediction
agrees with two targets, those targets are equal. This is the sole property
needed to turn known correctness into fiber determinacy.

The agent view is

```text
AgentState = candidate × observation × history,
```

whereas the closed semantic state additionally stores the inaccessible world.
Compatibility `CompatibleWithViewHistory(view, world)` describes the current
fiber of worlds consistent with what the agent has learned.

## 3.2 Gaps, interaction, and repair

An operational gap carries a visible index, a kind (`witnessedMismatch` or
`unresolvedFiber`), and observable evidence. It contains neither the semantic
world nor an expected private answer. The causal chain is

```text
detectGap
→ authorize
→ executeTransport
→ selectQuery
→ respond
→ buildRepair
→ executeRepair.
```

`IntrinsicRepair` contains a candidate patch, observation update, history
record, a proof that these data were derived from the response, and a complete
provenance witness connecting state, gap, use, transport, query, response, and
updates. `nextState` executes precisely this chain. On `closed`, it returns the
same state; on `open gap`, it executes the constructed repair.

## 3.3 Correctness and fiber determinacy

`CorrectAt(world,candidate,index)` means that the candidate prediction agrees
with the semantic target. `KnownCorrectAt(view,candidate,index)` quantifies this
property over every compatible world. `FiberDeterminateAt(view,index)` states
that every two compatible worlds have the same target at the index.

`GapClosedBy(system,before,gap,after)` requires world preservation, actual-world
compatibility after repair, and known correctness at the exact gap index.

# 4. Main generic results

## 4.1 Information necessity

`ContinuationAliasing` contains two hidden situations with equal visible codes
and separated required decisions.

**Theorem 1 (visible information necessity).** For any types and any functions
`encode` and `required`, if `ContinuationAliasing encode required` holds, no
rule `Visible → Decision` can be correct on both aliased situations.

The proof is constructive. Equality of visible codes yields equality of the
rule outputs by congruence. The two correctness equalities would then identify
the required decisions, contradicting their supplied separation.

At the semantic level, `LatentAliasing(system,view,index)` contains two worlds
in the same compatible fiber whose targets at `index` are separated.

**Theorem 2 (semantic information necessity).** Latent aliasing refutes
`FiberDeterminateAt`; therefore no candidate can satisfy `KnownCorrectAt` at an
aliased index.

The target-uniqueness law is essential here. Known correctness would make one
prediction agree with the two separated targets, forcing them to be equal.

## 4.2 Sufficiency restored by closure

`RestoredLocalSufficiency` records four properties after repair: actual-world
compatibility, correctness over the whole compatible fiber, fiber target
determinacy, and correctness in the actual world.

**Theorem 3 (closure restores local sufficiency).** Every
`GapClosedBy(system,before,gap,after)` constructively yields
`RestoredLocalSufficiency(system,after,gap.index)`.

Known correctness is already part of gap closure. It yields determinacy through
target uniqueness and actual correctness through the certified compatibility
of the preserved world. Hence any post-repair aliasing at the repaired index is
impossible.

This theorem closes the missing logical bridge between “the current gap was
closed” and “the repaired representation is locally sufficient for that
continuation.” It does not identify semantic worlds or internal poles; it only
proves equality of the task-relevant target on the remaining fiber.

## 4.3 Adaptive repairability characterization

The stronger finite result separates private semantic worlds from public
strategy state. A `PublicRepairTree` is built only from a public state, an
obligation, authorized queries, realizable public responses, and
`PublicRepairStep` values. The world appears only in semantic execution, where
it determines the response. Every step stores posterior soundness, retention
of every compatible world producing the response, response provenance, frame
preservation, strict-identity conservativity, transport coherence, and
consistency.

For a finite world list, `ActionConflict(s,g,w₁,w₂)` is coexistence in the
public fiber plus disagreement of required actions. The executable measure
`μAction(s,g)` counts such ordered conflicts in one fixed global pair list.

**Theorem 4 (conflict measure).** `μAction(s,g)=0` exactly when the fiber at
`s` is action-sufficient. If a posterior is included in the prior fiber and
eliminates a selected conflicting pair, `μAction` strictly decreases.

`PubliclyIndistinguishable` quantifies over the same public trees admitted by
the positive definition. Equality of transcripts entails equality of their
explicitly recorded terminal public states.

**Theorem 5 (adaptive public no-go).** Two compatible worlds that require
different actions and remain publicly indistinguishable under every admitted
repair tree refute `CertifiedRepairableAt`.

`UniformlyActionResolvableAt` contains one public tree whose every leaf is
action-sufficient. `CertifiedRepairableAt` additionally closes every leaf with
a public candidate, provenance, frame, identity, transport, and consistency
certificate.

**Theorem 6 (operational characterization).** Given a total public compiler
that realizes a correct candidate on every nonempty homogeneous fiber,
certified repairability is equivalent to uniform action resolvability.

Pairwise separation only at the initial state is insufficient. A
`ComposablePairSeparatingEpisode` eliminates its selected conflict on every
leaf and returns the declared repair-domain invariant on every leaf.

**Theorem 7 (constructive synthesis).** Composable adaptive pair separation,
initial invariant validity, public-fiber nonemptiness, and total homogeneous
decision realization construct a certified repairability witness. Each
recursive continuation is accepted only after a derived strict decrease of
`μAction`; no external rank or terminal bridge is supplied.

For a canonical exact-response compiler, `GeneratedByExactCompiler` restricts
the exactness claim to trees built by that compiler.

**Theorem 8 (exact leaf posterior).** At every leaf of a compiler-generated
tree, the represented public fiber is equivalent to the worlds following that
leaf transcript.

Four finite countermodels isolate the indispensable hypotheses: initial pair
separation need not compose; a homogeneous fiber need not be expressible by
the candidate language; a private-world policy invalidates a public no-go; and
posterior inclusion alone need not preserve a protected frame. A two-world
exact instance satisfies the complete interfaces and is closed by the generic
synthesizer.

The published finite and open realizations are also connected back to this
interface. A `BinaryPublicFiberAdapter` maps the binary protocol’s initial and
two response states to legacy public views and proves exact compatibility on
the two worlds already carried by the corresponding aliasing certificate. It
also aligns the selected responses and required actions, retains the legacy
`CertifiedLatentRepairStep`, and carries the public repairability witness.

**Theorem 9 (legacy-instance integration).** Each of the three finite repair
steps admits such an exact binary-slice adapter, and every natural stage of the
open orbit admits one for its two completion worlds. The finite adapters join
at their actual successor states, and the open adapter at stage `n` joins the
adapter at stage `n+1`. This theorem does not identify the complete 27-world
finite domain or the infinite Boolean-stream space with a binary universe.

# 5. Complete certified repair steps

A `CertifiedLatentRepairStep` packages the obligations needed for one complete
step:

```text
detected open gap
typed semantic evidence
pre-repair latent aliasing
strictly informative selected query
successor = intrinsic system.nextState
strict compatible-fiber reduction
gap closure
restored local sufficiency
impossibility of post-repair aliasing at the repaired index.
```

The “informative” property refers to the exact query selected downstream of the
system’s authorized use and transport. It is witnessed by two currently
compatible worlds that return separated responses. Strict reduction is set
inclusion from the later compatible fiber into the earlier one plus an explicit
world that was compatible before and incompatible after.

# 6. Finite realization

The finite domain has three indices and three semantic values. The canonical
trajectory is

```text
state0 → state1 → state2 → state3.
```

At `state0`, an observed mismatch is repaired at the first index. At `state1`
and `state2`, unresolved compatible-world fibers are repaired at the second and
third indices. For every step, the formal certificate supplies two compatible
worlds with separated targets, proves that the selected query returns separated
responses, executes a response-derived repair, exhibits a world eliminated
from the compatible fiber, and proves known and actual correctness at the
repaired index.

Non-regression is cumulative: the first repaired prefix is known correct in
`state1`, the first two indices in `state2`, and all three in `state3`. Repair
records are retained in history. A natural measure counts the remaining open
gaps and decreases exactly `3 → 2 → 1 → 0`. At the bound, the complete finite
domain is both actually and epistemically closed. The detector returns
`closed`, and `nextState(state3) = state3`.

Crossed-response interventions show necessity inside the instance: replacing
the actual response by the separated compatible-world response produces an
actual-world-incompatible successor and cannot close the gap.

# 7. Cumulative open realization

The open world is a Boolean stream `Nat → Bool`; the candidate is a finite list.
At stage `n`, the fresh gap index is the current list length, exactly `n`. Two
completion worlds agree with the whole current candidate but assign `false` and
`true` to the fresh index. They therefore witness latent aliasing at every
finite stage.

The selected query reveals the fresh value. Its two responses on the completion
worlds are separated. The actual baseline response is appended to the
candidate, observation, and history. The opposite completion remains a
constructive witness of strict fiber reduction: it was compatible before the
query and is incompatible afterward. The repaired index becomes known correct
over every remaining compatible world, while every previously learned entry is
preserved and remains known correct.

Thus, for every `n`:

```text
the gap at n is typed and detected;
the selected query is informative;
state(n+1) is the intrinsic repaired successor;
the current fiber strictly shrinks;
the current gap is closed;
the repaired prefix is preserved;
state(n+1) ≠ state(n).
```

There is nevertheless a fresh index at every finite stage, so no finite state
is globally closed. This is not failed termination: it is a constructive
open-world guarantee of local closure plus cumulative progress without a false
terminal oracle.

# 8. Visible/passive impossibility and positive separation

The generic information-necessity result is complemented by two executable
no-go families. A passive policy starting from identical agent views produces
the same run independently of which compatible semantic world is actual, so it
cannot guarantee correctness in two worlds requiring separated targets. A
visible-factored controller likewise cannot choose two different required
queries for full states sharing one visible projection. Seeded variants are
covered for every fixed seed.

The active controller escapes the obstruction only by acquiring information:
it selects a query whose response differs across the aliased worlds, then stores
that response in the repaired view. The theorem is therefore not that active
interaction magically recovers hidden data; it is that simultaneous correctness
requires preserving, acquiring, or relinquishing the missing distinction, and
the constructed system realizes the acquisition branch.

# 9. Constructive foundations

All new and inherited publication declarations are checked in Lean 4 without
`Classical`, `propext`, `Quot.sound`, `sorry`, `admit`, or introduced axioms.
Lean 4 provides the dependent theorem-proving and programming substrate used
for these kernel checks [@demoura2021lean4].
Strict equality retains ordinary substitution. Non-identitarian uses and
transports do not collapse their endpoints into equality. The foundational
realizations prove strict-identity conservativity, closed syntactic consistency,
non-projectivity of asymmetric use, and non-reduction of transport semantics to
the bare use graph.

This separation matters for latent repair: closing a task-relevant gap means
making the remaining compatible worlds agree on the required target, not
declaring the latent poles identical.

# 10. Quantized execution certificate

The executable agent has five heads: gap, use, transport, query, and repair.
Weights, inputs, integer affine computations, Int32 bounds, ties-to-even
rounding, Int8 saturation, reserved-class masks, canonical argmax, and winner
margins are reified in Lean. Eighty-eight numerical batches cover 697 explicit
examples:

```text
gap:        15
use:        22
transport:  44
query:      88
repair:    528
total:     697.
```

A parallel set of 88 semantic-alignment batches links every reified reference
to an input computed from the dependent finite semantics and proves complete,
duplicate-free head coverage. `SemanticallyClosedCertifiedRun` combines this
alignment with exact numerical validity and strict margins.

This is a finite catalogue theorem. It does not establish robustness regions,
performance on unseen distributions, or statistical generalization. Those
claims require a separate experimental campaign.

# 11. Scope of the solution

The aggregate `certifiedAdaptiveClosurePublicationValidation` combines the
earlier `certifiedLatentRepairPublication` with the adaptive characterization
and its inhabited exact instance. The artifact covers a generic finite
deterministic public class under explicit composable-separator and
decision-realization interfaces, plus two formally explicit trajectory
classes:

- a closed finite task whose internal measure reaches stable sufficiency; and
- a cumulative open task whose intrinsic data consume every nonterminal branch
  by closing the current gap and exposing the next fresh one.

The reusable generic contribution covers information necessity, the
aliasing/closure/sufficiency bridge, the adaptive public no-go, the operational
characterization, and well-founded public-strategy synthesis under their
declared constructive interfaces. Detection completeness, query
informativeness, strict reduction, and preservation are not asserted for an
arbitrary user-supplied detector; they are proved for every stage of both
published realizations. This boundary prevents an implementation law from being
smuggled in as a universal theorem.

Responses are exact and trusted as environmental observations. The artifact
does not yet cover noisy or adversarial responses, repair rollback, concurrent
gaps, continuous latent regions, learned detectors beyond the finite catalogue,
or external benchmark superiority.

# 12. Conclusion

Action-relevant aliasing is not resolved by relabeling a representation as
“sufficient.” It creates a proof obligation: either the missing distinction is
already accessible, it must be acquired, or simultaneous correctness is
impossible. We formalized that trilemma, characterized when a public acquisition
strategy exists in the declared finite class, and synthesized it from
composable local separators. We also constructed the acquisition branch through
a typed causal repair chain. The finite realization terminates with
stable closure; the open realization closes every current gap while preserving
all learned entries and continuing indefinitely. Certified closure is shown to
restore the precise local sufficiency that aliasing had obstructed. Together
with the conservative foundations and exact quantized execution, this yields a
self-contained, machine-checkable solution to certified online repair for the
specified finite and cumulative-open latent systems.

# Artifact availability

The anonymous artifact accompanies this manuscript. The exact build command,
claim-evidence matrix, axiom audit, checkpoint boundary, and staged
reproduction protocol appear in the supplement. No proposition is imported
from a JSON verdict; the Lean kernel checks the proof terms.
