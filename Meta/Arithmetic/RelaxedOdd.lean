import Meta.Arithmetic.Parity

/-!
# Enriched Nat relaxed odd role

This file isolates the relaxed odd role already carried by enriched Nat
parity.  The relaxed odd role is not defined by the non-relaxed arithmetic
code `2*k+1`; it is the mediating role together with the maximally relaxed
gap, its core diagonal certificate, projection obstruction, positive witness,
and relaxed right payload.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Audit-clean Nat arithmetic used by the visible concordance -/

/-- Three times a natural number is two copies followed by one copy. -/
theorem nat_three_mul_eq_double_add
    (k : Nat) :
    3 * k = (k + k) + k := by
  change Nat.succ 2 * k = (k + k) + k
  rw [Nat.succ_mul, Nat.two_mul]

/-- Multiplying by three after doubling agrees with doubling after multiplying by three. -/
theorem nat_three_mul_two_mul_eq_two_mul_three_mul
    (k : Nat) :
    3 * (2 * k) = 2 * (3 * k) := by
  induction k with
  | zero =>
      rfl
  | succ k ih =>
      rw [Nat.mul_succ 2 k]
      rw [Nat.mul_succ 3 k]
      rw [Nat.mul_add]
      rw [Nat.mul_add]
      rw [ih]

/-! ## Audit-clean division by two -/

/-- Every natural number is strictly below itself plus two. -/
theorem nat_lt_add_two_clean
    (x : Nat) :
    x < x + 2 := by
  induction x with
  | zero =>
      exact Nat.zero_lt_succ 1
  | succ x ih =>
      exact Nat.succ_lt_succ ih

/-- Two is below every double successor. -/
theorem nat_two_le_succ_succ_clean
    (x : Nat) :
    2 ≤ Nat.succ (Nat.succ x) :=
  Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le x))

/--
The `Nat.div.go` computation for divisor two is independent of its admissible
fuel.  This is the local constructive substitute for the standard division
lemmas that pull in forbidden dependencies in this project.
-/
theorem nat_div_go_two_eq_div_clean
    (x : Nat) :
    ∀ (fuel : Nat) (hfuel : x < fuel),
      Nat.div.go 2 (by decide : 0 < 2) fuel x hfuel = x / 2 := by
  induction x using Nat.strongRecOn with
  | ind x ih =>
      cases x with
      | zero =>
          intro fuel hfuel
          cases fuel with
          | zero =>
              cases hfuel
          | succ fuel =>
              unfold Nat.div.go
              rw [dif_neg (by decide : ¬2 ≤ 0)]
      | succ x =>
          cases x with
          | zero =>
              intro fuel hfuel
              cases fuel with
              | zero =>
                  cases hfuel
              | succ fuel =>
                  unfold Nat.div.go
                  rw [dif_neg (by decide : ¬2 ≤ 1)]
          | succ x =>
              intro fuel hfuel
              cases fuel with
              | zero =>
                  cases hfuel
              | succ fuel =>
                  unfold Nat.div.go
                  rw [dif_pos (nat_two_le_succ_succ_clean x)]
                  change
                    Nat.div.go 2 (by decide : 0 < 2) fuel x _ + 1 =
                      (Nat.succ (Nat.succ x)) / 2
                  rw [ih x (nat_lt_add_two_clean x)]
                  conv_rhs =>
                    change Nat.div (Nat.succ (Nat.succ x)) 2
                    unfold Nat.div
                    rw [dif_pos (by decide : 0 < 2)]
                    unfold Nat.div.go
                    rw [dif_pos (nat_two_le_succ_succ_clean x)]
                    change
                      Nat.div.go 2 (by decide : 0 < 2) (x + 2) x _ + 1
                    rw [ih x (nat_lt_add_two_clean x)]

