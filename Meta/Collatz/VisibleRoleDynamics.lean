import Meta.Arithmetic.Canonical
import Meta.Collatz.InternalTerminality
import Meta.Collatz.RelaxedOddActionBridge

/-!
# Collatz visible role dynamics

This file is the visible-entry producer for the Collatz layer.

It starts from a visible natural value, computes its enriched parity role, and
then performs the internal case analysis carried by the framework:

* closing role;
* terminal visible one, i.e. `mediatingValue 0`;
* non-terminal mediating role, which produces a formed intersection, a relaxed
  odd activation, and the canonical dynamic closure loop.

No external parity test, height, window, or terminal bridge is used.
-/

namespace Meta
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-! ## Visible values read as enriched parity roles -/

/-- Total enriched role read from a visible natural value. -/
def natEnrichedParityRoleOfVisible :
    Nat -> NatEnrichedParityRole
  | 0 => NatEnrichedParityRole.closingExcess 0
  | 1 => NatEnrichedParityRole.mediatingValue 0
  | Nat.succ (Nat.succ n) =>
      match natEnrichedParityRoleOfVisible n with
      | NatEnrichedParityRole.closingExcess k =>
          NatEnrichedParityRole.closingExcess (k + 1)
      | NatEnrichedParityRole.mediatingValue k =>
          NatEnrichedParityRole.mediatingValue (k + 1)

/-- Arithmetic code step for the next closing role. -/
theorem natEnrichedParityRoleCode_closing_succ
    (k : Nat) :
    2 * (k + 1) = Nat.succ (Nat.succ (2 * k)) := by
  rw [Nat.mul_add]

/-- Arithmetic code step for the next mediating role. -/
theorem natEnrichedParityRoleCode_mediating_succ
    (k : Nat) :
    2 * (k + 1) + 1 =
      Nat.succ (Nat.succ (2 * k + 1)) := by
  rw [Nat.mul_add]

/--
The role computed from a visible natural value codes back to that same visible
value.
-/
theorem natEnrichedParityRoleOfVisible_code :
    (visible : Nat) ->
    natEnrichedParityRoleCode
      (natEnrichedParityRoleOfVisible visible) = visible
  | 0 => rfl
  | 1 => rfl
  | Nat.succ (Nat.succ n) => by
      have ih := natEnrichedParityRoleOfVisible_code n
      cases hrole : natEnrichedParityRoleOfVisible n with
      | closingExcess k =>
          rw [hrole] at ih
          change 2 * k = n at ih
          calc
            natEnrichedParityRoleCode
                (natEnrichedParityRoleOfVisible (Nat.succ (Nat.succ n))) =
                2 * (k + 1) := by
                  rw [natEnrichedParityRoleOfVisible, hrole]
                  rfl
            _ = Nat.succ (Nat.succ (2 * k)) :=
                  natEnrichedParityRoleCode_closing_succ k
            _ = Nat.succ (Nat.succ n) := by
                  rw [ih]
      | mediatingValue k =>
          rw [hrole] at ih
          change 2 * k + 1 = n at ih
          calc
            natEnrichedParityRoleCode
                (natEnrichedParityRoleOfVisible (Nat.succ (Nat.succ n))) =
                2 * (k + 1) + 1 := by
                  rw [natEnrichedParityRoleOfVisible, hrole]
                  rfl
            _ = Nat.succ (Nat.succ (2 * k + 1)) :=
                  natEnrichedParityRoleCode_mediating_succ k
            _ = Nat.succ (Nat.succ n) := by
                  rw [ih]

/-! ## Visible step read from enriched roles -/

/-- Visible closing reading. -/
def collatzVisibleClosingStep (n : Nat) : Nat :=
  n / 2

/-- Visible mediating reading. -/
def collatzVisibleMediatingStep (n : Nat) : Nat :=
  3 * n + 1

