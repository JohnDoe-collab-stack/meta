import Meta.Core.Gap

/-!
# Dynamic stability

This file isolates the abstract dynamic reading of closed stability.

It does not define any concrete dynamics, time type, trajectory, bounded
window, or arithmetic collision.  It only records the core pattern:

* a dynamic source provides a typed intersection;
* the intersection forms an interface;
* the same formed interface carries a local projective recovery;
* the existing closed-stability theorem recovers the locally repaired
  non-projective closed-stability package.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s a

/-! ## Formed dynamic return -/

/--
A formed dynamic return.

The source is intentionally abstract: it may later be instantiated by an
observed collision, a bounded window, a repeated-index certificate, or another
dynamic source.  The core datum is the typed intersection produced by that
source.
-/
structure FormedDynamicReturn
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Source : Type a) :
    Type (max u v w a) where
  source : Source
  intersection : complete.Intersection branch

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

No new stability principle is proved here.  This is the dynamic packaging of
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
#print axioms Meta.ClosedStabilityTheorem.LocallyRecoveredDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.locallyRecoveredClosedStabilityOfDynamicReturn
/- AXIOM_AUDIT_END -/
