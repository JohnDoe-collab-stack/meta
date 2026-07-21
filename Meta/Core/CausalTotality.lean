import Meta.Core.CausalAdditive

/-!
# Historical causal totality without a terminal state or `Nat`

This module separates cumulative totalization from global completion.  Every
positive causal step strictly extends memory by an explicit source gap, while
the historical memory gathers all obligations reached along finite causal
words.  Every realized stage is strictly below that historical totality.

The construction uses neither `Nat` nor a quotient, rank, freshness oracle,
terminal state, or classical reasoning.
-/

namespace Meta
namespace CausalAdditive

universe u v

/-! ## Positive strict inclusion -/

/-- Constructive strict inclusion between two predicates, carrying an
explicit element of the difference. -/
structure StrictPredicateInclusion
    {Element : Type u}
    (lower upper : Element -> Prop) :
    Type u where
  included :
    (element : Element) ->
      lower element ->
        upper element
  witness : Element
  witness_absent : lower witness -> False
  witness_present : upper witness

namespace AccumulatingCausalSystem

variable {State : Type u}
variable {Gap : Type v}

/-! ## Stage memory and historical memory -/

/-- The memory predicate carried by one causal stage. -/
def stageMemory
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    (word : CausalWord) :
    Gap -> Prop :=
  fun gap => system.Memory (system.eval initial word) gap

/-- The positive totality of every memory obligation realized at some finite
causal word from `initial`.  This is a predicate over the generated history,
not a terminal state. -/
def HistoricalMemory
    (system : AccumulatingCausalSystem State Gap)
    (initial : State) :
    Gap -> Prop :=
  fun gap =>
    Exists fun word : CausalWord =>
      system.Memory (system.eval initial word) gap

/-- A state memory is included in the memory of its causal successor. -/
theorem memory_included_in_advance
    (system : AccumulatingCausalSystem State Gap)
    (state : State)
    (gap : Gap)
    (remembered : system.Memory state gap) :
    system.Memory (system.advance state) gap :=
  system.memory_preserved state gap remembered

/-- Every causal advance is a constructive strict memory extension.  Its
explicit separating witness is the source state's current gap. -/
def advance_strictMemoryExtension
    (system : AccumulatingCausalSystem State Gap)
    (state : State) :
    StrictPredicateInclusion
      (system.Memory state)
      (system.Memory (system.advance state)) where
  included := system.memory_included_in_advance state
  witness := system.gap state
  witness_absent := system.gap_absent state
  witness_present := system.gap_inscribed state

/-- Every obligation remembered at a realized stage belongs to the historical
memory. -/
theorem stageMemory_included_historical
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    (word : CausalWord)
    (gap : Gap)
    (remembered : system.stageMemory initial word gap) :
    system.HistoricalMemory initial gap :=
  Exists.intro word remembered

/-- The current gap of every realized stage belongs to historical memory,
witnessed by the immediately succeeding causal word. -/
theorem currentGap_mem_historical
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    (word : CausalWord) :
    system.HistoricalMemory
      initial
      (system.gap (system.eval initial word)) :=
  Exists.intro
    (CausalWord.succ word)
    (system.gap_inscribed (system.eval initial word))

/-- Every realized stage is constructively strictly included in historical
memory.  The stage's current gap is the explicit missing element. -/
def stageMemory_strictlyIncluded_historical
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    (word : CausalWord) :
    StrictPredicateInclusion
      (system.stageMemory initial word)
      (system.HistoricalMemory initial) where
  included := system.stageMemory_included_historical initial word
  witness := system.gap (system.eval initial word)
  witness_absent := system.gap_absent (system.eval initial word)
  witness_present := system.currentGap_mem_historical initial word

/-- A state exhausts historical memory when it remembers exactly every
historically realized obligation, extensionally and without predicate
extensionality. -/
def ExhaustsHistorical
    (system : AccumulatingCausalSystem State Gap)
    (initial state : State) :
    Prop :=
  (gap : Gap) ->
    system.HistoricalMemory initial gap ↔
      system.Memory state gap

/-- No realized stage exhausts historical memory. -/
theorem no_stage_exhausts_historical
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    (word : CausalWord)
    (exhausts :
      system.ExhaustsHistorical
        initial
        (system.eval initial word)) :
    False :=
  system.gap_absent
    (system.eval initial word)
    ((exhausts (system.gap (system.eval initial word))).mp
      (system.currentGap_mem_historical initial word))

/-! ## The realized infinite family of historical gaps -/

/-- The gap generated at a causal word. -/
def historicalGap
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    (word : CausalWord) :
    Gap :=
  system.gap (system.eval initial word)

