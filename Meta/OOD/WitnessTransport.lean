import Meta.Core.ClosedStabilityTheorem

/-!
# OOD witness transport

This file isolates the abstract OOD certificate used by the project.

The layer is deliberately instance-free.  It records a shared operative cell,
two visible projections, two visible readings, an inspectable source for the
visible shift, and the internal witness transported through the same cell.

The abstract layer does not prove that a concrete shift source is substantial.
That check belongs to each concrete instance.
-/

namespace Meta
namespace OOD

open ClosedStabilityTheorem

universe u v w z r s q

/--
Visible OOD shift carried by one operative cell.

The shift is not stored as a floating proof.  It is obtained from
`shiftSource` through `visibleShiftOfSource`.
-/
structure OODProjectionShift
    (Interface : Type u)
    (VisibleIn : Type v)
    (VisibleOut : Type w)
    (Label : Type z)
    (ShiftSource : Type r)
    (projectIn : Interface -> VisibleIn)
    (projectOut : Interface -> VisibleOut)
    (readIn : VisibleIn -> Label)
    (readOut : VisibleOut -> Label) :
    Type (max u v w z r) where
  formed : Interface
  shadow : Interface
  sameIn : projectIn formed = projectIn shadow
  sameOut : projectOut formed = projectOut shadow
  separated : formed = shadow -> False
  shiftSource : ShiftSource
  visibleShiftOfSource :
    ShiftSource ->
      readIn (projectIn formed) = readOut (projectOut formed) -> False

/-- The visible shift derived from its inspectable source. -/
def OODProjectionShift.visibleShift
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {ShiftSource : Type r}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    (shift :
      OODProjectionShift
        Interface
        VisibleIn
        VisibleOut
        Label
        ShiftSource
        projectIn
        projectOut
        readIn
        readOut) :
    readIn (projectIn shift.formed) =
      readOut (projectOut shift.formed) -> False :=
  shift.visibleShiftOfSource shift.shiftSource

/--
The recovered OOD cell.

The same formed/shadow pair is recovered under both projections.  The
non-reconstruction statements are still about `projectIn` and `projectOut`,
not about the readings.
-/
structure OODRecoveredCell
    (Interface : Type u)
    (VisibleIn : Type v)
    (VisibleOut : Type w)
    (Label : Type z)
    (ShiftSource : Type r)
    (projectIn : Interface -> VisibleIn)
    (projectOut : Interface -> VisibleOut)
    (readIn : VisibleIn -> Label)
    (readOut : VisibleOut -> Label)
    (RepairOf : Interface -> Type s) :
    Type (max u v w z r s) where
  shift :
    OODProjectionShift
      Interface
      VisibleIn
      VisibleOut
      Label
      ShiftSource
      projectIn
      projectOut
      readIn
      readOut
  repair : RepairOf shift.formed
  recovered : Interface
  recovered_eq_formed : recovered = shift.formed