/-- Visible Collatz reading selected by an enriched operational role. -/
def collatzVisibleStepOfRole :
    NatEnrichedParityRole -> Nat
  | NatEnrichedParityRole.closingExcess k =>
      collatzVisibleClosingStep
        (natEnrichedParityRoleCode (NatEnrichedParityRole.closingExcess k))
  | NatEnrichedParityRole.mediatingValue k =>
      collatzVisibleMediatingStep
        (natEnrichedParityRoleCode (NatEnrichedParityRole.mediatingValue k))

/-- The closing role reads as the closing visible step. -/
theorem collatzVisibleStepOfRole_closing
    (k : Nat) :
    collatzVisibleStepOfRole (NatEnrichedParityRole.closingExcess k) =
      collatzVisibleClosingStep
        (natEnrichedParityRoleCode
          (NatEnrichedParityRole.closingExcess k)) :=
  rfl

/-- The mediating role reads as the mediating visible step. -/
theorem collatzVisibleStepOfRole_mediating
    (k : Nat) :
    collatzVisibleStepOfRole (NatEnrichedParityRole.mediatingValue k) =
      collatzVisibleMediatingStep
        (natEnrichedParityRoleCode
          (NatEnrichedParityRole.mediatingValue k)) :=
  rfl

/-! ## Mediating source produced by the visible role reader -/

/-- A visible value whose computed enriched role is mediating. -/
structure CollatzVisibleMediatingSource
    (visible : Nat) where
  index : Nat
  role_eq :
    natEnrichedParityRoleOfVisible visible =
      NatEnrichedParityRole.mediatingValue index
  code_eq_visible :
    natEnrichedParityRoleCode
      (NatEnrichedParityRole.mediatingValue index) = visible

/-- Build the mediating source from the actual branch of the visible role reader. -/
def collatzVisibleMediatingSourceOfRoleEq
    {visible index : Nat}
    (role_eq :
      natEnrichedParityRoleOfVisible visible =
        NatEnrichedParityRole.mediatingValue index) :
    CollatzVisibleMediatingSource visible where
  index := index
  role_eq := role_eq
  code_eq_visible := by
    rw [← role_eq]
    exact natEnrichedParityRoleOfVisible_code visible

/-! ## Visible mediating activation -/

/-- The relaxed mediating activation produced from a visible mediating source. -/
structure CollatzVisibleMediatingActivation
    (visible : Nat) where
  source :
    CollatzVisibleMediatingSource visible
  relaxedOdd :
    NatEnrichedRelaxedOddRole source.index
  visibleStep :
    Nat
  visibleStep_eq :
    visibleStep = 3 * visible + 1
  rightPayload :
    Nat
  rightPayload_eq :
    rightPayload = relaxedOdd.rightPayload
  visibleStep_eq_two_mul_rightPayload :
    visibleStep = 2 * rightPayload
  visibleStep_div_two_eq_rightPayload :
    visibleStep / 2 = rightPayload

/-- Construct the relaxed mediating activation from its visible source. -/
def collatzVisibleMediatingActivation
    {visible : Nat}
    (source : CollatzVisibleMediatingSource visible) :
    CollatzVisibleMediatingActivation visible where
  source := source
  relaxedOdd := natEnrichedRelaxedOddRole source.index
  visibleStep := 3 * visible + 1
  visibleStep_eq := rfl
  rightPayload := (natEnrichedRelaxedOddRole source.index).rightPayload
  rightPayload_eq := rfl
  visibleStep_eq_two_mul_rightPayload := by
    conv_lhs => rw [← source.code_eq_visible]
    rw [natEnrichedRelaxedOddRole_rightPayload_eq_maximallyRelaxed]
    exact
      natEnrichedParityMediatingCode_three_mul_add_one_eq_two_mul_rightPayload
        source.index
  visibleStep_div_two_eq_rightPayload := by
    conv_lhs => rw [← source.code_eq_visible]
    rw [natEnrichedRelaxedOddRole_rightPayload_eq_maximallyRelaxed]
    exact
      natEnrichedParityMediatingCode_three_mul_add_one_div_two_eq_rightPayload
        source.index

/-! ## Indexed mediating activation -/