/-- Dividing a double successor by two removes the two added endpoints. -/
theorem nat_succ_succ_div_two_clean
    (x : Nat) :
    Nat.div (Nat.succ (Nat.succ x)) 2 = x / 2 + 1 := by
  unfold Nat.div
  rw [dif_pos (by decide : 0 < 2)]
  unfold Nat.div.go
  rw [dif_pos (nat_two_le_succ_succ_clean x)]
  change Nat.div.go 2 (by decide : 0 < 2) (x + 2) x _ + 1 = x / 2 + 1
  rw [nat_div_go_two_eq_div_clean x]

/-- The clean project-local theorem for the even retraction `(2*x)/2 = x`. -/
theorem nat_two_mul_div_two_clean
    (x : Nat) :
    (2 * x) / 2 = x := by
  induction x with
  | zero =>
      rfl
  | succ x ih =>
      rw [Nat.mul_succ]
      change Nat.div (Nat.succ (Nat.succ (2 * x))) 2 = Nat.succ x
      rw [nat_succ_succ_div_two_clean (2 * x)]
      rw [ih]

/-! ## Relaxed right payload -/

/-- The maximal relaxed right payload is source payload plus positive witness. -/
theorem natEnrichedParityMaximallyRelaxedRightPayload_eq_source_add_witness
    (k : Nat) :
    natEnrichedParityMaximallyRelaxedRightPayload k =
      k + natEnrichedParityMaximalRelaxedDivergence k :=
  rfl

/-- The maximal relaxed right payload has visible form `3*k + 2`. -/
theorem natEnrichedParityMaximallyRelaxedRightPayload_eq_three_mul_add_two
    (k : Nat) :
    natEnrichedParityMaximallyRelaxedRightPayload k =
      3 * k + 2 := by
  unfold natEnrichedParityMaximallyRelaxedRightPayload
  rw [natEnrichedParityMaximalRelaxedDivergence_eq_double_add_two]
  calc
    k + ((k + k) + 2) = (k + (k + k)) + 2 := by
      rw [← Nat.add_assoc k (k + k) 2]
    _ = ((k + k) + k) + 2 := by
      rw [Nat.add_comm k (k + k)]
    _ = 3 * k + 2 := by
      rw [← nat_three_mul_eq_double_add k]

/--
The non-relaxed visible mediating code under the odd Collatz expression is the
double of the relaxed right payload.

This is a visible concordance theorem.  It does not define the relaxed odd
role by `2*k+1`.
-/
theorem natEnrichedParityMediatingCode_three_mul_add_one_eq_two_mul_rightPayload
    (k : Nat) :
    3 *
        (natEnrichedParityRoleCode
          (NatEnrichedParityRole.mediatingValue k)) + 1 =
      2 * natEnrichedParityMaximallyRelaxedRightPayload k := by
  rw [natEnrichedParityMaximallyRelaxedRightPayload_eq_three_mul_add_two]
  unfold natEnrichedParityRoleCode
  rw [Nat.mul_add]
  rw [Nat.mul_one]
  rw [nat_three_mul_two_mul_eq_two_mul_three_mul]
  rw [Nat.mul_add]

/--
The visible odd Collatz expression on the non-relaxed mediating code retracts
by `/2` to the relaxed right payload.
-/
theorem natEnrichedParityMediatingCode_three_mul_add_one_div_two_eq_rightPayload
    (k : Nat) :
    (3 *
        (natEnrichedParityRoleCode
          (NatEnrichedParityRole.mediatingValue k)) + 1) / 2 =
      natEnrichedParityMaximallyRelaxedRightPayload k := by
  rw [natEnrichedParityMediatingCode_three_mul_add_one_eq_two_mul_rightPayload]
  exact nat_two_mul_div_two_clean
    (natEnrichedParityMaximallyRelaxedRightPayload k)

/-! ## Relaxed odd role -/

/--
The enriched Nat relaxed odd role at index `k`.

