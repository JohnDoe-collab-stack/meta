/-!
# Constructive intrinsic arithmetic syntax

This file provides a small raw arithmetic syntax independent of the
`Foundation` library.  Variables are De Bruijn indices.  Terms contain
numerals, successor, addition, and multiplication.  Formulas contain equality,
the constructive propositional connectives, quantifiers, an environment-closing
constructor, and an intrinsic fixed-point constructor.

The fixed-point constructor is part of this first reflective micro-kernel.  Its
semantics is structurally recursive: `fixed candidate` evaluates the candidate
at the computable code of that very fixed formula and negates the result.  A
later elimination layer may compile this primitive reflection into a smaller
non-reflective arithmetic syntax; no such elimination is assumed here.
-/

namespace Meta
namespace IntrinsicArithmeticSyntax

/-! ## Raw De Bruijn syntax -/

/-- Raw arithmetic terms with De Bruijn variables. -/
inductive RawTerm where
  | bvar : Nat -> RawTerm
  | numeral : Nat -> RawTerm
  | succ : RawTerm -> RawTerm
  | add : RawTerm -> RawTerm -> RawTerm
  | mul : RawTerm -> RawTerm -> RawTerm
deriving DecidableEq

/-- Raw arithmetic formulas with intrinsic closure and diagonalization. -/
inductive RawFormula where
  | falsum : RawFormula
  | equal : RawTerm -> RawTerm -> RawFormula
  | conj : RawFormula -> RawFormula -> RawFormula
  | disj : RawFormula -> RawFormula -> RawFormula
  | impl : RawFormula -> RawFormula -> RawFormula
  | all : RawFormula -> RawFormula
  | ex : RawFormula -> RawFormula
  | closed : RawFormula -> RawFormula
  | fixed : RawFormula -> RawFormula
deriving DecidableEq

/-- Constructive negation inside the raw syntax. -/
def RawFormula.neg (formula : RawFormula) : RawFormula :=
  RawFormula.impl formula RawFormula.falsum

/-! ## Computable quotation -/

/-- Doubling, defined structurally so its parity behavior is intrinsic. -/
def natDouble : Nat -> Nat
  | 0 => 0
  | Nat.succ value => Nat.succ (Nat.succ (natDouble value))

/-- Structural doubling is injective. -/
theorem natDouble_injective
    {left right : Nat}
    (sameDouble : natDouble left = natDouble right) :
    left = right := by
  induction left generalizing right with
  | zero =>
      cases right with
      | zero => rfl
      | succ right =>
          change 0 = Nat.succ (Nat.succ (natDouble right)) at sameDouble
          exact Nat.noConfusion sameDouble
  | succ left inductionHypothesis =>
      cases right with
      | zero =>
          change Nat.succ (Nat.succ (natDouble left)) = 0 at sameDouble
          exact Nat.noConfusion sameDouble
      | succ right =>
          change
            Nat.succ (Nat.succ (natDouble left)) =
              Nat.succ (Nat.succ (natDouble right)) at sameDouble
          exact
            congrArg Nat.succ
              (inductionHypothesis
                (Nat.succ.inj (Nat.succ.inj sameDouble)))

/-- A structural double can never equal the successor of a structural double. -/
theorem natDouble_ne_succ_natDouble
    (left right : Nat) :
    natDouble left = Nat.succ (natDouble right) -> False := by
  induction left generalizing right with
  | zero =>
      intro impossible
      change 0 = Nat.succ (natDouble right) at impossible
      exact Nat.noConfusion impossible
  | succ left inductionHypothesis =>
      cases right with
      | zero =>
          intro impossible
          change
            Nat.succ (Nat.succ (natDouble left)) = Nat.succ 0
              at impossible
          exact Nat.noConfusion (Nat.succ.inj impossible)
      | succ right =>
          intro impossible
          change
            Nat.succ (Nat.succ (natDouble left)) =
              Nat.succ (Nat.succ (Nat.succ (natDouble right)))
                at impossible
          exact
            inductionHypothesis right
              (Nat.succ.inj (Nat.succ.inj impossible))

/--
An explicit prefix pairing.  The first component is a finite prefix of odd
markers; the second component is terminated by a structural double.
-/
def natPair : Nat -> Nat -> Nat
  | 0, payload => natDouble payload
  | Nat.succ tag, payload =>
      Nat.succ (natDouble (natPair tag payload))

