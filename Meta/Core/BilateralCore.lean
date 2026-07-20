/-!
# Bilateral completeness and typed closure

This import-free root contains closure, typed intersection, recomposition,
provenance, and interface realization. It is independent of projections,
projective gaps, visible orders, and dynamic specializations.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s

/-! ## Bidirectional completeness -/

/-- Bidirectional completeness as a constructive information interface. -/
structure BidirectionalCompleteness
    (Branch : Type u) : Type (max (u + 1) (v + 1) (w + 1)) where
  Complete : Branch -> Type v
  Forward : Branch -> Type w
  Backward : Branch -> Type w
  Intersection : Branch -> Type w
  forwardOfComplete :
    (branch : Branch) ->
      Complete branch ->
        Forward branch
  backwardOfComplete :
    (branch : Branch) ->
      Complete branch ->
        Backward branch
  intersectionOfComplete :
    (branch : Branch) ->
      Complete branch ->
        Intersection branch
  completeOfIntersection :
    (branch : Branch) ->
      Intersection branch ->
        Complete branch

/-- Projection from `Complete` to the forward reading. -/
def forwardOfComplete
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (closed : complete.Complete branch) :
    complete.Forward branch :=
  complete.forwardOfComplete branch closed

/-- Projection from `Complete` to the backward reading. -/
def backwardOfComplete
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (closed : complete.Complete branch) :
    complete.Backward branch :=
  complete.backwardOfComplete branch closed

/-- Projection from `Complete` to its typed intersection. -/
def intersectionOfComplete
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (closed : complete.Complete branch) :
    complete.Intersection branch :=
  complete.intersectionOfComplete branch closed

/-- Recomposition of `Complete` from a typed intersection. -/
def completeOfIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (intersection : complete.Intersection branch) :
    complete.Complete branch :=
  complete.completeOfIntersection branch intersection

/-! ## Terminal cycles and internal coherence -/

/-- Raw terminal cycle data. -/
structure TerminalCycle
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch) : Type (max v w) where
  completeIn : complete.Complete branch
  forward : complete.Forward branch
  backward : complete.Backward branch
  intersection : complete.Intersection branch
  recomposed : complete.Complete branch

/-- Every complete datum enters a raw terminal cycle. -/
def terminalCycleOfComplete
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (closed : complete.Complete branch) :
    TerminalCycle complete branch where
  completeIn := closed
  forward := forwardOfComplete complete closed
  backward := backwardOfComplete complete closed
  intersection := intersectionOfComplete complete closed
  recomposed :=
    completeOfIntersection
      complete
      (intersectionOfComplete complete closed)

/-- A typed intersection recomposes and then enters a raw terminal cycle. -/
def terminalCycleOfIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (intersection : complete.Intersection branch) :
    TerminalCycle complete branch :=
  terminalCycleOfComplete
    complete
    (completeOfIntersection complete intersection)

/--
Coherent terminal cycle.

Unlike `TerminalCycle`, this package states that each stored field is exactly
the field obtained by reading and recomposing the carried `completeIn` datum.
-/
structure CoherentTerminalCycle
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch) : Type (max v w) where
  cycle : TerminalCycle complete branch
  forward_coherent :
    cycle.forward =
      forwardOfComplete complete cycle.completeIn
  backward_coherent :
    cycle.backward =
      backwardOfComplete complete cycle.completeIn
  intersection_coherent :
    cycle.intersection =
      intersectionOfComplete complete cycle.completeIn
  recomposed_coherent :
    cycle.recomposed =
      completeOfIntersection complete cycle.intersection

/-- The canonical terminal cycle of a complete datum is coherent. -/
def coherentTerminalCycleOfComplete
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (closed : complete.Complete branch) :
    CoherentTerminalCycle complete branch where
  cycle := terminalCycleOfComplete complete closed
  forward_coherent := rfl
  backward_coherent := rfl
  intersection_coherent := rfl
  recomposed_coherent := rfl

/-- The canonical terminal cycle generated by an intersection is coherent. -/
def coherentTerminalCycleOfIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (intersection : complete.Intersection branch) :
    CoherentTerminalCycle complete branch :=
  coherentTerminalCycleOfComplete
    complete
    (completeOfIntersection complete intersection)

