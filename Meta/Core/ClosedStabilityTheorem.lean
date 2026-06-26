/-!
# Standalone closed-stability package

This file isolates the abstract closed-stability package with no imports.

It formalizes:

* typed bidirectional completeness;
* recomposition from a typed intersection;
* internally coherent terminal cycles;
* both round-trip coherences;
* the link between a strong terminal cycle and the interface it forms;
* interface-witness dependency and closure/interface round-trips;
* projective non-reducibility as a proved obstruction to reconstruction;
* optional common stability, diagonal obstruction, recovery, and terminal
  projection packages.

The package is abstract by design.  `Forward` and `Backward` are related
through an already typed `Intersection`, which is then recomposed by
`completeOfIntersection`.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s

/-! ## Bidirectional completeness -/

/-- Bidirectional completeness as a constructive information interface. -/
structure BidirectionalCompleteness
    (Branch : Type u) : Type (max (u + 1) (v + 1) (w + 1)) where
  Complete : Branch -> Type v
  Forward : Branch -> Type w
  Backward : Branch -> Type w
  Intersection : Branch -> Type w
  forwardOfComplete :
    (branch : Branch) ->
      Complete branch ->
        Forward branch
  backwardOfComplete :
    (branch : Branch) ->
      Complete branch ->
        Backward branch
  intersectionOfComplete :
    (branch : Branch) ->
      Complete branch ->
        Intersection branch
  completeOfIntersection :
    (branch : Branch) ->
      Intersection branch ->
        Complete branch

/-- Projection from `Complete` to the forward reading. -/
def forwardOfComplete
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (closed : complete.Complete branch) :
    complete.Forward branch :=
  complete.forwardOfComplete branch closed

/-- Projection from `Complete` to the backward reading. -/
def backwardOfComplete
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (closed : complete.Complete branch) :
    complete.Backward branch :=
  complete.backwardOfComplete branch closed

/-- Projection from `Complete` to its typed intersection. -/
def intersectionOfComplete
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (closed : complete.Complete branch) :
    complete.Intersection branch :=
  complete.intersectionOfComplete branch closed

/-- Recomposition of `Complete` from a typed intersection. -/
def completeOfIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (intersection : complete.Intersection branch) :
    complete.Complete branch :=
  complete.completeOfIntersection branch intersection

/-! ## Terminal cycles and internal coherence -/

/-- Raw terminal cycle data. -/
structure TerminalCycle
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch) : Type (max v w) where
  completeIn : complete.Complete branch
  forward : complete.Forward branch
  backward : complete.Backward branch
  intersection : complete.Intersection branch
  recomposed : complete.Complete branch

/-- Every complete datum enters a raw terminal cycle. -/
def terminalCycleOfComplete
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (closed : complete.Complete branch) :
    TerminalCycle complete branch where
  completeIn := closed
  forward := forwardOfComplete complete closed
  backward := backwardOfComplete complete closed
  intersection := intersectionOfComplete complete closed
  recomposed :=
    completeOfIntersection
      complete
      (intersectionOfComplete complete closed)

/-- A typed intersection recomposes and then enters a raw terminal cycle. -/
def terminalCycleOfIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (intersection : complete.Intersection branch) :
    TerminalCycle complete branch :=
  terminalCycleOfComplete
    complete
    (completeOfIntersection complete intersection)

/--
Coherent terminal cycle.

Unlike `TerminalCycle`, this package states that each stored field is exactly
the field obtained by reading and recomposing the carried `completeIn` datum.
-/
structure CoherentTerminalCycle
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch) : Type (max v w) where
  cycle : TerminalCycle complete branch
  forward_coherent :
    cycle.forward =
      forwardOfComplete complete cycle.completeIn
  backward_coherent :
    cycle.backward =
      backwardOfComplete complete cycle.completeIn
  intersection_coherent :
    cycle.intersection =
      intersectionOfComplete complete cycle.completeIn
  recomposed_coherent :
    cycle.recomposed =
      completeOfIntersection complete cycle.intersection

