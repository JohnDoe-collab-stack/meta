import Meta.Tarski.BareArithmetic.ArithmeticFormulaTools

/-!
# Constructive arithmetic representation of primitive-recursive programs

Every positive `PRFunction` tree is compiled to a formula in the bare
first-order language `{0,S,+,*,=,∧,∨,→,∀,∃}`.  Primitive recursion is encoded
with Goedel beta sequences.  The compiler introduces no semantic predicate and
no new arithmetic function symbol.
-/

namespace Meta
namespace BareArithmeticTarski

/-! ## Vectors of already compiled graphs -/

/-- A length-indexed vector of arithmetic graph formulas of common arity. -/
inductive ArithmeticGraphVector (inputArity : Nat) : Nat -> Type
  | nil : ArithmeticGraphVector inputArity 0
  | cons {length : Nat} :
      ArithmeticGraph inputArity ->
      ArithmeticGraphVector inputArity length ->
      ArithmeticGraphVector inputArity (Nat.succ length)

/-- A raw formula together with a selected ambient scope. -/
structure ScopedFormula (bound : Nat) where
  raw : RawFormula
  isScoped : raw.WellScoped bound

/-- Constructive truth, used as the neutral conjunction formula. -/
def trueFormula : RawFormula := RawFormula.impl RawFormula.falsum RawFormula.falsum

/-- The truth abbreviation is scoped in every context. -/
theorem trueFormula_wellScoped (bound : Nat) :
    trueFormula.WellScoped bound :=
  And.intro trivial trivial

/--
All component graphs applied to consecutive intermediate-output variables.

The complete intermediate vector occupies variables `[0,total)`.  The
original graph environment begins at `total`: its output is variable `total`
and its inputs begin at `total+1`.
-/
def ArithmeticGraphVector.body
    {inputArity length : Nat}
    (graphs : ArithmeticGraphVector inputArity length)
    (offset total : Nat)
    (fits : offset + length <= total) :
    ScopedFormula (total + Nat.succ inputArity) :=
  match graphs with
  | ArithmeticGraphVector.nil =>
      { raw := trueFormula
        isScoped := trueFormula_wellScoped _ }
  | @ArithmeticGraphVector.cons _ tailLength head tail =>
      let originalInputs :=
        RawTermVector.variables (Nat.succ total) inputArity
      let headApplication :=
        head.apply (RawTerm.bvar offset) originalInputs
      let tailBody :=
        tail.body (Nat.succ offset) total (by omega)
      { raw := RawFormula.conj headApplication tailBody.raw
        isScoped := And.intro
          (head.apply_wellScoped
            (RawTerm.bvar offset)
            originalInputs
            (by omega)
            (RawTermVector.variables_wellScoped
              (Nat.succ total)
              inputArity
              (total + Nat.succ inputArity)
              (by omega)))
          tailBody.isScoped }

/-! ## Closure of graph formulas under composition -/

/-- Arithmetic graph formula for composition through finitely many outputs. -/
def compositionGraph
    {inputArity outputArity : Nat}
    (outer : ArithmeticGraph outputArity)
    (inner : ArithmeticGraphVector inputArity outputArity) :
    ArithmeticGraph inputArity :=
  let intermediateTerms := RawTermVector.variables 0 outputArity
  let outerApplication :=
    outer.apply (RawTerm.bvar outputArity) intermediateTerms
  let innerBody := inner.body 0 outputArity (Nat.le_refl outputArity)
  let body := RawFormula.conj outerApplication innerBody.raw
  { raw := body.existsMany outputArity
    isScoped := RawFormula.existsMany_wellScoped
      outputArity
      (Nat.succ inputArity)
      body
      (And.intro
        (outer.apply_wellScoped
          (RawTerm.bvar outputArity)
          intermediateTerms
          (by omega)
          (RawTermVector.variables_wellScoped
            0 outputArity
            (outputArity + Nat.succ inputArity)
            (by omega)))
        innerBody.isScoped) }

/-! ## Closure of graph formulas under primitive recursion -/

/-- Terms for the parameter block of a primitive-recursion base clause. -/
def primitiveBaseParameters (parameterArity : Nat) :
    RawTermVector parameterArity :=
  RawTermVector.variables 5 parameterArity

/-- Terms for the step inputs `(counter, previous, parameters)`. -/
def primitiveStepInputs (parameterArity : Nat) :
    RawTermVector (Nat.succ (Nat.succ parameterArity)) :=
  RawTermVector.cons (RawTerm.bvar 2)
    (RawTermVector.cons (RawTerm.bvar 0)
      (RawTermVector.variables 7 parameterArity))

/--
Arithmetic graph of primitive recursion.

