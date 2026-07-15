/-!
# Projective obstruction and local recovery

This import-free root contains projection, obstruction, reconstruction,
proof-relevant local recovery, and local projected-truth separation. It is
independent of bilateral completeness and terminal cycles.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s

/-! ## Projective non-reducibility -/

/--
An explicit obstruction to reconstruction from a visible projection.

Two formed interfaces have the same visible projection but are not equal as
formed interfaces.
-/
structure ProjectionObstruction
    (Interface : Type x)
    (Visible : Type y)
    (project : Interface -> Visible) :
    Type (max x y) where
  left : Interface
  right : Interface
  sameProjection : project left = project right
  separatedInterface : left = right -> False

/--
Projection fiber faithfulness is the internal information-conservation test:
two formed interfaces with the same projection must already be the same formed
interface.
-/
structure ProjectionFiberFaithful
    (Interface : Type x)
    (Visible : Type y)
    (project : Interface -> Visible) :
    Prop where
  preserves :
    (left right : Interface) ->
      project left = project right ->
        left = right

/--
Projection information conservation is the stronger global form: a visible
value carries a reconstructor that recovers every formed interface after
projection.
-/
structure ProjectionInformationConserving
    (Interface : Type x)
    (Visible : Type y)
    (project : Interface -> Visible) :
    Type (max x y) where
  recover : Visible -> Interface
  reconstructs :
    (interface : Interface) ->
      recover (project interface) = interface

/-- A global projection reconstructor implies projection fiber faithfulness. -/
theorem projectionFiberFaithful_of_informationConserving
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    (conserving :
      ProjectionInformationConserving Interface Visible project) :
    ProjectionFiberFaithful Interface Visible project := by
  refine ⟨?_⟩
  intro left right sameProjection
  have hLeft :
      conserving.recover (project left) = left :=
    conserving.reconstructs left
  have hRight :
      conserving.recover (project right) = right :=
    conserving.reconstructs right
  calc
    left =
        conserving.recover (project left) := hLeft.symm
    _ = conserving.recover (project right) := by
          rw [sameProjection]
    _ = right := hRight

/-- A projection obstruction refutes projection fiber faithfulness. -/
theorem projectionObstruction_notFiberFaithful
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    (obstruction : ProjectionObstruction Interface Visible project)
    (faithful : ProjectionFiberFaithful Interface Visible project) :
    False :=
  obstruction.separatedInterface
    (faithful.preserves
      obstruction.left
      obstruction.right
      obstruction.sameProjection)

/-- A projection obstruction refutes global projection information conservation. -/
theorem projectionObstruction_notInformationConserving
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    (obstruction : ProjectionObstruction Interface Visible project)
    (conserving :
      ProjectionInformationConserving Interface Visible project) :
    False :=
  projectionObstruction_notFiberFaithful
    obstruction
    (projectionFiberFaithful_of_informationConserving conserving)

/-- A projection obstruction rules out a canonical projective reconstruction. -/
def noProjectiveReconstruction
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    (obstruction : ProjectionObstruction Interface Visible project) :
    ((recover : Visible -> Interface) ->
      ((interface : Interface) ->
        recover (project interface) = interface) ->
          False) := by
  intro recover recovers
  have hLeft :
      obstruction.left =
        recover (project obstruction.left) :=
    Eq.symm (recovers obstruction.left)
  have hSame :
      recover (project obstruction.left) =
        recover (project obstruction.right) :=
    congrArg recover obstruction.sameProjection
  have hRight :
      recover (project obstruction.right) =
        obstruction.right :=
    recovers obstruction.right
  exact
    obstruction.separatedInterface
      (Eq.trans hLeft (Eq.trans hSame hRight))

/--
A diagonal certificate is sufficient when it gives equal visible projection and
separated formed interfaces.
-/
structure DiagonalCertificate
    (Interface : Type x)
    (Visible : Type y)
    (project : Interface -> Visible) :
    Type (max x y) where
  left : Interface
  right : Interface
  sameProjection : project left = project right
  separatedInterface : left = right -> False

/-- A diagonal certificate yields the projection obstruction. -/
def projectionObstructionOfDiagonalCertificate
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    (diagonal : DiagonalCertificate Interface Visible project) :
    ProjectionObstruction Interface Visible project where
  left := diagonal.left
  right := diagonal.right
  sameProjection := diagonal.sameProjection
  separatedInterface := diagonal.separatedInterface

