import Meta.Tarski.BareArithmetic.SubstitutionMachine

/-!
# Positive PR implementation of the capture-avoiding substitution machine

Every numeric operation of `SubstitutionMachine` is implemented below by an
explicit `PRFunction` tree.  The final unary program performs genuine
self-substitution on every well-formed formula code.
-/

namespace Meta
namespace BareArithmeticTarski

@[simp] theorem PRFunction.run_predecessor (value : Nat) :
    PRFunction.predecessor.run (NatVector.cons value NatVector.nil) =
      value.pred :=
  PRFunction.run_eq_of_evaluates
    (PRFunction.predecessor_evaluates value)

@[simp] theorem PRFunction.run_lessBit (left right : Nat) :
    PRFunction.lessBit.run
        (NatVector.cons left (NatVector.cons right NatVector.nil)) =
      natLessBit left right :=
  PRFunction.run_eq_of_evaluates
    (PRFunction.lessBit_evaluates left right)

@[simp] theorem PRFunction.run_double (value : Nat) :
    PRFunction.double.run (NatVector.cons value NatVector.nil) =
      natDouble value :=
  PRFunction.run_eq_of_evaluates
    (PRFunction.double_evaluates value)

/-! ## Context-polymorphic numeric constructors -/

/-- Apply a binary program to two programs in a shared input context. -/
def PRFunction.binaryIn
    {arity : Nat}
    (constructor : PRFunction 2)
    (left right : PRFunction arity) :
    PRFunction arity :=
  PRFunction.composition constructor
    (PRFunctionVector.cons left (PRFunctionVector.singleton right))

/-- Apply a unary program in a shared input context. -/
def PRFunction.unaryIn
    {arity : Nat}
    (constructor : PRFunction 1)
    (argument : PRFunction arity) :
    PRFunction arity :=
  PRFunction.composition constructor (PRFunctionVector.singleton argument)

@[simp] theorem PRFunction.run_binaryIn
    {arity : Nat}
    (constructor : PRFunction 2)
    (left right : PRFunction arity)
    (inputs : NatVector arity) :
    (PRFunction.binaryIn constructor left right).run inputs =
      constructor.run
        (NatVector.cons (left.run inputs)
          (NatVector.cons (right.run inputs) NatVector.nil)) :=
  rfl

@[simp] theorem PRFunction.run_unaryIn
    {arity : Nat}
    (constructor : PRFunction 1)
    (argument : PRFunction arity)
    (inputs : NatVector arity) :
    (PRFunction.unaryIn constructor argument).run inputs =
      constructor.run (NatVector.cons (argument.run inputs) NatVector.nil) :=
  rfl

/-- Positive stack push and total positive-stack projections. -/
def PRFunction.machineStackPush : PRFunction 2 :=
  PRFunction.unaryIn PRFunction.successor PRFunction.pair

def PRFunction.machineStackHead : PRFunction 1 :=
  PRFunction.select PRFunction.identity PRFunction.zero
    (PRFunction.unaryIn PRFunction.unpairLeft PRFunction.predecessor)

def PRFunction.machineStackTail : PRFunction 1 :=
  PRFunction.select PRFunction.identity PRFunction.zero
    (PRFunction.unaryIn PRFunction.unpairRight PRFunction.predecessor)

/-- Positive task constructor and paired machine state. -/
def PRFunction.machineTask : PRFunction 2 :=
  PRFunction.unaryIn PRFunction.successor PRFunction.pair

def PRFunction.machineState : PRFunction 2 := PRFunction.pair

/-- Lift stack, task, and state construction to any input context. -/
def PRFunction.machineStackPushIn
    {arity : Nat}
    (item stack : PRFunction arity) : PRFunction arity :=
  PRFunction.binaryIn PRFunction.machineStackPush item stack

def PRFunction.machineTaskIn
    {arity : Nat}
    (tag payload : PRFunction arity) : PRFunction arity :=
  PRFunction.binaryIn PRFunction.machineTask tag payload

def PRFunction.machineStateIn
    {arity : Nat}
    (work results : PRFunction arity) : PRFunction arity :=
  PRFunction.binaryIn PRFunction.machineState work results

def PRFunction.machineProcessTaskIn
    {arity : Nat}
    (taskTag code depth : PRFunction arity) : PRFunction arity :=
  PRFunction.machineTaskIn taskTag
    (PRFunction.binaryIn PRFunction.pair code depth)

def PRFunction.machinePushResultIn
    {arity : Nat}
    (work results result : PRFunction arity) : PRFunction arity :=
  PRFunction.machineStateIn work
    (PRFunction.machineStackPushIn result results)

