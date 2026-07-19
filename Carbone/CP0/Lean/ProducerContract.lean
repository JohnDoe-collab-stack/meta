import Carbone.CP0.Lean.EnvironmentImport

/-!
# CP0 intrinsic yield-producer contract

This file fixes the positive input surface and causal shape required of a
future CP0 yield producer.  It deliberately supplies no chemical rule and no
learned parameter.  In particular, there is no independent prediction or
successor field: the reported prediction is definitionally the execution of a
repair selected through the full gap--interaction--response chain.
-/

namespace Meta
namespace Carbone
namespace CP0
namespace ProducerContract

open EnvironmentImport

/-! ## Whitelisted intrinsic input -/

/--
The complete structural view authorized for a producer.

Every molecular field contains explicit fragments, atoms and bonds.  Dataset
identifiers, reaction identifiers, semantic hashes and row positions are not
representable in this type.
-/
structure IntrinsicInputView where
  amine : MolecularStructure
  acid : MolecularStructure
  amineAmount : ImportedAmount
  acidAmount : ImportedAmount
  auxiliaries : List ResolvedAuxiliary
  additionSteps : List AdditionStep
  condition : ImportedPhysicalCondition

/-- The only projection from a resolved CP0 organization into producer input. -/
def admissibleProjection
    (organization : InputOrganization) : IntrinsicInputView where
  amine := organization.amine
  acid := organization.acid
  amineAmount := organization.amineAmount
  acidAmount := organization.acidAmount
  auxiliaries := organization.auxiliaries
  additionSteps := organization.additionSteps
  condition := organization.condition

/-! ## Exact bounded output -/

/-- An exact rational percentage in the closed interval `[0, 100]`. -/
structure BoundedYield where
  numerator : Nat
  denominator : Nat
  denominatorPositive : 0 < denominator
  atMostHundred : numerator <= 100 * denominator

/-- A producer either returns an exact bounded value or explicitly abstains. -/
inductive YieldPrediction where
  | value (yield : BoundedYield)
  | abstain

/-- Construct a bounded percentage only when both checks are decidable truths. -/
def boundedYield? (numerator denominator : Nat) : Option BoundedYield :=
  if denominatorPositive : 0 < denominator then
    if atMostHundred : numerator <= 100 * denominator then
      some
        { numerator := numerator
          denominator := denominator
          denominatorPositive := denominatorPositive
          atMostHundred := atMostHundred }
    else
      none
  else
    none

/-! ## Finite response-and-repair chain -/

universe uGap uInteraction uResponse uRepair

/--
A future producer must instantiate this complete causal chain.

