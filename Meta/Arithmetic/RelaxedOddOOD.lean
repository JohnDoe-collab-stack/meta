import Meta.OOD.WitnessTransport
import Meta.Arithmetic.RelaxedOdd

/-!
# OOD lock for the enriched Nat relaxed odd role

This file formalizes the arithmetic `projectOut/readOut` candidate before any
larger OOD instance is built.

The source reading is the non-relaxed visible reading of the contracted
payload.  The target reading is the relaxed right payload.  The relaxed odd
role itself remains the enriched role package; it is not redefined by the
source reading.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem
open OOD

/-! ## OOD projections and readings -/

/-- Source projection: forget the enriched role and keep its payload. -/
def natEnrichedRelaxedOddOODProjectIn :
    NatEnrichedParityRole -> Nat :=
  natEnrichedParityRolePayload

/-- Source reading of the contracted payload. -/
def natEnrichedRelaxedOddOODReadIn
    (payload : Nat) :
    Nat :=
  2 * payload + 1

/--
Target projection: contract the role to its payload, then expose the relaxed
right return payload produced at that index.
-/
def natEnrichedRelaxedOddOODProjectOut :
    NatEnrichedParityRole -> Nat :=
  fun role =>
    natEnrichedParityMaximallyRelaxedRightPayload
      (natEnrichedParityRolePayload role)

/-- Target reading of the relaxed right payload. -/
def natEnrichedRelaxedOddOODReadOut
    (payload : Nat) :
    Nat :=
  payload

/-- Formed role of the arithmetic OOD lock. -/
def natEnrichedRelaxedOddOODFormed
    (k : Nat) :
    NatEnrichedParityRole :=
  NatEnrichedParityRole.closingExcess k

/-- Shadow role of the arithmetic OOD lock. -/
def natEnrichedRelaxedOddOODShadow
    (k : Nat) :
    NatEnrichedParityRole :=
  NatEnrichedParityRole.mediatingValue k

/-- The input projection contracts the formed and shadow roles. -/
theorem natEnrichedRelaxedOddOOD_sameIn
    (k : Nat) :
    natEnrichedRelaxedOddOODProjectIn
        (natEnrichedRelaxedOddOODFormed k) =
      natEnrichedRelaxedOddOODProjectIn
        (natEnrichedRelaxedOddOODShadow k) :=
  rfl

/-- The output projection also contracts the formed and shadow roles. -/
theorem natEnrichedRelaxedOddOOD_sameOut
    (k : Nat) :
    natEnrichedRelaxedOddOODProjectOut
        (natEnrichedRelaxedOddOODFormed k) =
      natEnrichedRelaxedOddOODProjectOut
        (natEnrichedRelaxedOddOODShadow k) :=
  rfl

/-- The formed and shadow roles remain separated internally. -/
theorem natEnrichedRelaxedOddOOD_separated
    (k : Nat) :
    natEnrichedRelaxedOddOODFormed k =
      natEnrichedRelaxedOddOODShadow k -> False :=
  closingExcess_ne_mediatingValue k

/-- The source reading is the non-relaxed visible reading of the payload. -/
theorem natEnrichedRelaxedOddOOD_sourceRead_eq
    (k : Nat) :
    natEnrichedRelaxedOddOODReadIn
        (natEnrichedRelaxedOddOODProjectIn
          (natEnrichedRelaxedOddOODFormed k)) =
      2 * k + 1 :=
  rfl

/-- The target reading is the relaxed right payload. -/
theorem natEnrichedRelaxedOddOOD_targetRead_eq
    (k : Nat) :
    natEnrichedRelaxedOddOODReadOut
        (natEnrichedRelaxedOddOODProjectOut
          (natEnrichedRelaxedOddOODFormed k)) =
      natEnrichedParityMaximallyRelaxedRightPayload k :=
  rfl

/-! ## Constructive visible shift -/

