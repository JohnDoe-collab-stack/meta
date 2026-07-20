import Meta.Semantics.Specialization.FiniteContextualModel
import Meta.Semantics.Specialization.FiniteDynamicModel
import Meta.Semantics.Specialization.FiniteCumulativeDynamicModel

/-!
# Closed foundational stability theorem

This certificate combines the generic semantics with its finite contextual and
repair-driven instances.  Its fields rule out the intended trivializations:
contexts, readings, use direction, transport witnesses, and dynamic states are
all constructively distinguished.
-/

namespace Meta
namespace RelaxedSemantics

open FiniteContextualModel
open FiniteDynamicModel
open FiniteCumulativeDynamicModel
open DynamicRelaxedUsageModel
open RelaxedUsageRegime

/-- Closed certificate that relaxed substitution is conservative and stable. -/
structure GeneralRelaxedFoundationalSemantics where
  closedContextualModel : ClosedRelaxedFoundationalModel
  contextualSubstitution : LawfulContextCategory finiteContextCategory
  genuineContextChange : NontrivialContextChange finiteContextCategory
  freeRefinementComputes :
    (finiteInterpretation .primary).interpretSubstitution
        finiteRefinementSyntax =
      FiniteSub.refine
  primaryModel : LawfulContextualRelaxedRegime (finiteRegime .primary)
  secondaryModel : LawfulContextualRelaxedRegime (finiteRegime .secondary)
  admissiblePredicates :
    LawfulAdmissiblePredicateDoctrine (finiteDoctrine .primary)
  independentSyntaxIsConservative :
    StrictIdentityConservativity finiteSignature
  independentSyntaxIsConsistent :
    ClosedRelaxedContradiction finiteSignature FiniteContext.fine -> False
  freeUseInterpretationIsInitial :
    (other : UseInterpretationAlgebra (finiteInterpretation .primary)) ->
    {gamma : FiniteContext} ->
    {A : FiniteTy} ->
    {x y : RelaxedTerm finiteSignature gamma A} ->
    (use : UseDerivation x y) ->
      other.evaluate use =
        (finiteInterpretation .primary).interpretUse use
  useGraphInsufficient :
    UseGraphSemanticNonReduction
      (finiteRegime .primary)
      (finiteRegime .secondary)
      (finiteDoctrine .primary)
      (finiteDoctrine .secondary)
  readingIsNonconstant :
    readPhase FiniteRead.fineProgress Phase.before =
      readPhase FiniteRead.fineProgress Phase.during ->
    False
  admissiblePredicateIsNonconstant :
    (reachedDuring.Holds Phase.before <->
      reachedDuring.Holds Phase.during) ->
    False
  asymmetricUseRefutesExactProjection :
    ExactProjectiveRepresentation.{0, 0}
        ((finiteRegime .primary).fiberRegime .fine .phase) ->
    False
  repairDrivenDynamics :
    GapRepairAlgebra switchIntrinsicDynamicReturnFamily
  visibleRepairDrivenDynamics :
    GapRepairAlgebra switchIntrinsicDynamicReturnFamily
  sameExternalTransition :
    (source : SwitchState) ->
    repairDrivenDynamics.next source =
      visibleRepairDrivenDynamics.next source
  initialRepairIsEffective :
    EffectiveRepairAt repairDrivenDynamics .leftToRight
  stableRepairOrbit :
    (n : Nat) ->
    SwitchOrbitStable
      (repairDrivenDynamics.iterate
        n
        switchIntrinsicDynamicReturnFamily.initial)
  transitionGraphInsufficient :
    DynamicTransitionSemanticDistinction
  cumulativeRepairSystem :
    FiniteDynamicFoundationalSystem

/-- Fully inhabited constructive model of the general semantics. -/
def generalRelaxedFoundationalSemantics :
    GeneralRelaxedFoundationalSemantics where
  closedContextualModel := finiteFoundationalModel
  contextualSubstitution := finiteContextLaws
  genuineContextChange := genuineRefinement
  freeRefinementComputes := finiteRefinementSyntax_interprets
  primaryModel := finiteRegimeLaws .primary
  secondaryModel := finiteRegimeLaws .secondary
  admissiblePredicates := finiteDoctrineLaws .primary
  independentSyntaxIsConservative :=
    strictIdentityConservativity finiteSignature
  independentSyntaxIsConsistent := finiteSyntax_consistent
  freeUseInterpretationIsInitial := finiteUseInterpretation_unique
  useGraphInsufficient := finiteUseGraphSemanticNonReduction
  readingIsNonconstant := progressRead_nonconstant
  admissiblePredicateIsNonconstant := reachedDuring_nonconstant
  asymmetricUseRefutesExactProjection :=
    not_exactProjective_of_asymmetric_use
      forwardFineUse
      noBackwardFineUse
  repairDrivenDynamics := switchMemoryRepairAlgebra
  visibleRepairDrivenDynamics := switchVisibleRepairAlgebra
  sameExternalTransition := switchRepairAlgebras_sameNext
  initialRepairIsEffective := switchRepairEffectiveAt .leftToRight
  stableRepairOrbit := switchStableAtIteration
  transitionGraphInsufficient :=
    finiteTransitionGraphSemanticDistinction
  cumulativeRepairSystem := finiteDynamicFoundationalSystem

/-- The central non-contraction theorem exposed by the closed certificate. -/
theorem foundationalTransport_withoutIdentity :
    HasUse
        ((finiteRegime .primary).fiberRegime .fine .phase)
        ()
        Phase.before
        Phase.during
    /\
    (Phase.before = Phase.during -> False) := by
  constructor
  · exact forwardFineUse
  · intro equality
    cases equality

/-- The same use graph admits two constructively distinct lawful transports. -/
def foundationalUseGraph_nonreduction :
    UseGraphSemanticNonReduction
      (finiteRegime .primary)
      (finiteRegime .secondary)
      (finiteDoctrine .primary)
      (finiteDoctrine .secondary) :=
  generalRelaxedFoundationalSemantics.useGraphInsufficient

/-- The same state graph carries two separated internal causal challenges. -/
def foundationalTransitionGraph_nonreduction :
    DynamicTransitionSemanticDistinction :=
  generalRelaxedFoundationalSemantics.transitionGraphInsufficient

end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.GeneralRelaxedFoundationalSemantics
#print axioms Meta.RelaxedSemantics.generalRelaxedFoundationalSemantics
#print axioms Meta.RelaxedSemantics.foundationalTransport_withoutIdentity
#print axioms Meta.RelaxedSemantics.foundationalUseGraph_nonreduction
#print axioms Meta.RelaxedSemantics.foundationalTransitionGraph_nonreduction
/- AXIOM_AUDIT_END -/