/-- Internal indexed mediating activation. -/
structure CollatzVisibleActivation
    (k : Nat) where
  closingRole :
    NatEnrichedParityRole
  closingRole_eq :
    closingRole = NatEnrichedParityRole.closingExcess k
  mediatingRole :
    NatEnrichedParityRole
  mediatingRole_eq :
    mediatingRole = NatEnrichedParityRole.mediatingValue k
  relaxedOdd :
    NatEnrichedRelaxedOddRole k
  visibleSource :
    Nat
  visibleSource_eq :
    visibleSource = natEnrichedParityRoleCode mediatingRole
  visibleStep :
    Nat
  visibleStep_eq :
    visibleStep = collatzVisibleStepOfRole mediatingRole
  rightPayload :
    Nat
  rightPayload_eq :
    rightPayload = relaxedOdd.rightPayload
  visibleStep_eq_two_mul_rightPayload :
    visibleStep = 2 * rightPayload
  visibleStep_div_two_eq_rightPayload :
    visibleStep / 2 = rightPayload

/-- Canonical indexed visible mediating activation. -/
def collatzVisibleActivation
    (k : Nat) :
    CollatzVisibleActivation k where
  closingRole := NatEnrichedParityRole.closingExcess k
  closingRole_eq := rfl
  mediatingRole := NatEnrichedParityRole.mediatingValue k
  mediatingRole_eq := rfl
  relaxedOdd := natEnrichedRelaxedOddRole k
  visibleSource :=
    natEnrichedParityRoleCode (NatEnrichedParityRole.mediatingValue k)
  visibleSource_eq := rfl
  visibleStep :=
    collatzVisibleStepOfRole (NatEnrichedParityRole.mediatingValue k)
  visibleStep_eq := rfl
  rightPayload := (natEnrichedRelaxedOddRole k).rightPayload
  rightPayload_eq := rfl
  visibleStep_eq_two_mul_rightPayload := by
    unfold collatzVisibleStepOfRole collatzVisibleMediatingStep
    rw [natEnrichedRelaxedOddRole_rightPayload_eq_maximallyRelaxed]
    exact
      natEnrichedParityMediatingCode_three_mul_add_one_eq_two_mul_rightPayload k
  visibleStep_div_two_eq_rightPayload := by
    unfold collatzVisibleStepOfRole collatzVisibleMediatingStep
    rw [natEnrichedRelaxedOddRole_rightPayload_eq_maximallyRelaxed]
    exact
      natEnrichedParityMediatingCode_three_mul_add_one_div_two_eq_rightPayload k

/-- Indexed activation extracted from a visible mediating source. -/
def collatzVisibleActivationOfMediatingSource
    {visible : Nat}
    (source : CollatzVisibleMediatingSource visible) :
    CollatzVisibleActivation source.index :=
  collatzVisibleActivation source.index

/-- Visible mediating activation extracted from a visible mediating source. -/
def collatzVisibleMediatingActivationOfSource
    {visible : Nat}
    (source : CollatzVisibleMediatingSource visible) :
    CollatzVisibleMediatingActivation visible :=
  collatzVisibleMediatingActivation source

/-! ## Formed intersection produced from visible non-terminal mediating data -/

/-- Branch used by the visible formed intersection. -/
def collatzVisibleFormedBranch
    (visible : Nat)
    (_terminalTime : Nat) :
    MemoryBranch :=
  canonicalBranch visible

/-- Formed intersection with positive formed index `terminalTime + 1`. -/
def collatzVisibleFormedIntersection
    (visible : Nat)
    (terminalTime : Nat) :
    PrimitiveMemoryReadingIntersection
      (collatzVisibleFormedBranch visible terminalTime) :=
  primitiveMemoryReadingIntersection_of_sharedTrace
    (branch := collatzVisibleFormedBranch visible terminalTime)
    (globalTrace visible)
    rfl
    rfl
    terminalTime

