import Meta.Tarski.BareArithmetic.PrimitiveRecursiveCodeSubstitution

/-!
# Capture-avoiding substitution machine

The machine carries the current De Bruijn depth in every processing task.
Bound variables are therefore preserved and only free variables are replaced
by the quoted numeral.  Work and result stacks are positive prefix-pair codes;
no semantic oracle occurs in the machine state.
-/

namespace Meta
namespace BareArithmeticTarski

/-! ## Iterated lifted numeral substitution -/

/-- The constant numeral substitution lifted below `depth` binders. -/
def numeralSubstitutionAtDepth (value : Nat) : Nat -> Substitution
  | 0 => fun _index => RawTerm.numeral value
  | Nat.succ depth => liftSubstitution (numeralSubstitutionAtDepth value depth)

/-- Renaming does not change a closed numeral. -/
theorem RawTerm.numeral_rename_succ (value : Nat) :
    (RawTerm.numeral value).rename Nat.succ = RawTerm.numeral value := by
  induction value with
  | zero => rfl
  | succ value inductionHypothesis =>
      change RawTerm.succ ((RawTerm.numeral value).rename Nat.succ) = _
      rw [inductionHypothesis]

/-- Below the current depth, the lifted substitution preserves bound indices. -/
theorem numeralSubstitutionAtDepth_of_lt
    (value depth index : Nat)
    (bounded : index < depth) :
    numeralSubstitutionAtDepth value depth index = RawTerm.bvar index := by
  induction depth generalizing index with
  | zero => exact (Nat.not_lt_zero index bounded).elim
  | succ depth inductionHypothesis =>
      cases index with
      | zero => rfl
      | succ index =>
          change
            (numeralSubstitutionAtDepth value depth index).rename Nat.succ =
              RawTerm.bvar (Nat.succ index)
          rw [inductionHypothesis index (Nat.lt_of_succ_lt_succ bounded)]
          rfl

/-- At and above the current depth, every free index becomes the numeral. -/
theorem numeralSubstitutionAtDepth_of_not_lt
    (value depth index : Nat)
    (unbounded : index < depth -> False) :
    numeralSubstitutionAtDepth value depth index = RawTerm.numeral value := by
  induction depth generalizing index with
  | zero => rfl
  | succ depth inductionHypothesis =>
      cases index with
      | zero => exact (unbounded (Nat.zero_lt_succ depth)).elim
      | succ index =>
          change
            (numeralSubstitutionAtDepth value depth index).rename Nat.succ =
              RawTerm.numeral value
          rw [inductionHypothesis index (fun bounded =>
            unbounded (Nat.succ_lt_succ bounded))]
          exact RawTerm.numeral_rename_succ value

/-- At depth zero this is exactly the public numeral instantiation. -/
theorem RawFormula.substitute_numeralAtDepth_zero
    (formula : RawFormula)
    (value : Nat) :
    formula.substitute (numeralSubstitutionAtDepth value 0) =
      formula.instantiateNumeral value :=
  rfl

/-! ## Positive numeric stacks, tasks, and states -/

/-- Positive stack cell; zero is reserved for the empty stack. -/
def substitutionStackPush (item stack : Nat) : Nat :=
  Nat.succ (natPair item stack)

/-- Total head and tail operations for a positive stack. -/
def substitutionStackHead : Nat -> Nat
  | 0 => 0
  | Nat.succ encoded => natUnpairLeft encoded

def substitutionStackTail : Nat -> Nat
  | 0 => 0
  | Nat.succ encoded => natUnpairRight encoded

theorem substitutionStackHead_push (item stack : Nat) :
    substitutionStackHead (substitutionStackPush item stack) = item :=
  natUnpairLeft_pair item stack

theorem substitutionStackTail_push (item stack : Nat) :
    substitutionStackTail (substitutionStackPush item stack) = stack :=
  natUnpairRight_pair item stack

/-- Task code with a positive outer marker. -/
def substitutionTask (tag payload : Nat) : Nat :=
  Nat.succ (natPair tag payload)

/-- Processing tasks carry `(syntaxCode, depth)`. -/
def substitutionProcessTermTask (code depth : Nat) : Nat :=
  substitutionTask 0 (natPair code depth)

def substitutionProcessFormulaTask (code depth : Nat) : Nat :=
  substitutionTask 1 (natPair code depth)

/-! Build-task tags. -/

