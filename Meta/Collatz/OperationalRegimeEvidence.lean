import Meta.Collatz.OperationalParity

/-!
# Collatz operational regime evidence

This file records when a parity regime is available from an operational
intersection.  It does not classify a natural number by classical parity.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Regime evidence local to an intersection -/

/--
Evidence that a regime is one of the two regimes already produced by an
operational enriched-Nat intersection.
-/
inductive CollatzIntersectionRegimeEvidence
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ParityRegime -> Type where
  | closing :
      CollatzIntersectionRegimeEvidence intersection
        (operationalParityRoles_closingRegime
          (arithmeticOperationalParityRolesOfIntersection intersection))
  | mediating :
      CollatzIntersectionRegimeEvidence intersection
        (operationalParityRoles_mediatingRegime
          (arithmeticOperationalParityRolesOfIntersection intersection))

/-- A Collatz action carried by a regime certified at one intersection. -/
structure CollatzOperationalActionAtIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) where
  regime : ParityRegime
  regimeEvidence :
    CollatzIntersectionRegimeEvidence intersection regime
  value : Nat
  value_eq_action :
    value = collatzParityAction n regime

/-- The closing/forming operational action at an intersection. -/
def collatzClosingOperationalActionAtIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) :
    CollatzOperationalActionAtIntersection intersection n where
  regime :=
    operationalParityRoles_closingRegime
      (arithmeticOperationalParityRolesOfIntersection intersection)
  regimeEvidence := CollatzIntersectionRegimeEvidence.closing
  value :=
    collatzParityAction n
      (operationalParityRoles_closingRegime
        (arithmeticOperationalParityRolesOfIntersection intersection))
  value_eq_action := rfl

/-- The mediating/shadow operational action at an intersection. -/
def collatzMediatingOperationalActionAtIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) :
    CollatzOperationalActionAtIntersection intersection n where
  regime :=
    operationalParityRoles_mediatingRegime
      (arithmeticOperationalParityRolesOfIntersection intersection)
  regimeEvidence := CollatzIntersectionRegimeEvidence.mediating
  value :=
    collatzParityAction n
      (operationalParityRoles_mediatingRegime
        (arithmeticOperationalParityRolesOfIntersection intersection))
  value_eq_action := rfl

/-! ## Public action readings -/

/-- The closing operational action carries the division projection. -/
theorem collatzClosingOperationalAction_value_eq_div_two
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) :
    (collatzClosingOperationalActionAtIntersection intersection n).value =
      n / 2 :=
  collatzClosingActionOfIntersection_eq_div_two intersection n

/-- The mediating operational action carries the relaxed `3*n+1` projection. -/
theorem collatzMediatingOperationalAction_value_eq_three_mul_add_one
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) :
    (collatzMediatingOperationalActionAtIntersection intersection n).value =
      3 * n + 1 :=
  collatzMediatingActionOfIntersection_eq_three_mul_add_one intersection n

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzIntersectionRegimeEvidence
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzOperationalActionAtIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzClosingOperationalActionAtIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzMediatingOperationalActionAtIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzClosingOperationalAction_value_eq_div_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzMediatingOperationalAction_value_eq_three_mul_add_one
/- AXIOM_AUDIT_END -/