def PRFunction.machineBuildUnaryIn
    {arity : Nat}
    (syntaxTag work results : PRFunction arity) : PRFunction arity :=
  PRFunction.machinePushResultIn
    work
    (PRFunction.unaryIn PRFunction.machineStackTail results)
    (PRFunction.unaryIn PRFunction.successor
      (PRFunction.binaryIn PRFunction.pair syntaxTag
        (PRFunction.unaryIn PRFunction.machineStackHead results)))

def PRFunction.machineBuildBinaryIn
    {arity : Nat}
    (syntaxTag work results : PRFunction arity) : PRFunction arity :=
  let right := PRFunction.unaryIn PRFunction.machineStackHead results
  let afterRight := PRFunction.unaryIn PRFunction.machineStackTail results
  let left := PRFunction.unaryIn PRFunction.machineStackHead afterRight
  let afterLeft := PRFunction.unaryIn PRFunction.machineStackTail afterRight
  PRFunction.machinePushResultIn
    work afterLeft
    (PRFunction.unaryIn PRFunction.successor
      (PRFunction.binaryIn PRFunction.pair syntaxTag
        (PRFunction.binaryIn PRFunction.pair left right)))

/-! ## Program for one term-processing task -/

def PRFunction.machineProcessTermStep : PRFunction 5 :=
  let code := PRFunction.projection 5 0 (by omega)
  let depth := PRFunction.projection 5 1 (by omega)
  let work := PRFunction.projection 5 2 (by omega)
  let results := PRFunction.projection 5 3 (by omega)
  let value := PRFunction.projection 5 4 (by omega)
  let encoded := PRFunction.unaryIn PRFunction.predecessor code
  let tag := PRFunction.unaryIn PRFunction.unpairLeft encoded
  let payload := PRFunction.unaryIn PRFunction.unpairRight encoded
  let payloadLeft := PRFunction.unaryIn PRFunction.unpairLeft payload
  let payloadRight := PRFunction.unaryIn PRFunction.unpairRight payload
  let fallback := PRFunction.machinePushResultIn
    work results (PRFunction.constant 5 RawTerm.zero.code)
  let boundVariable := PRFunction.machinePushResultIn
    work results
    (PRFunction.unaryIn PRFunction.successor
      (PRFunction.binaryIn PRFunction.pair
        (PRFunction.constant 5 0) payload))
  let numeral := PRFunction.machinePushResultIn
    work results
    (PRFunction.unaryIn PRFunction.numeralCode value)
  let variableBranch := PRFunction.select
    (PRFunction.binaryIn PRFunction.lessBit payload depth)
    numeral boundVariable
  let zeroBranch := fallback
  let unaryBranch := PRFunction.machineStateIn
    (PRFunction.machineStackPushIn
      (PRFunction.machineProcessTaskIn
        (PRFunction.constant 5 0) payload depth)
      (PRFunction.machineStackPushIn
        (PRFunction.constant 5 substitutionBuildTermSuccTask)
        work))
    results
  let binaryBranch := fun (buildTask : Nat) =>
    PRFunction.machineStateIn
      (PRFunction.machineStackPushIn
        (PRFunction.machineProcessTaskIn
          (PRFunction.constant 5 0) payloadLeft depth)
        (PRFunction.machineStackPushIn
          (PRFunction.machineProcessTaskIn
            (PRFunction.constant 5 0) payloadRight depth)
          (PRFunction.machineStackPushIn
            (PRFunction.constant 5 buildTask) work)))
      results
  let nodeBranch := PRFunction.selectTag tag 0 variableBranch
    (PRFunction.selectTag tag 1 zeroBranch
      (PRFunction.selectTag tag 2 unaryBranch
        (PRFunction.selectTag tag 3
          (binaryBranch substitutionBuildTermAddTask)
          (PRFunction.selectTag tag 4
            (binaryBranch substitutionBuildTermMulTask)
            fallback))))
  PRFunction.select code fallback nodeBranch

/-! ## Program for one formula-processing task -/

