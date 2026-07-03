import Meta.Core.ClosedStabilityTheorem

/-!
# Projected identity, identity of use, and non-contractive transport

This file formalizes a non-contractive regime of equality.

The theory stays constructive and projective: there is no Lean quotient object.
An interface is represented by a projection `project : Interface -> Visible`
and, when needed, a reading `read : Visible -> Label`.

A projected equality `project formed = project shadow` is not used to merge
the internal poles.  The cell keeps their internal separation as data, while
the projected equality is named as the identity of use and deployed as
transport through readings of the visible interface.

The central constructive chain is:

* internal separation is preserved;
* projected equality becomes `Id_use`;
* `Id_use` acts as read transport;
* polymorphic transport is equivalent to projected identity;
* reconstruction from the visible side is obstructed;
* a positive witness is carried by the diagonal cell itself;
* constrained relaxation preserves the witness and the chain across a visible
  regime change.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w z a

/-! ## Projected and read identities -/

/--
A projected identity cell.

The projection gives the two internal poles the same visible value, while the
cell keeps their internal separation as data.

This is the raw Lean form of an interface-induced observational equivalence:
the interface coordinates two poles without contracting them internally.
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

This records equality after the composite `read ∘ project`.  It is the
read-level form of an interface identity, again carried together with internal
separation of the two poles.
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

/--
A projected identity cell induces a read identity cell for any reading.

The proof term is ordinary equality congruence (`congrArg read`).  The point of
the structure is that this congruence is packaged inside a non-contractive
cell: the internal poles remain separated while the interface equality acts on
the reading.
-/
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

/-! ## Identity of use -/

/-- Internal identity on an interface. -/
abbrev InternalIdentity
    {Interface : Type u}
    {Visible : Type v}
    (_project : Interface -> Visible)
    (left right : Interface) :
    Prop :=
  left = right

/--
Identity produced by an interface projection.

This is the relation `Id_q`: the interface induces the same observation for
two internal poles, so they can be coordinated at the interface level without
being internally contracted.
-/
abbrev ProjectedIdentity
    {Interface : Type u}
    {Visible : Type v}
    (project : Interface -> Visible)
    (left right : Interface) :
    Prop :=
  project left = project right

/--
Identity of use induced by an interface.

This names the deliberate choice `Id_use := Id_q`: the
interface-induced observational equivalence becomes the equality used by the
constructive chain.  It is an alias, not a new quotient object.
-/
abbrev InterfaceIdentityOfUse
    {Interface : Type u}
    {Visible : Type v}
    (project : Interface -> Visible)
    (left right : Interface) :
    Prop :=
  ProjectedIdentity project left right

/--
The identity of use is exactly the projected identity.

This exposes `Id_use := Id_q` as a definitional equality of relations.
-/
theorem interfaceIdentityOfUse_iff_projectedIdentity
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (left right : Interface) :
    InterfaceIdentityOfUse project left right <->
      ProjectedIdentity project left right :=
  Iff.rfl

/-! ## Interface transport -/

/--
Read transport induced by an interface projection.

This is the fixed-reading form of the document's transport:

`Id_q(left, right)` acts through a reading `read : Visible -> Label` as
`read (project left) = read (project right)`.

In words: an interface-induced observational equivalence transports any fixed
reading of the visible representation.
-/
abbrev InterfaceReadTransport
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    (project : Interface -> Visible)
    (read : Visible -> Label)
    (left right : Interface) :
    Prop :=
  read (project left) = read (project right)

/--
A projected identity transports through every fixed reading.

The proof term is the local engine `congrArg read`.  Conceptually, this theorem
exposes the action direction: projected equality is not only a static equality
of visible values; inside the non-contractive cell it can be deployed through a
reading while internal separation remains available elsewhere in the chain.
-/
theorem interfaceReadTransportOfProjectedIdentity
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    {read : Visible -> Label}
    {left right : Interface}
    (identity : ProjectedIdentity project left right) :
    InterfaceReadTransport project read left right :=
  congrArg read identity