def substitutionBuildTermSuccTask : Nat := substitutionTask 2 0
def substitutionBuildTermAddTask : Nat := substitutionTask 3 0
def substitutionBuildTermMulTask : Nat := substitutionTask 4 0
def substitutionBuildFormulaEqualTask : Nat := substitutionTask 5 0
def substitutionBuildFormulaConjTask : Nat := substitutionTask 6 0
def substitutionBuildFormulaDisjTask : Nat := substitutionTask 7 0
def substitutionBuildFormulaImplTask : Nat := substitutionTask 8 0
def substitutionBuildFormulaAllTask : Nat := substitutionTask 9 0
def substitutionBuildFormulaExTask : Nat := substitutionTask 10 0

/-- A machine state pairs its work and result stacks. -/
def substitutionMachineState (work results : Nat) : Nat :=
  natPair work results

/-- Initial state for substitution in a formula at the outermost depth. -/
def substitutionMachineInitialState (formulaCode : Nat) : Nat :=
  substitutionMachineState
    (substitutionStackPush
      (substitutionProcessFormulaTask formulaCode 0)
      0)
    0

/-! ## Numeric constructor actions -/

/-- Push one transformed code on the result stack. -/
def substitutionPushResult (work results result : Nat) : Nat :=
  substitutionMachineState work (substitutionStackPush result results)

/-- Rebuild a unary node from the top result. -/
def substitutionBuildUnary
    (tag work results : Nat) : Nat :=
  substitutionPushResult
    work
    (substitutionStackTail results)
    (Nat.succ
      (natPair tag (substitutionStackHead results)))

/-- Rebuild a binary node from the two top results, right child first. -/
def substitutionBuildBinary
    (tag work results : Nat) : Nat :=
  let right := substitutionStackHead results
  let afterRight := substitutionStackTail results
  let left := substitutionStackHead afterRight
  let afterLeft := substitutionStackTail afterRight
  substitutionPushResult
    work
    afterLeft
    (Nat.succ (natPair tag (natPair left right)))

/-! ## One deterministic machine step -/

/-- Process one raw term node, expanding children into work-stack tasks. -/
def substitutionProcessTermStep
    (code depth work results value : Nat) : Nat :=
  match code with
  | 0 => substitutionPushResult work results RawTerm.zero.code
  | Nat.succ encoded =>
      let tag := natUnpairLeft encoded
      let payload := natUnpairRight encoded
      match tag with
      | 0 =>
          if payload < depth then
            substitutionPushResult work results
              (RawTerm.bvar payload).code
          else
            substitutionPushResult work results
              (RawTerm.numeral value).code
      | 1 => substitutionPushResult work results RawTerm.zero.code
      | 2 =>
          substitutionMachineState
            (substitutionStackPush
              (substitutionProcessTermTask payload depth)
              (substitutionStackPush substitutionBuildTermSuccTask work))
            results
      | 3 =>
          let left := natUnpairLeft payload
          let right := natUnpairRight payload
          substitutionMachineState
            (substitutionStackPush
              (substitutionProcessTermTask left depth)
              (substitutionStackPush
                (substitutionProcessTermTask right depth)
                (substitutionStackPush substitutionBuildTermAddTask work)))
            results
      | 4 =>
          let left := natUnpairLeft payload
          let right := natUnpairRight payload
          substitutionMachineState
            (substitutionStackPush
              (substitutionProcessTermTask left depth)
              (substitutionStackPush
                (substitutionProcessTermTask right depth)
                (substitutionStackPush substitutionBuildTermMulTask work)))
            results
      | _ => substitutionPushResult work results RawTerm.zero.code

