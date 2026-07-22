import Repairability.FixedPoint

namespace Repairability.PublicGame

/-- Exactness is an additional completeness law over the safe game update. -/
structure ExactPosteriorCompiler (E : PublicGame) where
  responseExact :
    ∀ s g q r w,
      Authorized E s g q →
      Realizable E s q r →
      Compatible E (E.advance s g q r) w →
      E.respond w q = r

theorem exactPosterior_iff
    (E : PublicGame) (X : ExactPosteriorCompiler E)
    (s : E.State) (g : E.Goal) (q : E.Query) (r : E.Response)
    (ha : Authorized E s g q) (hr : Realizable E s q r) (w : E.World) :
    Compatible E (E.advance s g q r) w ↔
      Compatible E s w ∧ E.respond w q = r := by
  constructor
  · intro hafter
    exact ⟨E.fiberMonotone s g q r w ha hr hafter,
      X.responseExact s g q r w ha hr hafter⟩
  · rintro ⟨hbefore, hresponse⟩
    exact E.posteriorContains s g q r w ha hbefore hresponse

theorem exactPosterior_retains_actual
    (E : PublicGame) (_X : ExactPosteriorCompiler E)
    (s : E.State) (g : E.Goal) (q : E.Query) (w : E.World)
    (ha : Authorized E s g q) (hw : Compatible E s w) :
    Compatible E (E.advance s g q (E.respond w q)) w := by
  exact E.posteriorContains s g q (E.respond w q) w ha hw rfl

theorem exactPosterior_eliminates_other_response
    (E : PublicGame) (X : ExactPosteriorCompiler E)
    (s : E.State) (g : E.Goal) (q : E.Query) (r : E.Response)
    (ha : Authorized E s g q) (hr : Realizable E s q r)
    (w : E.World) (hneq : E.respond w q ≠ r) :
    ¬ Compatible E (E.advance s g q r) w := by
  intro hafter
  exact hneq (X.responseExact s g q r w ha hr hafter)

theorem exactTarget_decision_correct
    (E : PublicGame) (_X : ExactPosteriorCompiler E)
    (s : E.State) (g : E.Goal)
    (htarget : CertifiedTarget E s g) :
    ∃ a, E.decision? s g = some a ∧
      ∀ w, Compatible E s w → E.required g w = a := by
  exact htarget.2.2

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.exactPosterior_iff
#print axioms Repairability.PublicGame.exactPosterior_retains_actual
#print axioms Repairability.PublicGame.exactPosterior_eliminates_other_response
/- AXIOM_AUDIT_END -/