/-- The visible formed intersection has formed index `terminalTime + 1`. -/
theorem collatzVisibleFormedIntersection_formedPositiveExcess
    (visible terminalTime : Nat) :
    formedPositiveExcessOfIntersection
      (collatzVisibleFormedIntersection visible terminalTime) =
        Nat.succ terminalTime :=
  rfl

/-! ## Total visible internal activation -/

/-- Total internal analysis of one visible Collatz value. -/
inductive CollatzVisibleInternalActivation
    (visible : Nat) where
  | closing
      (index : Nat)
      (role_eq :
        natEnrichedParityRoleOfVisible visible =
          NatEnrichedParityRole.closingExcess index)
      (code_eq_visible :
        natEnrichedParityRoleCode
          (NatEnrichedParityRole.closingExcess index) = visible)
  | terminalOne
      (role_eq :
        natEnrichedParityRoleOfVisible visible =
          NatEnrichedParityRole.mediatingValue 0)
      (code_eq_visible :
        natEnrichedParityRoleCode
          (NatEnrichedParityRole.mediatingValue 0) = visible)
  | mediating
      (terminalTime : Nat)
      (source :
        CollatzVisibleMediatingSource visible)
      (source_index_eq :
        source.index = Nat.succ terminalTime)
      (intersection :
        PrimitiveMemoryReadingIntersection
          (collatzVisibleFormedBranch visible terminalTime))
      (formedIndex_eq :
        formedPositiveExcessOfIntersection intersection =
          source.index)
      (activation :
        CollatzVisibleMediatingActivation visible)
      (closureLoop :
        CollatzDynamicClosureLoop intersection)

/-- Total internal activation produced by one visible value. -/
def collatzVisibleInternalActivation
    (visible : Nat) :
    CollatzVisibleInternalActivation visible := by
  cases role_eq : natEnrichedParityRoleOfVisible visible with
  | closingExcess index =>
      exact
        CollatzVisibleInternalActivation.closing
          index
          role_eq
          (by
            rw [← role_eq]
            exact natEnrichedParityRoleOfVisible_code visible)
  | mediatingValue index =>
      cases index with
      | zero =>
          exact
            CollatzVisibleInternalActivation.terminalOne
              role_eq
              (by
                rw [← role_eq]
                exact natEnrichedParityRoleOfVisible_code visible)
      | succ terminalTime =>
          let source := collatzVisibleMediatingSourceOfRoleEq role_eq
          let intersection :=
            collatzVisibleFormedIntersection visible terminalTime
          exact
            CollatzVisibleInternalActivation.mediating
              terminalTime
              source
              rfl
              intersection
              rfl
              (collatzVisibleMediatingActivation source)
              (collatzDynamicClosureLoop intersection)

/--
Extract the mediating activation when the visible role reader produces a
non-terminal mediating role.
-/
def collatzVisibleInternalActivation_mediatingSuccOfRoleEq
    {visible terminalTime : Nat}
    (role_eq :
      natEnrichedParityRoleOfVisible visible =
        NatEnrichedParityRole.mediatingValue (Nat.succ terminalTime)) :
    CollatzVisibleMediatingActivation visible :=
  collatzVisibleMediatingActivation
    (collatzVisibleMediatingSourceOfRoleEq role_eq)

end EnrichedNatClosedStabilityInstance
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityRoleOfVisible
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityRoleCode_closing_succ
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityRoleCode_mediating_succ
#print axioms Meta.EnrichedNatClosedStabilityInstance.natEnrichedParityRoleOfVisible_code
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzVisibleMediatingSource
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzVisibleMediatingSourceOfRoleEq
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzVisibleMediatingActivation
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzVisibleMediatingActivation
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzVisibleActivation
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzVisibleActivation
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzVisibleFormedIntersection
#print axioms Meta.EnrichedNatClosedStabilityInstance.CollatzVisibleInternalActivation
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzVisibleInternalActivation
#print axioms Meta.EnrichedNatClosedStabilityInstance.collatzVisibleInternalActivation_mediatingSuccOfRoleEq
/- AXIOM_AUDIT_END -/
