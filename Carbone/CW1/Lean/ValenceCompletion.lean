import Carbone.CW1.Lean.ActiveMaintenanceBoundary

/-!
# CW1-gamma: constructive neutral-valence completion

The heavy-atom skeletons of `CW0` contain two carbons and one oxygen but no
hydrogen atoms.  This module gives that representation a deliberately narrow
chemical semantics: ordinary neutral valences for H, C, N and O, integer bond
orders, and completion of the unused valences by implicit hydrogens.

Phosphorus and sulfur are rejected rather than assigned a misleading unique
valence.  Formal charge, radicals, aromatic bonds, stereochemistry, geometry,
energetics and kinetics remain outside this layer.  Consequently, the result
certifies molecular formula and constitutional connectivity in the declared
fragment; it does not certify a reaction between the two configurations.
-/

namespace Meta
namespace Carbone
namespace CW1

open CW0

namespace BondOrder

/-- Number of valence units consumed by an integer-order bond. -/
def valenceUnits : BondOrder -> Nat
  | .single => 1
  | .double => 2
  | .triple => 3

end BondOrder

namespace Element

/-!
Only the uncharged, closed-shell H/C/N/O fragment has a unique target in this
model.  Returning `none` for P and S is an executable boundary of validity.
-/
def neutralValence? : Element -> Option Nat
  | .hydrogen => some 1
  | .carbon => some 4
  | .nitrogen => some 3
  | .oxygen => some 2
  | .phosphorus => none
  | .sulfur => none

end Element

namespace BondRecord

def endpointContribution : Nat -> Nat -> Nat -> Nat
  | 0, 0, units => units
  | 0, _ + 1, _ => 0
  | _ + 1, 0, _ => 0
  | left + 1, right + 1, units => endpointContribution left right units

/-- Valence contributed by this bond at one atom index. -/
def valenceContributionAt (bond : BondRecord) (atomIndex : Nat) : Nat :=
  endpointContribution bond.left atomIndex
      (BondOrder.valenceUnits bond.order) +
    endpointContribution bond.right atomIndex
      (BondOrder.valenceUnits bond.order)

end BondRecord

namespace CarbonConfiguration

/-!
Constructive truncated deficit.  Unlike a proposition-valued comparison, this
recursion both decides admissibility and returns the unused valence.
-/
def valenceDeficit? : Nat -> Nat -> Option Nat
  | target, 0 => some target
  | 0, _ + 1 => none
  | target + 1, load + 1 => valenceDeficit? target load

def explicitHydrogenCompletion? : Nat -> Option Nat
  | 0 => none
  | 1 => some 0
  | _ + 2 => none

/-- Total explicit bond order incident at an atom index. -/
def bondValenceAt
    (configuration : CarbonConfiguration)
    (atomIndex : Nat) : Nat :=
  configuration.bonds.foldr
    (fun bond total => BondRecord.valenceContributionAt bond atomIndex + total)
    0

private def hydrogensToNeutralTarget?
    (configuration : CarbonConfiguration)
    (atomIndex : Nat)
    (element : Element) : Option Nat :=
  match Element.neutralValence? element with
  | none => none
  | some target =>
      valenceDeficit? target
        (CarbonConfiguration.bondValenceAt configuration atomIndex)

private def bondValenceProfileAux
    (configuration : CarbonConfiguration) :
    List Element -> Nat -> List Nat
  | [], _ => []
  | _ :: tail, atomIndex =>
      CarbonConfiguration.bondValenceAt configuration atomIndex ::
        bondValenceProfileAux configuration tail (atomIndex + 1)

/-- Explicit valence load, in the same order as `configuration.atoms`. -/
def bondValenceProfile (configuration : CarbonConfiguration) : List Nat :=
  bondValenceProfileAux configuration configuration.atoms 0

/--
Hydrogens needed at one explicit atom to reach the declared neutral valence.
An explicit hydrogen must already carry exactly one bond; the completion never
adds a second atom to repair an unbound explicit hydrogen.
-/
def implicitHydrogensAt
    (configuration : CarbonConfiguration)
    (atomIndex : Nat)
    (element : Element) : Option Nat := match element with
  | .hydrogen =>
      explicitHydrogenCompletion?
        (CarbonConfiguration.bondValenceAt configuration atomIndex)
  | .carbon => hydrogensToNeutralTarget? configuration atomIndex .carbon
  | .nitrogen => hydrogensToNeutralTarget? configuration atomIndex .nitrogen
  | .oxygen => hydrogensToNeutralTarget? configuration atomIndex .oxygen
  | .phosphorus => none
  | .sulfur => none