/-- Equal prefix pairs have equal components. -/
theorem natPair_injective_components
    {leftTag leftPayload rightTag rightPayload : Nat}
    (samePair :
      natPair leftTag leftPayload = natPair rightTag rightPayload) :
    leftTag = rightTag ∧ leftPayload = rightPayload := by
  induction leftTag generalizing rightTag leftPayload rightPayload with
  | zero =>
      cases rightTag with
      | zero =>
          exact ⟨rfl, natDouble_injective samePair⟩
      | succ rightTag =>
          exact
            (natDouble_ne_succ_natDouble
              leftPayload
              (natPair rightTag rightPayload)
              samePair).elim
  | succ leftTag inductionHypothesis =>
      cases rightTag with
      | zero =>
          exact
            (natDouble_ne_succ_natDouble
              rightPayload
              (natPair leftTag leftPayload)
              samePair.symm).elim
      | succ rightTag =>
          have sameInner :
              natPair leftTag leftPayload =
                natPair rightTag rightPayload :=
            natDouble_injective (Nat.succ.inj samePair)
          have components := inductionHypothesis sameInner
          exact ⟨congrArg Nat.succ components.1, components.2⟩

/-- Constructive injectivity interface for the intrinsic pairing function. -/
theorem natPair_eq_iff
    (leftTag leftPayload rightTag rightPayload : Nat) :
    natPair leftTag leftPayload = natPair rightTag rightPayload ↔
      leftTag = rightTag ∧ leftPayload = rightPayload := by
  constructor
  · exact natPair_injective_components
  · intro components
    cases components with
    | intro sameTag samePayload =>
        cases sameTag
        cases samePayload
        rfl

/-- With the prefix fixed, equality of pairs is equality of payloads. -/
theorem natPair_payload_injective
    {tag leftPayload rightPayload : Nat}
    (samePair :
      natPair tag leftPayload = natPair tag rightPayload) :
    leftPayload = rightPayload :=
  (natPair_injective_components samePair).2

/-- Pairs with provably distinct prefixes cannot be equal. -/
theorem natPair_ne_of_tag_ne
    {leftTag leftPayload rightTag rightPayload : Nat}
    (differentTags : leftTag = rightTag -> False)
    (samePair :
      natPair leftTag leftPayload = natPair rightTag rightPayload) :
    False :=
  differentTags (natPair_injective_components samePair).1

/-- Explicit structural code of a raw arithmetic term. -/
def RawTerm.code : RawTerm -> Nat
  | RawTerm.bvar index => natPair 0 index
  | RawTerm.numeral value => natPair 1 value
  | RawTerm.succ term => natPair 2 term.code
  | RawTerm.add left right => natPair 3 (natPair left.code right.code)
  | RawTerm.mul left right => natPair 4 (natPair left.code right.code)

/-- The explicit term code is injective. -/
theorem RawTerm.code_injective : Function.Injective RawTerm.code := by
  intro left right sameCode
  induction left generalizing right with
  | bvar index =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | cases natPair_payload_injective sameCode
          rfl
  | numeral value =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | cases natPair_payload_injective sameCode
          rfl
  | succ term inductionHypothesis =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | cases inductionHypothesis (natPair_payload_injective sameCode)
          rfl
  | add leftTerm rightTerm leftHypothesis rightHypothesis =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | have subterms :=
            natPair_injective_components
              (natPair_payload_injective sameCode)
          cases leftHypothesis subterms.1
          cases rightHypothesis subterms.2
          rfl
  | mul leftTerm rightTerm leftHypothesis rightHypothesis =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | have subterms :=
            natPair_injective_components
              (natPair_payload_injective sameCode)
          cases leftHypothesis subterms.1
          cases rightHypothesis subterms.2
          rfl

/-- Equality of explicit term codes is equality of terms. -/
theorem RawTerm.code_eq_code_iff (left right : RawTerm) :
    left.code = right.code ↔ left = right := by
  constructor
  · intro sameCode
    exact RawTerm.code_injective sameCode
  · intro sameTerm
    cases sameTerm
    rfl

