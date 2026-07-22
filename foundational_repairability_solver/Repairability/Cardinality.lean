import Repairability.Finite

namespace Repairability

def trueCount (p : α → Bool) : List α → Nat
  | [] => 0
  | x :: xs =>
      match p x with
      | false => trueCount p xs
      | true => trueCount p xs + 1

def sumNatList : List Nat → Nat
  | [] => 0
  | value :: rest => value + sumNatList rest

theorem sumNatList_map_eq_zero_iff
    (score : α → Nat) (xs : List α) :
    sumNatList (xs.map score) = 0 ↔
      ∀ x, x ∈ xs → score x = 0 := by
  induction xs with
  | nil =>
      constructor
      · intro _ x hx
        exact False.elim (List.not_mem_nil hx)
      · intro _
        rfl
  | cons head tail ih =>
      constructor
      · intro hzero x hx
        have hparts : score head = 0 ∧
            sumNatList (tail.map score) = 0 :=
          Nat.add_eq_zero_iff.mp hzero
        cases hx with
        | head => exact hparts.1
        | tail _ hmem => exact ih.mp hparts.2 x hmem
      · intro hall
        apply Nat.add_eq_zero_iff.mpr
        constructor
        · exact hall head (List.Mem.head tail)
        · apply ih.mpr
          intro x hx
          exact hall x (List.Mem.tail head hx)

theorem trueCount_le_length (p : α → Bool) (xs : List α) :
    trueCount p xs ≤ xs.length := by
  induction xs with
  | nil => exact Nat.le_refl 0
  | cons x xs ih =>
      cases hx : p x with
      | false =>
          rw [trueCount, hx]
          change trueCount p xs ≤ xs.length + 1
          exact Nat.le_trans ih (Nat.le_succ xs.length)
      | true =>
          rw [trueCount, hx]
          change trueCount p xs + 1 ≤ xs.length + 1
          exact Nat.add_le_add_right ih 1

theorem trueCount_mono
    (p q : α → Bool) (xs : List α)
    (hmono : ∀ x, x ∈ xs → p x = true → q x = true) :
    trueCount p xs ≤ trueCount q xs := by
  induction xs with
  | nil => exact Nat.le_refl 0
  | cons x xs ih =>
      have htail : ∀ y, y ∈ xs → p y = true → q y = true := by
        intro y hy hp
        exact hmono y (List.Mem.tail x hy) hp
      have hle := ih htail
      cases hp : p x with
      | false =>
          cases hq : q x with
          | false =>
              rw [trueCount, hp, trueCount, hq]
              exact hle
          | true =>
              rw [trueCount, hp, trueCount, hq]
              change trueCount p xs ≤ trueCount q xs + 1
              exact Nat.le_trans hle (Nat.le_succ (trueCount q xs))
      | true =>
          have hqtrue := hmono x (List.Mem.head xs) hp
          cases hq : q x with
          | false =>
              rw [hq] at hqtrue
              exact Bool.noConfusion hqtrue
          | true =>
              rw [trueCount, hp, trueCount, hq]
              change trueCount p xs + 1 ≤ trueCount q xs + 1
              exact Nat.add_le_add_right hle 1

theorem trueCount_lt_of_witness
    (p q : α → Bool) (xs : List α)
    (hmono : ∀ x, x ∈ xs → p x = true → q x = true)
    (w : α) (hw : w ∈ xs) (hpw : p w = false) (hqw : q w = true) :
    trueCount p xs < trueCount q xs := by
  induction xs with
  | nil => cases hw
  | cons x xs ih =>
      have htailMono : ∀ y, y ∈ xs → p y = true → q y = true := by
        intro y hy hp
        exact hmono y (List.Mem.tail x hy) hp
      cases hw with
      | head =>
          have htailLe := trueCount_mono p q xs htailMono
          rw [trueCount, hpw, trueCount, hqw]
          change trueCount p xs < trueCount q xs + 1
          exact Nat.lt_succ_of_le htailLe
      | tail head hw =>
          have htailLt := ih htailMono hw
          cases hp : p x with
          | false =>
              cases hq : q x with
              | false =>
                  rw [trueCount, hp, trueCount, hq]
                  exact htailLt
              | true =>
                  rw [trueCount, hp, trueCount, hq]
                  change trueCount p xs < trueCount q xs + 1
                  exact Nat.lt_trans htailLt (Nat.lt_succ_self (trueCount q xs))
          | true =>
              have hqtrue := hmono x (List.Mem.head xs) hp
              cases hq : q x with
              | false =>
                  rw [hq] at hqtrue
                  exact Bool.noConfusion hqtrue
              | true =>
                  rw [trueCount, hp, trueCount, hq]
                  change trueCount p xs + 1 < trueCount q xs + 1
                  exact Nat.add_lt_add_right htailLt 1

theorem trueCount_eq_zero_iff
    (p : α → Bool) (xs : List α) :
    trueCount p xs = 0 ↔ ∀ x, x ∈ xs → p x = false := by
  induction xs with
  | nil =>
      constructor
      · intro _ x hx
        exact False.elim (List.not_mem_nil hx)
      · intro _
        rfl
  | cons head tail ih =>
      constructor
      · intro hzero
        cases hhead : p head with
        | false =>
            have htailZero : trueCount p tail = 0 := by
              rw [trueCount, hhead] at hzero
              exact hzero
            intro x hx
            cases hx with
            | head => exact hhead
            | tail _ hmem => exact ih.mp htailZero x hmem
        | true =>
            rw [trueCount, hhead] at hzero
            have himpossible : trueCount p tail + 1 ≠ 0 := Nat.ne_of_gt
              (Nat.zero_lt_succ (trueCount p tail))
            exact False.elim (himpossible hzero)
      · intro hall
        have hhead : p head = false := hall head (List.Mem.head tail)
        have htail : trueCount p tail = 0 := ih.mpr (by
          intro x hx
          exact hall x (List.Mem.tail head hx))
        rw [trueCount, hhead, htail]

theorem allList_eq_false_iff
    (p : α → Bool) (xs : List α) :
    allList p xs = false ↔ ∃ x, x ∈ xs ∧ p x = false := by
  induction xs with
  | nil =>
      constructor
      · intro h
        change true = false at h
        exact Bool.noConfusion h
      · rintro ⟨x, hx, _⟩
        cases hx
  | cons x xs ih =>
      constructor
      · intro h
        cases hx : p x with
        | false => exact ⟨x, List.Mem.head xs, hx⟩
        | true =>
            rw [allList, hx] at h
            rcases ih.mp h with ⟨y, hy, hp⟩
            exact ⟨y, List.Mem.tail x hy, hp⟩
      · rintro ⟨y, hy, hp⟩
        cases hy with
        | head =>
            rw [allList, hp]
            rfl
        | tail head hy =>
            rw [allList]
            cases hx : p x with
            | false => rfl
            | true => exact ih.mpr ⟨y, hy, hp⟩

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.trueCount_le_length
#print axioms Repairability.sumNatList_map_eq_zero_iff
#print axioms Repairability.trueCount_mono
#print axioms Repairability.trueCount_lt_of_witness
#print axioms Repairability.trueCount_eq_zero_iff
#print axioms Repairability.allList_eq_false_iff
/- AXIOM_AUDIT_END -/
