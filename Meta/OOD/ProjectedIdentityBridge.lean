import Meta.Core.ProjectedIdentity
import Meta.OOD.WitnessTransport

/-!
# OOD bridge to projected identity

This file extracts the projected-identity core carried by a positive OOD
witness transport.

The bridge is one-way: OOD keeps additional data such as `ShiftSource`,
`RepairOf`, and the recovered cell.  The extraction exposes only the
constrained relaxation core.
-/

namespace Meta
namespace OOD

open ClosedStabilityTheorem

universe u v w z r s

/-! ## Constrained relaxation extracted from OOD -/

/--
A positive OOD witness transport provides a constrained projection relaxation.

This is an extraction, not an equivalence: the OOD layer carries extra repair
and source data that the projected-identity core does not keep.
-/
def constrainedProjectionRelaxationOfOODPositiveWitnessTransport
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {ShiftSource : Type r}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {RepairOf : Interface -> Type s}
    (transport :
      OODPositiveWitnessTransport
        Interface
        VisibleIn
        VisibleOut
        Label
        ShiftSource
        projectIn
        projectOut
        readIn
        readOut
        RepairOf) :
    ConstrainedProjectionRelaxation
      Interface
      VisibleIn
      VisibleOut
      Label
      projectIn
      projectOut
      readIn
      readOut
      (fun _ => Nat)
      (fun _ witness => 0 < witness) where
  sourceCell := {
    formed := transport.cell.shift.formed
    shadow := transport.cell.shift.shadow
    sameVisible := transport.cell.shift.sameIn
    separated := transport.cell.shift.separated
  }
  sameOut := transport.cell.shift.sameOut
  visibleShift := transport.cell.shift.visibleShift
  invariant := transport.witnessOfCell
  invariant_pos := transport.witness_pos
  witnessIn := transport.witnessIn
  witnessOut := transport.witnessOut
  witnessIn_eq := transport.witnessIn_eq
  witnessOut_eq := transport.witnessOut_eq

/-! ## Public projections of the extracted core -/

/-- Input projected identity cell extracted from positive OOD transport. -/
def projectedIdentityCellInOfOODPositiveWitnessTransport
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {ShiftSource : Type r}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {RepairOf : Interface -> Type s}
    (transport :
      OODPositiveWitnessTransport
        Interface
        VisibleIn
        VisibleOut
        Label
        ShiftSource
        projectIn
        projectOut
        readIn
        readOut
        RepairOf) :
    ProjectedIdentityCell Interface VisibleIn projectIn :=
  projectedIdentityCellInOfConstrainedRelaxation
    (constrainedProjectionRelaxationOfOODPositiveWitnessTransport transport)

/-- Output projected identity cell extracted from positive OOD transport. -/
def projectedIdentityCellOutOfOODPositiveWitnessTransport
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {ShiftSource : Type r}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {RepairOf : Interface -> Type s}
    (transport :
      OODPositiveWitnessTransport
        Interface
        VisibleIn
        VisibleOut
        Label
        ShiftSource
        projectIn
        projectOut
        readIn
        readOut
        RepairOf) :
    ProjectedIdentityCell Interface VisibleOut projectOut :=
  projectedIdentityCellOutOfConstrainedRelaxation
    (constrainedProjectionRelaxationOfOODPositiveWitnessTransport transport)

/-- Input read identity cell extracted from positive OOD transport. -/
def readIdentityCellInOfOODPositiveWitnessTransport
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {ShiftSource : Type r}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {RepairOf : Interface -> Type s}
    (transport :
      OODPositiveWitnessTransport
        Interface
        VisibleIn
        VisibleOut
        Label
        ShiftSource
        projectIn
        projectOut
        readIn
        readOut
        RepairOf) :
    ReadIdentityCell Interface VisibleIn Label projectIn readIn :=
  readIdentityCellInOfConstrainedRelaxation
    (constrainedProjectionRelaxationOfOODPositiveWitnessTransport transport)

/-- Output read identity cell extracted from positive OOD transport. -/
def readIdentityCellOutOfOODPositiveWitnessTransport
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {ShiftSource : Type r}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {RepairOf : Interface -> Type s}
    (transport :
      OODPositiveWitnessTransport
        Interface
        VisibleIn
        VisibleOut
        Label
        ShiftSource
        projectIn
        projectOut
        readIn
        readOut
        RepairOf) :
    ReadIdentityCell Interface VisibleOut Label projectOut readOut :=
  readIdentityCellOutOfConstrainedRelaxation
    (constrainedProjectionRelaxationOfOODPositiveWitnessTransport transport)