/-- Process one raw formula node with the same explicit binder depth. -/
def substitutionProcessFormulaStep
    (code depth work results value : Nat) : Nat :=
  match code with
  | 0 => substitutionPushResult work results RawFormula.falsum.code
  | Nat.succ encoded =>
      let tag := natUnpairLeft encoded
      let payload := natUnpairRight encoded
      match tag with
      | 0 => substitutionPushResult work results RawFormula.falsum.code
      | 1 =>
          let left := natUnpairLeft payload
          let right := natUnpairRight payload
          substitutionMachineState
            (substitutionStackPush
              (substitutionProcessTermTask left depth)
              (substitutionStackPush
                (substitutionProcessTermTask right depth)
                (substitutionStackPush substitutionBuildFormulaEqualTask work)))
            results
      | 2 =>
          let left := natUnpairLeft payload
          let right := natUnpairRight payload
          substitutionMachineState
            (substitutionStackPush
              (substitutionProcessFormulaTask left depth)
              (substitutionStackPush
                (substitutionProcessFormulaTask right depth)
                (substitutionStackPush substitutionBuildFormulaConjTask work)))
            results
      | 3 =>
          let left := natUnpairLeft payload
          let right := natUnpairRight payload
          substitutionMachineState
            (substitutionStackPush
              (substitutionProcessFormulaTask left depth)
              (substitutionStackPush
                (substitutionProcessFormulaTask right depth)
                (substitutionStackPush substitutionBuildFormulaDisjTask work)))
            results
      | 4 =>
          let left := natUnpairLeft payload
          let right := natUnpairRight payload
          substitutionMachineState
            (substitutionStackPush
              (substitutionProcessFormulaTask left depth)
              (substitutionStackPush
                (substitutionProcessFormulaTask right depth)
                (substitutionStackPush substitutionBuildFormulaImplTask work)))
            results
      | 5 =>
          substitutionMachineState
            (substitutionStackPush
              (substitutionProcessFormulaTask payload (Nat.succ depth))
              (substitutionStackPush substitutionBuildFormulaAllTask work))
            results
      | 6 =>
          substitutionMachineState
            (substitutionStackPush
              (substitutionProcessFormulaTask payload (Nat.succ depth))
              (substitutionStackPush substitutionBuildFormulaExTask work))
            results
      | _ => substitutionPushResult work results RawFormula.falsum.code

/-- Execute one work-stack task; completed states remain fixed. -/
def substitutionMachineStep (state value : Nat) : Nat :=
  let work := natUnpairLeft state
  let results := natUnpairRight state
  match work with
  | 0 => state
  | Nat.succ encodedWork =>
      let task := natUnpairLeft encodedWork
      let remainingWork := natUnpairRight encodedWork
      match task with
      | 0 => substitutionMachineState remainingWork results
      | Nat.succ encodedTask =>
          let tag := natUnpairLeft encodedTask
          let payload := natUnpairRight encodedTask
          match tag with
          | 0 =>
              substitutionProcessTermStep
                (natUnpairLeft payload)
                (natUnpairRight payload)
                remainingWork results value
          | 1 =>
              substitutionProcessFormulaStep
                (natUnpairLeft payload)
                (natUnpairRight payload)
                remainingWork results value
          | 2 => substitutionBuildUnary 2 remainingWork results
          | 3 => substitutionBuildBinary 3 remainingWork results
          | 4 => substitutionBuildBinary 4 remainingWork results
          | 5 => substitutionBuildBinary 1 remainingWork results
          | 6 => substitutionBuildBinary 2 remainingWork results
          | 7 => substitutionBuildBinary 3 remainingWork results
          | 8 => substitutionBuildBinary 4 remainingWork results
          | 9 => substitutionBuildUnary 5 remainingWork results
          | 10 => substitutionBuildUnary 6 remainingWork results
          | _ => substitutionMachineState remainingWork results

/-- Iterate the deterministic machine for an explicit number of steps. -/
def substitutionMachineRun : Nat -> Nat -> Nat -> Nat
  | 0, state, _value => state
  | Nat.succ steps, state, value =>
      substitutionMachineRun steps
        (substitutionMachineStep state value)
        value

/-! ## Exact structural cost -/

def RawTerm.substitutionCost : RawTerm -> Nat
  | RawTerm.bvar _index => 1
  | RawTerm.zero => 1
  | RawTerm.succ body => Nat.succ (Nat.succ body.substitutionCost)
  | RawTerm.add left right =>
      Nat.succ (left.substitutionCost + right.substitutionCost + 1)
  | RawTerm.mul left right =>
      Nat.succ (left.substitutionCost + right.substitutionCost + 1)

def RawFormula.substitutionCost : RawFormula -> Nat
  | RawFormula.falsum => 1
  | RawFormula.equal left right =>
      Nat.succ (left.substitutionCost + right.substitutionCost + 1)
  | RawFormula.conj left right =>
      Nat.succ (left.substitutionCost + right.substitutionCost + 1)
  | RawFormula.disj left right =>
      Nat.succ (left.substitutionCost + right.substitutionCost + 1)
  | RawFormula.impl left right =>
      Nat.succ (left.substitutionCost + right.substitutionCost + 1)
  | RawFormula.all body => Nat.succ (Nat.succ body.substitutionCost)
  | RawFormula.ex body => Nat.succ (Nat.succ body.substitutionCost)

/-! ## Exact execution of canonical tasks -/