/--
An identity of use transports through every fixed reading.

Since `Id_use := Id_q`, the identity actually used by the interface has the
same transport power as projected identity.
-/
theorem interfaceReadTransportOfIdentityOfUse
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    {read : Visible -> Label}
    {left right : Interface}
    (identity : InterfaceIdentityOfUse project left right) :
    InterfaceReadTransport project read left right :=
  interfaceReadTransportOfProjectedIdentity identity

/--
Identity reading transport is exactly projected identity.

This is the Lean form of recovering `Id_q` by taking the reading to be the
identity on the visible type.

It records that transport is the operational form of `Id_q`: with the identity
reading, the transport statement is definitionally the projected identity.
-/
theorem interfaceReadTransport_id_iff_projectedIdentity
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (left right : Interface) :
    InterfaceReadTransport project (fun visible => visible) left right <->
      ProjectedIdentity project left right :=
  Iff.rfl

/--
Polymorphic interface transport.

This is `Id_q` seen as its full action on readings at the visible universe.
It packages the operational reading of projected equality: every admissible
reading must respect the same interface-induced observational equivalence.
-/
abbrev InterfaceTransport
    {Interface : Type u}
    {Visible : Type v}
    (project : Interface -> Visible)
    (left right : Interface) :
    Prop :=
  (Label : Type v) -> (read : Visible -> Label) ->
    InterfaceReadTransport project read left right

/--
Projected identity gives polymorphic interface transport.

This is the full action direction of `Transport_q`.
-/
theorem interfaceTransportOfProjectedIdentity
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {left right : Interface}
    (identity : ProjectedIdentity project left right) :
    InterfaceTransport project left right :=
  fun _ read => interfaceReadTransportOfProjectedIdentity (read := read) identity

/--
Polymorphic interface transport recovers projected identity.

Taking the reading to be the identity on `Visible` recovers the original
projected equality.
-/
theorem projectedIdentityOfInterfaceTransport
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {left right : Interface}
    (transport : InterfaceTransport project left right) :
    ProjectedIdentity project left right :=
  transport Visible (fun visible => visible)

/--
Polymorphic transport is exactly projected identity.

This theorem is the formal version of:

`Transport_q` is `Id_q` seen as a principle of action.
-/
theorem interfaceTransport_iff_projectedIdentity
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (left right : Interface) :
    InterfaceTransport project left right <->
      ProjectedIdentity project left right :=
  Iff.intro
    projectedIdentityOfInterfaceTransport
    interfaceTransportOfProjectedIdentity

/--
Identity of use gives polymorphic interface transport.

This is the dynamic step `Id_use -> Transport_q`.
-/
theorem interfaceTransportOfIdentityOfUse
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {left right : Interface}
    (identity : InterfaceIdentityOfUse project left right) :
    InterfaceTransport project left right :=
  interfaceTransportOfProjectedIdentity identity

/--
A projected identity cell is an identity-of-use cell.

It keeps the two internal poles separated while exposing the projected equality
as the identity used by the interface.
-/
structure IdentityOfUseCell
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Type (max u v) where
  formed : Interface
  shadow : Interface
  usedIdentity : InterfaceIdentityOfUse project formed shadow
  internalSeparation : InternalIdentity project formed shadow -> False

/-- Extract the identity-of-use cell from a projected identity cell. -/
def identityOfUseCellOfProjectedIdentityCell
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (cell : ProjectedIdentityCell Interface Visible project) :
    IdentityOfUseCell Interface Visible project where
  formed := cell.formed
  shadow := cell.shadow
  usedIdentity := cell.sameVisible
  internalSeparation := cell.separated

/--
The projected cell identifies its poles by the identity of use.

This is the formal shape of `Id_use(formed, shadow)`, with
`Id_use := Id_q`.
-/
theorem projectedIdentityCell_identityOfUse
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (cell : ProjectedIdentityCell Interface Visible project) :
    InterfaceIdentityOfUse project cell.formed cell.shadow :=
  cell.sameVisible

