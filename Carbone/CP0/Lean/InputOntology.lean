import Carbone.CW1.Lean.ValenceCompletion

/-!
# CP0-ONTOLOGY-1: positive finite input language

This file closes only the structural gap exposed by `CP0-DATA-I0`. It adds
the observed elements, formal charges, aromatic and stereochemical labels,
connected molecular fragments, finite mixtures, roles, exact positive
quantities and physical-condition carriers.

It contains no yield, product, reaction identifier, empirical oracle or
chemical transformation. Aromatic bonds deliberately have no integer bond
order: a later Kekulé normalization must be an explicit total construction,
not a hidden convention.
-/

namespace Meta
namespace Carbone
namespace CP0

inductive Element where
  | hydrogen
  | boron
  | carbon
  | nitrogen
  | oxygen
  | fluorine
  | phosphorus
  | sulfur
  | chlorine
  | bromine
deriving DecidableEq, Repr

namespace Element

/-- Total embedding of the narrower CW0/CW1 element language. -/
def ofCW0 : CW0.Element -> Element
  | .hydrogen => .hydrogen
  | .carbon => .carbon
  | .nitrogen => .nitrogen
  | .oxygen => .oxygen
  | .phosphorus => .phosphorus
  | .sulfur => .sulfur

/-- Hydrogen is the only non-heavy element admitted by CP0. -/
def isHeavy : Element -> Bool
  | .hydrogen => false
  | .boron => true
  | .carbon => true
  | .nitrogen => true
  | .oxygen => true
  | .fluorine => true
  | .phosphorus => true
  | .sulfur => true
  | .chlorine => true
  | .bromine => true

end Element

inductive BondKind where
  | single
  | double
  | triple
  | aromatic
deriving DecidableEq, Repr

namespace BondKind

/-- Integer valence contribution, with explicit abstention on aromaticity. -/
def integerOrder? : BondKind -> Option Nat
  | .single => some 1
  | .double => some 2
  | .triple => some 3
  | .aromatic => none

end BondKind

inductive TetraStereo where
  | none
  | clockwise
  | counterclockwise
  | unspecified
deriving DecidableEq, Repr

inductive BondStereo where
  | none
  | cis
  | trans
  | unspecified
deriving DecidableEq, Repr

structure Atom where
  element : Element
  formalCharge : Int
  implicitHydrogens : Nat
  aromatic : Bool
  tetraStereo : TetraStereo
deriving DecidableEq, Repr

structure Bond where
  left : Nat
  right : Nat
  kind : BondKind
  stereo : BondStereo
deriving DecidableEq, Repr

structure MoleculeGraph where
  atoms : List Atom
  bonds : List Bond
deriving DecidableEq, Repr

namespace MoleculeGraph

def BondWellFormed (graph : MoleculeGraph) (bond : Bond) : Prop :=
  bond.left < graph.atoms.length ∧
  bond.right < graph.atoms.length ∧
  (bond.left = bond.right -> False)

def BondsWellFormed (graph : MoleculeGraph) : Prop :=
  (bond : Bond) -> bond ∈ graph.bonds -> graph.BondWellFormed bond

def SameUndirectedEndpoints (left right : Bond) : Prop :=
  (left.left = right.left ∧ left.right = right.right) ∨
  (left.left = right.right ∧ left.right = right.left)

/-- At most one stored bond may join one unordered endpoint pair. -/
def NoDuplicateBonds (graph : MoleculeGraph) : Prop :=
  (left right : Bond) ->
    left ∈ graph.bonds ->
    right ∈ graph.bonds ->
    SameUndirectedEndpoints left right ->
    left = right

def HasCarbon (graph : MoleculeGraph) : Prop :=
  ∃ atom, atom ∈ graph.atoms ∧ atom.element = .carbon

def Adjacent (graph : MoleculeGraph) (left right : Nat) : Prop :=
  ∃ bond,
    bond ∈ graph.bonds ∧
    ((bond.left = left ∧ bond.right = right) ∨
      (bond.left = right ∧ bond.right = left))

inductive Reachable (graph : MoleculeGraph) (start : Nat) : Nat -> Prop where
  | here : Reachable graph start start
  | step {middle target : Nat} :
      Reachable graph start middle ->
      graph.Adjacent middle target ->
      Reachable graph start target

/-- A nonempty graph whose every atom index is reachable from index zero. -/
def Connected (graph : MoleculeGraph) : Prop :=
  0 < graph.atoms.length ∧
  ∀ atomIndex : Nat,
    atomIndex < graph.atoms.length ->
    Reachable graph 0 atomIndex

end MoleculeGraph

/-!
`Molecule` is a positive certificate. A salt with several disconnected
fragments is not forced into this structure; `Species` represents it below as
a finite list of individually connected molecules.
-/
structure Molecule where
  graph : MoleculeGraph
  bondsWellFormed : graph.BondsWellFormed
  noDuplicateBonds : graph.NoDuplicateBonds
  connected : graph.Connected

/-! A possibly multifragment chemical species, such as a neutral salt. -/
structure Species where
  fragments : List Molecule
  nonempty : fragments = [] -> False
  hasCarbon :
    ∃ molecule,
      molecule ∈ fragments ∧ molecule.graph.HasCarbon

