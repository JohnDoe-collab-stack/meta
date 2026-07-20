import Meta.Tarski.BareArithmetic.PrimitiveRecursive
import Mathlib.Logic.Godel.GodelBetaFunction

/-!
# Arithmetic formula tools for constructive representability

This module contains only reusable infrastructure.  It gives finite vectors of
arithmetic terms, simultaneous graph application, blocks of existential
quantifiers, and the ordinary arithmetic formula defining one value of
Goedel's beta sequence.

The beta existence theorem is imported from Mathlib's constructive natural
number development.  No declaration from `Foundation` is imported.
-/

namespace Meta
namespace BareArithmeticTarski

/-! ## Total access to finite vectors -/

/-- Total vector access, returning zero outside the indexed extent. -/
def NatVector.getD {length : Nat} (values : NatVector length) : Nat -> Nat
  | 0 =>
      match values with
      | NatVector.nil => 0
      | NatVector.cons head _tail => head
  | Nat.succ index =>
      match values with
      | NatVector.nil => 0
      | NatVector.cons _head tail => tail.getD index

/-- Total access agrees with proof-indexed access inside the extent. -/
theorem NatVector.getD_eq_get
    {length index : Nat}
    (values : NatVector length)
    (bounded : index < length) :
    values.getD index = values.get index bounded := by
  induction values generalizing index with
  | nil =>
      exact (Nat.not_lt_zero index bounded).elim
  | @cons length head tail inductionHypothesis =>
      cases index with
      | zero => rfl
      | succ index =>
          exact inductionHypothesis (Nat.lt_of_succ_lt_succ bounded)

/-- A length-indexed vector of raw arithmetic terms. -/
inductive RawTermVector : Nat -> Type
  | nil : RawTermVector 0
  | cons {length : Nat} :
      RawTerm -> RawTermVector length -> RawTermVector (Nat.succ length)

/-- Total access to a term vector, with arithmetic zero as the default. -/
def RawTermVector.getD
    {length : Nat}
    (terms : RawTermVector length) :
    Nat -> RawTerm
  | 0 =>
      match terms with
      | RawTermVector.nil => RawTerm.zero
      | RawTermVector.cons head _tail => head
  | Nat.succ index =>
      match terms with
      | RawTermVector.nil => RawTerm.zero
      | RawTermVector.cons _head tail => tail.getD index

/-- Pointwise scoping of a finite term vector. -/
def RawTermVector.WellScoped
    (bound : Nat) :
    {length : Nat} -> RawTermVector length -> Prop
  | 0, RawTermVector.nil => True
  | Nat.succ _length, RawTermVector.cons head tail =>
      head.WellScoped bound ∧ tail.WellScoped bound

/-- Evaluation of a finite vector of terms. -/
def RawTermVector.evaluate
    {length : Nat}
    (terms : RawTermVector length)
    (environment : Environment) :
    NatVector length :=
  match terms with
  | RawTermVector.nil => NatVector.nil
  | RawTermVector.cons head tail =>
      NatVector.cons (head.evaluate environment) (tail.evaluate environment)

/-- Total access commutes with evaluation. -/
theorem RawTermVector.evaluate_getD
    {length : Nat}
    (terms : RawTermVector length)
    (environment : Environment)
    (index : Nat) :
    (terms.evaluate environment).getD index =
      (terms.getD index).evaluate environment := by
  induction terms generalizing index with
  | nil =>
      cases index <;> rfl
  | cons head tail inductionHypothesis =>
      cases index with
      | zero => rfl
      | succ index => exact inductionHypothesis index

/-- Every total vector component is scoped when the vector is scoped. -/
theorem RawTermVector.getD_wellScoped
    {length bound : Nat}
    (terms : RawTermVector length)
    (scoped : terms.WellScoped bound)
    (index : Nat) :
    (terms.getD index).WellScoped bound := by
  induction terms generalizing index with
  | nil =>
      cases index <;> exact trivial
  | cons head tail inductionHypothesis =>
      cases index with
      | zero => exact scoped.1
      | succ index => exact inductionHypothesis scoped.2 index

