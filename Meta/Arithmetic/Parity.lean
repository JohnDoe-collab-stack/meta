import Meta.Arithmetic.TwoPole
import Meta.Core.Parity
import Meta.Core.OrderGap
import Mathlib.Algebra.Group.Even

/-!
# Arithmetic parity from enriched Nat roles

This file instantiates the abstract dynamic role and parity layers inside the
enriched Nat arithmetic instance.

The construction does not start from classical even/odd labels.  It starts
from the two terminal atoms already carried by the enriched Nat interface:

* `NatTraceAtom.excess k`, read as the closing role;
* `NatTraceAtom.value k`, read as the mediating role.

The classical `2*k` / `2*k+1` reading is recovered only at the end as an
arithmetical code of these two operational roles.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Terminal readings -/

/-- Terminal payload helper with a current candidate. -/
def terminalPayloadWithDefault
    (current : Nat) :
    List Nat -> Nat
  | [] => current
  | payload :: rest => terminalPayloadWithDefault payload rest

/-- Last numeric payload of a finite Nat payload trace. -/
def terminalPayload : List Nat -> Nat
  | [] => 0
  | payload :: rest => terminalPayloadWithDefault payload rest

/-- The helper returns the singleton payload at the end of an extension. -/
theorem terminalPayloadWithDefault_append_singleton
    (current : Nat)
    (pref : List Nat)
    (payload : Nat) :
    terminalPayloadWithDefault current (pref ++ [payload]) = payload := by
  induction pref generalizing current with
  | nil => rfl
  | cons head rest ih =>
      exact ih head

/-- The terminal payload of a singleton extension is that singleton payload. -/
theorem terminalPayload_append_singleton
    (pref : List Nat)
    (payload : Nat) :
    terminalPayload (pref ++ [payload]) = payload := by
  cases pref with
  | nil => rfl
  | cons head rest =>
      exact terminalPayloadWithDefault_append_singleton head rest payload

/-! ## Enriched Nat operational parity roles -/

/--
Operational parity roles internal to enriched Nat.

The index is the shared terminal payload.  The constructors are not classical
even/odd labels: they remember whether the terminal atom is the formed excess
or the payload value shadow.
-/
inductive NatEnrichedParityRole where
  | closingExcess : Nat -> NatEnrichedParityRole
  | mediatingValue : Nat -> NatEnrichedParityRole

/-- Visible role payload: it forgets whether the terminal role was excess or value. -/
def natEnrichedParityRolePayload :
    NatEnrichedParityRole -> Nat
  | NatEnrichedParityRole.closingExcess k => k
  | NatEnrichedParityRole.mediatingValue k => k

/-- Role carried by one terminal trace atom. -/
def roleOfTerminalAtom :
    NatTraceAtom -> NatEnrichedParityRole
  | NatTraceAtom.excess k => NatEnrichedParityRole.closingExcess k
  | NatTraceAtom.value k => NatEnrichedParityRole.mediatingValue k
  | NatTraceAtom.quote k => NatEnrichedParityRole.mediatingValue k
  | NatTraceAtom.marginal k => NatEnrichedParityRole.mediatingValue k
  | NatTraceAtom.global k => NatEnrichedParityRole.mediatingValue k

/-- Terminal role helper with a current terminal atom candidate. -/
def terminalTraceRoleWithDefault
    (current : NatTraceAtom) :
    List NatTraceAtom -> NatEnrichedParityRole
  | [] => roleOfTerminalAtom current
  | atom :: rest => terminalTraceRoleWithDefault atom rest

/-- Terminal role read from the final atom of an enriched Nat trace. -/
def terminalTraceRole : List NatTraceAtom -> NatEnrichedParityRole
  | [] => NatEnrichedParityRole.mediatingValue 0
  | atom :: rest => terminalTraceRoleWithDefault atom rest

/-- The terminal-role helper returns the role of the singleton terminal atom. -/
theorem terminalTraceRoleWithDefault_append_singleton
    (current : NatTraceAtom)
    (pref : List NatTraceAtom)
    (atom : NatTraceAtom) :
    terminalTraceRoleWithDefault current (pref ++ [atom]) =
      roleOfTerminalAtom atom := by
  induction pref generalizing current with
  | nil => rfl
  | cons head rest ih =>
      exact ih head

/-- A trace ending in an excess atom is read as a closing role. -/
theorem terminalTraceRole_append_excess
    (pref : List NatTraceAtom)
    (k : Nat) :
    terminalTraceRole (pref ++ [NatTraceAtom.excess k]) =
      NatEnrichedParityRole.closingExcess k := by
  cases pref with
  | nil => rfl
  | cons head rest =>
      exact terminalTraceRoleWithDefault_append_singleton
        head
        rest
        (NatTraceAtom.excess k)

/-- A trace ending in a value atom is read as a mediating role. -/
theorem terminalTraceRole_append_value
    (pref : List NatTraceAtom)
    (k : Nat) :
    terminalTraceRole (pref ++ [NatTraceAtom.value k]) =
      NatEnrichedParityRole.mediatingValue k := by
  cases pref with
  | nil => rfl
  | cons head rest =>
      exact terminalTraceRoleWithDefault_append_singleton
        head
        rest
        (NatTraceAtom.value k)

/-- Payload projection commutes with one-atom extension. -/
theorem tracePayloads_append_singleton
    (pref : List NatTraceAtom)
    (atom : NatTraceAtom) :
    tracePayloads (pref ++ [atom]) =
      tracePayloads pref ++ [atomPayload atom] := by
  induction pref with
  | nil => rfl
  | cons head rest ih =>
      change
        atomPayload head :: tracePayloads (rest ++ [atom]) =
          atomPayload head :: (tracePayloads rest ++ [atomPayload atom])
      rw [ih]

/-- Payloads of a trace ending in an excess atom have terminal payload `k`. -/
theorem terminalPayload_tracePayloads_append_excess
    (pref : List NatTraceAtom)
    (k : Nat) :
    terminalPayload (tracePayloads (pref ++ [NatTraceAtom.excess k])) = k := by
  rw [tracePayloads_append_singleton]
  exact terminalPayload_append_singleton (tracePayloads pref) k