def PRFunction.machineProcessFormulaStep : PRFunction 5 :=
  let code := PRFunction.projection 5 0 (by omega)
  let depth := PRFunction.projection 5 1 (by omega)
  let work := PRFunction.projection 5 2 (by omega)
  let results := PRFunction.projection 5 3 (by omega)
  let encoded := PRFunction.unaryIn PRFunction.predecessor code
  let tag := PRFunction.unaryIn PRFunction.unpairLeft encoded
  let payload := PRFunction.unaryIn PRFunction.unpairRight encoded
  let payloadLeft := PRFunction.unaryIn PRFunction.unpairLeft payload
  let payloadRight := PRFunction.unaryIn PRFunction.unpairRight payload
  let fallback := PRFunction.machinePushResultIn
    work results (PRFunction.constant 5 RawFormula.falsum.code)
  let binaryBranch := fun (childTaskTag buildTask : Nat) =>
    PRFunction.machineStateIn
      (PRFunction.machineStackPushIn
        (PRFunction.machineProcessTaskIn
          (PRFunction.constant 5 childTaskTag) payloadLeft depth)
        (PRFunction.machineStackPushIn
          (PRFunction.machineProcessTaskIn
            (PRFunction.constant 5 childTaskTag) payloadRight depth)
          (PRFunction.machineStackPushIn
            (PRFunction.constant 5 buildTask) work)))
      results
  let unaryBranch := fun (buildTask : Nat) =>
    PRFunction.machineStateIn
      (PRFunction.machineStackPushIn
        (PRFunction.machineProcessTaskIn
          (PRFunction.constant 5 1)
          payload
          (PRFunction.unaryIn PRFunction.successor depth))
        (PRFunction.machineStackPushIn
          (PRFunction.constant 5 buildTask) work))
      results
  let nodeBranch := PRFunction.selectTag tag 0 fallback
    (PRFunction.selectTag tag 1
      (binaryBranch 0 substitutionBuildFormulaEqualTask)
      (PRFunction.selectTag tag 2
        (binaryBranch 1 substitutionBuildFormulaConjTask)
        (PRFunction.selectTag tag 3
          (binaryBranch 1 substitutionBuildFormulaDisjTask)
          (PRFunction.selectTag tag 4
            (binaryBranch 1 substitutionBuildFormulaImplTask)
            (PRFunction.selectTag tag 5
              (unaryBranch substitutionBuildFormulaAllTask)
              (PRFunction.selectTag tag 6
                (unaryBranch substitutionBuildFormulaExTask)
                fallback))))))
  PRFunction.select code fallback nodeBranch

/-! ## Complete one-step dispatcher -/

def PRFunction.machineStep : PRFunction 2 :=
  let state := PRFunction.projection 2 0 (by omega)
  let value := PRFunction.projection 2 1 (by omega)
  let work := PRFunction.unaryIn PRFunction.unpairLeft state
  let results := PRFunction.unaryIn PRFunction.unpairRight state
  let encodedWork := PRFunction.unaryIn PRFunction.predecessor work
  let task := PRFunction.unaryIn PRFunction.unpairLeft encodedWork
  let remainingWork := PRFunction.unaryIn PRFunction.unpairRight encodedWork
  let encodedTask := PRFunction.unaryIn PRFunction.predecessor task
  let tag := PRFunction.unaryIn PRFunction.unpairLeft encodedTask
  let payload := PRFunction.unaryIn PRFunction.unpairRight encodedTask
  let processCode := PRFunction.unaryIn PRFunction.unpairLeft payload
  let processDepth := PRFunction.unaryIn PRFunction.unpairRight payload
  let processTerm := PRFunction.composition PRFunction.machineProcessTermStep
    (PRFunctionVector.cons processCode
      (PRFunctionVector.cons processDepth
        (PRFunctionVector.cons remainingWork
          (PRFunctionVector.cons results
            (PRFunctionVector.singleton value)))))
  let processFormula := PRFunction.composition PRFunction.machineProcessFormulaStep
    (PRFunctionVector.cons processCode
      (PRFunctionVector.cons processDepth
        (PRFunctionVector.cons remainingWork
          (PRFunctionVector.cons results
            (PRFunctionVector.singleton value)))))
  let dropInvalid := PRFunction.machineStateIn remainingWork results
  let dispatch := PRFunction.selectTag tag 0 processTerm
    (PRFunction.selectTag tag 1 processFormula
      (PRFunction.selectTag tag 2
        (PRFunction.machineBuildUnaryIn
          (PRFunction.constant 2 2) remainingWork results)
        (PRFunction.selectTag tag 3
          (PRFunction.machineBuildBinaryIn
            (PRFunction.constant 2 3) remainingWork results)
          (PRFunction.selectTag tag 4
            (PRFunction.machineBuildBinaryIn
              (PRFunction.constant 2 4) remainingWork results)
            (PRFunction.selectTag tag 5
              (PRFunction.machineBuildBinaryIn
                (PRFunction.constant 2 1) remainingWork results)
              (PRFunction.selectTag tag 6
                (PRFunction.machineBuildBinaryIn
                  (PRFunction.constant 2 2) remainingWork results)
                (PRFunction.selectTag tag 7
                  (PRFunction.machineBuildBinaryIn
                    (PRFunction.constant 2 3) remainingWork results)
                  (PRFunction.selectTag tag 8
                    (PRFunction.machineBuildBinaryIn
                      (PRFunction.constant 2 4) remainingWork results)
                    (PRFunction.selectTag tag 9
                      (PRFunction.machineBuildUnaryIn
                        (PRFunction.constant 2 5) remainingWork results)
                      (PRFunction.selectTag tag 10
                        (PRFunction.machineBuildUnaryIn
                          (PRFunction.constant 2 6) remainingWork results)
                        dropInvalid))))))))))
  PRFunction.select work state
    (PRFunction.select task dropInvalid dispatch)