Each selected object carries a proof that it belongs to an explicit finite
candidate list.  `RepairOf` is indexed by the exact environmental response
from which it is obtained.  The only operation allowed to emit a prediction is
`executeRepair` at the end of that indexed chain.
-/
structure CoreYieldProducer where
  GapEvidence : IntrinsicInputView -> Type uGap
  Interaction :
    (source : IntrinsicInputView) -> GapEvidence source -> Type uInteraction
  EnvironmentalResponse :
    (source : IntrinsicInputView) ->
    (gap : GapEvidence source) ->
    Interaction source gap ->
    Type uResponse
  RepairOf :
    (source : IntrinsicInputView) ->
    (gap : GapEvidence source) ->
    (interaction : Interaction source gap) ->
    EnvironmentalResponse source gap interaction ->
    Type uRepair
  gapCandidates :
    (source : IntrinsicInputView) -> List (GapEvidence source)
  gapAt :
    (source : IntrinsicInputView) -> GapEvidence source
  gapAt_mem :
    (source : IntrinsicInputView) -> gapAt source ∈ gapCandidates source
  interactionCandidates :
    (source : IntrinsicInputView) ->
    (gap : GapEvidence source) ->
    List (Interaction source gap)
  interactionAt :
    (source : IntrinsicInputView) ->
    (gap : GapEvidence source) ->
    Interaction source gap
  interactionAt_mem :
    (source : IntrinsicInputView) ->
    (gap : GapEvidence source) ->
    interactionAt source gap ∈ interactionCandidates source gap
  responseCandidates :
    (source : IntrinsicInputView) ->
    (gap : GapEvidence source) ->
    (interaction : Interaction source gap) ->
    List (EnvironmentalResponse source gap interaction)
  responseAt :
    (source : IntrinsicInputView) ->
    (gap : GapEvidence source) ->
    (interaction : Interaction source gap) ->
    EnvironmentalResponse source gap interaction
  responseAt_mem :
    (source : IntrinsicInputView) ->
    (gap : GapEvidence source) ->
    (interaction : Interaction source gap) ->
    responseAt source gap interaction ∈
      responseCandidates source gap interaction
  repairCandidates :
    (source : IntrinsicInputView) ->
    (gap : GapEvidence source) ->
    (interaction : Interaction source gap) ->
    (response : EnvironmentalResponse source gap interaction) ->
    List (RepairOf source gap interaction response)
  repairAt :
    (source : IntrinsicInputView) ->
    (gap : GapEvidence source) ->
    (interaction : Interaction source gap) ->
    (response : EnvironmentalResponse source gap interaction) ->
    RepairOf source gap interaction response
  repairAt_mem :
    (source : IntrinsicInputView) ->
    (gap : GapEvidence source) ->
    (interaction : Interaction source gap) ->
    (response : EnvironmentalResponse source gap interaction) ->
    repairAt source gap interaction response ∈
      repairCandidates source gap interaction response
  executeRepair :
    (source : IntrinsicInputView) ->
    (gap : GapEvidence source) ->
    (interaction : Interaction source gap) ->
    (response : EnvironmentalResponse source gap interaction) ->
    RepairOf source gap interaction response ->
    YieldPrediction

/-!
The trace records one complete proof-relevant evaluation.  Its memberships
make the finiteness obligations visible at every stage.
-/
structure CausalTrace
    (producer : CoreYieldProducer)
    (source : IntrinsicInputView) where
  gap : producer.GapEvidence source
  gapSelected : gap ∈ producer.gapCandidates source
  interaction : producer.Interaction source gap
  interactionSelected :
    interaction ∈ producer.interactionCandidates source gap
  response : producer.EnvironmentalResponse source gap interaction
  responseSelected :
    response ∈ producer.responseCandidates source gap interaction
  repair : producer.RepairOf source gap interaction response
  repairSelected :
    repair ∈ producer.repairCandidates source gap interaction response
  prediction : YieldPrediction
  prediction_eq :
    prediction =
      producer.executeRepair source gap interaction response repair

/-- The canonical trace contains no choices beyond the producer's own chain. -/
def canonicalCausalTrace
    (producer : CoreYieldProducer)
    (source : IntrinsicInputView) : CausalTrace producer source :=
  let gap := producer.gapAt source
  let interaction := producer.interactionAt source gap
  let response := producer.responseAt source gap interaction
  let repair := producer.repairAt source gap interaction response
  { gap := gap
    gapSelected := producer.gapAt_mem source
    interaction := interaction
    interactionSelected := producer.interactionAt_mem source gap
    response := response
    responseSelected := producer.responseAt_mem source gap interaction
    repair := repair
    repairSelected := producer.repairAt_mem source gap interaction response
    prediction :=
      producer.executeRepair source gap interaction response repair
    prediction_eq := rfl }

/-- Execute a producer only through the admissible intrinsic projection. -/
def run
    (producer : CoreYieldProducer)
    (organization : InputOrganization) : YieldPrediction :=
  (canonicalCausalTrace producer (admissibleProjection organization)).prediction

/-- The reported value is definitionally the execution of the selected repair. -/
theorem run_eq_executeRepair
    (producer : CoreYieldProducer)
    (organization : InputOrganization) :
    let source := admissibleProjection organization
    let gap := producer.gapAt source
    let interaction := producer.interactionAt source gap
    let response := producer.responseAt source gap interaction
    let repair := producer.repairAt source gap interaction response
    run producer organization =
      producer.executeRepair source gap interaction response repair := by
  rfl