inductive InputRole where
  | reactant
  | reagent
  | solvent
deriving DecidableEq, Repr

structure PositiveRatio where
  numerator : Nat
  denominator : Nat
  numeratorPositive : 0 < numerator
  denominatorPositive : 0 < denominator

inductive AmountUnit where
  | mole
  | millimole
  | micromole
  | liter
  | milliliter
  | microliter
deriving DecidableEq, Repr

structure Amount where
  value : PositiveRatio
  unit : AmountUnit

structure MixtureComponent where
  species : Species
  role : InputRole
  amount : Amount

structure Mixture where
  components : List MixtureComponent
  nonempty : components = [] -> False

structure SignedRatio where
  numerator : Int
  denominator : Nat
  denominatorPositive : 0 < denominator

inductive TemperatureUnit where
  | celsius
  | kelvin
deriving DecidableEq, Repr

structure Temperature where
  value : SignedRatio
  unit : TemperatureUnit

inductive PressureUnit where
  | bar
  | atmosphere
  | pascal
deriving DecidableEq, Repr

structure Pressure where
  value : PositiveRatio
  unit : PressureUnit

inductive Stirring where
  | none
  | low
  | medium
  | high
  | revolutionsPerMinute (value : Nat)
deriving DecidableEq, Repr

structure Condition where
  temperature : Temperature
  pressure : Pressure
  stirring : Stirring
  reflux : Bool

structure Input where
  amine : Species
  acid : Species
  auxiliaries : Mixture
  condition : Condition

/-! ## Constructive structural witness -/

def neutralCarbonAtom : Atom where
  element := .carbon
  formalCharge := 0
  implicitHydrogens := 4
  aromatic := false
  tetraStereo := .none

def singletonCarbonGraph : MoleculeGraph where
  atoms := [neutralCarbonAtom]
  bonds := []

theorem singletonCarbonGraph_hasCarbon : singletonCarbonGraph.HasCarbon := by
  exact ⟨neutralCarbonAtom, List.Mem.head [], rfl⟩

theorem singletonCarbonGraph_bondsWellFormed :
    singletonCarbonGraph.BondsWellFormed := by
  intro bond membership
  nomatch membership

theorem singletonCarbonGraph_noDuplicateBonds :
    singletonCarbonGraph.NoDuplicateBonds := by
  intro left right leftMembership
  nomatch leftMembership

theorem singletonCarbonGraph_connected : singletonCarbonGraph.Connected := by
  constructor
  · exact Nat.zero_lt_succ 0
  · intro atomIndex atomIndexValid
    change atomIndex < 1 at atomIndexValid
    have atomIndexLeZero : atomIndex ≤ 0 := Nat.le_of_lt_succ atomIndexValid
    have atomIndexEqZero : atomIndex = 0 := Nat.eq_zero_of_le_zero atomIndexLeZero
    cases atomIndexEqZero
    exact MoleculeGraph.Reachable.here

def singletonCarbonMolecule : Molecule where
  graph := singletonCarbonGraph
  bondsWellFormed := singletonCarbonGraph_bondsWellFormed
  noDuplicateBonds := singletonCarbonGraph_noDuplicateBonds
  connected := singletonCarbonGraph_connected

def singletonCarbonSpecies : Species where
  fragments := [singletonCarbonMolecule]
  nonempty := by
    intro equality
    nomatch equality
  hasCarbon := by
    exact
      ⟨ singletonCarbonMolecule
      , List.Mem.head []
      , singletonCarbonGraph_hasCarbon ⟩

def oneMole : Amount where
  value :=
    { numerator := 1
      denominator := 1
      numeratorPositive := Nat.zero_lt_succ 0
      denominatorPositive := Nat.zero_lt_succ 0 }
  unit := .mole

def singletonCarbonReactant : MixtureComponent where
  species := singletonCarbonSpecies
  role := .reactant
  amount := oneMole

def singletonCarbonMixture : Mixture where
  components := [singletonCarbonReactant]
  nonempty := by
    intro equality
    nomatch equality

theorem singletonCarbonMolecule_hasCarbon :
    singletonCarbonMolecule.graph.HasCarbon :=
  singletonCarbonGraph_hasCarbon

end CP0
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CP0.Element.ofCW0
#print axioms Meta.Carbone.CP0.BondKind.integerOrder?
#print axioms Meta.Carbone.CP0.MoleculeGraph.BondWellFormed
#print axioms Meta.Carbone.CP0.MoleculeGraph.NoDuplicateBonds
#print axioms Meta.Carbone.CP0.MoleculeGraph.Connected
#print axioms Meta.Carbone.CP0.singletonCarbonGraph_connected
#print axioms Meta.Carbone.CP0.singletonCarbonMolecule
#print axioms Meta.Carbone.CP0.singletonCarbonSpecies
#print axioms Meta.Carbone.CP0.singletonCarbonMixture
#print axioms Meta.Carbone.CP0.singletonCarbonMolecule_hasCarbon
/- AXIOM_AUDIT_END -/