private def implicitHydrogenProfileAux
    (configuration : CarbonConfiguration) :
    List Element -> Nat -> Option (List Nat)
  | [], _ => some []
  | element :: tail, atomIndex =>
      match CarbonConfiguration.implicitHydrogensAt
          configuration atomIndex element,
          implicitHydrogenProfileAux configuration tail (atomIndex + 1) with
      | some atAtom, some atTail => some (atAtom :: atTail)
      | none, none => none
      | none, some _ => none
      | some _, none => none

/-!
The result is `none` exactly when this completion procedure rejects at least
one explicit atom: unsupported element, excessive valence, or malformed
explicit hydrogen.  No default value hides rejection.
-/
def implicitHydrogenProfile
    (configuration : CarbonConfiguration) : Option (List Nat) :=
  implicitHydrogenProfileAux configuration configuration.atoms 0

def sumImplicitHydrogens : List Nat -> Nat
  | [] => 0
  | count :: tail => count + sumImplicitHydrogens tail

def implicitHydrogenCount?
    (configuration : CarbonConfiguration) : Option Nat :=
  match CarbonConfiguration.implicitHydrogenProfile configuration with
  | none => none
  | some profile => some (sumImplicitHydrogens profile)

end CarbonConfiguration

namespace AtomInventory

/-- Add only the implicit hydrogens produced by the valence completion. -/
def addImplicitHydrogens
    (inventory : AtomInventory)
    (count : Nat) : AtomInventory where
  carbon := inventory.carbon
  hydrogen := inventory.hydrogen + count
  nitrogen := inventory.nitrogen
  oxygen := inventory.oxygen
  phosphorus := inventory.phosphorus
  sulfur := inventory.sulfur

end AtomInventory

namespace CarbonConfiguration

/-- Explicit inventory completed by the computed implicit hydrogens. -/
def neutralValenceInventory?
    (configuration : CarbonConfiguration) : Option AtomInventory :=
  match CarbonConfiguration.implicitHydrogenProfile configuration with
  | none => none
  | some profile =>
      some
        (AtomInventory.addImplicitHydrogens configuration.inventory
          (sumImplicitHydrogens profile))

end CarbonConfiguration

/-!
A positive certificate stores the exact profile returned by the algorithm.
The alignment field makes the one-entry-per-explicit-atom invariant directly
available to downstream constructions.
-/
structure NeutralValenceCertificate
    (configuration : CarbonConfiguration) where
  implicitHydrogens : List Nat
  profileComputed :
    CarbonConfiguration.implicitHydrogenProfile configuration =
      some implicitHydrogens
  profileAligned :
    implicitHydrogens.length = configuration.atoms.length

namespace NeutralValenceCertificate

def completedInventory
    {configuration : CarbonConfiguration}
    (certificate : NeutralValenceCertificate configuration) : AtomInventory :=
  AtomInventory.addImplicitHydrogens configuration.inventory
    (CarbonConfiguration.sumImplicitHydrogens certificate.implicitHydrogens)

theorem neutralValenceInventory?_eq
    {configuration : CarbonConfiguration}
    (certificate : NeutralValenceCertificate configuration) :
    CarbonConfiguration.neutralValenceInventory? configuration =
      some certificate.completedInventory := by
  unfold CarbonConfiguration.neutralValenceInventory? completedInventory
  rw [certificate.profileComputed]

end NeutralValenceCertificate

/-! ## Concrete C₂H₆O completion -/

def c2h6oInventory : AtomInventory where
  carbon := 2
  hydrogen := 6
  nitrogen := 0
  oxygen := 1
  phosphorus := 0
  sulfur := 0

/-- The C-C-O skeleton has explicit valence loads 1, 2 and 1. -/
theorem chainSkeleton_bondValenceProfile :
    CarbonConfiguration.bondValenceProfile chainSkeleton = [1, 2, 1] := rfl

/-- Completion gives CH₃-CH₂-OH: three, two and one implicit hydrogens. -/
theorem chainSkeleton_implicitHydrogenProfile :
    CarbonConfiguration.implicitHydrogenProfile chainSkeleton =
      some [3, 2, 1] := rfl

/-- The C-O-C skeleton has explicit valence loads 1, 1 and 2. -/
theorem bridgedSkeleton_bondValenceProfile :
    CarbonConfiguration.bondValenceProfile bridgedSkeleton = [1, 1, 2] := rfl

/-- Completion gives CH₃-O-CH₃: three, three and zero implicit hydrogens. -/
theorem bridgedSkeleton_implicitHydrogenProfile :
    CarbonConfiguration.implicitHydrogenProfile bridgedSkeleton =
      some [3, 3, 0] := rfl