/-! ## Round-trip coherence -/

/-- Complete -> Intersection -> Complete returns the same complete datum. -/
structure ReextractionCoherence
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch) :
    Type (max u v w) where
  complete_stable :
    (branch : Branch) ->
      (closed : complete.Complete branch) ->
        completeOfIntersection
          complete
          (intersectionOfComplete complete closed) =
            closed

/-- Intersection -> Complete -> Intersection returns the same intersection. -/
structure IntersectionRecompositionCoherence
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch) :
    Type (max u v w) where
  intersection_stable :
    (branch : Branch) ->
      (intersection : complete.Intersection branch) ->
        intersectionOfComplete
          complete
          (completeOfIntersection complete intersection) =
            intersection

/-- Both round-trip coherences together. -/
structure RoundTripCoherence
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch) :
    Type (max u v w) where
  completeRoundTrip : ReextractionCoherence complete
  intersectionRoundTrip : IntersectionRecompositionCoherence complete

/-- A coherent terminal cycle with strong complete reextraction. -/
structure StrongTerminalCycle
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch) : Type (max u v w) where
  coherentCycle : CoherentTerminalCycle complete branch
  reextracted :
    completeOfIntersection
      complete
      (intersectionOfComplete complete coherentCycle.cycle.recomposed) =
        coherentCycle.cycle.recomposed

/--
Strong terminal cycle generated from an initial intersection, preserving that
initial intersection after recomposition.
-/
structure StrongTerminalCycleFromIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch) : Type (max u v w) where
  sourceIntersection : complete.Intersection branch
  strongCycle : StrongTerminalCycle complete branch
  completeIn_from_source :
    strongCycle.coherentCycle.cycle.completeIn =
      completeOfIntersection complete sourceIntersection
  intersection_from_source :
    strongCycle.coherentCycle.cycle.intersection =
      intersectionOfComplete
        complete
        (completeOfIntersection complete sourceIntersection)
  sourceIntersection_preserved :
    intersectionOfComplete
      complete
      (completeOfIntersection complete sourceIntersection) =
        sourceIntersection

/-- An intersection gives a strong terminal cycle with complete reextraction. -/
def strongTerminalCycleOfIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : ReextractionCoherence complete)
    {branch : Branch}
    (intersection : complete.Intersection branch) :
    StrongTerminalCycle complete branch where
  coherentCycle :=
    coherentTerminalCycleOfIntersection complete intersection
  reextracted :=
    coherence.complete_stable
      branch
      (coherentTerminalCycleOfIntersection complete intersection).cycle.recomposed

/-- With both round trips, the initial intersection is preserved too. -/
def strongTerminalCycleFromIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    {branch : Branch}
    (intersection : complete.Intersection branch) :
    StrongTerminalCycleFromIntersection complete branch where
  sourceIntersection := intersection
  strongCycle :=
    strongTerminalCycleOfIntersection
      complete
      coherence.completeRoundTrip
      intersection
  completeIn_from_source := rfl
  intersection_from_source := rfl
  sourceIntersection_preserved :=
    coherence.intersectionRoundTrip.intersection_stable branch intersection

/-! ## Interface-witness dependency -/

/-- Generic interface-witness package. -/
structure InterfaceWitness
    (Interface : Type x)
    (WitnessOf : Interface -> Type y) :
    Type (max x y) where
  interface : Interface
  witness : WitnessOf interface

/-- Projection to the carried interface. -/
def interfaceOf
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    (formed : InterfaceWitness Interface WitnessOf) :
    Interface :=
  formed.interface

/-- Projection to the witness indexed by the carried interface. -/
def witnessOf
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    (formed : InterfaceWitness Interface WitnessOf) :
    WitnessOf formed.interface :=
  formed.witness

/-! ## Cycle/interface realization -/

/--
Linked weak closed stability.

The relation `RealizesInterface` states that the terminal cycle forms the
interface carried by `formed`.
-/
structure WeakClosedStability
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      TerminalCycle complete branch -> Interface -> Type z) :
    Type (max u v w x y z) where
  cycle : TerminalCycle complete branch
  formed : InterfaceWitness Interface WitnessOf
  interface_coherent :
    RealizesInterface cycle formed.interface

