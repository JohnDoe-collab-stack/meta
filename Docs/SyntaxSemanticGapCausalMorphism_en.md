# Syntactic gap and causal morphism

## Principle

The gap is neither a numerical distance nor a comparison between two truth
values. It is a distinguished arithmetic sentence, constructed syntactically
from the current state. This sentence provides the syntactic handle through
which the local evaluation can be extended without being confused with the
syntax.

At each state, the function `gap` designates one current gap. This
individuation does not mean that the system has no other disagreement or
independent sentence. It means that a canonical syntactic event is selected to
mark the current evaluation frontier, cause the next step, and then enter the
causal domain that has already been evaluated.

The exact extension property concerns event memory: one step records exactly
the current gap and preserves all previous events.

```text
Memory(advance(S), d)
↔ d = gap(S) ∨ Memory(S, d)
```

This law is more precise than the three minimal laws of the causal system:

```text
(A) the current gap is absent from the current memory;
(I) the next step records the current gap;
(C) the next step preserves all previous memory.
```

The laws `(A)(I)(C)` suffice for freshness, causal non-recurrence, and additive
faithfulness. The exact extension law additionally states that exactly one new
event is added at each step. Further local laws then relate this syntactic
memory to the evaluation proper to each system.

## Two distinct layers

### Common syntactic layer

```text
Sentence
Predicate
diagonal : Predicate → Sentence
```

`Sentence` and `Predicate` are scoped arithmetic formulas. `diagonal` is a
syntactic transformation. Its definition decides no truth and queries no
provability relation.

For a predicate `τ : Predicate`, its code is a number distinct from the formula
itself:

```text
τ : Predicate
τ.raw.code : Nat
diagonal(τ) : Sentence
```

The diagonalizer consumes `τ`, not merely its numerical code.

### Local evaluation interfaces

The Tarskian system has its local interpretation:

```text
models : Sentence → Prop

truthAt(p, s)
:⇔ models(p applied to the code of s).
```

The theory system has its local derivability relation:

```text
Theorems(S, s)
:⇔ TheoryProvable(S.history, s).
```

Only at the root does `Theorems(initialPAState, s)` coincide with
`PAProvable(s)`. After an extension, the relevant relation is provability in
the current history, not provability in PA alone.

The causal morphism neither identifies nor compares the two interfaces. Each
system nevertheless retains its own local adequacy theorems. In particular,
the arithmetic provability formula must be related to the metatheoretic
relation it represents:

```text
models(provabilityPredicate(h) applied to the code of s)
↔ TheoryProvable(h, s).
```

This theorem belongs to the provability system. It does not compare the truth
of the Tarskian gap with the derivability of a gap in the theory system.

## Factorization of evaluation through the gap

Separating syntax from semantics does not isolate syntax from all evaluation.
It requires the passage from one to the other to be explicit and local to each
system.

The two realizations therefore have distinct evaluation relations:

```text
Evaluated_T(S, d)
:⇔ the current candidate of S is correct at sentence d

Evaluated_P(S, d)
:⇔ the theory carried by S proves sentence d.
```

In system `T`, `Evaluated_T` is defined from `CorrectAt`, hence from `truthAt`
and `models`. In system `P`, `Evaluated_P` is defined by `TheoryProvable`. No
equivalence between these two relations is required.

In each system, memory supplies a certified causal domain of evaluation:

```text
Memory_T(S, d)
→ Evaluated_T(S, d)

EventMemory_P(S, d)
→ Evaluated_P(S, d).
```

The converse is not required. A candidate may be correct at a sentence that
has not been memorized, and a theory generally proves many more sentences than
the events recorded in its history. Memory therefore does not represent the
entire extension of the evaluator; it represents the causally constructed and
positively preserved subdomain.

The current gap is the syntactic frontier of that domain:

```text
¬Evaluated_T(S, gap_T(S))

¬Evaluated_P(S, gap_P(S)).
```

The step caused by this gap constructs the next evaluator by incorporating the
gap, then certifies that this incorporation actually extends the local
evaluation:

```text
Evaluated_T(advance_T(S), gap_T(S))

Evaluated_P(advance_P(S), gap_P(S)).
```

This closure is not an independent discovery made by the evaluator after the
step. It is targeted by the very definition of `advance`: the gap becomes
constitutive of the state defining the next evaluator. The law
`frontier_closed` certifies that the syntactic construction produces the
announced evaluation effect. It does not decide the truth of the gap and
transports no semantic value between the systems.

