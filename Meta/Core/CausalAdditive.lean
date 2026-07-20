/-!
# Causal additive realization without a prior natural-number index

This import-free module constructs unary causal words, their additive
composition, and their faithful action on every accumulating causal system.

The word algebra is defined without using `Nat`.  An accumulating system
supplies exactly the three causal laws: the current gap is absent, one advance
inscribes it, and all previous memories survive.  Those laws force every
nonempty word to separate its endpoint from its source and therefore make the
unary additive action faithful.

No quotient, classical reasoning, external rank, freshness oracle, or
terminal bridge is used.
-/

namespace Meta
namespace CausalAdditive

universe u v w

/-! ## Unary causal words -/

/-- A causal word is either empty or extended by the unique global step. -/
inductive CausalWord : Type where
  | zero : CausalWord
  | succ (previous : CausalWord) : CausalWord

namespace CausalWord

/-- The one-step causal word. -/
def one : CausalWord :=
  CausalWord.succ CausalWord.zero

/-- Addition is chronological concatenation, recursive in the second word. -/
def add : CausalWord -> CausalWord -> CausalWord
  | left, CausalWord.zero => left
  | left, CausalWord.succ right => CausalWord.succ (add left right)

/-- Zero cannot be a successor. -/
theorem zero_ne_succ (word : CausalWord) :
    CausalWord.zero = CausalWord.succ word -> False := by
  intro impossible
  cases impossible

/-- A successor cannot be zero. -/
theorem succ_ne_zero (word : CausalWord) :
    CausalWord.succ word = CausalWord.zero -> False := by
  intro impossible
  cases impossible

/-- Successor is injective. -/
theorem succ_injective
    {left right : CausalWord}
    (same : CausalWord.succ left = CausalWord.succ right) :
    left = right := by
  injection same

/-- Right zero is definitional for causal addition. -/
theorem add_zero (word : CausalWord) :
    add word CausalWord.zero = word :=
  rfl

/-- Addition by a successor is definitional. -/
theorem add_succ (left right : CausalWord) :
    add left (CausalWord.succ right) =
      CausalWord.succ (add left right) :=
  rfl

/-- Zero is also a left identity. -/
theorem zero_add (word : CausalWord) :
    add CausalWord.zero word = word := by
  induction word with
  | zero => rfl
  | succ previous inductionHypothesis =>
      exact congrArg CausalWord.succ inductionHypothesis

/-- A successor on the left passes through every causal suffix. -/
theorem succ_add (left right : CausalWord) :
    add (CausalWord.succ left) right =
      CausalWord.succ (add left right) := by
  induction right with
  | zero => rfl
  | succ previous inductionHypothesis =>
      exact congrArg CausalWord.succ inductionHypothesis

/-- Causal addition is associative. -/
theorem add_associative (left middle right : CausalWord) :
    add (add left middle) right =
      add left (add middle right) := by
  induction right with
  | zero => rfl
  | succ previous inductionHypothesis =>
      exact congrArg CausalWord.succ inductionHypothesis

/-- Unary causal addition is commutative. -/
theorem add_commutative (left right : CausalWord) :
    add left right = add right left := by
  induction right with
  | zero =>
      exact (zero_add left).symm
  | succ previous inductionHypothesis =>
      calc
        add left (CausalWord.succ previous) =
            CausalWord.succ (add left previous) := rfl
        _ = CausalWord.succ (add previous left) :=
          congrArg CausalWord.succ inductionHypothesis
        _ = add (CausalWord.succ previous) left :=
          (succ_add previous left).symm

/-- Constructive right cancellation for causal addition. -/
theorem add_right_cancel
    {left right suffix : CausalWord}
    (same : add left suffix = add right suffix) :
    left = right := by
  induction suffix with
  | zero =>
      exact same
  | succ previous inductionHypothesis =>
      exact inductionHypothesis (succ_injective same)

