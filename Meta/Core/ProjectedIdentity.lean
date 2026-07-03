import Meta.Core.ClosedStabilityTheorem

/-!
# Projected identity and constrained relaxation

This file extracts the abstract core behind quotient-like identities.

The theory stays constructive and projective: there is no Lean quotient object.
An interface is represented by a projection `project : Interface -> Visible`
and, when needed, a reading `read : Visible -> Label`.

The central pattern is:

* two internal interfaces can be separated while sharing one projection;
* this yields a diagonal certificate and a reconstruction obstruction;
* a positive witness must be carried by the diagonal cell itself;
* a constrained relaxation preserves that witness across the input/output
  sides of a visible regime change.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w z a

/-! ## Projected and read identities -/

/--
A projected identity cell.

The projection identifies `formed` and `shadow`, while the internal interface
keeps them separated.
-/
structure ProjectedIdentityCell
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Type (max u v) where
  formed : Interface
  shadow : Interface
  sameVisible : project formed = project shadow
  separated : formed = shadow -> False

/-- The composite reading of a projection. -/
def readProjection
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    (project : Interface -> Visible)
    (read : Visible -> Label) :
    Interface -> Label :=
  fun interface => read (project interface)

/--
A read identity cell.

This is weaker than projected identity: it only says the readings agree.
-/
structure ReadIdentityCell
    (Interface : Type u)
    (Visible : Type v)
    (Label : Type w)
    (project : Interface -> Visible)
    (read : Visible -> Label) :
    Type (max u v w) where
  formed : Interface
  shadow : Interface
  sameRead :
    read (project formed) = read (project shadow)
  separated : formed = shadow -> False

/-- A projected identity cell induces a read identity cell for any reading. -/
def readIdentityCellOfProjectedIdentityCell
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    (read : Visible -> Label)
    (cell : ProjectedIdentityCell Interface Visible project) :
    ReadIdentityCell Interface Visible Label project read where
  formed := cell.formed
  shadow := cell.shadow
  sameRead := congrArg read cell.sameVisible
  separated := cell.separated

/-! ## Diagonal certificates and obstructions -/

/-- A projected identity cell is a diagonal certificate. -/
def diagonalCertificateOfProjectedIdentityCell
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (cell : ProjectedIdentityCell Interface Visible project) :
    DiagonalCertificate Interface Visible project where
  left := cell.formed
  right := cell.shadow
  sameProjection := cell.sameVisible
  separatedInterface := cell.separated

/-- A projected identity cell yields a projection obstruction. -/
def projectionObstructionOfProjectedIdentityCell
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (cell : ProjectedIdentityCell Interface Visible project) :
    ProjectionObstruction Interface Visible project :=
  projectionObstructionOfDiagonalCertificate
    (diagonalCertificateOfProjectedIdentityCell cell)

/-- A projected identity cell rules out global reconstruction from `Visible`. -/
def noProjectiveReconstructionOfProjectedIdentityCell
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (cell : ProjectedIdentityCell Interface Visible project) :
    ((recover : Visible -> Interface) ->
      ((interface : Interface) ->
        recover (project interface) = interface) ->
          False) :=
  noProjectiveReconstruction
    (projectionObstructionOfProjectedIdentityCell cell)

/-- A read identity cell is a diagonal certificate for the read projection. -/
def diagonalCertificateOfReadIdentityCell
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    {read : Visible -> Label}
    (cell : ReadIdentityCell Interface Visible Label project read) :
    DiagonalCertificate
      Interface
      Label
      (readProjection project read) where
  left := cell.formed
  right := cell.shadow
  sameProjection := cell.sameRead
  separatedInterface := cell.separated

/-- A read identity cell yields an obstruction for reconstruction from labels. -/
def projectionObstructionOfReadIdentityCell
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    {read : Visible -> Label}
    (cell : ReadIdentityCell Interface Visible Label project read) :
    ProjectionObstruction
      Interface
      Label
      (readProjection project read) :=
  projectionObstructionOfDiagonalCertificate
    (diagonalCertificateOfReadIdentityCell cell)

/-- A read identity cell rules out global reconstruction from read labels. -/
def noProjectiveReconstructionOfReadIdentityCell
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    {read : Visible -> Label}
    (cell : ReadIdentityCell Interface Visible Label project read) :
    ((recover : Label -> Interface) ->
      ((interface : Interface) ->
        recover (read (project interface)) = interface) ->
          False) :=
  noProjectiveReconstruction
    (projectionObstructionOfReadIdentityCell cell)