/-- Explicit structural code of a raw arithmetic formula. -/
def RawFormula.code : RawFormula -> Nat
  | RawFormula.falsum => natPair 0 0
  | RawFormula.equal left right =>
      natPair 1 (natPair left.code right.code)
  | RawFormula.conj left right =>
      natPair 2 (natPair left.code right.code)
  | RawFormula.disj left right =>
      natPair 3 (natPair left.code right.code)
  | RawFormula.impl left right =>
      natPair 4 (natPair left.code right.code)
  | RawFormula.all body => natPair 5 body.code
  | RawFormula.ex body => natPair 6 body.code
  | RawFormula.closed body => natPair 7 body.code
  | RawFormula.fixed candidate => natPair 8 candidate.code

/-- The explicit formula code is injective. -/
theorem RawFormula.code_injective : Function.Injective RawFormula.code := by
  intro left right sameCode
  induction left generalizing right with
  | falsum =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | rfl
  | equal leftTerm rightTerm =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | have subterms :=
            natPair_injective_components
              (natPair_payload_injective sameCode)
          cases RawTerm.code_injective subterms.1
          cases RawTerm.code_injective subterms.2
          rfl
  | conj leftFormula rightFormula leftHypothesis rightHypothesis =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | have subformulas :=
            natPair_injective_components
              (natPair_payload_injective sameCode)
          cases leftHypothesis subformulas.1
          cases rightHypothesis subformulas.2
          rfl
  | disj leftFormula rightFormula leftHypothesis rightHypothesis =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | have subformulas :=
            natPair_injective_components
              (natPair_payload_injective sameCode)
          cases leftHypothesis subformulas.1
          cases rightHypothesis subformulas.2
          rfl
  | impl leftFormula rightFormula leftHypothesis rightHypothesis =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | have subformulas :=
            natPair_injective_components
              (natPair_payload_injective sameCode)
          cases leftHypothesis subformulas.1
          cases rightHypothesis subformulas.2
          rfl
  | all body inductionHypothesis =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | cases inductionHypothesis (natPair_payload_injective sameCode)
          rfl
  | ex body inductionHypothesis =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | cases inductionHypothesis (natPair_payload_injective sameCode)
          rfl
  | closed body inductionHypothesis =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | cases inductionHypothesis (natPair_payload_injective sameCode)
          rfl
  | fixed candidate inductionHypothesis =>
      cases right <;>
        first
        | exact (natPair_ne_of_tag_ne (by decide) sameCode).elim
        | cases inductionHypothesis (natPair_payload_injective sameCode)
          rfl

/-- Computable Gödel quotation of a raw arithmetic formula. -/
def quote (formula : RawFormula) : Nat :=
  formula.code

/-- Structural quotation is injective. -/
theorem quote_injective : Function.Injective quote :=
  RawFormula.code_injective

/-- Equal codes determine equal raw formulas. -/
theorem quote_eq_quote_iff (left right : RawFormula) :
    quote left = quote right ↔ left = right := by
  constructor
  · intro sameCode
    exact quote_injective sameCode
  · intro sameFormula
    cases sameFormula
    rfl

/-! ## Environments and term evaluation -/

/-- A De Bruijn environment in the standard natural-number model. -/
abbrev Environment : Type := Nat -> Nat

/-- The empty environment assigns zero to every unused variable. -/
def emptyEnvironment : Environment :=
  fun _ => 0

/-- Add one new De Bruijn value at index zero. -/
def pushEnvironment
    (environment : Environment)
    (value : Nat) :
    Environment
  | 0 => value
  | Nat.succ index => environment index

/-- Remove the first De Bruijn value from an environment. -/
def tailEnvironment
    (environment : Environment) :
    Environment :=
  fun index => environment (Nat.succ index)

/-- Evaluation of raw arithmetic terms in `Nat`. -/
def RawTerm.evaluate : RawTerm -> Environment -> Nat
  | RawTerm.bvar index, environment => environment index
  | RawTerm.numeral value, _environment => value
  | RawTerm.succ term, environment => Nat.succ (term.evaluate environment)
  | RawTerm.add left right, environment =>
      left.evaluate environment + right.evaluate environment
  | RawTerm.mul left right, environment =>
      left.evaluate environment * right.evaluate environment

/-! ## Capture-avoiding instantiation by a closed numeral -/

