import Meta.Semantics.Interpretation

/-!
# Constructive soundness of relaxed substitution

The proof interpreter follows the syntax.  The transport rule is validated
only by the doctrine's `substituteUse` operation applied to the use computed
from the syntactic derivation.
-/

namespace Meta
namespace RelaxedSemantics

universe u v s t ta p q d r o sp cq w pd h

/-- Every derivation realizes its interpreted judgment. -/
def relaxedProof_sound
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (doctrineLaws : LawfulAdmissiblePredicateDoctrine D)
    (interpretation : RelaxedInterpretation signature L M D)
    {gamma : C.Ctx}
    {Hypothesis : RelaxedFormula signature gamma -> Type h}
    (environment : interpretation.RealizesHypotheses Hypothesis) :
    {judgment : RelaxedJudgment signature gamma} ->
    RelaxedProof Hypothesis judgment ->
    interpretation.interpretJudgment judgment
  | _, .assumption hypothesis => environment _ hypothesis
  | _, .topIntro => ()
  | _, .conjunctionIntro left right =>
      (relaxedProof_sound doctrineLaws interpretation environment left,
        relaxedProof_sound doctrineLaws interpretation environment right)
  | _, .conjunctionLeft proof =>
      (relaxedProof_sound doctrineLaws interpretation environment proof).1
  | _, .conjunctionRight proof =>
      (relaxedProof_sound doctrineLaws interpretation environment proof).2
  | _, .strictIdentity proof =>
      { evidence := interpretation.interpretStrictIdentity proof }
  | _, .transport use proof =>
      { evidence :=
          D.substituteUse
            (interpretation.interpretUse use)
            (interpretation.interpretPredicate _)
            (relaxedProof_sound
              doctrineLaws interpretation environment proof).evidence }

/-- No closed derivation of bottom exists in any lawful interpreted model. -/
theorem closedRelaxedConsistency
    {C : ContextCategory.{u, v}}
    {signature : RelaxedTransportSignature.{u, v, s, ta, p, q, d} C}
    {L : IndexedTermLanguage.{u, v, s, t} C signature.Ty}
    {M : ContextualRelaxedRegime.{u, v, s, t, r, o, sp, cq, w} C L}
    {D : AdmissiblePredicateDoctrine.{u, v, s, t, r, o, sp, cq, w, pd} M}
    (doctrineLaws : LawfulAdmissiblePredicateDoctrine D)
    (interpretation : RelaxedInterpretation signature L M D)
    (gamma : C.Ctx) :
    ClosedRelaxedContradiction signature gamma ->
    False := by
  intro contradiction
  cases contradiction with
  | intro proof =>
      have environment :
          interpretation.RealizesHypotheses
            (NoRelaxedHypotheses
              (signature := signature)
              (gamma := gamma)) :=
        fun _ impossible => nomatch impossible
      exact
        (relaxedProof_sound
          doctrineLaws
          interpretation
          environment
          proof).elim

end RelaxedSemantics
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.RelaxedSemantics.relaxedProof_sound
#print axioms Meta.RelaxedSemantics.closedRelaxedConsistency
/- AXIOM_AUDIT_END -/