Evaluations already acquired are preserved:

```text
Evaluated_T(S, d)
→ Evaluated_T(advance_T(S), d)

Evaluated_P(S, d)
→ Evaluated_P(advance_P(S), d).
```

In `T`, the first preservation law follows from mismatch at the current gap
and preservation of the patch away from that index. In `P`, the second follows
from transporting derivations into the extended theory.

The common interface to formalize can be presented as follows:

```text
GapMediatedEvaluation(State, Gap) :
  gap       : State → Gap
  Memory    : State → Gap → Prop
  Evaluated : State → Gap → Prop
  advance   : State → State

  memory_sound :
    Memory(S, d) → Evaluated(S, d)

  frontier_open :
    ¬Evaluated(S, gap(S))

  frontier_closed :
    Evaluated(advance(S), gap(S))

  evaluation_preserved :
    Evaluated(S, d) → Evaluated(advance(S), d)

  memory_exact :
    Memory(advance(S), d)
    ↔ d = gap(S) ∨ Memory(S, d).
```

This interface is the propositional projection of the mechanism. It suffices
to apply the causal Core, but it must not be the primary transport object: a
witness of `Memory(S, d) : Prop` cannot in general be eliminated
constructively to manufacture data in `Type`.

### Positive realization by positions

The primary object is the type of causal occurrences already recorded. Each
position carries its sentence and its local evaluation certificate:

```text
PositiveGapMediatedEvaluation(State, Gap) :
  gap       : State → Gap
  Position  : State → Type
  label     : Position(S) → Gap
  Evaluated : State → Gap → Prop
  advance   : State → State

  position_evaluated :
    Evaluated(S, label(p))

  advancePositions :
    ConstructiveEquivalence(
      Position(advance(S)),
      Option(Position(S)))

  newest_label :
    label(advancePositions⁻¹(none)) = gap(S)

  inherited_label :
    label(advancePositions⁻¹(some(p))) = label(p)

  frontier_open :
    ¬Evaluated(S, gap(S))

  evaluation_preserved :
    Evaluated(S, d) → Evaluated(advance(S), d).
```

`none` designates the newly created position, while `some(p)` preserves an
earlier position. `ConstructiveEquivalence` is positive data consisting of two
inverse functions; it uses neither choice nor a quotient.

The propositional memory is then defined by forgetting the position, but only
after transport:

```text
Memory⁺(S, d)
:⇔ there exists p : Position(S), label(p) = d.
```

The constitutive laws are no longer independent fields:

```text
frontier_closed
  follows from the none position, newest_label,
  and position_evaluated in advance(S);

memory_exact
  follows by analyzing advancePositions(p) : Option(Position(S));

memory_sound
  follows directly from position_evaluated;

gap_absent
  follows from memory_sound and frontier_open;

gap_inscribed and memory_preserved
  follow respectively from the none and some branches.
```

This formulation makes the role of the gap exact. The current gap evaluates
nothing by itself in the source state. `advance` transforms it into a new
positive occurrence; this occurrence then belongs to the certified causal
domain of the successor evaluator. Closure of the former gap is therefore
constructed from its new position, whereas frontier openness and preservation
of all evaluation remain theorems proper to the system.

One must not define a function of the form:

```text
positionOfMemory : Memory⁺(S, d) → Position(S).
```

Such a function would require extracting data in `Type` from an existential
proof in `Prop`. The morphism will transport `Position` directly;
`Memory_T` and `EventMemory_P` will only be their extensional projections.

Both systems must supply closed realizations of this positive interface. They
share its causal form, but each constructs `position_evaluated`,
`frontier_open`, and `evaluation_preserved` using its own evaluator.

### Status of the interface laws

The five laws are not independent in the same sense and do not carry the same
proof-theoretic content.

The constitutive laws express what the construction of `advance` is designed
to produce:

```text
frontier_closed
memory_exact.
```

They must nevertheless be proved. Defining the next state is not enough by
itself: one must show that the local evaluator correctly recognizes the
syntactic incorporation of the gap and that the memory representation has
exactly the announced form.

The obstruction law carries the negative content that makes the step
necessary:

```text
frontier_open.
```

It does not follow from adding the gap. In `T`, it follows from diagonal
mismatch. In `P`, it must follow from Rosser independence and consistency of
the current state.

The coherence laws relate causal history to the local evaluator and guarantee
that advancing does not destroy what has already been acquired:

```text
memory_sound
evaluation_preserved.
```