It packages the mediating role together with the maximally relaxed gap, its
right payload, the core diagonal certificate, projection obstruction, and the
positive internal witness.  It is intentionally independent from the
non-relaxed arithmetic code.
-/
structure NatEnrichedRelaxedOddRole
    (k : Nat) where
  mediatingRole : NatEnrichedParityRole
  mediatingRole_eq :
    mediatingRole = NatEnrichedParityRole.mediatingValue k
  relaxedGap :
    NatEnrichedParityRelaxedBilateralGap k
  relaxedGap_mediating :
    relaxedGap.mediatingRole = mediatingRole
  rightPayload : Nat
  rightPayload_eq :
    rightPayload = relaxedGap.rightPayload
  rightPayload_eq_maximallyRelaxed :
    rightPayload = natEnrichedParityMaximallyRelaxedRightPayload k
  rightPayload_eq_source_add_witness :
    rightPayload = k + natEnrichedParityMaximalRelaxedDivergence k
  diagonalCertificate :
    DiagonalCertificate
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload
  diagonal_left_eq_closing :
    diagonalCertificate.left = NatEnrichedParityRole.closingExcess k
  diagonal_right_eq_mediating :
    diagonalCertificate.right = mediatingRole
  projectionObstruction :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload
  positiveWitness : Nat
  positiveWitness_eq_divergence :
    positiveWitness = relaxedGap.divergence
  positiveWitness_pos :
    0 < positiveWitness
  positiveWitness_eq_maximalDivergence :
    positiveWitness = natEnrichedParityMaximalRelaxedDivergence k

/-- The canonical relaxed odd role carried by enriched Nat at index `k`. -/
def natEnrichedRelaxedOddRole
    (k : Nat) :
    NatEnrichedRelaxedOddRole k where
  mediatingRole := NatEnrichedParityRole.mediatingValue k
  mediatingRole_eq := rfl
  relaxedGap := natEnrichedParityMaximallyRelaxedBilateralGap k
  relaxedGap_mediating := rfl
  rightPayload := natEnrichedParityMaximallyRelaxedRightPayload k
  rightPayload_eq := rfl
  rightPayload_eq_maximallyRelaxed := rfl
  rightPayload_eq_source_add_witness := rfl
  diagonalCertificate := natEnrichedParityMaximallyRelaxedDiagonalCertificate k
  diagonal_left_eq_closing := rfl
  diagonal_right_eq_mediating := rfl
  projectionObstruction := natEnrichedParityMaximallyRelaxedProjectionObstruction k
  positiveWitness := natEnrichedParityMaximalRelaxedDivergence k
  positiveWitness_eq_divergence := rfl
  positiveWitness_pos := natEnrichedParityMaximalRelaxedDivergence_pos k
  positiveWitness_eq_maximalDivergence := rfl

/-- The relaxed odd role has the mediating role at index `k`. -/
theorem natEnrichedRelaxedOddRole_mediating_eq
    (k : Nat) :
    (natEnrichedRelaxedOddRole k).mediatingRole =
      NatEnrichedParityRole.mediatingValue k :=
  rfl

/-- The relaxed odd right payload is the canonical maximal relaxed right payload. -/
theorem natEnrichedRelaxedOddRole_rightPayload_eq_maximallyRelaxed
    (k : Nat) :
    (natEnrichedRelaxedOddRole k).rightPayload =
      natEnrichedParityMaximallyRelaxedRightPayload k :=
  rfl

/-- The relaxed odd right payload is source payload plus its positive witness. -/
theorem natEnrichedRelaxedOddRole_rightPayload_eq_source_add_witness
    (k : Nat) :
    (natEnrichedRelaxedOddRole k).rightPayload =
      k + (natEnrichedRelaxedOddRole k).positiveWitness :=
  rfl

/-- The relaxed odd witness is exactly the divergence of its relaxed gap. -/
theorem natEnrichedRelaxedOddRole_witness_eq_divergence
    (k : Nat) :
    (natEnrichedRelaxedOddRole k).positiveWitness =
      (natEnrichedRelaxedOddRole k).relaxedGap.divergence :=
  rfl