/-- The canonical terminal cycle of a complete datum is coherent. -/
def coherentTerminalCycleOfComplete
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (closed : complete.Complete branch) :
    CoherentTerminalCycle complete branch where
  cycle := terminalCycleOfComplete complete closed
  forward_coherent := rfl
  backward_coherent := rfl
  intersection_coherent := rfl
  recomposed_coherent := rfl

/-- The canonical terminal cycle generated by an intersection is coherent. -/
def coherentTerminalCycleOfIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (intersection : complete.Intersection branch) :
    CoherentTerminalCycle complete branch :=
  coherentTerminalCycleOfComplete
    complete
    (completeOfIntersection complete intersection)

/-! ## Round-trip coherence -/

/-- Complete -> Intersection -> Complete returns the same complete datum. -/
structure ReextractionCoherence
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch) :
    Type (max u v w) where
  complete_stable :
    (branch : Branch) ->
      (closed : complete.Complete branch) ->
        completeOfIntersection
          complete
          (intersectionOfComplete complete closed) =
            closed

/-- Intersection -> Complete -> Intersection returns the same intersection. -/
structure IntersectionRecompositionCoherence
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch) :
    Type (max u v w) where
  intersection_stable :
    (branch : Branch) ->
      (intersection : complete.Intersection branch) ->
        intersectionOfComplete
          complete
          (completeOfIntersection complete intersection) =
            intersection

/-- Both round-trip coherences together. -/
structure RoundTripCoherence
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch) :
    Type (max u v w) where
  completeRoundTrip : ReextractionCoherence complete
  intersectionRoundTrip : IntersectionRecompositionCoherence complete

/-- A coherent terminal cycle with strong complete reextraction. -/
structure StrongTerminalCycle
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch) : Type (max u v w) where
  coherentCycle : CoherentTerminalCycle complete branch
  reextracted :
    completeOfIntersection
      complete
      (intersectionOfComplete complete coherentCycle.cycle.recomposed) =
        coherentCycle.cycle.recomposed

/--
Strong terminal cycle generated from an initial intersection, preserving that
initial intersection after recomposition.
-/
structure StrongTerminalCycleFromIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch) : Type (max u v w) where
  sourceIntersection : complete.Intersection branch
  strongCycle : StrongTerminalCycle complete branch
  completeIn_from_source :
    strongCycle.coherentCycle.cycle.completeIn =
      completeOfIntersection complete sourceIntersection
  intersection_from_source :
    strongCycle.coherentCycle.cycle.intersection =
      intersectionOfComplete
        complete
        (completeOfIntersection complete sourceIntersection)
  sourceIntersection_preserved :
    intersectionOfComplete
      complete
      (completeOfIntersection complete sourceIntersection) =
        sourceIntersection

/-- An intersection gives a strong terminal cycle with complete reextraction. -/
def strongTerminalCycleOfIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : ReextractionCoherence complete)
    {branch : Branch}
    (intersection : complete.Intersection branch) :
    StrongTerminalCycle complete branch where
  coherentCycle :=
    coherentTerminalCycleOfIntersection complete intersection
  reextracted :=
    coherence.complete_stable
      branch
      (coherentTerminalCycleOfIntersection complete intersection).cycle.recomposed

/-- With both round trips, the initial intersection is preserved too. -/
def strongTerminalCycleFromIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    {branch : Branch}
    (intersection : complete.Intersection branch) :
    StrongTerminalCycleFromIntersection complete branch where
  sourceIntersection := intersection
  strongCycle :=
    strongTerminalCycleOfIntersection
      complete
      coherence.completeRoundTrip
      intersection
  completeIn_from_source := rfl
  intersection_from_source := rfl
  sourceIntersection_preserved :=
    coherence.intersectionRoundTrip.intersection_stable branch intersection

/-! ## Interface-witness dependency -/