/-! ## Computed boundary and plumbing examples -/

def zeroPercent? : Option BoundedYield := boundedYield? 0 1

def hundredPercent? : Option BoundedYield := boundedYield? 100 1

def aboveHundredPercent? : Option BoundedYield := boundedYield? 101 1

def zeroDenominatorPercent? : Option BoundedYield := boundedYield? 0 0

theorem boundedYield_accepts_zero : zeroPercent?.isSome = true := by
  rfl

theorem boundedYield_accepts_hundred : hundredPercent?.isSome = true := by
  rfl

theorem boundedYield_rejects_above_hundred :
    aboveHundredPercent?.isSome = false := by
  rfl

theorem boundedYield_rejects_zero_denominator :
    zeroDenominatorPercent?.isSome = false := by
  rfl

def syntheticMolecularStructure : MolecularStructure where
  fragments :=
    [ { atoms := [neutralCarbonAtom]
        bonds := []
        parents := [0] } ]

def syntheticCondition : ImportedPhysicalCondition where
  temperature := { numerator := (25 : Int), denominator := 1 }
  temperatureUnit := .celsius
  temperatureControl := .dryAluminumPlate
  pressureControl := .ambient
  atmosphere := .air
  stirring := .stirBar
  reflux := false

def syntheticInputOrganization : InputOrganization where
  amine := syntheticMolecularStructure
  acid := syntheticMolecularStructure
  amineAmount := oneMillimoleImported
  acidAmount := oneMillimoleImported
  auxiliaries := []
  additionSteps := validAdditionSteps
  condition := syntheticCondition

def fiftyPercent : BoundedYield where
  numerator := 50
  denominator := 1
  denominatorPositive := by decide
  atMostHundred := by decide

/-- A plumbing-only producer used to compute the contract end to end. -/
def syntheticProducer : CoreYieldProducer where
  GapEvidence := fun _ => Unit
  Interaction := fun _ _ => Unit
  EnvironmentalResponse := fun _ _ _ => Unit
  RepairOf := fun _ _ _ _ => Unit
  gapCandidates := fun _ => [()]
  gapAt := fun _ => ()
  gapAt_mem := fun _ => List.Mem.head []
  interactionCandidates := fun _ _ => [()]
  interactionAt := fun _ _ => ()
  interactionAt_mem := fun _ _ => List.Mem.head []
  responseCandidates := fun _ _ _ => [()]
  responseAt := fun _ _ _ => ()
  responseAt_mem := fun _ _ _ => List.Mem.head []
  repairCandidates := fun _ _ _ _ => [()]
  repairAt := fun _ _ _ _ => ()
  repairAt_mem := fun _ _ _ _ => List.Mem.head []
  executeRepair := fun _ _ _ _ _ => .value fiftyPercent

theorem syntheticProducer_runs_through_repair :
    run syntheticProducer syntheticInputOrganization =
      YieldPrediction.value fiftyPercent := by
  rfl

end ProducerContract
end CP0
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CP0.ProducerContract.admissibleProjection
#print axioms Meta.Carbone.CP0.ProducerContract.boundedYield?
#print axioms Meta.Carbone.CP0.ProducerContract.CoreYieldProducer
#print axioms Meta.Carbone.CP0.ProducerContract.canonicalCausalTrace
#print axioms Meta.Carbone.CP0.ProducerContract.run
#print axioms Meta.Carbone.CP0.ProducerContract.run_eq_executeRepair
#print axioms Meta.Carbone.CP0.ProducerContract.boundedYield_accepts_zero
#print axioms Meta.Carbone.CP0.ProducerContract.boundedYield_accepts_hundred
#print axioms Meta.Carbone.CP0.ProducerContract.boundedYield_rejects_above_hundred
#print axioms Meta.Carbone.CP0.ProducerContract.boundedYield_rejects_zero_denominator
#print axioms Meta.Carbone.CP0.ProducerContract.syntheticProducer_runs_through_repair
/- AXIOM_AUDIT_END -/
