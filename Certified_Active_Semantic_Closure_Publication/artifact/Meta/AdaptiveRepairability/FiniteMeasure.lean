import Std

namespace Meta.AdaptiveRepairability

/-!
Constructive finite semantics for action-relevant latent ambiguity.

The conflict measure is computed over one fixed enumeration of world pairs.  This
choice makes strict decrease a theorem about filtering a fixed finite carrier;
it does not require finite-set quotients, classical choice, or proof-irrelevant
cardinality arguments.
-/

structure FiniteActionModel where
  World : Type
  State : Type
  Obligation : Type
  Action : Type
  worlds : List World
  worlds_nodup : worlds.Nodup
  worlds_complete : ∀ w, w ∈ worlds
  worldEq : (w₁ w₂ : World) → Decidable (w₁ = w₂)
  compatible : State → World → Bool
  required : Obligation → World → Action
  actionEq : (a b : Action) → Decidable (a = b)

def Compatible (E : FiniteActionModel) (s : E.State) (w : E.World) : Prop :=
  E.compatible s w = true

def FiberIncluded (E : FiniteActionModel) (after before : E.State) : Prop :=
  ∀ w, Compatible E after w → Compatible E before w

def ActionSufficientAt
    (E : FiniteActionModel) (s : E.State) (g : E.Obligation) : Prop :=
  ∀ w₁ w₂,
    Compatible E s w₁ →
    Compatible E s w₂ →
    E.required g w₁ = E.required g w₂

def ActionConflict
    (E : FiniteActionModel) (s : E.State) (g : E.Obligation)
    (w₁ w₂ : E.World) : Prop :=
  Compatible E s w₁ ∧
  Compatible E s w₂ ∧
  E.required g w₁ ≠ E.required g w₂

def pairWith (x : α) : List β → List (α × β)
  | [] => []
  | y :: ys => (x, y) :: pairWith x ys

def orderedPairs : List α → List β → List (α × β)
  | [], _ => []
  | x :: xs, ys => pairWith x ys ++ orderedPairs xs ys

private theorem mem_append_left
    {x : α} {xs ys : List α} (hmem : x ∈ xs) : x ∈ xs ++ ys := by
  induction hmem with
  | head tail => exact List.Mem.head (tail ++ ys)
  | tail head hmem ih => exact List.Mem.tail head ih

private theorem mem_append_right
    {x : α} (xs : List α) {ys : List α} (hmem : x ∈ ys) : x ∈ xs ++ ys := by
  induction xs with
  | nil => exact hmem
  | cons head tail ih => exact List.Mem.tail head ih

private theorem mem_pairWith_of_mem
    (x : α) {y : β} {ys : List β} (hmem : y ∈ ys) :
    (x, y) ∈ pairWith x ys := by
  induction hmem with
  | head tail => exact List.Mem.head (pairWith x tail)
  | tail head hmem ih => exact List.Mem.tail (x, head) ih

theorem mem_orderedPairs_of_mem
    {x : α} {y : β} {xs : List α} {ys : List β}
    (hx : x ∈ xs) (hy : y ∈ ys) :
    (x, y) ∈ orderedPairs xs ys := by
  induction hx with
  | head tail =>
      exact mem_append_left (mem_pairWith_of_mem x hy)
  | tail head hmem ih =>
      exact mem_append_right (pairWith head ys) ih

def actionDiffB
    (E : FiniteActionModel) (g : E.Obligation) (w₁ w₂ : E.World) : Bool :=
  match E.actionEq (E.required g w₁) (E.required g w₂) with
  | isTrue _ => false
  | isFalse _ => true