/-- Shift every De Bruijn index in a term by one. -/
def RawTerm.lift : RawTerm -> RawTerm
  | RawTerm.bvar index => RawTerm.bvar (Nat.succ index)
  | RawTerm.numeral value => RawTerm.numeral value
  | RawTerm.succ term => RawTerm.succ term.lift
  | RawTerm.add left right => RawTerm.add left.lift right.lift
  | RawTerm.mul left right => RawTerm.mul left.lift right.lift

/-- Insert a value at an arbitrary De Bruijn depth. -/
def insertEnvironment : Nat -> Nat -> Environment -> Environment
  | 0, value, environment => pushEnvironment environment value
  | Nat.succ depth, value, environment =>
      fun index =>
        match index with
        | 0 => environment 0
        | Nat.succ inner =>
            insertEnvironment
              depth
              value
              (tailEnvironment environment)
              inner

/-- Replace one variable by a closed numeral and lower later indices. -/
def replaceVariable : Nat -> Nat -> Nat -> RawTerm
  | 0, value, 0 => RawTerm.numeral value
  | 0, _value, Nat.succ index => RawTerm.bvar index
  | Nat.succ _depth, _value, 0 => RawTerm.bvar 0
  | Nat.succ depth, value, Nat.succ index =>
      (replaceVariable depth value index).lift

/-- Instantiate the variable at `depth` by a closed numeral. -/
def RawTerm.instantiateAt : RawTerm -> Nat -> Nat -> RawTerm
  | RawTerm.bvar index, depth, value => replaceVariable depth value index
  | RawTerm.numeral storedValue, _depth, _value =>
      RawTerm.numeral storedValue
  | RawTerm.succ term, depth, value =>
      RawTerm.succ (term.instantiateAt depth value)
  | RawTerm.add left right, depth, value =>
      RawTerm.add
        (left.instantiateAt depth value)
        (right.instantiateAt depth value)
  | RawTerm.mul left right, depth, value =>
      RawTerm.mul
        (left.instantiateAt depth value)
        (right.instantiateAt depth value)

/-- Shifted term evaluation reads the tail of the environment. -/
theorem RawTerm.evaluate_lift
    (term : RawTerm)
    (environment : Environment) :
    term.lift.evaluate environment =
      term.evaluate (tailEnvironment environment) := by
  induction term with
  | bvar index => rfl
  | numeral value => rfl
  | succ term inductionHypothesis =>
      change
        Nat.succ (term.lift.evaluate environment) =
          Nat.succ (term.evaluate (tailEnvironment environment))
      rw [inductionHypothesis]
  | add left right leftHypothesis rightHypothesis =>
      change
        left.lift.evaluate environment + right.lift.evaluate environment =
          left.evaluate (tailEnvironment environment) +
            right.evaluate (tailEnvironment environment)
      rw [leftHypothesis, rightHypothesis]
  | mul left right leftHypothesis rightHypothesis =>
      change
        left.lift.evaluate environment * right.lift.evaluate environment =
          left.evaluate (tailEnvironment environment) *
            right.evaluate (tailEnvironment environment)
      rw [leftHypothesis, rightHypothesis]

/-- Replacing one variable has exactly the inserted-environment semantics. -/
theorem evaluate_replaceVariable
    (depth value index : Nat)
    (environment : Environment) :
    (replaceVariable depth value index).evaluate environment =
      insertEnvironment depth value environment index := by
  induction depth generalizing index environment with
  | zero =>
      cases index <;> rfl
  | succ depth inductionHypothesis =>
      cases index with
      | zero => rfl
      | succ index =>
          change
            (replaceVariable depth value index).lift.evaluate environment =
              insertEnvironment
                depth
                value
                (tailEnvironment environment)
                index
          rw [RawTerm.evaluate_lift]
          exact
            inductionHypothesis
              index
              (tailEnvironment environment)

