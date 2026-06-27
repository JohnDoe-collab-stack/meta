import Meta.Core.ReferentialLength

/-!
# Two-pole reading

This file gives the positive two-pole reading of the existing referential gap
vocabulary.  It introduces no new obstruction data: the structural and
operational two-pole interfaces are views of the already existing structural
and operational referential gaps.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v s

/-! ## Two-pole aliases -/

/-- A structural two-pole interface: two separated interfaces share one visible projection. -/
abbrev StructuralTwoPole
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Type (max u v) :=
  StructuralReferentialGap Interface Visible project

/--
An operational two-pole interface: a structural two-pole interface together
with the local repair carried by its formed pole.
-/
abbrev OperationalTwoPole
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max u v s) :=
  OperationalReferentialGap Interface Visible project RepairOf

/-! ## Structural two-pole projections -/

/-- The left pole of a structural two-pole interface. -/
def structuralTwoPole_leftPole
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (twoPole : StructuralTwoPole Interface Visible project) :
    Interface :=
  twoPole.left

/-- The right pole of a structural two-pole interface. -/
def structuralTwoPole_rightPole
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (twoPole : StructuralTwoPole Interface Visible project) :
    Interface :=
  twoPole.right

/-- The two structural poles share the same visible projection. -/
def structuralTwoPole_sameVisible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (twoPole : StructuralTwoPole Interface Visible project) :
    project (structuralTwoPole_leftPole twoPole) =
      project (structuralTwoPole_rightPole twoPole) :=
  twoPole.sameProjection

/-- The structural two-pole interface keeps its poles separated. -/
def structuralTwoPole_separatedPoles
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (twoPole : StructuralTwoPole Interface Visible project) :
    structuralTwoPole_leftPole twoPole =
      structuralTwoPole_rightPole twoPole -> False :=
  twoPole.separatedInterface

/-! ## Operational two-pole projections -/

/-- The formed pole of an operational two-pole interface. -/
def operationalTwoPole_leftPole
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (twoPole : OperationalTwoPole Interface Visible project RepairOf) :
    Interface :=
  twoPole.formed

/-- The shadow pole of an operational two-pole interface. -/
def operationalTwoPole_rightPole
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (twoPole : OperationalTwoPole Interface Visible project RepairOf) :
    Interface :=
  twoPole.shadow

/-- The two operational poles share the same visible projection. -/
def operationalTwoPole_sameVisible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (twoPole : OperationalTwoPole Interface Visible project RepairOf) :
    project (operationalTwoPole_leftPole twoPole) =
      project (operationalTwoPole_rightPole twoPole) :=
  twoPole.sameProjection

/-- The operational two-pole interface keeps its poles separated. -/
def operationalTwoPole_separatedPoles
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (twoPole : OperationalTwoPole Interface Visible project RepairOf) :
    operationalTwoPole_leftPole twoPole =
      operationalTwoPole_rightPole twoPole -> False :=
  twoPole.separated

/-- The local repair carried by the formed pole. -/
def operationalTwoPole_repair
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (twoPole : OperationalTwoPole Interface Visible project RepairOf) :
    RepairOf (operationalTwoPole_leftPole twoPole) :=
  twoPole.repair

/-- The recovered pole of an operational two-pole interface. -/
def operationalTwoPole_recovered
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (twoPole : OperationalTwoPole Interface Visible project RepairOf) :
    Interface :=
  twoPole.recovered

/-- The recovered pole is the formed pole. -/
def operationalTwoPole_recovered_eq_leftPole
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (twoPole : OperationalTwoPole Interface Visible project RepairOf) :
    operationalTwoPole_recovered twoPole =
      operationalTwoPole_leftPole twoPole :=
  twoPole.recovered_eq_formed

/-- An operational two-pole interface exposes its structural two-pole interface. -/
def operationalTwoPole_structural
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (twoPole : OperationalTwoPole Interface Visible project RepairOf) :
    StructuralTwoPole Interface Visible project :=
  structuralGapOfOperationalGap twoPole

/-! ## Refutation of contracted readings -/

/-- A structural two-pole interface refutes the short referential presentation. -/
theorem structuralTwoPole_refutes_shortPresentation
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (twoPole : StructuralTwoPole Interface Visible project)
    (short : ShortReferentialPresentation Interface Visible project) :
    False :=
  structuralLength_refutes_shortPresentation twoPole short

/-- An operational two-pole interface refutes the short referential presentation. -/
theorem operationalTwoPole_refutes_shortPresentation
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (twoPole : OperationalTwoPole Interface Visible project RepairOf)
    (short : ShortReferentialPresentation Interface Visible project) :
    False :=
  operationalLength_refutes_shortPresentation twoPole short

/-- An operational two-pole interface refutes contractibility of the visible fiber. -/
theorem operationalTwoPole_not_contractible
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (twoPole : OperationalTwoPole Interface Visible project RepairOf)
    (contractible : ContractibleReferentialGap Interface Visible project) :
    False :=
  operationalGap_not_contractible twoPole contractible

/-- An operational two-pole interface rules out uniform visible reconstruction. -/
def operationalTwoPole_noProjectiveReconstruction
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (twoPole : OperationalTwoPole Interface Visible project RepairOf) :
    ((recover : Visible -> Interface) ->
      ((interface : Interface) -> recover (project interface) = interface) ->
        False) :=
  noProjectiveReconstructionOfOperationalGap twoPole

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.StructuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.OperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.structuralTwoPole_leftPole
#print axioms Meta.ClosedStabilityTheorem.structuralTwoPole_rightPole
#print axioms Meta.ClosedStabilityTheorem.structuralTwoPole_sameVisible
#print axioms Meta.ClosedStabilityTheorem.structuralTwoPole_separatedPoles
#print axioms Meta.ClosedStabilityTheorem.operationalTwoPole_leftPole
#print axioms Meta.ClosedStabilityTheorem.operationalTwoPole_rightPole
#print axioms Meta.ClosedStabilityTheorem.operationalTwoPole_sameVisible
#print axioms Meta.ClosedStabilityTheorem.operationalTwoPole_separatedPoles
#print axioms Meta.ClosedStabilityTheorem.operationalTwoPole_repair
#print axioms Meta.ClosedStabilityTheorem.operationalTwoPole_recovered
#print axioms Meta.ClosedStabilityTheorem.operationalTwoPole_recovered_eq_leftPole
#print axioms Meta.ClosedStabilityTheorem.operationalTwoPole_structural
#print axioms Meta.ClosedStabilityTheorem.structuralTwoPole_refutes_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.operationalTwoPole_refutes_shortPresentation
#print axioms Meta.ClosedStabilityTheorem.operationalTwoPole_not_contractible
#print axioms Meta.ClosedStabilityTheorem.operationalTwoPole_noProjectiveReconstruction
/- AXIOM_AUDIT_END -/
