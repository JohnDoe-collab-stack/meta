import Meta.Core.Gap

/-!
# Dynamic stability

This file isolates the abstract dynamic reading of closed stability.

Concrete source-specific data are kept outside the core.  This file records
the abstract pattern:

* a dynamic source provides a typed intersection;
* the intersection forms an interface;
* the same formed interface carries a local projective recovery;
* the existing closed-stability theorem recovers the locally repaired
  non-projective closed-stability package.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s a p q

/-! ## Formed dynamic return -/

/--
A formed dynamic return.

The source is abstract so it can later be instantiated by any dynamic datum
that produces a typed intersection.  The core datum is the typed intersection
produced by that source.
-/
structure FormedDynamicReturn
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Source : Type a) :
    Type (max u v w a) where
  source : Source
  intersection : complete.Intersection branch

/-! ## Temporal provenance of formed excess -/

/--
Temporal provenance of a formed excess carried by a formed dynamic return.

The terminal time is read from the dynamic source; the formed excess is read
from the produced typed intersection.  The `advance` map records the intrinsic
step from terminal time to formed excess.
-/
structure TemporalExcessDynamicReturn
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Source : Type a)
    (dynamicReturn : FormedDynamicReturn complete branch Source)
    (Time : Type p)
    (Excess : Type q) :
    Type (max u v w a p q) where
  terminalTimeOf : Source -> Time
  formedExcessOf : complete.Intersection branch -> Excess
  advance : Time -> Excess
  formedExcess_eq_advance_terminalTime :
    formedExcessOf dynamicReturn.intersection =
      advance (terminalTimeOf dynamicReturn.source)

/-! ## Locally recovered dynamic return -/

/--
A locally recovered dynamic return.

This strengthens a formed dynamic return by carrying the formed interface
realized by the strong terminal cycle generated from the source intersection,
and the local projective recovery whose formed side is that same interface.
-/
structure LocallyRecoveredDynamicReturn
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    (branch : Branch)
    (Source : Type a)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z)
    (Visible : Type r)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max u v w a x y z r s) where
  formedReturn : FormedDynamicReturn complete branch Source
  formed : InterfaceWitness Interface WitnessOf
  realizes :
    RealizesInterface
      (strongTerminalCycleFromIntersection
        complete
        coherence
        formedReturn.intersection)
      formed.interface
  localRecovery :
    LocalProjectiveRecovery Interface Visible project RepairOf
  localRecovery_sameInterface :
    localRecovery.formed = formed.interface

/--
The closed-stability package recovered from a locally recovered dynamic return.

This introduces no independent stability postulate.  It exposes the
dynamic-return form of
`locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem`.
-/
def locallyRecoveredClosedStabilityOfDynamicReturn
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {coherence : RoundTripCoherence complete}
    {branch : Branch}
    {Source : Type a}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (dynamicReturn :
      LocallyRecoveredDynamicReturn
        complete
        coherence
        branch
        Source
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project
        RepairOf) :
    LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface
      Visible
      project
      RepairOf :=
  locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem
    complete
    coherence
    dynamicReturn.formedReturn.intersection
    dynamicReturn.formed
    dynamicReturn.realizes
    dynamicReturn.localRecovery
    dynamicReturn.localRecovery_sameInterface

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.FormedDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.TemporalExcessDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.LocallyRecoveredDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.locallyRecoveredClosedStabilityOfDynamicReturn
/- AXIOM_AUDIT_END -/
