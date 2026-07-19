import Carbone.CP0.Lean.ImportedSpecies

/-!
# CP0 target-free environment import

This file defines the positive data boundary for the 94 semantic environments
of the AIChemEco corpus.  Dataset hashes are lookup keys only: successful
resolution erases them before constructing `InputOrganization`, so they cannot
become numerical or categorical features of a later producer.
-/

namespace Meta
namespace Carbone
namespace CP0

namespace EnvironmentImport

inductive InputGroup where
  | carboxylicAcid
  | additive
  | activationAgent
  | amine
  | base
  | solvent
deriving DecidableEq, Repr

def InputGroup.code : InputGroup -> Nat
  | .carboxylicAcid => 0
  | .additive => 1
  | .activationAgent => 2
  | .amine => 3
  | .base => 4
  | .solvent => 5

inductive ImportedAmountUnit where
  | millimole
  | microliter
deriving DecidableEq, Repr

structure ImportedPositiveRatio where
  numerator : Nat
  denominator : Nat
deriving DecidableEq, Repr

structure ImportedSignedRatio where
  numerator : Int
  denominator : Nat
deriving DecidableEq, Repr

structure ImportedAmount where
  value : ImportedPositiveRatio
  unit : ImportedAmountUnit
deriving DecidableEq, Repr

structure ImportedComponent where
  group : InputGroup
  speciesIndex : Nat
  role : InputRole
  amount : ImportedAmount
deriving DecidableEq, Repr

inductive AdditionDevice where
  | pipette
deriving DecidableEq, Repr

structure AdditionStep where
  group : InputGroup
  order : Nat
  delayHours : Option ImportedPositiveRatio
  device : AdditionDevice
deriving DecidableEq, Repr

inductive TemperatureControl where
  | dryAluminumPlate
deriving DecidableEq, Repr

inductive PressureControl where
  | ambient
deriving DecidableEq, Repr

inductive Atmosphere where
  | air
deriving DecidableEq, Repr

inductive StirringMethod where
  | stirBar
deriving DecidableEq, Repr

structure ImportedPhysicalCondition where
  temperature : ImportedSignedRatio
  temperatureUnit : TemperatureUnit
  temperatureControl : TemperatureControl
  pressureControl : PressureControl
  atmosphere : Atmosphere
  stirring : StirringMethod
  reflux : Bool
deriving DecidableEq, Repr

structure EnvironmentTemplate where
  semanticConditionSha256 : String
  canonicalContentSha256 : String
  amineAmount : ImportedAmount
  acidAmount : ImportedAmount
  auxiliaries : List ImportedComponent
  additionSteps : List AdditionStep
  condition : ImportedPhysicalCondition
deriving DecidableEq, Repr

def positiveRatioValid (value : ImportedPositiveRatio) : Bool :=
  (0 < value.numerator) && (0 < value.denominator)

def signedRatioValid (value : ImportedSignedRatio) : Bool :=
  0 < value.denominator

def amountValid (amount : ImportedAmount) : Bool :=
  positiveRatioValid amount.value

def auxiliaryRoleValid : InputRole -> Bool
  | .reactant => false
  | .reagent => true
  | .solvent => true

def componentValid (component : ImportedComponent) : Bool :=
  (component.speciesIndex < 194) &&
  auxiliaryRoleValid component.role &&
  amountValid component.amount

def additionStepValid (step : AdditionStep) : Bool :=
  (0 < step.order) &&
  match step.delayHours with
  | none => true
  | some delay => positiveRatioValid delay

def naturalsUnique : List Nat -> Bool
  | [] => true
  | value :: rest =>
      !(rest.contains value) && naturalsUnique rest

def additionGroups (steps : List AdditionStep) : List Nat :=
  steps.map fun step => step.group.code

def additionOrders (steps : List AdditionStep) : List Nat :=
  steps.map AdditionStep.order

def additionProtocolValid (steps : List AdditionStep) : Bool :=
  (steps.length == 6) &&
  steps.all additionStepValid &&
  naturalsUnique (additionGroups steps) &&
  naturalsUnique (additionOrders steps)

def physicalConditionValid (condition : ImportedPhysicalCondition) : Bool :=
  signedRatioValid condition.temperature

def environmentValid (environment : EnvironmentTemplate) : Bool :=
  !(environment.semanticConditionSha256.isEmpty) &&
  !(environment.canonicalContentSha256.isEmpty) &&
  amountValid environment.amineAmount &&
  amountValid environment.acidAmount &&
  environment.auxiliaries.all componentValid &&
  additionProtocolValid environment.additionSteps &&
  physicalConditionValid environment.condition

def allEnvironmentsValid (environments : List EnvironmentTemplate) : Bool :=
  environments.all environmentValid

def semanticHashes (environments : List EnvironmentTemplate) : List String :=
  environments.map EnvironmentTemplate.semanticConditionSha256

def contentHashes (environments : List EnvironmentTemplate) : List String :=
  environments.map EnvironmentTemplate.canonicalContentSha256

