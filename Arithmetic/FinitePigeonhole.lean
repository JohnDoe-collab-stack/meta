import LocalSemanticClosure.Standalone.Clean.meta.Arithmetic.RepeatedIndex

/-!
# FinitePigeonhole
-/

namespace LocalSemanticClosure
namespace Standalone
namespace Clean
namespace EnrichedNatClosedStabilityInstance

open ClosedStabilityTheorem

/-!
## Constructive finite-window collision

This is the finite pigeonhole mechanism needed to turn a certified
self-covering Nat-height window into actual post-height finite collision data.
-/

/-- Constructive decidability of membership for lists of natural numbers. -/
def natMemDecidable
    (a : Nat) :
    ∀ values : List Nat, Decidable (a ∈ values)
  | [] =>
      isFalse (fun h => nomatch h)
  | x :: xs =>
      match Nat.decEq a x with
      | isTrue hEq =>
          isTrue (by
            rw [hEq]
            exact List.Mem.head xs)
      | isFalse hNe =>
          match natMemDecidable a xs with
          | isTrue hTail =>
              isTrue (List.Mem.tail x hTail)
          | isFalse hNotTail =>
              isFalse (by
                intro hMem
                cases hMem with
                | head _ =>
                    exact hNe rfl
                | tail _ hTail =>
                    exact hNotTail hTail)

/-- Remove the first occurrence of a natural number from a list. -/
def removeFirstNat (a : Nat) : List Nat → List Nat
  | [] => []
  | x :: xs =>
      match (inferInstance : Decidable (x = a)) with
      | isTrue _h => xs
      | isFalse _h => x :: removeFirstNat a xs

/-- Removing a present value decreases length by exactly one. -/
theorem removeFirstNat_length_succ_of_mem
    (a : Nat) :
    ∀ values : List Nat,
      a ∈ values →
        (removeFirstNat a values).length + 1 = values.length
  | [], hMem => by
      nomatch hMem
  | x :: xs, hMem => by
      unfold removeFirstNat
      cases hDec : (inferInstance : Decidable (x = a)) with
      | isTrue _hEq =>
          rfl
      | isFalse hNe =>
        cases hMem with
        | head _ =>
            exact False.elim (hNe rfl)
        | tail _ hTail =>
            have ih := removeFirstNat_length_succ_of_mem a xs hTail
            change (removeFirstNat a xs).length + 1 + 1 = xs.length + 1
            rw [ih]

/-- Membership after removal came from membership before removal. -/
theorem mem_of_mem_removeFirstNat
    (a x : Nat) :
    ∀ values : List Nat,
      x ∈ removeFirstNat a values → x ∈ values
  | [], hMem => by
      nomatch hMem
  | y :: ys, hMem => by
      unfold removeFirstNat at hMem
      cases hDec : (inferInstance : Decidable (y = a)) with
      | isTrue _hEq =>
          rw [hDec] at hMem
          exact List.Mem.tail y hMem
      | isFalse _hNe =>
          rw [hDec] at hMem
          cases hMem with
          | head _ =>
              exact List.Mem.head ys
          | tail _ hTail =>
              exact List.Mem.tail y
                (mem_of_mem_removeFirstNat a x ys hTail)

/-- Removing one value preserves duplicate-freeness. -/
theorem removeFirstNat_nodup
    (a : Nat) :
    ∀ values : List Nat,
      values.Nodup → (removeFirstNat a values).Nodup
  | [], _hNodup => by
      exact List.Pairwise.nil
  | y :: ys, hNodup => by
      cases hNodup with
      | cons hHeadNotMem hTailNodup =>
          unfold removeFirstNat
          cases hDec : (inferInstance : Decidable (y = a)) with
          | isTrue _hEq =>
              exact hTailNodup
          | isFalse _hNe =>
              exact
                List.Pairwise.cons
                  (fun z hzRemove hEq => by
                    have hzYs : z ∈ ys :=
                      mem_of_mem_removeFirstNat a z ys hzRemove
                    exact hHeadNotMem z hzYs hEq)
                  (removeFirstNat_nodup a ys hTailNodup)

