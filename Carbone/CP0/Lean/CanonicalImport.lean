import Carbone.CP0.Lean.InputOntology

/-!
# CP0 canonical input import

This file defines the target-free, decidable qualification boundary used to
import the 194 canonical input species exposed by `CP0-DATA-I0`.

An imported fragment carries an explicit parent vector.  Index zero is its
own root; every later atom must point to a strictly smaller adjacent index.
Consequently a successful check contains a finite spanning-tree witness and
does not rely on a graph-search oracle.  The check also enforces valid bond
endpoints and uniqueness of unordered bond endpoints.
-/

namespace Meta
namespace Carbone
namespace CP0

structure ImportedFragment where
  atoms : List Atom
  bonds : List Bond
  parents : List Nat
deriving DecidableEq, Repr

structure ImportedSpecies where
  identitySha256 : String
  canonicalGraphSha256 : String
  fragments : List ImportedFragment
deriving DecidableEq, Repr

namespace CanonicalImport

def sameUndirectedEndpoints (left right : Bond) : Bool :=
  ((left.left == right.left) && (left.right == right.right)) ||
  ((left.left == right.right) && (left.right == right.left))

def bondEndpointValid (atomCount : Nat) (bond : Bond) : Bool :=
  (bond.left < atomCount) &&
  (bond.right < atomCount) &&
  !(bond.left == bond.right)

def bondEndpointsValid (atomCount : Nat) (bonds : List Bond) : Bool :=
  bonds.all (bondEndpointValid atomCount)

def noDuplicateBondEndpoints : List Bond -> Bool
  | [] => true
  | bond :: rest =>
      !(rest.any (sameUndirectedEndpoints bond)) &&
      noDuplicateBondEndpoints rest

def adjacent (bonds : List Bond) (left right : Nat) : Bool :=
  bonds.any fun bond =>
    ((bond.left == left) && (bond.right == right)) ||
    ((bond.left == right) && (bond.right == left))

def parentEdgesValid (bonds : List Bond) : Nat -> List Nat -> Bool
  | _, [] => true
  | 0, parent :: rest =>
      (parent == 0) && parentEdgesValid bonds 1 rest
  | index, parent :: rest =>
      (parent < index) &&
      adjacent bonds parent index &&
      parentEdgesValid bonds (index + 1) rest

def fragmentHasCarbon (fragment : ImportedFragment) : Bool :=
  fragment.atoms.any fun atom => decide (atom.element = .carbon)

def fragmentValid (fragment : ImportedFragment) : Bool :=
  !(fragment.atoms.isEmpty) &&
  (fragment.parents.length == fragment.atoms.length) &&
  bondEndpointsValid fragment.atoms.length fragment.bonds &&
  noDuplicateBondEndpoints fragment.bonds &&
  parentEdgesValid fragment.bonds 0 fragment.parents

def speciesValid (species : ImportedSpecies) : Bool :=
  !(species.fragments.isEmpty) &&
  species.fragments.all fragmentValid &&
  species.fragments.any fragmentHasCarbon

def stringsUnique : List String -> Bool
  | [] => true
  | value :: rest =>
      !(rest.contains value) && stringsUnique rest

def allSpeciesValid (species : List ImportedSpecies) : Bool :=
  species.all speciesValid

def identityHashes (species : List ImportedSpecies) : List String :=
  species.map ImportedSpecies.identitySha256

def graphHashes (species : List ImportedSpecies) : List String :=
  species.map ImportedSpecies.canonicalGraphSha256

structure ValidatedImport where
  species : List ImportedSpecies
  count194 : species.length = 194
  allValid : allSpeciesValid species = true
  identityHashesUnique : stringsUnique (identityHashes species) = true
  graphHashesUnique : stringsUnique (graphHashes species) = true

/-! Small computed rejection corpus for the qualification boundary. -/

def emptyImportedFragment : ImportedFragment where
  atoms := []
  bonds := []
  parents := []

def loopImportedFragment : ImportedFragment where
  atoms := [neutralCarbonAtom]
  bonds :=
    [{ left := 0, right := 0, kind := .single, stereo := .none }]
  parents := [0]

def disconnectedImportedFragment : ImportedFragment where
  atoms := [neutralCarbonAtom, neutralCarbonAtom]
  bonds := []
  parents := [0, 0]

def validSingletonImportedFragment : ImportedFragment where
  atoms := [neutralCarbonAtom]
  bonds := []
  parents := [0]

theorem fragmentValid_accepts_singleton :
    fragmentValid validSingletonImportedFragment = true := by
  rfl

theorem fragmentValid_rejects_empty :
    fragmentValid emptyImportedFragment = false := by
  rfl

theorem fragmentValid_rejects_loop :
    fragmentValid loopImportedFragment = false := by
  rfl

theorem fragmentValid_rejects_disconnected :
    fragmentValid disconnectedImportedFragment = false := by
  rfl

end CanonicalImport
end CP0
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CP0.CanonicalImport.fragmentValid
#print axioms Meta.Carbone.CP0.CanonicalImport.speciesValid
#print axioms Meta.Carbone.CP0.CanonicalImport.stringsUnique
#print axioms Meta.Carbone.CP0.CanonicalImport.ValidatedImport
#print axioms Meta.Carbone.CP0.CanonicalImport.fragmentValid_accepts_singleton
#print axioms Meta.Carbone.CP0.CanonicalImport.fragmentValid_rejects_empty
#print axioms Meta.Carbone.CP0.CanonicalImport.fragmentValid_rejects_loop
#print axioms Meta.Carbone.CP0.CanonicalImport.fragmentValid_rejects_disconnected
/- AXIOM_AUDIT_END -/