/-- Payloads of a trace ending in a value atom have terminal payload `k`. -/
theorem terminalPayload_tracePayloads_append_value
    (pref : List NatTraceAtom)
    (k : Nat) :
    terminalPayload (tracePayloads (pref ++ [NatTraceAtom.value k])) = k := by
  rw [tracePayloads_append_singleton]
  exact terminalPayload_append_singleton (tracePayloads pref) k

/-- Closing and mediating roles with the same payload are separated. -/
theorem closingExcess_ne_mediatingValue
    (k : Nat) :
    NatEnrichedParityRole.closingExcess k =
      NatEnrichedParityRole.mediatingValue k -> False := by
  intro h
  cases h

/-! ## Role repair and role two-poles -/

/-- Local repair of an enriched Nat parity role after visible payload contraction. -/
structure NatEnrichedParityRoleRepair
    (role : NatEnrichedParityRole) where
  visible : Nat
  recovered : NatEnrichedParityRole
  visible_eq_projection :
    visible = natEnrichedParityRolePayload role
  recovered_eq_role :
    recovered = role

/-- Intrinsic repair of an enriched Nat parity role. -/
def natEnrichedParityRoleRepair
    (role : NatEnrichedParityRole) :
    NatEnrichedParityRoleRepair role where
  visible := natEnrichedParityRolePayload role
  recovered := role
  visible_eq_projection := rfl
  recovered_eq_role := rfl

/-- The role two-pole generated by a terminal payload. -/
def natEnrichedParityRoleOperationalTwoPole
    (k : Nat) :
    OperationalTwoPole
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload
      NatEnrichedParityRoleRepair where
  formed := NatEnrichedParityRole.closingExcess k
  shadow := NatEnrichedParityRole.mediatingValue k
  sameProjection := rfl
  separated := closingExcess_ne_mediatingValue k
  repair := natEnrichedParityRoleRepair
    (NatEnrichedParityRole.closingExcess k)
  recovered := NatEnrichedParityRole.closingExcess k
  recovered_eq_formed := rfl

/-- The structural role two-pole generated by a terminal payload. -/
def natEnrichedParityRoleStructuralTwoPole
    (k : Nat) :
    StructuralTwoPole
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload :=
  operationalTwoPole_structural
    (natEnrichedParityRoleOperationalTwoPole k)

/-! ## Relaxed bilateral gap before arithmetic coding -/

/--
Role-level relaxed bilateral gap around the mediating role.

This structure is deliberately placed before the arithmetic role code.  It does
not describe the non-relaxed numeric reading of the mediating role.  It keeps
the left role, mediating role, right return role, and produced divergence as
intrinsic enriched-Nat data.
-/
structure NatEnrichedParityRelaxedBilateralGap
    (k : Nat) where
  leftRole : NatEnrichedParityRole
  mediatingRole : NatEnrichedParityRole
  rightPayload : Nat
  rightRole : NatEnrichedParityRole
  leftRole_eq :
    leftRole = NatEnrichedParityRole.closingExcess k
  mediatingRole_eq :
    mediatingRole = NatEnrichedParityRole.mediatingValue k
  rightRole_eq :
    rightRole = NatEnrichedParityRole.closingExcess rightPayload
  same_left_mediating_payload :
    natEnrichedParityRolePayload leftRole =
      natEnrichedParityRolePayload mediatingRole
  separated_left_mediating :
    leftRole = mediatingRole -> False
  divergence : Nat
  right_payload_eq_left_plus_divergence :
    natEnrichedParityRolePayload rightRole =
      natEnrichedParityRolePayload leftRole + divergence
  divergence_pos :
    0 < divergence

/--
The maximal relaxed divergence carried by the general mediating role at index
`k`.  It is not obtained by coding the mediating role as a non-relaxed numeric
odd.  It is the produced gap between the left closing payload and the relaxed
right return payload.

Here `maximal` means maximal non-contraction of the mediating role inside the
enriched Nat parity layer.  It is not an external universal maximum over an
ordered family of possible relaxations.
-/
def natEnrichedParityMaximalRelaxedDivergence
    (k : Nat) :
    Nat :=
  Nat.succ (k + Nat.succ k)

/-- The maximal relaxed divergence is strictly positive. -/
theorem natEnrichedParityMaximalRelaxedDivergence_pos
    (k : Nat) :
    0 < natEnrichedParityMaximalRelaxedDivergence k :=
  Nat.succ_pos (k + Nat.succ k)

/--
The maximal relaxed divergence is a double mediation followed by the two
terminal poles consumed by countdown.
-/
theorem natEnrichedParityMaximalRelaxedDivergence_eq_double_add_two
    (k : Nat) :
    natEnrichedParityMaximalRelaxedDivergence k = (k + k) + 2 := by
  unfold natEnrichedParityMaximalRelaxedDivergence
  rw [Nat.add_succ]

/-! ## Fibrewise structural peak carried by each index -/

/--
The fibrewise structural peak carried by one enriched Nat index.

This is not a trajectory height.  It is the maximal relaxed divergence already
carried by the enriched parity structure at the index.
-/
def natEnrichedParityFibrewiseStructuralPeak
    (k : Nat) :
    Nat :=
  natEnrichedParityMaximalRelaxedDivergence k

/-- The fibrewise structural peak is exactly the maximal relaxed divergence. -/
theorem natEnrichedParityFibrewiseStructuralPeak_eq_maximalDivergence
    (k : Nat) :
    natEnrichedParityFibrewiseStructuralPeak k =
      natEnrichedParityMaximalRelaxedDivergence k :=
  rfl

/-- The fibrewise structural peak is strictly positive for every index. -/
theorem natEnrichedParityFibrewiseStructuralPeak_pos
    (k : Nat) :
    0 < natEnrichedParityFibrewiseStructuralPeak k :=
  natEnrichedParityMaximalRelaxedDivergence_pos k