/--
Linked strong closed stability.

The interface witness is not an arbitrary side package: `interface_coherent`
links it to the strong terminal cycle that forms it.
-/
structure StrongClosedStability
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycle complete branch -> Interface -> Type z) :
    Type (max u v w x y z) where
  strongCycle : StrongTerminalCycle complete branch
  formed : InterfaceWitness Interface WitnessOf
  interface_coherent :
    RealizesInterface strongCycle formed.interface

/--
Strong closed stability generated from an initial intersection.

This package carries the stronger terminal datum, including preservation of the
source intersection, and links the formed interface to that whole datum.
-/
structure StrongClosedStabilityFromIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z) :
    Type (max u v w x y z) where
  strongFromIntersection : StrongTerminalCycleFromIntersection complete branch
  formed : InterfaceWitness Interface WitnessOf
  interface_coherent :
    RealizesInterface strongFromIntersection formed.interface

/-- Strong stability forgets to weak stability through compatible realizers. -/
def weakOfStrongClosedStability
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {branch : Branch}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {StrongRealizes :
      StrongTerminalCycle complete branch -> Interface -> Type z}
    {WeakRealizes :
      TerminalCycle complete branch -> Interface -> Type r}
    (realizerForget :
      (strongCycle : StrongTerminalCycle complete branch) ->
        (interface : Interface) ->
          StrongRealizes strongCycle interface ->
            WeakRealizes strongCycle.coherentCycle.cycle interface)
    (stability :
      StrongClosedStability
        complete
        branch
        Interface
        WitnessOf
        StrongRealizes) :
    WeakClosedStability
      complete
      branch
      Interface
      WitnessOf
      WeakRealizes where
  cycle := stability.strongCycle.coherentCycle.cycle
  formed := stability.formed
  interface_coherent :=
    realizerForget
      stability.strongCycle
      stability.formed.interface
      stability.interface_coherent

/-! ## Common stability -/

/-- A self-coupling whose coupled datum conserves memory and source. -/
structure SelfCoupling
    (Branch : Type u)
    (Support : Type x) : Type (max u x (w + 1)) where
  memory : Branch -> Support
  source : Branch -> Support
  Coupled : Branch -> Type w
  coupled_conserves :
    (branch : Branch) ->
      Coupled branch ->
        memory branch = source branch

/-- A strong terminal cycle gives common stability when `Complete` enters the coupling. -/
def commonStabilityOfStrongTerminalCycle
    {Branch : Type u}
    {Support : Type x}
    (coupling : SelfCoupling Branch Support)
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    (completeToCoupled :
      (branch : Branch) ->
        complete.Complete branch ->
          coupling.Coupled branch)
    {branch : Branch}
    (cycle : StrongTerminalCycle complete branch) :
    coupling.memory branch = coupling.source branch :=
  coupling.coupled_conserves
    branch
    (completeToCoupled
      branch
      cycle.coherentCycle.cycle.recomposed)

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.BidirectionalCompleteness
#print axioms Meta.ClosedStabilityTheorem.completeOfIntersection
#print axioms Meta.ClosedStabilityTheorem.TerminalCycle
#print axioms Meta.ClosedStabilityTheorem.CoherentTerminalCycle
#print axioms Meta.ClosedStabilityTheorem.RoundTripCoherence
#print axioms Meta.ClosedStabilityTheorem.StrongTerminalCycle
#print axioms Meta.ClosedStabilityTheorem.StrongTerminalCycleFromIntersection
#print axioms Meta.ClosedStabilityTheorem.strongTerminalCycleFromIntersection
#print axioms Meta.ClosedStabilityTheorem.InterfaceWitness
#print axioms Meta.ClosedStabilityTheorem.WeakClosedStability
#print axioms Meta.ClosedStabilityTheorem.StrongClosedStability
#print axioms Meta.ClosedStabilityTheorem.StrongClosedStabilityFromIntersection
#print axioms Meta.ClosedStabilityTheorem.SelfCoupling
#print axioms Meta.ClosedStabilityTheorem.commonStabilityOfStrongTerminalCycle
/- AXIOM_AUDIT_END -/

