import Meta.Tarski.BareArithmetic.CodeSubstitution

/-!
# Positive language of primitive-recursive programs

This module starts gate G5 with an intrinsically generated program language.
There is no constructor carrying an arbitrary Lean function.  Consequently a
future certificate for code substitution must be an actual program tree.
-/

namespace Meta
namespace BareArithmeticTarski

/-- Length-indexed vectors used as program inputs and intermediate outputs. -/
inductive NatVector : Nat -> Type
  | nil : NatVector 0
  | cons {length : Nat} : Nat -> NatVector length -> NatVector (Nat.succ length)

/-- Constructive lookup in a length-indexed vector. -/
def NatVector.get
    {length : Nat}
    (values : NatVector length)
    (index : Nat)
    (bounded : index < length) :
    Nat :=
  match values with
  | NatVector.nil => (Nat.not_lt_zero index bounded).elim
  | NatVector.cons head tail =>
      match index with
      | 0 => head
      | Nat.succ inner =>
          tail.get inner (Nat.lt_of_succ_lt_succ bounded)

mutual
  /-- Standard primitive-recursive program trees, indexed by input arity. -/
  inductive PRFunction : Nat -> Type
    | zero {arity : Nat} : PRFunction arity
    | successor : PRFunction 1
    | projection
        (arity index : Nat)
        (bounded : index < arity) :
        PRFunction arity
    | composition
        {inputArity outputArity : Nat} :
        PRFunction outputArity ->
        PRFunctionVector inputArity outputArity ->
        PRFunction inputArity
    | primitiveRecursion
        {parameterArity : Nat} :
        PRFunction parameterArity ->
        PRFunction (Nat.succ (Nat.succ parameterArity)) ->
        PRFunction (Nat.succ parameterArity)

  /-- A vector of programs sharing the same input arity. -/
  inductive PRFunctionVector : Nat -> Nat -> Type
    | nil {inputArity : Nat} : PRFunctionVector inputArity 0
    | cons
        {inputArity length : Nat} :
        PRFunction inputArity ->
        PRFunctionVector inputArity length ->
        PRFunctionVector inputArity (Nat.succ length)
end

mutual
  /-- Positive execution evidence for a primitive-recursive program. -/
  inductive PRFunction.Evaluates :
      {arity : Nat} -> PRFunction arity -> NatVector arity -> Nat -> Prop
    | zero
        {arity : Nat}
        (inputs : NatVector arity) :
        PRFunction.Evaluates PRFunction.zero inputs 0
    | successor
        (value : Nat) :
        PRFunction.Evaluates
          PRFunction.successor
          (NatVector.cons value NatVector.nil)
          (Nat.succ value)
    | projection
        {arity : Nat}
        (index : Nat)
        (bounded : index < arity)
        (inputs : NatVector arity) :
        PRFunction.Evaluates
          (PRFunction.projection arity index bounded)
          inputs
          (inputs.get index bounded)
    | composition
        {inputArity outputArity : Nat}
        {outer : PRFunction outputArity}
        {inner : PRFunctionVector inputArity outputArity}
        {inputs : NatVector inputArity}
        {intermediate : NatVector outputArity}
        {output : Nat}
        (innerEvaluation :
          PRFunctionVector.Evaluates inner inputs intermediate)
        (outerEvaluation :
          PRFunction.Evaluates outer intermediate output) :
        PRFunction.Evaluates
          (PRFunction.composition outer inner)
          inputs
          output
    | primitiveZero
        {parameterArity : Nat}
        {base : PRFunction parameterArity}
        {step : PRFunction (Nat.succ (Nat.succ parameterArity))}
        {parameters : NatVector parameterArity}
        {output : Nat}
        (baseEvaluation : PRFunction.Evaluates base parameters output) :
        PRFunction.Evaluates
          (PRFunction.primitiveRecursion base step)
          (NatVector.cons 0 parameters)
          output
    | primitiveSucc
        {parameterArity : Nat}
        {base : PRFunction parameterArity}
        {step : PRFunction (Nat.succ (Nat.succ parameterArity))}
        {counter previous output : Nat}
        {parameters : NatVector parameterArity}
        (previousEvaluation :
          PRFunction.Evaluates
            (PRFunction.primitiveRecursion base step)
            (NatVector.cons counter parameters)
            previous)
        (stepEvaluation :
          PRFunction.Evaluates
            step
            (NatVector.cons counter
              (NatVector.cons previous parameters))
            output) :
        PRFunction.Evaluates
          (PRFunction.primitiveRecursion base step)
          (NatVector.cons (Nat.succ counter) parameters)
          output

  /-- Positive pointwise execution evidence for a vector of programs. -/
  inductive PRFunctionVector.Evaluates :
      {inputArity outputArity : Nat} ->
        PRFunctionVector inputArity outputArity ->
        NatVector inputArity ->
        NatVector outputArity ->
        Prop
    | nil
        {inputArity : Nat}
        (inputs : NatVector inputArity) :
        PRFunctionVector.Evaluates
          PRFunctionVector.nil
          inputs
          NatVector.nil
    | cons
        {inputArity length : Nat}
        {head : PRFunction inputArity}
        {tail : PRFunctionVector inputArity length}
        {inputs : NatVector inputArity}
        {headOutput : Nat}
        {tailOutput : NatVector length}
        (headEvaluation : PRFunction.Evaluates head inputs headOutput)
        (tailEvaluation :
          PRFunctionVector.Evaluates tail inputs tailOutput) :
        PRFunctionVector.Evaluates
          (PRFunctionVector.cons head tail)
          inputs
          (NatVector.cons headOutput tailOutput)
end

/-- The unary identity program. -/
def PRFunction.identity : PRFunction 1 :=
  PRFunction.projection 1 0 (Nat.zero_lt_succ 0)

/-- A closed positive execution witness for successor. -/
def PRFunction.successor_evaluates (value : Nat) :
    PRFunction.Evaluates
      PRFunction.successor
      (NatVector.cons value NatVector.nil)
      (Nat.succ value) :=
  PRFunction.Evaluates.successor value

/-- A closed positive execution witness for projections. -/
def PRFunction.projection_evaluates
    (arity index : Nat)
    (bounded : index < arity)
    (inputs : NatVector arity) :
    PRFunction.Evaluates
      (PRFunction.projection arity index bounded)
      inputs
      (inputs.get index bounded) :=
  PRFunction.Evaluates.projection index bounded inputs

end BareArithmeticTarski
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.BareArithmeticTarski.NatVector
#print axioms Meta.BareArithmeticTarski.PRFunction
#print axioms Meta.BareArithmeticTarski.PRFunctionVector
#print axioms Meta.BareArithmeticTarski.PRFunction.Evaluates
#print axioms Meta.BareArithmeticTarski.PRFunctionVector.Evaluates
#print axioms Meta.BareArithmeticTarski.PRFunction.successor_evaluates
#print axioms Meta.BareArithmeticTarski.PRFunction.projection_evaluates
/- AXIOM_AUDIT_END -/
