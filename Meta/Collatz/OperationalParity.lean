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

/-! ## Collatz as an indexed diagonal step -/

/--
One Collatz step, read on an enriched Nat intersection.

The package consumes the arithmetic indexed diagonal parity already carried by
enriched Nat, then adds the Collatz-specific closing payload and shadow return.
-/
structure CollatzOperationalDiagonalStep
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Type where
  arithmeticIndexedParity :
    ArithmeticIndexedDiagonalParity intersection
  arithmeticIndexedParity_eq :
    arithmeticIndexedParity =
      arithmeticIndexedDiagonalParityOfIntersection intersection
  closingPayload : Nat
  closingPayload_eq_terminalTime_succ :
    closingPayload = terminalTimeOfIntersection intersection + 1
  shadowReturnRole : NatEnrichedParityRole
  shadowReturnRole_eq_terminalTime_succ :
    shadowReturnRole =
      NatEnrichedParityRole.closingExcess
        (3 * (terminalTimeOfIntersection intersection + 1) + 2)

/--
Every enriched Nat intersection canonically induces the Collatz indexed
diagonal step carried by that same intersection.
-/
def collatzOperationalDiagonalStepOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    CollatzOperationalDiagonalStep intersection where
  arithmeticIndexedParity :=
    arithmeticIndexedDiagonalParityOfIntersection intersection
  arithmeticIndexedParity_eq := rfl
  closingPayload := collatzClosingPayloadOfIntersection intersection
  closingPayload_eq_terminalTime_succ :=
    collatzClosingPayloadOfIntersection_eq_terminalTime_succ intersection
  shadowReturnRole := collatzShadowReturnRoleOfIntersection intersection
  shadowReturnRole_eq_terminalTime_succ :=
    collatzShadowReturnRoleOfIntersection_eq_terminalTime_succ intersection

/--
The Collatz indexed diagonal step consumes exactly the arithmetic indexed
diagonal parity of its enriched Nat intersection.
-/
theorem collatzOperationalDiagonalStep_carries_arithmeticIndexedParity
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzOperationalDiagonalStepOfIntersection intersection).arithmeticIndexedParity =
      arithmeticIndexedDiagonalParityOfIntersection intersection :=
  rfl

/--
The arithmetic parity consumed by the Collatz indexed diagonal step carries
the exact Core diagonal certificate of its enriched Nat intersection.
-/
theorem collatzOperationalDiagonalStep_carries_diagonal
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzOperationalDiagonalStepOfIntersection intersection).arithmeticIndexedParity.diagonal =
      diagonalCertificateOfIntersection intersection :=
  rfl

/--
The Collatz indexed diagonal step is indexed by the successor of the terminal
time of the same enriched Nat intersection.
-/
theorem collatzOperationalDiagonalStep_closingPayload_eq_terminalTime_succ
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzOperationalDiagonalStepOfIntersection intersection).closingPayload =
      terminalTimeOfIntersection intersection + 1 :=
  collatzClosingPayloadOfIntersection_eq_terminalTime_succ intersection

/--
The shadow return of the Collatz indexed diagonal step is computed from the
same successor of terminal time.
-/
theorem collatzOperationalDiagonalStep_shadowReturnRole_eq_terminalTime_succ
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzOperationalDiagonalStepOfIntersection intersection).shadowReturnRole =
      NatEnrichedParityRole.closingExcess
        (3 * (terminalTimeOfIntersection intersection + 1) + 2) :=
  collatzShadowReturnRoleOfIntersection_eq_terminalTime_succ intersection

/-! ## Collatz on positive-window indexed parity -/

/--
Collatz positive operational diagonal step.

The positive-window indexed parity is supplied by the arithmetic layer.  This
package consumes it and adds the Collatz-specific operational diagonal:
closing payload on the terminal formed excess and shadow return
`3 * formedExcess + 2`.
-/
structure CollatzPositiveOperationalDiagonalStep
    {step : Nat -> Nat}
    {start : Nat}
    {cert : NatTrajectoryFinitePrefixHeightCertificate step start}
    (positiveIndexedParity :
      ArithmeticPositiveWindowIndexedDiagonalParity cert) :
    Type where
  collatzStep :
    CollatzOperationalDiagonalStep
      positiveIndexedParity.terminalIntersection
  collatzStep_eq :
    collatzStep =
      collatzOperationalDiagonalStepOfIntersection
        positiveIndexedParity.terminalIntersection
  closingPayload_eq_formedExcess :
    collatzStep.closingPayload =
      positiveIndexedParity.indexedParity.formedExcess
  shadowReturnRole_eq_formedExcess :
    collatzStep.shadowReturnRole =
      NatEnrichedParityRole.closingExcess
        (3 * positiveIndexedParity.indexedParity.formedExcess + 2)