/-- The fibrewise structural peak is already in countdown-consumable form. -/
theorem natEnrichedParityFibrewiseStructuralPeak_eq_double_add_two
    (k : Nat) :
    natEnrichedParityFibrewiseStructuralPeak k = (k + k) + 2 :=
  natEnrichedParityMaximalRelaxedDivergence_eq_double_add_two k

/-- Right payload obtained by adding the maximal relaxed divergence to the left payload. -/
def natEnrichedParityMaximallyRelaxedRightPayload
    (k : Nat) :
    Nat :=
  k + natEnrichedParityMaximalRelaxedDivergence k

/--
The intrinsic maximally relaxed bilateral gap of enriched Nat.

Unlike `NatEnrichedParityBilateralGap`, this construction does not pass through
the arithmetic role code.  The mediating role is kept as an enriched role, and
the right return is separated by the produced maximal relaxed divergence.
-/
def natEnrichedParityMaximallyRelaxedBilateralGap
    (k : Nat) :
    NatEnrichedParityRelaxedBilateralGap k where
  leftRole := NatEnrichedParityRole.closingExcess k
  mediatingRole := NatEnrichedParityRole.mediatingValue k
  rightPayload := natEnrichedParityMaximallyRelaxedRightPayload k
  rightRole :=
    NatEnrichedParityRole.closingExcess
      (natEnrichedParityMaximallyRelaxedRightPayload k)
  leftRole_eq := rfl
  mediatingRole_eq := rfl
  rightRole_eq := rfl
  same_left_mediating_payload := rfl
  separated_left_mediating := closingExcess_ne_mediatingValue k
  divergence := natEnrichedParityMaximalRelaxedDivergence k
  right_payload_eq_left_plus_divergence := rfl
  divergence_pos := natEnrichedParityMaximalRelaxedDivergence_pos k

/-- A relaxed bilateral gap carries a core diagonal certificate. -/
def natEnrichedParityRelaxedDiagonalCertificate
    {k : Nat}
    (gap : NatEnrichedParityRelaxedBilateralGap k) :
    DiagonalCertificate
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload where
  left := gap.leftRole
  right := gap.mediatingRole
  sameProjection := gap.same_left_mediating_payload
  separatedInterface := gap.separated_left_mediating

/-- A relaxed bilateral gap therefore yields the corresponding projection obstruction. -/
def natEnrichedParityRelaxedProjectionObstruction
    {k : Nat}
    (gap : NatEnrichedParityRelaxedBilateralGap k) :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload :=
  projectionObstructionOfDiagonalCertificate
    (natEnrichedParityRelaxedDiagonalCertificate gap)

/-- The maximally relaxed gap realizes exactly the maximal relaxed divergence. -/
theorem natEnrichedParityMaximallyRelaxedBilateralGap_divergence_eq_maximal
    (k : Nat) :
    (natEnrichedParityMaximallyRelaxedBilateralGap k).divergence =
      natEnrichedParityMaximalRelaxedDivergence k :=
  rfl

/-- The maximally relaxed gap carries the core diagonal certificate. -/
def natEnrichedParityMaximallyRelaxedDiagonalCertificate
    (k : Nat) :
    DiagonalCertificate
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload :=
  natEnrichedParityRelaxedDiagonalCertificate
    (natEnrichedParityMaximallyRelaxedBilateralGap k)

/-- The maximally relaxed gap carries the corresponding projection obstruction. -/
def natEnrichedParityMaximallyRelaxedProjectionObstruction
    (k : Nat) :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload :=
  natEnrichedParityRelaxedProjectionObstruction
    (natEnrichedParityMaximallyRelaxedBilateralGap k)

/--
Positive internal diagonal witness generated by a relaxed bilateral gap.

The witness is not a generic Nat diagonal applied after the fact.  It carries
the core diagonal certificate of the relaxed mediating configuration and the
positive divergence produced by that same configuration.
-/
structure NatEnrichedParityPositiveInternalDiagonalWitness
    (k : Nat) where
  relaxedGap : NatEnrichedParityRelaxedBilateralGap k
  diagonalCertificate :
    DiagonalCertificate
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload
  diagonal_left_eq :
    diagonalCertificate.left = relaxedGap.leftRole
  diagonal_right_eq :
    diagonalCertificate.right = relaxedGap.mediatingRole
  projectionObstruction :
    ProjectionObstruction
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload
  witness : Nat
  witness_eq_divergence :
    witness = relaxedGap.divergence
  witness_pos :
    0 < witness
  witness_eq_maximal :
    witness = natEnrichedParityMaximalRelaxedDivergence k

/-- The maximally relaxed bilateral gap produces the positive internal diagonal witness. -/
def natEnrichedParityPositiveInternalDiagonalWitnessOfMaximallyRelaxedGap
    (k : Nat) :
    NatEnrichedParityPositiveInternalDiagonalWitness k where
  relaxedGap := natEnrichedParityMaximallyRelaxedBilateralGap k
  diagonalCertificate :=
    natEnrichedParityMaximallyRelaxedDiagonalCertificate k
  diagonal_left_eq := rfl
  diagonal_right_eq := rfl
  projectionObstruction :=
    natEnrichedParityMaximallyRelaxedProjectionObstruction k
  witness := natEnrichedParityMaximalRelaxedDivergence k
  witness_eq_divergence := rfl
  witness_pos := natEnrichedParityMaximalRelaxedDivergence_pos k
  witness_eq_maximal := rfl

/--
The positive internal diagonal witness carried by the fibrewise structural peak
at one enriched Nat index.
-/
def natEnrichedParityFibrewiseStructuralPeakWitness
    (k : Nat) :
    NatEnrichedParityPositiveInternalDiagonalWitness k :=
  natEnrichedParityPositiveInternalDiagonalWitnessOfMaximallyRelaxedGap k

