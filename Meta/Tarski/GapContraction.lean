import Meta.Core.Gap
import Meta.Tarski.TruthGap

/-!
# Tarski gap contraction

This file is the Tarski instance layer over the standalone meta package.

No new semantic assumption is introduced here.  The file only exposes the
already proved projective consequences under the vocabulary of gap
contraction.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v

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
#print axioms Meta.ClosedStabilityTheorem.TarskiSyntaxFiberContractible
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.structuralGap
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.operationalGap
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.notContractible
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.notInformationConservingByContraction
#print axioms Meta.ClosedStabilityTheorem.TarskiDiagonalObstruction.truthGapRecoveryOfDiagonalObstruction
/- AXIOM_AUDIT_END -/