/-- Positive projected invariant extracted from positive OOD transport. -/
def positiveProjectedInvariantOfOODPositiveWitnessTransport
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {ShiftSource : Type r}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {RepairOf : Interface -> Type s}
    (transport :
      OODPositiveWitnessTransport
        Interface
        VisibleIn
        VisibleOut
        Label
        ShiftSource
        projectIn
        projectOut
        readIn
        readOut
        RepairOf) :
    PositiveProjectedInvariant
      Interface
      VisibleIn
      projectIn
      (fun _ => Nat)
      (fun _ witness => 0 < witness) :=
  positiveProjectedInvariantOfConstrainedRelaxation
    (constrainedProjectionRelaxationOfOODPositiveWitnessTransport transport)

/-! ## Obstructions and non-reconstruction extracted from OOD -/

/-- Input projection obstruction extracted from positive OOD transport. -/
def projectionObstructionInOfOODPositiveWitnessTransport
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {ShiftSource : Type r}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {RepairOf : Interface -> Type s}
    (transport :
      OODPositiveWitnessTransport
        Interface
        VisibleIn
        VisibleOut
        Label
        ShiftSource
        projectIn
        projectOut
        readIn
        readOut
        RepairOf) :
    ProjectionObstruction Interface VisibleIn projectIn :=
  projectionObstructionInOfConstrainedRelaxation
    (constrainedProjectionRelaxationOfOODPositiveWitnessTransport transport)

/-- Output projection obstruction extracted from positive OOD transport. -/
def projectionObstructionOutOfOODPositiveWitnessTransport
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {ShiftSource : Type r}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {RepairOf : Interface -> Type s}
    (transport :
      OODPositiveWitnessTransport
        Interface
        VisibleIn
        VisibleOut
        Label
        ShiftSource
        projectIn
        projectOut
        readIn
        readOut
        RepairOf) :
    ProjectionObstruction Interface VisibleOut projectOut :=
  projectionObstructionOutOfConstrainedRelaxation
    (constrainedProjectionRelaxationOfOODPositiveWitnessTransport transport)

/-- Input non-reconstruction extracted from positive OOD transport. -/
def noProjectiveReconstructionInOfOODPositiveWitnessTransport
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {ShiftSource : Type r}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {RepairOf : Interface -> Type s}
    (transport :
      OODPositiveWitnessTransport
        Interface
        VisibleIn
        VisibleOut
        Label
        ShiftSource
        projectIn
        projectOut
        readIn
        readOut
        RepairOf) :
    ((recover : VisibleIn -> Interface) ->
      ((interface : Interface) ->
        recover (projectIn interface) = interface) ->
          False) :=
  noProjectiveReconstructionInOfConstrainedRelaxation
    (constrainedProjectionRelaxationOfOODPositiveWitnessTransport transport)

/-- Output non-reconstruction extracted from positive OOD transport. -/
def noProjectiveReconstructionOutOfOODPositiveWitnessTransport
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {ShiftSource : Type r}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {RepairOf : Interface -> Type s}
    (transport :
      OODPositiveWitnessTransport
        Interface
        VisibleIn
        VisibleOut
        Label
        ShiftSource
        projectIn
        projectOut
        readIn
        readOut
        RepairOf) :
    ((recover : VisibleOut -> Interface) ->
      ((interface : Interface) ->
        recover (projectOut interface) = interface) ->
          False) :=
  noProjectiveReconstructionOutOfConstrainedRelaxation
    (constrainedProjectionRelaxationOfOODPositiveWitnessTransport transport)

end OOD
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.OOD.constrainedProjectionRelaxationOfOODPositiveWitnessTransport
#print axioms Meta.OOD.projectedIdentityCellInOfOODPositiveWitnessTransport
#print axioms Meta.OOD.projectedIdentityCellOutOfOODPositiveWitnessTransport
#print axioms Meta.OOD.readIdentityCellInOfOODPositiveWitnessTransport
#print axioms Meta.OOD.readIdentityCellOutOfOODPositiveWitnessTransport
#print axioms Meta.OOD.positiveProjectedInvariantOfOODPositiveWitnessTransport
#print axioms Meta.OOD.projectionObstructionInOfOODPositiveWitnessTransport
#print axioms Meta.OOD.projectionObstructionOutOfOODPositiveWitnessTransport
#print axioms Meta.OOD.noProjectiveReconstructionInOfOODPositiveWitnessTransport
#print axioms Meta.OOD.noProjectiveReconstructionOutOfOODPositiveWitnessTransport
/- AXIOM_AUDIT_END -/
