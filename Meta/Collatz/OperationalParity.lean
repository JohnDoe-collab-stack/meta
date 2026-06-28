import Meta.Arithmetic.Parity

/-!
# Collatz operational parity

This file records the Collatz action on the operational parity regimes already
constructed inside enriched Nat.

The file does not rebuild enriched Nat.  It uses the existing arithmetic
dynamic parity separation and attaches the two Collatz transformations to the
two operational parity regimes:

* the closing/forming regime carries `n / 2`;
* the mediating/shadow regime carries `3 * n + 1`.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Action on pure parity regimes -/

/-- Collatz action read on the two operational parity regimes. -/
def collatzParityAction
    (n : Nat) :
    ParityRegime -> Nat
  | ParityRegime.left => n / 2
  | ParityRegime.right => 3 * n + 1

/-- The left parity regime carries the division action. -/
theorem collatzParityAction_left
    (n : Nat) :
    collatzParityAction n ParityRegime.left = n / 2 :=
  rfl

/-- The right parity regime carries the `3*n+1` action. -/
theorem collatzParityAction_right
    (n : Nat) :
    collatzParityAction n ParityRegime.right = 3 * n + 1 :=
  rfl

/-! ## Action on enriched Nat operational parity -/

/-- Collatz action carried by the closing regime of one enriched Nat intersection. -/
def collatzClosingActionOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) :
    Nat :=
  collatzParityAction n
    (operationalParityRoles_closingRegime
      (arithmeticOperationalParityRolesOfIntersection intersection))

/-- Collatz action carried by the mediating regime of one enriched Nat intersection. -/
def collatzMediatingActionOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) :
    Nat :=
  collatzParityAction n
    (operationalParityRoles_mediatingRegime
      (arithmeticOperationalParityRolesOfIntersection intersection))

/-- The enriched Nat closing/forming regime carries `n / 2`. -/
theorem collatzClosingActionOfIntersection_eq_div_two
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) :
    collatzClosingActionOfIntersection intersection n = n / 2 := by
  unfold collatzClosingActionOfIntersection
  rw [arithmeticOperationalParityRoles_closing_left intersection]
  rfl

/-- The enriched Nat mediating/shadow regime carries `3*n+1`. -/
theorem collatzMediatingActionOfIntersection_eq_three_mul_add_one
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch)
    (n : Nat) :
    collatzMediatingActionOfIntersection intersection n = 3 * n + 1 := by
  unfold collatzMediatingActionOfIntersection
  rw [arithmeticOperationalParityRoles_mediating_right intersection]
  rfl

/-! ## Formed/shadow dependency exposed through the existing raccord -/

/-- The Collatz closing action is attached to the formed dynamic regime. -/
theorem collatzClosingRegime_eq_formedRegime
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    operationalParityRoles_closingRegime
        (arithmeticOperationalParityRolesOfIntersection intersection) =
      dynamicParitySeparation_formedRegime
        (arithmeticDynamicParitySeparationOfIntersection intersection) :=
  operationalParityRoles_closing_eq_formed
    (arithmeticOperationalParityRolesOfIntersection intersection)

/-- The Collatz mediating action is attached to the shadow dynamic regime. -/
theorem collatzMediatingRegime_eq_shadowRegime
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    operationalParityRoles_mediatingRegime
        (arithmeticOperationalParityRolesOfIntersection intersection) =
      dynamicParitySeparation_shadowRegime
        (arithmeticDynamicParitySeparationOfIntersection intersection) :=
  operationalParityRoles_mediating_eq_shadow
    (arithmeticOperationalParityRolesOfIntersection intersection)

/-- The two Collatz regimes keep the contracted parity projection. -/
theorem collatzOperationalParity_sameProjection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    parityProjection
        (operationalParityRoles_closingRegime
          (arithmeticOperationalParityRolesOfIntersection intersection)) =
      parityProjection
        (operationalParityRoles_mediatingRegime
          (arithmeticOperationalParityRolesOfIntersection intersection)) :=
  operationalParityRoles_sameParityProjection
    (arithmeticOperationalParityRolesOfIntersection intersection)

/-- The two Collatz regimes remain separated inside enriched Nat. -/
theorem collatzOperationalParity_separated
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    operationalParityRoles_closingRegime
        (arithmeticOperationalParityRolesOfIntersection intersection) =
      operationalParityRoles_mediatingRegime
        (arithmeticOperationalParityRolesOfIntersection intersection) ->
        False :=
  operationalParityRoles_separated
    (arithmeticOperationalParityRolesOfIntersection intersection)