/-- A value still present after removing `a` from a duplicate-free list is not `a`. -/
theorem ne_of_mem_removeFirstNat_of_nodup
    (a x : Nat) :
    ∀ values : List Nat,
      values.Nodup → x ∈ removeFirstNat a values → x ≠ a
  | [], _hNodup, hMem => by
      nomatch hMem
  | y :: ys, hNodup, hMem => by
      cases hNodup with
      | cons hHeadNotMem hTailNodup =>
          unfold removeFirstNat at hMem
          cases hDec : (inferInstance : Decidable (y = a)) with
          | isTrue hyEq =>
              rw [hDec] at hMem
              intro hxEq
              have hyx : y ≠ x := hHeadNotMem x hMem
              exact hyx (by rw [hyEq, hxEq])
          | isFalse hyNe =>
              rw [hDec] at hMem
              cases hMem with
              | head _ =>
                  intro hxy
                  exact hyNe hxy
              | tail _ hTail =>
                  exact ne_of_mem_removeFirstNat_of_nodup
                    a x ys hTailNodup hTail

/--
A duplicate-free list of natural numbers included in another list has length
bounded by the length of the ambient list.
-/
theorem natList_nodup_length_le_of_subset :
    ∀ (ambient values : List Nat),
      values.Nodup →
        (∀ x : Nat, x ∈ values → x ∈ ambient) →
          values.length ≤ ambient.length
  | [], values, _hNodup, hSubset => by
      cases values with
      | nil =>
          exact Nat.le_refl 0
      | cons x xs =>
          have hMem : x ∈ x :: xs := List.Mem.head xs
          have hEmpty : x ∈ ([] : List Nat) := hSubset x hMem
          nomatch hEmpty
  | a :: ambient, values, hNodup, hSubset => by
      cases natMemDecidable a values with
      | isTrue hMemA =>
          have hEraseNodup : (removeFirstNat a values).Nodup :=
            removeFirstNat_nodup a values hNodup
          have hEraseSubset :
              ∀ x : Nat, x ∈ removeFirstNat a values → x ∈ ambient := by
            intro x hxErase
            have hxValues : x ∈ values :=
              mem_of_mem_removeFirstNat a x values hxErase
            have hxAmbientCons : x ∈ a :: ambient :=
              hSubset x hxValues
            cases hxAmbientCons with
            | head _ =>
                have haNe : a ≠ a :=
                  ne_of_mem_removeFirstNat_of_nodup
                    a a values hNodup hxErase
                exact False.elim (haNe rfl)
            | tail _ hxAmbient =>
                exact hxAmbient
          have hLengthEraseLe :
              (removeFirstNat a values).length ≤ ambient.length :=
            natList_nodup_length_le_of_subset
              ambient
              (removeFirstNat a values)
              hEraseNodup
              hEraseSubset
          have hSuccErase :
              (removeFirstNat a values).length + 1 = values.length :=
            removeFirstNat_length_succ_of_mem a values hMemA
          rw [← hSuccErase]
          exact Nat.succ_le_succ hLengthEraseLe
      | isFalse hMemA =>
          have hSubsetTail :
              ∀ x : Nat, x ∈ values → x ∈ ambient := by
            intro x hxValues
            have hxAmbientCons : x ∈ a :: ambient :=
              hSubset x hxValues
            cases hxAmbientCons with
            | head _ =>
                exact False.elim (hMemA hxValues)
            | tail _ hxAmbient =>
                exact hxAmbient
          have hLengthLe :
              values.length ≤ ambient.length :=
            natList_nodup_length_le_of_subset
              ambient
              values
              hNodup
              hSubsetTail
          exact Nat.le_trans hLengthLe (Nat.le_succ _)

/-- Constructive indexed lookup for lists of natural numbers. -/
def natListNth? : List Nat → Nat → Option Nat
  | [], _ => none
  | x :: _xs, 0 => some x
  | _x :: xs, i + 1 => natListNth? xs i

/-- A member of a list has an explicit constructive lookup index. -/
theorem natListNth_of_mem
    (a : Nat) :
    ∀ values : List Nat,
      a ∈ values → ∃ i : Nat, natListNth? values i = some a
  | [], hMem => by
      nomatch hMem
  | x :: xs, hMem => by
      cases hMem with
      | head _ =>
          exact ⟨0, rfl⟩
      | tail _ hTail =>
          rcases natListNth_of_mem a xs hTail with ⟨i, hi⟩
          exact ⟨i + 1, hi⟩