/-- The witness value of the peak witness is the fibrewise structural peak. -/
theorem natEnrichedParityFibrewiseStructuralPeakWitness_witness_eq_peak
    (k : Nat) :
    (natEnrichedParityFibrewiseStructuralPeakWitness k).witness =
      natEnrichedParityFibrewiseStructuralPeak k :=
  rfl

/-- The peak witness certifies a positive value. -/
theorem natEnrichedParityFibrewiseStructuralPeakWitness_witness_pos
    (k : Nat) :
    0 < (natEnrichedParityFibrewiseStructuralPeakWitness k).witness :=
  (natEnrichedParityFibrewiseStructuralPeakWitness k).witness_pos

/-! ## Arithmetic dynamic return from an exact intersection -/

/-- Exact arithmetic dynamic source attached to one primitive intersection. -/
abbrev ArithmeticIntersectionSource
    (branch : MemoryBranch) :=
  PLift (PrimitiveMemoryReadingIntersection branch)

/-- A primitive intersection is a formed dynamic return. -/
def arithmeticFormedDynamicReturnOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    FormedDynamicReturn
      bidirectionalCompleteness
      branch
      (ArithmeticIntersectionSource branch) where
  source := ⟨intersection⟩
  intersection := intersection

/--
Temporal provenance of the formed excess carried by an exact arithmetic
intersection.
-/
def arithmeticTemporalExcessOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    TemporalExcessDynamicReturn
      bidirectionalCompleteness
      branch
      (ArithmeticIntersectionSource branch)
      (arithmeticFormedDynamicReturnOfIntersection intersection)
      Nat
      Nat where
  terminalTimeOf := fun source =>
    terminalTimeOfIntersection source.down
  formedExcessOf := fun inter =>
    formedPositiveExcessOfIntersection inter
  advance := fun time => time + 1
  formedExcess_eq_advance_terminalTime := rfl

/-- Interface witness carried by the formed trace of an intersection. -/
def arithmeticInterfaceWitnessOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    InterfaceWitness (List NatTraceAtom) NatInterfaceWitness where
  interface := formedTraceOfIntersection intersection
  witness :=
    { payload := tracePayloads (formedTraceOfIntersection intersection)
      payload_eq := rfl }

/-- The strong cycle of an intersection realizes its formed trace. -/
def arithmeticInterfaceRealizationOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatInterfaceRealization
      (strongTerminalCycleFromIntersection
        bidirectionalCompleteness
        enrichedNatRoundTripCoherence
        intersection)
      (formedTraceOfIntersection intersection) where
  interface_eq_formedTrace := rfl

/-- A primitive intersection gives the locally recovered dynamic return. -/
def arithmeticLocallyRecoveredDynamicReturnOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    LocallyRecoveredDynamicReturn
      bidirectionalCompleteness
      enrichedNatRoundTripCoherence
      branch
      (ArithmeticIntersectionSource branch)
      (List NatTraceAtom)
      NatInterfaceWitness
      NatInterfaceRealization
      (List Nat)
      tracePayloads
      NatInterfaceRepair where
  formedReturn := arithmeticFormedDynamicReturnOfIntersection intersection
  formed := arithmeticInterfaceWitnessOfIntersection intersection
  realizes := arithmeticInterfaceRealizationOfIntersection intersection
  localRecovery := localProjectiveRecoveryOfIntersection intersection
  localRecovery_sameInterface := rfl

/-! ## Terminal role facts for exact intersections -/

/-- The formed trace of an intersection reads as the closing excess role. -/
theorem terminalTraceRole_formedTraceOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    terminalTraceRole (formedTraceOfIntersection intersection) =
      NatEnrichedParityRole.closingExcess
        (formedPositiveExcessOfIntersection intersection) := by
  unfold formedTraceOfIntersection
  exact terminalTraceRole_append_excess
    intersection.forward.trace
    (formedPositiveExcessOfIntersection intersection)

/-- The payload-only shadow of an intersection reads as the mediating value role. -/
theorem terminalTraceRole_payloadOnlyTraceOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    terminalTraceRole (payloadOnlyTraceOfIntersection intersection) =
      NatEnrichedParityRole.mediatingValue
        (formedPositiveExcessOfIntersection intersection) := by
  unfold payloadOnlyTraceOfIntersection
  exact terminalTraceRole_append_value
    intersection.forward.trace
    (formedPositiveExcessOfIntersection intersection)

/-- The formed trace has the expected terminal visible role payload. -/
theorem terminalPayload_formedTraceOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    terminalPayload (tracePayloads (formedTraceOfIntersection intersection)) =
      formedPositiveExcessOfIntersection intersection := by
  unfold formedTraceOfIntersection
  exact terminalPayload_tracePayloads_append_excess
    intersection.forward.trace
    (formedPositiveExcessOfIntersection intersection)

/-- The payload-only shadow has the expected terminal visible role payload. -/
theorem terminalPayload_payloadOnlyTraceOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    terminalPayload
        (tracePayloads (payloadOnlyTraceOfIntersection intersection)) =
      formedPositiveExcessOfIntersection intersection := by
  unfold payloadOnlyTraceOfIntersection
  exact terminalPayload_tracePayloads_append_value
    intersection.forward.trace
    (formedPositiveExcessOfIntersection intersection)

/-! ## Dynamic role carrier over enriched Nat -/