/-! ## Iteration and final substitution programs -/

def PRFunction.machineIterationStep : PRFunction 4 :=
  PRFunction.composition PRFunction.machineStep
    (PRFunctionVector.cons
      (PRFunction.projection 4 1 (by omega))
      (PRFunctionVector.singleton
        (PRFunction.projection 4 3 (by omega))))

def PRFunction.machineRun : PRFunction 3 :=
  PRFunction.primitiveRecursion
    (PRFunction.projection 2 0 (by omega))
    PRFunction.machineIterationStep

def PRFunction.machineInitialState : PRFunction 1 :=
  PRFunction.machineStateIn
    (PRFunction.machineStackPushIn
      (PRFunction.machineProcessTaskIn
        (PRFunction.constant 1 1)
        PRFunction.identity
        (PRFunction.constant 1 0))
      (PRFunction.constant 1 0))
    (PRFunction.constant 1 0)

def PRFunction.machineSubstituteNumeral : PRFunction 2 :=
  let code := PRFunction.projection 2 0 (by omega)
  let value := PRFunction.projection 2 1 (by omega)
  let fuel := PRFunction.unaryIn PRFunction.double code
  let initial := PRFunction.unaryIn PRFunction.machineInitialState code
  let finalState := PRFunction.composition PRFunction.machineRun
    (PRFunctionVector.cons fuel
      (PRFunctionVector.cons initial (PRFunctionVector.singleton value)))
  PRFunction.unaryIn PRFunction.machineStackHead
    (PRFunction.unaryIn PRFunction.unpairRight finalState)

/-- Unary self-substitution used by the genuine diagonal lemma. -/
def PRFunction.captureAvoidingDiagonalSubstitution : PRFunction 1 :=
  PRFunction.composition PRFunction.machineSubstituteNumeral
    (PRFunctionVector.cons PRFunction.identity
      (PRFunctionVector.singleton PRFunction.identity))

/-! ## Correctness of the numeric program -/

@[simp] theorem PRFunction.run_machineStackPush (item stack : Nat) :
    PRFunction.machineStackPush.run
        (NatVector.cons item (NatVector.cons stack NatVector.nil)) =
      substitutionStackPush item stack := by
  change Nat.succ (PRFunction.pair.run _) = _
  rw [PRFunction.run_pair]
  rfl

@[simp] theorem PRFunction.run_machineStackHead (stack : Nat) :
    PRFunction.machineStackHead.run (NatVector.cons stack NatVector.nil) =
      substitutionStackHead stack := by
  cases stack with
  | zero => rfl
  | succ encoded =>
      simp [PRFunction.machineStackHead, substitutionStackHead,
        natIfZero]

@[simp] theorem PRFunction.run_machineStackTail (stack : Nat) :
    PRFunction.machineStackTail.run (NatVector.cons stack NatVector.nil) =
      substitutionStackTail stack := by
  cases stack with
  | zero => rfl
  | succ encoded =>
      simp [PRFunction.machineStackTail, substitutionStackTail,
        natIfZero]

@[simp] theorem PRFunction.run_machineTask (tag payload : Nat) :
    PRFunction.machineTask.run
        (NatVector.cons tag (NatVector.cons payload NatVector.nil)) =
      substitutionTask tag payload := by
  change Nat.succ (PRFunction.pair.run _) = _
  rw [PRFunction.run_pair]
  rfl

@[simp] theorem PRFunction.run_machineState (work results : Nat) :
    PRFunction.machineState.run
        (NatVector.cons work (NatVector.cons results NatVector.nil)) =
      substitutionMachineState work results :=
  PRFunction.run_pair work results

@[simp] theorem PRFunction.run_machineStackPushIn
    {arity : Nat}
    (item stack : PRFunction arity)
    (inputs : NatVector arity) :
    (PRFunction.machineStackPushIn item stack).run inputs =
      substitutionStackPush (item.run inputs) (stack.run inputs) := by
  change PRFunction.machineStackPush.run _ = _
  rw [PRFunction.run_machineStackPush]

