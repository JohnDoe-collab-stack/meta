import Meta.Core.TwoPole
import Meta.Core.DynamicStability

/-!
# Dynamic two-pole reading

This file exposes locally recovered dynamic returns as generic operational gaps
and as positive two-pole interfaces.  Order-specific consequences remain in
`OrderGap.lean`.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s a

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
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_operationalGap
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_structuralGap
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_refutes_shortReferentialPresentation
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_operationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_structuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_twoPole_refutes_shortPresentation
/- AXIOM_AUDIT_END -/
