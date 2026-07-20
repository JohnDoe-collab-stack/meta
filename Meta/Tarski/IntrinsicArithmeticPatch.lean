import Meta.Tarski.GenericPatchOrbit
import Meta.Tarski.IntrinsicArithmeticSyntax

/-!
# Closed intrinsic arithmetic patch orbit

This file instantiates the generic patch-orbit theorem with the autonomous raw
arithmetic syntax.  No declaration below uses the historical `Foundation`
bridge: quotation, diagonal mismatch, local repair, preservation, and the
resulting non-recurrent dynamics are all supplied internally.

The present micro-kernel is deliberately reflective.  Its `closed` and `fixed`
constructors have structurally recursive standard-`Nat` semantics.  Compiling
those two reflective constructors into a smaller non-reflective first-order
signature is a separate conservativity layer and is not assumed by this closed
instance.
-/

namespace Meta
namespace IntrinsicArithmeticPatch

open ClosedStabilityTheorem
open IntrinsicArithmeticSyntax
open TarskiDynamicRelaxedUsage

/-! ## Closed arithmetic and patchable contexts -/

/-- Arithmetic Tarski context carried entirely by the intrinsic raw syntax. -/
def intrinsicArithmeticTarskiContext : ArithmeticTarskiContext where
  Sentence := RawFormula
  Predicate := RawFormula
  applyQuote := IntrinsicArithmeticSyntax.applyQuote
  models := IntrinsicArithmeticSyntax.models
  diagonal := IntrinsicArithmeticSyntax.diagonal
  diagonal_spec := IntrinsicArithmeticSyntax.diagonal_spec

/-- The intrinsic syntactic patch closes the arithmetic context under repair. -/
def intrinsicPatchableTarskiContext : PatchableArithmeticTarskiContext where
  context := intrinsicArithmeticTarskiContext
  patchPredicate := IntrinsicArithmeticSyntax.patchPredicate
  patch_agrees_at := IntrinsicArithmeticSyntax.patchPredicate_agrees_at
  patch_preserves_off_index :=
    IntrinsicArithmeticSyntax.patchPredicate_preserves_off_index

/-- The constantly false raw predicate is the closed initial candidate. -/
def initialIntrinsicPredicate : RawFormula :=
  RawFormula.falsum

/-! ## Closed dynamic synthesis and generic orbit -/

/-- The complete gap-driven dynamic synthesis of the intrinsic arithmetic patch. -/
def intrinsicTarskiDynamicRelaxedUsageSynthesis :
    TarskiDynamicRelaxedUsageSynthesis
      intrinsicPatchableTarskiContext
      initialIntrinsicPredicate :=
  tarskiDynamicRelaxedUsageSynthesis
    intrinsicPatchableTarskiContext
    initialIntrinsicPredicate

/-- All generic orbit consequences specialized to the intrinsic arithmetic syntax. -/
def intrinsicGenericPatchOrbitTheorem :
    PatchableArithmeticTarskiContext.GenericPatchOrbitTheorem
      intrinsicPatchableTarskiContext
      initialIntrinsicPredicate :=
  PatchableArithmeticTarskiContext.genericPatchOrbitTheorem
    intrinsicPatchableTarskiContext
    initialIntrinsicPredicate

/-- The raw predicate reached after `n` intrinsic diagonal repairs. -/
def intrinsicOrbitCandidate (n : Nat) : RawFormula :=
  PatchableArithmeticTarskiContext.genericOrbitCandidate
    intrinsicPatchableTarskiContext
    initialIntrinsicPredicate
    n

/-- The raw diagonal sentence challenged at step `n`. -/
def intrinsicOrbitIndex (n : Nat) : RawFormula :=
  PatchableArithmeticTarskiContext.genericOrbitIndex
    intrinsicPatchableTarskiContext
    initialIntrinsicPredicate
    n

/-- The intrinsic diagonal challenges determine their iteration numbers. -/
theorem intrinsicOrbitIndex_injective
    {k n : Nat}
    (sameIndex : intrinsicOrbitIndex k = intrinsicOrbitIndex n) :
    k = n :=
  PatchableArithmeticTarskiContext.genericOrbitIndex_injective
    intrinsicPatchableTarskiContext
    initialIntrinsicPredicate
    sameIndex

/-- The intrinsic arithmetic candidates determine their iteration numbers. -/
theorem intrinsicOrbitCandidate_injective
    {k n : Nat}
    (sameCandidate : intrinsicOrbitCandidate k = intrinsicOrbitCandidate n) :
    k = n :=
  PatchableArithmeticTarskiContext.genericOrbitCandidate_injective
    intrinsicPatchableTarskiContext
    initialIntrinsicPredicate
    sameCandidate