/-- Consecutive variables beginning at `start`. -/
def RawTermVector.variables :
    (start length : Nat) -> RawTermVector length
  | _start, 0 => RawTermVector.nil
  | start, Nat.succ length =>
      RawTermVector.cons
        (RawTerm.bvar start)
        (RawTermVector.variables (Nat.succ start) length)

/-- Consecutive variables are scoped below any common upper bound. -/
theorem RawTermVector.variables_wellScoped
    (start length bound : Nat)
    (bounded : start + length <= bound) :
    (RawTermVector.variables start length).WellScoped bound := by
  induction length generalizing start with
  | zero => exact trivial
  | succ length inductionHypothesis =>
      constructor
      · exact Nat.lt_of_lt_of_le
          (Nat.lt_add_of_pos_right (Nat.succ_pos length))
          bounded
      · apply inductionHypothesis (Nat.succ start)
        rw [Nat.succ_add]
        exact bounded

/-! ## Environments and existential blocks -/

/-- Prefix an environment by all entries of a finite vector. -/
def prependEnvironment :
    {length : Nat} -> NatVector length -> Environment -> Environment
  | 0, NatVector.nil, environment => environment
  | Nat.succ _length, NatVector.cons head tail, environment =>
      pushEnvironment (prependEnvironment tail environment) head

/-- Looking inside the prefix returns the corresponding vector entry. -/
theorem prependEnvironment_get
    {length index : Nat}
    (values : NatVector length)
    (environment : Environment)
    (bounded : index < length) :
    prependEnvironment values environment index =
      values.get index bounded := by
  induction values generalizing index with
  | nil => exact (Nat.not_lt_zero index bounded).elim
  | cons head tail inductionHypothesis =>
      cases index with
      | zero => rfl
      | succ index =>
          exact inductionHypothesis (Nat.lt_of_succ_lt_succ bounded)

/-- Variables beyond the prefix are read from the original environment. -/
theorem prependEnvironment_shift
    {length : Nat}
    (values : NatVector length)
    (environment : Environment)
    (index : Nat) :
    prependEnvironment values environment (length + index) =
      environment index := by
  induction values with
  | nil => rfl
  | @cons length head tail inductionHypothesis =>
      change
        prependEnvironment tail environment (length + index) =
          environment index
      exact inductionHypothesis

/-- Bind `count` consecutive variables around a formula. -/
def RawFormula.existsMany : Nat -> RawFormula -> RawFormula
  | 0, body => body
  | Nat.succ count, body =>
      RawFormula.existsMany count (RawFormula.ex body)

/-- A block of existentials binds exactly its prefixed environment. -/
theorem RawFormula.existsMany_holds
    (count : Nat)
    (body : RawFormula)
    (environment : Environment) :
    (body.existsMany count).Holds environment ↔
      Exists fun values : NatVector count =>
        body.Holds (prependEnvironment values environment) := by
  induction count with
  | zero =>
      constructor
      · intro bodyHolds
        exact Exists.intro NatVector.nil bodyHolds
      · intro witness
        cases witness with
        | intro values bodyHolds =>
            cases values
            exact bodyHolds
  | succ count inductionHypothesis =>
      apply Iff.trans (inductionHypothesis (RawFormula.ex body) environment)
      constructor
      · intro witness
        cases witness with
        | intro tailValues existentialHolds =>
            cases existentialHolds with
            | intro headValue bodyHolds =>
                exact Exists.intro
                  (NatVector.cons headValue tailValues)
                  bodyHolds
      · intro witness
        cases witness with
        | intro values bodyHolds =>
            cases values with
            | cons headValue tailValues =>
                exact Exists.intro tailValues
                  (Exists.intro headValue bodyHolds)