/-- Generic interface-witness package. -/
structure InterfaceWitness
    (Interface : Type x)
    (WitnessOf : Interface -> Type y) :
    Type (max x y) where
  interface : Interface
  witness : WitnessOf interface

/-- Projection to the carried interface. -/
def interfaceOf
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    (formed : InterfaceWitness Interface WitnessOf) :
    Interface :=
  formed.interface

/-- Projection to the witness indexed by the carried interface. -/
def witnessOf
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    (formed : InterfaceWitness Interface WitnessOf) :
    WitnessOf formed.interface :=
  formed.witness

/-- A formed interface carries an outcome indexed by that interface. -/
structure FormedReferentialClosure
    (Interface : Type x)
    (OutcomeOf : Interface -> Type y) :
    Type (max x y) where
  formedInterface : Interface
  outcome : OutcomeOf formedInterface

/-- The interface-witness presentation of a formed referential closure. -/
abbrev FormedInterfaceWitness
    (Interface : Type x)
    (OutcomeOf : Interface -> Type y) :
    Type (max x y) :=
  InterfaceWitness Interface OutcomeOf

/-- A formed referential closure is an interface carrying its witness. -/
def formedInterfaceWitnessOfClosure
    {Interface : Type x}
    {OutcomeOf : Interface -> Type y}
    (closure : FormedReferentialClosure Interface OutcomeOf) :
    FormedInterfaceWitness Interface OutcomeOf where
  interface := closure.formedInterface
  witness := closure.outcome

/-- An interface-witness package reconstructs the formed closure. -/
def closureOfFormedInterfaceWitness
    {Interface : Type x}
    {OutcomeOf : Interface -> Type y}
    (formed : FormedInterfaceWitness Interface OutcomeOf) :
    FormedReferentialClosure Interface OutcomeOf where
  formedInterface := formed.interface
  outcome := formed.witness

/-- Round-trip from closure to interface-witness and back. -/
theorem closure_roundtrip
    {Interface : Type x}
    {OutcomeOf : Interface -> Type y}
    (closure : FormedReferentialClosure Interface OutcomeOf) :
    closureOfFormedInterfaceWitness
      (formedInterfaceWitnessOfClosure closure) =
        closure := by
  cases closure
  rfl

/-- Round-trip from interface-witness to closure and back. -/
theorem formedInterfaceWitness_roundtrip
    {Interface : Type x}
    {OutcomeOf : Interface -> Type y}
    (formed : FormedInterfaceWitness Interface OutcomeOf) :
    formedInterfaceWitnessOfClosure
      (closureOfFormedInterfaceWitness formed) =
        formed := by
  cases formed
  rfl

/-! ## Cycle/interface realization -/

/--
Linked weak closed stability.

The relation `RealizesInterface` states that the terminal cycle forms the
interface carried by `formed`.
-/
structure WeakClosedStability
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      TerminalCycle complete branch -> Interface -> Type z) :
    Type (max u v w x y z) where
  cycle : TerminalCycle complete branch
  formed : InterfaceWitness Interface WitnessOf
  interface_coherent :
    RealizesInterface cycle formed.interface

/--
Linked strong closed stability.

The interface witness is not an arbitrary side package: `interface_coherent`
links it to the strong terminal cycle that forms it.
-/
structure StrongClosedStability
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycle complete branch -> Interface -> Type z) :
    Type (max u v w x y z) where
  strongCycle : StrongTerminalCycle complete branch
  formed : InterfaceWitness Interface WitnessOf
  interface_coherent :
    RealizesInterface strongCycle formed.interface

/--
Strong closed stability generated from an initial intersection.

This package carries the stronger terminal datum, including preservation of the
source intersection, and links the formed interface to that whole datum.
-/
structure StrongClosedStabilityFromIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z) :
    Type (max u v w x y z) where
  strongFromIntersection : StrongTerminalCycleFromIntersection complete branch
  formed : InterfaceWitness Interface WitnessOf
  interface_coherent :
    RealizesInterface strongFromIntersection formed.interface