/-- Constructive left cancellation for causal addition. -/
theorem add_left_cancel
    {base left right : CausalWord}
    (same : add base left = add base right) :
    left = right := by
  apply add_right_cancel (suffix := base)
  calc
    add left base = add base left := add_commutative left base
    _ = add base right := same
    _ = add right base := (add_commutative right base).symm

/-- No nonzero suffix can be absorbed by addition. -/
theorem add_eq_left_implies_zero
    {left suffix : CausalWord}
    (absorbed : add left suffix = left) :
    suffix = CausalWord.zero := by
  apply add_left_cancel (base := left)
  exact absorbed

/-- Multiplication is recursion over already constructed causal addition. -/
def mul : CausalWord -> CausalWord -> CausalWord
  | _, CausalWord.zero => CausalWord.zero
  | left, CausalWord.succ right => add (mul left right) left

/-! ## Induction and universal recursion -/

/-- Universal fold of the causal-word algebra. -/
def fold
    {X : Type u}
    (zero : X)
    (step : X -> X) :
    CausalWord -> X
  | CausalWord.zero => zero
  | CausalWord.succ previous => step (fold zero step previous)

/-- Every map satisfying the fold equations agrees pointwise with the fold. -/
theorem fold_unique
    {X : Type u}
    (zero : X)
    (step : X -> X)
    (candidate : CausalWord -> X)
    (candidate_zero : candidate CausalWord.zero = zero)
    (candidate_succ :
      (word : CausalWord) ->
        candidate (CausalWord.succ word) = step (candidate word))
    (word : CausalWord) :
    candidate word = fold zero step word := by
  induction word with
  | zero =>
      exact candidate_zero
  | succ previous inductionHypothesis =>
      calc
        candidate (CausalWord.succ previous) =
            step (candidate previous) := candidate_succ previous
        _ = step (fold zero step previous) :=
          congrArg step inductionHypothesis
        _ = fold zero step (CausalWord.succ previous) := rfl

/-! ## Constructive prefix comparison -/

/-- Constructive comparison of two words in the unary prefix order. -/
inductive PrefixComparison (left right : CausalWord) : Type where
  | equal (same : left = right) : PrefixComparison left right
  | leftPrefix
      (suffix : CausalWord)
      (nonzero : suffix = CausalWord.zero -> False)
      (right_eq : right = add left suffix) :
      PrefixComparison left right
  | rightPrefix
      (suffix : CausalWord)
      (nonzero : suffix = CausalWord.zero -> False)
      (left_eq : left = add right suffix) :
      PrefixComparison left right

/-- Any two unary words are equal or one is a positive extension of the other. -/
def compare :
    (left right : CausalWord) -> PrefixComparison left right
  | CausalWord.zero, CausalWord.zero =>
      PrefixComparison.equal rfl
  | CausalWord.zero, CausalWord.succ right =>
      PrefixComparison.leftPrefix
        (CausalWord.succ right)
        (succ_ne_zero right)
        (zero_add (CausalWord.succ right)).symm
  | CausalWord.succ left, CausalWord.zero =>
      PrefixComparison.rightPrefix
        (CausalWord.succ left)
        (succ_ne_zero left)
        (zero_add (CausalWord.succ left)).symm
  | CausalWord.succ left, CausalWord.succ right =>
      match compare left right with
      | PrefixComparison.equal same =>
          PrefixComparison.equal (congrArg CausalWord.succ same)
      | PrefixComparison.leftPrefix suffix nonzero right_eq =>
          PrefixComparison.leftPrefix suffix nonzero (by
            calc
              CausalWord.succ right =
                  CausalWord.succ (add left suffix) :=
                congrArg CausalWord.succ right_eq
              _ = add (CausalWord.succ left) suffix :=
                (succ_add left suffix).symm)
      | PrefixComparison.rightPrefix suffix nonzero left_eq =>
          PrefixComparison.rightPrefix suffix nonzero (by
            calc
              CausalWord.succ left =
                  CausalWord.succ (add right suffix) :=
                congrArg CausalWord.succ left_eq
              _ = add (CausalWord.succ right) suffix :=
                (succ_add right suffix).symm)

end CausalWord