The strength of the system therefore does not lie in `frontier_closed` taken
in isolation, but in the following conjunction:

```text
a frontier that is genuinely open before the step
+ closure constructed and certified by advance
+ exact memory of the event
+ preservation of previous evaluations
+ a fresh new frontier after the step.
```

Every instance of `GapMediatedEvaluation` then supplies the three laws of the
causal Core by forgetting the particular nature of `Evaluated`:

```text
gap_absent
  follows from memory_sound and frontier_open;

gap_inscribed
  follows from memory_exact with d = gap(S);

memory_preserved
  follows from memory_exact by retaining the former branch.
```

The causal Core thus receives a common structure because the gap has already
mediated, within each realization, the passage from syntax to its local
evaluation. Forgetting down to `(A)(I)(C)` removes the nature of the evaluator
but retains the causal consequences of that mediation.

The role of the gap can therefore be summarized without mixing the layers:

```text
state syntax
→ construction of the gap
→ current frontier of the local evaluation
→ advance caused by the gap
→ local evaluation of the former gap
→ recording in the certified causal domain
→ production of a new frontier.
```

The gap is not itself an evaluator and carries no universal semantic value. It
is the syntactic object that makes a controlled extension of each local
evaluator possible.

## Provability predicates and diagonal sentences

Once the numerical checker has been built and represented in arithmetic, each
finite history `h` supplies a genuine unary formula:

```text
provabilityPredicate(h) : Predicate
```

The negative diagonal of this predicate supplies the simple Gödel sentence:

```text
godelSentence(h)
:= diagonal(provabilityPredicate(h)).
```

This sentence remains useful for internal theorems of diagonalization and
provability. It is not the gap chosen for the closed progression based on
consistency alone.

To build a sequence of theories whose consistency is preserved at every step,
the gap is the Rosser sentence:

```text
rosserBadPredicate(h) : Predicate

rosserSentence(h)
:= diagonal(rosserBadPredicate(h)).
```

From consistency of the history, the Rosser construction provides:

```text
¬TheoryProvable(h, rosserSentence(h))

¬TheoryProvable(h, negation of rosserSentence(h)).
```

The second non-provability transforms any contradiction in the extension into
a contradiction in the source theory. It therefore supplies consistency of
the next state without adding soundness, 1-consistency, or ω-consistency.

## Tarskian causal system

The complete Tarskian state contains the current candidate and the positive
memory of the path that produced it:

```text
State_T := CausalState

current_T : State_T → Predicate
Memory_T  : State_T → Sentence → Prop

Evaluated_T(S, d)
:⇔ CorrectAt(current_T(S), d).
```

The gap and advance are:

```text
gap_T(S)
:= diagonal(current_T(S))

advance_T(S)
:= the state obtained by replacing current_T(S) with
   patch(current_T(S), gap_T(S))
   and extending its causal memory.
```

The patch is purely syntactic. It inserts the selected sentence into a local
formula without deciding whether that sentence is true. Its certificate then
proves:

```text
the new candidate is correct at the former gap;
the previous behavior is preserved away from that index;
the former gap is memorized;
the new gap is absent from the new memory.
```

The status of the laws is precise:

```text
frontier_open_T
  follows from the diagonal fixed point and local mismatch;

frontier_closed_T
  follows from patch_agrees_at;

memory_exact_T
  follows from the inductive shape of memory extension;

memory_sound_T
  follows by induction over memory, using repair of every former gap
  and its preservation by later patches;

evaluation_preserved_T
  follows from mismatch at the current gap and
  patch_preserves_off_index.
```

`frontier_closed_T` is close to the design of the patch, but it is not merely
a definitional equality. The patch syntactically contains sentence `d` in the
branch selected at the code of `d`. One must still prove, in the semantics of
formulas, that this branch is actually selected and that its interpretation
coincides with `models(d)`. This proof certifies incorporation of the gap; it
does not compute whether `d` is true or false.

Tarskian memory is semantically certified but remains syntactic and causal
data:

```text
Memory_T(S, d)
→ Evaluated_T(S, d).
```

This implication is proved locally in `T`. It introduces no relation with
provability in system `P`.

A bare `Predicate` does not suffice as a causal state: two states with the same
visible behavior may retain different histories. Memory is part of the causal
identity of the state.

The positive realization needed for transport is already present in the
Tarskian code:

```text
Position_T(S)
:= CausalState.MemoryPosition(S)

label_T(p)
:= CausalMemory.sentenceAt(S.memory, p).
```