/-- Constructive lookup returning a value carries a valid index. -/
theorem natListNth_some_lt :
    ∀ values : List Nat, ∀ i v : Nat,
      natListNth? values i = some v → i < values.length
  | [], i, _v, hSome => by
      cases i <;> cases hSome
  | _x :: _xs, 0, _v, _hSome => by
      exact Nat.succ_pos _
  | _x :: xs, i + 1, v, hSome => by
      exact Nat.succ_lt_succ
        (natListNth_some_lt xs i v hSome)

/-- Result of a constructive lookup for the first occurrence of a Nat in a list. -/
structure NatListFirstIndexResult
    (a : Nat)
    (values : List Nat) where
  index : Option Nat
  none_no_mem :
    index = none → a ∈ values → False
  some_reads :
    ∀ i : Nat,
      index = some i → natListNth? values i = some a
  some_lt :
    ∀ i : Nat,
      index = some i → i < values.length

/-- Constructive lookup for the first occurrence of a Nat in a list. -/
def natListFirstIndexResult
    (a : Nat) :
    (values : List Nat) → NatListFirstIndexResult a values
  | [] =>
      { index := none
        none_no_mem := by
          intro _hNone hMem
          nomatch hMem
        some_reads := by
          intro _i hSome
          cases hSome
        some_lt := by
          intro _i hSome
          cases hSome }
  | x :: xs =>
      match (inferInstance : Decidable (x = a)) with
      | isTrue hEq =>
        { index := some 0
          none_no_mem := by
            intro hNone
            cases hNone
          some_reads := by
            intro i hSome
            have hi : 0 = i := Option.some.inj hSome
            cases hi
            exact congrArg some hEq
          some_lt := by
            intro i hSome
            have hi : 0 = i := Option.some.inj hSome
            cases hi
            exact Nat.succ_pos xs.length }
      | isFalse hEq =>
        let tail := natListFirstIndexResult a xs
        match hTail : tail.index with
        | some tailIndex =>
            { index := some (tailIndex + 1)
              none_no_mem := by
                intro hNone
                cases hNone
              some_reads := by
                intro i hSome
                have hi : tailIndex + 1 = i := Option.some.inj hSome
                cases hi
                exact tail.some_reads tailIndex hTail
              some_lt := by
                intro i hSome
                have hi : tailIndex + 1 = i := Option.some.inj hSome
                cases hi
                exact Nat.succ_lt_succ (tail.some_lt tailIndex hTail) }
        | none =>
            { index := none
              none_no_mem := by
                intro _hNone hMem
                cases hMem with
                | head _ =>
                    exact hEq rfl
                | tail _ hTailMem =>
                    exact tail.none_no_mem hTail hTailMem
              some_reads := by
                intro _i hSome
                cases hSome
              some_lt := by
                intro _i hSome
                cases hSome }

/--
Failure of `Nodup` for a list of natural numbers produces explicit duplicate
positions.
-/
theorem natList_duplicate_indices_of_not_nodup :
    ∀ values : List Nat,
      ¬ values.Nodup →
        ∃ i j v : Nat,
          i < j ∧
            j < values.length ∧
              natListNth? values i = some v ∧
                natListNth? values j = some v
  | [], hNotNodup => by
      exact False.elim (hNotNodup List.Pairwise.nil)
  | a :: values, hNotNodup => by
      cases natMemDecidable a values with
      | isTrue hMemA =>
          rcases natListNth_of_mem a values hMemA with ⟨j, hjSome⟩
          have hjLt : j < values.length :=
            natListNth_some_lt values j a hjSome
          refine
            ⟨0, j + 1, a, Nat.succ_pos j, ?_, ?_, ?_⟩
          · exact Nat.succ_lt_succ hjLt
          · rfl
          · exact hjSome
      | isFalse hMemA =>
          have hTailNotNodup : ¬ values.Nodup := by
            intro hValuesNodup
            apply hNotNodup
            exact List.Pairwise.cons
              (fun x hx hEq => by
                have hMem : a ∈ values := by
                  rw [hEq]
                  exact hx
                exact hMemA hMem)
              hValuesNodup
          rcases natList_duplicate_indices_of_not_nodup
              values hTailNotNodup with
            ⟨i, j, v, hij, hjLen, hiSome, hjSome⟩
          refine
            ⟨i + 1, j + 1, v,
              Nat.succ_lt_succ hij, ?_, ?_, ?_⟩
          · exact Nat.succ_lt_succ hjLen
          · exact hiSome
          · exact hjSome

