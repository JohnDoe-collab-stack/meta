import Meta.Arithmetic.Window

/-!
# HeightDiagonal
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Finite-prefix height source for bounded windows -/

/-- A finite trajectory prefix with a realized maximum height. -/
structure NatTrajectoryFinitePrefixHeightCertificate
    (step : Nat -> Nat)
    (start : Nat) where
  horizon : Nat
  height : Nat
  peakTime : Nat
  peak_le_horizon : peakTime <= horizon
  peak_realizes_height : natTrajectory step start peakTime = height
  bounds_prefix :
    forall time : Nat,
      time <= horizon -> natTrajectory step start time <= height

/-- A post-peak window long enough to read `height + 2` values. -/
structure NatTrajectoryPostPeakWindow
    {step : Nat -> Nat}
    {start : Nat}
    (cert : NatTrajectoryFinitePrefixHeightCertificate step start) where
  post_window_within_prefix :
    cert.peakTime + (cert.height + 1) <= cert.horizon

/--
Positive diagonal witness supported by the realized finite-prefix height.

The support is exactly the height carried by the certificate.  The diagonal
interface is the canonical enriched-Nat interface at that support, and the
positive witness is the formed positive excess of that same interface.
-/
structure NatTrajectoryPositiveDiagonalHeightWitness
    {step : Nat -> Nat}
    {start : Nat}
    (cert : NatTrajectoryFinitePrefixHeightCertificate step start) where
  support : Nat
  support_eq_height : support = cert.height
  peakTime : Nat
  peakTime_eq : peakTime = cert.peakTime
  peak_realizes_support :
    natTrajectory step start peakTime = support
  diagonalBranch : MemoryBranch
  diagonalBranch_eq :
    diagonalBranch = canonicalBranch support
  diagonalIntersection :
    bidirectionalCompleteness.Intersection diagonalBranch
  diagonalIntersection_eq :
    diagonalIntersection =
      Eq.ndrec
        (canonicalIntersection support)
        diagonalBranch_eq.symm
  positiveWitness : Nat
  positiveWitness_eq :
    positiveWitness =
      formedPositiveExcessOfIntersection diagonalIntersection
  positiveWitness_pos :
    0 < positiveWitness

/-- Canonical positive diagonal witness of a realized finite-prefix height. -/
def natTrajectoryPositiveDiagonalHeightWitness
    {step : Nat -> Nat}
    {start : Nat}
    (cert : NatTrajectoryFinitePrefixHeightCertificate step start) :
    NatTrajectoryPositiveDiagonalHeightWitness cert where
  support := cert.height
  support_eq_height := rfl
  peakTime := cert.peakTime
  peakTime_eq := rfl
  peak_realizes_support := cert.peak_realizes_height
  diagonalBranch := canonicalBranch cert.height
  diagonalBranch_eq := rfl
  diagonalIntersection := canonicalIntersection cert.height
  diagonalIntersection_eq := rfl
  positiveWitness :=
    formedPositiveExcessOfIntersection (canonicalIntersection cert.height)
  positiveWitness_eq := rfl
  positiveWitness_pos :=
    formedPositiveExcessOfIntersection_pos (canonicalIntersection cert.height)

/--
Finite-prefix height certificate bundled with the positive diagonal witness
carried by that same height.
-/
structure NatTrajectoryFinitePrefixHeightWithPositiveDiagonalWitness
    (step : Nat -> Nat)
    (start : Nat) where
  cert : NatTrajectoryFinitePrefixHeightCertificate step start
  positiveDiagonal :
    NatTrajectoryPositiveDiagonalHeightWitness cert

/--
Canonical bundling of a finite-prefix height certificate with its positive
diagonal witness.
-/
def natTrajectoryFinitePrefixHeightWithPositiveDiagonalWitness
    {step : Nat -> Nat}
    {start : Nat}
    (cert : NatTrajectoryFinitePrefixHeightCertificate step start) :
    NatTrajectoryFinitePrefixHeightWithPositiveDiagonalWitness step start where
  cert := cert
  positiveDiagonal := natTrajectoryPositiveDiagonalHeightWitness cert

/-- A post-peak finite-prefix window produces the bounded window used by pigeonhole. -/
def boundedWindow_of_postPeakWindow
    {step : Nat -> Nat}
    {start : Nat}
    {cert : NatTrajectoryFinitePrefixHeightCertificate step start}
    (window : NatTrajectoryPostPeakWindow cert) :
    NatTrajectoryBoundedWindow step start cert.peakTime cert.height where
  value_le_bound := by
    intro offset hOffset
    have hTimeLe : cert.peakTime + offset <= cert.horizon := by
      have hToWindow :
          cert.peakTime + offset <= cert.peakTime + (cert.height + 1) :=
        Nat.add_le_add_left hOffset cert.peakTime
      exact Nat.le_trans hToWindow window.post_window_within_prefix
    exact cert.bounds_prefix (cert.peakTime + offset) hTimeLe

/--
Post-peak closed-stability package carrying the realized height, its positive
diagonal witness, the post-peak window, and the closure generated from that
same window.
-/
structure NatTrajectoryPostPeakClosedStabilityHeightPackage
    {step : Nat -> Nat}
    {start : Nat}
    (heightWithWitness :
      NatTrajectoryFinitePrefixHeightWithPositiveDiagonalWitness
        step
        start) where
  window :
    NatTrajectoryPostPeakWindow heightWithWitness.cert
  closedStability :
    RecoveredNonProjectiveClosedStabilityFromIntersection
      bidirectionalCompleteness
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (windowCollision_of_boundedWindow
              (boundedWindow_of_postPeakWindow window)))))
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads
      NatInterfaceRepair

/--
Canonical post-peak package from a window.  The positive diagonal witness is
formed from the same finite-prefix height certificate that carries the window.
-/
def natTrajectoryPostPeakClosedStabilityHeightPackage
    {step : Nat -> Nat}
    {start : Nat}
    {cert : NatTrajectoryFinitePrefixHeightCertificate step start}
    (window : NatTrajectoryPostPeakWindow cert) :
    NatTrajectoryPostPeakClosedStabilityHeightPackage
      (natTrajectoryFinitePrefixHeightWithPositiveDiagonalWitness cert) where
  window := window
  closedStability :=
    boundedWindowClosedStabilityInstance
      (boundedWindow_of_postPeakWindow window)

/-- A post-peak finite-prefix window produces closed stability. -/
def postPeakWindowClosedStabilityInstance
    {step : Nat -> Nat}
    {start : Nat}
    {cert : NatTrajectoryFinitePrefixHeightCertificate step start}
    (window : NatTrajectoryPostPeakWindow cert) :
    RecoveredNonProjectiveClosedStabilityFromIntersection
      bidirectionalCompleteness
      (repeatedIndexBranch
        (repeatedIndexCollision_of_trajectoryCollision
          (trajectoryCollision_of_windowCollision
            (windowCollision_of_boundedWindow
              (boundedWindow_of_postPeakWindow window)))))
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads
      NatInterfaceRepair :=
  (natTrajectoryPostPeakClosedStabilityHeightPackage window).closedStability

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatTrajectoryPositiveDiagonalHeightWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.natTrajectoryPositiveDiagonalHeightWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatTrajectoryFinitePrefixHeightWithPositiveDiagonalWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatTrajectoryPostPeakClosedStabilityHeightPackage
#print axioms Meta.EnrichedNatClosedStabilityInstance.natTrajectoryPostPeakClosedStabilityHeightPackage
#print axioms Meta.EnrichedNatClosedStabilityInstance.postPeakWindowClosedStabilityInstance
/- AXIOM_AUDIT_END -/