The definition of `CausalMemory.Position` has exactly the expected shape:

```text
Position_T(root) = empty type

Position_T(advance_T(S))
= Option(Position_T(S)).
```

The `none` position carries the gap just repaired, while `some(p)` preserves
the former position. The already compiled theorems establish:

```text
CausalMemory.position_remembered
  : every position supplies a memory witness;

CausalMemory.remembers_iff_position
  : Memory_T(S, d) is equivalent in Prop to the existence
    of a position labelled d;

CausalMemory.sentenceAt_injective
  : two positions with the same label are equal;

CausalMemory.positionEquivalence
  : positions are constructively equivalent to the intrinsic
    finite causal time of memory.
```

The certificate `position_evaluated_T` is obtained by composing
`position_remembered` with `CausalMemory.correctAt_of_remembers`. The positive
part of the interface therefore does not require rebuilding Tarskian memory;
it only remains to package it under the common interface.

## Causal system of theories

A history is a finite, positively constructed sequence of sentences added to
PA:

```text
TheoryHistory.root
TheoryHistory.extend(previous, event)
```

A state carries this history together with its constructed consistency:

```text
CertifiedTheoryState :=
  finite history
  + consistency certificate for the corresponding theory.
```

The gap and advance are:

```text
gap_P(S)
:= rosserSentence(S.history)

advance_P(S)
:= the state whose history is
   S.history.extend(gap_P(S)),
   with the consistency certificate produced by the Rosser theorem
   and the deduction theorem for finite extensions.
```

The transition adds a sentence without running a procedure that attempts to
decide its provability. Certification of the new state uses the independence
theorems already constructed.

Two observables remain separate:

```text
EventMemory_P(S, d)
:⇔ d occurs in S.history

Theorems_P(S, φ)
:⇔ TheoryProvable(S.history, φ).

Evaluated_P(S, φ)
:⇔ Theorems_P(S, φ).
```

The arithmetic code already has a positive occurrence indexed by the
sentence:

```text
TheoryHistory.Contains : Sentence → TheoryHistory → Type.
```

`newest` designates the last sentence added, and `earlier` transports a
previous occurrence. The current propositional memory is exactly the
forgetting of this witness:

```text
EventMemory_P(S, d)
:= Nonempty(S.history.Contains(d)).
```

The unindexed position required by the common interface can therefore be
defined without choice:

```text
Position_P(S)
:= Σ d : Sentence, S.history.Contains(d)

label_P(p)
:= p.1.
```

Extension has an explicit constructive equivalence:

```text
Position_P(advance_P(S))
≃ Option(Position_P(S))

⟨gap_P(S), newest⟩  ↦ none
⟨d, earlier(old)⟩   ↦ some(⟨d, old⟩).
```

The inverse maps `none` to the new occurrence and `some(p)` to `earlier(p)`.
The two identities are proved by analyzing the constructors of `Contains`; no
search and no elimination of `Nonempty` into `Type` is required.

`position_evaluated_P` is obtained by wrapping the occurrence in `Nonempty`
and then applying `historyMember_provable`. The equivalence between
`EventMemory_P(S, d)` and the existence, in `Prop`, of a position carrying `d`
is constructive as well.

One precision is necessary: `TheoryHistory` syntactically permits two equal
additions, so `label_P` is not injective on an arbitrary certified state. The
occurrence morphism does not need that injectivity. On the orbit generated
from `initialPAState`, however, `provabilityGap_not_mem` permits an inductive
proof that each new label is fresh. That property is required only if one
later wishes to forget occurrences and obtain a function on the historical
sentences themselves.

Event memory satisfies exact extension:

```text
EventMemory_P(advance_P(S), d)
↔ d = gap_P(S) ∨ EventMemory_P(S, d).
```

The collection of theorems satisfies only the appropriate laws:

```text
¬Theorems_P(S, gap_P(S))

Theorems_P(advance_P(S), gap_P(S))

Theorems_P(S, φ)
→ Theorems_P(advance_P(S), φ).
```

The declarations intended to carry these laws are present in
`ProvabilityProgression.lean`:

```text
frontier_open_P
  = provabilityGap_not_provable,
    derived from Rosser independence for the current history;

frontier_closed_P
  = provabilityGap_provable_after_advance,
    constructed by the new-axiom rule;

memory_exact_P
  = provabilityAdvance_memory_iff,
    derived by analyzing newest and earlier;

memory_sound_P
  = historyMember_provable,
    which converts an occurrence into a derivation by the axiom rule;

evaluation_preserved_P
  = provabilityTheorems_preserved,
    an explicit transformation of previous derivations.
```