/-- No positive period returns the intrinsic arithmetic orbit to an old state. -/
theorem intrinsicOrbit_noExactReturn
    (n period : Nat)
    (positivePeriod : 0 < period)
    (sameCandidate :
      intrinsicOrbitCandidate (n + period) = intrinsicOrbitCandidate n) :
    False :=
  PatchableArithmeticTarskiContext.genericOrbit_noExactReturn
    intrinsicPatchableTarskiContext
    initialIntrinsicPredicate
    n
    period
    positivePeriod
    sameCandidate

/-- Every intrinsic arithmetic candidate remains globally Tarski-incomplete. -/
theorem intrinsicOrbit_everyCandidateIncomplete
    (n : Nat)
    (definition :
      TarskiTruthDefinition
        (intrinsicPatchableTarskiContext.truthAt
          (intrinsicOrbitCandidate n))
        intrinsicArithmeticTarskiContext.models) :
    False :=
  PatchableArithmeticTarskiContext.genericOrbit_everyCandidateIncomplete
    intrinsicPatchableTarskiContext
    initialIntrinsicPredicate
    n
    definition

/-! ## Formal non-triviality -/

/-- A closed raw arithmetic sentence true in the standard natural numbers. -/
def intrinsicTrueSentence : RawFormula :=
  RawFormula.equal (RawTerm.numeral 0) (RawTerm.numeral 0)

/-- A closed raw arithmetic sentence false in the standard natural numbers. -/
def intrinsicFalseSentence : RawFormula :=
  RawFormula.falsum

/-- The intrinsic true sentence is genuinely modeled. -/
def intrinsicTrueSentence_models :
    intrinsicArithmeticTarskiContext.models intrinsicTrueSentence :=
  rfl

/-- The intrinsic false sentence is genuinely refuted. -/
theorem intrinsicFalseSentence_not_models :
    intrinsicArithmeticTarskiContext.models intrinsicFalseSentence -> False := by
  intro impossible
  exact impossible

/-- Standard-`Nat` semantics is not constant on the intrinsic sentence type. -/
theorem intrinsicModels_nonconstant
    (sameTruth :
      intrinsicArithmeticTarskiContext.models intrinsicTrueSentence ↔
        intrinsicArithmeticTarskiContext.models intrinsicFalseSentence) :
    False :=
  intrinsicFalseSentence_not_models
    (sameTruth.mp intrinsicTrueSentence_models)

/-- Distinct iteration numbers give distinct intrinsic candidates. -/
theorem intrinsicOrbitCandidate_ne_of_ne
    {k n : Nat}
    (differentIterations : k = n -> False)
    (sameCandidate : intrinsicOrbitCandidate k = intrinsicOrbitCandidate n) :
    False :=
  differentIterations (intrinsicOrbitCandidate_injective sameCandidate)

/-- Distinct iteration numbers give distinct intrinsic diagonal challenges. -/
theorem intrinsicOrbitIndex_ne_of_ne
    {k n : Nat}
    (differentIterations : k = n -> False)
    (sameIndex : intrinsicOrbitIndex k = intrinsicOrbitIndex n) :
    False :=
  differentIterations (intrinsicOrbitIndex_injective sameIndex)

/-- The first repair produces a state distinct from the initial state. -/
theorem intrinsicInitialCandidate_ne_first
    (sameCandidate : intrinsicOrbitCandidate 0 = intrinsicOrbitCandidate 1) :
    False :=
  intrinsicOrbitCandidate_ne_of_ne
    (fun impossible => Nat.noConfusion impossible)
    sameCandidate

/-- Every successor candidate is correct at the challenge just repaired. -/
theorem intrinsicOrbit_repairsPrevious (n : Nat) :
    PatchableArithmeticTarskiContext.CorrectAt
      intrinsicPatchableTarskiContext
      (intrinsicOrbitCandidate (Nat.succ n))
      (intrinsicOrbitIndex n) :=
  intrinsicGenericPatchOrbitTheorem.cumulativeAgreement
    (Nat.lt_succ_self n)

/-- Every candidate still mismatches semantics at its own current challenge. -/
theorem intrinsicOrbit_currentMismatch (n : Nat) :
    PatchableArithmeticTarskiContext.CorrectAt
        intrinsicPatchableTarskiContext
        (intrinsicOrbitCandidate n)
        (intrinsicOrbitIndex n) ->
      False :=
  intrinsicGenericPatchOrbitTheorem.currentMismatch n