@[simp] theorem PRFunction.run_machineTaskIn
    {arity : Nat}
    (tag payload : PRFunction arity)
    (inputs : NatVector arity) :
    (PRFunction.machineTaskIn tag payload).run inputs =
      substitutionTask (tag.run inputs) (payload.run inputs) := by
  change PRFunction.machineTask.run _ = _
  rw [PRFunction.run_machineTask]

@[simp] theorem PRFunction.run_machineStateIn
    {arity : Nat}
    (work results : PRFunction arity)
    (inputs : NatVector arity) :
    (PRFunction.machineStateIn work results).run inputs =
      substitutionMachineState (work.run inputs) (results.run inputs) := by
  change PRFunction.machineState.run _ = _
  rw [PRFunction.run_machineState]

@[simp] theorem PRFunction.run_machineProcessTaskIn
    {arity : Nat}
    (taskTag code depth : PRFunction arity)
    (inputs : NatVector arity) :
    (PRFunction.machineProcessTaskIn taskTag code depth).run inputs =
      substitutionTask
        (taskTag.run inputs)
        (natPair (code.run inputs) (depth.run inputs)) := by
  simp [PRFunction.machineProcessTaskIn]

@[simp] theorem PRFunction.run_machinePushResultIn
    {arity : Nat}
    (work results result : PRFunction arity)
    (inputs : NatVector arity) :
    (PRFunction.machinePushResultIn work results result).run inputs =
      substitutionPushResult
        (work.run inputs) (results.run inputs) (result.run inputs) := by
  simp [PRFunction.machinePushResultIn, substitutionPushResult]

@[simp] theorem PRFunction.run_machineBuildUnaryIn
    {arity : Nat}
    (syntaxTag work results : PRFunction arity)
    (inputs : NatVector arity) :
    (PRFunction.machineBuildUnaryIn syntaxTag work results).run inputs =
      substitutionBuildUnary
        (syntaxTag.run inputs) (work.run inputs) (results.run inputs) := by
  simp [PRFunction.machineBuildUnaryIn, substitutionBuildUnary,
    substitutionPushResult]

@[simp] theorem PRFunction.run_machineBuildBinaryIn
    {arity : Nat}
    (syntaxTag work results : PRFunction arity)
    (inputs : NatVector arity) :
    (PRFunction.machineBuildBinaryIn syntaxTag work results).run inputs =
      substitutionBuildBinary
        (syntaxTag.run inputs) (work.run inputs) (results.run inputs) := by
  simp [PRFunction.machineBuildBinaryIn, substitutionBuildBinary,
    substitutionPushResult]

/-- Numeric less-than bits are exact constructive characteristic values. -/
theorem natLessBit_eq_one_of_lt
    {left right : Nat}
    (strict : left < right) :
    natLessBit left right = 1 := by
  unfold natLessBit natPositiveBit
  have positive : 0 < right - left := Nat.sub_pos_of_lt strict
  cases difference : right - left with
  | zero => exact (Nat.lt_irrefl 0 (difference ▸ positive)).elim
  | succ difference => rfl

theorem natLessBit_eq_zero_of_not_lt
    {left right : Nat}
    (notStrict : left < right -> False) :
    natLessBit left right = 0 := by
  unfold natLessBit natPositiveBit
  rw [Nat.sub_eq_zero_of_le (Nat.le_of_not_gt notStrict)]
  rfl

