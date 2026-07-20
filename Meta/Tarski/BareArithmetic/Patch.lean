import Meta.Tarski.BareArithmetic.Diagonal

/-!
# Intrinsic syntactic patch in bare arithmetic

The patch is the ordinary arithmetic formula

`(x = quote(d) and d) or (x != quote(d) and tau(x))`.

It never decides whether `d` is true.  Closure of `d` is transported by its
positive scoping proof.
-/

namespace Meta
namespace BareArithmeticTarski

/-- Equality of the unary input with the quoted patch index. -/
def patchIndexEquality (index : Sentence) : RawFormula :=
  RawFormula.equal
    (RawTerm.bvar 0)
    (RawTerm.numeral index.quote)

/-- Purely syntactic local repair of a unary arithmetic predicate. -/
def patch (predicate : Predicate) (index : Sentence) : Predicate :=
  let atIndex := patchIndexEquality index
  { raw := RawFormula.disj
      (RawFormula.conj atIndex index.raw)
      (RawFormula.conj (RawFormula.neg atIndex) predicate.raw)
    isScoped := And.intro
      (And.intro
        (And.intro
          (Nat.zero_lt_succ 0)
          (RawTerm.numeral_wellScoped index.quote 1))
        index.scopedOne)
      (And.intro
        (And.intro
          (And.intro
            (Nat.zero_lt_succ 0)
            (RawTerm.numeral_wellScoped index.quote 1))
          trivial)
        predicate.isScoped) }

/-- The quoted index equality is true exactly at equal quotations. -/
theorem patchIndexEquality_holds
    (index : Sentence)
    (value : Nat)
    (environment : Environment) :
    (patchIndexEquality index).Holds
        (pushEnvironment environment value) ↔
      value = index.quote := by
  change
    value = (RawTerm.numeral index.quote).evaluate
      (pushEnvironment environment value) ↔ _
  rw [RawTerm.evaluate_numeral]

/-- The patch agrees with standard truth at the selected sentence. -/
theorem patch_agrees_at
    (predicate : Predicate)
    (index : Sentence) :
    ((patch predicate index).applyNumeral index.quote).models ↔
      index.models := by
  apply Iff.trans
    ((patch predicate index).models_applyNumeral index.quote)
  change
    (((patchIndexEquality index).Holds
          (pushEnvironment emptyEnvironment index.quote) ∧
        index.raw.Holds
          (pushEnvironment emptyEnvironment index.quote)) ∨
      ((((patchIndexEquality index).Holds
          (pushEnvironment emptyEnvironment index.quote)) -> False) ∧
        predicate.raw.Holds
          (pushEnvironment emptyEnvironment index.quote))) ↔
      index.raw.Holds emptyEnvironment
  have equalityHolds :
      (patchIndexEquality index).Holds
        (pushEnvironment emptyEnvironment index.quote) :=
    (patchIndexEquality_holds index index.quote emptyEnvironment).mpr rfl
  have closedSemantics :=
    index.holds_environment_independent
      (pushEnvironment emptyEnvironment index.quote)
      emptyEnvironment
  constructor
  · intro patched
    cases patched with
    | inl selected =>
        exact closedSemantics.mp selected.2
    | inr preserved =>
        exact (preserved.1 equalityHolds).elim
  · intro modeled
    exact Or.inl
      (And.intro equalityHolds (closedSemantics.mpr modeled))

/-- Away from the selected sentence, the old predicate is preserved exactly. -/
theorem patch_preserves_off_index
    (predicate : Predicate)
    (index sentence : Sentence)
    (different : sentence = index -> False) :
    ((patch predicate index).applyNumeral sentence.quote).models ↔
      (predicate.applyNumeral sentence.quote).models := by
  apply Iff.trans
    ((patch predicate index).models_applyNumeral sentence.quote)
  have quoteDifferent : sentence.quote = index.quote -> False := by
    intro sameQuote
    exact different (Sentence.quote_injective sameQuote)
  have equalityFails :
      (patchIndexEquality index).Holds
          (pushEnvironment emptyEnvironment sentence.quote) -> False := by
    intro equalityHolds
    exact quoteDifferent
      ((patchIndexEquality_holds
        index sentence.quote emptyEnvironment).mp equalityHolds)
  change
    (((patchIndexEquality index).Holds
          (pushEnvironment emptyEnvironment sentence.quote) ∧
        index.raw.Holds
          (pushEnvironment emptyEnvironment sentence.quote)) ∨
      ((((patchIndexEquality index).Holds
          (pushEnvironment emptyEnvironment sentence.quote)) -> False) ∧
        predicate.raw.Holds
          (pushEnvironment emptyEnvironment sentence.quote))) ↔
      (predicate.applyNumeral sentence.quote).models
  constructor
  · intro patched
    cases patched with
    | inl selected => exact (equalityFails selected.1).elim
    | inr preserved =>
        exact (predicate.models_applyNumeral sentence.quote).mpr preserved.2
  · intro oldHolds
    exact Or.inr
      (And.intro equalityFails
        ((predicate.models_applyNumeral sentence.quote).mp oldHolds))

end BareArithmeticTarski
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.BareArithmeticTarski.patch
#print axioms Meta.BareArithmeticTarski.patch_agrees_at
#print axioms Meta.BareArithmeticTarski.patch_preserves_off_index
/- AXIOM_AUDIT_END -/