/-- The closing/forming side carries the local dynamic repair. -/
def collatzOperationalParity_dynamicRepair
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatInterfaceRepair
      (operationalTwoPole_leftPole
        (dynamicParitySeparation_dynamicOperationalTwoPole
          (arithmeticDynamicParitySeparationOfIntersection intersection))) :=
  operationalParityRoles_dynamicRepair
    (arithmeticOperationalParityRolesOfIntersection intersection)

/-! ## Exact impact in enriched Nat coordinates -/

/-- The closing/forming branch exposes the enriched payload carried by the formed role. -/
def collatzClosingPayloadAction
    (k : Nat) :
    Nat :=
  k

/--
The role produced by the shadow branch in enriched Nat coordinates.

The shadow branch returns to a closing role.  The new closing payload is
`3*k+2`, where `k` is the shared payload of the formed/shadow pair.
-/
def collatzShadowReturnRole
    (k : Nat) :
    NatEnrichedParityRole :=
  NatEnrichedParityRole.closingExcess (3 * k + 2)

/-- The closing/forming branch returns exactly the shared enriched payload. -/
theorem collatzClosingPayloadAction_eq
    (k : Nat) :
    collatzClosingPayloadAction k = k :=
  rfl

/-- The shadow branch returns to a closing role with payload `3*k+2`. -/
theorem collatzShadowReturnRole_eq
    (k : Nat) :
    collatzShadowReturnRole k =
      NatEnrichedParityRole.closingExcess (3 * k + 2) :=
  rfl

/-! ## Exact impact on one enriched Nat dynamic intersection -/

/-- Collatz closing payload extracted from an enriched Nat intersection. -/
def collatzClosingPayloadOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Nat :=
  collatzClosingPayloadAction
    (formedPositiveExcessOfIntersection intersection)

/-- Collatz shadow return role extracted from an enriched Nat intersection. -/
def collatzShadowReturnRoleOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatEnrichedParityRole :=
  collatzShadowReturnRole
    (formedPositiveExcessOfIntersection intersection)

/-- The extracted closing side returns exactly the formed payload. -/
theorem collatzClosingPayloadOfIntersection_eq
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzClosingPayloadOfIntersection intersection =
      formedPositiveExcessOfIntersection intersection :=
  rfl

/-- The extracted closing side returns the successor of the terminal time. -/
theorem collatzClosingPayloadOfIntersection_eq_terminalTime_succ
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzClosingPayloadOfIntersection intersection =
      terminalTimeOfIntersection intersection + 1 := by
  rw [collatzClosingPayloadOfIntersection_eq]
  rfl

/-- The extracted shadow side returns to a closing role with payload `3*k+2`. -/
theorem collatzShadowReturnRoleOfIntersection_eq
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzShadowReturnRoleOfIntersection intersection =
      NatEnrichedParityRole.closingExcess
        (3 * formedPositiveExcessOfIntersection intersection + 2) :=
  rfl

/--
The extracted shadow side returns to a closing role whose payload is computed
from the successor of the terminal time.
-/
theorem collatzShadowReturnRoleOfIntersection_eq_terminalTime_succ
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzShadowReturnRoleOfIntersection intersection =
      NatEnrichedParityRole.closingExcess
        (3 * (terminalTimeOfIntersection intersection + 1) + 2) := by
  rw [collatzShadowReturnRoleOfIntersection_eq]
  rfl

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzParityAction
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzParityAction_left
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzParityAction_right
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzClosingActionOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzMediatingActionOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzClosingActionOfIntersection_eq_div_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzMediatingActionOfIntersection_eq_three_mul_add_one
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzClosingRegime_eq_formedRegime
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzMediatingRegime_eq_shadowRegime
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalParity_sameProjection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalParity_separated
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalParity_dynamicRepair
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzClosingPayloadAction
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzShadowReturnRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzClosingPayloadAction_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzShadowReturnRole_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzClosingPayloadOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzShadowReturnRoleOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzClosingPayloadOfIntersection_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzShadowReturnRoleOfIntersection_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzClosingPayloadOfIntersection_eq_terminalTime_succ
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzShadowReturnRoleOfIntersection_eq_terminalTime_succ
/- AXIOM_AUDIT_END -/