/-- The five-input term program implements the numeric term step exactly. -/
theorem PRFunction.run_machineProcessTermStep
    (code depth work results value : Nat) :
    PRFunction.machineProcessTermStep.run
        (NatVector.cons code
          (NatVector.cons depth
            (NatVector.cons work
              (NatVector.cons results
                (NatVector.cons value NatVector.nil))))) =
      substitutionProcessTermStep code depth work results value := by
  cases code with
  | zero =>
      simp [PRFunction.machineProcessTermStep,
        substitutionProcessTermStep, natIfZero]
  | succ encoded =>
      cases components : natUnpair encoded with
      | mk tag payload =>
          have leftComponent : natUnpairLeft encoded = tag := by
            unfold natUnpairLeft
            rw [← components]
            rfl
          have rightComponent : natUnpairRight encoded = payload := by
            unfold natUnpairRight
            rw [← components]
            rfl
          rw [show encoded = natPair tag payload by
            exact (congrArg (fun pair => natPair pair.1 pair.2) components).symm.trans
              (natUnpair_pair tag payload ▸ rfl)]
          rw [natUnpairLeft_pair, natUnpairRight_pair]
          cases tag with
          | zero =>
              by_cases bounded : payload < depth
              · rw [natLessBit_eq_one_of_lt bounded]
                simp [PRFunction.machineProcessTermStep,
                  substitutionProcessTermStep, natIfZero,
                  natEqualBit, natIsZero]
              · rw [natLessBit_eq_zero_of_not_lt bounded]
                simp [PRFunction.machineProcessTermStep,
                  substitutionProcessTermStep, natIfZero,
                  natEqualBit, natIsZero]
          | succ tag =>
              cases tag with
              | zero =>
                  simp [PRFunction.machineProcessTermStep,
                    substitutionProcessTermStep, natIfZero,
                    natEqualBit, natIsZero]
              | succ tag =>
                  cases tag with
                  | zero =>
                      simp [PRFunction.machineProcessTermStep,
                        substitutionProcessTermStep, natIfZero,
                        natEqualBit, natIsZero]
                  | succ tag =>
                      cases tag with
                      | zero =>
                          simp [PRFunction.machineProcessTermStep,
                            substitutionProcessTermStep, natIfZero,
                            natEqualBit, natIsZero]
                      | succ tag =>
                          cases tag with
                          | zero =>
                              simp [PRFunction.machineProcessTermStep,
                                substitutionProcessTermStep, natIfZero,
                                natEqualBit, natIsZero]

/-- The five-input formula program implements the numeric formula step exactly. -/
theorem PRFunction.run_machineProcessFormulaStep
    (code depth work results value : Nat) :
    PRFunction.machineProcessFormulaStep.run
        (NatVector.cons code
          (NatVector.cons depth
            (NatVector.cons work
              (NatVector.cons results
                (NatVector.cons value NatVector.nil))))) =
      substitutionProcessFormulaStep code depth work results value := by
  cases code with
  | zero =>
      simp [PRFunction.machineProcessFormulaStep,
        substitutionProcessFormulaStep, natIfZero]
  | succ encoded =>
      cases components : natUnpair encoded with
      | mk tag payload =>
          rw [show encoded = natPair tag payload by
            exact (congrArg (fun pair => natPair pair.1 pair.2) components).symm.trans
              (natUnpair_pair tag payload ▸ rfl)]
          rw [natUnpairLeft_pair, natUnpairRight_pair]
          cases tag with
          | zero =>
              simp [PRFunction.machineProcessFormulaStep,
                substitutionProcessFormulaStep, natIfZero,
                natEqualBit, natIsZero]
          | succ tag =>
              cases tag with
              | zero =>
                  simp [PRFunction.machineProcessFormulaStep,
                    substitutionProcessFormulaStep, natIfZero,
                    natEqualBit, natIsZero]
              | succ tag =>
                  cases tag with
                  | zero =>
                      simp [PRFunction.machineProcessFormulaStep,
                        substitutionProcessFormulaStep, natIfZero,
                        natEqualBit, natIsZero]
                  | succ tag =>
                      cases tag with
                      | zero =>
                          simp [PRFunction.machineProcessFormulaStep,
                            substitutionProcessFormulaStep, natIfZero,
                            natEqualBit, natIsZero]
                      | succ tag =>
                          cases tag with
                          | zero =>
                              simp [PRFunction.machineProcessFormulaStep,
                                substitutionProcessFormulaStep, natIfZero,
                                natEqualBit, natIsZero]
                          | succ tag =>
                              cases tag with
                              | zero =>
                                  simp [PRFunction.machineProcessFormulaStep,
                                    substitutionProcessFormulaStep, natIfZero,
                                    natEqualBit, natIsZero]
                              | succ tag =>
                                  cases tag with
                                  | zero =>
                                      simp [PRFunction.machineProcessFormulaStep,
                                        substitutionProcessFormulaStep, natIfZero,
                                        natEqualBit, natIsZero]