/-- Strong stability forgets to weak stability through compatible realizers. -/
def weakOfStrongClosedStability
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {branch : Branch}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {StrongRealizes :
      StrongTerminalCycle complete branch -> Interface -> Type z}
    {WeakRealizes :
      TerminalCycle complete branch -> Interface -> Type r}
    (realizerForget :
      (strongCycle : StrongTerminalCycle complete branch) ->
        (interface : Interface) ->
          StrongRealizes strongCycle interface ->
            WeakRealizes strongCycle.coherentCycle.cycle interface)
    (stability :
      StrongClosedStability
        complete
        branch
        Interface
        WitnessOf
        StrongRealizes) :
    WeakClosedStability
      complete
      branch
      Interface
      WitnessOf
      WeakRealizes where
  cycle := stability.strongCycle.coherentCycle.cycle
  formed := stability.formed
  interface_coherent :=
    realizerForget
      stability.strongCycle
      stability.formed.interface
      stability.interface_coherent

/-! ## Common stability -/

/-- A self-coupling whose coupled datum conserves memory and source. -/
structure SelfCoupling
    (Branch : Type u)
    (Support : Type x) : Type (max u x (w + 1)) where
  memory : Branch -> Support
  source : Branch -> Support
  Coupled : Branch -> Type w
  coupled_conserves :
    (branch : Branch) ->
      Coupled branch ->
        memory branch = source branch

/-- A strong terminal cycle gives common stability when `Complete` enters the coupling. -/
def commonStabilityOfStrongTerminalCycle
    {Branch : Type u}
    {Support : Type x}
    (coupling : SelfCoupling Branch Support)
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    (completeToCoupled :
      (branch : Branch) ->
        complete.Complete branch ->
          coupling.Coupled branch)
    {branch : Branch}
    (cycle : StrongTerminalCycle complete branch) :
    coupling.memory branch = coupling.source branch :=
  coupling.coupled_conserves
    branch
    (completeToCoupled
      branch
      cycle.coherentCycle.cycle.recomposed)

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

/-! ## Non-projective strong stability -/

/--
Non-projective strong closed stability.

The visible projection does not reconstruct the formed interface, because an
explicit obstruction is carried and can be consumed by
`noProjectiveReconstruction`.
-/
structure NonProjectiveStrongClosedStability
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycle complete branch -> Interface -> Type z)
    (Visible : Type r)
    (project : Interface -> Visible) :
    Type (max u v w x y z r) where
  stability :
    StrongClosedStability
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface
  obstruction :
    ProjectionObstruction Interface Visible project

/-- A non-projective stability package rules out projective reconstruction. -/
def noProjectiveReconstructionOfStability
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {branch : Branch}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycle complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    (stability :
      NonProjectiveStrongClosedStability
        complete
        branch
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project) :
    ((recover : Visible -> Interface) ->
      ((interface : Interface) ->
        recover (project interface) = interface) ->
          False) :=
  noProjectiveReconstruction stability.obstruction

/--
Recovered non-projective closed stability.

This terminal package connects the non-projective stability to a recovery bundle
and a terminal projection carried by the same formed interface.
-/
structure RecoveredNonProjectiveClosedStability
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycle complete branch -> Interface -> Type z)
    (Visible : Type r)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max u v w x y z r s) where
  stability :
    NonProjectiveStrongClosedStability
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface
      Visible
      project
  recovery : RecoveryBundle Interface RepairOf
  recovery_sameInterface :
    recovery.interface = stability.stability.formed.interface
  projection : TerminalProjection Interface Visible project
  projection_sameInterface :
    projection.interface = stability.stability.formed.interface

/-- Non-projective closed stability preserving the source intersection. -/
structure NonProjectiveStrongClosedStabilityFromIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z)
    (Visible : Type r)
    (project : Interface -> Visible) :
    Type (max u v w x y z r) where
  stability :
    StrongClosedStabilityFromIntersection
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface
  obstruction :
    ProjectionObstruction Interface Visible project