/-- Splitting an iteration count executes the two blocks consecutively. -/
theorem substitutionMachineRun_add
    (first second state value : Nat) :
    substitutionMachineRun (first + second) state value =
      substitutionMachineRun second
        (substitutionMachineRun first state value)
        value := by
  induction first generalizing state with
  | zero => rfl
  | succ first inductionHypothesis =>
      change
        substitutionMachineRun (first + second)
            (substitutionMachineStep state value) value =
          substitutionMachineRun second
            (substitutionMachineRun first
              (substitutionMachineStep state value) value)
            value
      exact inductionHypothesis (substitutionMachineStep state value)

/-- A canonical term-processing task dispatches to the term step. -/
theorem substitutionMachineStep_processTermTask
    (code depth work results value : Nat) :
    substitutionMachineStep
        (substitutionMachineState
          (substitutionStackPush
            (substitutionProcessTermTask code depth)
            work)
          results)
        value =
      substitutionProcessTermStep code depth work results value := by
  simp [substitutionMachineStep, substitutionMachineState,
    substitutionStackPush, substitutionProcessTermTask,
    substitutionTask, substitutionStackHead, substitutionStackTail,
    natUnpairLeft_pair, natUnpairRight_pair]

/-- A canonical formula-processing task dispatches to the formula step. -/
theorem substitutionMachineStep_processFormulaTask
    (code depth work results value : Nat) :
    substitutionMachineStep
        (substitutionMachineState
          (substitutionStackPush
            (substitutionProcessFormulaTask code depth)
            work)
          results)
        value =
      substitutionProcessFormulaStep code depth work results value := by
  simp [substitutionMachineStep, substitutionMachineState,
    substitutionStackPush, substitutionProcessFormulaTask,
    substitutionTask, substitutionStackHead, substitutionStackTail,
    natUnpairLeft_pair, natUnpairRight_pair]

/-- One term task consumes exactly its structural cost. -/
theorem RawTerm.substitutionMachineRun
    (term : RawTerm)
    (depth work results value : Nat) :
    substitutionMachineRun term.substitutionCost
        (substitutionMachineState
          (substitutionStackPush
            (substitutionProcessTermTask term.code depth)
            work)
          results)
        value =
      substitutionMachineState work
        (substitutionStackPush
          (term.substitute (numeralSubstitutionAtDepth value depth)).code
          results) := by
  induction term generalizing depth work results with
  | bvar index =>
      change substitutionMachineStep _ value = _
      rw [substitutionMachineStep_processTermTask]
      unfold substitutionProcessTermStep RawTerm.code RawTerm.substitute
      rw [natUnpairLeft_pair, natUnpairRight_pair]
      by_cases bounded : index < depth
      · rw [if_pos bounded,
          numeralSubstitutionAtDepth_of_lt value depth index bounded]
      · rw [if_neg bounded,
          numeralSubstitutionAtDepth_of_not_lt value depth index bounded]
  | zero =>
      change substitutionMachineStep _ value = _
      rw [substitutionMachineStep_processTermTask]
      simp [substitutionProcessTermStep, RawTerm.code,
        RawTerm.substitute, natUnpairLeft_pair, natUnpairRight_pair]
  | succ body inductionHypothesis =>
      change substitutionMachineRun (Nat.succ body.substitutionCost)
        (substitutionMachineStep _ value) value = _
      rw [substitutionMachineStep_processTermTask]
      simp only [substitutionProcessTermStep, RawTerm.code,
        natUnpairLeft_pair, natUnpairRight_pair]
      rw [show Nat.succ body.substitutionCost =
        body.substitutionCost + 1 by omega]
      rw [substitutionMachineRun_add]
      rw [inductionHypothesis depth
        (substitutionStackPush substitutionBuildTermSuccTask work)
        results]
      change substitutionMachineStep _ value = _
      simp [substitutionMachineStep, substitutionMachineState,
        substitutionStackPush, substitutionTask,
        substitutionBuildTermSuccTask, substitutionBuildUnary,
        substitutionPushResult, substitutionStackHead,
        substitutionStackTail, natUnpairLeft_pair, natUnpairRight_pair,
        RawTerm.substitute, RawTerm.code]

