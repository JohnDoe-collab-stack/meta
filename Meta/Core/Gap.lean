import Meta.Core.ClosedStabilityTheorem

/-!
# Referential gap vocabulary

This file isolates the generic vocabulary of referential gaps.

It records three regimes:

* contractible gap: the visible projection determines the enriched interface;
* structural gap: separated enriched interfaces share one visible value;
* operational gap: the structural gap carries a local repair indexed by the
  formed interface.

The definitions are intentionally independent of any particular instance such
as Tarski, Beth, Bell, or arithmetic dynamics.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v s

/-! ## Contractible, structural, and operational gaps -/

/--
A contractible referential gap.

This is the precise form of the informal case `gap = 0`: the visible value
already determines the enriched interface inside each projection fiber.
-/
abbrev ContractibleReferentialGap
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Prop :=
  ProjectionFiberFaithful Interface Visible project

/--
A structural referential gap.

This is the precise form of the informal case `gap > 0`: two separated
enriched interfaces have the same visible projection.
-/
abbrev StructuralReferentialGap
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Type (max u v) :=
  ProjectionObstruction Interface Visible project

/--
An operational referential gap.

This strengthens a structural gap by carrying the formed interface, its
projected shadow, and a repair indexed by the formed interface.
-/
abbrev OperationalReferentialGap
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max u v s) :=
  LocalProjectiveRecovery Interface Visible project RepairOf

/-- An operational gap exposes the underlying structural gap. -/
def structuralGapOfOperationalGap
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf) :
    StructuralReferentialGap Interface Visible project :=
  localProjectiveRecovery_obstruction gap

/-- A structural gap refutes contractibility of the projection fiber. -/
theorem structuralGap_not_contractible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (gap :
      StructuralReferentialGap Interface Visible project)
    (contractible :
      ContractibleReferentialGap Interface Visible project) :
    False :=
  projectionObstruction_notFiberFaithful gap contractible

/-- A structural gap refutes global information conservation by projection. -/
theorem structuralGap_not_informationConserving
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (gap :
      StructuralReferentialGap Interface Visible project)
    (conserving :
      ProjectionInformationConserving Interface Visible project) :
    False :=
  projectionObstruction_notInformationConserving gap conserving

/-- An operational gap refutes contractibility of the projection fiber. -/
theorem operationalGap_not_contractible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf)
    (contractible :
      ContractibleReferentialGap Interface Visible project) :
    False :=
  localProjectiveRecovery_notFiberFaithful gap contractible

/-- An operational gap refutes global information conservation by projection. -/
theorem operationalGap_not_informationConserving
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf)
    (conserving :
      ProjectionInformationConserving Interface Visible project) :
    False :=
  localProjectiveRecovery_notInformationConserving gap conserving

/-- An operational gap rules out a uniform visible-to-interface reconstruction. -/
def noProjectiveReconstructionOfOperationalGap
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      OperationalReferentialGap Interface Visible project RepairOf) :
    ((recover : Visible -> Interface) ->
      ((interface : Interface) ->
        recover (project interface) = interface) ->
          False) :=
  noProjectiveReconstructionOfLocalProjectiveRecovery gap

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.ContractibleReferentialGap
#print axioms Meta.ClosedStabilityTheorem.StructuralReferentialGap
#print axioms Meta.ClosedStabilityTheorem.OperationalReferentialGap
#print axioms Meta.ClosedStabilityTheorem.structuralGapOfOperationalGap
#print axioms Meta.ClosedStabilityTheorem.structuralGap_not_contractible
#print axioms Meta.ClosedStabilityTheorem.structuralGap_not_informationConserving
#print axioms Meta.ClosedStabilityTheorem.operationalGap_not_contractible
#print axioms Meta.ClosedStabilityTheorem.operationalGap_not_informationConserving
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstructionOfOperationalGap
/- AXIOM_AUDIT_END -/
