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

/-! ## Relaxed diagonal instantiated by Collatz operational parity -/

/--
Collatz instantiates the positive internal diagonal witness already carried by
the maximally relaxed enriched-Nat parity gap at the intersection index.
-/
def collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatEnrichedParityPositiveInternalDiagonalWitness
      (formedPositiveExcessOfIntersection intersection) :=
  natEnrichedParityPositiveInternalDiagonalWitnessOfMaximallyRelaxedGap
    (formedPositiveExcessOfIntersection intersection)

/-- The relaxed gap instantiated by one Collatz operational intersection. -/
def collatzRelaxedGapOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatEnrichedParityRelaxedBilateralGap
      (formedPositiveExcessOfIntersection intersection) :=
  (collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    intersection).relaxedGap

/-- The core diagonal certificate carried by the Collatz relaxed gap. -/
def collatzRelaxedDiagonalCertificateOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    DiagonalCertificate
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload :=
  (collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    intersection).diagonalCertificate

/-- The projection obstruction carried by the Collatz relaxed diagonal. -/
def collatzRelaxedProjectionObstructionOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload :=
  (collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    intersection).projectionObstruction

/-- The positive diagonal value carried by the Collatz relaxed diagonal. -/
def collatzRelaxedPositiveDiagonalValueOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Nat :=
  (collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    intersection).witness

/-- The Collatz relaxed diagonal value is strictly positive. -/
theorem collatzRelaxedPositiveDiagonalValue_pos
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    0 <
      collatzRelaxedPositiveDiagonalValueOfIntersection intersection :=
  (collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    intersection).witness_pos

/-- The Collatz relaxed diagonal value is the maximal relaxed divergence at the intersection index. -/
theorem collatzRelaxedPositiveDiagonalValue_eq_maximalDivergence
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    collatzRelaxedPositiveDiagonalValueOfIntersection intersection =
      natEnrichedParityMaximalRelaxedDivergence
        (formedPositiveExcessOfIntersection intersection) :=
  (collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
    intersection).witness_eq_maximal

/-- The left side of the Collatz relaxed diagonal is the extracted closing role. -/
theorem collatzRelaxedDiagonalCertificate_left_eq_closingRole
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedDiagonalCertificateOfIntersection intersection).left =
      arithmeticClosingRoleOfIntersection intersection := by
  rw [arithmeticClosingRoleOfIntersection_eq intersection]
  rfl

/-- The right side of the Collatz relaxed diagonal is the extracted mediating role. -/
theorem collatzRelaxedDiagonalCertificate_right_eq_mediatingRole
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (collatzRelaxedDiagonalCertificateOfIntersection intersection).right =
      arithmeticMediatingRoleOfIntersection intersection := by
  rw [arithmeticMediatingRoleOfIntersection_eq intersection]
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
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedPositiveInternalDiagonalWitnessOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedGapOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedDiagonalCertificateOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedProjectionObstructionOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedPositiveDiagonalValueOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedPositiveDiagonalValue_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedPositiveDiagonalValue_eq_maximalDivergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedDiagonalCertificate_left_eq_closingRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzRelaxedDiagonalCertificate_right_eq_mediatingRole
/- AXIOM_AUDIT_END -/
