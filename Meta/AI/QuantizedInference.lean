/-!
# Exact quantized inference kernel

The kernel uses mathematical integers together with executable Int8 and Int32
bounds.  A certified run proves that every parameter, activation, input and
accumulator remains in its prescribed machine range, so the calculation is
extensionally the required non-overflowing Int8/Int32 inference.
-/

namespace Meta
namespace ActiveSemanticClosure
namespace Quantized

def int8B (value : Int) : Bool :=
  decide ((-128 : Int) <= value ∧ value <= 127)

def int32B (value : Int) : Bool :=
  decide ((-(2 ^ 31) : Int) <= value ∧ value <= (2 ^ 31 : Int) - 1)

def vectorInt8B (values : List Int) : Bool := values.all int8B

def vectorInt32B (values : List Int) : Bool := values.all int32B

def matrixInt8B (matrix : List (List Int)) : Bool :=
  matrix.all vectorInt8B

def matrixShapeB
    (rows columns : Nat)
    (matrix : List (List Int)) : Bool :=
  decide (matrix.length = rows) &&
    matrix.all (fun row => decide (row.length = columns))

def dot : List Int -> List Int -> Int
  | [], _ => 0
  | left :: leftTail, right =>
      match right with
      | [] => 0
      | rightValue :: rightTail =>
          left * rightValue + dot leftTail rightTail

def affine : List (List Int) -> List Int -> List Int -> List Int
  | [], _, _ => []
  | row :: rows, bias, input =>
      match bias with
      | [] => []
      | offset :: offsets =>
          (dot row input + offset) :: affine rows offsets input

def roundMagnitudeTiesToEven (value shift : Nat) : Nat :=
  if shift = 0 then
    value
  else
    let divisor := 2 ^ shift
    let quotient := value / divisor
    let remainder := value % divisor
    if divisor < 2 * remainder then
      quotient + 1
    else if 2 * remainder < divisor then
      quotient
    else if quotient % 2 = 1 then
      quotient + 1
    else
      quotient

def intMagnitude : Int -> Nat
  | .ofNat value => value
  | .negSucc value => value + 1

def roundTiesToEven (value : Int) (shift : Nat) : Int :=
  let rounded := roundMagnitudeTiesToEven (intMagnitude value) shift
  if value < 0 then -(Int.ofNat rounded) else Int.ofNat rounded

theorem roundTiesToEven_signedExamples :
    roundTiesToEven 1 1 = 0 ∧
    roundTiesToEven 3 1 = 2 ∧
    roundTiesToEven 5 1 = 2 ∧
    roundTiesToEven 7 1 = 4 ∧
    roundTiesToEven (-1) 1 = 0 ∧
    roundTiesToEven (-3) 1 = -2 ∧
    roundTiesToEven (-5) 1 = -2 ∧
    roundTiesToEven (-7) 1 = -4 := by
  decide

def saturateInt8 (value : Int) : Int :=
  if value < -128 then -128 else if 127 < value then 127 else value

def quantizeActivation (shift : Nat) (value : Int) : Int :=
  saturateInt8 (roundTiesToEven value shift)

def relu (value : Int) : Int := if value < 0 then 0 else value

structure QuantizedHead where
  inputDim : Nat
  outputDim : Nat
  hiddenWeights : List (List Int)
  hiddenBias : List Int
  outputWeights : List (List Int)
  outputBias : List Int
  hiddenShift : Nat
  outputShift : Nat
  validClasses : List Nat
  deriving DecidableEq

def hiddenActivations
    (head : QuantizedHead)
    (input : List Int) : List Int :=
  (affine head.hiddenWeights head.hiddenBias input).map fun value =>
    relu (quantizeActivation head.hiddenShift value)

def rawOutputAccumulators
    (head : QuantizedHead)
    (input : List Int) : List Int :=
  affine head.outputWeights head.outputBias (hiddenActivations head input)

