import Meta.Core.StrictRelaxation
import Meta.Semantics.UseGraphNonReduction

/-!
# Finite nontrivial contextual semantics

This model has two contexts, a genuine refinement substitution, three terms,
composable asymmetric uses, two authorized readings, and two lawful transport
semantics on the exact same proof-relevant use graph.
-/

namespace Meta
namespace RelaxedSemantics
namespace FiniteContextualModel

open RelaxedUsageRegime

/-! ## Contexts and terms -/

inductive FiniteContext where
  | coarse
  | fine

inductive FiniteSub : FiniteContext -> FiniteContext -> Type where
  | coarseIdentity : FiniteSub .coarse .coarse
  | fineIdentity : FiniteSub .fine .fine
  | refine : FiniteSub .fine .coarse

def finiteIdentity : (gamma : FiniteContext) -> FiniteSub gamma gamma
  | .coarse => .coarseIdentity
  | .fine => .fineIdentity

def finiteCompose :
    {theta delta gamma : FiniteContext} ->
    FiniteSub theta delta ->
    FiniteSub delta gamma ->
    FiniteSub theta gamma
  | _, _, _, .coarseIdentity, .coarseIdentity => .coarseIdentity
  | _, _, _, .fineIdentity, .fineIdentity => .fineIdentity
  | _, _, _, .fineIdentity, .refine => .refine
  | _, _, _, .refine, .coarseIdentity => .refine

abbrev finiteContextCategory : ContextCategory where
  Ctx := FiniteContext
  Sub := FiniteSub
  identity := finiteIdentity
  compose := finiteCompose

def finiteContextLaws : LawfulContextCategory finiteContextCategory where
  leftIdentity := by
    intro delta gamma substitution
    cases substitution <;> rfl
  rightIdentity := by
    intro delta gamma substitution
    cases substitution <;> rfl
  associativity := by
    intro theta delta gamma omega first second third
    cases first <;> cases second <;> cases third <;> rfl

theorem coarse_ne_fine : FiniteContext.coarse = .fine -> False := by
  intro equality
  cases equality

def genuineRefinement : NontrivialContextChange finiteContextCategory where
  source := .fine
  target := .coarse
  substitution := .refine
  contextsSeparated := fun equality => coarse_ne_fine equality.symm

inductive FiniteTy where
  | phase

inductive Phase where
  | before
  | during
  | after

abbrev phaseLanguage : IndexedTermLanguage finiteContextCategory FiniteTy where
  Term := fun _ _ => Phase
  reindexTerm := fun {_ _} _ {_} phase => phase

def phaseLanguageLaws : LawfulIndexedTermLanguage phaseLanguage where
  reindexIdentity := by intro gamma A phase; rfl
  reindexComposition := by
    intro theta delta gamma first second A phase
    rfl

/-! ## Directed use and visible transport -/

inductive PhaseSeparation : Phase -> Phase -> Type where
  | beforeDuring : PhaseSeparation .before .during
  | duringAfter : PhaseSeparation .during .after
  | beforeAfter : PhaseSeparation .before .after

inductive PhaseCoordination : Phase -> Phase -> Type where
  | beforeDuring : PhaseCoordination .before .during
  | duringAfter : PhaseCoordination .during .after
  | beforeAfter : PhaseCoordination .before .after

inductive PhaseUse : Phase -> Phase -> Type where
  | beforeIdentity : PhaseUse .before .before
  | duringIdentity : PhaseUse .during .during
  | afterIdentity : PhaseUse .after .after
  | enter : PhaseUse .before .during
  | finish : PhaseUse .during .after
  | direct : PhaseUse .before .after

def phaseUseIdentity : (phase : Phase) -> PhaseUse phase phase
  | .before => .beforeIdentity
  | .during => .duringIdentity
  | .after => .afterIdentity

def phaseUseCompose :
    {left middle right : Phase} ->
    PhaseUse left middle ->
    PhaseUse middle right ->
    PhaseUse left right
  | _, _, _, .beforeIdentity, second => second
  | _, _, _, .duringIdentity, second => second
  | _, _, _, .afterIdentity, second => second
  | _, _, _, .enter, .duringIdentity => .enter
  | _, _, _, .enter, .finish => .direct
  | _, _, _, .finish, .afterIdentity => .finish
  | _, _, _, .direct, .afterIdentity => .direct