/-- Existential blocks remove the corresponding number of free variables. -/
theorem RawFormula.existsMany_wellScoped
    (count bound : Nat)
    (body : RawFormula)
    (scoped : body.WellScoped (count + bound)) :
    (body.existsMany count).WellScoped bound := by
  induction count with
  | zero => exact scoped
  | succ count inductionHypothesis =>
      apply inductionHypothesis (RawFormula.ex body)
      change body.WellScoped (Nat.succ (count + bound))
      rw [← Nat.succ_add]
      exact scoped

/-! ## Graph application by ordinary substitution -/

/-- Environment convention for a graph: output first, then all inputs. -/
def graphEnvironment
    {arity : Nat}
    (inputs : NatVector arity)
    (output : Nat) :
    Environment
  | 0 => output
  | Nat.succ index => inputs.getD index

/-- A raw graph formula paired with its exact arity scoping certificate. -/
structure ArithmeticGraph (arity : Nat) where
  raw : RawFormula
  isScoped : raw.WellScoped (Nat.succ arity)

/-- Semantic graph holding under the output-first convention. -/
def ArithmeticGraph.Holds
    {arity : Nat}
    (graph : ArithmeticGraph arity)
    (inputs : NatVector arity)
    (output : Nat) :
    Prop :=
  graph.raw.Holds (graphEnvironment inputs output)

/-- Substitute an output term and an input vector into a graph formula. -/
def ArithmeticGraph.apply
    {arity : Nat}
    (graph : ArithmeticGraph arity)
    (output : RawTerm)
    (inputs : RawTermVector arity) :
    RawFormula :=
  graph.raw.substitute fun index =>
    match index with
    | 0 => output
    | Nat.succ inputIndex => inputs.getD inputIndex

/-- Graph application has the expected pointwise semantics. -/
theorem ArithmeticGraph.apply_holds
    {arity : Nat}
    (graph : ArithmeticGraph arity)
    (output : RawTerm)
    (inputs : RawTermVector arity)
    (environment : Environment) :
    (graph.apply output inputs).Holds environment ↔
      graph.Holds
        (inputs.evaluate environment)
        (output.evaluate environment) := by
  apply Iff.trans
    (graph.raw.holds_substitute
      (fun index =>
        match index with
        | 0 => output
        | Nat.succ inputIndex => inputs.getD inputIndex)
      environment)
  apply graph.raw.holds_iff_of_scoped_agreement graph.isScoped
  intro index bounded
  cases index with
  | zero => rfl
  | succ index =>
      exact (RawTermVector.evaluate_getD inputs environment index).symm

/-- Graph application preserves any common target scope. -/
theorem ArithmeticGraph.apply_wellScoped
    {arity bound : Nat}
    (graph : ArithmeticGraph arity)
    (output : RawTerm)
    (inputs : RawTermVector arity)
    (outputScoped : output.WellScoped bound)
    (inputsScoped : inputs.WellScoped bound) :
    (graph.apply output inputs).WellScoped bound :=
  graph.raw.wellScoped_substitute
    graph.isScoped
    (fun index =>
      match index with
      | 0 => output
      | Nat.succ inputIndex => inputs.getD inputIndex)
    (by
      intro index bounded
      cases index with
      | zero => exact outputScoped
      | succ inputIndex =>
          exact inputs.getD_wellScoped inputsScoped inputIndex)

/-! ## The arithmetic beta relation -/

/-- Shift a term below one newly introduced binder. -/
def RawTerm.shift (term : RawTerm) : RawTerm :=
  term.rename Nat.succ

/-- Shifting a scoped term places it below one additional binder. -/
theorem RawTerm.shift_wellScoped
    {bound : Nat}
    (term : RawTerm)
    (scoped : term.WellScoped bound) :
    term.shift.WellScoped (Nat.succ bound) :=
  term.wellScoped_rename scoped Nat.succ
    (fun _index bounded => Nat.succ_lt_succ bounded)

/-- Ordinary arithmetic strict order, expressed using one existential gap. -/
def lessThanFormula (left right : RawTerm) : RawFormula :=
  RawFormula.ex
    (RawFormula.equal
      (RawTerm.add left.shift (RawTerm.succ (RawTerm.bvar 0)))
      right.shift)

