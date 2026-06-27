import Meta.Core.TwoPole
import Meta.Core.DynamicStability

/-!
# Dynamic two-pole reading

This file exposes locally recovered dynamic returns in the positive two-pole
vocabulary.  It does not move the older order-facing aliases; it gives the
same generic data a direct two-pole reading.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s a

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
  dynamicReturn.localRecovery

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
  operationalTwoPole_structural
    (dynamicReturn_operationalTwoPole dynamicReturn)

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
  operationalTwoPole_refutes_shortPresentation
    (dynamicReturn_operationalTwoPole dynamicReturn)
    short

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_operationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_structuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.dynamicReturn_twoPole_refutes_shortPresentation
/- AXIOM_AUDIT_END -/