/-- The input-side diagonal certificate carried by an OOD cell. -/
def oodDiagonalIn
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
    (cell :
      OODRecoveredCell
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
    DiagonalCertificate Interface VisibleIn projectIn where
  left := cell.shift.formed
  right := cell.shift.shadow
  sameProjection := cell.shift.sameIn
  separatedInterface := cell.shift.separated

/-- The output-side diagonal certificate carried by an OOD cell. -/
def oodDiagonalOut
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
    (cell :
      OODRecoveredCell
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
    DiagonalCertificate Interface VisibleOut projectOut where
  left := cell.shift.formed
  right := cell.shift.shadow
  sameProjection := cell.shift.sameOut
  separatedInterface := cell.shift.separated

/-- The input-side projection obstruction carried by an OOD cell. -/
def oodProjectionObstructionIn
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
    (cell :
      OODRecoveredCell
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
  projectionObstructionOfDiagonalCertificate (oodDiagonalIn cell)

/-- The output-side projection obstruction carried by an OOD cell. -/
def oodProjectionObstructionOut
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
    (cell :
      OODRecoveredCell
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
  projectionObstructionOfDiagonalCertificate (oodDiagonalOut cell)

/-- Input-side local projective recovery. -/
def oodLocalRecoveryIn
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
    (cell :
      OODRecoveredCell
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
    LocalProjectiveRecovery Interface VisibleIn projectIn RepairOf where
  formed := cell.shift.formed
  shadow := cell.shift.shadow
  sameProjection := cell.shift.sameIn
  separated := cell.shift.separated
  repair := cell.repair
  recovered := cell.recovered
  recovered_eq_formed := cell.recovered_eq_formed

/-- Output-side local projective recovery. -/
def oodLocalRecoveryOut
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
    (cell :
      OODRecoveredCell
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
    LocalProjectiveRecovery Interface VisibleOut projectOut RepairOf where
  formed := cell.shift.formed
  shadow := cell.shift.shadow
  sameProjection := cell.shift.sameOut
  separated := cell.shift.separated
  repair := cell.repair
  recovered := cell.recovered
  recovered_eq_formed := cell.recovered_eq_formed

/-- Input-side projective non-reconstruction. -/
def oodNoProjectiveReconstructionIn
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
    (cell :
      OODRecoveredCell
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
  noProjectiveReconstruction (oodProjectionObstructionIn cell)

/-- Output-side projective non-reconstruction. -/
def oodNoProjectiveReconstructionOut
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
    (cell :
      OODRecoveredCell
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
  noProjectiveReconstruction (oodProjectionObstructionOut cell)

/--
Internal witness transported through the same OOD cell.

The abstract layer names `witnessOfCell`; concrete instances must make it a
direct field or theorem of the operative cell.
-/
structure OODWitnessTransport
    (Interface : Type u)
    (VisibleIn : Type v)
    (VisibleOut : Type w)
    (Label : Type z)
    (ShiftSource : Type r)
    (projectIn : Interface -> VisibleIn)
    (projectOut : Interface -> VisibleOut)
    (readIn : VisibleIn -> Label)
    (readOut : VisibleOut -> Label)
    (RepairOf : Interface -> Type s)
    (WitnessOf : Interface -> Type q) :
    Type (max u v w z r s q) where
  cell :
    OODRecoveredCell
      Interface
      VisibleIn
      VisibleOut
      Label
      ShiftSource
      projectIn
      projectOut
      readIn
      readOut
      RepairOf
  witnessOfCell : WitnessOf cell.shift.formed
  witnessIn : WitnessOf cell.shift.formed
  witnessOut : WitnessOf cell.shift.formed
  witnessIn_eq : witnessIn = witnessOfCell
  witnessOut_eq : witnessOut = witnessOfCell

/-- Positive Nat version of OOD witness transport. -/
structure OODPositiveWitnessTransport
    (Interface : Type u)
    (VisibleIn : Type v)
    (VisibleOut : Type w)
    (Label : Type z)
    (ShiftSource : Type r)
    (projectIn : Interface -> VisibleIn)
    (projectOut : Interface -> VisibleOut)
    (readIn : VisibleIn -> Label)
    (readOut : VisibleOut -> Label)
    (RepairOf : Interface -> Type s) :
    Type (max u v w z r s) where
  cell :
    OODRecoveredCell
      Interface
      VisibleIn
      VisibleOut
      Label
      ShiftSource
      projectIn
      projectOut
      readIn
      readOut
      RepairOf
  witnessOfCell : Nat
  witness_pos : 0 < witnessOfCell
  witnessIn : Nat
  witnessOut : Nat
  witnessIn_eq : witnessIn = witnessOfCell
  witnessOut_eq : witnessOut = witnessOfCell

/-- Full OOD certificate assembled from the witness transport. -/
structure OODStructuralCertificate
    (Interface : Type u)
    (VisibleIn : Type v)
    (VisibleOut : Type w)
    (Label : Type z)
    (ShiftSource : Type r)
    (projectIn : Interface -> VisibleIn)
    (projectOut : Interface -> VisibleOut)
    (readIn : VisibleIn -> Label)
    (readOut : VisibleOut -> Label)
    (RepairOf : Interface -> Type s)
    (WitnessOf : Interface -> Type q) :
    Type (max u v w z r s q) where
  transport :
    OODWitnessTransport
      Interface
      VisibleIn
      VisibleOut
      Label
      ShiftSource
      projectIn
      projectOut
      readIn
      readOut
      RepairOf
      WitnessOf
  visibleShift :
    readIn (projectIn transport.cell.shift.formed) =
      readOut (projectOut transport.cell.shift.formed) -> False
  diagonalIn :
    DiagonalCertificate Interface VisibleIn projectIn
  diagonalOut :
    DiagonalCertificate Interface VisibleOut projectOut
  projectionObstructionIn :
    ProjectionObstruction Interface VisibleIn projectIn
  projectionObstructionOut :
    ProjectionObstruction Interface VisibleOut projectOut
  noProjectiveReconstructionIn :
    ((recover : VisibleIn -> Interface) ->
      ((interface : Interface) ->
        recover (projectIn interface) = interface) ->
          False)
  noProjectiveReconstructionOut :
    ((recover : VisibleOut -> Interface) ->
      ((interface : Interface) ->
        recover (projectOut interface) = interface) ->
          False)

/-- Assemble the abstract OOD structural certificate. -/
def oodStructuralCertificateOfWitnessTransport
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
    {WitnessOf : Interface -> Type q}
    (transport :
      OODWitnessTransport
        Interface
        VisibleIn
        VisibleOut
        Label
        ShiftSource
        projectIn
        projectOut
        readIn
        readOut
        RepairOf
        WitnessOf) :
    OODStructuralCertificate
      Interface
      VisibleIn
      VisibleOut
      Label
      ShiftSource
      projectIn
      projectOut
      readIn
      readOut
      RepairOf
      WitnessOf where
  transport := transport
  visibleShift := transport.cell.shift.visibleShift
  diagonalIn := oodDiagonalIn transport.cell
  diagonalOut := oodDiagonalOut transport.cell
  projectionObstructionIn := oodProjectionObstructionIn transport.cell
  projectionObstructionOut := oodProjectionObstructionOut transport.cell
  noProjectiveReconstructionIn :=
    oodNoProjectiveReconstructionIn transport.cell
  noProjectiveReconstructionOut :=
    oodNoProjectiveReconstructionOut transport.cell

end OOD
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.OOD.OODProjectionShift
#print axioms Meta.OOD.OODProjectionShift.visibleShift
#print axioms Meta.OOD.OODRecoveredCell
#print axioms Meta.OOD.oodDiagonalIn
#print axioms Meta.OOD.oodDiagonalOut
#print axioms Meta.OOD.oodProjectionObstructionIn
#print axioms Meta.OOD.oodProjectionObstructionOut
#print axioms Meta.OOD.oodNoProjectiveReconstructionIn
#print axioms Meta.OOD.oodNoProjectiveReconstructionOut
#print axioms Meta.OOD.OODWitnessTransport
#print axioms Meta.OOD.OODPositiveWitnessTransport
#print axioms Meta.OOD.OODStructuralCertificate
#print axioms Meta.OOD.oodStructuralCertificateOfWitnessTransport
/- AXIOM_AUDIT_END -/