/-- The enriched Nat dynamic role carrier of one exact intersection. -/
def arithmeticDynamicRoleCarrierOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    DynamicRoleCarrier
      (arithmeticLocallyRecoveredDynamicReturnOfIntersection intersection)
      NatEnrichedParityRole
      Nat
      natEnrichedParityRolePayload
      NatEnrichedParityRoleRepair where
  roleOf := terminalTraceRole
  visibleRoleOf := terminalPayload
  roleTwoPole :=
    natEnrichedParityRoleOperationalTwoPole
      (formedPositiveExcessOfIntersection intersection)
  formed_role :=
    terminalTraceRole_formedTraceOfIntersection intersection
  shadow_role :=
    terminalTraceRole_payloadOnlyTraceOfIntersection intersection
  formed_visible := by
    change
      terminalPayload (tracePayloads (formedTraceOfIntersection intersection)) =
        natEnrichedParityRolePayload
          (terminalTraceRole (formedTraceOfIntersection intersection))
    calc
      terminalPayload (tracePayloads (formedTraceOfIntersection intersection)) =
          formedPositiveExcessOfIntersection intersection :=
        terminalPayload_formedTraceOfIntersection intersection
      _ =
          natEnrichedParityRolePayload
            (terminalTraceRole (formedTraceOfIntersection intersection)) := by
        rw [terminalTraceRole_formedTraceOfIntersection intersection]
        rfl
  shadow_visible := by
    change
      terminalPayload
          (tracePayloads (payloadOnlyTraceOfIntersection intersection)) =
        natEnrichedParityRolePayload
          (terminalTraceRole (payloadOnlyTraceOfIntersection intersection))
    calc
      terminalPayload
          (tracePayloads (payloadOnlyTraceOfIntersection intersection)) =
          formedPositiveExcessOfIntersection intersection :=
        terminalPayload_payloadOnlyTraceOfIntersection intersection
      _ =
          natEnrichedParityRolePayload
            (terminalTraceRole
              (payloadOnlyTraceOfIntersection intersection)) := by
        rw [terminalTraceRole_payloadOnlyTraceOfIntersection intersection]
        rfl

/-- Mediated dynamic roles extracted from the arithmetic role carrier. -/
def arithmeticMediatedDynamicRolesOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    MediatedDynamicRoles
      (arithmeticDynamicRoleCarrierOfIntersection intersection) :=
  mediatedDynamicRolesOfCarrier
    (arithmeticDynamicRoleCarrierOfIntersection intersection)

/-! ## Raccord to the minimal parity separation -/

/-- Read an enriched Nat role as a minimal parity regime. -/
def parityRegimeOfNatRole :
    NatEnrichedParityRole -> ParityRegime
  | NatEnrichedParityRole.closingExcess _ => ParityRegime.left
  | NatEnrichedParityRole.mediatingValue _ => ParityRegime.right

/-- Read an enriched Nat interface as a minimal parity regime. -/
def parityRegimeOfNatInterface
    (interface : List NatTraceAtom) :
    ParityRegime :=
  parityRegimeOfNatRole (terminalTraceRole interface)

/-- The visible parity reading of every payload trace is the contracted visible. -/
def parityVisibleOfPayload
    (_visible : List Nat) :
    ParityVisible :=
  ParityVisible.contracted

/-- The formed intersection interface reads as the left parity regime. -/
theorem parityRegimeOfNatInterface_formed
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    parityRegimeOfNatInterface (formedTraceOfIntersection intersection) =
      ParityRegime.left := by
  unfold parityRegimeOfNatInterface parityRegimeOfNatRole
  rw [terminalTraceRole_formedTraceOfIntersection intersection]

/-- The payload-only shadow reads as the right parity regime. -/
theorem parityRegimeOfNatInterface_shadow
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    parityRegimeOfNatInterface (payloadOnlyTraceOfIntersection intersection) =
      ParityRegime.right := by
  unfold parityRegimeOfNatInterface parityRegimeOfNatRole
  rw [terminalTraceRole_payloadOnlyTraceOfIntersection intersection]

/-- Exact arithmetic dynamic parity separation attached to one intersection. -/
def arithmeticDynamicParitySeparationOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    DynamicParitySeparation
      (arithmeticLocallyRecoveredDynamicReturnOfIntersection intersection) :=
  dynamicParitySeparation_leftRight
    (arithmeticLocallyRecoveredDynamicReturnOfIntersection intersection)
    parityRegimeOfNatInterface
    parityVisibleOfPayload
    (parityRegimeOfNatInterface_formed intersection)
    (parityRegimeOfNatInterface_shadow intersection)
    rfl
    rfl

/-- Operational parity roles extracted from the arithmetic parity separation. -/
def arithmeticOperationalParityRolesOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    OperationalParityRoles
      (arithmeticDynamicParitySeparationOfIntersection intersection) :=
  operationalParityRolesOfDynamicParitySeparation
    (arithmeticDynamicParitySeparationOfIntersection intersection)

/-- The arithmetic closing parity regime is the left regime. -/
theorem arithmeticOperationalParityRoles_closing_left
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    operationalParityRoles_closingRegime
        (arithmeticOperationalParityRolesOfIntersection intersection) =
      ParityRegime.left :=
  parityRegimeOfNatInterface_formed intersection

/-- The arithmetic mediating parity regime is the right regime. -/
theorem arithmeticOperationalParityRoles_mediating_right
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    operationalParityRoles_mediatingRegime
        (arithmeticOperationalParityRolesOfIntersection intersection) =
      ParityRegime.right :=
  parityRegimeOfNatInterface_shadow intersection

/-! ## Arithmetic visible order test -/

/-- Equality preorder on arithmetic visible payloads. -/
def arithmeticVisiblePreorder :
    VisiblePreorder ArithmeticVisiblePayload where
  le := fun left right => left = right
  refl := by
    intro visible
    rfl
  trans := by
    intro left middle right hLeft hRight
    exact Eq.trans hLeft hRight

/-- Equality partial order on arithmetic visible payloads. -/
def arithmeticVisiblePartialOrder :
    VisiblePartialOrder ArithmeticVisiblePayload where
  le := arithmeticVisiblePreorder.le
  refl := arithmeticVisiblePreorder.refl
  trans := arithmeticVisiblePreorder.trans
  antisymm := by
    intro left _right hLeft _hRight
    exact hLeft

/-- The ordered visible test sees equality of the arithmetic dynamic row projections. -/
theorem arithmeticDynamicRow_visible_eq
    (row : ArithmeticDynamicGapRow) :
    arithmeticPayloadProjection (arithmeticDynamicRow_leftPole row) =
      arithmeticPayloadProjection (arithmeticDynamicRow_rightPole row) :=
  operationalGap_visible_eq_of_partialOrder
    arithmeticVisiblePartialOrder
    (arithmeticDynamicRowOperationalGap row)