/-- The source visible reading is strictly below the relaxed target form. -/
theorem nat_two_mul_add_one_lt_three_mul_add_two
    (k : Nat) :
    2 * k + 1 < 3 * k + 2 := by
  have hpos : 0 < k + 1 := Nat.succ_pos k
  have hlt :
      2 * k + 1 < (2 * k + 1) + (k + 1) :=
    Nat.lt_add_of_pos_right hpos
  have hsmall : 1 + (k + 1) = k + 2 := by
    rw [Nat.add_comm 1 (k + 1)]
  have heq :
      (2 * k + 1) + (k + 1) = 3 * k + 2 := by
    calc
      (2 * k + 1) + (k + 1) =
          2 * k + (1 + (k + 1)) := by
            rw [Nat.add_assoc]
      _ = 2 * k + (k + 2) := by
            rw [hsmall]
      _ = (2 * k + k) + 2 := by
            rw [← Nat.add_assoc]
      _ = 3 * k + 2 := by
            rw [nat_three_mul_eq_double_add]
            rw [Nat.two_mul]
  exact Nat.lt_of_lt_of_eq hlt heq

/-- The source visible reading is below the relaxed right payload. -/
theorem natEnrichedRelaxedOddOOD_sourceRead_lt_targetRead
    (k : Nat) :
    natEnrichedRelaxedOddOODReadIn
        (natEnrichedRelaxedOddOODProjectIn
          (natEnrichedRelaxedOddOODFormed k)) <
      natEnrichedRelaxedOddOODReadOut
        (natEnrichedRelaxedOddOODProjectOut
          (natEnrichedRelaxedOddOODFormed k)) := by
  change
    2 * k + 1 <
      natEnrichedParityMaximallyRelaxedRightPayload k
  rw [natEnrichedParityMaximallyRelaxedRightPayload_eq_three_mul_add_two]
  exact nat_two_mul_add_one_lt_three_mul_add_two k

/--
The target reading is the right payload of the supplied relaxed odd role.

This is the point where the shift source is used as structure, not as a
rebadged proof.
-/
theorem natEnrichedRelaxedOddOOD_targetRead_eq_sourceRightPayload
    {k : Nat}
    (source : NatEnrichedRelaxedOddRole k) :
    natEnrichedRelaxedOddOODReadOut
        (natEnrichedRelaxedOddOODProjectOut
          (natEnrichedRelaxedOddOODFormed k)) =
      source.rightPayload :=
  source.rightPayload_eq_maximallyRelaxed.symm

/-- The source role carries its own positive witness. -/
theorem natEnrichedRelaxedOddOOD_sourceWitness_pos
    {k : Nat}
    (source : NatEnrichedRelaxedOddRole k) :
    0 < source.positiveWitness :=
  source.positiveWitness_pos

/-- The source right payload is source payload plus its positive witness. -/
theorem natEnrichedRelaxedOddOOD_sourceRightPayload_eq_source_add_witness
    {k : Nat}
    (source : NatEnrichedRelaxedOddRole k) :
    source.rightPayload = k + source.positiveWitness :=
  by
    rw [source.positiveWitness_eq_maximalDivergence]
    exact source.rightPayload_eq_source_add_witness

/-- The OOD visible shift derived from the relaxed odd role source. -/
theorem natEnrichedRelaxedOddOOD_visibleShiftOfSource
    {k : Nat}
    (source : NatEnrichedRelaxedOddRole k) :
    natEnrichedRelaxedOddOODReadIn
        (natEnrichedRelaxedOddOODProjectIn
          (natEnrichedRelaxedOddOODFormed k)) =
      natEnrichedRelaxedOddOODReadOut
        (natEnrichedRelaxedOddOODProjectOut
          (natEnrichedRelaxedOddOODFormed k)) -> False := by
  intro h
  have htarget :
      natEnrichedRelaxedOddOODReadOut
          (natEnrichedRelaxedOddOODProjectOut
            (natEnrichedRelaxedOddOODFormed k)) =
        source.rightPayload :=
    natEnrichedRelaxedOddOOD_targetRead_eq_sourceRightPayload source
  have hlt :
      natEnrichedRelaxedOddOODReadIn
          (natEnrichedRelaxedOddOODProjectIn
            (natEnrichedRelaxedOddOODFormed k)) <
        source.rightPayload := by
    rw [← htarget]
    exact natEnrichedRelaxedOddOOD_sourceRead_lt_targetRead k
  rw [h] at hlt
  rw [htarget] at hlt
  exact Nat.lt_irrefl source.rightPayload hlt

/-! ## OOD lock package -/