/-- Explicit duplicate lookup data for a list of natural numbers. -/
structure NatListDuplicateIndicesData
    (values : List Nat) where
  leftIndex : Nat
  rightIndex : Nat
  duplicatedValue : Nat
  left_lt_right :
    leftIndex < rightIndex
  right_lt_length :
    rightIndex < values.length
  left_reads :
    natListNth? values leftIndex = some duplicatedValue
  right_reads :
    natListNth? values rightIndex = some duplicatedValue

/--
Failure of `Nodup` for a list of natural numbers, kept as explicit duplicate
data instead of compressed to a proposition-valued existential.
-/
def natList_duplicate_indices_data_of_not_nodup :
    ∀ values : List Nat,
      ¬ values.Nodup →
        NatListDuplicateIndicesData values
  | [], hNotNodup =>
      False.elim (hNotNodup List.Pairwise.nil)
  | a :: values, hNotNodup =>
      match natMemDecidable a values with
      | isTrue hMemA =>
          let lookup := natListFirstIndexResult a values
          match hLookup : lookup.index with
          | some j =>
              { leftIndex := 0
                rightIndex := j + 1
                duplicatedValue := a
                left_lt_right := Nat.succ_pos j
                right_lt_length :=
                  Nat.succ_lt_succ (lookup.some_lt j hLookup)
                left_reads := rfl
                right_reads := lookup.some_reads j hLookup }
          | none =>
              False.elim (lookup.none_no_mem hLookup hMemA)
      | isFalse hMemA =>
          let hTailNotNodup : ¬ values.Nodup := by
            intro hValuesNodup
            apply hNotNodup
            exact List.Pairwise.cons
              (fun x hx hEq => by
                have hMem : a ∈ values := by
                  rw [hEq]
                  exact hx
                exact hMemA hMem)
              hValuesNodup
          let duplicate :=
            natList_duplicate_indices_data_of_not_nodup
              values
              hTailNotNodup
          { leftIndex := duplicate.leftIndex + 1
            rightIndex := duplicate.rightIndex + 1
            duplicatedValue := duplicate.duplicatedValue
            left_lt_right := Nat.succ_lt_succ duplicate.left_lt_right
            right_lt_length := Nat.succ_lt_succ duplicate.right_lt_length
            left_reads := duplicate.left_reads
            right_reads := duplicate.right_reads }

/-- The finite value range `0, ..., B`, stored in descending order. -/
def natRangeLe : Nat → List Nat
  | 0 => [0]
  | B + 1 => (B + 1) :: natRangeLe B

/-- The finite range `0, ..., B` has length `B + 1`. -/
theorem natRangeLe_length :
    ∀ B : Nat, (natRangeLe B).length = B + 1
  | 0 => by
      rfl
  | B + 1 => by
      change (natRangeLe B).length + 1 = (B + 1) + 1
      rw [natRangeLe_length B]

/-- Every value bounded by `B` belongs to the finite range `0, ..., B`. -/
theorem natRangeLe_mem_of_le :
    ∀ B x : Nat, x ≤ B → x ∈ natRangeLe B
  | 0, x, hx => by
      have hx0 : x = 0 := Nat.eq_zero_of_le_zero hx
      rw [hx0]
      exact List.Mem.head []
  | B + 1, x, hx => by
      cases Nat.lt_or_eq_of_le hx with
      | inl hLt =>
          have hxB : x ≤ B := Nat.le_of_lt_succ hLt
          exact List.Mem.tail (B + 1)
            (natRangeLe_mem_of_le B x hxB)
      | inr hEq =>
          rw [hEq]
          exact List.Mem.head (natRangeLe B)