/-- The ordered visible test does not identify the enriched arithmetic poles. -/
theorem arithmeticDynamicRow_visible_eq_not_interface_eq
    (row : ArithmeticDynamicGapRow) :
    And
      (arithmeticPayloadProjection (arithmeticDynamicRow_leftPole row) =
        arithmeticPayloadProjection (arithmeticDynamicRow_rightPole row))
      (arithmeticDynamicRow_leftPole row =
        arithmeticDynamicRow_rightPole row -> False) :=
  operationalGap_partialOrder_visible_eq_not_interface_eq
    arithmeticVisiblePartialOrder
    (arithmeticDynamicRowOperationalGap row)

/-- The arithmetic dynamic row refutes the ordered short reading. -/
theorem arithmeticDynamicRow_not_orderContractive
    (row : ArithmeticDynamicGapRow)
    (contractive :
      OrderContractiveProjection
        ArithmeticEnrichedInterface
        ArithmeticVisiblePayload
        arithmeticPayloadProjection
        arithmeticVisiblePreorder) :
    False :=
  operationalGap_not_orderContractive
    (arithmeticDynamicRowOperationalGap row)
    contractive

/-! ## Classical even/odd code recovered from operational roles -/

/-- Classical evenness as an existential `2*k` code. -/
def EvenClassical (n : Nat) : Prop :=
  Exists (fun k : Nat => n = 2 * k)

/-- Classical oddness as an existential `2*k+1` code. -/
def OddClassical (n : Nat) : Prop :=
  Exists (fun k : Nat => n = 2 * k + 1)

/-- Arithmetic code of an enriched Nat operational parity role. -/
def natEnrichedParityRoleCode :
    NatEnrichedParityRole -> Nat
  | NatEnrichedParityRole.closingExcess k => 2 * k
  | NatEnrichedParityRole.mediatingValue k => 2 * k + 1

/--
The maximal relaxed divergence is statically incompatible with the non-relaxed
mediating code at the same index.

This theorem does not define the relaxed divergence by the non-relaxed code. It
only records, after the code has been introduced, that the relaxed maximal
divergence cannot collapse to that code.
-/
theorem natEnrichedParityMaximalRelaxedDivergence_ne_nonrelaxedMediatingCode
    (k : Nat) :
    natEnrichedParityMaximalRelaxedDivergence k ≠
      natEnrichedParityRoleCode (NatEnrichedParityRole.mediatingValue k) := by
  intro h
  have hcode :
      natEnrichedParityRoleCode (NatEnrichedParityRole.mediatingValue k) =
        k + Nat.succ k := by
    unfold natEnrichedParityRoleCode
    calc
      2 * k + 1 = k + k + 1 := by
        rw [Nat.two_mul]
      _ = k + Nat.succ k :=
        Eq.symm (Nat.add_succ k k)
  have hsucc :
      Nat.succ (k + Nat.succ k) = k + Nat.succ k := by
    unfold natEnrichedParityMaximalRelaxedDivergence at h
    rw [hcode] at h
    exact h
  exact Nat.succ_ne_self (k + Nat.succ k) hsucc

/-! ## Bilateral arithmetic gap around the mediating role -/

/-- The mediating role is one arithmetic step after the closing role at the same index. -/
theorem natEnrichedParityRoleCode_leftAdjacency
    (k : Nat) :
    natEnrichedParityRoleCode
        (NatEnrichedParityRole.mediatingValue k) =
      natEnrichedParityRoleCode
        (NatEnrichedParityRole.closingExcess k) + 1 :=
  rfl

/--
The next closing role is one arithmetic step after the mediating role.

This is kept as a separate theorem from left adjacency: the two sides are not
identified as a single symmetric fact.
-/
theorem natEnrichedParityRoleCode_rightAdjacency
    (k : Nat) :
    natEnrichedParityRoleCode
        (NatEnrichedParityRole.closingExcess (k + 1)) =
      natEnrichedParityRoleCode
        (NatEnrichedParityRole.mediatingValue k) + 1 := by
  change 2 * (k + 1) = (2 * k + 1) + 1
  rw [Nat.mul_add, Nat.mul_one]

/--
Bilateral arithmetic gap around one mediating role.

The left and right steps are stored independently.  The structure deliberately
does not contain a field identifying them, so later instances can relax one
side without changing the other.
-/
structure NatEnrichedParityBilateralGap
    (k : Nat) where
  leftStep : Nat
  rightStep : Nat
  mediating_from_left :
    natEnrichedParityRoleCode
        (NatEnrichedParityRole.mediatingValue k) =
      natEnrichedParityRoleCode
        (NatEnrichedParityRole.closingExcess k) + leftStep
  closing_from_right :
    natEnrichedParityRoleCode
        (NatEnrichedParityRole.closingExcess (k + 1)) =
      natEnrichedParityRoleCode
        (NatEnrichedParityRole.mediatingValue k) + rightStep

/--
The classical enriched-Nat bilateral gap has unit steps on both sides, without
collapsing the two step fields into one symmetric datum.
-/
def natEnrichedParityClassicalBilateralGap
    (k : Nat) :
    NatEnrichedParityBilateralGap k where
  leftStep := 1
  rightStep := 1
  mediating_from_left := natEnrichedParityRoleCode_leftAdjacency k
  closing_from_right := natEnrichedParityRoleCode_rightAdjacency k

/-- The left step of the classical enriched-Nat bilateral gap is `1`. -/
theorem natEnrichedParityClassicalBilateralGap_leftStep_eq_one
    (k : Nat) :
    (natEnrichedParityClassicalBilateralGap k).leftStep = 1 :=
  rfl

/-- The right step of the classical enriched-Nat bilateral gap is `1`. -/
theorem natEnrichedParityClassicalBilateralGap_rightStep_eq_one
    (k : Nat) :
    (natEnrichedParityClassicalBilateralGap k).rightStep = 1 :=
  rfl