/-! ## Recovery and terminal projection packages -/

/--
Local projective recovery.

The package is indexed by the exact formed interface.  It records the
payload-visible shadow, the diagonal separation from that shadow, the repair
attached to the formed interface, and the recovered interface.
-/
structure LocalProjectiveRecovery
    (Interface : Type x)
    (Visible : Type y)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max x y s) where
  formed : Interface
  shadow : Interface
  sameProjection : project formed = project shadow
  separated : formed = shadow -> False
  repair : RepairOf formed
  recovered : Interface
  recovered_eq_formed : recovered = formed

/-- The obstruction carried by a local projective recovery package. -/
def localProjectiveRecovery_obstruction
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (localRecovery :
      LocalProjectiveRecovery Interface Visible project RepairOf) :
    ProjectionObstruction Interface Visible project where
  left := localRecovery.formed
  right := localRecovery.shadow
  sameProjection := localRecovery.sameProjection
  separatedInterface := localRecovery.separated

/-- A local projective recovery rules out global projective reconstruction. -/
def noProjectiveReconstructionOfLocalProjectiveRecovery
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (localRecovery :
      LocalProjectiveRecovery Interface Visible project RepairOf) :
    ((recover : Visible -> Interface) ->
      ((interface : Interface) ->
        recover (project interface) = interface) ->
          False) :=
  noProjectiveReconstruction
    (localProjectiveRecovery_obstruction localRecovery)

/-- A local projective recovery refutes projection fiber faithfulness. -/
theorem localProjectiveRecovery_notFiberFaithful
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (localRecovery :
      LocalProjectiveRecovery Interface Visible project RepairOf)
    (faithful : ProjectionFiberFaithful Interface Visible project) :
    False :=
  projectionObstruction_notFiberFaithful
    (localProjectiveRecovery_obstruction localRecovery)
    faithful

/-- A local projective recovery refutes global projection information conservation. -/
theorem localProjectiveRecovery_notInformationConserving
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (localRecovery :
      LocalProjectiveRecovery Interface Visible project RepairOf)
    (conserving :
      ProjectionInformationConserving Interface Visible project) :
    False :=
  projectionObstruction_notInformationConserving
    (localProjectiveRecovery_obstruction localRecovery)
    conserving

/-! ## Local formation / projected-truth separation over a gap -/

/-- A referential scene is a local collection of formed interfaces. -/
abbrev ReferentialScene
    (Interface : Type x) :
    Type x :=
  Interface -> Prop

/--
Geometric formation: the scene contains an interface carrying the chosen
truth/formation predicate.
-/
def GeometricFormation
    {Interface : Type x}
    (Truth : Interface -> Prop)
    (scene : ReferentialScene Interface) :
    Prop :=
  ∃ interface : Interface,
    scene interface ∧ Truth interface

/--
Projected local truth: inside the scene, the visible projection preserves the
chosen local truth/formation predicate along equal visible payloads.
-/
def ProjectedLocalTruth
    {Interface : Type x}
    {Visible : Type y}
    (project : Interface -> Visible)
    (Truth : Interface -> Prop)
    (scene : ReferentialScene Interface) :
    Prop :=
  ∀ left right : Interface,
    scene left ->
    scene right ->
    project left = project right ->
      (Truth left ↔ Truth right)

/--
Local projected-truth recovery over a gap.

It is a local projective recovery whose formed side carries the selected truth
while its projected shadow does not.  This is the abstract `1 + gap + 1`
interface: formed truth, projective gap, recovered formed truth.
-/
structure LocalTruthGapRecovery
    (Interface : Type x)
    (Visible : Type y)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s)
    (Truth : Interface -> Prop) :
    Type (max x y s) where
  localRecovery :
    LocalProjectiveRecovery Interface Visible project RepairOf
  formed_truth :
    Truth localRecovery.formed
  shadow_not_truth :
    Truth localRecovery.shadow -> False

/-- The two-point scene around the formed interface and its projected shadow. -/
def localTruthGapRecovery_fullScene
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {Truth : Interface -> Prop}
    (truthGap :
      LocalTruthGapRecovery Interface Visible project RepairOf Truth) :
    ReferentialScene Interface :=
  fun interface =>
    interface = truthGap.localRecovery.formed ∨
      interface = truthGap.localRecovery.shadow