/--
The projected cell keeps its poles internally separated.

This is the formal shape of the internal separation carried alongside the
identity of use.
-/
theorem projectedIdentityCell_notInternalIdentity
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (cell : ProjectedIdentityCell Interface Visible project) :
    InternalIdentity project cell.formed cell.shadow -> False :=
  cell.separated

/--
A projected identity cell carries an identity of use together with internal
separation.

This is the minimal two-regime statement:
internal separation plus projected identity of use.
-/
theorem projectedIdentityCell_internalDifference_usedIdentity
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (cell : ProjectedIdentityCell Interface Visible project) :
    And
      (InternalIdentity project cell.formed cell.shadow -> False)
      (InterfaceIdentityOfUse project cell.formed cell.shadow) :=
  And.intro
    (projectedIdentityCell_notInternalIdentity cell)
    (projectedIdentityCell_identityOfUse cell)

/--
A projected identity cell transports through every fixed reading.

This turns the cell's identity of use into an equality at the read level.
-/
theorem projectedIdentityCell_readTransport
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    (read : Visible -> Label)
    (cell : ProjectedIdentityCell Interface Visible project) :
    InterfaceReadTransport project read cell.formed cell.shadow :=
  interfaceReadTransportOfIdentityOfUse
    (read := read)
    (projectedIdentityCell_identityOfUse cell)

/--
An identity-of-use cell transports through every fixed reading.

This exposes transport directly from the cell that already names `Id_use`.
-/
theorem identityOfUseCell_readTransport
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    (read : Visible -> Label)
    (cell : IdentityOfUseCell Interface Visible project) :
    InterfaceReadTransport project read cell.formed cell.shadow :=
  interfaceReadTransportOfIdentityOfUse
    (read := read)
    cell.usedIdentity

/--
The constructive chain carried by an interface equality.

It packages exactly:

* internal separation;
* identity of use;
* read transport induced by that identity of use.

This is the compact object that prevents the equality from being read as a
contraction of the poles.  Equality is used as a mediator for readings while
the internal distinction remains part of the same chain.
-/
abbrev ConstructiveInterfaceChain
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    (project : Interface -> Visible)
    (read : Visible -> Label)
    (left right : Interface) :
    Prop :=
  And
    (InternalIdentity project left right -> False)
    (And
      (InterfaceIdentityOfUse project left right)
      (InterfaceReadTransport project read left right))

/--
A projected identity cell carries the constructive chain:
internal separation, identity of use, and read transport.

This is the named facade for the dynamic sequence
`ProjectedIdentityCell -> Id_use -> read transport`.
-/
theorem projectedIdentityCell_constructiveChain
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    (read : Visible -> Label)
    (cell : ProjectedIdentityCell Interface Visible project) :
    ConstructiveInterfaceChain project read cell.formed cell.shadow :=
  And.intro
    (projectedIdentityCell_notInternalIdentity cell)
    (And.intro
      (projectedIdentityCell_identityOfUse cell)
      (projectedIdentityCell_readTransport read cell))

/--
An identity-of-use cell carries the constructive chain directly.

This is the same chain when the interface identity of use has already been
extracted as data.
-/
theorem identityOfUseCell_constructiveChain
    {Interface : Type u}
    {Visible : Type v}
    {Label : Type w}
    {project : Interface -> Visible}
    (read : Visible -> Label)
    (cell : IdentityOfUseCell Interface Visible project) :
    ConstructiveInterfaceChain project read cell.formed cell.shadow :=
  And.intro
    cell.internalSeparation
    (And.intro
      cell.usedIdentity
      (identityOfUseCell_readTransport read cell))

/--
A projected identity cell carries full polymorphic transport.

The cell carries `Id_q` as a principle of action on all visible readings.
-/
theorem projectedIdentityCell_interfaceTransport
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (cell : ProjectedIdentityCell Interface Visible project) :
    InterfaceTransport project cell.formed cell.shadow :=
  interfaceTransportOfIdentityOfUse
    (projectedIdentityCell_identityOfUse cell)