These declarations are present in the source text. Their presence establishes
that the local laws of `P` have been written and connected to the expected
structures; it does not by itself certify the compilation state of their
entire import chain. One must therefore distinguish:

```text
presence of the declarations and their proofs in the sources;

verified closure of the P side
= successful compilation of the terminal target
  + a successful axiom audit in the same repository state.
```

The causal and conceptual status described here does not rely on confusing
these two levels of verification.

The proof of `frontier_closed_P` is direct once the sentence has been added:
every axiom of the current history immediately has a derivation. This does not
make `advance_P` trivial. For its result to remain a
`CertifiedTheoryState`, one must construct consistency of the extended theory.
That construction consumes the second Rosser non-provability theorem and the
deduction theorem for finite extensions.

The following distinction is therefore essential:

```text
incorporating the gap as a new axiom
→ immediate local closure of the gap;

certifying the next state
→ substantive proof that the incorporation preserves consistency.
```

The history thus also supplies a certified causal domain:

```text
EventMemory_P(S, d)
→ Evaluated_P(S, d).
```

This implication is realized by an explicit transformation that converts an
occurrence in the history into a derivation using the axiom rule.

One must not require the set of theorems to gain exactly one sentence: adding
an axiom also adds all of its consequences.

## Local repair and global openness

Each step genuinely handles its current gap:

```text
in system T, the former index is repaired;
in system P, the former sentence becomes an axiom and therefore a theorem.
```

In both cases, local closure is constructed. `advance` does not consult an
independent evaluator that later discovers the gap has been resolved. It
incorporates the gap into the structure defining the next evaluator and then
supplies the corresponding local certificate. The gap is therefore the
structural cause of its own closure in the successor state, without evaluating
itself in the source state.

What remains open is not the former gap but the progression as a whole. The
successor has a new gap, distinct from all events already memorized. Hence no
terminal state exhausts the history of gaps.

## Change of reference frame

The same data admits two readings that change neither the syntax nor the local
theorems.

### Classical reference frame

The classical reference frame first considers the obstruction produced at a
given state:

```text
the current Tarskian candidate fails at its diagonal sentence;
the current certified theory does not prove its Rosser sentence.
```

In this reading, each state is marked by a current limit. Repetition of this
form at every state expresses the global incompleteness of the progression.

Here, the word “classical” designates this obstruction-centered mode of
reading. It does not designate `LogicMode.classical` and introduces no
classical reasoning into Lean.

### Positive reference frame

The positive reference frame preserves the obstruction as causal data rather
than reducing it to a negative conclusion. The current gap becomes an
individuated event that:

```text
causes the next step;
is recorded in memory;
remains identifiable throughout future history;
extends the certified causal domain of evaluation;
causally separates the source state from its successors;
produces a new gap after it is handled.
```

“Positive” means that the gap, step, and memory are carried by internal data
and witnesses. It means neither that the gap sentence is positive in the
logical sense nor that the morphism attributes a truth value to it.

The change of reference frame therefore does not turn a false sentence into a
true sentence and does not compare truth with provability. It changes the
reading of the same phenomenon: from an observed obstruction to a syntactic
frontier that enables extension of the local evaluation, remains preserved as
an event, and generates a progression.

## Constant global incompleteness and non-constant local totalization

Global incompleteness is constant in form, not in content. At every certified
state, the system constructs a current gap absent from the relevant local
evaluation:

```text
system T: the current candidate is not correct at its diagonal gap;
system P: the current theory does not prove its Rosser sentence.
```

“Constant” means that this form of obstruction is reproduced at every state.
It does not mean that the same sentence recurs. On the contrary, causal
freshness requires the new gap to be distinct from all previously memorized
gaps.

Local totalization designates the exact handling of the current gap:

```text
system T: advance_T repairs the former diagonal index;
system P: advance_P records the former Rosser sentence as an axiom,
          hence makes it provable in the next theory.
```

This totalization is non-constant because it transforms the state to which it
applies. It produces neither a final globally correct predicate, nor a
complete theory, nor a terminal fixed point. After every treatment:

```text
the former gap belongs to memory;
the former gap belongs to the certified causal domain of evaluation;
the current state has changed;
a new fresh gap is produced;
the progression remains open.
```

The rupture can therefore be stated without a numerical measure:

```text
constant global incompleteness
= the presence, at every state, of an obstruction of the same form;

non-constant local totalization
= effective evaluation and recording of the current obstruction by a
  transformation that generates a new state and a new obstruction.
```

There is no global totalization of a single lack. There is an intrinsic
sequence of local closures, each preserved as an event and each followed by a
new gap.

## Intended causal morphism

The central morphism concerns complete causal states, their syntactic
frontiers, and their certified causal domains of evaluation. It compares
neither the values produced by `models` and `TheoryProvable` nor the relations
`Evaluated_T` and `Evaluated_P`.

The first component transports states and commutes with advance:

```text
φ : State_T → CertifiedTheoryState

φ(advance_T(S))
= advance_P(φ(S)).
```

Because `State_T` contains an inductive memory from its root, `φ` can be
defined by recursion over that memory:

```text
φMemory(CausalMemory.root)
:= initialPAState

φMemory(CausalMemory.extend(previous, event))
:= advance_P(φMemory(previous))

φ(S)
:= φMemory(S.memory).
```

The syntactic content of `event` is not mapped to an identical sentence: it
determines the causal position of the step. The corresponding Rosser gap is
reconstructed locally from the `P` state obtained at the preceding step. By
reduction on the `extend` constructor, this definition aims for definitional
commutation with `advance`, rather than a bridge added after the recursion.

This recursion supplies the state component, but it does not by itself suffice
for the intended morphism. The events constituting the certified domains must
also be transported. Every extension must preserve the correspondence between
the gap that caused the Tarskian step and the gap that caused the theory step.

The complete construction uses the causal path itself. It introduces no
numerical rank, temporal counter, or search for an external index.

The second primary component transports positive occurrences:

```text
positionMap_S :
  ConstructiveEquivalence(
    Position_T(S),
    Position_P(φ(S))).
```

It is constructed by the same recursion as `φ`. At the root, it relates the
two empty types. At every extension, it applies the `Option` functor to the
equivalence already obtained. It must therefore satisfy the following
coherence equations:

```text
positionMap_root(p)
:= elimination of the empty type

positionMap_extend(none)
:= new_P

positionMap_extend(some(p))
:= old_P(positionMap_previous(p))

positionMap_advance(new_T(S))
= new_P(φ(S))

positionMap_advance(old_T(p))
= old_P(positionMap_S(p)).
```

Here `new` is the inverse image of the `none` branch of `advancePositions`, and
`old` is that of the `some` branch. These equations rule out an arbitrary
bijection between two memories of the same size: they preserve the causal
origin of every occurrence and its retention through later steps.

The correspondence between frontiers is then a consequence of transporting
the new position. The two current gaps are the labels of positions appearing
in the successor states:

```text
gap_T(S)
= label_T[advance_T(S)](new_T(S))

gap_P(φ(S))
= label_P[advance_P(φ(S))](new_P(φ(S))).
```

Because `φ` commutes with `advance` and `positionMap_advance` sends the new
position to the new position, the morphism pairs the two frontier events
without identifying their sentences. The state indices written in brackets
are essential: `new_T(S)` and `new_P(φ(S))` are positions of the successor
states, not positions of the source states.

For every historical position `p`, the transported pair of sentences is:

```text
d_T := label_T(p)

d_P := label_P(positionMap_S(p)).
```

It immediately provides the two corresponding memory facts. Reverse transport
uses `positionMap_S⁻¹`. Thus one obtains bidirectional transport of the
certified causal domains without selecting a position from a proof of
`Memory_T` or `EventMemory_P`.

The local evaluation theorems are then applied separately:

```text
Memory_T(S, d_T)
→ Evaluated_T(S, d_T)

EventMemory_P(φ(S), d_P)
→ Evaluated_P(φ(S), d_P).
```

There is no arrow between the two `Evaluated` conclusions. The morphism shows
that the same syntactic architecture of frontier and extension receives two
different local semantic realizations:

```text
gap_T(S)  → advance_T(S)  → new_T / Position_T → Evaluated_T
   ↓              ↓                ↓
paired event      φ             positionMap
   ↓              ↓                ↓
gap_P(φ(S)) → advance_P(φ(S)) → new_P / Position_P → Evaluated_P
```

The horizontal arrows describe mediation from the gap to local evaluation.
The vertical arrows transport only syntactic and causal structure. No vertical
arrow compares the terminal semantics.

The morphism must therefore preserve the complete cycle:

```text
current frontier not evaluated locally;
syntactic gap causing advance;
local evaluation of the former gap after advance;
exact recording in memory;
preservation of the already certified domain;
appearance of a fresh new frontier.
```

This preservation distinguishes the morphism from a mere synchronization of
step counts. Two histories of the same length do not suffice: their
occurrences must be paired by an equivalence compatible with `none` and
`some`, and every transported position must continue to provide its local
evaluation certificate.

The morphism also preserves the status of the laws:

```text
both frontier_open laws remain locally proved obstructions;
both frontier_closed laws remain closures constructed by advance;
both memory_exact laws describe exact incorporation of an event;
both memory_sound laws separately relate memory to local evaluation;
both evaluation_preserved laws retain the achievements of each evaluator.
```

It does not turn a constructed closure into a semantic discovery. It shows
that two different incorporation mechanisms realize the same form of
mediation: the syntactic gap reconfigures the next evaluator, which then
locally certifies the former gap.

### Secondary global syntactic transformation

The positive morphism already supplies a syntactic transformation depending
on the state and occurrence:

```text
χ_S(p : Position_T(S))
:= label_P(positionMap_S(p)).
```

This definition is constructive because `p` is data in `Type`. It pairs
historical events exactly. For the current frontier, the same construction is
applied to the new positions in the successor states:

```text
χ_frontier,S(gap_T(S))
:= label_P(new_P(φ(S)))
 = gap_P(φ(S)).
```

This notation does not claim to define `χ_frontier,S` on every sentence: its
domain is the individuated current event. It suffices for the causal morphism
because that morphism transports occurrences and their labels, not an
arbitrary function on all syntax.

A global syntactic function

```text
χ : Sentence → Sentence
```

is an additional target. It can be declared only after construction of an
explicit transformation satisfying:

```text
gap_P(φ(S)) = χ(gap_T(S)).
```

Such a function would strengthen the relational correspondence of the gaps,
but it is not the core of the morphism. The central result exists as soon as
frontiers, positions, their labels, and their role in the local extension of
evaluation are transported without semantic identification.

To descend `χ_S` from occurrences to historical sentences, label faithfulness
is also required. It already exists in `T` through
`sentenceAt_injective`. In `P`, it must be proved on the generated orbit from
freshness of every Rosser gap. Even after this descent, the transformation
naturally remains state-dependent. A global function on every `Sentence`
would additionally require a coherence law between states and an explicit
definition outside the historical domain; these data are unnecessary for the
causal result.

The case `χ = id` is a possible theorem, not initial data. It would require a
proof that patching a Tarskian candidate and reconstructing the provability
predicate after theory extension produce syntactically identical diagonals.
Yet the two operations behave differently: the patch is local to one code,
whereas a theory extension may create many new theorems. Correspondence of
histories therefore does not imply identity of sentences.

### Candidate universal factorization

The direct construction of `φ` by recursion over `CausalMemory` has a more
canonical reformulation. Introduce an intrinsic object `K` carrying only
provenance:

```text
KState :
  root
  step(previous)

KPosition(root) = Empty

KPosition(step(previous))
≃ Option(KPosition(previous)).
```

`K` contains no sentence, syntactic gap, or evaluator. It is the candidate
initial object of the structure `GapOrbit⁺` of pointed positive orbits and
morphisms preserving `root`, `advance`, `new`, and `old`. Uniqueness is
formulated pointwise, relative to an explicit equivalence between morphisms,
without a quotient or function extensionality.

The two realizations must then be constructed separately:

```text
r_T : K → K_T⁺
r_P : K → K_P⁺.
```

The fundamental diagram becomes the span:

```text
T ← K → P.
```

If `r_T` and `r_P` are equivalences on the generated orbits, the direct
morphism is derived:

```text
F = r_P ∘ r_T⁻¹.
```

This formula concerns only the generated orbits. It supplies no inverse on
possible raw states inaccessible from the root.

The labels are then two local decorations of the same universal event:

```text
k ↦ label_T(r_T(k))
k ↦ label_P(r_P(k)).
```

They are not identified. Each label separately mediates extension of its local
evaluator. Thus the universal property concerns causal provenance, while the
evaluative role of the gap remains proper to each realization.

This factorization must not yet be announced as a theorem. It is the precise
target to prove: define `GapOrbit⁺`, construct `K`, establish its initiality,
and then show that the Tarskian and Rosser orbits are the two indicated
realizations.

## Scope of the morphism