structure ValidatedEnvironmentImport where
  environments : List EnvironmentTemplate
  count94 : environments.length = 94
  allValid : allEnvironmentsValid environments = true
  semanticHashesUnique :
    CanonicalImport.stringsUnique (semanticHashes environments) = true
  contentHashesUnique :
    CanonicalImport.stringsUnique (contentHashes environments) = true

def allStringsIn (values allowed : List String) : Bool :=
  values.all fun value => allowed.contains value

structure ValidatedInputDomainImport where
  environments : List EnvironmentTemplate
  amineIdentityHashes : List String
  acidIdentityHashes : List String
  environmentCount94 : environments.length = 94
  amineCount70 : amineIdentityHashes.length = 70
  acidCount66 : acidIdentityHashes.length = 66
  allEnvironmentsValid :
    EnvironmentImport.allEnvironmentsValid environments = true
  environmentSemanticHashesUnique :
    CanonicalImport.stringsUnique (semanticHashes environments) = true
  environmentContentHashesUnique :
    CanonicalImport.stringsUnique (contentHashes environments) = true
  amineHashesUnique :
    CanonicalImport.stringsUnique amineIdentityHashes = true
  acidHashesUnique :
    CanonicalImport.stringsUnique acidIdentityHashes = true
  allAmineHashesImported :
    allStringsIn amineIdentityHashes
      (CanonicalImport.identityHashes CanonicalImport.importedSpecies) = true
  allAcidHashesImported :
    allStringsIn acidIdentityHashes
      (CanonicalImport.identityHashes CanonicalImport.importedSpecies) = true

/-! ## Hash-free resolved organization -/

structure MolecularStructure where
  fragments : List ImportedFragment
deriving DecidableEq, Repr

def toMolecularStructure
    (species : ImportedSpecies) : MolecularStructure where
  fragments := species.fragments

structure ResolvedAuxiliary where
  group : InputGroup
  species : MolecularStructure
  role : InputRole
  amount : ImportedAmount
deriving DecidableEq, Repr

structure InputOrganization where
  amine : MolecularStructure
  acid : MolecularStructure
  amineAmount : ImportedAmount
  acidAmount : ImportedAmount
  auxiliaries : List ResolvedAuxiliary
  additionSteps : List AdditionStep
  condition : ImportedPhysicalCondition
deriving DecidableEq, Repr

def speciesAtList? : List ImportedSpecies -> Nat -> Option ImportedSpecies
  | [], _ => none
  | species :: _, 0 => some species
  | _ :: rest, index + 1 => speciesAtList? rest index

def speciesAt? (index : Nat) : Option ImportedSpecies :=
  speciesAtList? CanonicalImport.importedSpecies index

def findSpecies? (identitySha256 : String) : Option ImportedSpecies :=
  CanonicalImport.importedSpecies.find? fun species =>
    species.identitySha256 == identitySha256

def findEnvironment?
    (environments : List EnvironmentTemplate)
    (semanticConditionSha256 : String) : Option EnvironmentTemplate :=
  environments.find? fun environment =>
    environment.semanticConditionSha256 == semanticConditionSha256

def resolveAuxiliariesReverse :
    List ImportedComponent -> List ResolvedAuxiliary ->
      Option (List ResolvedAuxiliary)
  | [], resolved => some resolved.reverse
  | component :: rest, resolved =>
      match speciesAt? component.speciesIndex with
      | some species =>
          resolveAuxiliariesReverse rest
            ({ group := component.group
               species := toMolecularStructure species
               role := component.role
               amount := component.amount } :: resolved)
      | none => none

def resolveAuxiliaries
    (components : List ImportedComponent) : Option (List ResolvedAuxiliary) :=
  resolveAuxiliariesReverse components []

def resolveInput?
    (environments : List EnvironmentTemplate)
    (amineIdentitySha256 acidIdentitySha256 semanticConditionSha256 : String) :
    Option InputOrganization :=
  match findSpecies? amineIdentitySha256 with
  | none => none
  | some amine =>
      match findSpecies? acidIdentitySha256 with
      | none => none
      | some acid =>
          match findEnvironment? environments semanticConditionSha256 with
          | none => none
          | some environment =>
              match resolveAuxiliaries environment.auxiliaries with
              | none => none
              | some auxiliaries =>
                  some
                    { amine := toMolecularStructure amine
                      acid := toMolecularStructure acid
                      amineAmount := environment.amineAmount
                      acidAmount := environment.acidAmount
                      auxiliaries := auxiliaries
                      additionSteps := environment.additionSteps
                      condition := environment.condition }

def resolveQualifiedInput?
    (environments : List EnvironmentTemplate)
    (amineIdentityHashes acidIdentityHashes : List String)
    (amineIdentitySha256 acidIdentitySha256 semanticConditionSha256 : String) :
    Option InputOrganization :=
  if amineIdentityHashes.contains amineIdentitySha256 then
    if acidIdentityHashes.contains acidIdentitySha256 then
      resolveInput? environments
        amineIdentitySha256 acidIdentitySha256 semanticConditionSha256
    else
      none
  else
    none

/-! ## Intrinsic numerical projection, with no dataset key -/