def phaseUseOfNoncontractive :
    {left right : Phase} ->
    PhaseSeparation left right ->
    PhaseCoordination left right ->
    PhaseUse left right
  | _, _, .beforeDuring, .beforeDuring => .enter
  | _, _, .duringAfter, .duringAfter => .finish
  | _, _, .beforeAfter, .beforeAfter => .direct

inductive FiniteRead : FiniteContext -> Type where
  | coarseProgress : FiniteRead .coarse
  | fineProgress : FiniteRead .fine
  | fineCompletion : FiniteRead .fine

def defaultFiniteRead : (gamma : FiniteContext) -> FiniteRead gamma
  | .coarse => .coarseProgress
  | .fine => .fineProgress

def reindexFiniteRead :
    {delta gamma : FiniteContext} ->
    FiniteSub delta gamma ->
    FiniteRead gamma ->
    FiniteRead delta
  | _, _, .coarseIdentity, .coarseProgress => .coarseProgress
  | _, _, .fineIdentity, .fineProgress => .fineProgress
  | _, _, .fineIdentity, .fineCompletion => .fineCompletion
  | _, _, .refine, .coarseProgress => .fineProgress

def readPhase : {gamma : FiniteContext} -> FiniteRead gamma -> Phase -> Bool
  | _, .coarseProgress, .before => false
  | _, .coarseProgress, .during => true
  | _, .coarseProgress, .after => true
  | _, .fineProgress, .before => false
  | _, .fineProgress, .during => true
  | _, .fineProgress, .after => true
  | _, .fineCompletion, .before => false
  | _, .fineCompletion, .during => false
  | _, .fineCompletion, .after => true

inductive TransportFlavor where
  | primary
  | secondary

inductive TaggedBoolTransport : Bool -> Bool -> Type where
  | stayFalse : TaggedBoolTransport false false
  | risePrimary : TaggedBoolTransport false true
  | riseSecondary : TaggedBoolTransport false true
  | stayTrue : TaggedBoolTransport true true

def taggedIdentity : (value : Bool) -> TaggedBoolTransport value value
  | false => .stayFalse
  | true => .stayTrue

def taggedRise : (flavor : TransportFlavor) -> TaggedBoolTransport false true
  | .primary => .risePrimary
  | .secondary => .riseSecondary

def taggedCompose :
    {left middle right : Bool} ->
    TaggedBoolTransport left middle ->
    TaggedBoolTransport middle right ->
    TaggedBoolTransport left right
  | _, _, _, .stayFalse, second => second
  | _, _, _, .risePrimary, .stayTrue => .risePrimary
  | _, _, _, .riseSecondary, .stayTrue => .riseSecondary
  | _, _, _, .stayTrue, second => second

/-- Context refinement preserves the proof-relevant transport tag. -/
def reindexTaggedTransport :
    {delta gamma : FiniteContext} ->
    (substitution : FiniteSub delta gamma) ->
    (reading : FiniteRead gamma) ->
    (left right : Phase) ->
    TaggedBoolTransport (readPhase reading left) (readPhase reading right) ->
    TaggedBoolTransport
      (readPhase (reindexFiniteRead substitution reading) left)
      (readPhase (reindexFiniteRead substitution reading) right) := by
  intro delta gamma substitution reading left right relation
  cases substitution
  · cases reading
    exact relation
  · cases reading <;> exact relation
  · cases reading
    cases left <;> cases right <;> exact relation

