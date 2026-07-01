import Meta.Collatz.OperationalRegimeEvidence
import Meta.Arithmetic.CountdownGapContraction

/-!
# Collatz operational temporal representation

This file exposes a visible operational projection whose regime is certified by
an enriched-Nat intersection.  It is not the fibrewise height concordance.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Operational support -/

/-- A packaged intersection support for a visible index. -/
def collatzOperationalTemporalSupport
    (n : Nat) :
    Sigma (fun branch : MemoryBranch =>
      PrimitiveMemoryReadingIntersection branch) :=
  ⟨_, countdownTerminalIntersection (n + n)⟩

/-- The closing regime read from the operational temporal support. -/
def collatzOperationalTemporalRegime
    (n : Nat) :
    ParityRegime :=
  operationalParityRoles_closingRegime
    (arithmeticOperationalParityRolesOfIntersection
      (collatzOperationalTemporalSupport n).2)

/-- The visible operational projection attached to the certified closing regime. -/
def collatzOperationalTemporalStep
    (n : Nat) :
    Nat :=
  collatzParityAction n (collatzOperationalTemporalRegime n)

/-- A visible step together with its operational regime producer. -/
structure CollatzOperationalTemporalRepresentation
    (step : Nat -> Nat) where
  supportOf :
    Nat ->
      Sigma (fun branch : MemoryBranch =>
        PrimitiveMemoryReadingIntersection branch)
  regimeOf : Nat -> ParityRegime
  regime_is_operational :
    forall n,
      CollatzIntersectionRegimeEvidence
        (supportOf n).2
        (regimeOf n)
  step_eq_action :
    forall n,
      step n = collatzParityAction n (regimeOf n)

/-- The canonical closing operational temporal projection. -/
def collatzOperationalTemporalRepresentation :
    CollatzOperationalTemporalRepresentation
      collatzOperationalTemporalStep where
  supportOf := collatzOperationalTemporalSupport
  regimeOf := collatzOperationalTemporalRegime
  regime_is_operational := by
    intro n
    exact CollatzIntersectionRegimeEvidence.closing
  step_eq_action := by
    intro n
    rfl

/-! ## Public readings -/

/-- The operational temporal step is read from `collatzParityAction`. -/
theorem collatzOperationalTemporalStep_eq_action
    (n : Nat) :
    collatzOperationalTemporalStep n =
      collatzParityAction n
        ((collatzOperationalTemporalRepresentation).regimeOf n) :=
  (collatzOperationalTemporalRepresentation).step_eq_action n

/-- The operational temporal regime is certified by an enriched intersection. -/
def collatzOperationalTemporalRegime_is_operational
    (n : Nat) :
    CollatzIntersectionRegimeEvidence
      ((collatzOperationalTemporalRepresentation).supportOf n).2
      ((collatzOperationalTemporalRepresentation).regimeOf n) :=
  (collatzOperationalTemporalRepresentation).regime_is_operational n

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalTemporalSupport
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalTemporalRegime
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalTemporalStep
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzOperationalTemporalRepresentation
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalTemporalRepresentation
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalTemporalStep_eq_action
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalTemporalRegime_is_operational
/- AXIOM_AUDIT_END -/