/-! ## Chronological endotransformations -/

/-- An endotransformation of causal states, without quotienting functions. -/
structure ChronologicalEndomorphism (State : Type u) : Type u where
  run : State -> State

namespace ChronologicalEndomorphism

/-- Identity chronological transformation. -/
def identity {State : Type u} : ChronologicalEndomorphism State where
  run := fun state => state

/-- Chronological composition: `second` runs after `first`. -/
def compose {State : Type u}
    (first second : ChronologicalEndomorphism State) :
    ChronologicalEndomorphism State where
  run := fun state => second.run (first.run state)

end ChronologicalEndomorphism

/-! ## Accumulating causal systems -/

/--
A system whose current gap is absent, is inscribed by one advance, and whose
previous memories survive every advance.
-/
structure AccumulatingCausalSystem
    (State : Type u)
    (Gap : Type v) :
    Type (max u v) where
  gap : State -> Gap
  Memory : State -> Gap -> Prop
  advance : State -> State
  gap_absent :
    (state : State) ->
      Memory state (gap state) -> False
  gap_inscribed :
    (state : State) ->
      Memory (advance state) (gap state)
  memory_preserved :
    (state : State) ->
    (rememberedGap : Gap) ->
      Memory state rememberedGap ->
        Memory (advance state) rememberedGap

namespace AccumulatingCausalSystem

variable {State : Type u}
variable {Gap : Type v}

/-- Evaluation of a causal word by repeated intrinsic advance. -/
def eval
    (system : AccumulatingCausalSystem State Gap)
    (state : State) :
    CausalWord -> State
  | CausalWord.zero => state
  | CausalWord.succ previous => system.advance (system.eval state previous)

/-- The empty word acts as identity. -/
theorem eval_zero
    (system : AccumulatingCausalSystem State Gap)
    (state : State) :
    system.eval state CausalWord.zero = state :=
  rfl

/-- Successor acts by one further advance. -/
theorem eval_succ
    (system : AccumulatingCausalSystem State Gap)
    (state : State)
    (word : CausalWord) :
    system.eval state (CausalWord.succ word) =
      system.advance (system.eval state word) :=
  rfl

/-- Addition of words is exactly chronological composition of their actions. -/
theorem eval_add
    (system : AccumulatingCausalSystem State Gap)
    (state : State)
    (left right : CausalWord) :
    system.eval state (CausalWord.add left right) =
      system.eval (system.eval state left) right := by
  induction right with
  | zero => rfl
  | succ previous inductionHypothesis =>
      exact congrArg system.advance inductionHypothesis

/-- The chronological endotransformation represented by a causal word. -/
def wordAction
    (system : AccumulatingCausalSystem State Gap)
    (word : CausalWord) :
    ChronologicalEndomorphism State where
  run := fun state => system.eval state word

/-- The empty word acts pointwise as the chronological identity. -/
theorem wordAction_zero_at
    (system : AccumulatingCausalSystem State Gap)
    (state : State) :
    (system.wordAction CausalWord.zero).run state =
      ChronologicalEndomorphism.identity.run state :=
  rfl

/-- Word addition is pointwise chronological composition. -/
theorem wordAction_add_at
    (system : AccumulatingCausalSystem State Gap)
    (left right : CausalWord)
    (state : State) :
    (system.wordAction (CausalWord.add left right)).run state =
      (ChronologicalEndomorphism.compose
        (system.wordAction left)
        (system.wordAction right)).run state :=
  system.eval_add state left right

/-- Extensional equality of the obligations remembered by two states. -/
structure MemoryEquivalent
    (system : AccumulatingCausalSystem State Gap)
    (left right : State) :
    Prop where
  forward :
    (rememberedGap : Gap) ->
      system.Memory left rememberedGap ->
        system.Memory right rememberedGap
  backward :
    (rememberedGap : Gap) ->
      system.Memory right rememberedGap ->
        system.Memory left rememberedGap