/-- Term instantiation is interpreted by insertion into the environment. -/
theorem RawTerm.evaluate_instantiateAt
    (term : RawTerm)
    (depth value : Nat)
    (environment : Environment) :
    (term.instantiateAt depth value).evaluate environment =
      term.evaluate (insertEnvironment depth value environment) := by
  induction term with
  | bvar index =>
      exact evaluate_replaceVariable depth value index environment
  | numeral numeral => rfl
  | succ term inductionHypothesis =>
      change
        Nat.succ
            ((term.instantiateAt depth value).evaluate environment) =
          Nat.succ
            (term.evaluate (insertEnvironment depth value environment))
      rw [inductionHypothesis]
  | add left right leftHypothesis rightHypothesis =>
      change
        (left.instantiateAt depth value).evaluate environment +
            (right.instantiateAt depth value).evaluate environment =
          left.evaluate (insertEnvironment depth value environment) +
            right.evaluate (insertEnvironment depth value environment)
      rw [leftHypothesis, rightHypothesis]
  | mul left right leftHypothesis rightHypothesis =>
      change
        (left.instantiateAt depth value).evaluate environment *
            (right.instantiateAt depth value).evaluate environment =
          left.evaluate (insertEnvironment depth value environment) *
            right.evaluate (insertEnvironment depth value environment)
      rw [leftHypothesis, rightHypothesis]

/-- Insertion commutes definitionally with adding a bound variable. -/
theorem insertEnvironment_succ_push
    (depth value bound : Nat)
    (environment : Environment) :
    insertEnvironment
        (Nat.succ depth)
        value
        (pushEnvironment environment bound) =
      pushEnvironment
        (insertEnvironment depth value environment)
        bound := by
  rfl

/-- Capture-avoiding instantiation throughout a raw formula. -/
def RawFormula.instantiateAt : RawFormula -> Nat -> Nat -> RawFormula
  | RawFormula.falsum, _depth, _value => RawFormula.falsum
  | RawFormula.equal left right, depth, value =>
      RawFormula.equal
        (left.instantiateAt depth value)
        (right.instantiateAt depth value)
  | RawFormula.conj left right, depth, value =>
      RawFormula.conj
        (left.instantiateAt depth value)
        (right.instantiateAt depth value)
  | RawFormula.disj left right, depth, value =>
      RawFormula.disj
        (left.instantiateAt depth value)
        (right.instantiateAt depth value)
  | RawFormula.impl left right, depth, value =>
      RawFormula.impl
        (left.instantiateAt depth value)
        (right.instantiateAt depth value)
  | RawFormula.all body, depth, value =>
      RawFormula.all
        (body.instantiateAt (Nat.succ depth) value)
  | RawFormula.ex body, depth, value =>
      RawFormula.ex
        (body.instantiateAt (Nat.succ depth) value)
  | RawFormula.closed body, _depth, _value => RawFormula.closed body
  | RawFormula.fixed candidate, _depth, _value => RawFormula.fixed candidate

/-- Instantiate the first free De Bruijn variable. -/
def RawFormula.instantiate
    (formula : RawFormula)
    (value : Nat) :
    RawFormula :=
  formula.instantiateAt 0 value

/-! ## Standard `Nat` semantics -/

/-- Constructive semantics of raw formulas in the standard natural numbers. -/
def RawFormula.Holds : RawFormula -> Environment -> Prop
  | RawFormula.falsum, _environment => False
  | RawFormula.equal left right, environment =>
      left.evaluate environment = right.evaluate environment
  | RawFormula.conj left right, environment =>
      left.Holds environment ∧ right.Holds environment
  | RawFormula.disj left right, environment =>
      left.Holds environment ∨ right.Holds environment
  | RawFormula.impl left right, environment =>
      left.Holds environment -> right.Holds environment
  | RawFormula.all body, environment =>
      forall value : Nat,
        body.Holds (pushEnvironment environment value)
  | RawFormula.ex body, environment =>
      exists value : Nat,
        body.Holds (pushEnvironment environment value)
  | RawFormula.closed body, _environment =>
      body.Holds emptyEnvironment
  | RawFormula.fixed candidate, _environment =>
      candidate.Holds
          (pushEnvironment
            emptyEnvironment
            (quote (RawFormula.fixed candidate))) ->
        False

