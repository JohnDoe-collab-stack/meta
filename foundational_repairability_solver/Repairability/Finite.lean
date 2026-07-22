import Std

namespace Repairability

universe u

/-- Constructive finite carrier with an explicit complete enumeration. -/
structure FiniteCarrier (α : Type u) where
  elements : List α
  nodup : elements.Nodup
  complete : ∀ x : α, x ∈ elements
  eqDec : (x y : α) → Decidable (x = y)

def anyList (p : α → Bool) : List α → Bool
  | [] => false
  | x :: xs => p x || anyList p xs

def allList (p : α → Bool) : List α → Bool
  | [] => true
  | x :: xs => p x && allList p xs

theorem boolAnd_eq_true_iff (p q : Bool) :
    (p && q) = true ↔ p = true ∧ q = true := by
  constructor
  · intro h
    cases hp : p with
    | false =>
        rw [hp] at h
        exact Bool.noConfusion h
    | true =>
        cases hq : q with
        | false =>
            rw [hp, hq] at h
            exact Bool.noConfusion h
        | true => exact ⟨rfl, rfl⟩
  · rintro ⟨hp, hq⟩
    cases hp
    cases hq
    rfl

theorem boolOr_eq_true_iff (p q : Bool) :
    (p || q) = true ↔ p = true ∨ q = true := by
  constructor
  · intro h
    cases hp : p with
    | true => exact Or.inl rfl
    | false =>
        cases hq : q with
        | true => exact Or.inr rfl
        | false =>
            rw [hp, hq] at h
            exact Bool.noConfusion h
  · intro h
    cases h with
    | inl hp =>
        cases hp
        rfl
    | inr hq =>
        cases hq
        cases p <;> rfl

theorem boolNotOr_eq_true_iff (p q : Bool) :
    ((!p) || q) = true ↔ (p = true → q = true) := by
  cases hp : p with
  | false =>
      constructor
      · intro _ htrue
        cases htrue
      · intro _
        rfl
  | true =>
      constructor
      · intro h _
        cases hq : q with
        | true => rfl
        | false =>
            rw [hq] at h
            exact Bool.noConfusion h
      · intro himp
        have hq : q = true := himp rfl
        cases hq
        rfl

theorem boolOr_eq_false_iff (p q : Bool) :
    (p || q) = false ↔ p = false ∧ q = false := by
  constructor
  · intro h
    cases hp : p with
    | true =>
        rw [hp] at h
        exact Bool.noConfusion h
    | false =>
        cases hq : q with
        | true =>
            rw [hp, hq] at h
            exact Bool.noConfusion h
        | false => exact ⟨rfl, rfl⟩
  · rintro ⟨hp, hq⟩
    cases hp
    cases hq
    rfl

theorem boolNot_eq_true_iff (p : Bool) :
    (!p) = true ↔ p = false := by
  cases p
  · exact ⟨fun _ => rfl, fun _ => rfl⟩
  · constructor <;> intro h <;> exact Bool.noConfusion h

def decideWith {p : Prop} (d : Decidable p) : Bool :=
  @decide p d

theorem decideWith_eq_true_iff {p : Prop} (d : Decidable p) :
    decideWith d = true ↔ p := by
  constructor
  · exact @of_decide_eq_true p d
  · exact @decide_eq_true p d

theorem anyList_eq_true_iff
    (p : α → Bool) (xs : List α) :
    anyList p xs = true ↔ ∃ x, x ∈ xs ∧ p x = true := by
  induction xs with
  | nil =>
      constructor
      · intro h
        change false = true at h
        exact Bool.noConfusion h
      · rintro ⟨x, hmem, _⟩
        cases hmem
  | cons x xs ih =>
      constructor
      · intro h
        cases hx : p x with
        | false =>
            rw [anyList, hx] at h
            rcases ih.mp h with ⟨y, hy, hp⟩
            exact ⟨y, List.Mem.tail x hy, hp⟩
        | true =>
            exact ⟨x, List.Mem.head xs, hx⟩
      · rintro ⟨y, hy, hp⟩
        cases hy with
        | head =>
            rw [anyList, hp]
            rfl
        | tail head hy =>
            rw [anyList]
            cases hh : p x with
            | false => exact ih.mpr ⟨y, hy, hp⟩
            | true => rfl