def phaseTransport
    (flavor : TransportFlavor) :
    {gamma : FiniteContext} ->
    {left right : Phase} ->
    PhaseUse left right ->
    (reading : FiniteRead gamma) ->
    TaggedBoolTransport (readPhase reading left) (readPhase reading right)
  | _, _, _, .beforeIdentity, reading =>
      taggedIdentity (readPhase reading .before)
  | _, _, _, .duringIdentity, reading =>
      taggedIdentity (readPhase reading .during)
  | _, _, _, .afterIdentity, reading =>
      taggedIdentity (readPhase reading .after)
  | _, _, _, .enter, .coarseProgress => taggedRise flavor
  | _, _, _, .enter, .fineProgress => taggedRise flavor
  | _, _, _, .enter, .fineCompletion => .stayFalse
  | _, _, _, .finish, .coarseProgress => .stayTrue
  | _, _, _, .finish, .fineProgress => .stayTrue
  | _, _, _, .finish, .fineCompletion => taggedRise flavor
  | _, _, _, .direct, .coarseProgress => taggedRise flavor
  | _, _, _, .direct, .fineProgress => taggedRise flavor
  | _, _, _, .direct, .fineCompletion => taggedRise flavor

abbrev finiteRegime
    (flavor : TransportFlavor) :
    ContextualRelaxedRegime finiteContextCategory phaseLanguage where
  Read := fun gamma _ => FiniteRead gamma
  defaultRead := fun gamma _ => defaultFiniteRead gamma
  Out := fun _ _ _ => Bool
  read := fun {_ _} reading phase => readPhase reading phase
  Sep := fun {_ _} left right => PhaseSeparation left right
  Coord := fun {_ _} left right => PhaseCoordination left right
  Use := fun {_ _} left right => PhaseUse left right
  OutRel := fun {_ _} _ left right => TaggedBoolTransport left right
  identityUse := fun {_ _} phase => phaseUseIdentity phase
  composeUse := fun {_ _ _ _ _} first second => phaseUseCompose first second
  useOfNoncontractive := fun {_ _ _ _} separation coordination =>
    phaseUseOfNoncontractive separation coordination
  transport := fun {_ _ _ _} use reading => phaseTransport flavor use reading
  outIdentity := fun {_ _} reading phase =>
    taggedIdentity (readPhase reading phase)
  outCompose := fun {_ _} _ {_ _ _} first second =>
    taggedCompose first second
  reindexRead := fun {_ _} substitution {_} reading =>
    reindexFiniteRead substitution reading
  reindexSep := fun {_ _} _ {_ _ _} separation => separation
  reindexCoord := fun {_ _} _ {_ _ _} coordination => coordination
  reindexUse := fun {_ _} _ {_ _ _} use => use
  reindexOutRel := by
    intro delta gamma substitution A reading left right relation
    exact reindexTaggedTransport substitution reading left right relation

def finiteRegimeLaws
    (flavor : TransportFlavor) :
    LawfulContextualRelaxedRegime (finiteRegime flavor) where
  contextLaws := finiteContextLaws
  termLaws := phaseLanguageLaws
  separationRefutesIdentity := by
    intro gamma A left right separation equality
    cases separation <;> cases equality
  useLeftIdentity := by
    intro gamma A left right use
    cases use <;> rfl
  useRightIdentity := by
    intro gamma A left right use
    cases use <;> rfl
  useAssociativity := by
    intro gamma A left middle right target first second third
    cases first <;> cases second <;> cases third <;> rfl
  outLeftIdentity := by
    intro gamma A reading left right relation
    cases reading <;> cases left <;> cases right <;> cases relation <;> rfl
  outRightIdentity := by
    intro gamma A reading left right relation
    cases reading <;> cases left <;> cases right <;> cases relation <;> rfl
  outAssociativity := by
    intro gamma A reading left middle right target first second third
    cases reading <;> cases left <;> cases middle <;> cases right <;>
      cases target <;> cases first <;> cases second <;> cases third <;> rfl
  transportIdentity := by
    intro gamma A reading phase
    cases reading <;> cases phase <;> rfl
  transportComposition := by
    intro gamma A reading left middle right first second
    cases flavor <;> cases reading <;> cases first <;> cases second <;> rfl
  reindexReadIdentity := by
    intro gamma A reading
    cases reading <;> rfl
  reindexReadComposition := by
    intro theta delta gamma first second A reading
    cases first <;> cases second <;> cases reading <;> rfl
  transportReindexing := by
    intro delta gamma substitution A reading left right use
    cases flavor <;> cases substitution <;> cases reading <;> cases use <;> rfl