/-- The shadow-only scene associated to a local truth gap. -/
def localTruthGapRecovery_shadowScene
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {Truth : Interface -> Prop}
    (truthGap :
      LocalTruthGapRecovery Interface Visible project RepairOf Truth) :
    ReferentialScene Interface :=
  fun interface =>
    interface = truthGap.localRecovery.shadow

/-- The full local scene is geometrically formed. -/
theorem localTruthGapRecovery_fullScene_geometricFormation
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {Truth : Interface -> Prop}
    (truthGap :
      LocalTruthGapRecovery Interface Visible project RepairOf Truth) :
    GeometricFormation
      Truth
      (localTruthGapRecovery_fullScene truthGap) := by
  exact
    ⟨ truthGap.localRecovery.formed
    , Or.inl rfl
    , truthGap.formed_truth
    ⟩

/-- The full local scene cannot preserve local truth by visible projection. -/
theorem localTruthGapRecovery_fullScene_not_projectedDynamicTruth
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {Truth : Interface -> Prop}
    (truthGap :
      LocalTruthGapRecovery Interface Visible project RepairOf Truth) :
    ProjectedLocalTruth
      project
      Truth
      (localTruthGapRecovery_fullScene truthGap) ->
        False := by
  intro hTruth
  have hIff :
      Truth truthGap.localRecovery.formed ↔
        Truth truthGap.localRecovery.shadow :=
    hTruth
      truthGap.localRecovery.formed
      truthGap.localRecovery.shadow
      (Or.inl rfl)
      (Or.inr rfl)
      truthGap.localRecovery.sameProjection
  exact
    truthGap.shadow_not_truth
      (hIff.mp truthGap.formed_truth)

/--
The shadow-only scene is projectively truth-stable: any truth claim inside it is
already impossible, because the sole projected shadow does not carry truth.
-/
theorem localTruthGapRecovery_shadowScene_projectedDynamicTruth
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {Truth : Interface -> Prop}
    (truthGap :
      LocalTruthGapRecovery Interface Visible project RepairOf Truth) :
    ProjectedLocalTruth
      project
      Truth
      (localTruthGapRecovery_shadowScene truthGap) := by
  intro left right hLeft hRight _sameProjection
  constructor
  · intro hTruth
    rw [hLeft] at hTruth
    exact False.elim (truthGap.shadow_not_truth hTruth)
  · intro hTruth
    rw [hRight] at hTruth
    exact False.elim (truthGap.shadow_not_truth hTruth)

/-- The shadow-only scene is not geometrically formed. -/
theorem localTruthGapRecovery_shadowScene_not_geometricFormation
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {Truth : Interface -> Prop}
    (truthGap :
      LocalTruthGapRecovery Interface Visible project RepairOf Truth) :
    GeometricFormation
      Truth
      (localTruthGapRecovery_shadowScene truthGap) ->
        False := by
  intro hFormation
  rcases hFormation with ⟨interface, hScene, hTruth⟩
  rw [hScene] at hTruth
  exact truthGap.shadow_not_truth hTruth

/--
A local projected-truth recovery over a gap separates local formation from
projected local truth in both directions.
-/
theorem localTruthGapRecovery_localFormation_projectedTruth_independent
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {Truth : Interface -> Prop}
    (truthGap :
      LocalTruthGapRecovery Interface Visible project RepairOf Truth) :
    (∃ scene : ReferentialScene Interface,
      GeometricFormation Truth scene ∧
        (ProjectedLocalTruth project Truth scene -> False))
    ∧
    (∃ scene : ReferentialScene Interface,
      ProjectedLocalTruth project Truth scene ∧
        (GeometricFormation Truth scene -> False)) := by
  constructor
  · exact
      ⟨ localTruthGapRecovery_fullScene truthGap
      , localTruthGapRecovery_fullScene_geometricFormation truthGap
      , localTruthGapRecovery_fullScene_not_projectedDynamicTruth truthGap
      ⟩
  · exact
      ⟨ localTruthGapRecovery_shadowScene truthGap
      , localTruthGapRecovery_shadowScene_projectedDynamicTruth truthGap
      , localTruthGapRecovery_shadowScene_not_geometricFormation truthGap
      ⟩