/-- Consecutive values `f start, ..., f (start + len - 1)`. -/
def natWindowValuesFrom (f : Nat → Nat) : Nat → Nat → List Nat
  | _start, 0 => []
  | start, len + 1 =>
      f start :: natWindowValuesFrom f (start + 1) len

/-- Window values have the requested finite length. -/
theorem natWindowValuesFrom_length
    (f : Nat → Nat) :
    ∀ start len : Nat,
      (natWindowValuesFrom f start len).length = len
  | _start, 0 => by
      rfl
  | start, len + 1 => by
      change
        (natWindowValuesFrom f (start + 1) len).length + 1 =
          len + 1
      rw [natWindowValuesFrom_length f (start + 1) len]

/-- The value at window index `i` is `f (start + i)`. -/
theorem natWindowValuesFrom_nth
    (f : Nat → Nat) :
    ∀ start len i : Nat,
      i < len →
        natListNth? (natWindowValuesFrom f start len) i =
          some (f (start + i))
  | _start, 0, i, hLt => by
      exact False.elim (Nat.not_lt_zero i hLt)
  | _start, _len + 1, 0, _hLt => by
      rfl
  | start, len + 1, i + 1, hLt => by
      change
        natListNth? (natWindowValuesFrom f (start + 1) len) i =
          some (f (start + (i + 1)))
      have hiLt : i < len :=
        Nat.lt_of_succ_lt_succ hLt
      rw [natWindowValuesFrom_nth f (start + 1) len i hiLt]
      have hAdd : start + 1 + i = start + (i + 1) := by
        rw [Nat.add_assoc, Nat.add_comm 1 i, ← Nat.add_assoc]
      rw [hAdd]

/--
Values in a bounded finite window belong to the finite value range `0, ..., B`.
-/
theorem natWindowValuesFrom_mem_range_of_bound
    (f : Nat → Nat) (B : Nat)
    (hBound : ∀ t : Nat, t ≤ B + 1 → f t ≤ B) :
    ∀ start len : Nat,
      start + len ≤ B + 2 →
        ∀ x : Nat,
          x ∈ natWindowValuesFrom f start len →
            x ∈ natRangeLe B
  | _start, 0, _hEnd, _x, hMem => by
      nomatch hMem
  | start, len + 1, hEnd, x, hMem => by
      cases hMem with
      | head _ =>
          have hStartLt : start < B + 2 := by
            have hPos : 0 < len + 1 := Nat.succ_pos len
            have hLt : start < start + (len + 1) :=
              Nat.lt_add_of_pos_right hPos
            exact Nat.lt_of_lt_of_le hLt hEnd
          have hStartLe : start ≤ B + 1 :=
            Nat.le_of_lt_succ hStartLt
          exact natRangeLe_mem_of_le B (f start)
            (hBound start hStartLe)
      | tail _ hTail =>
          have hTailEnd : start + 1 + len ≤ B + 2 := by
            rw [Nat.add_assoc, Nat.add_comm 1 len, ← Nat.add_assoc]
            exact hEnd
          exact natWindowValuesFrom_mem_range_of_bound
            f B hBound (start + 1) len hTailEnd x hTail

/--
The `B + 2` values of a finite window bounded by `B` cannot be duplicate-free.
-/
theorem natFiniteWindowValues_not_nodup
    (f : Nat → Nat) (B : Nat)
    (hBound : ∀ t : Nat, t ≤ B + 1 → f t ≤ B) :
    ¬ (natWindowValuesFrom f 0 (B + 2)).Nodup := by
  intro hNodup
  have hSubset :
      ∀ x : Nat,
        x ∈ natWindowValuesFrom f 0 (B + 2) →
          x ∈ natRangeLe B := by
    intro x hx
    exact natWindowValuesFrom_mem_range_of_bound
      f B hBound 0 (B + 2)
      (by rw [Nat.zero_add]; exact Nat.le_refl _)
      x hx
  have hLengthLe :
      (natWindowValuesFrom f 0 (B + 2)).length ≤
        (natRangeLe B).length :=
    natList_nodup_length_le_of_subset
      (natRangeLe B)
      (natWindowValuesFrom f 0 (B + 2))
      hNodup
      hSubset
  rw [natWindowValuesFrom_length f 0 (B + 2),
    natRangeLe_length B] at hLengthLe
  exact Nat.not_succ_le_self (B + 1) hLengthLe