theorem allList_eq_true_iff
    (p : α → Bool) (xs : List α) :
    allList p xs = true ↔ ∀ x, x ∈ xs → p x = true := by
  induction xs with
  | nil =>
      constructor
      · intro _ x hmem
        cases hmem
      · intro _
        rfl
  | cons x xs ih =>
      constructor
      · intro h y hy
        have hand : p x = true ∧ allList p xs = true := by
          exact (boolAnd_eq_true_iff (p x) (allList p xs)).mp h
        cases hy with
        | head => exact hand.1
        | tail head hy => exact ih.mp hand.2 y hy
      · intro hall
        apply (boolAnd_eq_true_iff (p x) (allList p xs)).mpr
        constructor
        · exact hall x (List.Mem.head xs)
        · apply ih.mpr
          intro y hy
          exact hall y (List.Mem.tail x hy)

theorem anyList_eq_false_iff
    (p : α → Bool) (xs : List α) :
    anyList p xs = false ↔ ∀ x, x ∈ xs → p x = false := by
  induction xs with
  | nil =>
      constructor
      · intro _ x hmem
        cases hmem
      · intro _
        rfl
  | cons x xs ih =>
      constructor
      · intro h y hy
        have hparts : p x = false ∧ anyList p xs = false := by
          exact (boolOr_eq_false_iff (p x) (anyList p xs)).mp h
        cases hy with
        | head => exact hparts.1
        | tail head hy => exact ih.mp hparts.2 y hy
      · intro hall
        apply (boolOr_eq_false_iff (p x) (anyList p xs)).mpr
        constructor
        · exact hall x (List.Mem.head xs)
        · apply ih.mpr
          intro y hy
          exact hall y (List.Mem.tail x hy)

def findList? (p : α → Bool) : List α → Option α
  | [] => none
  | x :: xs =>
      match p x with
      | true => some x
      | false => findList? p xs

theorem findList?_some_sound
    (p : α → Bool) (xs : List α) (x : α)
    (h : findList? p xs = some x) :
    x ∈ xs ∧ p x = true := by
  induction xs with
  | nil =>
      change (none : Option α) = some x at h
      cases h
  | cons y ys ih =>
      cases hy : p y with
      | false =>
          rw [findList?, hy] at h
          have hrest := ih h
          exact ⟨List.Mem.tail y hrest.1, hrest.2⟩
      | true =>
          rw [findList?, hy] at h
          cases h
          exact ⟨List.Mem.head ys, hy⟩

theorem findList?_none_iff
    (p : α → Bool) (xs : List α) :
    findList? p xs = none ↔ ∀ x, x ∈ xs → p x = false := by
  induction xs with
  | nil =>
      constructor
      · intro _ x hmem
        cases hmem
      · intro _
        rfl
  | cons x xs ih =>
      constructor
      · intro h y hy
        cases hy with
        | head =>
            cases hx : p x with
            | false => rfl
            | true =>
                rw [findList?, hx] at h
                cases h
        | tail head hy =>
            have htail : findList? p xs = none := by
              cases hx : p x with
              | false =>
                  rw [findList?, hx] at h
                  exact h
              | true =>
                  rw [findList?, hx] at h
                  cases h
            exact ih.mp htail y hy
      · intro hall
        cases hx : p x with
        | false =>
            rw [findList?, hx]
            apply ih.mpr
            intro y hy
            exact hall y (List.Mem.tail x hy)
        | true =>
            have hfalse : p x = false := hall x (List.Mem.head xs)
            rw [hx] at hfalse
            exact Bool.noConfusion hfalse

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.anyList_eq_true_iff
#print axioms Repairability.allList_eq_true_iff
#print axioms Repairability.findList?_none_iff
#print axioms Repairability.boolNotOr_eq_true_iff
#print axioms Repairability.anyList_eq_false_iff
#print axioms Repairability.decideWith_eq_true_iff
/- AXIOM_AUDIT_END -/