/-- Recovered terminal package preserving the source intersection. -/
structure RecoveredNonProjectiveClosedStabilityFromIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z)
    (Visible : Type r)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max u v w x y z r s) where
  stability :
    NonProjectiveStrongClosedStabilityFromIntersection
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface
      Visible
      project
  recovery : RecoveryBundle Interface RepairOf
  recovery_sameInterface :
    recovery.interface = stability.stability.formed.interface
  projection : TerminalProjection Interface Visible project
  projection_sameInterface :
    projection.interface = stability.stability.formed.interface

/--
Locally recovered terminal package preserving the source intersection.

This strengthens `RecoveredNonProjectiveClosedStabilityFromIntersection` by
carrying the local projective recovery whose formed interface is the same
interface carried by the closed-stability package.
-/
structure LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (branch : Branch)
    (Interface : Type x)
    (WitnessOf : Interface -> Type y)
    (RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z)
    (Visible : Type r)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s) :
    Type (max u v w x y z r s) where
  recovered :
    RecoveredNonProjectiveClosedStabilityFromIntersection
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface
      Visible
      project
      RepairOf
  localRecovery :
    LocalProjectiveRecovery Interface Visible project RepairOf
  localRecovery_sameInterface :
    localRecovery.formed =
      recovered.stability.stability.formed.interface

/-- A source-preserving non-projective stability package rules out projective reconstruction. -/
def noProjectiveReconstructionOfStabilityFromIntersection
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {branch : Branch}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    (stability :
      NonProjectiveStrongClosedStabilityFromIntersection
        complete
        branch
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project) :
    ((recover : Visible -> Interface) ->
      ((interface : Interface) ->
        recover (project interface) = interface) ->
          False) :=
  noProjectiveReconstruction stability.obstruction

/-! ## Theorems -/

/-- Weak closed-stability package with an explicit cycle/interface link. -/
def weakClosedStabilityTheorem
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    {branch : Branch}
    (intersection : complete.Intersection branch)
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      TerminalCycle complete branch -> Interface -> Type z}
    (formed : InterfaceWitness Interface WitnessOf)
    (interface_coherent :
      RealizesInterface
        (terminalCycleOfIntersection complete intersection)
        formed.interface) :
    WeakClosedStability
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface where
  cycle := terminalCycleOfIntersection complete intersection
  formed := formed
  interface_coherent := interface_coherent

/-- Strong closed-stability package with complete reextraction and an interface link. -/
def strongClosedStabilityTheorem
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    {branch : Branch}
    (intersection : complete.Intersection branch)
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycle complete branch -> Interface -> Type z}
    (formed : InterfaceWitness Interface WitnessOf)
    (interface_coherent :
      RealizesInterface
        (strongTerminalCycleOfIntersection
          complete
          coherence.completeRoundTrip
          intersection)
        formed.interface) :
    StrongClosedStability
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface where
  strongCycle :=
    strongTerminalCycleOfIntersection
      complete
      coherence.completeRoundTrip
      intersection
  formed := formed
  interface_coherent := interface_coherent

/-- Strong stability retaining the initial intersection after recomposition. -/
def strongClosedStabilityFromIntersectionTheorem
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    {branch : Branch}
    (intersection : complete.Intersection branch) :
    StrongTerminalCycleFromIntersection complete branch :=
  strongTerminalCycleFromIntersection complete coherence intersection

/-- Strong closed stability carrying both round-trips and the formed interface link. -/
def strongClosedStabilityFromIntersectionLinkedTheorem
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    {branch : Branch}
    (intersection : complete.Intersection branch)
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    (formed : InterfaceWitness Interface WitnessOf)
    (interface_coherent :
      RealizesInterface
        (strongTerminalCycleFromIntersection complete coherence intersection)
        formed.interface) :
    StrongClosedStabilityFromIntersection
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface where
  strongFromIntersection :=
    strongTerminalCycleFromIntersection complete coherence intersection
  formed := formed
  interface_coherent := interface_coherent