/-! ## Admissible predicates and independent syntax -/

structure MonotonePhasePredicate where
  Holds : Phase -> Prop
  preserves :
    {left right : Phase} ->
    PhaseUse left right ->
    Holds left ->
    Holds right

def predicateTop : MonotonePhasePredicate where
  Holds := fun _ => True
  preserves := fun {_ _} _ proof => proof

def predicateBottom : MonotonePhasePredicate where
  Holds := fun _ => False
  preserves := fun {_ _} _ impossible => impossible

def predicateConjunction
    (left right : MonotonePhasePredicate) :
    MonotonePhasePredicate where
  Holds := fun phase => left.Holds phase /\ right.Holds phase
  preserves := fun use proof =>
    ⟨left.preserves use proof.1, right.preserves use proof.2⟩

def reachedDuring : MonotonePhasePredicate where
  Holds
    | .before => False
    | .during => True
    | .after => True
  preserves := by
    intro left right use proof
    cases use <;> trivial

def reachedCompletion : MonotonePhasePredicate where
  Holds
    | .before => False
    | .during => False
    | .after => True
  preserves := by
    intro left right use proof
    cases use <;> trivial

abbrev finiteDoctrine
    (flavor : TransportFlavor) :
    AdmissiblePredicateDoctrine (finiteRegime flavor) where
  Pred := fun _ _ => MonotonePhasePredicate
  Holds := fun {_ _} predicate phase => predicate.Holds phase
  top := fun _ _ => predicateTop
  bottom := fun _ _ => predicateBottom
  conjunction := fun {_ _} left right => predicateConjunction left right
  reindexPred := fun {_ _} _ {_} predicate => predicate
  substituteUse := fun {_ _ _ _} use predicate proof =>
    predicate.preserves use proof

def finiteDoctrineLaws
    (flavor : TransportFlavor) :
    LawfulAdmissiblePredicateDoctrine (finiteDoctrine flavor) where
  holdsTop := by intro gamma A phase; trivial
  holdsBottomRefuted := fun impossible => impossible
  holdsConjunctionLeft := fun proof => proof.1
  holdsConjunctionRight := fun proof => proof.2
  holdsConjunction := fun left right => ⟨left, right⟩
  reindexHolds := fun {_ _} _ {_ _ _} proof => proof
  reindexReflectsHolds := fun {_ _} _ {_ _ _} proof => proof
  substitutionIdentity := by
    intro gamma A phase predicate proof
    exact Subsingleton.elim _ _
  substitutionComposition := by
    intro gamma A left middle right first second predicate proof
    exact Subsingleton.elim _ _

inductive FinitePredicateAtom where
  | during
  | completion

abbrev finiteSignature : RelaxedTransportSignature finiteContextCategory where
  Ty := FiniteTy
  SubstitutionAtom := FiniteSub
  TermAtom := fun _ _ => Phase
  SeparationAtom := fun {_ _} left right => PhaseSeparation left right
  CoordinationAtom := fun {_ _} left right => PhaseCoordination left right
  PredicateAtom := fun _ _ => FinitePredicateAtom

def finiteInterpretation
    (flavor : TransportFlavor) :
    RelaxedInterpretation
      finiteSignature
      phaseLanguage
      (finiteRegime flavor)
      (finiteDoctrine flavor) where
  substitutionAtom := fun substitution => substitution
  termAtom := fun phase => phase
  separationAtom := fun separation => separation
  coordinationAtom := fun coordination => coordination
  predicateAtom
    | .during => reachedDuring
    | .completion => reachedCompletion

/-- A second lawful interpretation gives the same syntax atom a stricter meaning. -/
def finiteInterpretationAlternative :
    RelaxedInterpretation
      finiteSignature
      phaseLanguage
      (finiteRegime .secondary)
      (finiteDoctrine .secondary) where
  substitutionAtom := fun substitution => substitution
  termAtom := fun phase => phase
  separationAtom := fun separation => separation
  coordinationAtom := fun coordination => coordination
  predicateAtom
    | .during => reachedCompletion
    | .completion => reachedDuring

