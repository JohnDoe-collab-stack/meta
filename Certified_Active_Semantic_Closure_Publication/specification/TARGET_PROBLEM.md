# Normative target problem

## Objective

Construct and certify an agent that can determine when its current accessible
latent state has contracted a distinction required for continuation, acquire
the missing information through an authorized interaction, repair its
candidate/observation/memory with causal provenance, preserve prior certified
knowledge, and either reach finite stable sufficiency or continue with
certified local progress in an open domain.

## Input obstruction

The representation is action-insufficient when either of the following holds.

Visible continuation aliasing:

```text
encode(left) = encode(right)
required(left) ≠ required(right).
```

Compatible-world semantic aliasing:

```text
Compatible(view,leftWorld)
Compatible(view,rightWorld)
evaluate(leftWorld,index) ≠ evaluate(rightWorld,index).
```

## Required constructive output

A satisfactory solution must expose, not merely assert, this chain:

```text
aliasing witness
→ detected typed gap that does not contain the private world answer
→ authorized use and proof-relevant transport
→ exact selected query with a compatible-world response separation witness
→ environmental response
→ patch, observation update, and history record derived from that response
→ complete repair provenance
→ successor equal to execution of the intrinsic repair
→ strict compatible-fiber reduction or direct certified closure
→ preservation of earlier certified entries
→ known and actual correctness at the repaired index
→ target determinacy on the remaining compatible fiber.
```

## Termination/progress alternative

Closed finite domains must carry an internal decreasing measure and reach a
detector-closed stable state. Open domains must not use an external terminal
bridge; every finite nonterminal branch must be consumed by intrinsic data,
closing the current gap, preserving the repaired prefix, and making an
effective transition.

## Information-necessity requirement

The positive construction must be paired with a no-go result: a controller that
receives only the aliased visible code cannot guarantee both separated required
continuations. A correct architecture must preserve the distinction, acquire
information that reveals it, or relinquish simultaneous correctness.

## Acceptance criteria

- All formal declarations are constructive and axiom-free.
- The generic no-go and closure-to-sufficiency bridge quantify over their
  explicit interfaces.
- Implementation-specific properties are proved for every published stage,
  not promoted to a false universal statement.
- Repairs are response-derived and provenance-carrying.
- Earlier known-correct entries survive subsequent repairs.
- The finite realization terminates internally.
- The open realization proves local closure and strict progress for every
  natural stage without claiming finite global closure.
- The final theorem aggregates all obligations in one inhabited certificate.
- Neural claims are limited to exactly reified finite inputs unless a separate
  generalization theorem is supplied.

## Realization in this package

The acceptance object is

```text
Meta.ActiveSemanticClosure.LatentRepair.plannedProblemResolutionAudit
```

in `artifact/Meta/LatentRepair/ProblemResolutionAudit.lean`. It rechecks the
publication theorem together with obligations that make finite closure and
open nonterminal progress explicit. The detailed one-to-one evidence maps are
in `supplement/PROBLEM_RESOLUTION_AUDIT.md`,
`supplement/CLAIM_EVIDENCE_MATRIX.md`, and
`supplement/TECHNICAL_APPENDIX.md`.