/-- The relaxed odd witness is positive. -/
theorem natEnrichedRelaxedOddRole_witness_pos
    (k : Nat) :
    0 < (natEnrichedRelaxedOddRole k).positiveWitness :=
  natEnrichedParityMaximalRelaxedDivergence_pos k

/-- The relaxed odd witness is the maximal relaxed divergence. -/
theorem natEnrichedRelaxedOddRole_witness_eq_maximalDivergence
    (k : Nat) :
    (natEnrichedRelaxedOddRole k).positiveWitness =
      natEnrichedParityMaximalRelaxedDivergence k :=
  rfl

/-- The relaxed odd diagonal starts at the closing role. -/
theorem natEnrichedRelaxedOddRole_diagonal_left_eq_closing
    (k : Nat) :
    (natEnrichedRelaxedOddRole k).diagonalCertificate.left =
      NatEnrichedParityRole.closingExcess k :=
  rfl

/-- The relaxed odd diagonal ends at the mediating role. -/
theorem natEnrichedRelaxedOddRole_diagonal_right_eq_mediating
    (k : Nat) :
    (natEnrichedRelaxedOddRole k).diagonalCertificate.right =
      (natEnrichedRelaxedOddRole k).mediatingRole :=
  rfl

/--
The visible odd Collatz expression on the non-relaxed mediating code is the
double of the relaxed odd right payload.
-/
theorem natEnrichedRelaxedOddRole_visibleOddStep_eq_two_mul_rightPayload
    (k : Nat) :
    3 *
        (natEnrichedParityRoleCode
          (natEnrichedRelaxedOddRole k).mediatingRole) + 1 =
      2 * (natEnrichedRelaxedOddRole k).rightPayload := by
  rw [natEnrichedRelaxedOddRole_mediating_eq]
  rw [natEnrichedRelaxedOddRole_rightPayload_eq_maximallyRelaxed]
  exact
    natEnrichedParityMediatingCode_three_mul_add_one_eq_two_mul_rightPayload k

/--
The visible odd expression on the relaxed odd role retracts by `/2` to its
relaxed right payload.
-/
theorem natEnrichedRelaxedOddRole_visibleOddStep_div_two_eq_rightPayload
    (k : Nat) :
    (3 *
        (natEnrichedParityRoleCode
          (natEnrichedRelaxedOddRole k).mediatingRole) + 1) / 2 =
      (natEnrichedRelaxedOddRole k).rightPayload := by
  rw [natEnrichedRelaxedOddRole_visibleOddStep_eq_two_mul_rightPayload]
  exact nat_two_mul_div_two_clean
    (natEnrichedRelaxedOddRole k).rightPayload

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_three_mul_eq_double_add
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_three_mul_two_mul_eq_two_mul_three_mul
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_lt_add_two_clean
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_two_le_succ_succ_clean
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_div_go_two_eq_div_clean
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_succ_succ_div_two_clean
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_two_mul_div_two_clean
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMaximallyRelaxedRightPayload_eq_source_add_witness
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMaximallyRelaxedRightPayload_eq_three_mul_add_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMediatingCode_three_mul_add_one_eq_two_mul_rightPayload
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMediatingCode_three_mul_add_one_div_two_eq_rightPayload
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedRelaxedOddRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddRole_mediating_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddRole_rightPayload_eq_maximallyRelaxed
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddRole_rightPayload_eq_source_add_witness
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddRole_witness_eq_divergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddRole_witness_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddRole_witness_eq_maximalDivergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddRole_diagonal_left_eq_closing
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddRole_diagonal_right_eq_mediating
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddRole_visibleOddStep_eq_two_mul_rightPayload
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddRole_visibleOddStep_div_two_eq_rightPayload
/- AXIOM_AUDIT_END -/