/-- One formula task consumes exactly its structural cost. -/
theorem RawFormula.substitutionMachineRun
    (formula : RawFormula)
    (depth work results value : Nat) :
    substitutionMachineRun formula.substitutionCost
        (substitutionMachineState
          (substitutionStackPush
            (substitutionProcessFormulaTask formula.code depth)
            work)
          results)
        value =
      substitutionMachineState work
        (substitutionStackPush
          (formula.substitute
            (numeralSubstitutionAtDepth value depth)).code
          results) := by
  induction formula generalizing depth work results with
  | falsum =>
      change substitutionMachineStep _ value = _
      rw [substitutionMachineStep_processFormulaTask]
      simp [substitutionProcessFormulaStep, RawFormula.code,
        RawFormula.substitute, natUnpairLeft_pair, natUnpairRight_pair]
  | equal left right =>
      change substitutionMachineRun
          (left.substitutionCost + right.substitutionCost + 1)
        (substitutionMachineStep _ value) value = _
      rw [substitutionMachineStep_processFormulaTask]
      simp only [substitutionProcessFormulaStep, RawFormula.code,
        natUnpairLeft_pair, natUnpairRight_pair]
      rw [substitutionMachineRun_add left.substitutionCost]
      rw [left.substitutionMachineRun depth
        (substitutionStackPush
          (substitutionProcessTermTask right.code depth)
          (substitutionStackPush substitutionBuildFormulaEqualTask work))
        results]
      rw [substitutionMachineRun_add right.substitutionCost 1]
      rw [right.substitutionMachineRun depth
        (substitutionStackPush substitutionBuildFormulaEqualTask work)]
      change substitutionMachineStep _ value = _
      simp [substitutionMachineStep, substitutionMachineState,
        substitutionStackPush, substitutionTask,
        substitutionBuildFormulaEqualTask, substitutionBuildBinary,
        substitutionPushResult, substitutionStackHead,
        substitutionStackTail, natUnpairLeft_pair, natUnpairRight_pair,
        RawFormula.substitute, RawFormula.code]
  | conj left right leftHypothesis rightHypothesis =>
      change substitutionMachineRun
          (left.substitutionCost + right.substitutionCost + 1)
        (substitutionMachineStep _ value) value = _
      rw [substitutionMachineStep_processFormulaTask]
      simp only [substitutionProcessFormulaStep, RawFormula.code,
        natUnpairLeft_pair, natUnpairRight_pair]
      rw [substitutionMachineRun_add left.substitutionCost]
      rw [leftHypothesis depth
        (substitutionStackPush
          (substitutionProcessFormulaTask right.code depth)
          (substitutionStackPush substitutionBuildFormulaConjTask work))
        results]
      rw [substitutionMachineRun_add right.substitutionCost 1]
      rw [rightHypothesis depth
        (substitutionStackPush substitutionBuildFormulaConjTask work)]
      change substitutionMachineStep _ value = _
      simp [substitutionMachineStep, substitutionMachineState,
        substitutionStackPush, substitutionTask,
        substitutionBuildFormulaConjTask, substitutionBuildBinary,
        substitutionPushResult, substitutionStackHead,
        substitutionStackTail, natUnpairLeft_pair, natUnpairRight_pair,
        RawFormula.substitute, RawFormula.code]
  | disj left right leftHypothesis rightHypothesis =>
      change substitutionMachineRun
          (left.substitutionCost + right.substitutionCost + 1)
        (substitutionMachineStep _ value) value = _
      rw [substitutionMachineStep_processFormulaTask]
      simp only [substitutionProcessFormulaStep, RawFormula.code,
        natUnpairLeft_pair, natUnpairRight_pair]
      rw [substitutionMachineRun_add left.substitutionCost]
      rw [leftHypothesis depth
        (substitutionStackPush
          (substitutionProcessFormulaTask right.code depth)
          (substitutionStackPush substitutionBuildFormulaDisjTask work))
        results]
      rw [substitutionMachineRun_add right.substitutionCost 1]
      rw [rightHypothesis depth
        (substitutionStackPush substitutionBuildFormulaDisjTask work)]
      change substitutionMachineStep _ value = _
      simp [substitutionMachineStep, substitutionMachineState,
        substitutionStackPush, substitutionTask,
        substitutionBuildFormulaDisjTask, substitutionBuildBinary,
        substitutionPushResult, substitutionStackHead,
        substitutionStackTail, natUnpairLeft_pair, natUnpairRight_pair,
        RawFormula.substitute, RawFormula.code]
  | impl left right leftHypothesis rightHypothesis =>
      change substitutionMachineRun
          (left.substitutionCost + right.substitutionCost + 1)
        (substitutionMachineStep _ value) value = _
      rw [substitutionMachineStep_processFormulaTask]
      simp only [substitutionProcessFormulaStep, RawFormula.code,
        natUnpairLeft_pair, natUnpairRight_pair]
      rw [substitutionMachineRun_add left.substitutionCost]
      rw [leftHypothesis depth
        (substitutionStackPush
          (substitutionProcessFormulaTask right.code depth)
          (substitutionStackPush substitutionBuildFormulaImplTask work))
        results]
      rw [substitutionMachineRun_add right.substitutionCost 1]
      rw [rightHypothesis depth
        (substitutionStackPush substitutionBuildFormulaImplTask work)]
      change substitutionMachineStep _ value = _
      simp [substitutionMachineStep, substitutionMachineState,
        substitutionStackPush, substitutionTask,
        substitutionBuildFormulaImplTask, substitutionBuildBinary,
        substitutionPushResult, substitutionStackHead,
        substitutionStackTail, natUnpairLeft_pair, natUnpairRight_pair,
        RawFormula.substitute, RawFormula.code]
  | all body inductionHypothesis =>
      change substitutionMachineRun (Nat.succ body.substitutionCost)
        (substitutionMachineStep _ value) value = _
      rw [substitutionMachineStep_processFormulaTask]
      simp only [substitutionProcessFormulaStep, RawFormula.code,
        natUnpairLeft_pair, natUnpairRight_pair]
      rw [show Nat.succ body.substitutionCost =
        body.substitutionCost + 1 by omega]
      rw [substitutionMachineRun_add]
      rw [inductionHypothesis (Nat.succ depth)
        (substitutionStackPush substitutionBuildFormulaAllTask work)
        results]
      change substitutionMachineStep _ value = _
      simp [substitutionMachineStep, substitutionMachineState,
        substitutionStackPush, substitutionTask,
        substitutionBuildFormulaAllTask, substitutionBuildUnary,
        substitutionPushResult, substitutionStackHead,
        substitutionStackTail, natUnpairLeft_pair, natUnpairRight_pair,
        numeralSubstitutionAtDepth, RawFormula.substitute,
        RawFormula.code]