/-- Reflexivity of memory equivalence. -/
def memoryEquivalentRefl
    (system : AccumulatingCausalSystem State Gap)
    (state : State) :
    MemoryEquivalent system state state where
  forward := by
    intro _ remembered
    exact remembered
  backward := by
    intro _ remembered
    exact remembered

/-- Symmetry of memory equivalence. -/
def MemoryEquivalent.symm
    {system : AccumulatingCausalSystem State Gap}
    {left right : State}
    (equivalent : MemoryEquivalent system left right) :
    MemoryEquivalent system right left where
  forward := equivalent.backward
  backward := equivalent.forward

/-- Transitivity of memory equivalence. -/
def MemoryEquivalent.trans
    {system : AccumulatingCausalSystem State Gap}
    {left middle right : State}
    (leftMiddle : MemoryEquivalent system left middle)
    (middleRight : MemoryEquivalent system middle right) :
    MemoryEquivalent system left right where
  forward := by
    intro rememberedGap remembered
    exact middleRight.forward rememberedGap
      (leftMiddle.forward rememberedGap remembered)
  backward := by
    intro rememberedGap remembered
    exact leftMiddle.backward rememberedGap
      (middleRight.backward rememberedGap remembered)

/-- Every nonempty word carries the source gap into its target memory. -/
theorem remembers_source_gap_of_nonzero
    (system : AccumulatingCausalSystem State Gap)
    (state : State)
    (word : CausalWord)
    (nonzero : word = CausalWord.zero -> False) :
    system.Memory (system.eval state word) (system.gap state) := by
  induction word with
  | zero =>
      exact (nonzero rfl).elim
  | succ previous inductionHypothesis =>
      cases previous with
      | zero =>
          exact system.gap_inscribed state
      | succ earlier =>
          exact
            system.memory_preserved
              (system.eval state (CausalWord.succ earlier))
              (system.gap state)
              (inductionHypothesis (CausalWord.succ_ne_zero earlier))

/-- A positive extension is not memory-equivalent to its source. -/
theorem no_memoryEquivalent_forward_of_nonzero
    (system : AccumulatingCausalSystem State Gap)
    (state : State)
    (word : CausalWord)
    (nonzero : word = CausalWord.zero -> False)
    (equivalent :
      MemoryEquivalent system state (system.eval state word)) :
    False :=
  system.gap_absent state
    (equivalent.backward
      (system.gap state)
      (system.remembers_source_gap_of_nonzero state word nonzero))

/-- The same non-return statement in the reverse equivalence orientation. -/
theorem no_memoryEquivalent_backward_of_nonzero
    (system : AccumulatingCausalSystem State Gap)
    (state : State)
    (word : CausalWord)
    (nonzero : word = CausalWord.zero -> False)
    (equivalent :
      MemoryEquivalent system (system.eval state word) state) :
    False :=
  system.no_memoryEquivalent_forward_of_nonzero
    state word nonzero equivalent.symm

/-- The current gap after a positive path is intrinsically fresh. -/
theorem source_gap_ne_target_gap_of_nonzero
    (system : AccumulatingCausalSystem State Gap)
    (state : State)
    (word : CausalWord)
    (nonzero : word = CausalWord.zero -> False) :
    system.gap state = system.gap (system.eval state word) -> False := by
  intro sameGap
  apply system.gap_absent (system.eval state word)
  rw [← sameGap]
  exact system.remembers_source_gap_of_nonzero state word nonzero

/-- Memory-equivalent evaluations at one source determine their causal words. -/
theorem eval_faithful
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    {left right : CausalWord}
    (equivalent :
      MemoryEquivalent
        system
        (system.eval initial left)
        (system.eval initial right)) :
    left = right := by
  cases CausalWord.compare left right with
  | equal same =>
      exact same
  | leftPrefix suffix nonzero right_eq =>
      subst right
      exfalso
      apply
        (system.no_memoryEquivalent_forward_of_nonzero
          (system.eval initial left)
          suffix
          nonzero)
      simpa only [system.eval_add] using equivalent
  | rightPrefix suffix nonzero left_eq =>
      subst left
      exfalso
      apply
        (system.no_memoryEquivalent_forward_of_nonzero
          (system.eval initial right)
          suffix
          nonzero)
      simpa only [system.eval_add] using equivalent.symm