/-- A genuine syntactic refinement, independent of semantic composition. -/
def finiteRefinementSyntax :
    RelaxedSubstitution finiteSignature .fine .coarse :=
  .atom .refine

/-- Its interpretation computes the semantic refinement substitution. -/
theorem finiteRefinementSyntax_interprets :
    (finiteInterpretation .primary).interpretSubstitution
        finiteRefinementSyntax =
      FiniteSub.refine :=
  rfl

/-- Closed model data; consistency is deliberately not a field. -/
structure ClosedRelaxedFoundationalModel : Type where
  contextLaws : LawfulContextCategory finiteContextCategory
  regimeLaws : LawfulContextualRelaxedRegime (finiteRegime .primary)
  doctrineLaws : LawfulAdmissiblePredicateDoctrine (finiteDoctrine .primary)
  interpretation :
    RelaxedInterpretation
      finiteSignature
      phaseLanguage
      (finiteRegime .primary)
      (finiteDoctrine .primary)

/-- Inhabited nontrivial model of the contextual relaxed calculus. -/
def finiteFoundationalModel : ClosedRelaxedFoundationalModel where
  contextLaws := finiteContextLaws
  regimeLaws := finiteRegimeLaws .primary
  doctrineLaws := finiteDoctrineLaws .primary
  interpretation := finiteInterpretation .primary

/-! ## Nontriviality and non-reduction witnesses -/

def sameUseGraph :
    SameContextualUseGraph
      (finiteRegime .primary)
      (finiteRegime .secondary) where
  forward := fun use => use
  backward := fun use => use
  backwardForward := fun _ => rfl
  forwardBackward := fun _ => rfl

theorem transportSemantics_distinct :
    (finiteRegime .primary).transport
        (gamma := FiniteContext.fine)
        (A := FiniteTy.phase)
        PhaseUse.enter
        FiniteRead.fineProgress =
      (finiteRegime .secondary).transport
        (gamma := FiniteContext.fine)
        (A := FiniteTy.phase)
        PhaseUse.enter
        FiniteRead.fineProgress ->
    False := by
  intro equality
  cases equality

/-- Observe specifically the primary proof-relevant rise constructor. -/
def observesPrimaryRise :
    {left right : Bool} ->
    TaggedBoolTransport left right ->
    Bool
  | _, _, .risePrimary => true
  | _, _, .riseSecondary => false
  | _, _, .stayFalse => false
  | _, _, .stayTrue => false

/-- Concrete transport distinction over the common `enter` use. -/
def finiteTransportSemanticDistinction :
    TransportSemanticDistinction
      (finiteRegime .primary)
      (finiteRegime .secondary) where
  context := .fine
  sort := .phase
  source := .before
  target := .during
  leftUse := .enter
  rightUse := .enter
  leftReading := .fineProgress
  rightReading := .fineProgress
  observeLeft := observesPrimaryRise
  observeRight := observesPrimaryRise
  leftObserved := rfl
  rightObserved := rfl

/-- The shared term `during` validates one admissible meaning and refutes another. -/
def finitePredicateSemanticDistinction :
    PredicateSemanticDistinction
      (finiteDoctrine .primary)
      (finiteDoctrine .secondary) where
  context := .fine
  sort := .phase
  term := .during
  leftPredicate := reachedDuring
  rightPredicate := reachedCompletion
  leftHolds := trivial
  rightRefuted := fun impossible => impossible

/-- One proof-relevant use graph supports two observably different semantics. -/
def finiteUseGraphSemanticNonReduction :
    UseGraphSemanticNonReduction
      (finiteRegime .primary)
      (finiteRegime .secondary)
      (finiteDoctrine .primary)
      (finiteDoctrine .secondary) where
  sameGraph := sameUseGraph
  transportDistinction := finiteTransportSemanticDistinction
  predicateDistinction := finitePredicateSemanticDistinction