/-! ## Positive witnesses carried by identity cells -/

/--
A positive invariant carried by a projected identity cell.

The witness family depends on the cell, so the witness is not an external
positive value added after the diagonal cell has been built.
-/
structure PositiveProjectedInvariant
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (WitnessOf :
      ProjectedIdentityCell Interface Visible project -> Type a)
    (Positive :
      (cell : ProjectedIdentityCell Interface Visible project) ->
        WitnessOf cell -> Prop) :
    Type (max u v a) where
  cell : ProjectedIdentityCell Interface Visible project
  witness : WitnessOf cell
  witness_pos : Positive cell witness

/--
A positive invariant carried by a read identity cell.

This is the read-level analogue of `PositiveProjectedInvariant`.
-/
structure PositiveReadInvariant
    (Interface : Type u)
    (Visible : Type v)
    (Label : Type w)
    (project : Interface -> Visible)
    (read : Visible -> Label)
    (WitnessOf :
      ReadIdentityCell Interface Visible Label project read -> Type a)
    (Positive :
      (cell : ReadIdentityCell Interface Visible Label project read) ->
        WitnessOf cell -> Prop) :
    Type (max u v w a) where
  cell : ReadIdentityCell Interface Visible Label project read
  witness : WitnessOf cell
  witness_pos : Positive cell witness

/-! ## Constrained relaxation -/

/--
A constrained projection relaxation.

The source projected identity cell carries the invariant witness.  The output
projection also contracts the same internal pair, the reading can shift, and
the witness is explicitly conserved as input and output witness data.
-/
structure ConstrainedProjectionRelaxation
    (Interface : Type u)
    (VisibleIn : Type v)
    (VisibleOut : Type w)
    (Label : Type z)
    (projectIn : Interface -> VisibleIn)
    (projectOut : Interface -> VisibleOut)
    (readIn : VisibleIn -> Label)
    (readOut : VisibleOut -> Label)
    (WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a)
    (Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop) :
    Type (max u v w a) where
  sourceCell :
    ProjectedIdentityCell Interface VisibleIn projectIn
  sameOut :
    projectOut sourceCell.formed = projectOut sourceCell.shadow
  visibleShift :
    readIn (projectIn sourceCell.formed) =
      readOut (projectOut sourceCell.formed) -> False
  invariant : WitnessOf sourceCell
  invariant_pos : Positive sourceCell invariant
  witnessIn : WitnessOf sourceCell
  witnessOut : WitnessOf sourceCell
  witnessIn_eq : witnessIn = invariant
  witnessOut_eq : witnessOut = invariant

/-- The formed interface of a constrained relaxation. -/
def ConstrainedProjectionRelaxation.formed
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a}
    {Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop}
    (relaxation :
      ConstrainedProjectionRelaxation
        Interface
        VisibleIn
        VisibleOut
        Label
        projectIn
        projectOut
        readIn
        readOut
        WitnessOf
        Positive) :
    Interface :=
  relaxation.sourceCell.formed

/-- The shadow interface of a constrained relaxation. -/
def ConstrainedProjectionRelaxation.shadow
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a}
    {Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop}
    (relaxation :
      ConstrainedProjectionRelaxation
        Interface
        VisibleIn
        VisibleOut
        Label
        projectIn
        projectOut
        readIn
        readOut
        WitnessOf
        Positive) :
    Interface :=
  relaxation.sourceCell.shadow

/-- The input-side projected identity cell carried by a relaxation. -/
def projectedIdentityCellInOfConstrainedRelaxation
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a}
    {Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop}
    (relaxation :
      ConstrainedProjectionRelaxation
        Interface
        VisibleIn
        VisibleOut
        Label
        projectIn
        projectOut
        readIn
        readOut
        WitnessOf
        Positive) :
    ProjectedIdentityCell Interface VisibleIn projectIn :=
  relaxation.sourceCell

/-- The output-side projected identity cell carried by a relaxation. -/
def projectedIdentityCellOutOfConstrainedRelaxation
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a}
    {Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop}
    (relaxation :
      ConstrainedProjectionRelaxation
        Interface
        VisibleIn
        VisibleOut
        Label
        projectIn
        projectOut
        readIn
        readOut
        WitnessOf
        Positive) :
    ProjectedIdentityCell Interface VisibleOut projectOut where
  formed := relaxation.sourceCell.formed
  shadow := relaxation.sourceCell.shadow
  sameVisible := relaxation.sameOut
  separated := relaxation.sourceCell.separated