/-- The two-input positive program implements one complete machine step. -/
theorem PRFunction.run_machineStep (state value : Nat) :
    PRFunction.machineStep.run
        (NatVector.cons state (NatVector.cons value NatVector.nil)) =
      substitutionMachineStep state value := by
  cases stateComponents : natUnpair state with
  | mk work results =>
      rw [show state = natPair work results by
        exact (congrArg (fun pair => natPair pair.1 pair.2) stateComponents).symm.trans
          (natUnpair_pair work results ▸ rfl)]
      rw [natUnpairLeft_pair, natUnpairRight_pair]
      cases work with
      | zero =>
          simp [PRFunction.machineStep, substitutionMachineStep,
            substitutionMachineState, natIfZero]
      | succ encodedWork =>
          cases workComponents : natUnpair encodedWork with
          | mk task remainingWork =>
              rw [show encodedWork = natPair task remainingWork by
                exact (congrArg (fun pair => natPair pair.1 pair.2)
                  workComponents).symm.trans
                  (natUnpair_pair task remainingWork ▸ rfl)]
              rw [natUnpairLeft_pair, natUnpairRight_pair]
              cases task with
              | zero =>
                  simp [PRFunction.machineStep, substitutionMachineStep,
                    substitutionMachineState, natIfZero]
              | succ encodedTask =>
                  cases taskComponents : natUnpair encodedTask with
                  | mk tag payload =>
                      rw [show encodedTask = natPair tag payload by
                        exact (congrArg (fun pair => natPair pair.1 pair.2)
                          taskComponents).symm.trans
                          (natUnpair_pair tag payload ▸ rfl)]
                      rw [natUnpairLeft_pair, natUnpairRight_pair]
                      cases tag with
                      | zero =>
                          simp [PRFunction.machineStep,
                            substitutionMachineStep,
                            substitutionMachineState, natIfZero,
                            natEqualBit, natIsZero]
                      | succ tag =>
                          cases tag with
                          | zero =>
                              simp [PRFunction.machineStep,
                                substitutionMachineStep,
                                substitutionMachineState, natIfZero,
                                natEqualBit, natIsZero]
                          | succ tag =>
                              cases tag with
                              | zero =>
                                  simp [PRFunction.machineStep,
                                    substitutionMachineStep,
                                    substitutionMachineState, natIfZero,
                                    natEqualBit, natIsZero]
                              | succ tag =>
                                  cases tag with
                                  | zero =>
                                      simp [PRFunction.machineStep,
                                        substitutionMachineStep,
                                        substitutionMachineState, natIfZero,
                                        natEqualBit, natIsZero]
                                  | succ tag =>
                                      cases tag with
                                      | zero =>
                                          simp [PRFunction.machineStep,
                                            substitutionMachineStep,
                                            substitutionMachineState, natIfZero,
                                            natEqualBit, natIsZero]
                                      | succ tag =>
                                          cases tag with
                                          | zero =>
                                              simp [PRFunction.machineStep,
                                                substitutionMachineStep,
                                                substitutionMachineState,
                                                natIfZero, natEqualBit, natIsZero]
                                          | succ tag =>
                                              cases tag with
                                              | zero =>
                                                  simp [PRFunction.machineStep,
                                                    substitutionMachineStep,
                                                    substitutionMachineState,
                                                    natIfZero, natEqualBit,
                                                    natIsZero]
                                              | succ tag =>
                                                  cases tag with
                                                  | zero =>
                                                      simp [PRFunction.machineStep,
                                                        substitutionMachineStep,
                                                        substitutionMachineState,
                                                        natIfZero, natEqualBit,
                                                        natIsZero]
                                                  | succ tag =>
                                                      cases tag with
                                                      | zero =>
                                                          simp [PRFunction.machineStep,
                                                            substitutionMachineStep,
                                                            substitutionMachineState,
                                                            natIfZero, natEqualBit,
                                                            natIsZero]
                                                      | succ tag =>
                                                          cases tag with
                                                          | zero =>
                                                              simp [PRFunction.machineStep,
                                                                substitutionMachineStep,
                                                                substitutionMachineState,
                                                                natIfZero, natEqualBit,
                                                                natIsZero]
                                                          | succ tag =>
                                                              cases tag with
                                                              | zero =>
                                                                  simp [PRFunction.machineStep,
                                                                    substitutionMachineStep,
                                                                    substitutionMachineState,
                                                                    natIfZero,
                                                                    natEqualBit,
                                                                    natIsZero]

@[simp] theorem PRFunction.run_machineIterationStep
    (counter previous state value : Nat) :
    PRFunction.machineIterationStep.run
        (NatVector.cons counter
          (NatVector.cons previous
            (NatVector.cons state
              (NatVector.cons value NatVector.nil)))) =
      substitutionMachineStep previous value := by
  change PRFunction.machineStep.run _ = _
  rw [PRFunction.run_machineStep]