/-- Recovery data indexed by the formed interface it repairs. -/
structure RecoveryBundle
    (Interface : Type x)
    (RepairOf : Interface -> Type s) :
    Type (max x s) where
  interface : Interface
  repair : RepairOf interface

/-- A local projective recovery gives the ordinary recovery bundle. -/
def recoveryBundleOfLocalProjectiveRecovery
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (localRecovery :
      LocalProjectiveRecovery Interface Visible project RepairOf) :
    RecoveryBundle Interface RepairOf where
  interface := localRecovery.formed
  repair := localRecovery.repair

/-- Terminal projection from a formed interface to a visible value. -/
structure TerminalProjection
    (Interface : Type x)
    (Visible : Type y)
    (project : Interface -> Visible) :
    Type (max x y) where
  interface : Interface
  visible : Visible
  projected : project interface = visible

/-- A local projective recovery gives the terminal visible projection. -/
def terminalProjectionOfLocalProjectiveRecovery
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (localRecovery :
      LocalProjectiveRecovery Interface Visible project RepairOf) :
    TerminalProjection Interface Visible project where
  interface := localRecovery.formed
  visible := project localRecovery.formed
  projected := rfl


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


/-! ## Referential length regimes -/

/-- The short regime: the visible projection has contractible fibers. -/
abbrev ShortReferentialPresentation
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Prop :=
  ContractibleReferentialGap Interface Visible project

/-- The enriched structural regime: one visible value can cover separated interfaces. -/
abbrev EnrichedStructuralReferentialLength
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible) :
    Type (max u v) :=
  StructuralReferentialGap Interface Visible project

/--
The enriched operational regime: a structural gap plus local repair of the
formed interface.
-/
abbrev EnrichedOperationalReferentialLength
    (Interface : Type u)
    (Visible : Type v)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max u v s) :=
  OperationalReferentialGap Interface Visible project RepairOf

/-- A structural enriched length refutes the short presentation. -/
theorem structuralLength_refutes_shortPresentation
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    (gap :
      EnrichedStructuralReferentialLength Interface Visible project)
    (short :
      ShortReferentialPresentation Interface Visible project) :
    False :=
  structuralGap_not_contractible gap short

/-- An operational enriched length refutes the short presentation. -/
theorem operationalLength_refutes_shortPresentation
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      EnrichedOperationalReferentialLength
        Interface
        Visible
        project
        RepairOf)
    (short :
      ShortReferentialPresentation Interface Visible project) :
    False :=
  operationalGap_not_contractible gap short

/-- An operational enriched length exposes the structural enriched length it carries. -/
def structuralLengthOfOperationalLength
    {Interface : Type u}
    {Visible : Type v}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (gap :
      EnrichedOperationalReferentialLength
        Interface
        Visible
        project
        RepairOf) :
    EnrichedStructuralReferentialLength Interface Visible project :=
  structuralGapOfOperationalGap gap


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
#print axioms Meta.ClosedStabilityTheorem.ProjectionObstruction
#print axioms Meta.ClosedStabilityTheorem.ProjectionFiberFaithful
#print axioms Meta.ClosedStabilityTheorem.ProjectionInformationConserving
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstruction
#print axioms Meta.ClosedStabilityTheorem.DiagonalCertificate
#print axioms Meta.ClosedStabilityTheorem.LocalProjectiveRecovery
#print axioms Meta.ClosedStabilityTheorem.localProjectiveRecovery_obstruction
#print axioms Meta.ClosedStabilityTheorem.LocalTruthGapRecovery
#print axioms Meta.ClosedStabilityTheorem.localTruthGapRecovery_localFormation_projectedTruth_independent
#print axioms Meta.ClosedStabilityTheorem.RecoveryBundle
#print axioms Meta.ClosedStabilityTheorem.TerminalProjection
#print axioms Meta.ClosedStabilityTheorem.StructuralReferentialGap
#print axioms Meta.ClosedStabilityTheorem.OperationalReferentialGap
#print axioms Meta.ClosedStabilityTheorem.EnrichedOperationalReferentialLength
#print axioms Meta.ClosedStabilityTheorem.StructuralTwoPole
#print axioms Meta.ClosedStabilityTheorem.OperationalTwoPole
#print axioms Meta.ClosedStabilityTheorem.operationalTwoPole_noProjectiveReconstruction
/- AXIOM_AUDIT_END -/