/-- Raw equality of evaluations also determines their words. -/
theorem eval_injective
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    {left right : CausalWord}
    (same : system.eval initial left = system.eval initial right) :
    left = right := by
  apply system.eval_faithful initial
  exact {
    forward := by
      intro rememberedGap remembered
      rw [← same]
      exact remembered
    backward := by
      intro rememberedGap remembered
      rw [same]
      exact remembered
  }

/-- Equality of the generated transformations is already separated at one state. -/
theorem action_pointwise_faithful
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    {left right : CausalWord}
    (sameAction :
      (state : State) ->
        system.eval state left = system.eval state right) :
    left = right :=
  system.eval_injective initial (sameAction initial)

/-- The additive representation into chronological endotransformations is
faithful under pointwise equality; no function extensionality is used. -/
theorem wordAction_pointwise_faithful
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    {left right : CausalWord}
    (sameAction :
      (state : State) ->
        (system.wordAction left).run state =
          (system.wordAction right).run state) :
    left = right :=
  system.action_pointwise_faithful initial sameAction

/-! ## Positive transcontextual paths -/

/-- A path of complete advances, indexed by its exact source and target. -/
inductive CausalPath
    (system : AccumulatingCausalSystem State Gap) :
    State -> State -> Type u where
  | identity (state : State) : CausalPath system state state
  | extend
      {source target : State}
      (previous : CausalPath system source target) :
      CausalPath system source (system.advance target)

/-- Composition of paths whose intermediate state agrees exactly. -/
def CausalPath.compose
    {system : AccumulatingCausalSystem State Gap}
    {source middle target : State} :
    CausalPath system source middle ->
      CausalPath system middle target ->
        CausalPath system source target
  | first, CausalPath.identity _ => first
  | first, CausalPath.extend second =>
      CausalPath.extend (CausalPath.compose first second)

/-- The canonical complete transition path represented by a word. -/
def pathOfWord
    (system : AccumulatingCausalSystem State Gap)
    (state : State) :
    (word : CausalWord) ->
      CausalPath system state (system.eval state word)
  | CausalWord.zero => CausalPath.identity state
  | CausalWord.succ previous =>
      CausalPath.extend (system.pathOfWord state previous)

/-- Reindex only the target of a positive path along an ordinary equality. -/
def CausalPath.castTarget
    {system : AccumulatingCausalSystem State Gap}
    {source leftTarget rightTarget : State}
    (sameTarget : leftTarget = rightTarget)
    (path : CausalPath system source leftTarget) :
    CausalPath system source rightTarget := by
  cases sameTarget
  exact path

/--
The transcontextual composite path for an additive word decomposition.

The second path starts at the state produced by the first; the additive action
law reindexes its endpoint to the evaluation of the sum.
-/
def composedWordPath
    (system : AccumulatingCausalSystem State Gap)
    (state : State)
    (left right : CausalWord) :
    CausalPath
      system
      state
      (system.eval state (CausalWord.add left right)) :=
  CausalPath.castTarget
    (system.eval_add state left right).symm
    (CausalPath.compose
      (system.pathOfWord state left)
      (system.pathOfWord (system.eval state left) right))

/-! ## Proof-relevant transcontextual transport paths -/

/--
A complete transcontextual path whose every extension stores the positive
transport payload computed at its current target state.
-/
inductive CausalTransportPath
    (system : AccumulatingCausalSystem State Gap)
    (Payload : State -> Type w) :
    State -> State -> Type (max u w) where
  | identity (state : State) :
      CausalTransportPath system Payload state state
  | extend
      {source target : State}
      (previous : CausalTransportPath system Payload source target)
      (payload : Payload target) :
      CausalTransportPath system Payload source (system.advance target)