/-- The primitive-recursion iterator is exactly the semantic machine run. -/
theorem PRFunction.run_machineRun
    (steps state value : Nat) :
    PRFunction.machineRun.run
        (NatVector.cons steps
          (NatVector.cons state
            (NatVector.cons value NatVector.nil))) =
      substitutionMachineRun steps state value := by
  induction steps with
  | zero => rfl
  | succ steps inductionHypothesis =>
      change
        PRFunction.machineIterationStep.run
            (NatVector.cons steps
              (NatVector.cons
                (PRFunction.machineRun.run
                  (NatVector.cons steps
                    (NatVector.cons state
                      (NatVector.cons value NatVector.nil))))
                (NatVector.cons state
                  (NatVector.cons value NatVector.nil)))) = _
      rw [PRFunction.run_machineIterationStep, inductionHypothesis]
      rfl

@[simp] theorem PRFunction.run_machineInitialState (formulaCode : Nat) :
    PRFunction.machineInitialState.run
        (NatVector.cons formulaCode NatVector.nil) =
      substitutionMachineInitialState formulaCode := by
  simp [PRFunction.machineInitialState,
    substitutionMachineInitialState, substitutionMachineState,
    substitutionStackPush, substitutionProcessFormulaTask,
    substitutionTask]

/-- The explicit binary program computes the verified code substitution. -/
theorem PRFunction.run_machineSubstituteNumeral
    (formulaCode value : Nat) :
    PRFunction.machineSubstituteNumeral.run
        (NatVector.cons formulaCode
          (NatVector.cons value NatVector.nil)) =
      machineSubstituteNumeralCode formulaCode value := by
  simp [PRFunction.machineSubstituteNumeral,
    machineSubstituteNumeralCode,
    PRFunction.run_machineRun]

/-- Positive execution certificate for substitution on every genuine code. -/
theorem PRFunction.machineSubstituteNumeral_evaluates_code
    (formula : RawFormula)
    (value : Nat) :
    PRFunction.Evaluates PRFunction.machineSubstituteNumeral
        (NatVector.cons formula.code
          (NatVector.cons value NatVector.nil))
        (formula.instantiateNumeral value).code := by
  have evaluation := PRFunction.machineSubstituteNumeral.run_evaluates
    (NatVector.cons formula.code
      (NatVector.cons value NatVector.nil))
  rw [PRFunction.run_machineSubstituteNumeral,
    machineSubstituteNumeralCode_code] at evaluation
  exact evaluation

/-- The unary diagonal program computes capture-avoiding self-substitution. -/
theorem PRFunction.captureAvoidingDiagonalSubstitution_evaluates_code
    (formula : RawFormula) :
    PRFunction.Evaluates PRFunction.captureAvoidingDiagonalSubstitution
        (NatVector.cons formula.code NatVector.nil)
        (formula.instantiateNumeral formula.code).code := by
  apply PRFunction.Evaluates.composition
  · exact PRFunctionVector.Evaluates.cons
      (PRFunction.Evaluates.projection
        0 (Nat.zero_lt_succ 0)
        (NatVector.cons formula.code NatVector.nil))
      (PRFunctionVector.Evaluates.cons
        (PRFunction.Evaluates.projection
          0 (Nat.zero_lt_succ 0)
          (NatVector.cons formula.code NatVector.nil))
        (PRFunctionVector.Evaluates.nil
          (NatVector.cons formula.code NatVector.nil)))
  · exact PRFunction.machineSubstituteNumeral_evaluates_code
      formula formula.code
                                                              | succ tag =>
                                                                  simp [PRFunction.machineStep,
                                                                    substitutionMachineStep,
                                                                    substitutionMachineState,
                                                                    natIfZero,
                                                                    natEqualBit,
                                                                    natIsZero]
                                  | succ tag =>
                                      simp [PRFunction.machineProcessFormulaStep,
                                        substitutionProcessFormulaStep, natIfZero,
                                        natEqualBit, natIsZero]
                          | succ tag =>
                              simp [PRFunction.machineProcessTermStep,
                                substitutionProcessTermStep, natIfZero,
                                natEqualBit, natIsZero]

end BareArithmeticTarski
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.BareArithmeticTarski.PRFunction.machineProcessTermStep
#print axioms Meta.BareArithmeticTarski.PRFunction.machineProcessFormulaStep
#print axioms Meta.BareArithmeticTarski.PRFunction.machineStep
#print axioms Meta.BareArithmeticTarski.PRFunction.machineRun
#print axioms Meta.BareArithmeticTarski.PRFunction.machineSubstituteNumeral
#print axioms Meta.BareArithmeticTarski.PRFunction.captureAvoidingDiagonalSubstitution
#print axioms Meta.BareArithmeticTarski.PRFunction.run_machineRun
#print axioms Meta.BareArithmeticTarski.PRFunction.captureAvoidingDiagonalSubstitution_evaluates_code
/- AXIOM_AUDIT_END -/