def maskLogits
    (validClasses : List Nat)
    (shift : Nat) : Nat -> List Int -> List Int
  | _, [] => []
  | index, value :: values =>
      (if validClasses.contains index then
          quantizeActivation shift value
        else
          -128) ::
        maskLogits validClasses shift (index + 1) values

def headLogits
    (head : QuantizedHead)
    (input : List Int) : List Int :=
  maskLogits head.validClasses head.outputShift 0
    (rawOutputAccumulators head input)

def canonicalArgmaxAux
    (bestIndex : Nat)
    (bestValue : Int)
    (nextIndex : Nat) : List Int -> Nat
  | [] => bestIndex
  | value :: values =>
      if bestValue < value then
        canonicalArgmaxAux nextIndex value (nextIndex + 1) values
      else
        canonicalArgmaxAux bestIndex bestValue (nextIndex + 1) values

def canonicalArgmax : List Int -> Nat
  | [] => 0
  | value :: values => canonicalArgmaxAux 0 value 1 values

def strictWinnerAuxB
    (winner : Nat)
    (winningValue : Int) : Nat -> List Int -> Bool
  | _, [] => true
  | index, value :: values =>
      (if index = winner then true else decide (value < winningValue)) &&
        strictWinnerAuxB winner winningValue (index + 1) values

def valueAt? : List Int -> Nat -> Option Int
  | [], _ => none
  | value :: _, 0 => some value
  | _ :: values, index + 1 => valueAt? values index

def strictWinnerB (logits : List Int) (winner : Nat) : Bool :=
  match valueAt? logits winner with
  | none => false
  | some winningValue => strictWinnerAuxB winner winningValue 0 logits

def quantizedHeadValidB (hiddenDim : Nat) (head : QuantizedHead) : Bool :=
  matrixShapeB hiddenDim head.inputDim head.hiddenWeights &&
    decide (head.hiddenBias.length = hiddenDim) &&
    matrixShapeB head.outputDim hiddenDim head.outputWeights &&
    decide (head.outputBias.length = head.outputDim) &&
    matrixInt8B head.hiddenWeights && vectorInt8B head.hiddenBias &&
    matrixInt8B head.outputWeights && vectorInt8B head.outputBias &&
    decide (head.hiddenShift <= 15) && decide (head.outputShift <= 15) &&
    head.validClasses.all (fun index => decide (index < head.outputDim))

inductive HeadKind where
  | gap
  | use
  | transport
  | query
  | repair
  deriving DecidableEq

structure QuantizedModel where
  gap : QuantizedHead
  use : QuantizedHead
  transport : QuantizedHead
  query : QuantizedHead
  repair : QuantizedHead
  deriving DecidableEq

structure QuantizedHeadSpec where
  inputDim : Nat
  outputDim : Nat
  validClasses : List Nat
  deriving DecidableEq

structure QuantizedArchitecture where
  hiddenDim : Nat
  headSpec : HeadKind -> QuantizedHeadSpec

def QuantizedModel.head
    (model : QuantizedModel) : HeadKind -> QuantizedHead
  | .gap => model.gap
  | .use => model.use
  | .transport => model.transport
  | .query => model.query
  | .repair => model.repair

def headConformsB
    (hiddenDim : Nat)
    (spec : QuantizedHeadSpec)
    (head : QuantizedHead) : Bool :=
  quantizedHeadValidB hiddenDim head &&
    decide (head.inputDim = spec.inputDim) &&
    decide (head.outputDim = spec.outputDim) &&
    decide (head.validClasses = spec.validClasses)

def architectureValidB
    (architecture : QuantizedArchitecture)
    (model : QuantizedModel) : Bool :=
  headConformsB architecture.hiddenDim (architecture.headSpec .gap) model.gap &&
    headConformsB architecture.hiddenDim (architecture.headSpec .use) model.use &&
    headConformsB architecture.hiddenDim
      (architecture.headSpec .transport) model.transport &&
    headConformsB architecture.hiddenDim (architecture.headSpec .query) model.query &&
    headConformsB architecture.hiddenDim (architecture.headSpec .repair) model.repair