theorem actionDiffB_eq_true_iff
    (E : FiniteActionModel) (g : E.Obligation) (w₁ w₂ : E.World) :
    actionDiffB E g w₁ w₂ = true ↔
      E.required g w₁ ≠ E.required g w₂ := by
  cases hdecision : E.actionEq (E.required g w₁) (E.required g w₂) with
  | isTrue heq =>
      constructor
      · intro htrue
        unfold actionDiffB at htrue
        rw [hdecision] at htrue
        exact False.elim (Bool.noConfusion htrue)
      · intro hneq
        exact False.elim (hneq heq)
  | isFalse hneq =>
      constructor
      · intro _
        exact hneq
      · intro _
        unfold actionDiffB
        rw [hdecision]

def conflictB
    (E : FiniteActionModel) (s : E.State) (g : E.Obligation)
    (pair : E.World × E.World) : Bool :=
  (E.compatible s pair.1 && E.compatible s pair.2) &&
    actionDiffB E g pair.1 pair.2

theorem conflictB_eq_true_iff
    (E : FiniteActionModel) (s : E.State) (g : E.Obligation)
    (pair : E.World × E.World) :
    conflictB E s g pair = true ↔
      ActionConflict E s g pair.1 pair.2 := by
  constructor
  · intro htrue
    cases h₁ : E.compatible s pair.1 with
    | false =>
        unfold conflictB at htrue
        rw [h₁] at htrue
        exact False.elim (Bool.noConfusion htrue)
    | true =>
        cases h₂ : E.compatible s pair.2 with
        | false =>
            unfold conflictB at htrue
            rw [h₁, h₂] at htrue
            exact False.elim (Bool.noConfusion htrue)
        | true =>
            have hdiffB : actionDiffB E g pair.1 pair.2 = true := by
              unfold conflictB at htrue
              rw [h₁, h₂] at htrue
              exact htrue
            exact ⟨h₁, h₂,
              (actionDiffB_eq_true_iff E g pair.1 pair.2).mp hdiffB⟩
  · rintro ⟨h₁, h₂, hdiff⟩
    have hdiffB := (actionDiffB_eq_true_iff E g pair.1 pair.2).mpr hdiff
    unfold conflictB
    rw [h₁, h₂, hdiffB]
    rfl

def allWorldPairs (E : FiniteActionModel) : List (E.World × E.World) :=
  orderedPairs E.worlds E.worlds

theorem mem_allWorldPairs
    (E : FiniteActionModel) (w₁ w₂ : E.World) :
    (w₁, w₂) ∈ allWorldPairs E := by
  exact mem_orderedPairs_of_mem (E.worlds_complete w₁) (E.worlds_complete w₂)

def conflictPairs
    (E : FiniteActionModel) (s : E.State) (g : E.Obligation) :
    List (E.World × E.World) :=
  (allWorldPairs E).filter (conflictB E s g)

theorem filterMemberPredicateTrue
    (p : α → Bool) {x : α} :
    ∀ {xs : List α}, x ∈ xs.filter p → p x = true := by
  intro xs hmem
  induction xs with
  | nil => cases hmem
  | cons head tail ih =>
      cases hhead : p head with
      | false =>
          rw [List.filter, hhead] at hmem
          exact ih hmem
      | true =>
          rw [List.filter, hhead] at hmem
          cases hmem with
          | head => exact hhead
          | tail _ htail => exact ih htail

theorem memFilterOfMemOfTrue
    (p : α → Bool) {x : α} :
    ∀ {xs : List α}, x ∈ xs → p x = true → x ∈ xs.filter p := by
  intro xs hmem hp
  induction hmem with
  | head tail =>
      rw [List.filter, hp]
      exact List.Mem.head (tail.filter p)
  | tail head hmem ih =>
      cases hhead : p head with
      | false =>
          rw [List.filter, hhead]
          exact ih
      | true =>
          rw [List.filter, hhead]
          exact List.Mem.tail head ih