/-! ## A code-computable uniform fuel bound -/

/-- Prefix pairing dominates the sum of its two components. -/
theorem nat_add_le_natPair (left right : Nat) :
    left + right <= natPair left right := by
  induction left with
  | zero => exact nat_le_natDouble right
  | succ left inductionHypothesis =>
      change Nat.succ (left + right) <=
        Nat.succ (natDouble (natPair left right))
      exact Nat.succ_le_succ
        (Nat.le_trans inductionHypothesis
          (nat_le_natDouble (natPair left right)))

/-- Structural doubling is monotone. -/
theorem natDouble_mono
    {left right : Nat}
    (bounded : left <= right) :
    natDouble left <= natDouble right := by
  rw [← nat_add_self_eq_natDouble, ← nat_add_self_eq_natDouble]
  exact Nat.add_le_add bounded bounded

/-- Every term task finishes within twice its syntax code. -/
theorem RawTerm.substitutionCost_le_doubleCode (term : RawTerm) :
    term.substitutionCost <= natDouble term.code := by
  induction term with
  | bvar index =>
      rw [← nat_add_self_eq_natDouble]
      change 1 <= _ + _
      omega
  | zero =>
      rw [← nat_add_self_eq_natDouble]
      decide
  | succ body inductionHypothesis =>
      have childBound : body.code <= natPair 2 body.code :=
        natPair_right_le 2 body.code
      have doubledChild := natDouble_mono childBound
      rw [← nat_add_self_eq_natDouble] at inductionHypothesis
      rw [← nat_add_self_eq_natDouble]
      change Nat.succ (Nat.succ body.substitutionCost) <= _
      omega
  | add left right leftHypothesis rightHypothesis =>
      have childrenBound :
          left.code + right.code <= natPair left.code right.code :=
        nat_add_le_natPair left.code right.code
      have payloadBound :
          natPair left.code right.code <=
            natPair 3 (natPair left.code right.code) :=
        natPair_right_le 3 (natPair left.code right.code)
      rw [← nat_add_self_eq_natDouble] at
        leftHypothesis rightHypothesis
      rw [← nat_add_self_eq_natDouble]
      change Nat.succ
          (left.substitutionCost + right.substitutionCost + 1) <= _
      omega
  | mul left right leftHypothesis rightHypothesis =>
      have childrenBound :
          left.code + right.code <= natPair left.code right.code :=
        nat_add_le_natPair left.code right.code
      have payloadBound :
          natPair left.code right.code <=
            natPair 4 (natPair left.code right.code) :=
        natPair_right_le 4 (natPair left.code right.code)
      rw [← nat_add_self_eq_natDouble] at
        leftHypothesis rightHypothesis
      rw [← nat_add_self_eq_natDouble]
      change Nat.succ
          (left.substitutionCost + right.substitutionCost + 1) <= _
      omega