/-- Non-projective strong closed-stability package. -/
def nonProjectiveStrongClosedStabilityTheorem
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    {branch : Branch}
    (intersection : complete.Intersection branch)
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycle complete branch -> Interface -> Type z}
    (formed : InterfaceWitness Interface WitnessOf)
    (interface_coherent :
      RealizesInterface
        (strongTerminalCycleOfIntersection
          complete
          coherence.completeRoundTrip
          intersection)
        formed.interface)
    {Visible : Type r}
    {project : Interface -> Visible}
    (obstruction : ProjectionObstruction Interface Visible project) :
    NonProjectiveStrongClosedStability
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface
      Visible
      project where
  stability :=
    strongClosedStabilityTheorem
      complete
      coherence
      intersection
      formed
      interface_coherent
  obstruction := obstruction

/-- Terminal theorem linking non-projective stability, recovery, and projection. -/
def recoveredNonProjectiveClosedStabilityTheorem
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {branch : Branch}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycle complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (stability :
      NonProjectiveStrongClosedStability
        complete
        branch
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project)
    (recovery : RecoveryBundle Interface RepairOf)
    (recovery_sameInterface :
      recovery.interface = stability.stability.formed.interface)
    (projection : TerminalProjection Interface Visible project)
    (projection_sameInterface :
      projection.interface = stability.stability.formed.interface) :
    RecoveredNonProjectiveClosedStability
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface
      Visible
      project
      RepairOf where
  stability := stability
  recovery := recovery
  recovery_sameInterface := recovery_sameInterface
  projection := projection
  projection_sameInterface := projection_sameInterface

/-- Non-projective theorem preserving the source intersection through the terminal chain. -/
def nonProjectiveStrongClosedStabilityFromIntersectionTheorem
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    {branch : Branch}
    (intersection : complete.Intersection branch)
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    (formed : InterfaceWitness Interface WitnessOf)
    (interface_coherent :
      RealizesInterface
        (strongTerminalCycleFromIntersection complete coherence intersection)
        formed.interface)
    {Visible : Type r}
    {project : Interface -> Visible}
    (obstruction : ProjectionObstruction Interface Visible project) :
    NonProjectiveStrongClosedStabilityFromIntersection
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface
      Visible
      project where
  stability :=
    strongClosedStabilityFromIntersectionLinkedTheorem
      complete
      coherence
      intersection
      formed
      interface_coherent
  obstruction := obstruction

/-- Terminal recovery/projection theorem preserving the source intersection. -/
def recoveredNonProjectiveClosedStabilityFromIntersectionTheorem
    {Branch : Type u}
    {complete : BidirectionalCompleteness.{u, v, w} Branch}
    {branch : Branch}
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (stability :
      NonProjectiveStrongClosedStabilityFromIntersection
        complete
        branch
        Interface
        WitnessOf
        RealizesInterface
        Visible
        project)
    (recovery : RecoveryBundle Interface RepairOf)
    (recovery_sameInterface :
      recovery.interface = stability.stability.formed.interface)
    (projection : TerminalProjection Interface Visible project)
    (projection_sameInterface :
      projection.interface = stability.stability.formed.interface) :
    RecoveredNonProjectiveClosedStabilityFromIntersection
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface
      Visible
      project
      RepairOf where
  stability := stability
  recovery := recovery
  recovery_sameInterface := recovery_sameInterface
  projection := projection
  projection_sameInterface := projection_sameInterface

/--
Terminal local recovery theorem preserving the source intersection.