theorem mem_conflictPairs_iff
    (E : FiniteActionModel) (s : E.State) (g : E.Obligation)
    (w₁ w₂ : E.World) :
    (w₁, w₂) ∈ conflictPairs E s g ↔ ActionConflict E s g w₁ w₂ := by
  constructor
  · intro hmem
    have htrue := filterMemberPredicateTrue (conflictB E s g) hmem
    exact (conflictB_eq_true_iff E s g (w₁, w₂)).mp htrue
  · intro hconflict
    exact memFilterOfMemOfTrue
      (conflictB E s g)
      (mem_allWorldPairs E w₁ w₂)
      ((conflictB_eq_true_iff E s g (w₁, w₂)).mpr hconflict)

def actionConflictMeasure
    (E : FiniteActionModel) (s : E.State) (g : E.Obligation) : Nat :=
  (conflictPairs E s g).length

private theorem list_eq_nil_of_no_member
    (xs : List α) (h : ∀ x, x ∈ xs → False) : xs = [] := by
  cases xs with
  | nil => rfl
  | cons x tail =>
      exact False.elim (h x (List.Mem.head tail))

theorem actionConflictMeasure_eq_zero_iff
    (E : FiniteActionModel) (s : E.State) (g : E.Obligation) :
    actionConflictMeasure E s g = 0 ↔ ActionSufficientAt E s g := by
  constructor
  · intro hzero w₁ w₂ hw₁ hw₂
    cases E.actionEq (E.required g w₁) (E.required g w₂) with
    | isTrue heq => exact heq
    | isFalse hneq =>
        have hmem : (w₁, w₂) ∈ conflictPairs E s g :=
          (mem_conflictPairs_iff E s g w₁ w₂).mpr ⟨hw₁, hw₂, hneq⟩
        cases hpairs : conflictPairs E s g with
        | nil =>
            have hempty : (w₁, w₂) ∈ ([] : List (E.World × E.World)) := by
              rw [← hpairs]
              exact hmem
            exact False.elim (nomatch hempty)
        | cons pair tail =>
            have hsucc : Nat.succ tail.length = 0 := by
              unfold actionConflictMeasure at hzero
              rw [hpairs] at hzero
              exact hzero
            exact False.elim (Nat.noConfusion hsucc)
  · intro hsufficient
    have hnil : conflictPairs E s g = [] := by
      apply list_eq_nil_of_no_member
      intro pair hpair
      have hconflict : ActionConflict E s g pair.1 pair.2 := by
        exact (conflictB_eq_true_iff E s g pair).mp
          (filterMemberPredicateTrue (conflictB E s g) hpair)
      exact hconflict.2.2 (hsufficient pair.1 pair.2 hconflict.1 hconflict.2.1)
    unfold actionConflictMeasure
    rw [hnil]
    rfl

private theorem filter_length_le_of_imp
    (p q : α → Bool)
    (himp : ∀ x, p x = true → q x = true) :
    ∀ xs : List α, (xs.filter p).length ≤ (xs.filter q).length := by
  intro xs
  induction xs with
  | nil => exact Nat.le_refl 0
  | cons x tail ih =>
      cases hp : p x with
      | false =>
          cases hq : q x with
          | false =>
              rw [List.filter, hp, List.filter, hq]
              exact ih
          | true =>
              rw [List.filter, hp, List.filter, hq]
              exact Nat.le_succ_of_le ih
      | true =>
          have hq : q x = true := himp x hp
          rw [List.filter, hp, List.filter, hq]
          exact Nat.succ_le_succ ih

private theorem filter_length_lt_of_imp_of_witness
    (p q : α → Bool)
    (himp : ∀ x, p x = true → q x = true)
    (xs : List α) (witness : α)
    (hwitness : witness ∈ xs)
    (hp : p witness = false)
    (hq : q witness = true) :
    (xs.filter p).length < (xs.filter q).length := by
  revert witness
  induction xs with
  | nil =>
      intro witness hwitness
      exact nomatch hwitness
  | cons x tail ih =>
      intro witness hwitness hp hq
      cases hwitness with
      | head =>
          rw [List.filter, hp, List.filter, hq]
          exact Nat.lt_succ_of_le (filter_length_le_of_imp p q himp tail)
      | tail _ htail =>
          cases hxP : p x with
          | false =>
              cases hxQ : q x with
              | false =>
                  rw [List.filter, hxP, List.filter, hxQ]
                  exact ih witness htail hp hq
              | true =>
                  rw [List.filter, hxP, List.filter, hxQ]
                  exact Nat.lt_succ_of_le (filter_length_le_of_imp p q himp tail)
          | true =>
              have hxQ : q x = true := himp x hxP
              rw [List.filter, hxP, List.filter, hxQ]
              exact Nat.succ_lt_succ (ih witness htail hp hq)