/-- Formula instantiation has the inserted-environment semantics. -/
theorem RawFormula.holds_instantiateAt
    (formula : RawFormula)
    (depth value : Nat)
    (environment : Environment) :
    (formula.instantiateAt depth value).Holds environment ↔
      formula.Holds (insertEnvironment depth value environment) := by
  induction formula generalizing depth environment with
  | falsum =>
      exact Iff.rfl
  | equal left right =>
      change
        (left.instantiateAt depth value).evaluate environment =
            (right.instantiateAt depth value).evaluate environment ↔
          left.evaluate (insertEnvironment depth value environment) =
            right.evaluate (insertEnvironment depth value environment)
      rw [left.evaluate_instantiateAt, right.evaluate_instantiateAt]
  | conj left right leftHypothesis rightHypothesis =>
      exact
        and_congr
          (leftHypothesis depth environment)
          (rightHypothesis depth environment)
  | disj left right leftHypothesis rightHypothesis =>
      exact
        or_congr
          (leftHypothesis depth environment)
          (rightHypothesis depth environment)
  | impl left right leftHypothesis rightHypothesis =>
      constructor
      · intro implication leftHolds
        exact
          (rightHypothesis depth environment).mp
            (implication
              ((leftHypothesis depth environment).mpr leftHolds))
      · intro implication leftHolds
        exact
          (rightHypothesis depth environment).mpr
            (implication
              ((leftHypothesis depth environment).mp leftHolds))
  | all body inductionHypothesis =>
      constructor
      · intro universal bound
        have instantiated :=
          (inductionHypothesis
            (Nat.succ depth)
            (pushEnvironment environment bound)).mp
            (universal bound)
        rw [insertEnvironment_succ_push] at instantiated
        exact instantiated
      · intro universal bound
        apply
          (inductionHypothesis
            (Nat.succ depth)
            (pushEnvironment environment bound)).mpr
        rw [insertEnvironment_succ_push]
        exact universal bound
  | ex body inductionHypothesis =>
      constructor
      · intro existential
        cases existential with
        | intro bound bodyHolds =>
            refine Exists.intro bound ?_
            have instantiated :=
              (inductionHypothesis
                (Nat.succ depth)
                (pushEnvironment environment bound)).mp
                bodyHolds
            rw [insertEnvironment_succ_push] at instantiated
            exact instantiated
      · intro existential
        cases existential with
        | intro bound bodyHolds =>
            refine Exists.intro bound ?_
            apply
              (inductionHypothesis
                (Nat.succ depth)
                (pushEnvironment environment bound)).mpr
            rw [insertEnvironment_succ_push]
            exact bodyHolds
  | closed body inductionHypothesis =>
      exact Iff.rfl
  | fixed candidate inductionHypothesis =>
      exact Iff.rfl

/-- Instantiating the first variable evaluates at the pushed value. -/
theorem RawFormula.holds_instantiate
    (formula : RawFormula)
    (value : Nat)
    (environment : Environment) :
    (formula.instantiate value).Holds environment ↔
      formula.Holds (pushEnvironment environment value) :=
  formula.holds_instantiateAt 0 value environment

/-! ## Quoted application and intrinsic diagonalization -/

/-- Apply a unary raw predicate to the code of a raw sentence. -/
def applyQuote
    (candidate sentence : RawFormula) :
    RawFormula :=
  candidate.instantiate (quote sentence)

/-- Standard-model truth of a raw sentence. -/
def models (sentence : RawFormula) : Prop :=
  sentence.Holds emptyEnvironment

/-- The truth predicate induced by a raw unary candidate. -/
def truthAt
    (candidate : RawFormula)
    (sentence : RawFormula) :
    Prop :=
  models (applyQuote candidate sentence)

/-- The intrinsic diagonal sentence of a candidate. -/
def diagonal (candidate : RawFormula) : RawFormula :=
  RawFormula.fixed candidate

/-- Quoted application has the expected standard-model semantics. -/
theorem holds_applyQuote
    (candidate sentence : RawFormula) :
    models (applyQuote candidate sentence) ↔
      candidate.Holds
        (pushEnvironment emptyEnvironment (quote sentence)) :=
  candidate.holds_instantiate
    (quote sentence)
    emptyEnvironment

/-- The intrinsic diagonal constructor satisfies the Tarski fixed-point law. -/
theorem diagonal_spec
    (candidate : RawFormula) :
    models (diagonal candidate) ↔
      (models (applyQuote candidate (diagonal candidate)) -> False) := by
  constructor
  · intro diagonalHolds applicationHolds
    exact
      diagonalHolds
        ((holds_applyQuote candidate (diagonal candidate)).mp
          applicationHolds)
  · intro applicationRefuted candidateHolds
    exact
      applicationRefuted
        ((holds_applyQuote candidate (diagonal candidate)).mpr
          candidateHolds)