/--
Canonical Collatz positive operational diagonal step from an arithmetic
positive-window indexed parity package.
-/
def collatzPositiveOperationalDiagonalStepOfArithmetic
    {step : Nat -> Nat}
    {start : Nat}
    {cert : NatTrajectoryFinitePrefixHeightCertificate step start}
    (positiveIndexedParity :
      ArithmeticPositiveWindowIndexedDiagonalParity cert) :
    CollatzPositiveOperationalDiagonalStep positiveIndexedParity where
  collatzStep :=
    collatzOperationalDiagonalStepOfIntersection
      positiveIndexedParity.terminalIntersection
  collatzStep_eq := rfl
  closingPayload_eq_formedExcess := by
    have hIndexed :
        positiveIndexedParity.indexedParity.formedExcess =
          terminalTimeOfIntersection
              positiveIndexedParity.terminalIntersection + 1 := by
      rw [positiveIndexedParity.indexedParity_eq]
      exact
        arithmeticIndexedDiagonalParity_formedExcess_eq_terminalTime_succ
          positiveIndexedParity.terminalIntersection
    calc
      (collatzOperationalDiagonalStepOfIntersection
          positiveIndexedParity.terminalIntersection).closingPayload =
          terminalTimeOfIntersection
              positiveIndexedParity.terminalIntersection + 1 :=
        collatzOperationalDiagonalStep_closingPayload_eq_terminalTime_succ
          positiveIndexedParity.terminalIntersection
      _ = positiveIndexedParity.indexedParity.formedExcess :=
        Eq.symm hIndexed
  shadowReturnRole_eq_formedExcess := by
    have hIndexed :
        positiveIndexedParity.indexedParity.formedExcess =
          terminalTimeOfIntersection
              positiveIndexedParity.terminalIntersection + 1 := by
      rw [positiveIndexedParity.indexedParity_eq]
      exact
        arithmeticIndexedDiagonalParity_formedExcess_eq_terminalTime_succ
          positiveIndexedParity.terminalIntersection
    calc
      (collatzOperationalDiagonalStepOfIntersection
          positiveIndexedParity.terminalIntersection).shadowReturnRole =
          NatEnrichedParityRole.closingExcess
            (3 *
              (terminalTimeOfIntersection
                  positiveIndexedParity.terminalIntersection + 1) + 2) :=
        collatzOperationalDiagonalStep_shadowReturnRole_eq_terminalTime_succ
          positiveIndexedParity.terminalIntersection
      _ =
          NatEnrichedParityRole.closingExcess
            (3 * positiveIndexedParity.indexedParity.formedExcess + 2) := by
        rw [hIndexed]

/-- The Collatz positive step consumes the arithmetic positive-window package. -/
theorem collatzPositiveOperationalDiagonalStep_carries_arithmetic
    {step : Nat -> Nat}
    {start : Nat}
    {cert : NatTrajectoryFinitePrefixHeightCertificate step start}
    (positiveIndexedParity :
      ArithmeticPositiveWindowIndexedDiagonalParity cert) :
    (collatzPositiveOperationalDiagonalStepOfArithmetic
        positiveIndexedParity).collatzStep =
      collatzOperationalDiagonalStepOfIntersection
        positiveIndexedParity.terminalIntersection :=
  rfl

/-- The Collatz positive step uses the arithmetic formed excess as closing payload. -/
theorem collatzPositiveOperationalDiagonalStep_closingPayload_eq_formedExcess
    {step : Nat -> Nat}
    {start : Nat}
    {cert : NatTrajectoryFinitePrefixHeightCertificate step start}
    (positiveIndexedParity :
      ArithmeticPositiveWindowIndexedDiagonalParity cert) :
    (collatzPositiveOperationalDiagonalStepOfArithmetic
        positiveIndexedParity).collatzStep.closingPayload =
      positiveIndexedParity.indexedParity.formedExcess :=
  (collatzPositiveOperationalDiagonalStepOfArithmetic
    positiveIndexedParity).closingPayload_eq_formedExcess

/-- The Collatz positive step returns the shadow to a closing role. -/
theorem collatzPositiveOperationalDiagonalStep_shadowReturnRole_eq_formedExcess
    {step : Nat -> Nat}
    {start : Nat}
    {cert : NatTrajectoryFinitePrefixHeightCertificate step start}
    (positiveIndexedParity :
      ArithmeticPositiveWindowIndexedDiagonalParity cert) :
    (collatzPositiveOperationalDiagonalStepOfArithmetic
        positiveIndexedParity).collatzStep.shadowReturnRole =
      NatEnrichedParityRole.closingExcess
        (3 * positiveIndexedParity.indexedParity.formedExcess + 2) :=
  (collatzPositiveOperationalDiagonalStepOfArithmetic
    positiveIndexedParity).shadowReturnRole_eq_formedExcess

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
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzOperationalDiagonalStep
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalDiagonalStepOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalDiagonalStep_carries_arithmeticIndexedParity
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalDiagonalStep_carries_diagonal
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalDiagonalStep_closingPayload_eq_terminalTime_succ
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzOperationalDiagonalStep_shadowReturnRole_eq_terminalTime_succ
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzPositiveOperationalDiagonalStep
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzPositiveOperationalDiagonalStepOfArithmetic
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzPositiveOperationalDiagonalStep_carries_arithmetic
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzPositiveOperationalDiagonalStep_closingPayload_eq_formedExcess
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzPositiveOperationalDiagonalStep_shadowReturnRole_eq_formedExcess
/- AXIOM_AUDIT_END -/