/-- The strict-order formula preserves the common term scope. -/
theorem lessThanFormula_wellScoped
    {bound : Nat}
    (left right : RawTerm)
    (leftScoped : left.WellScoped bound)
    (rightScoped : right.WellScoped bound) :
    (lessThanFormula left right).WellScoped bound :=
  And.intro
    (And.intro
      (left.shift_wellScoped leftScoped)
      (And.intro trivial (Nat.zero_lt_succ bound)))
    (right.shift_wellScoped rightScoped)

/-- The strict-order formula has its standard natural-number semantics. -/
theorem lessThanFormula_holds
    (left right : RawTerm)
    (environment : Environment) :
    (lessThanFormula left right).Holds environment ↔
      left.evaluate environment < right.evaluate environment := by
  change
    (Exists fun gap : Nat =>
      (RawTerm.add left.shift (RawTerm.succ (RawTerm.bvar 0))).evaluate
          (pushEnvironment environment gap) =
        right.shift.evaluate (pushEnvironment environment gap)) ↔
      left.evaluate environment < right.evaluate environment
  rw [left.evaluate_rename, right.evaluate_rename]
  change
    (Exists fun gap : Nat =>
      left.evaluate environment + Nat.succ gap = right.evaluate environment) ↔
      left.evaluate environment < right.evaluate environment
  constructor
  · intro witness
    cases witness with
    | intro gap equality =>
        rw [← equality]
        exact Nat.lt_add_of_pos_right (Nat.succ_pos gap)
  · intro strict
    cases Nat.exists_eq_add_of_lt strict with
    | intro gap equality =>
        cases gap with
        | zero =>
            exact (Nat.lt_irrefl _ (equality ▸ strict)).elim
        | succ gap =>
            exact Exists.intro gap (by
              rw [Nat.add_comm] at equality
              exact equality.symm)

/-- `remainder` is the remainder of `dividend` modulo positive `modulus`. -/
def remainderFormula
    (dividend modulus remainder : RawTerm) :
    RawFormula :=
  RawFormula.conj
    (lessThanFormula remainder modulus)
    (RawFormula.ex
      (RawFormula.equal
        dividend.shift
        (RawTerm.add
          (RawTerm.mul (RawTerm.bvar 0) modulus.shift)
          remainder.shift)))

/-- The remainder formula preserves the common scope of its terms. -/
theorem remainderFormula_wellScoped
    {bound : Nat}
    (dividend modulus remainder : RawTerm)
    (dividendScoped : dividend.WellScoped bound)
    (modulusScoped : modulus.WellScoped bound)
    (remainderScoped : remainder.WellScoped bound) :
    (remainderFormula dividend modulus remainder).WellScoped bound :=
  And.intro
    (lessThanFormula_wellScoped
      remainder modulus remainderScoped modulusScoped)
    (And.intro
      (dividend.shift_wellScoped dividendScoped)
      (And.intro
        (And.intro
          (Nat.zero_lt_succ bound)
          (modulus.shift_wellScoped modulusScoped))
        (remainder.shift_wellScoped remainderScoped)))

/-- Arithmetic remainder is characterized by a bounded quotient equation. -/
theorem remainderFormula_holds
    (dividend modulus remainder : RawTerm)
    (environment : Environment) :
    (remainderFormula dividend modulus remainder).Holds environment ↔
      remainder.evaluate environment < modulus.evaluate environment ∧
      Exists fun quotient : Nat =>
        dividend.evaluate environment =
          quotient * modulus.evaluate environment +
            remainder.evaluate environment := by
  apply and_congr (lessThanFormula_holds remainder modulus environment)
  change
    (Exists fun quotient : Nat =>
      dividend.shift.evaluate (pushEnvironment environment quotient) =
        (RawTerm.add
          (RawTerm.mul (RawTerm.bvar 0) modulus.shift)
          remainder.shift).evaluate
            (pushEnvironment environment quotient)) ↔ _
  rw [dividend.evaluate_rename, modulus.evaluate_rename,
    remainder.evaluate_rename]