/-- Closing roles code as classical even numbers. -/
theorem closingExcess_code_even
    (k : Nat) :
    EvenClassical
      (natEnrichedParityRoleCode
        (NatEnrichedParityRole.closingExcess k)) :=
  Exists.intro k rfl

/-- Mediating roles code as classical odd numbers. -/
theorem mediatingValue_code_odd
    (k : Nat) :
    OddClassical
      (natEnrichedParityRoleCode
        (NatEnrichedParityRole.mediatingValue k)) :=
  Exists.intro k rfl

/-- Numbers coded by closing roles are exactly classical even numbers. -/
def IsClosingCode (n : Nat) : Prop :=
  Exists (fun k : Nat =>
    n =
      natEnrichedParityRoleCode
        (NatEnrichedParityRole.closingExcess k))

/-- Numbers coded by mediating roles are exactly classical odd numbers. -/
def IsMediatingCode (n : Nat) : Prop :=
  Exists (fun k : Nat =>
    n =
      natEnrichedParityRoleCode
        (NatEnrichedParityRole.mediatingValue k))

/-- Closing-role codes are equivalent to the classical even definition. -/
theorem isClosingCode_iff_evenClassical
    (n : Nat) :
    IsClosingCode n <-> EvenClassical n :=
  Iff.rfl

/-- Mediating-role codes are equivalent to the classical odd definition. -/
theorem isMediatingCode_iff_oddClassical
    (n : Nat) :
    IsMediatingCode n <-> OddClassical n :=
  Iff.rfl

/-! ## Raccord with Mathlib parity -/

/-- The local classical even predicate is Mathlib's `Even` predicate on `Nat`. -/
theorem evenClassical_iff_mathlib_even
    (n : Nat) :
    EvenClassical n <-> Even n := by
  constructor
  · intro h
    rcases h with ⟨k, hk⟩
    exact ⟨k, by rw [hk, Nat.two_mul]⟩
  · intro h
    rcases h with ⟨k, hk⟩
    exact ⟨k, by rw [hk, Nat.two_mul]⟩

/-- Closing-role codes are exactly Mathlib-even numbers. -/
theorem isClosingCode_iff_mathlib_even
    (n : Nat) :
    IsClosingCode n <-> Even n :=
  Iff.trans
    (isClosingCode_iff_evenClassical n)
    (evenClassical_iff_mathlib_even n)

/-! ## Dynamic intersection codes as standard parity -/

/-- Closing role extracted from the dynamic role carrier of an exact intersection. -/
def arithmeticClosingRoleOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatEnrichedParityRole :=
  mediatedDynamicRoles_closingRole
    (arithmeticMediatedDynamicRolesOfIntersection intersection)

/-- Mediating role extracted from the dynamic role carrier of an exact intersection. -/
def arithmeticMediatingRoleOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatEnrichedParityRole :=
  mediatedDynamicRoles_mediatingRole
    (arithmeticMediatedDynamicRolesOfIntersection intersection)

/-- The extracted closing role is the terminal excess role. -/
theorem arithmeticClosingRoleOfIntersection_eq
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingRoleOfIntersection intersection =
      NatEnrichedParityRole.closingExcess
        (formedPositiveExcessOfIntersection intersection) := by
  change
    terminalTraceRole (formedTraceOfIntersection intersection) =
      NatEnrichedParityRole.closingExcess
        (formedPositiveExcessOfIntersection intersection)
  exact terminalTraceRole_formedTraceOfIntersection intersection

/-- The extracted mediating role is the terminal value role. -/
theorem arithmeticMediatingRoleOfIntersection_eq
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticMediatingRoleOfIntersection intersection =
      NatEnrichedParityRole.mediatingValue
        (formedPositiveExcessOfIntersection intersection) := by
  change
    terminalTraceRole (payloadOnlyTraceOfIntersection intersection) =
      NatEnrichedParityRole.mediatingValue
        (formedPositiveExcessOfIntersection intersection)
  exact terminalTraceRole_payloadOnlyTraceOfIntersection intersection

/-- The extracted closing role is indexed by the successor of the terminal time. -/
theorem arithmeticClosingRoleOfIntersection_eq_terminalTime_succ
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingRoleOfIntersection intersection =
      NatEnrichedParityRole.closingExcess
        (terminalTimeOfIntersection intersection + 1) := by
  rw [arithmeticClosingRoleOfIntersection_eq]
  rfl

/-- The extracted mediating role is indexed by the successor of the terminal time. -/
theorem arithmeticMediatingRoleOfIntersection_eq_terminalTime_succ
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticMediatingRoleOfIntersection intersection =
      NatEnrichedParityRole.mediatingValue
        (terminalTimeOfIntersection intersection + 1) := by
  rw [arithmeticMediatingRoleOfIntersection_eq]
  rfl

/-- Arithmetic code of the closing role extracted from one exact dynamic gap. -/
def arithmeticClosingCodeOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Nat :=
  natEnrichedParityRoleCode
    (arithmeticClosingRoleOfIntersection intersection)

/-- Arithmetic code of the mediating role extracted from one exact dynamic gap. -/
def arithmeticMediatingCodeOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Nat :=
  natEnrichedParityRoleCode
    (arithmeticMediatingRoleOfIntersection intersection)

/-- The closing code extracted from the dynamic gap is `2*k`. -/
theorem arithmeticClosingCodeOfIntersection_eq
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticClosingCodeOfIntersection intersection =
      2 * formedPositiveExcessOfIntersection intersection := by
  unfold arithmeticClosingCodeOfIntersection
  rw [arithmeticClosingRoleOfIntersection_eq intersection]
  rfl

/-- The mediating code extracted from the dynamic gap is `2*k+1`. -/
theorem arithmeticMediatingCodeOfIntersection_eq
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    arithmeticMediatingCodeOfIntersection intersection =
      2 * formedPositiveExcessOfIntersection intersection + 1 := by
  unfold arithmeticMediatingCodeOfIntersection
  rw [arithmeticMediatingRoleOfIntersection_eq intersection]
  rfl