/-- Composition of proof-relevant transport paths across their shared state. -/
def CausalTransportPath.compose
    {system : AccumulatingCausalSystem State Gap}
    {Payload : State -> Type w}
    {source middle target : State} :
    CausalTransportPath system Payload source middle ->
      CausalTransportPath system Payload middle target ->
        CausalTransportPath system Payload source target
  | first, CausalTransportPath.identity _ => first
  | first, CausalTransportPath.extend second payload =>
      CausalTransportPath.extend
        (CausalTransportPath.compose first second)
        payload

/-- Canonical proof-relevant transport path represented by a causal word. -/
def transportPathOfWord
    (system : AccumulatingCausalSystem State Gap)
    (Payload : State -> Type w)
    (payloadAt : (state : State) -> Payload state)
    (state : State) :
    (word : CausalWord) ->
      CausalTransportPath
        system Payload state (system.eval state word)
  | CausalWord.zero => CausalTransportPath.identity state
  | CausalWord.succ previous =>
      CausalTransportPath.extend
        (system.transportPathOfWord Payload payloadAt state previous)
        (payloadAt (system.eval state previous))

/-- Reindex the target of a transport path along an ordinary equality. -/
def CausalTransportPath.castTarget
    {system : AccumulatingCausalSystem State Gap}
    {Payload : State -> Type w}
    {source leftTarget rightTarget : State}
    (sameTarget : leftTarget = rightTarget)
    (path : CausalTransportPath system Payload source leftTarget) :
    CausalTransportPath system Payload source rightTarget := by
  cases sameTarget
  exact path

/--
The proof-relevant transcontextual transport obtained by composing the paths
of two additive summands.
-/
def composedTransportWordPath
    (system : AccumulatingCausalSystem State Gap)
    (Payload : State -> Type w)
    (payloadAt : (state : State) -> Payload state)
    (state : State)
    (left right : CausalWord) :
    CausalTransportPath
      system
      Payload
      state
      (system.eval state (CausalWord.add left right)) :=
  CausalTransportPath.castTarget
    (system.eval_add state left right).symm
    (CausalTransportPath.compose
      (system.transportPathOfWord Payload payloadAt state left)
      (system.transportPathOfWord
        Payload payloadAt (system.eval state left) right))

/-! ## Abstract dependent transport, separate from causal faithfulness -/

/--
Identity, dependent composition, and the intrinsic one-step transport of a
causal system.

This structure is deliberately separate from the three memory laws.  Those
laws prove additive faithfulness; a transport instance additionally explains
how complete step payloads compose across changing contexts.
-/
structure CausalTransportStructure
    (system : AccumulatingCausalSystem State Gap) :
    Type (max u (w + 1)) where
  Transport : State -> State -> Type w
  identity : (state : State) -> Transport state state
  compose :
    {source middle target : State} ->
      Transport source middle ->
        Transport middle target ->
          Transport source target
  stepTransport :
    (state : State) -> Transport state (system.advance state)

namespace CausalTransportStructure

variable {system : AccumulatingCausalSystem State Gap}

/-- Reindex the target of a dependent transport along equality. -/
def castTarget
    (transport : CausalTransportStructure.{u, v, w} system)
    {source leftTarget rightTarget : State}
    (sameTarget : leftTarget = rightTarget)
    (carried : transport.Transport source leftTarget) :
    transport.Transport source rightTarget := by
  cases sameTarget
  exact carried

/-- Transport generated recursively by a causal word. -/
def pathTransport
    (transport : CausalTransportStructure.{u, v, w} system)
    (state : State) :
    (word : CausalWord) ->
      transport.Transport state (system.eval state word)
  | CausalWord.zero => transport.identity state
  | CausalWord.succ previous =>
      transport.compose
        (transport.pathTransport state previous)
        (transport.stepTransport (system.eval state previous))

/--
Dependent composition of the transports of two additive summands.