structure CertifiedExample where
  head : HeadKind
  input : List Int
  expected : Nat
  deriving DecidableEq

structure CertifiedDecision where
  head : HeadKind
  predicted : Nat
  expected : Nat
  logits : List Int
  deriving DecidableEq

abbrev RawTrace := List CertifiedDecision

def runExample
    (model : QuantizedModel)
    (sample : CertifiedExample) : CertifiedDecision :=
  let logits := headLogits (model.head sample.head) sample.input
  { head := sample.head
    predicted := canonicalArgmax logits
    expected := sample.expected
    logits := logits }

def runModel
    (model : QuantizedModel)
    (inputs : List CertifiedExample) : RawTrace :=
  inputs.map (runExample model)

def exampleValidB
    (model : QuantizedModel)
    (sample : CertifiedExample) : Bool :=
  let head := model.head sample.head
  decide (sample.input.length = head.inputDim) &&
    vectorInt8B sample.input &&
    head.validClasses.contains sample.expected

def exampleAccumulatorsValidB
    (model : QuantizedModel)
    (sample : CertifiedExample) : Bool :=
  let head := model.head sample.head
  vectorInt32B (affine head.hiddenWeights head.hiddenBias sample.input) &&
    vectorInt8B (hiddenActivations head sample.input) &&
    vectorInt32B (rawOutputAccumulators head sample.input) &&
    vectorInt8B (headLogits head sample.input)

def examplesValidB
    (model : QuantizedModel)
    (inputs : List CertifiedExample) : Bool :=
  inputs.all (exampleValidB model)

def allAccumulatorsValidB
    (model : QuantizedModel)
    (inputs : List CertifiedExample) : Bool :=
  inputs.all (exampleAccumulatorsValidB model)

def traceZeroErrorB (trace : RawTrace) : Bool :=
  trace.all fun decision => decide (decision.predicted = decision.expected)

def traceStrictB (trace : RawTrace) : Bool :=
  trace.all fun decision => strictWinnerB decision.logits decision.predicted

def ValidTrace (trace : RawTrace) : Prop :=
  traceZeroErrorB trace = true ∧ traceStrictB trace = true

structure CertifiedBatch
    (model : QuantizedModel)
    (inputs : List CertifiedExample)
    (rawTrace : RawTrace) : Prop where
  inputsValid : examplesValidB model inputs = true
  accumulatorsValid : allAccumulatorsValidB model inputs = true
  run_eq : runModel model inputs = rawTrace
  traceValid : ValidTrace rawTrace
  nonempty : inputs = [] -> False

structure CertifiedBatchData (model : QuantizedModel) where
  inputs : List CertifiedExample
  rawTrace : RawTrace
  certificate : CertifiedBatch model inputs rawTrace

structure ValidCertifiedRun
    (architecture : QuantizedArchitecture)
    (model : QuantizedModel)
    (inputs : List CertifiedExample)
    (rawTrace : RawTrace) where
  architectureValid : architectureValidB architecture model = true
  batches : List (CertifiedBatchData model)
  inputs_eq : batches.flatMap (fun batch => batch.inputs) = inputs
  rawTrace_eq : batches.flatMap (fun batch => batch.rawTrace) = rawTrace
  nonempty : batches = [] -> False

end Quantized
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.Quantized.runModel
#print axioms Meta.ActiveSemanticClosure.Quantized.roundTiesToEven_signedExamples
#print axioms Meta.ActiveSemanticClosure.Quantized.ValidTrace
#print axioms Meta.ActiveSemanticClosure.Quantized.architectureValidB
#print axioms Meta.ActiveSemanticClosure.Quantized.CertifiedBatch
#print axioms Meta.ActiveSemanticClosure.Quantized.ValidCertifiedRun
/- AXIOM_AUDIT_END -/