/-- Explicit collision data for a bounded finite natural-number window. -/
structure NatFiniteWindowCollisionData
    (f : Nat → Nat) (B : Nat) where
  leftIndex : Nat
  rightIndex : Nat
  left_lt_right :
    leftIndex < rightIndex
  right_le_bound_succ :
    rightIndex ≤ B + 1
  values_eq :
    f leftIndex = f rightIndex

/--
Constructive finite pigeonhole for a bounded natural-number window.

Values `f 0, ..., f (B + 1)` all bounded by `B` force two distinct positions in
that same finite window to carry the same value, kept as data.
-/
def natFiniteWindowCollisionData_of_bounded
    (f : Nat → Nat) (B : Nat)
    (hBound : ∀ t : Nat, t ≤ B + 1 → f t ≤ B) :
    NatFiniteWindowCollisionData f B := by
  let values := natWindowValuesFrom f 0 (B + 2)
  have hNotNodup : ¬ values.Nodup := by
    exact natFiniteWindowValues_not_nodup f B hBound
  let duplicate :=
    natList_duplicate_indices_data_of_not_nodup
      values
      hNotNodup
  have hValuesLength : values.length = B + 2 := by
    unfold values
    rw [natWindowValuesFrom_length]
  have hjLt : duplicate.rightIndex < B + 2 := by
    have hRightLt := duplicate.right_lt_length
    rw [hValuesLength] at hRightLt
    exact hRightLt
  have hiLt : duplicate.leftIndex < B + 2 :=
    Nat.lt_trans duplicate.left_lt_right hjLt
  have hjLe : duplicate.rightIndex ≤ B + 1 :=
    Nat.le_of_lt_succ hjLt
  have hiValue :
      natListNth? values duplicate.leftIndex =
        some (f duplicate.leftIndex) := by
    unfold values
    simpa [Nat.zero_add] using
      natWindowValuesFrom_nth f 0 (B + 2) duplicate.leftIndex hiLt
  have hjValue :
      natListNth? values duplicate.rightIndex =
        some (f duplicate.rightIndex) := by
    unfold values
    simpa [Nat.zero_add] using
      natWindowValuesFrom_nth f 0 (B + 2) duplicate.rightIndex hjLt
  have hLeftReads := duplicate.left_reads
  have hRightReads := duplicate.right_reads
  rw [hiValue] at hLeftReads
  rw [hjValue] at hRightReads
  injection hLeftReads with hfi
  injection hRightReads with hfj
  exact
    { leftIndex := duplicate.leftIndex
      rightIndex := duplicate.rightIndex
      left_lt_right := duplicate.left_lt_right
      right_le_bound_succ := hjLe
      values_eq := by
        rw [hfi, hfj] }

/--
Constructive finite pigeonhole for a bounded natural-number window.

Values `f 0, ..., f (B + 1)` all bounded by `B` force two distinct positions in
that same finite window to carry the same value.
-/
theorem natFiniteWindowCollision_of_bounded
    (f : Nat → Nat) (B : Nat)
    (hBound : ∀ t : Nat, t ≤ B + 1 → f t ≤ B) :
    ∃ i j : Nat,
      i < j ∧ j ≤ B + 1 ∧ f i = f j := by
  let collision := natFiniteWindowCollisionData_of_bounded f B hBound
  refine
    ⟨collision.leftIndex,
      collision.rightIndex,
      collision.left_lt_right,
      collision.right_le_bound_succ,
      collision.values_eq⟩

end EnrichedNatClosedStabilityInstance
end Clean
end Standalone
end LocalSemanticClosure

/- AXIOM_AUDIT_BEGIN -/
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.natList_duplicate_indices_data_of_not_nodup
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.natFiniteWindowCollisionData_of_bounded
#print axioms LocalSemanticClosure.Standalone.Clean.EnrichedNatClosedStabilityInstance.natFiniteWindowCollision_of_bounded
/- AXIOM_AUDIT_END -/