/-- The input-side obstruction carried by a constrained relaxation. -/
def projectionObstructionInOfConstrainedRelaxation
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a}
    {Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop}
    (relaxation :
      ConstrainedProjectionRelaxation
        Interface
        VisibleIn
        VisibleOut
        Label
        projectIn
        projectOut
        readIn
        readOut
        WitnessOf
        Positive) :
    ProjectionObstruction Interface VisibleIn projectIn :=
  projectionObstructionOfProjectedIdentityCell
    (projectedIdentityCellInOfConstrainedRelaxation relaxation)

/-- The output-side obstruction carried by a constrained relaxation. -/
def projectionObstructionOutOfConstrainedRelaxation
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a}
    {Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop}
    (relaxation :
      ConstrainedProjectionRelaxation
        Interface
        VisibleIn
        VisibleOut
        Label
        projectIn
        projectOut
        readIn
        readOut
        WitnessOf
        Positive) :
    ProjectionObstruction Interface VisibleOut projectOut :=
  projectionObstructionOfProjectedIdentityCell
    (projectedIdentityCellOutOfConstrainedRelaxation relaxation)

/-- The invariant is conserved on the input side. -/
theorem constrainedProjectionRelaxation_witnessIn_eq_invariant
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a}
    {Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop}
    (relaxation :
      ConstrainedProjectionRelaxation
        Interface
        VisibleIn
        VisibleOut
        Label
        projectIn
        projectOut
        readIn
        readOut
        WitnessOf
        Positive) :
    relaxation.witnessIn = relaxation.invariant :=
  relaxation.witnessIn_eq

/-- The invariant is conserved on the output side. -/
theorem constrainedProjectionRelaxation_witnessOut_eq_invariant
    {Interface : Type u}
    {VisibleIn : Type v}
    {VisibleOut : Type w}
    {Label : Type z}
    {projectIn : Interface -> VisibleIn}
    {projectOut : Interface -> VisibleOut}
    {readIn : VisibleIn -> Label}
    {readOut : VisibleOut -> Label}
    {WitnessOf :
      ProjectedIdentityCell Interface VisibleIn projectIn -> Type a}
    {Positive :
      (cell : ProjectedIdentityCell Interface VisibleIn projectIn) ->
        WitnessOf cell -> Prop}
    (relaxation :
      ConstrainedProjectionRelaxation
        Interface
        VisibleIn
        VisibleOut
        Label
        projectIn
        projectOut
        readIn
        readOut
        WitnessOf
        Positive) :
    relaxation.witnessOut = relaxation.invariant :=
  relaxation.witnessOut_eq

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.ProjectedIdentityCell
#print axioms Meta.ClosedStabilityTheorem.readProjection
#print axioms Meta.ClosedStabilityTheorem.ReadIdentityCell
#print axioms Meta.ClosedStabilityTheorem.readIdentityCellOfProjectedIdentityCell
#print axioms Meta.ClosedStabilityTheorem.diagonalCertificateOfProjectedIdentityCell
#print axioms Meta.ClosedStabilityTheorem.projectionObstructionOfProjectedIdentityCell
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstructionOfProjectedIdentityCell
#print axioms Meta.ClosedStabilityTheorem.diagonalCertificateOfReadIdentityCell
#print axioms Meta.ClosedStabilityTheorem.projectionObstructionOfReadIdentityCell
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstructionOfReadIdentityCell
#print axioms Meta.ClosedStabilityTheorem.PositiveProjectedInvariant
#print axioms Meta.ClosedStabilityTheorem.PositiveReadInvariant
#print axioms Meta.ClosedStabilityTheorem.ConstrainedProjectionRelaxation
#print axioms Meta.ClosedStabilityTheorem.ConstrainedProjectionRelaxation.formed
#print axioms Meta.ClosedStabilityTheorem.ConstrainedProjectionRelaxation.shadow
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityCellInOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityCellOutOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.projectionObstructionInOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.projectionObstructionOutOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.constrainedProjectionRelaxation_witnessIn_eq_invariant
#print axioms Meta.ClosedStabilityTheorem.constrainedProjectionRelaxation_witnessOut_eq_invariant
/- AXIOM_AUDIT_END -/