/-- Every generated gap is positively contained in historical memory. -/
theorem historicalGap_mem_historical
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    (word : CausalWord) :
    system.HistoricalMemory initial (system.historicalGap initial word) :=
  system.currentGap_mem_historical initial word

/-- Distinct causal words generate distinct historical gaps.  Prefix
comparison orients the pair, and intrinsic freshness separates the source gap
from the gap after the resulting positive suffix. -/
theorem historicalGap_injective
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    {left right : CausalWord}
    (sameGap :
      system.historicalGap initial left =
        system.historicalGap initial right) :
    left = right := by
  cases CausalWord.compare left right with
  | equal same =>
      exact same
  | leftPrefix suffix nonzero right_eq =>
      exfalso
      apply
        system.source_gap_ne_target_gap_of_nonzero
          (system.eval initial left)
          suffix
          nonzero
      calc
        system.gap (system.eval initial left) =
            system.gap (system.eval initial right) := sameGap
        _ = system.gap
              (system.eval initial (CausalWord.add left suffix)) :=
          congrArg
            (fun word => system.gap (system.eval initial word))
            right_eq
        _ = system.gap
              (system.eval (system.eval initial left) suffix) :=
          congrArg system.gap (system.eval_add initial left suffix)
  | rightPrefix suffix nonzero left_eq =>
      exfalso
      apply
        system.source_gap_ne_target_gap_of_nonzero
          (system.eval initial right)
          suffix
          nonzero
      calc
        system.gap (system.eval initial right) =
            system.gap (system.eval initial left) := sameGap.symm
        _ = system.gap
              (system.eval initial (CausalWord.add right suffix)) :=
          congrArg
            (fun word => system.gap (system.eval initial word))
            left_eq
        _ = system.gap
              (system.eval (system.eval initial right) suffix) :=
          congrArg system.gap (system.eval_add initial right suffix)

/-- The subtype of gaps positively realized somewhere in historical memory. -/
def HistoricalGap
    (system : AccumulatingCausalSystem State Gap)
    (initial : State) :
    Type v :=
  Subtype (system.HistoricalMemory initial)

/-- Every causal word realizes an inhabitant of the historical-gap subtype. -/
def realizedHistoricalGap
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    (word : CausalWord) :
    system.HistoricalGap initial :=
  Subtype.mk
    (system.historicalGap initial word)
    (system.historicalGap_mem_historical initial word)

/-- Historical gaps realize a constructive injection of all causal words into
the positive historical totality. -/
theorem realizedHistoricalGap_injective
    (system : AccumulatingCausalSystem State Gap)
    (initial : State)
    {left right : CausalWord}
    (same :
      system.realizedHistoricalGap initial left =
        system.realizedHistoricalGap initial right) :
    left = right :=
  system.historicalGap_injective
    initial
    (congrArg Subtype.val same)

/-! ## Closed generic theorem package -/

/-- The constructive cumulative-totality theorem generated by the three
memory laws of every accumulating causal system. -/
structure CumulativeTotalityTheorem
    (system : AccumulatingCausalSystem State Gap)
    (initial : State) :
    Type (max u v) where
  advanceStrict :
    (state : State) ->
      StrictPredicateInclusion
        (system.Memory state)
        (system.Memory (system.advance state))
  stageStrict :
    (word : CausalWord) ->
      StrictPredicateInclusion
        (system.stageMemory initial word)
        (system.HistoricalMemory initial)
  historicalGapRemembered :
    (word : CausalWord) ->
      system.HistoricalMemory initial (system.historicalGap initial word)
  historicalGapInjective :
    {left right : CausalWord} ->
      system.historicalGap initial left =
          system.historicalGap initial right ->
        left = right
  noStageExhausts :
    (word : CausalWord) ->
      system.ExhaustsHistorical initial (system.eval initial word) ->
        False

/-- Canonical cumulative-totality package for an accumulating causal system. -/
def cumulativeTotalityTheorem
    (system : AccumulatingCausalSystem State Gap)
    (initial : State) :
    CumulativeTotalityTheorem system initial where
  advanceStrict := system.advance_strictMemoryExtension
  stageStrict := system.stageMemory_strictlyIncluded_historical initial
  historicalGapRemembered := system.historicalGap_mem_historical initial
  historicalGapInjective := system.historicalGap_injective initial
  noStageExhausts := system.no_stage_exhausts_historical initial

end AccumulatingCausalSystem
end CausalAdditive
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.advance_strictMemoryExtension
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.stageMemory_strictlyIncluded_historical
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.historicalGap_injective
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.realizedHistoricalGap_injective
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.no_stage_exhausts_historical
#print axioms Meta.CausalAdditive.AccumulatingCausalSystem.cumulativeTotalityTheorem
/- AXIOM_AUDIT_END -/
