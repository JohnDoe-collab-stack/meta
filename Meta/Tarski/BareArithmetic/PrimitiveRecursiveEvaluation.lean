import Meta.Tarski.BareArithmetic.PrimitiveRecursiveSyntaxCoding

/-!
# Total evaluator for positive primitive-recursive programs

The evaluator is defined only by recursion on the positive program tree and,
in the primitive-recursion case, on the explicit natural counter.  It carries
no arbitrary Lean function.  Its correctness is witnessed by the original
positive `Evaluates` relation.
-/

namespace Meta
namespace BareArithmeticTarski

mutual
  /-- Total structural evaluator of a positive primitive-recursive program. -/
  def PRFunction.run :
      {arity : Nat} -> PRFunction arity -> NatVector arity -> Nat
    | _arity, PRFunction.zero, _inputs => 0
    | _arity, PRFunction.successor,
        NatVector.cons value NatVector.nil => Nat.succ value
    | _arity, PRFunction.projection _arity index bounded, inputs =>
        inputs.get index bounded
    | _arity, PRFunction.composition outer inner, inputs =>
        PRFunction.run outer (PRFunctionVector.run inner inputs)
    | _arity, @PRFunction.primitiveRecursion parameterArity base step,
        NatVector.cons counter parameters =>
        counter.rec
          (PRFunction.run base parameters)
          (fun index previous =>
            PRFunction.run step
              (NatVector.cons index
                (NatVector.cons previous parameters)))

  /-- Pointwise total evaluator for a vector of positive programs. -/
  def PRFunctionVector.run :
      {inputArity outputArity : Nat} ->
        PRFunctionVector inputArity outputArity ->
        NatVector inputArity ->
        NatVector outputArity
    | _inputArity, _outputArity, PRFunctionVector.nil, _inputs =>
        NatVector.nil
    | _inputArity, _outputArity,
        PRFunctionVector.cons head tail, inputs =>
        NatVector.cons
          (PRFunction.run head inputs)
          (PRFunctionVector.run tail inputs)
end


mutual
  /-- Positive program execution is functional. -/
  theorem PRFunction.evaluates_unique
      {arity : Nat}
      {program : PRFunction arity}
      {inputs : NatVector arity}
      {left right : Nat}
      (leftEvaluation : PRFunction.Evaluates program inputs left)
      (rightEvaluation : PRFunction.Evaluates program inputs right) :
      left = right := by
    induction leftEvaluation generalizing right with
    | zero =>
        cases rightEvaluation
        rfl
    | successor =>
        cases rightEvaluation
        rfl
    | projection =>
        cases rightEvaluation
        rfl
    | @composition inputArity outputArity outer inner inputs
        intermediate output innerEvaluation outerEvaluation
        innerHypothesis outerHypothesis =>
        cases rightEvaluation with
        | @composition _ _ _ _ _ rightIntermediate _
            rightInner rightOuter =>
            have sameIntermediate : intermediate = rightIntermediate :=
              PRFunctionVector.evaluates_unique
                innerEvaluation rightInner
            cases sameIntermediate
            exact outerHypothesis rightOuter
    | @primitiveZero parameterArity base step parameters output
        baseEvaluation baseHypothesis =>
        cases rightEvaluation with
        | primitiveZero rightBase =>
            exact baseHypothesis rightBase
    | @primitiveSucc parameterArity base step counter previous output
        parameters previousEvaluation stepEvaluation
        previousHypothesis stepHypothesis =>
        cases rightEvaluation with
        | primitiveSucc rightPrevious rightStep =>
            have samePrevious : previous = _ :=
              previousHypothesis rightPrevious
            cases samePrevious
            exact stepHypothesis rightStep

  /-- Pointwise vector execution is functional. -/
  theorem PRFunctionVector.evaluates_unique
      {inputArity outputArity : Nat}
      {programs : PRFunctionVector inputArity outputArity}
      {inputs : NatVector inputArity}
      {left right : NatVector outputArity}
      (leftEvaluation : PRFunctionVector.Evaluates programs inputs left)
      (rightEvaluation : PRFunctionVector.Evaluates programs inputs right) :
      left = right := by
    induction leftEvaluation generalizing right with
    | nil =>
        cases rightEvaluation
        rfl
    | @cons inputArity length head tail inputs headOutput tailOutput
        headEvaluation tailEvaluation headHypothesis tailHypothesis =>
        cases rightEvaluation with
        | @cons _ _ _ _ _ rightHead rightTail
            rightHeadEvaluation rightTailEvaluation =>
            have sameHead : headOutput = rightHead :=
              PRFunction.evaluates_unique
                headEvaluation rightHeadEvaluation
            have sameTail : tailOutput = rightTail :=
              tailHypothesis rightTailEvaluation
            cases sameHead
            cases sameTail
            rfl
end

mutual
  /-- The structural evaluator always produces positive execution evidence. -/
  def PRFunction.run_evaluates :
      {arity : Nat} ->
        (program : PRFunction arity) ->
        (inputs : NatVector arity) ->
          PRFunction.Evaluates program inputs (program.run inputs)
    | _arity, PRFunction.zero, inputs =>
        PRFunction.Evaluates.zero inputs
    | _arity, PRFunction.successor,
        NatVector.cons value NatVector.nil =>
        PRFunction.Evaluates.successor value
    | _arity, PRFunction.projection arity index bounded, inputs =>
        PRFunction.Evaluates.projection index bounded inputs
    | _arity, PRFunction.composition outer inner, inputs =>
        PRFunction.Evaluates.composition
          (PRFunctionVector.run_evaluates inner inputs)
          (PRFunction.run_evaluates outer (inner.run inputs))
    | _arity, @PRFunction.primitiveRecursion parameterArity base step,
        NatVector.cons counter parameters => by
        induction counter with
        | zero =>
            exact PRFunction.Evaluates.primitiveZero
              (PRFunction.run_evaluates base parameters)
        | succ counter inductionHypothesis =>
            exact PRFunction.Evaluates.primitiveSucc
              inductionHypothesis
              (PRFunction.run_evaluates step
                (NatVector.cons counter
                  (NatVector.cons
                    ((PRFunction.primitiveRecursion base step).run
                      (NatVector.cons counter parameters))
                    parameters)))

  /-- The vector evaluator always produces pointwise execution evidence. -/
  def PRFunctionVector.run_evaluates :
      {inputArity outputArity : Nat} ->
        (programs : PRFunctionVector inputArity outputArity) ->
        (inputs : NatVector inputArity) ->
          PRFunctionVector.Evaluates
            programs inputs (programs.run inputs)
    | _inputArity, _outputArity, PRFunctionVector.nil, inputs =>
        PRFunctionVector.Evaluates.nil inputs
    | _inputArity, _outputArity,
        PRFunctionVector.cons head tail, inputs =>
        PRFunctionVector.Evaluates.cons
          (PRFunction.run_evaluates head inputs)
          (PRFunctionVector.run_evaluates tail inputs)
end

end BareArithmeticTarski
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.BareArithmeticTarski.PRFunction.run
#print axioms Meta.BareArithmeticTarski.PRFunctionVector.run
#print axioms Meta.BareArithmeticTarski.PRFunction.run_evaluates
#print axioms Meta.BareArithmeticTarski.PRFunctionVector.run_evaluates
#print axioms Meta.BareArithmeticTarski.PRFunction.evaluates_unique
#print axioms Meta.BareArithmeticTarski.PRFunctionVector.evaluates_unique
/- AXIOM_AUDIT_END -/