The local projective recovery supplies the obstruction, the recovery bundle and
the terminal projection for the same formed interface.
-/
def locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem
    {Branch : Type u}
    (complete : BidirectionalCompleteness.{u, v, w} Branch)
    (coherence : RoundTripCoherence complete)
    {branch : Branch}
    (intersection : complete.Intersection branch)
    {Interface : Type x}
    {WitnessOf : Interface -> Type y}
    {RealizesInterface :
      StrongTerminalCycleFromIntersection complete branch -> Interface -> Type z}
    (formed : InterfaceWitness Interface WitnessOf)
    (interface_coherent :
      RealizesInterface
        (strongTerminalCycleFromIntersection complete coherence intersection)
        formed.interface)
    {Visible : Type r}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    (localRecovery :
      LocalProjectiveRecovery Interface Visible project RepairOf)
    (localRecovery_sameInterface :
      localRecovery.formed = formed.interface) :
    LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
      complete
      branch
      Interface
      WitnessOf
      RealizesInterface
      Visible
      project
      RepairOf where
  recovered :=
    recoveredNonProjectiveClosedStabilityFromIntersectionTheorem
      (nonProjectiveStrongClosedStabilityFromIntersectionTheorem
        complete
        coherence
        intersection
        formed
        interface_coherent
        (localProjectiveRecovery_obstruction localRecovery))
      (recoveryBundleOfLocalProjectiveRecovery localRecovery)
      localRecovery_sameInterface
      (terminalProjectionOfLocalProjectiveRecovery localRecovery)
      localRecovery_sameInterface
  localRecovery := localRecovery
  localRecovery_sameInterface := localRecovery_sameInterface