/-- Every formula task finishes within twice its syntax code. -/
theorem RawFormula.substitutionCost_le_doubleCode (formula : RawFormula) :
    formula.substitutionCost <= natDouble formula.code := by
  induction formula with
  | falsum =>
      rw [← nat_add_self_eq_natDouble]
      decide
  | equal left right =>
      have childrenBound := nat_add_le_natPair left.code right.code
      have payloadBound :=
        natPair_right_le 1 (natPair left.code right.code)
      have leftBound := left.substitutionCost_le_doubleCode
      have rightBound := right.substitutionCost_le_doubleCode
      rw [← nat_add_self_eq_natDouble] at leftBound rightBound
      rw [← nat_add_self_eq_natDouble]
      change Nat.succ
          (left.substitutionCost + right.substitutionCost + 1) <= _
      omega
  | conj left right leftHypothesis rightHypothesis =>
      have childrenBound := nat_add_le_natPair left.code right.code
      have payloadBound :=
        natPair_right_le 2 (natPair left.code right.code)
      rw [← nat_add_self_eq_natDouble] at
        leftHypothesis rightHypothesis
      rw [← nat_add_self_eq_natDouble]
      change Nat.succ
          (left.substitutionCost + right.substitutionCost + 1) <= _
      omega
  | disj left right leftHypothesis rightHypothesis =>
      have childrenBound := nat_add_le_natPair left.code right.code
      have payloadBound :=
        natPair_right_le 3 (natPair left.code right.code)
      rw [← nat_add_self_eq_natDouble] at
        leftHypothesis rightHypothesis
      rw [← nat_add_self_eq_natDouble]
      change Nat.succ
          (left.substitutionCost + right.substitutionCost + 1) <= _
      omega
  | impl left right leftHypothesis rightHypothesis =>
      have childrenBound := nat_add_le_natPair left.code right.code
      have payloadBound :=
        natPair_right_le 4 (natPair left.code right.code)
      rw [← nat_add_self_eq_natDouble] at
        leftHypothesis rightHypothesis
      rw [← nat_add_self_eq_natDouble]
      change Nat.succ
          (left.substitutionCost + right.substitutionCost + 1) <= _
      omega
  | all body inductionHypothesis =>
      have childBound := natPair_right_le 5 body.code
      rw [← nat_add_self_eq_natDouble] at inductionHypothesis
      rw [← nat_add_self_eq_natDouble]
      change Nat.succ (Nat.succ body.substitutionCost) <= _
      omega
  | ex body inductionHypothesis =>
      have childBound := natPair_right_le 6 body.code
      rw [← nat_add_self_eq_natDouble] at inductionHypothesis
      rw [← nat_add_self_eq_natDouble]
      change Nat.succ (Nat.succ body.substitutionCost) <= _
      omega

/-- A completed machine state is fixed by every further step. -/
theorem substitutionMachineStep_completed
    (results value : Nat) :
    substitutionMachineStep
        (substitutionMachineState 0 results)
        value =
      substitutionMachineState 0 results := by
  simp [substitutionMachineStep, substitutionMachineState,
    natUnpairLeft_pair, natUnpairRight_pair]

/-- A completed machine state is fixed by every further run. -/
theorem substitutionMachineRun_completed
    (steps results value : Nat) :
    substitutionMachineRun steps
        (substitutionMachineState 0 results)
        value =
      substitutionMachineState 0 results := by
  induction steps with
  | zero => rfl
  | succ steps inductionHypothesis =>
      change substitutionMachineRun steps
        (substitutionMachineStep
          (substitutionMachineState 0 results) value) value = _
      rw [substitutionMachineStep_completed, inductionHypothesis]

/-- Total code-level substitution computed by the verified stack machine. -/
def machineSubstituteNumeralCode (formulaCode value : Nat) : Nat :=
  substitutionStackHead
    (natUnpairRight
      (substitutionMachineRun
        (natDouble formulaCode)
        (substitutionMachineInitialState formulaCode)
        value))