/--
The bilateral arithmetic gap carried by the dynamic intersection at its formed
positive excess.
-/
def arithmeticBilateralGapOfIntersection
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    NatEnrichedParityBilateralGap
      (formedPositiveExcessOfIntersection intersection) :=
  natEnrichedParityClassicalBilateralGap
    (formedPositiveExcessOfIntersection intersection)

/-- The left step of the intersection bilateral gap is `1`. -/
theorem arithmeticBilateralGapOfIntersection_leftStep_eq_one
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (arithmeticBilateralGapOfIntersection intersection).leftStep = 1 :=
  rfl

/-- The right step of the intersection bilateral gap is `1`. -/
theorem arithmeticBilateralGapOfIntersection_rightStep_eq_one
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    (arithmeticBilateralGapOfIntersection intersection).rightStep = 1 :=
  rfl

/-- The closing code extracted from the dynamic gap is Mathlib-even. -/
theorem arithmeticClosingCodeOfIntersection_even
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    Even (arithmeticClosingCodeOfIntersection intersection) := by
  rw [arithmeticClosingCodeOfIntersection_eq intersection]
  exact
    Exists.intro
      (formedPositiveExcessOfIntersection intersection)
      (by rw [Nat.two_mul])

/-- The mediating code extracted from the dynamic gap is constructively odd. -/
theorem arithmeticMediatingCodeOfIntersection_oddClassical
    {branch : MemoryBranch}
    (intersection : PrimitiveMemoryReadingIntersection branch) :
    OddClassical (arithmeticMediatingCodeOfIntersection intersection) := by
  rw [arithmeticMediatingCodeOfIntersection_eq intersection]
  exact
    Exists.intro
      (formedPositiveExcessOfIntersection intersection)
      rfl

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.terminalPayload
#print axioms Meta.EnrichedNatClosedStabilityInstance.terminalPayloadWithDefault
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedParityRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityRolePayload
#print axioms Meta.EnrichedNatClosedStabilityInstance.roleOfTerminalAtom
#print axioms Meta.EnrichedNatClosedStabilityInstance.terminalTraceRole
#print axioms Meta.EnrichedNatClosedStabilityInstance.terminalTraceRoleWithDefault
#print axioms Meta.EnrichedNatClosedStabilityInstance.terminalTraceRole_append_excess
#print axioms Meta.EnrichedNatClosedStabilityInstance.terminalTraceRole_append_value
#print axioms Meta.EnrichedNatClosedStabilityInstance.closingExcess_ne_mediatingValue
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedParityRoleRepair
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityRoleOperationalTwoPole
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedParityRelaxedBilateralGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMaximalRelaxedDivergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMaximalRelaxedDivergence_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMaximalRelaxedDivergence_eq_double_add_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityFibrewiseStructuralPeak
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityFibrewiseStructuralPeak_eq_maximalDivergence
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityFibrewiseStructuralPeak_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityFibrewiseStructuralPeak_eq_double_add_two
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMaximallyRelaxedRightPayload
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMaximallyRelaxedBilateralGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityRelaxedDiagonalCertificate
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityRelaxedProjectionObstruction
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMaximallyRelaxedBilateralGap_divergence_eq_maximal
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMaximallyRelaxedDiagonalCertificate
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMaximallyRelaxedProjectionObstruction
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedParityPositiveInternalDiagonalWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityPositiveInternalDiagonalWitnessOfMaximallyRelaxedGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityFibrewiseStructuralPeakWitness
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityFibrewiseStructuralPeakWitness_witness_eq_peak
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityFibrewiseStructuralPeakWitness_witness_pos
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticFormedDynamicReturnOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticTemporalExcessOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticLocallyRecoveredDynamicReturnOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.terminalTraceRole_formedTraceOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.terminalTraceRole_payloadOnlyTraceOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRoleCarrierOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticMediatedDynamicRolesOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.parityRegimeOfNatInterface
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicParitySeparationOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticOperationalParityRolesOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticVisiblePartialOrder
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_visible_eq_not_interface_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticDynamicRow_not_orderContractive
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityRoleCode
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityMaximalRelaxedDivergence_ne_nonrelaxedMediatingCode
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityRoleCode_leftAdjacency
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityRoleCode_rightAdjacency
#print axioms Meta.EnrichedNatClosedStabilityInstance.NatEnrichedParityBilateralGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityClassicalBilateralGap
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityClassicalBilateralGap_leftStep_eq_one
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityClassicalBilateralGap_rightStep_eq_one
#print axioms Meta.EnrichedNatClosedStabilityInstance.closingExcess_code_even
#print axioms Meta.EnrichedNatClosedStabilityInstance.mediatingValue_code_odd
#print axioms Meta.EnrichedNatClosedStabilityInstance.isClosingCode_iff_evenClassical
#print axioms Meta.EnrichedNatClosedStabilityInstance.isMediatingCode_iff_oddClassical
#print axioms Meta.EnrichedNatClosedStabilityInstance.evenClassical_iff_mathlib_even
#print axioms Meta.EnrichedNatClosedStabilityInstance.isClosingCode_iff_mathlib_even
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticClosingRoleOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticMediatingRoleOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticClosingRoleOfIntersection_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticMediatingRoleOfIntersection_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticClosingRoleOfIntersection_eq_terminalTime_succ
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticMediatingRoleOfIntersection_eq_terminalTime_succ
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticClosingCodeOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticMediatingCodeOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticClosingCodeOfIntersection_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticMediatingCodeOfIntersection_eq
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticBilateralGapOfIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticBilateralGapOfIntersection_leftStep_eq_one
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticBilateralGapOfIntersection_rightStep_eq_one
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticClosingCodeOfIntersection_even
#print axioms Meta.EnrichedNatClosedStabilityInstance.arithmeticMediatingCodeOfIntersection_oddClassical
/- AXIOM_AUDIT_END -/