No equality with the recursively normalized `pathTransport` is asserted
without separate identity and associativity laws for the transport instance.
-/
def composedPathTransport
    (transport : CausalTransportStructure.{u, v, w} system)
    (state : State)
    (left right : CausalWord) :
    transport.Transport
      state
      (system.eval state (CausalWord.add left right)) :=
  transport.castTarget
    (system.eval_add state left right).symm
    (transport.compose
      (transport.pathTransport state left)
      (transport.pathTransport (system.eval state left) right))

end CausalTransportStructure

/--
Complete proof-relevant event paths intrinsically instantiate dependent causal
transport.  Each step payload is recomputed at the context reached by the
preceding word.
-/
def causalTransportStructureOfPayload
    (system : AccumulatingCausalSystem State Gap)
    (Payload : State -> Type w)
    (payloadAt : (state : State) -> Payload state) :
    CausalTransportStructure.{u, v, max u w} system where
  Transport := CausalTransportPath system Payload
  identity := CausalTransportPath.identity
  compose := CausalTransportPath.compose
  stepTransport := fun state =>
    CausalTransportPath.extend
      (CausalTransportPath.identity state)
      (payloadAt state)

/-! ## The realized causal natural object -/

/-- A causal word positively paired with the state it realizes from `initial`. -/
structure RealizedCausalNat
    (system : AccumulatingCausalSystem State Gap)
    (initial : State) :
    Type u where
  word : CausalWord
  state : State
  realized : state = system.eval initial word

namespace RealizedCausalNat

variable {system : AccumulatingCausalSystem State Gap}
variable {initial : State}

/-- Canonical realization of a word. -/
def embed (word : CausalWord) :
    RealizedCausalNat system initial where
  word := word
  state := system.eval initial word
  realized := rfl

/-- Realized additive zero. -/
def zero : RealizedCausalNat system initial :=
  embed CausalWord.zero

/-- Realized successor. -/
def succ (realizedNat : RealizedCausalNat system initial) :
    RealizedCausalNat system initial where
  word := CausalWord.succ realizedNat.word
  state := system.advance realizedNat.state
  realized := by
    calc
      system.advance realizedNat.state =
          system.advance (system.eval initial realizedNat.word) :=
        congrArg system.advance realizedNat.realized
      _ = system.eval initial (CausalWord.succ realizedNat.word) := rfl

/-- Realized addition, relative to the common causal origin. -/
def add
    (left right : RealizedCausalNat system initial) :
    RealizedCausalNat system initial :=
  embed (CausalWord.add left.word right.word)

/-- Embedding preserves zero. -/
theorem embed_zero :
    embed (system := system) (initial := initial) CausalWord.zero = zero :=
  rfl

/-- Embedding preserves successor. -/
theorem embed_succ (word : CausalWord) :
    embed (system := system) (initial := initial) (CausalWord.succ word) =
      succ (embed word) :=
  rfl

/-- Embedding preserves causal addition. -/
theorem embed_add (left right : CausalWord) :
    embed (system := system) (initial := initial) (CausalWord.add left right) =
      add (embed left) (embed right) :=
  rfl

/-- Projecting the word after embedding returns the original word. -/
theorem word_embed (word : CausalWord) :
    (embed (system := system) (initial := initial) word).word = word :=
  rfl

/-- Every realized object is its canonical word realization. -/
theorem embed_word (realizedNat : RealizedCausalNat system initial) :
    embed realizedNat.word = realizedNat := by
  cases realizedNat with
  | mk word state realized =>
      cases realized
      rfl

/-- Equality of words determines equality of realized objects. -/
theorem ext_word
    {left right : RealizedCausalNat system initial}
    (sameWord : left.word = right.word) :
    left = right := by
  rw [← embed_word left, ← embed_word right, sameWord]

/-- The state of a realized sum is chronological evaluation from the left state. -/
theorem state_add
    (left right : RealizedCausalNat system initial) :
    (add left right).state = system.eval left.state right.word := by
  calc
    (add left right).state =
        system.eval initial (CausalWord.add left.word right.word) := rfl
    _ = system.eval (system.eval initial left.word) right.word :=
      system.eval_add initial left.word right.word
    _ = system.eval left.state right.word :=
      congrArg
        (fun state => system.eval state right.word)
        left.realized.symm

