import Meta.Core.BilateralCore
import Meta.Core.ProjectiveCore

/-!
# Closed-stability combination layer

This historical module combines the import-free bilateral core with projective
obstruction, local recovery, and the large closed-stability packages. Public
names remain in `Meta.ClosedStabilityTheorem`.
-/

namespace Meta
namespace ClosedStabilityTheorem

universe u v w x y z r s

/-! ## Formed referential closure -/

/--
A non-trivial formed referential closure.

It does not merely package an interface with an outcome.  It carries the formed
interface, its projected shadow, the projective gap between them, a local repair
indexed by the formed interface, the recovered formed interface, and the
outcome indexed by that same formed interface.
-/
structure FormedReferentialClosure
    (Interface : Type x)
    (Visible : Type y)
    (project : Interface -> Visible)
    (RepairOf : Interface -> Type s)
    (OutcomeOf : Interface -> Type z) :
    Type (max x y s z) where
  formedInterface : Interface
  shadowInterface : Interface
  sameProjection :
    project formedInterface = project shadowInterface
  separatedInterface :
    formedInterface = shadowInterface -> False
  repair : RepairOf formedInterface
  recoveredInterface : Interface
  recovered_eq_formed :
    recoveredInterface = formedInterface
  outcome : OutcomeOf formedInterface

/-- A formed referential closure exposes its outcome as an interface witness. -/
def outcomeWitnessOfFormedReferentialClosure
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {OutcomeOf : Interface -> Type z}
    (closure :
      FormedReferentialClosure Interface Visible project RepairOf OutcomeOf) :
    InterfaceWitness Interface OutcomeOf where
  interface := closure.formedInterface
  witness := closure.outcome

/-! ## Non-trivial formed referential closure consequences -/

/-- A formed referential closure carries its diagonal certificate. -/
def FormedReferentialClosure.diagonalCertificate
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {OutcomeOf : Interface -> Type z}
    (closure :
      FormedReferentialClosure Interface Visible project RepairOf OutcomeOf) :
    DiagonalCertificate Interface Visible project where
  left := closure.formedInterface
  right := closure.shadowInterface
  sameProjection := closure.sameProjection
  separatedInterface := closure.separatedInterface

/-- A formed referential closure carries its projection obstruction. -/
def FormedReferentialClosure.projectionObstruction
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {OutcomeOf : Interface -> Type z}
    (closure :
      FormedReferentialClosure Interface Visible project RepairOf OutcomeOf) :
    ProjectionObstruction Interface Visible project :=
  projectionObstructionOfDiagonalCertificate
    closure.diagonalCertificate

/-- A formed referential closure carries its local projective recovery. -/
def FormedReferentialClosure.localProjectiveRecovery
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {OutcomeOf : Interface -> Type z}
    (closure :
      FormedReferentialClosure Interface Visible project RepairOf OutcomeOf) :
    LocalProjectiveRecovery Interface Visible project RepairOf where
  formed := closure.formedInterface
  shadow := closure.shadowInterface
  sameProjection := closure.sameProjection
  separated := closure.separatedInterface
  repair := closure.repair
  recovered := closure.recoveredInterface
  recovered_eq_formed := closure.recovered_eq_formed

/-- A formed referential closure rules out a uniform visible reconstruction. -/
def noProjectiveReconstructionOfFormedReferentialClosure
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {OutcomeOf : Interface -> Type z}
    (closure :
      FormedReferentialClosure Interface Visible project RepairOf OutcomeOf) :
    ((recover : Visible -> Interface) ->
      ((interface : Interface) ->
        recover (project interface) = interface) ->
          False) :=
  noProjectiveReconstructionOfLocalProjectiveRecovery
    closure.localProjectiveRecovery

/-- A formed referential closure refutes projection fiber faithfulness. -/
theorem formedReferentialClosure_notFiberFaithful
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {OutcomeOf : Interface -> Type z}
    (closure :
      FormedReferentialClosure Interface Visible project RepairOf OutcomeOf)
    (faithful : ProjectionFiberFaithful Interface Visible project) :
    False :=
  projectionObstruction_notFiberFaithful
    closure.projectionObstruction
    faithful

/-- A formed referential closure refutes global projection information conservation. -/
theorem formedReferentialClosure_notInformationConserving
    {Interface : Type x}
    {Visible : Type y}
    {project : Interface -> Visible}
    {RepairOf : Interface -> Type s}
    {OutcomeOf : Interface -> Type z}
    (closure :
      FormedReferentialClosure Interface Visible project RepairOf OutcomeOf)
    (conserving :
      ProjectionInformationConserving Interface Visible project) :
    False :=
  projectionObstruction_notInformationConserving
    closure.projectionObstruction
    conserving

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
#print axioms Meta.ClosedStabilityTheorem.outcomeWitnessOfFormedReferentialClosure
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
#print axioms Meta.ClosedStabilityTheorem.FormedReferentialClosure.diagonalCertificate
#print axioms Meta.ClosedStabilityTheorem.FormedReferentialClosure.projectionObstruction
#print axioms Meta.ClosedStabilityTheorem.FormedReferentialClosure.localProjectiveRecovery
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstructionOfFormedReferentialClosure
#print axioms Meta.ClosedStabilityTheorem.formedReferentialClosure_notFiberFaithful
#print axioms Meta.ClosedStabilityTheorem.formedReferentialClosure_notInformationConserving
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