/-- The OOD projection shift of the canonical relaxed odd role at index `k`. -/
def natEnrichedRelaxedOddOODProjectionShift
    (k : Nat) :
    OODProjectionShift
      NatEnrichedParityRole
      Nat
      Nat
      Nat
      (NatEnrichedRelaxedOddRole k)
      natEnrichedRelaxedOddOODProjectIn
      natEnrichedRelaxedOddOODProjectOut
      natEnrichedRelaxedOddOODReadIn
      natEnrichedRelaxedOddOODReadOut where
  formed := natEnrichedRelaxedOddOODFormed k
  shadow := natEnrichedRelaxedOddOODShadow k
  sameIn := natEnrichedRelaxedOddOOD_sameIn k
  sameOut := natEnrichedRelaxedOddOOD_sameOut k
  separated := natEnrichedRelaxedOddOOD_separated k
  shiftSource := natEnrichedRelaxedOddRole k
  visibleShiftOfSource :=
    fun source =>
      natEnrichedRelaxedOddOOD_visibleShiftOfSource source

/-- The recovered cell for the arithmetic OOD lock. -/
def natEnrichedRelaxedOddOODRecoveredCell
    (k : Nat) :
    OODRecoveredCell
      NatEnrichedParityRole
      Nat
      Nat
      Nat
      (NatEnrichedRelaxedOddRole k)
      natEnrichedRelaxedOddOODProjectIn
      natEnrichedRelaxedOddOODProjectOut
      natEnrichedRelaxedOddOODReadIn
      natEnrichedRelaxedOddOODReadOut
      NatEnrichedParityRoleRepair where
  shift := natEnrichedRelaxedOddOODProjectionShift k
  repair :=
    natEnrichedParityRoleRepair
      (natEnrichedRelaxedOddOODFormed k)
  recovered := natEnrichedRelaxedOddOODFormed k
  recovered_eq_formed := rfl

/-- The positive witness is exactly the one carried by the relaxed odd role. -/
theorem natEnrichedRelaxedOddOOD_witnessOfCell_eq_relaxedOddWitness
    (k : Nat) :
    (natEnrichedRelaxedOddRole k).positiveWitness =
      natEnrichedParityMaximalRelaxedDivergence k :=
  natEnrichedRelaxedOddRole_witness_eq_maximalDivergence k

/-- The OOD witness family used by the arithmetic lock. -/
def natEnrichedRelaxedOddOODWitnessOf
    (_role : NatEnrichedParityRole) :
    Type :=
  Nat

/-- The witness transport extracted from the relaxed odd role. -/
def natEnrichedRelaxedOddOODWitnessTransport
    (k : Nat) :
    OODWitnessTransport
      NatEnrichedParityRole
      Nat
      Nat
      Nat
      (NatEnrichedRelaxedOddRole k)
      natEnrichedRelaxedOddOODProjectIn
      natEnrichedRelaxedOddOODProjectOut
      natEnrichedRelaxedOddOODReadIn
      natEnrichedRelaxedOddOODReadOut
      NatEnrichedParityRoleRepair
      natEnrichedRelaxedOddOODWitnessOf where
  cell := natEnrichedRelaxedOddOODRecoveredCell k
  witnessOfCell := (natEnrichedRelaxedOddRole k).positiveWitness
  witnessIn := (natEnrichedRelaxedOddRole k).positiveWitness
  witnessOut := (natEnrichedRelaxedOddRole k).positiveWitness
  witnessIn_eq := rfl
  witnessOut_eq := rfl

/-- Positive Nat witness transport for the arithmetic OOD lock. -/
def natEnrichedRelaxedOddOODPositiveWitnessTransport
    (k : Nat) :
    OODPositiveWitnessTransport
      NatEnrichedParityRole
      Nat
      Nat
      Nat
      (NatEnrichedRelaxedOddRole k)
      natEnrichedRelaxedOddOODProjectIn
      natEnrichedRelaxedOddOODProjectOut
      natEnrichedRelaxedOddOODReadIn
      natEnrichedRelaxedOddOODReadOut
      NatEnrichedParityRoleRepair where
  cell := natEnrichedRelaxedOddOODRecoveredCell k
  witnessOfCell := (natEnrichedRelaxedOddRole k).positiveWitness
  witness_pos := natEnrichedRelaxedOddRole_witness_pos k
  witnessIn := (natEnrichedRelaxedOddRole k).positiveWitness
  witnessOut := (natEnrichedRelaxedOddRole k).positiveWitness
  witnessIn_eq := rfl
  witnessOut_eq := rfl