theorem actionConflictMeasure_monotone
    (E : FiniteActionModel)
    (before after : E.State)
    (g : E.Obligation)
    (hincluded : FiberIncluded E after before) :
    actionConflictMeasure E after g ≤ actionConflictMeasure E before g := by
  unfold actionConflictMeasure conflictPairs
  apply filter_length_le_of_imp
  intro pair hafter
  have hconfAfter := (conflictB_eq_true_iff E after g pair).mp hafter
  exact (conflictB_eq_true_iff E before g pair).mpr
    ⟨hincluded pair.1 hconfAfter.1,
     hincluded pair.2 hconfAfter.2.1,
     hconfAfter.2.2⟩

theorem actionConflictMeasure_strictly_decreases
    (E : FiniteActionModel)
    (before after : E.State)
    (g : E.Obligation)
    (w₁ w₂ : E.World)
    (hincluded : FiberIncluded E after before)
    (hconflict : ActionConflict E before g w₁ w₂)
    (heliminated : ¬ (Compatible E after w₁ ∧ Compatible E after w₂)) :
    actionConflictMeasure E after g < actionConflictMeasure E before g := by
  unfold actionConflictMeasure conflictPairs
  apply filter_length_lt_of_imp_of_witness
    (p := conflictB E after g)
    (q := conflictB E before g)
    (witness := (w₁, w₂))
  · intro pair hafter
    have hconfAfter := (conflictB_eq_true_iff E after g pair).mp hafter
    exact (conflictB_eq_true_iff E before g pair).mpr
      ⟨hincluded pair.1 hconfAfter.1,
       hincluded pair.2 hconfAfter.2.1,
       hconfAfter.2.2⟩
  · exact mem_allWorldPairs E w₁ w₂
  · cases hafter : conflictB E after g (w₁, w₂) with
    | false => rfl
    | true =>
        have hafterConflict :=
          (conflictB_eq_true_iff E after g (w₁, w₂)).mp hafter
        exact False.elim (heliminated ⟨hafterConflict.1, hafterConflict.2.1⟩)
  · exact (conflictB_eq_true_iff E before g (w₁, w₂)).mpr hconflict

inductive SufficiencyInspection
    (E : FiniteActionModel) (s : E.State) (g : E.Obligation) : Type where
  | sufficient : ActionSufficientAt E s g → SufficiencyInspection E s g
  | conflict :
      (w₁ w₂ : E.World) →
      ActionConflict E s g w₁ w₂ →
      SufficiencyInspection E s g

def inspectActionSufficiency
    (E : FiniteActionModel) (s : E.State) (g : E.Obligation) :
    SufficiencyInspection E s g :=
  match hpairs : conflictPairs E s g with
  | [] => SufficiencyInspection.sufficient (by
      apply (actionConflictMeasure_eq_zero_iff E s g).mp
      unfold actionConflictMeasure
      rw [hpairs]
      rfl)
  | (w₁, w₂) :: tail => SufficiencyInspection.conflict w₁ w₂ (by
      apply (mem_conflictPairs_iff E s g w₁ w₂).mp
      rw [hpairs]
      exact List.Mem.head tail)

/- AXIOM_AUDIT_BEGIN -/
#print axioms actionConflictMeasure_eq_zero_iff
#print axioms actionConflictMeasure_monotone
#print axioms actionConflictMeasure_strictly_decreases
#print axioms inspectActionSufficiency
/- AXIOM_AUDIT_END -/
