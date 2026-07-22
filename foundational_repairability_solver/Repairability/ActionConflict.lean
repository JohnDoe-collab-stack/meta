import Repairability.Cardinality
import Repairability.Game

namespace Repairability.PublicGame

def actionConflictPairB
    (E : PublicGame) (s : E.State) (g : E.Goal)
    (w₁ w₂ : E.World) : Bool :=
  (E.compatible s w₁ && E.compatible s w₂) &&
    (!decideWith (E.actionEq (E.required g w₁) (E.required g w₂)))

def actionConflictMeasure
    (E : PublicGame) (s : E.State) (g : E.Goal) : Nat :=
  sumNatList (E.worlds.elements.map fun w₁ =>
    trueCount (actionConflictPairB E s g w₁) E.worlds.elements)

theorem actionConflictMeasure_eq_zero_iff
    (E : PublicGame) (s : E.State) (g : E.Goal) :
    actionConflictMeasure E s g = 0 ↔ ActionSufficient E s g := by
  constructor
  · intro hzero w₁ w₂ hw₁ hw₂
    have houter := (sumNatList_map_eq_zero_iff
      (fun w₁ => trueCount (actionConflictPairB E s g w₁)
        E.worlds.elements) E.worlds.elements).mp hzero
    have hinnerZero := houter w₁ (E.worlds.complete w₁)
    have hpairFalse := (trueCount_eq_zero_iff
      (actionConflictPairB E s g w₁) E.worlds.elements).mp hinnerZero
      w₂ (E.worlds.complete w₂)
    cases heq : decideWith
        (E.actionEq (E.required g w₁) (E.required g w₂)) with
    | true =>
        exact (decideWith_eq_true_iff
          (E.actionEq (E.required g w₁) (E.required g w₂))).mp heq
    | false =>
        have hcompatibleBoth :
            (E.compatible s w₁ && E.compatible s w₂) = true :=
          (boolAnd_eq_true_iff _ _).mpr ⟨hw₁, hw₂⟩
        have hnot :
            (!decideWith
              (E.actionEq (E.required g w₁) (E.required g w₂))) = true := by
          rw [heq]
          rfl
        have hconflict : actionConflictPairB E s g w₁ w₂ = true :=
          (boolAnd_eq_true_iff _ _).mpr ⟨hcompatibleBoth, hnot⟩
        rw [hconflict] at hpairFalse
        exact False.elim (Bool.noConfusion hpairFalse)
  · intro hsufficient
    apply (sumNatList_map_eq_zero_iff
      (fun w₁ => trueCount (actionConflictPairB E s g w₁)
        E.worlds.elements) E.worlds.elements).mpr
    intro w₁ _
    apply (trueCount_eq_zero_iff
      (actionConflictPairB E s g w₁) E.worlds.elements).mpr
    intro w₂ _
    cases hleft : E.compatible s w₁ with
    | false =>
        unfold actionConflictPairB
        rw [hleft]
        rfl
    | true =>
        cases hright : E.compatible s w₂ with
        | false =>
            unfold actionConflictPairB
            rw [hleft, hright]
            rfl
        | true =>
            have heq := hsufficient w₁ w₂ hleft hright
            have hdecide : decideWith
                (E.actionEq (E.required g w₁) (E.required g w₂)) = true :=
              (decideWith_eq_true_iff
                (E.actionEq (E.required g w₁) (E.required g w₂))).mpr heq
            unfold actionConflictPairB
            rw [hleft, hright, hdecide]
            rfl

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.actionConflictMeasure_eq_zero_iff
/- AXIOM_AUDIT_END -/