/-! ## Intrinsic syntactic patch -/

/-- Test whether the current input is the code of the selected sentence. -/
def codeTest (index : RawFormula) : RawFormula :=
  RawFormula.equal
    (RawTerm.bvar 0)
    (RawTerm.numeral (quote index))

/--
Purely syntactic repair of a candidate at one sentence:

`(x = quote(index) and index) or (x != quote(index) and candidate(x))`.
-/
def patchPredicate
    (candidate index : RawFormula) :
    RawFormula :=
  RawFormula.disj
    (RawFormula.conj
      (codeTest index)
      (RawFormula.closed index))
    (RawFormula.conj
      (RawFormula.neg (codeTest index))
      candidate)

/-- The intrinsic patch agrees with standard truth at the repaired index. -/
theorem patchPredicate_agrees_at
    (candidate index : RawFormula) :
    truthAt (patchPredicate candidate index) index ↔
      models index := by
  have applicationSemantics :=
    holds_applyQuote (patchPredicate candidate index) index
  exact
    applicationSemantics.trans
      (by
        change
          (((quote index = quote index) ∧ models index) ∨
              (((quote index = quote index) -> False) ∧
                candidate.Holds
                  (pushEnvironment emptyEnvironment (quote index)))) ↔
            models index
        constructor
        · intro patched
          cases patched with
          | inl selected => exact selected.2
          | inr unselected =>
              exact (unselected.1 rfl).elim
        · intro indexHolds
          exact Or.inl ⟨rfl, indexHolds⟩)

/-- Patching one sentence preserves the candidate at every other sentence. -/
theorem patchPredicate_preserves_off_index
    (candidate index sentence : RawFormula)
    (offIndex : sentence = index -> False) :
    truthAt (patchPredicate candidate index) sentence ↔
      truthAt candidate sentence := by
  have differentCode : quote sentence = quote index -> False := by
    intro sameCode
    exact offIndex (quote_injective sameCode)
  have patchedApplication :=
    holds_applyQuote (patchPredicate candidate index) sentence
  have candidateApplication :=
    holds_applyQuote candidate sentence
  apply Iff.trans patchedApplication
  apply Iff.trans ?_ candidateApplication.symm
  change
    (((quote sentence = quote index) ∧ models index) ∨
        (((quote sentence = quote index) -> False) ∧
          candidate.Holds
            (pushEnvironment emptyEnvironment (quote sentence)))) ↔
      candidate.Holds
        (pushEnvironment emptyEnvironment (quote sentence))
  constructor
  · intro patched
    cases patched with
    | inl selected =>
        exact (differentCode selected.1).elim
    | inr unselected =>
        exact unselected.2
  · intro candidateHolds
    exact Or.inr ⟨differentCode, candidateHolds⟩

end IntrinsicArithmeticSyntax
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.IntrinsicArithmeticSyntax.natPair_eq_iff
#print axioms Meta.IntrinsicArithmeticSyntax.RawTerm
#print axioms Meta.IntrinsicArithmeticSyntax.RawFormula
#print axioms Meta.IntrinsicArithmeticSyntax.RawTerm.code_injective
#print axioms Meta.IntrinsicArithmeticSyntax.RawTerm.code_eq_code_iff
#print axioms Meta.IntrinsicArithmeticSyntax.RawFormula.code_injective
#print axioms Meta.IntrinsicArithmeticSyntax.quote
#print axioms Meta.IntrinsicArithmeticSyntax.quote_injective
#print axioms Meta.IntrinsicArithmeticSyntax.RawTerm.evaluate_instantiateAt
#print axioms Meta.IntrinsicArithmeticSyntax.RawFormula.Holds
#print axioms Meta.IntrinsicArithmeticSyntax.RawFormula.holds_instantiateAt
#print axioms Meta.IntrinsicArithmeticSyntax.applyQuote
#print axioms Meta.IntrinsicArithmeticSyntax.diagonal
#print axioms Meta.IntrinsicArithmeticSyntax.diagonal_spec
#print axioms Meta.IntrinsicArithmeticSyntax.patchPredicate
#print axioms Meta.IntrinsicArithmeticSyntax.patchPredicate_agrees_at
#print axioms Meta.IntrinsicArithmeticSyntax.patchPredicate_preserves_off_index
/- AXIOM_AUDIT_END -/