/-- Bounded quotient equations are exactly natural remainders. -/
theorem remainder_characterization
    (dividend modulus remainder : Nat)
    (positive : 0 < modulus) :
    (remainder < modulus ∧
      Exists fun quotient : Nat =>
        dividend = quotient * modulus + remainder) ↔
      remainder = dividend % modulus := by
  constructor
  · intro characterization
    cases characterization with
    | intro bounded witness =>
        cases witness with
        | intro quotient equality =>
            rw [equality, Nat.add_mod, Nat.mul_mod,
              Nat.zero_add, Nat.mod_eq_of_lt bounded]
  · intro equality
    cases equality
    constructor
    · exact Nat.mod_lt dividend positive
    · exact Exists.intro (dividend / modulus) (by
        have division := Nat.mod_add_div dividend modulus
        rw [Nat.mul_comm] at division
        exact division.symm)

/-- The modulus used by one component of Goedel's beta sequence. -/
def betaModulusTerm (coefficient index : RawTerm) : RawTerm :=
  RawTerm.succ
    (RawTerm.mul (RawTerm.succ index) coefficient)

/-- Arithmetic formula for one beta-sequence lookup. -/
def betaValueFormula
    (dividend coefficient index value : RawTerm) :
    RawFormula :=
  remainderFormula
    dividend
    (betaModulusTerm coefficient index)
    value

/-- The beta lookup formula preserves the common scope of its four terms. -/
theorem betaValueFormula_wellScoped
    {bound : Nat}
    (dividend coefficient index value : RawTerm)
    (dividendScoped : dividend.WellScoped bound)
    (coefficientScoped : coefficient.WellScoped bound)
    (indexScoped : index.WellScoped bound)
    (valueScoped : value.WellScoped bound) :
    (betaValueFormula dividend coefficient index value).WellScoped bound :=
  remainderFormula_wellScoped
    dividend
    (betaModulusTerm coefficient index)
    value
    dividendScoped
    (And.intro (And.intro indexScoped trivial) coefficientScoped)
    valueScoped

/-- The beta lookup formula computes the intended remainder. -/
theorem betaValueFormula_holds
    (dividend coefficient index value : RawTerm)
    (environment : Environment) :
    (betaValueFormula dividend coefficient index value).Holds environment ↔
      value.evaluate environment =
        dividend.evaluate environment %
          ((index.evaluate environment + 1) *
            coefficient.evaluate environment + 1) := by
  apply Iff.trans
    (remainderFormula_holds
      dividend
      (betaModulusTerm coefficient index)
      value
      environment)
  change
    (value.evaluate environment <
        Nat.succ
          (Nat.succ (index.evaluate environment) *
            coefficient.evaluate environment) ∧
      Exists fun quotient : Nat =>
        dividend.evaluate environment =
          quotient *
              Nat.succ
                (Nat.succ (index.evaluate environment) *
                  coefficient.evaluate environment) +
            value.evaluate environment) ↔ _
  rw [remainder_characterization
    (dividend.evaluate environment)
    (Nat.succ
      (Nat.succ (index.evaluate environment) *
        coefficient.evaluate environment))
    (value.evaluate environment)
    (Nat.succ_pos _)]
  change
    value.evaluate environment =
      dividend.evaluate environment %
        Nat.succ
          (Nat.succ (index.evaluate environment) *
            coefficient.evaluate environment) ↔ _
  rw [Nat.succ_eq_add_one, Nat.succ_eq_add_one]

end BareArithmeticTarski
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.BareArithmeticTarski.RawFormula.existsMany_holds
#print axioms Meta.BareArithmeticTarski.ArithmeticGraph.apply_holds
#print axioms Meta.BareArithmeticTarski.betaValueFormula_wellScoped
#print axioms Meta.BareArithmeticTarski.lessThanFormula_holds
#print axioms Meta.BareArithmeticTarski.remainder_characterization
#print axioms Meta.BareArithmeticTarski.betaValueFormula_holds
#print axioms Nat.beta_unbeta_coe
/- AXIOM_AUDIT_END -/