/-- The realized word determines its state up to memory equivalence. -/
theorem memoryEquivalent_determines_word
    (left right : RealizedCausalNat system initial)
    (equivalent :
      MemoryEquivalent system left.state right.state) :
    left.word = right.word := by
  apply system.eval_faithful initial
  cases left with
  | mk leftWord leftState leftRealized =>
      cases leftRealized
      cases right with
      | mk rightWord rightState rightRealized =>
          cases rightRealized
          exact equivalent

/-- Memory equivalence of realized states determines the complete objects. -/
theorem memoryEquivalent_determines
    (left right : RealizedCausalNat system initial)
    (equivalent :
      MemoryEquivalent system left.state right.state) :
    left = right :=
  ext_word (memoryEquivalent_determines_word left right equivalent)

/-- Raw equality of realized states determines their causal words. -/
theorem state_eq_determines_word
    (left right : RealizedCausalNat system initial)
    (sameState : left.state = right.state) :
    left.word = right.word := by
  apply system.eval_injective initial
  calc
    system.eval initial left.word = left.state := left.realized.symm
    _ = right.state := sameState
    _ = system.eval initial right.word := right.realized

/-- Realized zero is a right additive identity. -/
theorem add_zero (realizedNat : RealizedCausalNat system initial) :
    add realizedNat zero = realizedNat := by
  apply ext_word
  exact CausalWord.add_zero realizedNat.word

/-- Realized zero is a left additive identity. -/
theorem zero_add (realizedNat : RealizedCausalNat system initial) :
    add zero realizedNat = realizedNat := by
  apply ext_word
  exact CausalWord.zero_add realizedNat.word

/-- Realized addition is associative. -/
theorem add_associative
    (left middle right : RealizedCausalNat system initial) :
    add (add left middle) right = add left (add middle right) := by
  apply ext_word
  exact CausalWord.add_associative left.word middle.word right.word

/-- Realized addition is commutative. -/
theorem add_commutative
    (left right : RealizedCausalNat system initial) :
    add left right = add right left := by
  apply ext_word
  exact CausalWord.add_commutative left.word right.word

/-- Realized addition has constructive right cancellation. -/
theorem add_right_cancel
    {left right suffix : RealizedCausalNat system initial}
    (same : add left suffix = add right suffix) :
    left = right := by
  apply ext_word
  apply CausalWord.add_right_cancel
  exact congrArg RealizedCausalNat.word same

/-- Realized addition has constructive left cancellation. -/
theorem add_left_cancel
    {base left right : RealizedCausalNat system initial}
    (same : add base left = add base right) :
    left = right := by
  apply ext_word
  apply CausalWord.add_left_cancel
  exact congrArg RealizedCausalNat.word same

/-- Realized successor is addition of the realized one. -/
theorem succ_eq_add_one
    (realizedNat : RealizedCausalNat system initial) :
    succ realizedNat = add realizedNat (embed CausalWord.one) := by
  apply ext_word
  rfl

/-- No nonempty realized increment can be absorbed. -/
theorem no_positive_absorption
    (realizedNat : RealizedCausalNat system initial)
    (word : CausalWord)
    (nonzero : word = CausalWord.zero -> False)
    (absorbed : add realizedNat (embed word) = realizedNat) :
    False := by
  apply nonzero
  apply CausalWord.add_eq_left_implies_zero
  exact congrArg RealizedCausalNat.word absorbed

end RealizedCausalNat
end AccumulatingCausalSystem

end CausalAdditive
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.CausalAdditive.CausalWord.add_commutative
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.wordAction_add_at
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.wordAction_pointwise_faithful
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.eval_faithful
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.composedWordPath
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.composedTransportWordPath
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.CausalTransportStructure.pathTransport
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.causalTransportStructureOfPayload
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.RealizedCausalNat.state_add
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.RealizedCausalNat.memoryEquivalent_determines
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.RealizedCausalNat.no_positive_absorption
/- AXIOM_AUDIT_END -/