/-- The atom `during` itself receives the two distinguished predicate meanings. -/
theorem finitePredicateInterpretation_distinct :
    (finiteDoctrine .secondary).Holds
        (gamma := FiniteContext.fine)
        (A := FiniteTy.phase)
        (finiteInterpretationAlternative.predicateAtom
          (gamma := FiniteContext.fine)
          (A := FiniteTy.phase)
          FinitePredicateAtom.during)
        Phase.during ->
    False := by
  intro impossible
  exact impossible

theorem progressRead_nonconstant :
    readPhase FiniteRead.fineProgress Phase.before =
      readPhase FiniteRead.fineProgress Phase.during ->
    False := by
  intro equality
  cases equality

theorem reachedDuring_nonconstant :
    (reachedDuring.Holds Phase.before <->
      reachedDuring.Holds Phase.during) ->
    False := by
  intro equivalence
  exact equivalence.mpr trivial

def forwardFineUse :
    HasUse
      ((finiteRegime .primary).fiberRegime .fine .phase)
      ()
      Phase.before
      Phase.during :=
  ⟨PhaseUse.enter⟩

theorem noBackwardFineUse :
    HasUse
        ((finiteRegime .primary).fiberRegime .fine .phase)
        ()
        Phase.during
        Phase.before ->
    False := by
  intro backward
  cases backward with
  | intro use => cases use

theorem finiteFiber_not_projectivelyRepresentable :
    ProjectivelyRepresentable
        ((finiteRegime .primary).fiberRegime .fine .phase) ->
    False :=
  not_projectivelyRepresentable_of_asymmetric_use
    forwardFineUse
    noBackwardFineUse

/-- Consistency is derived from soundness of the closed model. -/
theorem finiteModel_noClosedContradiction :
    ClosedRelaxedContradiction finiteSignature FiniteContext.fine ->
    False :=
  closedRelaxedConsistency
    finiteFoundationalModel.doctrineLaws
    finiteFoundationalModel.interpretation
    .fine

theorem finiteSyntax_consistent :
    ClosedRelaxedContradiction finiteSignature FiniteContext.fine ->
    False :=
  finiteModel_noClosedContradiction

/-- Closed witness of a directed use that cannot be strict identity. -/
structure FiniteStrictRelaxation : Type where
  forward : PhaseUse .before .during
  separated : Phase.before = Phase.during -> False
  noBackward : PhaseUse .during .before -> False

def finiteModel_strictRelaxation : FiniteStrictRelaxation where
  forward := .enter
  separated := by intro equality; cases equality
  noBackward := by intro backward; cases backward

/-- Pointwise initiality specialized to the finite closed interpretation. -/
theorem finiteUseInterpretation_unique
    (other : UseInterpretationAlgebra (finiteInterpretation .primary)) :
    {gamma : FiniteContext} ->
    {A : FiniteTy} ->
    {x y : RelaxedTerm finiteSignature gamma A} ->
    (use : UseDerivation x y) ->
      other.evaluate use =
        (finiteInterpretation .primary).interpretUse use :=
  (finiteInterpretation .primary).interpretUse_unique other

/-- Named closed witness for the semantic non-reduction theorem. -/
def finiteModel_useGraphSemanticDistinction :
    UseGraphSemanticNonReduction
      (finiteRegime .primary)
      (finiteRegime .secondary)
      (finiteDoctrine .primary)
      (finiteDoctrine .secondary) :=
  finiteUseGraphSemanticNonReduction

end FiniteContextualModel
end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteContextLaws
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.genuineRefinement
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteRegimeLaws
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteDoctrineLaws
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteRefinementSyntax_interprets
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteFoundationalModel
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.sameUseGraph
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.transportSemantics_distinct
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteTransportSemanticDistinction
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finitePredicateSemanticDistinction
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteUseGraphSemanticNonReduction
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finitePredicateInterpretation_distinct
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteFiber_not_projectivelyRepresentable
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteModel_noClosedContradiction
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteSyntax_consistent
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteModel_strictRelaxation
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteUseInterpretation_unique
#print axioms Meta.RelaxedSemantics.FiniteContextualModel.finiteModel_useGraphSemanticDistinction
/- AXIOM_AUDIT_END -/