/--
Every repair changes the induced semantic truth value at the current challenge;
the orbit is not merely a sequence of differently written but equivalent
predicates.
-/
theorem intrinsicOrbit_semanticChangeAtCurrent
    (n : Nat)
    (sameTruth :
      intrinsicPatchableTarskiContext.truthAt
          (intrinsicOrbitCandidate n)
          (intrinsicOrbitIndex n) ↔
        intrinsicPatchableTarskiContext.truthAt
          (intrinsicOrbitCandidate (Nat.succ n))
          (intrinsicOrbitIndex n)) :
    False :=
  intrinsicOrbit_currentMismatch n
    (sameTruth.trans (intrinsicOrbit_repairsPrevious n))

/-- Closed certificate that the intrinsic arithmetic orbit is non-vacuous. -/
structure IntrinsicArithmeticNontriviality : Type where
  trueSentenceModeled :
    intrinsicArithmeticTarskiContext.models intrinsicTrueSentence
  falseSentenceRefuted :
    intrinsicArithmeticTarskiContext.models intrinsicFalseSentence -> False
  semanticValuesSeparated :
    (intrinsicArithmeticTarskiContext.models intrinsicTrueSentence ↔
      intrinsicArithmeticTarskiContext.models intrinsicFalseSentence) ->
        False
  firstStepSeparated :
    intrinsicOrbitCandidate 0 = intrinsicOrbitCandidate 1 -> False
  allCandidatesSeparated :
    forall {k n : Nat},
      (k = n -> False) ->
        intrinsicOrbitCandidate k = intrinsicOrbitCandidate n -> False
  allIndicesSeparated :
    forall {k n : Nat},
      (k = n -> False) ->
        intrinsicOrbitIndex k = intrinsicOrbitIndex n -> False
  everyStepChangesSemantics :
    forall n : Nat,
      (intrinsicPatchableTarskiContext.truthAt
          (intrinsicOrbitCandidate n)
          (intrinsicOrbitIndex n) ↔
        intrinsicPatchableTarskiContext.truthAt
          (intrinsicOrbitCandidate (Nat.succ n))
          (intrinsicOrbitIndex n)) ->
        False

/-- Canonical closed proof of intrinsic arithmetic non-triviality. -/
def intrinsicArithmeticNontriviality :
    IntrinsicArithmeticNontriviality where
  trueSentenceModeled := intrinsicTrueSentence_models
  falseSentenceRefuted := intrinsicFalseSentence_not_models
  semanticValuesSeparated := intrinsicModels_nonconstant
  firstStepSeparated := intrinsicInitialCandidate_ne_first
  allCandidatesSeparated := intrinsicOrbitCandidate_ne_of_ne
  allIndicesSeparated := intrinsicOrbitIndex_ne_of_ne
  everyStepChangesSemantics := intrinsicOrbit_semanticChangeAtCurrent

/--
One closed value retaining both the dynamic synthesis and the full injective
orbit theorem for the autonomous arithmetic syntax.
-/
structure IntrinsicArithmeticClosedSystem : Type where
  dynamicSynthesis :
    TarskiDynamicRelaxedUsageSynthesis
      intrinsicPatchableTarskiContext
      initialIntrinsicPredicate
  orbitTheorem :
    PatchableArithmeticTarskiContext.GenericPatchOrbitTheorem
      intrinsicPatchableTarskiContext
      initialIntrinsicPredicate
  nontriviality : IntrinsicArithmeticNontriviality

/-- Canonical closed arithmetic system, independent of `Foundation`. -/
def intrinsicArithmeticClosedSystem : IntrinsicArithmeticClosedSystem where
  dynamicSynthesis := intrinsicTarskiDynamicRelaxedUsageSynthesis
  orbitTheorem := intrinsicGenericPatchOrbitTheorem
  nontriviality := intrinsicArithmeticNontriviality

end IntrinsicArithmeticPatch
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicArithmeticTarskiContext
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicPatchableTarskiContext
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicTarskiDynamicRelaxedUsageSynthesis
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicGenericPatchOrbitTheorem
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicOrbitIndex_injective
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicOrbitCandidate_injective
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicOrbit_noExactReturn
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicOrbit_everyCandidateIncomplete
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicModels_nonconstant
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicInitialCandidate_ne_first
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicOrbit_semanticChangeAtCurrent
#print axioms Meta.IntrinsicArithmeticPatch.IntrinsicArithmeticNontriviality
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicArithmeticNontriviality
#print axioms Meta.IntrinsicArithmeticPatch.IntrinsicArithmeticClosedSystem
#print axioms Meta.IntrinsicArithmeticPatch.intrinsicArithmeticClosedSystem
/- AXIOM_AUDIT_END -/