/--
The arithmetic OOD lock produces the abstract OOD structural certificate.

This is still the lock-level instance: it verifies the candidate
`projectOut/readOut` before any larger ML-facing interpretation is added.
-/
def natEnrichedRelaxedOddOODStructuralCertificate
    (k : Nat) :
    OODStructuralCertificate
      NatEnrichedParityRole
      Nat
      Nat
      Nat
      (NatEnrichedRelaxedOddRole k)
      natEnrichedRelaxedOddOODProjectIn
      natEnrichedRelaxedOddOODProjectOut
      natEnrichedRelaxedOddOODReadIn
      natEnrichedRelaxedOddOODReadOut
      NatEnrichedParityRoleRepair
      natEnrichedRelaxedOddOODWitnessOf :=
  oodStructuralCertificateOfWitnessTransport
    (natEnrichedRelaxedOddOODWitnessTransport k)

/--
The compact positive structural certificate for the arithmetic OOD lock.

This facade keeps the structural obstruction and the positive relaxed witness
on the same recovered cell.
-/
def natEnrichedRelaxedOddOODPositiveStructuralCertificate
    (k : Nat) :
    OODPositiveStructuralCertificate
      NatEnrichedParityRole
      Nat
      Nat
      Nat
      (NatEnrichedRelaxedOddRole k)
      natEnrichedRelaxedOddOODProjectIn
      natEnrichedRelaxedOddOODProjectOut
      natEnrichedRelaxedOddOODReadIn
      natEnrichedRelaxedOddOODReadOut
      NatEnrichedParityRoleRepair :=
  oodPositiveStructuralCertificateOfPositiveWitnessTransport
    (natEnrichedRelaxedOddOODPositiveWitnessTransport k)

/-- The facade carries the positive witness of the relaxed odd source. -/
theorem natEnrichedRelaxedOddOODPositiveStructuralCertificate_witness_eq
    (k : Nat) :
    (natEnrichedRelaxedOddOODPositiveStructuralCertificate k).positiveTransport.witnessOfCell =
      (natEnrichedRelaxedOddRole k).positiveWitness :=
  rfl

/--
The explicit OOD invariant of the arithmetic lock.

It is not the visible shift.  It is the positive witness carried by the
relaxed odd role and transported unchanged across the input and output sides.
-/
def natEnrichedRelaxedOddOODPositiveInvariant
    (k : Nat) :
    OODPositiveInvariant
      NatEnrichedParityRole
      Nat
      Nat
      Nat
      (NatEnrichedRelaxedOddRole k)
      natEnrichedRelaxedOddOODProjectIn
      natEnrichedRelaxedOddOODProjectOut
      natEnrichedRelaxedOddOODReadIn
      natEnrichedRelaxedOddOODReadOut
      NatEnrichedParityRoleRepair :=
  oodPositiveInvariantOfPositiveWitnessTransport
    (natEnrichedRelaxedOddOODPositiveWitnessTransport k)

/-- The arithmetic OOD invariant is exactly the relaxed odd positive witness. -/
theorem natEnrichedRelaxedOddOODPositiveInvariant_eq_positiveWitness
    (k : Nat) :
    (natEnrichedRelaxedOddOODPositiveInvariant k).invariant =
      (natEnrichedRelaxedOddRole k).positiveWitness :=
  rfl

/-- The arithmetic OOD invariant is positive. -/
theorem natEnrichedRelaxedOddOODPositiveInvariant_pos
    (k : Nat) :
    0 < (natEnrichedRelaxedOddOODPositiveInvariant k).invariant :=
  (natEnrichedRelaxedOddOODPositiveInvariant k).invariant_pos

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOODProjectIn
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOODProjectOut
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOOD_sameIn
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOOD_sameOut
#print axioms Meta.EnrichedNatClosedStabilityInstance.nat_two_mul_add_one_lt_three_mul_add_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOOD_visibleShiftOfSource
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOODProjectionShift
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOODRecoveredCell
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOODWitnessTransport
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOODPositiveWitnessTransport
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOODStructuralCertificate
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOODPositiveStructuralCertificate
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOODPositiveStructuralCertificate_witness_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOODPositiveInvariant
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOODPositiveInvariant_eq_positiveWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedRelaxedOddOODPositiveInvariant_pos
/- AXIOM_AUDIT_END -/