/--
An identity-of-use cell carries full polymorphic transport.

This is `Id_use` unfolded as `Transport_q`.
-/
theorem identityOfUseCell_interfaceTransport
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (cell : IdentityOfUseCell Interface Visible project) :
    InterfaceTransport project cell.formed cell.shadow :=
  interfaceTransportOfIdentityOfUse cell.usedIdentity

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

The witness family depends on the cell, so the positive witness is carried by
the diagonal identity data itself.
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

This is the read-level analogue of `PositiveProjectedInvariant`: the positive
witness is attached to the read identity cell itself.
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
projection carries the same two internal poles with a new projected identity,
the reading can shift, and the witness is explicitly conserved as input and
output witness data.

The relaxation does not erase the original diagonal structure.  It duplicates
the constructive chain across two visible regimes while preserving the same
internal poles and the positive witness carried by the source cell.

This is the regime-change object used later to expose: input constructive
chain, output constructive chain, and visible shift.
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

/-- The input-side read identity cell carried by a relaxation. -/
def readIdentityCellInOfConstrainedRelaxation
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
    ReadIdentityCell Interface VisibleIn Label projectIn readIn :=
  readIdentityCellOfProjectedIdentityCell
    readIn
    (projectedIdentityCellInOfConstrainedRelaxation relaxation)

/-- The output-side read identity cell carried by a relaxation. -/
def readIdentityCellOutOfConstrainedRelaxation
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
    ReadIdentityCell Interface VisibleOut Label projectOut readOut :=
  readIdentityCellOfProjectedIdentityCell
    readOut
    (projectedIdentityCellOutOfConstrainedRelaxation relaxation)

/-- The positive projected invariant carried by a constrained relaxation. -/
def positiveProjectedInvariantOfConstrainedRelaxation
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
    PositiveProjectedInvariant
      Interface
      VisibleIn
      projectIn
      WitnessOf
      Positive where
  cell := relaxation.sourceCell
  witness := relaxation.invariant
  witness_pos := relaxation.invariant_pos

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

/-- Input-side non-reconstruction carried by a constrained relaxation. -/
def noProjectiveReconstructionInOfConstrainedRelaxation
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
    ((recover : VisibleIn -> Interface) ->
      ((interface : Interface) ->
        recover (projectIn interface) = interface) ->
          False) :=
  noProjectiveReconstruction
    (projectionObstructionInOfConstrainedRelaxation relaxation)

/-- Output-side non-reconstruction carried by a constrained relaxation. -/
def noProjectiveReconstructionOutOfConstrainedRelaxation
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
    ((recover : VisibleOut -> Interface) ->
      ((interface : Interface) ->
        recover (projectOut interface) = interface) ->
          False) :=
  noProjectiveReconstruction
    (projectionObstructionOutOfConstrainedRelaxation relaxation)

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

/--
Input constructive chain carried by a constrained relaxation.

This exposes the source regime as a full chain: internal separation, identity
of use, and read transport through `projectIn`.
-/
def constructiveChainInOfConstrainedRelaxation
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
    ConstructiveInterfaceChain
      projectIn
      readIn
      relaxation.formed
      relaxation.shadow :=
  projectedIdentityCell_constructiveChain
    readIn
    (projectedIdentityCellInOfConstrainedRelaxation relaxation)

/--
Output constructive chain carried by a constrained relaxation.

This exposes the target regime as a full chain over the same internal poles,
now through `projectOut` and `readOut`.
-/
def constructiveChainOutOfConstrainedRelaxation
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
    ConstructiveInterfaceChain
      projectOut
      readOut
      relaxation.formed
      relaxation.shadow :=
  projectedIdentityCell_constructiveChain
    readOut
    (projectedIdentityCellOutOfConstrainedRelaxation relaxation)

/--
A constrained relaxation carries input chain, output chain, and visible shift.