def chainNeutralValenceCertificate :
    NeutralValenceCertificate chainSkeleton where
  implicitHydrogens := [3, 2, 1]
  profileComputed := chainSkeleton_implicitHydrogenProfile
  profileAligned := rfl

def bridgedNeutralValenceCertificate :
    NeutralValenceCertificate bridgedSkeleton where
  implicitHydrogens := [3, 3, 0]
  profileComputed := bridgedSkeleton_implicitHydrogenProfile
  profileAligned := rfl

theorem chainSkeleton_neutralValenceInventory :
    CarbonConfiguration.neutralValenceInventory? chainSkeleton =
      some c2h6oInventory := rfl

theorem bridgedSkeleton_neutralValenceInventory :
    CarbonConfiguration.neutralValenceInventory? bridgedSkeleton =
      some c2h6oInventory := rfl

/-! ## Positive connectedness of the two molecular graphs -/

/-- Undirected adjacency witnessed by one bond actually stored in the graph. -/
inductive StoredBondAdjacency
    (configuration : CarbonConfiguration) : Nat -> Nat -> Type where
  | forward (bond : BondRecord) :
      bond ∈ configuration.bonds ->
        StoredBondAdjacency configuration bond.left bond.right
  | backward (bond : BondRecord) :
      bond ∈ configuration.bonds ->
        StoredBondAdjacency configuration bond.right bond.left

/-- A finite path composed exclusively of stored bond adjacencies. -/
inductive StoredBondPath
    (configuration : CarbonConfiguration) : Nat -> Nat -> Type where
  | here (atomIndex : Nat) :
      StoredBondPath configuration atomIndex atomIndex
  | step {source middle target : Nat} :
      StoredBondAdjacency configuration source middle ->
      StoredBondPath configuration middle target ->
      StoredBondPath configuration source target

/-!
Every explicit atom must be reachable from one valid root.  Since adjacency is
undirected, this is a positive connectedness certificate for the whole stored
heavy-atom graph.
-/
structure ConnectedOrganizationCertificate
    (organization : CarbonOrganization) where
  root : Nat
  rootValid : root < organization.configuration.atoms.length
  pathFromRoot :
    (atomIndex : Nat) ->
      atomIndex < organization.configuration.atoms.length ->
        StoredBondPath organization.configuration root atomIndex

def chainBond_zero_one : StoredBondAdjacency chainSkeleton 0 1 :=
  StoredBondAdjacency.forward
    { left := 0, right := 1, order := .single }
    (List.Mem.head _)

def chainBond_one_two : StoredBondAdjacency chainSkeleton 1 2 :=
  StoredBondAdjacency.forward
    { left := 1, right := 2, order := .single }
    (List.Mem.tail _ (List.Mem.head _))

def bridgedBond_zero_two : StoredBondAdjacency bridgedSkeleton 0 2 :=
  StoredBondAdjacency.forward
    { left := 0, right := 2, order := .single }
    (List.Mem.head _)

def bridgedBond_two_one : StoredBondAdjacency bridgedSkeleton 2 1 :=
  StoredBondAdjacency.backward
    { left := 1, right := 2, order := .single }
    (List.Mem.tail _ (List.Mem.head _))

def chainConnectedCertificate :
    ConnectedOrganizationCertificate chainOrganization where
  root := 0
  rootValid := Nat.zero_lt_succ 2
  pathFromRoot := by
    intro atomIndex atomIndexValid
    cases atomIndex with
    | zero => exact StoredBondPath.here 0
    | succ atomIndex =>
        cases atomIndex with
        | zero =>
            exact
              StoredBondPath.step
                chainBond_zero_one
                (StoredBondPath.here 1)
        | succ atomIndex =>
            cases atomIndex with
            | zero =>
                exact
                  StoredBondPath.step
                    chainBond_zero_one
                    (StoredBondPath.step
                      chainBond_one_two
                      (StoredBondPath.here 2))
            | succ atomIndex =>
                have lowerBound :
                    3 <= Nat.succ (Nat.succ (Nat.succ atomIndex)) :=
                  Nat.succ_le_succ
                    (Nat.succ_le_succ
                      (Nat.succ_le_succ (Nat.zero_le atomIndex)))
                exact False.elim ((Nat.not_lt_of_ge lowerBound) atomIndexValid)