def countWhere {α : Type} (predicate : α -> Bool) : List α -> Nat
  | [] => 0
  | value :: rest =>
      (if predicate value then 1 else 0) + countWhere predicate rest

structure MolecularSummary where
  fragments : Nat
  atoms : Nat
  bonds : Nat
  carbonAtoms : Nat
  aromaticAtoms : Nat
  formallyChargedAtoms : Nat
  implicitHydrogens : Nat
deriving DecidableEq, Repr

def summarizeStructure (molecular : MolecularStructure) : MolecularSummary :=
  let atoms := molecular.fragments.flatMap ImportedFragment.atoms
  { fragments := molecular.fragments.length
    atoms := atoms.length
    bonds :=
      (molecular.fragments.map fun fragment => fragment.bonds.length).foldl
        Nat.add 0
    carbonAtoms :=
      countWhere (fun atom => decide (atom.element = .carbon)) atoms
    aromaticAtoms := countWhere Atom.aromatic atoms
    formallyChargedAtoms :=
      countWhere (fun atom => decide (atom.formalCharge ≠ 0)) atoms
    implicitHydrogens :=
      (atoms.map Atom.implicitHydrogens).foldl Nat.add 0 }

structure AuxiliaryProjection where
  group : InputGroup
  molecular : MolecularSummary
  role : InputRole
  amount : ImportedAmount
deriving DecidableEq, Repr

structure InputProjection where
  amine : MolecularSummary
  acid : MolecularSummary
  amineAmount : ImportedAmount
  acidAmount : ImportedAmount
  auxiliaries : List AuxiliaryProjection
  additionSteps : List AdditionStep
  condition : ImportedPhysicalCondition
deriving DecidableEq, Repr

def projectInput (organization : InputOrganization) : InputProjection where
  amine := summarizeStructure organization.amine
  acid := summarizeStructure organization.acid
  amineAmount := organization.amineAmount
  acidAmount := organization.acidAmount
  auxiliaries := organization.auxiliaries.map fun auxiliary =>
    { group := auxiliary.group
      molecular := summarizeStructure auxiliary.species
      role := auxiliary.role
      amount := auxiliary.amount }
  additionSteps := organization.additionSteps
  condition := organization.condition

/-! ## Computed positive and negative boundary examples -/

def oneMillimoleImported : ImportedAmount where
  value := { numerator := 1, denominator := 1 }
  unit := .millimole

def invalidZeroAmount : ImportedAmount where
  value := { numerator := 0, denominator := 1 }
  unit := .millimole

def validAdditionSteps : List AdditionStep :=
  [ { group := .carboxylicAcid, order := 1, delayHours := none, device := .pipette }
  , { group := .additive, order := 2, delayHours := none, device := .pipette }
  , { group := .activationAgent, order := 3, delayHours := none, device := .pipette }
  , { group := .amine, order := 4, delayHours := none, device := .pipette }
  , { group := .base, order := 5, delayHours := none, device := .pipette }
  , { group := .solvent, order := 6, delayHours := none, device := .pipette } ]

def duplicateAdditionSteps : List AdditionStep :=
  [ { group := .carboxylicAcid, order := 1, delayHours := none, device := .pipette }
  , { group := .additive, order := 1, delayHours := none, device := .pipette }
  , { group := .activationAgent, order := 3, delayHours := none, device := .pipette }
  , { group := .amine, order := 4, delayHours := none, device := .pipette }
  , { group := .base, order := 5, delayHours := none, device := .pipette }
  , { group := .solvent, order := 6, delayHours := none, device := .pipette } ]

theorem amountValid_accepts_oneMillimole :
    amountValid oneMillimoleImported = true := by
  rfl

theorem amountValid_rejects_zero : amountValid invalidZeroAmount = false := by
  rfl

theorem additionProtocolValid_accepts_complete :
    additionProtocolValid validAdditionSteps = true := by
  rfl

theorem additionProtocolValid_rejects_duplicateOrder :
    additionProtocolValid duplicateAdditionSteps = false := by
  rfl

end EnvironmentImport
end CP0
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CP0.EnvironmentImport.environmentValid
#print axioms Meta.Carbone.CP0.EnvironmentImport.ValidatedEnvironmentImport
#print axioms Meta.Carbone.CP0.EnvironmentImport.ValidatedInputDomainImport
#print axioms Meta.Carbone.CP0.EnvironmentImport.resolveInput?
#print axioms Meta.Carbone.CP0.EnvironmentImport.resolveQualifiedInput?
#print axioms Meta.Carbone.CP0.EnvironmentImport.projectInput
#print axioms Meta.Carbone.CP0.EnvironmentImport.amountValid_accepts_oneMillimole
#print axioms Meta.Carbone.CP0.EnvironmentImport.amountValid_rejects_zero
#print axioms Meta.Carbone.CP0.EnvironmentImport.additionProtocolValid_accepts_complete
#print axioms Meta.Carbone.CP0.EnvironmentImport.additionProtocolValid_rejects_duplicateOrder
/- AXIOM_AUDIT_END -/