After the two outer witnesses, variables `0,1` are the beta dividend and
coefficient, while the original graph variables begin at `2`.  The transition
clause binds its counter universally and its adjacent sequence values
existentially.
-/
def primitiveRecursionGraph
    {parameterArity : Nat}
    (base : ArithmeticGraph parameterArity)
    (step : ArithmeticGraph (Nat.succ (Nat.succ parameterArity))) :
    ArithmeticGraph (Nat.succ parameterArity) :=
  let baseCore := RawFormula.conj
    (betaValueFormula
      (RawTerm.bvar 1)
      (RawTerm.bvar 2)
      RawTerm.zero
      (RawTerm.bvar 0))
    (base.apply
      (RawTerm.bvar 0)
      (primitiveBaseParameters parameterArity))
  let baseClause := RawFormula.ex baseCore
  let transitionCore := RawFormula.conj
    (betaValueFormula
      (RawTerm.bvar 3)
      (RawTerm.bvar 4)
      (RawTerm.bvar 2)
      (RawTerm.bvar 0))
    (RawFormula.conj
      (betaValueFormula
        (RawTerm.bvar 3)
        (RawTerm.bvar 4)
        (RawTerm.succ (RawTerm.bvar 2))
        (RawTerm.bvar 1))
      (step.apply
        (RawTerm.bvar 1)
        (primitiveStepInputs parameterArity)))
  let transitionClause := RawFormula.all
    (RawFormula.impl
      (lessThanFormula (RawTerm.bvar 0) (RawTerm.bvar 4))
      (transitionCore.existsMany 2))
  let outputClause := betaValueFormula
    (RawTerm.bvar 0)
    (RawTerm.bvar 1)
    (RawTerm.bvar 3)
    (RawTerm.bvar 2)
  let body := RawFormula.conj baseClause
    (RawFormula.conj transitionClause outputClause)
  { raw := body.existsMany 2
    isScoped := RawFormula.existsMany_wellScoped
      2
      (Nat.succ (Nat.succ parameterArity))
      body
      (And.intro
        (by
          apply And.intro
          · exact betaValueFormula_wellScoped
              (RawTerm.bvar 1)
              (RawTerm.bvar 2)
              RawTerm.zero
              (RawTerm.bvar 0)
              (by omega) (by omega) trivial (by omega)
          · exact base.apply_wellScoped
              (RawTerm.bvar 0)
              (primitiveBaseParameters parameterArity)
              (by omega)
              (RawTermVector.variables_wellScoped
                5 parameterArity
                (Nat.succ (2 + Nat.succ (Nat.succ parameterArity)))
                (by omega)))
        (And.intro
          (by
            apply And.intro
            · exact lessThanFormula_wellScoped
                (RawTerm.bvar 0)
                (RawTerm.bvar 4)
                (by omega) (by omega)
            · apply RawFormula.existsMany_wellScoped
              exact And.intro
                (betaValueFormula_wellScoped
                  (RawTerm.bvar 3)
                  (RawTerm.bvar 4)
                  (RawTerm.bvar 2)
                  (RawTerm.bvar 0)
                  (by omega) (by omega) (by omega) (by omega))
                (And.intro
                  (betaValueFormula_wellScoped
                    (RawTerm.bvar 3)
                    (RawTerm.bvar 4)
                    (RawTerm.succ (RawTerm.bvar 2))
                    (RawTerm.bvar 1)
                    (by omega) (by omega) (by
                      exact (by omega)) (by omega))
                  (step.apply_wellScoped
                    (RawTerm.bvar 1)
                    (primitiveStepInputs parameterArity)
                    (by omega)
                    (And.intro (by omega)
                      (And.intro (by omega)
                        (RawTermVector.variables_wellScoped
                          7 parameterArity
                          (2 + Nat.succ
                            (2 + Nat.succ (Nat.succ parameterArity)))
                          (by omega))))))
          (betaValueFormula_wellScoped
            (RawTerm.bvar 0)
            (RawTerm.bvar 1)
            (RawTerm.bvar 3)
            (RawTerm.bvar 2)
            (by omega) (by omega) (by omega) (by omega)))) }

/-! ## The compiler -/

mutual
  /-- Compile a positive primitive-recursive program to bare arithmetic. -/
  def PRFunction.graphFormula :
      {arity : Nat} -> PRFunction arity -> ArithmeticGraph arity
    | arity, PRFunction.zero =>
        { raw := RawFormula.equal (RawTerm.bvar 0) RawTerm.zero
          isScoped := And.intro (Nat.zero_lt_succ arity) trivial }
    | _arity, PRFunction.successor =>
        { raw := RawFormula.equal
            (RawTerm.bvar 0)
            (RawTerm.succ (RawTerm.bvar 1))
          isScoped := And.intro
            (Nat.zero_lt_succ 1)
            (Nat.succ_lt_succ (Nat.zero_lt_succ 0)) }
    | _arity, PRFunction.projection arity index bounded =>
        { raw := RawFormula.equal
            (RawTerm.bvar 0)
            (RawTerm.bvar (Nat.succ index))
          isScoped := And.intro
            (Nat.zero_lt_succ arity)
            (Nat.succ_lt_succ bounded) }
    | _arity, PRFunction.composition outer inner =>
        compositionGraph outer.graphFormula inner.graphFormulas
    | _arity, PRFunction.primitiveRecursion base step =>
        primitiveRecursionGraph base.graphFormula step.graphFormula

  /-- Compile a vector of programs pointwise. -/
  def PRFunctionVector.graphFormulas :
      {inputArity outputArity : Nat} ->
        PRFunctionVector inputArity outputArity ->
        ArithmeticGraphVector inputArity outputArity
    | _inputArity, _outputArity, PRFunctionVector.nil =>
        ArithmeticGraphVector.nil
    | _inputArity, _outputArity, PRFunctionVector.cons head tail =>
        ArithmeticGraphVector.cons
          head.graphFormula
          tail.graphFormulas
end

/-! ## Semantic correctness of composition -/

/-- A graph formula represents a positive execution relation exactly. -/
def ArithmeticGraph.Represents
    {arity : Nat}
    (graph : ArithmeticGraph arity)
    (program : PRFunction arity) :
    Prop :=
  (inputs : NatVector arity) ->
    (output : Nat) ->
      graph.Holds inputs output ↔
        PRFunction.Evaluates program inputs output

/-- Pointwise representation evidence for a vector of programs. -/
inductive ArithmeticGraphVector.Represents
    {inputArity : Nat} :
    {length : Nat} ->
      ArithmeticGraphVector inputArity length ->
      PRFunctionVector inputArity length ->
      Prop
  | nil :
      ArithmeticGraphVector.Represents
        ArithmeticGraphVector.nil
        PRFunctionVector.nil
  | cons
      {length : Nat}
      {headGraph : ArithmeticGraph inputArity}
      {tailGraphs : ArithmeticGraphVector inputArity length}
      {headProgram : PRFunction inputArity}
      {tailPrograms : PRFunctionVector inputArity length}
      (headRepresents : headGraph.Represents headProgram)
      (tailRepresents : tailGraphs.Represents tailPrograms) :
      ArithmeticGraphVector.Represents
        (ArithmeticGraphVector.cons headGraph tailGraphs)
        (PRFunctionVector.cons headProgram tailPrograms)

/-- Consecutive variable vectors read consecutive environment entries. -/
theorem RawTermVector.variables_evaluate_get
    (start length : Nat)
    (environment : Environment)
    (index : Nat)
    (bounded : index < length) :
    ((RawTermVector.variables start length).getD index).evaluate environment =
      environment (start + index) := by
  induction length generalizing start index with
  | zero => exact (Nat.not_lt_zero index bounded).elim
  | succ length inductionHypothesis =>
      cases index with
      | zero =>
          rw [Nat.add_zero]
      | succ index =>
          change
            ((RawTermVector.variables (Nat.succ start) length).getD index).evaluate
                environment =
              environment (start + Nat.succ index)
          rw [inductionHypothesis
            (Nat.succ start)
            index
            (Nat.lt_of_succ_lt_succ bounded)]
          rw [Nat.succ_add, Nat.add_succ]

/-- Evaluate an applied graph from pointwise values of all supplied terms. -/
theorem ArithmeticGraph.apply_holds_of_values
    {arity : Nat}
    (graph : ArithmeticGraph arity)
    (outputTerm : RawTerm)
    (inputTerms : RawTermVector arity)
    (environment : Environment)
    (inputs : NatVector arity)
    (output : Nat)
    (outputValue : outputTerm.evaluate environment = output)
    (inputValues :
      (index : Nat) ->
        (bounded : index < arity) ->
          (inputTerms.getD index).evaluate environment =
            inputs.get index bounded) :
    (graph.apply outputTerm inputTerms).Holds environment ↔
      graph.Holds inputs output := by
  apply Iff.trans (graph.apply_holds outputTerm inputTerms environment)
  apply graph.raw.holds_iff_of_scoped_agreement graph.isScoped
  intro index bounded
  cases index with
  | zero => exact outputValue
  | succ index =>
      rw [RawTermVector.evaluate_getD]
      exact inputValues index (Nat.lt_of_succ_lt_succ bounded)

/--
The conjunction generated for a graph vector represents pointwise vector
execution under any environment satisfying the documented variable layout.
-/
theorem ArithmeticGraphVector.body_holds_iff
    {inputArity length : Nat}
    {graphs : ArithmeticGraphVector inputArity length}
    {programs : PRFunctionVector inputArity length}
    (represents : graphs.Represents programs)
    (offset total : Nat)
    (fits : offset + length <= total)
    (environment : Environment)
    (inputs : NatVector inputArity)
    (outputs : NatVector length)
    (inputValues :
      (index : Nat) ->
        (bounded : index < inputArity) ->
          environment (Nat.succ total + index) =
            inputs.get index bounded)
    (outputValues :
      (index : Nat) ->
        (bounded : index < length) ->
          environment (offset + index) =
            outputs.get index bounded) :
    (graphs.body offset total fits).raw.Holds environment ↔
      PRFunctionVector.Evaluates programs inputs outputs := by
  induction represents generalizing offset outputs with
  | nil =>
      cases outputs with
      | nil =>
          constructor
          · intro _truth
            exact PRFunctionVector.Evaluates.nil inputs
          · intro _evaluation impossible
            exact impossible
  | @cons length headGraph tailGraphs headProgram tailPrograms
      headRepresents tailRepresents inductionHypothesis =>
      cases outputs with
      | cons headOutput tailOutputs =>
          change
            ((headGraph.apply
                (RawTerm.bvar offset)
                (RawTermVector.variables
                  (Nat.succ total) inputArity)).Holds environment ∧
              (tailGraphs.body
                (Nat.succ offset)
                total
                (by omega)).raw.Holds environment) ↔
              PRFunctionVector.Evaluates
                (PRFunctionVector.cons headProgram tailPrograms)
                inputs
                (NatVector.cons headOutput tailOutputs)
          have headFormula :
              (headGraph.apply
                (RawTerm.bvar offset)
                (RawTermVector.variables
                  (Nat.succ total) inputArity)).Holds environment ↔
                PRFunction.Evaluates headProgram inputs headOutput := by
            apply Iff.trans
              (headGraph.apply_holds_of_values
                (RawTerm.bvar offset)
                (RawTermVector.variables
                  (Nat.succ total) inputArity)
                environment
                inputs
                headOutput
                (outputValues 0 (Nat.zero_lt_succ length))
                (fun index bounded =>
                  (RawTermVector.variables_evaluate_get
                    (Nat.succ total)
                    inputArity
                    environment
                    index
                    bounded).trans
                    (inputValues index bounded)))
            exact headRepresents inputs headOutput
          have tailFormula :
              (tailGraphs.body
                (Nat.succ offset)
                total
                (by omega)).raw.Holds environment ↔
                PRFunctionVector.Evaluates
                  tailPrograms inputs tailOutputs := by
            apply inductionHypothesis
            · exact inputValues
            · intro index bounded
              have mapped :=
                outputValues
                  (Nat.succ index)
                  (Nat.succ_lt_succ bounded)
              change
                environment (Nat.succ offset + index) =
                  tailOutputs.get index bounded
              rw [Nat.succ_add]
              exact mapped
          constructor
          · intro conjunction
            exact PRFunctionVector.Evaluates.cons
              (headFormula.mp conjunction.1)
              (tailFormula.mp conjunction.2)
          · intro evaluation
            cases evaluation with
            | cons headEvaluation tailEvaluation =>
                exact And.intro
                  (headFormula.mpr headEvaluation)
                  (tailFormula.mpr tailEvaluation)

/-- The arithmetic graph constructor for composition is semantically exact. -/
theorem compositionGraph_represents
    {inputArity outputArity : Nat}
    {outerProgram : PRFunction outputArity}
    {innerPrograms : PRFunctionVector inputArity outputArity}
    (outerGraph : ArithmeticGraph outputArity)
    (innerGraphs : ArithmeticGraphVector inputArity outputArity)
    (outerRepresents : outerGraph.Represents outerProgram)
    (innerRepresents : innerGraphs.Represents innerPrograms) :
    (compositionGraph outerGraph innerGraphs).Represents
      (PRFunction.composition outerProgram innerPrograms) := by
  intro inputs output
  change
    ((RawFormula.conj
      (outerGraph.apply
        (RawTerm.bvar outputArity)
        (RawTermVector.variables 0 outputArity))
      (innerGraphs.body
        0 outputArity (Nat.le_refl outputArity)).raw).existsMany
          outputArity).Holds (graphEnvironment inputs output) ↔ _
  rw [RawFormula.existsMany_holds]
  constructor
  · intro witness
    cases witness with
    | intro intermediate bodyHolds =>
        have outerFormula :
            (outerGraph.apply
              (RawTerm.bvar outputArity)
              (RawTermVector.variables 0 outputArity)).Holds
                (prependEnvironment intermediate
                  (graphEnvironment inputs output)) ↔
              PRFunction.Evaluates
                outerProgram intermediate output := by
          apply Iff.trans
            (outerGraph.apply_holds_of_values
              (RawTerm.bvar outputArity)
              (RawTermVector.variables 0 outputArity)
              (prependEnvironment intermediate
                (graphEnvironment inputs output))
              intermediate
              output
              (prependEnvironment_shift
                intermediate
                (graphEnvironment inputs output)
                0)
              (fun index bounded =>
                (RawTermVector.variables_evaluate_get
                  0 outputArity
                  (prependEnvironment intermediate
                    (graphEnvironment inputs output))
                  index bounded).trans (by
                    rw [Nat.zero_add]
                    exact prependEnvironment_get
                      intermediate
                      (graphEnvironment inputs output)
                      bounded)))
          exact outerRepresents intermediate output
        have innerFormula :
            (innerGraphs.body
              0 outputArity (Nat.le_refl outputArity)).raw.Holds
                (prependEnvironment intermediate
                  (graphEnvironment inputs output)) ↔
              PRFunctionVector.Evaluates
                innerPrograms inputs intermediate := by
          apply innerGraphs.body_holds_iff
            innerRepresents
            0
            outputArity
            (Nat.le_refl outputArity)
          · intro index bounded
            rw [prependEnvironment_shift]
            rfl
          · intro index bounded
            rw [Nat.zero_add]
            exact prependEnvironment_get
              intermediate
              (graphEnvironment inputs output)
              bounded
        exact PRFunction.Evaluates.composition
          (innerFormula.mp bodyHolds.2)
          (outerFormula.mp bodyHolds.1)
  · intro evaluation
    cases evaluation with
    | @composition _ _ _ _ _ intermediate _
        innerEvaluation outerEvaluation =>
        refine Exists.intro intermediate ?_
        constructor
        · apply (outerGraph.apply_holds_of_values
            (RawTerm.bvar outputArity)
            (RawTermVector.variables 0 outputArity)
            (prependEnvironment intermediate
              (graphEnvironment inputs output))
            intermediate
            output
            (prependEnvironment_shift
              intermediate
              (graphEnvironment inputs output)
              0)
            (fun index bounded =>
              (RawTermVector.variables_evaluate_get
                0 outputArity
                (prependEnvironment intermediate
                  (graphEnvironment inputs output))
                index bounded).trans (by
                  rw [Nat.zero_add]
                  exact prependEnvironment_get
                    intermediate
                    (graphEnvironment inputs output)
                    bounded))).mpr
          ((outerRepresents intermediate output).mpr outerEvaluation)
        · apply (innerGraphs.body_holds_iff
            innerRepresents
            0
            outputArity
            (Nat.le_refl outputArity)
            (prependEnvironment intermediate
              (graphEnvironment inputs output))
            inputs
            intermediate
            (fun index bounded => by
              rw [prependEnvironment_shift]
              rfl)
            (fun index bounded => by
              rw [Nat.zero_add]
              exact prependEnvironment_get
                intermediate
                (graphEnvironment inputs output)
                bounded)).mpr
          innerEvaluation

/-! ## Finite execution runs for primitive recursion -/

/-- Append one value at the end of a length-indexed vector. -/
def NatVector.snoc {length : Nat} :
    NatVector length -> Nat -> NatVector (Nat.succ length)
  | NatVector.nil, value => NatVector.cons value NatVector.nil
  | NatVector.cons head tail, value =>
      NatVector.cons head (tail.snoc value)

/-- Appending preserves every prior vector entry. -/
theorem NatVector.get_snoc_of_lt
    {length index : Nat}
    (values : NatVector length)
    (value : Nat)
    (bounded : index < length) :
    (values.snoc value).get index (Nat.lt_trans bounded (Nat.lt_succ_self length)) =
      values.get index bounded := by
  induction values generalizing index with
  | nil => exact (Nat.not_lt_zero index bounded).elim
  | cons head tail inductionHypothesis =>
      cases index with
      | zero => rfl
      | succ index =>
          exact inductionHypothesis
            value
            (Nat.lt_of_succ_lt_succ bounded)

/-- The new final vector entry is the appended value. -/
theorem NatVector.get_snoc_last
    {length : Nat}
    (values : NatVector length)
    (value : Nat) :
    (values.snoc value).get length (Nat.lt_succ_self length) = value := by
  induction values with
  | nil => rfl
  | cons head tail inductionHypothesis => exact inductionHypothesis

/-- Forget the length index and retain the entries in order. -/
def NatVector.toList {length : Nat} : NatVector length -> List Nat
  | NatVector.nil => []
  | NatVector.cons head tail => head :: tail.toList

/-- The forgotten list has the indexed vector length. -/
theorem NatVector.toList_length
    {length : Nat}
    (values : NatVector length) :
    values.toList.length = length := by
  induction values with
  | nil => rfl
  | cons head tail inductionHypothesis =>
      change Nat.succ tail.toList.length = Nat.succ _
      rw [inductionHypothesis]

/-- List lookup agrees with proof-indexed vector lookup. -/
theorem NatVector.toList_get
    {length index : Nat}
    (values : NatVector length)
    (bounded : index < length) :
    values.toList.get
        ⟨index, values.toList_length ▸ bounded⟩ =
      values.get index bounded := by
  induction values generalizing index with
  | nil => exact (Nat.not_lt_zero index bounded).elim
  | cons head tail inductionHypothesis =>
      cases index with
      | zero => rfl
      | succ index =>
          exact inductionHypothesis (Nat.lt_of_succ_lt_succ bounded)

/-- Numeric beta component with its two sequence parameters kept separate. -/
def betaComponent (dividend coefficient index : Nat) : Nat :=
  dividend % ((index + 1) * coefficient + 1)

/-- `unbeta` supplies two components coding every entry of a finite vector. -/
theorem betaComponent_unbeta_vector
    {length index : Nat}
    (values : NatVector length)
    (bounded : index < length) :
    betaComponent
        (Nat.unbeta values.toList).unpair.1
        (Nat.unbeta values.toList).unpair.2
        index =
      values.get index bounded := by
  have betaLookup :=
    Nat.beta_unbeta_coe
      values.toList
      ⟨index, values.toList_length ▸ bounded⟩
  rw [NatVector.toList_get values bounded] at betaLookup
  exact betaLookup

/-- Complete finite run certified by a primitive-recursion execution. -/
structure PrimitiveRecursionRun
    {parameterArity : Nat}
    (base : PRFunction parameterArity)
    (step : PRFunction (Nat.succ (Nat.succ parameterArity)))
    (parameters : NatVector parameterArity)
    (counter output : Nat) where
  values : NatVector (Nat.succ counter)
  baseEvaluation :
    PRFunction.Evaluates base parameters
      (values.get 0 (Nat.zero_lt_succ counter))
  stepEvaluation :
    (index : Nat) ->
      (bounded : index < counter) ->
        PRFunction.Evaluates step
          (NatVector.cons index
            (NatVector.cons
              (values.get index
                (Nat.lt_trans bounded (Nat.lt_succ_self counter)))
              parameters))
          (values.get (Nat.succ index) (Nat.succ_lt_succ bounded))
  finalValue :
    values.get counter (Nat.lt_succ_self counter) = output

/-- Every positive primitive-recursion evaluation yields its complete run. -/
def PrimitiveRecursionRun.ofEvaluation
    {parameterArity : Nat}
    {base : PRFunction parameterArity}
    {step : PRFunction (Nat.succ (Nat.succ parameterArity))}
    {parameters : NatVector parameterArity}
    {counter output : Nat}
    (evaluation :
      PRFunction.Evaluates
        (PRFunction.primitiveRecursion base step)
        (NatVector.cons counter parameters)
        output) :
    PrimitiveRecursionRun base step parameters counter output :=
  match evaluation with
  | PRFunction.Evaluates.primitiveZero baseEvaluation =>
      { values := NatVector.cons output NatVector.nil
        baseEvaluation := baseEvaluation
        stepEvaluation := by
          intro index impossible
          exact (Nat.not_lt_zero index impossible).elim
        finalValue := rfl }
  | @PRFunction.Evaluates.primitiveSucc _ _ _ counter previous output
      parameters previousEvaluation stepEvaluation =>
      let previousRun :=
        PrimitiveRecursionRun.ofEvaluation previousEvaluation
      { values := previousRun.values.snoc output
        baseEvaluation := by
          rw [NatVector.get_snoc_of_lt]
          exact previousRun.baseEvaluation
        stepEvaluation := by
          intro index bounded
          have boundedOrFinal : index < counter ∨ index = counter :=
            Nat.lt_or_eq_of_le (Nat.le_of_lt_succ bounded)
          cases boundedOrFinal with
          | inl earlier =>
              have oldStep := previousRun.stepEvaluation index earlier
              rw [NatVector.get_snoc_of_lt,
                NatVector.get_snoc_of_lt]
              exact oldStep
          | inr finalIndex =>
              cases finalIndex
              rw [NatVector.get_snoc_of_lt,
                NatVector.get_snoc_last,
                previousRun.finalValue]
              exact stepEvaluation
        finalValue := NatVector.get_snoc_last previousRun.values output }

/-! ## Semantic correctness of primitive recursion -/

/-- Values of the parameter variables in the primitive-recursion base body. -/
theorem primitiveBaseParameters_evaluate
    {parameterArity : Nat}
    (topEnvironment : Environment)
    (parameters : NatVector parameterArity)
    (baseValue : Nat)
    (parameterValues :
      (index : Nat) ->
        (bounded : index < parameterArity) ->
          topEnvironment (4 + index) = parameters.get index bounded)
    (index : Nat)
    (bounded : index < parameterArity) :
    ((primitiveBaseParameters parameterArity).getD index).evaluate
        (pushEnvironment topEnvironment baseValue) =
      parameters.get index bounded := by
  rw [RawTermVector.variables_evaluate_get 5 parameterArity]
  change topEnvironment (4 + index) = parameters.get index bounded
  exact parameterValues index bounded

/-- Values of the parameter variables in a primitive-recursion step body. -/
theorem primitiveStepParameters_evaluate
    {parameterArity : Nat}
    (topEnvironment : Environment)
    (parameters : NatVector parameterArity)
    (counterValue previous next : Nat)
    (parameterValues :
      (index : Nat) ->
        (bounded : index < parameterArity) ->
          topEnvironment (4 + index) = parameters.get index bounded)
    (index : Nat)
    (bounded : index < parameterArity) :
    ((RawTermVector.variables 7 parameterArity).getD index).evaluate
        (prependEnvironment
          (NatVector.cons previous
            (NatVector.cons next NatVector.nil))
          (pushEnvironment topEnvironment counterValue)) =
      parameters.get index bounded := by
  rw [RawTermVector.variables_evaluate_get 7 parameterArity]
  change topEnvironment (4 + index) = parameters.get index bounded
  exact parameterValues index bounded

/-- The arithmetic beta construction makes primitive recursion representable. -/
theorem primitiveRecursionGraph_represents
    {parameterArity : Nat}
    {baseProgram : PRFunction parameterArity}
    {stepProgram : PRFunction (Nat.succ (Nat.succ parameterArity))}
    (baseGraph : ArithmeticGraph parameterArity)
    (stepGraph : ArithmeticGraph (Nat.succ (Nat.succ parameterArity)))
    (baseRepresents : baseGraph.Represents baseProgram)
    (stepRepresents : stepGraph.Represents stepProgram) :
    (primitiveRecursionGraph baseGraph stepGraph).Represents
      (PRFunction.primitiveRecursion baseProgram stepProgram) := by
  intro inputs output
  cases inputs with
  | cons counter parameters =>
      let baseCore := RawFormula.conj
        (betaValueFormula
          (RawTerm.bvar 1)
          (RawTerm.bvar 2)
          RawTerm.zero
          (RawTerm.bvar 0))
        (baseGraph.apply
          (RawTerm.bvar 0)
          (primitiveBaseParameters parameterArity))
      let baseClause := RawFormula.ex baseCore
      let transitionCore := RawFormula.conj
        (betaValueFormula
          (RawTerm.bvar 3)
          (RawTerm.bvar 4)
          (RawTerm.bvar 2)
          (RawTerm.bvar 0))
        (RawFormula.conj
          (betaValueFormula
            (RawTerm.bvar 3)
            (RawTerm.bvar 4)
            (RawTerm.succ (RawTerm.bvar 2))
            (RawTerm.bvar 1))
          (stepGraph.apply
            (RawTerm.bvar 1)
            (primitiveStepInputs parameterArity)))
      let transitionClause := RawFormula.all
        (RawFormula.impl
          (lessThanFormula (RawTerm.bvar 0) (RawTerm.bvar 4))
          (transitionCore.existsMany 2))
      let outputClause := betaValueFormula
        (RawTerm.bvar 0)
        (RawTerm.bvar 1)
        (RawTerm.bvar 3)
        (RawTerm.bvar 2)
      let body := RawFormula.conj baseClause
        (RawFormula.conj transitionClause outputClause)
      change
        (body.existsMany 2).Holds
            (graphEnvironment
              (NatVector.cons counter parameters)
              output) ↔
          PRFunction.Evaluates
            (PRFunction.primitiveRecursion baseProgram stepProgram)
            (NatVector.cons counter parameters)
            output
      rw [RawFormula.existsMany_holds]
      constructor
      · intro witness
        cases witness with
        | intro sequenceParameters bodyHolds =>
            cases sequenceParameters with
            | cons dividend sequenceTail =>
                cases sequenceTail with
                | cons coefficient emptyTail =>
                    cases emptyTail
                    let originalEnvironment :=
                      graphEnvironment
                        (NatVector.cons counter parameters)
                        output
                    let topEnvironment :=
                      prependEnvironment
                        (NatVector.cons dividend
                          (NatVector.cons coefficient NatVector.nil))
                        originalEnvironment
                    have topParameterValues :
                        (index : Nat) ->
                          (bounded : index < parameterArity) ->
                            topEnvironment (4 + index) =
                              parameters.get index bounded := by
                      intro index bounded
                      rfl
                    have baseHolds : baseClause.Holds topEnvironment :=
                      bodyHolds.1
                    cases baseHolds with
                    | intro baseValue baseCoreHolds =>
                        let baseEnvironment :=
                          pushEnvironment topEnvironment baseValue
                        have baseBeta :
                            baseValue =
                              betaComponent dividend coefficient 0 := by
                          apply (betaValueFormula_holds
                            (RawTerm.bvar 1)
                            (RawTerm.bvar 2)
                            RawTerm.zero
                            (RawTerm.bvar 0)
                            baseEnvironment).mp
                          exact baseCoreHolds.1
                        have baseExecutionAtWitness :
                            PRFunction.Evaluates
                              baseProgram parameters baseValue := by
                          apply (baseRepresents parameters baseValue).mp
                          apply (baseGraph.apply_holds_of_values
                            (RawTerm.bvar 0)
                            (primitiveBaseParameters parameterArity)
                            baseEnvironment
                            parameters
                            baseValue
                            rfl
                            (primitiveBaseParameters_evaluate
                              topEnvironment
                              parameters
                              baseValue
                              topParameterValues)).mp
                          exact baseCoreHolds.2
                        have baseExecution :
                            PRFunction.Evaluates
                              baseProgram parameters
                                (betaComponent dividend coefficient 0) := by
                          rw [← baseBeta]
                          exact baseExecutionAtWitness
                        have transitionHolds :
                            transitionClause.Holds topEnvironment :=
                          bodyHolds.2.1
                        have stepExecution :
                            (index : Nat) ->
                              index < counter ->
                                PRFunction.Evaluates stepProgram
                                  (NatVector.cons index
                                    (NatVector.cons
                                      (betaComponent
                                        dividend coefficient index)
                                      parameters))
                                  (betaComponent
                                    dividend coefficient (Nat.succ index)) := by
                          intro index bounded
                          let indexEnvironment :=
                            pushEnvironment topEnvironment index
                          have conditionHolds :
                              (lessThanFormula
                                (RawTerm.bvar 0)
                                (RawTerm.bvar 4)).Holds indexEnvironment := by
                            apply (lessThanFormula_holds
                              (RawTerm.bvar 0)
                              (RawTerm.bvar 4)
                              indexEnvironment).mpr
                            exact bounded
                          have transitionExists :=
                            transitionHolds index conditionHolds
                          rw [RawFormula.existsMany_holds] at transitionExists
                          cases transitionExists with
                          | intro adjacent transitionCoreHolds =>
                              cases adjacent with
                              | cons previous adjacentTail =>
                                  cases adjacentTail with
                                  | cons next emptyAdjacent =>
                                      cases emptyAdjacent
                                      let stepEnvironment :=
                                        prependEnvironment
                                          (NatVector.cons previous
                                            (NatVector.cons next NatVector.nil))
                                          indexEnvironment
                                      have previousBeta :
                                          previous =
                                            betaComponent
                                              dividend coefficient index := by
                                        apply (betaValueFormula_holds
                                          (RawTerm.bvar 3)
                                          (RawTerm.bvar 4)
                                          (RawTerm.bvar 2)
                                          (RawTerm.bvar 0)
                                          stepEnvironment).mp
                                        exact transitionCoreHolds.1
                                      have nextBeta :
                                          next =
                                            betaComponent
                                              dividend coefficient
                                              (Nat.succ index) := by
                                        have betaSemantics :=
                                          (betaValueFormula_holds
                                            (RawTerm.bvar 3)
                                            (RawTerm.bvar 4)
                                            (RawTerm.succ (RawTerm.bvar 2))
                                            (RawTerm.bvar 1)
                                            stepEnvironment).mp
                                            transitionCoreHolds.2.1
                                        exact betaSemantics
                                      have stepAtWitness :
                                          PRFunction.Evaluates stepProgram
                                            (NatVector.cons index
                                              (NatVector.cons previous parameters))
                                            next := by
                                        apply (stepRepresents
                                          (NatVector.cons index
                                            (NatVector.cons previous parameters))
                                          next).mp
                                        apply (stepGraph.apply_holds_of_values
                                          (RawTerm.bvar 1)
                                          (primitiveStepInputs parameterArity)
                                          stepEnvironment
                                          (NatVector.cons index
                                            (NatVector.cons previous parameters))
                                          next
                                          rfl
                                          ?_).mp
                                        · exact transitionCoreHolds.2.2
                                        · intro inputIndex inputBounded
                                          cases inputIndex with
                                          | zero => rfl
                                          | succ inputIndex =>
                                              cases inputIndex with
                                              | zero => rfl
                                              | succ parameterIndex =>
                                                  exact
                                                    primitiveStepParameters_evaluate
                                                      topEnvironment
                                                      parameters
                                                      index
                                                      previous
                                                      next
                                                      topParameterValues
                                                      parameterIndex
                                                      (Nat.lt_of_succ_lt_succ
                                                        (Nat.lt_of_succ_lt_succ
                                                          inputBounded))
                                      rw [← previousBeta, ← nextBeta]
                                      exact stepAtWitness
                        have buildExecution :
                            (index : Nat) ->
                              index <= counter ->
                                PRFunction.Evaluates
                                  (PRFunction.primitiveRecursion
                                    baseProgram stepProgram)
                                  (NatVector.cons index parameters)
                                  (betaComponent
                                    dividend coefficient index) := by
                          intro index within
                          induction index with
                          | zero =>
                              exact PRFunction.Evaluates.primitiveZero
                                baseExecution
                          | succ index inductionHypothesis =>
                              exact PRFunction.Evaluates.primitiveSucc
                                (inductionHypothesis
                                  (Nat.le_trans
                                    (Nat.le_succ index)
                                    within))
                                (stepExecution index
                                  (Nat.lt_of_succ_le within))
                        have outputBeta :
                            output =
                              betaComponent
                                dividend coefficient counter := by
                          apply (betaValueFormula_holds
                            (RawTerm.bvar 0)
                            (RawTerm.bvar 1)
                            (RawTerm.bvar 3)
                            (RawTerm.bvar 2)
                            topEnvironment).mp
                          exact bodyHolds.2.2
                        rw [outputBeta]
                        exact buildExecution counter (Nat.le_refl counter)
      · intro evaluation
        let run := PrimitiveRecursionRun.ofEvaluation evaluation
        let encoded := Nat.unbeta run.values.toList
        let dividend := encoded.unpair.1
        let coefficient := encoded.unpair.2
        refine Exists.intro
          (NatVector.cons dividend
            (NatVector.cons coefficient NatVector.nil)) ?_
        let originalEnvironment :=
          graphEnvironment
            (NatVector.cons counter parameters)
            output
        let topEnvironment :=
          prependEnvironment
            (NatVector.cons dividend
              (NatVector.cons coefficient NatVector.nil))
            originalEnvironment
        have topParameterValues :
            (index : Nat) ->
              (bounded : index < parameterArity) ->
                topEnvironment (4 + index) =
                  parameters.get index bounded := by
          intro index bounded
          rfl
        constructor
        · let baseValue :=
            run.values.get 0 (Nat.zero_lt_succ counter)
          refine Exists.intro baseValue ?_
          let baseEnvironment := pushEnvironment topEnvironment baseValue
          constructor
          · apply (betaValueFormula_holds
              (RawTerm.bvar 1)
              (RawTerm.bvar 2)
              RawTerm.zero
              (RawTerm.bvar 0)
              baseEnvironment).mpr
            exact (betaComponent_unbeta_vector
              run.values
              (Nat.zero_lt_succ counter)).symm
          · apply (baseGraph.apply_holds_of_values
              (RawTerm.bvar 0)
              (primitiveBaseParameters parameterArity)
              baseEnvironment
              parameters
              baseValue
              rfl
              (primitiveBaseParameters_evaluate
                topEnvironment
                parameters
                baseValue
                topParameterValues)).mpr
            exact (baseRepresents parameters baseValue).mpr
              run.baseEvaluation
        · constructor
          · intro index
            let indexEnvironment := pushEnvironment topEnvironment index
            intro conditionHolds
            have bounded : index < counter :=
              (lessThanFormula_holds
                (RawTerm.bvar 0)
                (RawTerm.bvar 4)
                indexEnvironment).mp conditionHolds
            let previous :=
              run.values.get index
                (Nat.lt_trans bounded (Nat.lt_succ_self counter))
            let next :=
              run.values.get (Nat.succ index)
                (Nat.succ_lt_succ bounded)
            rw [RawFormula.existsMany_holds]
            refine Exists.intro
              (NatVector.cons previous
                (NatVector.cons next NatVector.nil)) ?_
            let stepEnvironment :=
              prependEnvironment
                (NatVector.cons previous
                  (NatVector.cons next NatVector.nil))
                indexEnvironment
            constructor
            · apply (betaValueFormula_holds
                (RawTerm.bvar 3)
                (RawTerm.bvar 4)
                (RawTerm.bvar 2)
                (RawTerm.bvar 0)
                stepEnvironment).mpr
              exact (betaComponent_unbeta_vector
                run.values
                (Nat.lt_trans bounded
                  (Nat.lt_succ_self counter))).symm
            · constructor
              · apply (betaValueFormula_holds
                  (RawTerm.bvar 3)
                  (RawTerm.bvar 4)
                  (RawTerm.succ (RawTerm.bvar 2))
                  (RawTerm.bvar 1)
                  stepEnvironment).mpr
                exact (betaComponent_unbeta_vector
                  run.values
                  (Nat.succ_lt_succ bounded)).symm
              · apply (stepGraph.apply_holds_of_values
                  (RawTerm.bvar 1)
                  (primitiveStepInputs parameterArity)
                  stepEnvironment
                  (NatVector.cons index
                    (NatVector.cons previous parameters))
                  next
                  rfl
                  ?_).mpr
                · exact (stepRepresents
                    (NatVector.cons index
                      (NatVector.cons previous parameters))
                    next).mpr
                    (run.stepEvaluation index bounded)
                · intro inputIndex inputBounded
                  cases inputIndex with
                  | zero => rfl
                  | succ inputIndex =>
                      cases inputIndex with
                      | zero => rfl
                      | succ parameterIndex =>
                          exact primitiveStepParameters_evaluate
                            topEnvironment
                            parameters
                            index
                            previous
                            next
                            topParameterValues
                            parameterIndex
                            (Nat.lt_of_succ_lt_succ
                              (Nat.lt_of_succ_lt_succ inputBounded))
          · apply (betaValueFormula_holds
              (RawTerm.bvar 0)
              (RawTerm.bvar 1)
              (RawTerm.bvar 3)
              (RawTerm.bvar 2)
              topEnvironment).mpr
            rw [← run.finalValue]
            exact (betaComponent_unbeta_vector
              run.values
              (Nat.lt_succ_self counter)).symm

/-! ## Correctness of the complete compiler -/

mutual
  /-- Every compiled program graph is extensionally its execution relation. -/
  def PRFunction.graphFormula_represents :
      {arity : Nat} ->
        (program : PRFunction arity) ->
          program.graphFormula.Represents program
    | _arity, PRFunction.zero => by
        intro inputs output
        change (output = 0) ↔ PRFunction.Evaluates PRFunction.zero inputs output
        constructor
        · intro equality
          cases equality
          exact PRFunction.Evaluates.zero inputs
        · intro evaluation
          cases evaluation
          rfl
    | _arity, PRFunction.successor => by
        intro inputs output
        cases inputs with
        | cons value tail =>
            cases tail
            change
              (output = Nat.succ value) ↔
                PRFunction.Evaluates
                  PRFunction.successor
                  (NatVector.cons value NatVector.nil)
                  output
            constructor
            · intro equality
              cases equality
              exact PRFunction.Evaluates.successor value
            · intro evaluation
              cases evaluation
              rfl
    | _arity, PRFunction.projection arity index bounded => by
        intro inputs output
        change
          (output = inputs.get index bounded) ↔
            PRFunction.Evaluates
              (PRFunction.projection arity index bounded)
              inputs
              output
        constructor
        · intro equality
          cases equality
          exact PRFunction.Evaluates.projection index bounded inputs
        · intro evaluation
          cases evaluation
          rfl
    | _arity, PRFunction.composition outer inner =>
        compositionGraph_represents
          outer.graphFormula
          inner.graphFormulas
          outer.graphFormula_represents
          inner.graphFormulas_represent
    | _arity, PRFunction.primitiveRecursion base step =>
        primitiveRecursionGraph_represents
          base.graphFormula
          step.graphFormula
          base.graphFormula_represents
          step.graphFormula_represents

  /-- Every compiled vector graph represents pointwise vector execution. -/
  def PRFunctionVector.graphFormulas_represent :
      {inputArity outputArity : Nat} ->
        (programs : PRFunctionVector inputArity outputArity) ->
          programs.graphFormulas.Represents programs
    | _inputArity, _outputArity, PRFunctionVector.nil =>
        ArithmeticGraphVector.Represents.nil
    | _inputArity, _outputArity, PRFunctionVector.cons head tail =>
        ArithmeticGraphVector.Represents.cons
          head.graphFormula_represents
          tail.graphFormulas_represent
end

/-- Public biconditional specification of the arithmetic graph compiler. -/
theorem PRFunction.graphFormula_spec
    {arity : Nat}
    (program : PRFunction arity)
    (inputs : NatVector arity)
    (output : Nat) :
    program.graphFormula.Holds inputs output ↔
      PRFunction.Evaluates program inputs output :=
  program.graphFormula_represents inputs output

end BareArithmeticTarski
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.BareArithmeticTarski.compositionGraph
#print axioms Meta.BareArithmeticTarski.primitiveRecursionGraph
#print axioms Meta.BareArithmeticTarski.PRFunction.graphFormula
#print axioms Meta.BareArithmeticTarski.PRFunctionVector.graphFormulas
#print axioms Meta.BareArithmeticTarski.PRFunction.graphFormula_spec
/- AXIOM_AUDIT_END -/