def bridgedConnectedCertificate :
    ConnectedOrganizationCertificate bridgedOrganization where
  root := 0
  rootValid := Nat.zero_lt_succ 2
  pathFromRoot := by
    intro atomIndex atomIndexValid
    cases atomIndex with
    | zero => exact StoredBondPath.here 0
    | succ atomIndex =>
        cases atomIndex with
        | zero =>
            exact
              StoredBondPath.step
                bridgedBond_zero_two
                (StoredBondPath.step
                  bridgedBond_two_one
                  (StoredBondPath.here 1))
        | succ atomIndex =>
            cases atomIndex with
            | zero =>
                exact
                  StoredBondPath.step
                    bridgedBond_zero_two
                    (StoredBondPath.here 2)
            | succ atomIndex =>
                have lowerBound :
                    3 <= Nat.succ (Nat.succ (Nat.succ atomIndex)) :=
                  Nat.succ_le_succ
                    (Nat.succ_le_succ
                      (Nat.succ_le_succ (Nat.zero_le atomIndex)))
                exact False.elim ((Nat.not_lt_of_ge lowerBound) atomIndexValid)

/-!
This witness is intentionally structural.  It certifies two separated bond
graphs with one completed formula under the declared semantics.  It carries no
edge asserting a physically admissible conversion between those graphs.
-/
structure NeutralValenceConstitutionalIsomerWitness where
  left : CarbonOrganization
  right : CarbonOrganization
  formula : AtomInventory
  leftCertificate : NeutralValenceCertificate left.configuration
  rightCertificate : NeutralValenceCertificate right.configuration
  leftConnected : ConnectedOrganizationCertificate left
  rightConnected : ConnectedOrganizationCertificate right
  leftFormula :
    CarbonConfiguration.neutralValenceInventory? left.configuration =
      some formula
  rightFormula :
    CarbonConfiguration.neutralValenceInventory? right.configuration =
      some formula
  separated : left = right -> False

/--
Constructive witness for the C₂H₆O constitutional pair represented by the
C-C-O and C-O-C heavy-atom connectivities.
-/
def c2h6oConstitutionalIsomerWitness :
    NeutralValenceConstitutionalIsomerWitness where
  left := chainOrganization
  right := bridgedOrganization
  formula := c2h6oInventory
  leftCertificate := chainNeutralValenceCertificate
  rightCertificate := bridgedNeutralValenceCertificate
  leftConnected := chainConnectedCertificate
  rightConnected := bridgedConnectedCertificate
  leftFormula := chainSkeleton_neutralValenceInventory
  rightFormula := bridgedSkeleton_neutralValenceInventory
  separated := chainOrganization_ne_bridgedOrganization

theorem c2h6o_sameHeavyAtomProjection :
    project c2h6oConstitutionalIsomerWitness.left =
      project c2h6oConstitutionalIsomerWitness.right := rfl

end CW1
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CW1.BondOrder.valenceUnits
#print axioms Meta.Carbone.CW1.Element.neutralValence?
#print axioms Meta.Carbone.CW1.BondRecord.endpointContribution
#print axioms Meta.Carbone.CW1.CarbonConfiguration.valenceDeficit?
#print axioms Meta.Carbone.CW1.CarbonConfiguration.explicitHydrogenCompletion?
#print axioms Meta.Carbone.CW1.BondRecord.valenceContributionAt
#print axioms Meta.Carbone.CW1.CarbonConfiguration.bondValenceAt
#print axioms Meta.Carbone.CW1.CarbonConfiguration.implicitHydrogensAt
#print axioms Meta.Carbone.CW1.CarbonConfiguration.implicitHydrogenProfile
#print axioms Meta.Carbone.CW1.CarbonConfiguration.neutralValenceInventory?
#print axioms Meta.Carbone.CW1.NeutralValenceCertificate.neutralValenceInventory?_eq
#print axioms Meta.Carbone.CW1.chainSkeleton_bondValenceProfile
#print axioms Meta.Carbone.CW1.chainSkeleton_implicitHydrogenProfile
#print axioms Meta.Carbone.CW1.bridgedSkeleton_bondValenceProfile
#print axioms Meta.Carbone.CW1.bridgedSkeleton_implicitHydrogenProfile
#print axioms Meta.Carbone.CW1.chainSkeleton_neutralValenceInventory
#print axioms Meta.Carbone.CW1.bridgedSkeleton_neutralValenceInventory
#print axioms Meta.Carbone.CW1.chainConnectedCertificate
#print axioms Meta.Carbone.CW1.bridgedConnectedCertificate
#print axioms Meta.Carbone.CW1.c2h6oConstitutionalIsomerWitness
#print axioms Meta.Carbone.CW1.c2h6o_sameHeavyAtomProjection
/- AXIOM_AUDIT_END -/