The morphism must not establish any proposition of the form:

```text
models(gap_T(S))
↔ TheoryProvable(φ(S).history, gap_P(φ(S))).
```

It transports the causal factorization of evaluation:

```text
state succession;
individuation of the current syntactic frontier;
local openness carried by the current gap;
local evaluation of the former gap after advance;
exact recording of events;
preservation of certified causal domains;
the local implications memory → evaluation;
the causal laws `(A)(I)(C)`;
the additive structure induced by causal paths.
```

Transport of the implications `memory → evaluation` means that each remains
valid in its own realization. It never transforms a proof of `Evaluated_T`
into a proof of `Evaluated_P`, or conversely. Tarskian semantics and
provability remain certificates local to the two systems.

## State of the sources and remaining construction order

The arithmetic chain previously described as a prerequisite is now present in
the source files:

```text
P3  PRFunction.proofCheck;
P4  proofFormula, provabilityPredicate, Prov_PA, and their specifications;
P5  internal representability and refutation of primitive-recursive functions;
P6  internal diagonalization;
P7  paConsistent;
P8  Rosser independence and extendWithRosser_consistent;
P9  CertifiedTheoryState, advance, Theorems, and exact event memory;
P10 paProvabilityAccumulatingSystem and the declarations of its causal orbit.
```

The implementation plan marks these ten gates as closed. The protocol that
must certify this statement in a given repository state is:

```text
lake clean
lake build Meta.Tarski.BareArithmetic.ProvabilityClosedOrbit
lake build Meta
```

These commands are a validation criterion, not a consequence of the mere
presence of files. In the working state reviewed on 23 July 2026, a rebuild of
the terminal target did not complete: the first failing module was
`PrimitiveRecursiveProofCorrectness.lean`. It is therefore not exact, for this
specific repository state, to state that closure by a cold build has been
re-established.

```text
paProvabilityClosedSystem : PAProvabilityClosedSystem
```

is a declaration present in the sources. Its status as a closed, axiom-free
value must be reaffirmed only after the protocol above succeeds and its
`AXIOM_AUDIT` block is read in the same repository state.

The intended initial consistency connection has the following complete
syntactic shape:

```text
Derivation.negativeTranslate :
  Derivation(classical,PA,Γ,φ)
  → Derivation(intuitionistic,HA,Γᴺ,φᴺ)

haDerivation_sound :
  Derivation(intuitionistic,HA,Γ,φ)
  → Holds(Γ) → Holds(φ).
```

Thus the intended route for `paConsistent` is PA → HA → standard semantics of
HA; it is neither an assumed field nor a merely informal invocation of
negative translation.

The provability formula remains distinct from this consistency proof. The
repository constructs D1 by quoting a real derivation and two admissible
transformations for composition and introspection. It does not present the
latter as uniform arithmetic D2/D3 schemes over variable codes. Those stronger
schemes are consumed neither by Rosser nor by causal system `P`.

The remaining work must follow the universal factorization rather than taking
the direct morphism as primary data:

```text
M1  define the positive provenance skeleton, the structure GapOrbit⁺,
    and its pointwise equivalence between morphisms;

M2  construct the intrinsic object K through root / step and prove
    its constructive initiality;

M3  package the Tarskian positions and construct
    r_T : K → K_T⁺;

M4  define Position_P := Σ d, TheoryHistory.Contains d,
    its Option extension, and then construct r_P : K → K_P⁺;

M5  restrict explicitly to the generated orbits and prove that
    r_T and r_P are equivalences there;

M6  derive φ and positionMap through F = r_P ∘ r_T⁻¹,
    then recover their new / old commutation laws;

M7  add the syntactic decorations D_T and D_P, then package
    their evaluators separately in PositiveGapMediatedEvaluation;

M8  derive transport of frontiers as events, propositional memories,
    and local certificates, with no semantic arrow;

M9  optionally prove injectivity of label_P on the generated orbit
    and study descent to a global syntactic transformation χ.
```

From the architectural point of view, the construction of `Evaluated_P` and
causal system `P` is written. From the point of view of repository
certification, its closure must be restored through compilation and audit
before being announced as acquired. Once this point is confirmed, what remains
specific to the present document will be the additional morphism between the
two realizations: `GapOrbit⁺`, the intrinsic free object `K`, its two
realizations, and then the derived `φ`, `positionMap`, and coherence laws. This
construction must remain intrinsic, by recursion over histories, with no
numerical rank, no choice, and no external terminal bridge.
