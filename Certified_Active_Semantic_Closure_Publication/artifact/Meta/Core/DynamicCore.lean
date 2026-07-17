import Meta.Core.ClosedStabilityTheorem
import Meta.Core.ProjectiveCore

/-!
# Dynamic return and its projective views

This module carries formed dynamic returns, temporal provenance, local
recovery, and the canonical operational/structural gap and two-pole views.
Role, order, and parity readings remain downstream specializations.
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


/-! ## Dynamic return as generic gap -/

/--
A locally recovered dynamic return exposes the operational gap carried by its
local recovery package.
-/
def dynamicReturn_operationalGap
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
    OperationalReferentialGap Interface Visible project RepairOf :=
  dynamicReturn.localRecovery

/--
A locally recovered dynamic return exposes the structural gap underlying its
operational local recovery.
-/
def dynamicReturn_structuralGap
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
    StructuralReferentialGap Interface Visible project :=
  structuralGapOfOperationalGap
    (dynamicReturn_operationalGap dynamicReturn)

/--
A locally recovered dynamic return refutes the short referential presentation.
-/
theorem dynamicReturn_refutes_shortReferentialPresentation
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
        RepairOf)
    (short :
      ShortReferentialPresentation Interface Visible project) :
    False :=
  operationalLength_refutes_shortPresentation
    (dynamicReturn_operationalGap dynamicReturn)
    short

/-! ## Dynamic return as two-pole interface -/

/-- A locally recovered dynamic return exposes the operational two-pole it carries. -/
def dynamicReturn_operationalTwoPole
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
    OperationalTwoPole Interface Visible project RepairOf :=
  dynamicReturn_operationalGap dynamicReturn

/-- A locally recovered dynamic return exposes its structural two-pole interface. -/
def dynamicReturn_structuralTwoPole
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
    StructuralTwoPole Interface Visible project :=
  dynamicReturn_structuralGap dynamicReturn

/-- A dynamic two-pole refutes the short referential presentation it carries. -/
theorem dynamicReturn_twoPole_refutes_shortPresentation
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
        RepairOf)
    (short : ShortReferentialPresentation Interface Visible project) :
    False :=
  dynamicReturn_refutes_shortReferentialPresentation dynamicReturn short


end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.FormedDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.TemporalExcessDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.LocallyRecoveredDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.locallyRecoveredClosedStabilityOfDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_operationalGap
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_structuralGap
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_refutes_shortReferentialPresentation
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_operationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_structuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_twoPole_refutes_shortPresentation
/- AXIOM_AUDIT_END -/