This is the explicit regime-change facade:

* the input projection carries a constructive interface chain;
* the output projection carries a constructive interface chain over the same
  internal poles;
* `visibleShift` records that the two read regimes do not collapse into one
  read value on the formed pole.
-/
theorem constrainedProjectionRelaxation_constructiveRegimeChange
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
    And
      (ConstructiveInterfaceChain
        projectIn
        readIn
        relaxation.formed
        relaxation.shadow)
      (And
        (ConstructiveInterfaceChain
          projectOut
          readOut
          relaxation.formed
          relaxation.shadow)
        (readIn (projectIn relaxation.formed) =
          readOut (projectOut relaxation.formed) -> False)) :=
  And.intro
    (constructiveChainInOfConstrainedRelaxation relaxation)
    (And.intro
      (constructiveChainOutOfConstrainedRelaxation relaxation)
      relaxation.visibleShift)

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.ProjectedIdentityCell
#print axioms Meta.ClosedStabilityTheorem.readProjection
#print axioms Meta.ClosedStabilityTheorem.ReadIdentityCell
#print axioms Meta.ClosedStabilityTheorem.readIdentityCellOfProjectedIdentityCell
#print axioms Meta.ClosedStabilityTheorem.InternalIdentity
#print axioms Meta.ClosedStabilityTheorem.ProjectedIdentity
#print axioms Meta.ClosedStabilityTheorem.InterfaceIdentityOfUse
#print axioms Meta.ClosedStabilityTheorem.interfaceIdentityOfUse_iff_projectedIdentity
#print axioms Meta.ClosedStabilityTheorem.InterfaceReadTransport
#print axioms Meta.ClosedStabilityTheorem.interfaceReadTransportOfProjectedIdentity
#print axioms Meta.ClosedStabilityTheorem.interfaceReadTransportOfIdentityOfUse
#print axioms Meta.ClosedStabilityTheorem.interfaceReadTransport_id_iff_projectedIdentity
#print axioms Meta.ClosedStabilityTheorem.InterfaceTransport
#print axioms Meta.ClosedStabilityTheorem.interfaceTransportOfProjectedIdentity
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityOfInterfaceTransport
#print axioms Meta.ClosedStabilityTheorem.interfaceTransport_iff_projectedIdentity
#print axioms Meta.ClosedStabilityTheorem.interfaceTransportOfIdentityOfUse
#print axioms Meta.ClosedStabilityTheorem.IdentityOfUseCell
#print axioms Meta.ClosedStabilityTheorem.identityOfUseCellOfProjectedIdentityCell
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityCell_identityOfUse
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityCell_notInternalIdentity
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityCell_internalDifference_usedIdentity
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityCell_readTransport
#print axioms Meta.ClosedStabilityTheorem.identityOfUseCell_readTransport
#print axioms Meta.ClosedStabilityTheorem.ConstructiveInterfaceChain
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityCell_constructiveChain
#print axioms Meta.ClosedStabilityTheorem.identityOfUseCell_constructiveChain
#print axioms Meta.ClosedStabilityTheorem.projectedIdentityCell_interfaceTransport
#print axioms Meta.ClosedStabilityTheorem.identityOfUseCell_interfaceTransport
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
#print axioms Meta.ClosedStabilityTheorem.readIdentityCellInOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.readIdentityCellOutOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.positiveProjectedInvariantOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.projectionObstructionInOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.projectionObstructionOutOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstructionInOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstructionOutOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.constrainedProjectionRelaxation_witnessIn_eq_invariant
#print axioms Meta.ClosedStabilityTheorem.constrainedProjectionRelaxation_witnessOut_eq_invariant
#print axioms Meta.ClosedStabilityTheorem.constructiveChainInOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.constructiveChainOutOfConstrainedRelaxation
#print axioms Meta.ClosedStabilityTheorem.constrainedProjectionRelaxation_constructiveRegimeChange
/- AXIOM_AUDIT_END -/