/-- The machine commutes exactly with syntax on every genuine formula code. -/
theorem machineSubstituteNumeralCode_code
    (formula : RawFormula)
    (value : Nat) :
    machineSubstituteNumeralCode formula.code value =
      (formula.instantiateNumeral value).code := by
  cases natExistsEqAddOfLe formula.substitutionCost_le_doubleCode with
  | intro extra fuelEquality =>
      unfold machineSubstituteNumeralCode
      rw [fuelEquality, substitutionMachineRun_add]
      have exactRun := formula.substitutionMachineRun 0 0 0 value
      rw [RawFormula.substitute_numeralAtDepth_zero] at exactRun
      rw [exactRun, substitutionMachineRun_completed]
      simp [substitutionMachineState, substitutionStackPush,
        substitutionStackHead, natUnpairLeft_pair, natUnpairRight_pair]
  | ex body inductionHypothesis =>
      change substitutionMachineRun (Nat.succ body.substitutionCost)
        (substitutionMachineStep _ value) value = _
      rw [substitutionMachineStep_processFormulaTask]
      simp only [substitutionProcessFormulaStep, RawFormula.code,
        natUnpairLeft_pair, natUnpairRight_pair]
      rw [show Nat.succ body.substitutionCost =
        body.substitutionCost + 1 by omega]
      rw [substitutionMachineRun_add]
      rw [inductionHypothesis (Nat.succ depth)
        (substitutionStackPush substitutionBuildFormulaExTask work)
        results]
      change substitutionMachineStep _ value = _
      simp [substitutionMachineStep, substitutionMachineState,
        substitutionStackPush, substitutionTask,
        substitutionBuildFormulaExTask, substitutionBuildUnary,
        substitutionPushResult, substitutionStackHead,
        substitutionStackTail, natUnpairLeft_pair, natUnpairRight_pair,
        numeralSubstitutionAtDepth, RawFormula.substitute,
        RawFormula.code]
  | add left right leftHypothesis rightHypothesis =>
      change substitutionMachineRun
          (left.substitutionCost + right.substitutionCost + 1)
        (substitutionMachineStep _ value) value = _
      rw [substitutionMachineStep_processTermTask]
      simp only [substitutionProcessTermStep, RawTerm.code,
        natUnpairLeft_pair, natUnpairRight_pair]
      rw [substitutionMachineRun_add left.substitutionCost]
      rw [leftHypothesis depth
        (substitutionStackPush
          (substitutionProcessTermTask right.code depth)
          (substitutionStackPush substitutionBuildTermAddTask work))
        results]
      rw [show right.substitutionCost + 1 =
        right.substitutionCost + 1 by rfl]
      rw [substitutionMachineRun_add]
      rw [rightHypothesis depth
        (substitutionStackPush substitutionBuildTermAddTask work)]
      change substitutionMachineStep _ value = _
      simp [substitutionMachineStep, substitutionMachineState,
        substitutionStackPush, substitutionTask,
        substitutionBuildTermAddTask, substitutionBuildBinary,
        substitutionPushResult, substitutionStackHead,
        substitutionStackTail, natUnpairLeft_pair, natUnpairRight_pair,
        RawTerm.substitute, RawTerm.code]
  | mul left right leftHypothesis rightHypothesis =>
      change substitutionMachineRun
          (left.substitutionCost + right.substitutionCost + 1)
        (substitutionMachineStep _ value) value = _
      rw [substitutionMachineStep_processTermTask]
      simp only [substitutionProcessTermStep, RawTerm.code,
        natUnpairLeft_pair, natUnpairRight_pair]
      rw [substitutionMachineRun_add left.substitutionCost]
      rw [leftHypothesis depth
        (substitutionStackPush
          (substitutionProcessTermTask right.code depth)
          (substitutionStackPush substitutionBuildTermMulTask work))
        results]
      rw [substitutionMachineRun_add right.substitutionCost 1]
      rw [rightHypothesis depth
        (substitutionStackPush substitutionBuildTermMulTask work)]
      change substitutionMachineStep _ value = _
      simp [substitutionMachineStep, substitutionMachineState,
        substitutionStackPush, substitutionTask,
        substitutionBuildTermMulTask, substitutionBuildBinary,
        substitutionPushResult, substitutionStackHead,
        substitutionStackTail, natUnpairLeft_pair, natUnpairRight_pair,
        RawTerm.substitute, RawTerm.code]

end BareArithmeticTarski
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.BareArithmeticTarski.numeralSubstitutionAtDepth
#print axioms Meta.BareArithmeticTarski.substitutionMachineStep
#print axioms Meta.BareArithmeticTarski.substitutionMachineRun
#print axioms Meta.BareArithmeticTarski.RawTerm.substitutionCost
#print axioms Meta.BareArithmeticTarski.RawFormula.substitutionCost
#print axioms Meta.BareArithmeticTarski.RawTerm.substitutionMachineRun
#print axioms Meta.BareArithmeticTarski.RawFormula.substitutionMachineRun
#print axioms Meta.BareArithmeticTarski.machineSubstituteNumeralCode_code
/- AXIOM_AUDIT_END -/
