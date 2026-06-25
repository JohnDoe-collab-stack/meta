import Meta.Tarski.TruthGap

/-!
# Tarski gap contraction

This file is a naming layer over the standalone meta package.

It records the enriched reading of a short two-pole presentation as a
contracted projective chain:

* the gap is contractible when the visible projection is fiber-faithful;
* the gap is structural when two distinct enriched interfaces share one
  visible projection;
* the gap is operational when the structural obstruction is carried together
  with a local repair of the formed interface.

No new semantic assumption is introduced here.  The file only exposes the
already proved projective consequences under the vocabulary of gap
contraction.
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

/-! ## Tarski as a contracted gap -/

/--
The Tarski projection has a contractible gap exactly when syntax determines the
semantic/syntactic interface role.
-/
abbrev TarskiSyntaxFiberContractible
    (Sentence : Type u) :
    Prop :=
  ContractibleReferentialGap
    (TarskiInterface Sentence)
    Sentence
    (@TarskiInterface.project Sentence)

/-- Compatibility alias for the original contraction name. -/
abbrev TarskiGapContractible
    (Sentence : Type u) :
    Prop :=
  TarskiSyntaxFiberContractible Sentence

/-- A Tarski diagonal obstruction is a structural gap over syntax. -/
def TarskiDiagonalObstruction.structuralGap
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    StructuralReferentialGap Meaning Syntax project :=
  structuralGapOfOperationalGap gap.localRecovery

/-- A Tarski diagonal obstruction is an operational gap over syntax. -/
def TarskiDiagonalObstruction.operationalGap
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    OperationalReferentialGap
      Meaning
      Syntax
      project
      (@TarskiTruthRepair Meaning) :=
  gap.localRecovery

/--
Tarski's diagonal gap refutes the short contractible reading of the syntactic
projection.
-/
theorem TarskiDiagonalObstruction.notContractible
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (contractible :
      ContractibleReferentialGap Meaning Syntax project) :
    False :=
  operationalGap_not_contractible gap.operationalGap contractible

/--
Tarski's diagonal gap refutes any global reconstruction of enriched meaning
from visible syntax.
-/
theorem TarskiDiagonalObstruction.notInformationConservingByContraction
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth)
    (conserving :
      ProjectionInformationConserving Meaning Syntax project) :
    False :=
  operationalGap_not_informationConserving gap.operationalGap conserving

/--
Tarski's diagonal gap supplies the local truth-gap recovery of the enriched
`1 + gap + 1` reading.
-/
def TarskiDiagonalObstruction.truthGapRecoveryOfDiagonalObstruction
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    LocalTruthGapRecovery
      Meaning
      Syntax
      project
      (@TarskiTruthRepair Meaning)
      Truth :=
  gap.localTruthGapRecovery

/-- Compatibility alias for the original contracted-recovery name. -/
def TarskiDiagonalObstruction.contractedTruthGapRecovery
    {Syntax : Type u}
    {Meaning : Type v}
    {project : Meaning -> Syntax}
    {Truth : Meaning -> Prop}
    (gap :
      TarskiDiagonalObstruction Syntax Meaning project Truth) :
    LocalTruthGapRecovery
      Meaning
      Syntax
      project
      (@TarskiTruthRepair Meaning)
      Truth :=
  gap.truthGapRecoveryOfDiagonalObstruction

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
#print axioms Meta.ClosedStabilityTheorem.TarskiSyntaxFiberContractible
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.structuralGap
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.operationalGap
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.notContractible
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.notInformationConservingByContraction
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.truthGapRecoveryOfDiagonalObstruction
/- AXIOM_AUDIT_END -/