end ClosedStabilityTheorem
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.BidirectionalCompleteness
#print axioms Meta.ClosedStabilityTheorem.completeOfIntersection
#print axioms Meta.ClosedStabilityTheorem.TerminalCycle
#print axioms Meta.ClosedStabilityTheorem.CoherentTerminalCycle
#print axioms Meta.ClosedStabilityTheorem.coherentTerminalCycleOfIntersection
#print axioms Meta.ClosedStabilityTheorem.ReextractionCoherence
#print axioms Meta.ClosedStabilityTheorem.IntersectionRecompositionCoherence
#print axioms Meta.ClosedStabilityTheorem.RoundTripCoherence
#print axioms Meta.ClosedStabilityTheorem.StrongTerminalCycle
#print axioms Meta.ClosedStabilityTheorem.StrongTerminalCycleFromIntersection
#print axioms Meta.ClosedStabilityTheorem.StrongTerminalCycleFromIntersection.completeIn_from_source
#print axioms Meta.ClosedStabilityTheorem.StrongTerminalCycleFromIntersection.intersection_from_source
#print axioms Meta.ClosedStabilityTheorem.strongTerminalCycleFromIntersection
#print axioms Meta.ClosedStabilityTheorem.InterfaceWitness
#print axioms Meta.ClosedStabilityTheorem.FormedReferentialClosure
#print axioms Meta.ClosedStabilityTheorem.FormedInterfaceWitness
#print axioms Meta.ClosedStabilityTheorem.formedInterfaceWitnessOfClosure
#print axioms Meta.ClosedStabilityTheorem.closureOfFormedInterfaceWitness
#print axioms Meta.ClosedStabilityTheorem.closure_roundtrip
#print axioms Meta.ClosedStabilityTheorem.formedInterfaceWitness_roundtrip
#print axioms Meta.ClosedStabilityTheorem.WeakClosedStability
#print axioms Meta.ClosedStabilityTheorem.StrongClosedStability
#print axioms Meta.ClosedStabilityTheorem.StrongClosedStabilityFromIntersection
#print axioms Meta.ClosedStabilityTheorem.SelfCoupling
#print axioms Meta.ClosedStabilityTheorem.commonStabilityOfStrongTerminalCycle
#print axioms Meta.ClosedStabilityTheorem.ProjectionObstruction
#print axioms Meta.ClosedStabilityTheorem.ProjectionFiberFaithful
#print axioms Meta.ClosedStabilityTheorem.ProjectionInformationConserving
#print axioms Meta.ClosedStabilityTheorem.projectionFiberFaithful_of_informationConserving
#print axioms Meta.ClosedStabilityTheorem.projectionObstruction_notFiberFaithful
#print axioms Meta.ClosedStabilityTheorem.projectionObstruction_notInformationConserving
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstruction
#print axioms Meta.ClosedStabilityTheorem.DiagonalCertificate
#print axioms Meta.ClosedStabilityTheorem.projectionObstructionOfDiagonalCertificate
#print axioms Meta.ClosedStabilityTheorem.LocalProjectiveRecovery
#print axioms Meta.ClosedStabilityTheorem.localProjectiveRecovery_obstruction
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstructionOfLocalProjectiveRecovery
#print axioms Meta.ClosedStabilityTheorem.localProjectiveRecovery_notFiberFaithful
#print axioms Meta.ClosedStabilityTheorem.localProjectiveRecovery_notInformationConserving
#print axioms Meta.ClosedStabilityTheorem.ReferentialScene
#print axioms Meta.ClosedStabilityTheorem.GeometricFormation
#print axioms Meta.ClosedStabilityTheorem.ProjectedLocalTruth
#print axioms Meta.ClosedStabilityTheorem.LocalTruthGapRecovery
#print axioms Meta.ClosedStabilityTheorem.localTruthGapRecovery_fullScene_geometricFormation
#print axioms Meta.ClosedStabilityTheorem.localTruthGapRecovery_fullScene_not_projectedDynamicTruth
#print axioms Meta.ClosedStabilityTheorem.localTruthGapRecovery_shadowScene_projectedDynamicTruth
#print axioms Meta.ClosedStabilityTheorem.localTruthGapRecovery_shadowScene_not_geometricFormation
#print axioms Meta.ClosedStabilityTheorem.localTruthGapRecovery_localFormation_projectedTruth_independent
#print axioms Meta.ClosedStabilityTheorem.RecoveryBundle
#print axioms Meta.ClosedStabilityTheorem.recoveryBundleOfLocalProjectiveRecovery
#print axioms Meta.ClosedStabilityTheorem.TerminalProjection
#print axioms Meta.ClosedStabilityTheorem.terminalProjectionOfLocalProjectiveRecovery
#print axioms Meta.ClosedStabilityTheorem.NonProjectiveStrongClosedStability
#print axioms Meta.ClosedStabilityTheorem.RecoveredNonProjectiveClosedStability
#print axioms Meta.ClosedStabilityTheorem.NonProjectiveStrongClosedStabilityFromIntersection
#print axioms Meta.ClosedStabilityTheorem.RecoveredNonProjectiveClosedStabilityFromIntersection
#print axioms Meta.ClosedStabilityTheorem.LocallyRecoveredNonProjectiveClosedStabilityFromIntersection
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstructionOfStability
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstructionOfStabilityFromIntersection
#print axioms Meta.ClosedStabilityTheorem.weakClosedStabilityTheorem
#print axioms Meta.ClosedStabilityTheorem.strongClosedStabilityTheorem
#print axioms Meta.ClosedStabilityTheorem.strongClosedStabilityFromIntersectionTheorem
#print axioms Meta.ClosedStabilityTheorem.strongClosedStabilityFromIntersectionLinkedTheorem
#print axioms Meta.ClosedStabilityTheorem.nonProjectiveStrongClosedStabilityTheorem
#print axioms Meta.ClosedStabilityTheorem.recoveredNonProjectiveClosedStabilityTheorem
#print axioms Meta.ClosedStabilityTheorem.nonProjectiveStrongClosedStabilityFromIntersectionTheorem
#print axioms Meta.ClosedStabilityTheorem.recoveredNonProjectiveClosedStabilityFromIntersectionTheorem
#print axioms Meta.ClosedStabilityTheorem.locallyRecoveredNonProjectiveClosedStabilityFromIntersectionTheorem
/- AXIOM_AUDIT_END -/
