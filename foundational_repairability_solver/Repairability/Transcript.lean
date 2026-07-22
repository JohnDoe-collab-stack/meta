import Repairability.ExactPosterior

namespace Repairability.PublicGame

/-- A public, certified interaction history from `initial` to `final`. -/
inductive CertifiedTranscript (E : PublicGame) (g : E.Goal) :
    E.State → E.State → Type
  | nil (s : E.State) : CertifiedTranscript E g s s
  | step {initial current : E.State}
      (history : CertifiedTranscript E g initial current)
      (q : E.Query) (r : E.Response)
      (authorized : Authorized E current g q)
      (realizable : Realizable E current q r) :
      CertifiedTranscript E g initial (E.advance current g q r)

def TranscriptMatches {E : PublicGame} {g : E.Goal} {initial final : E.State}
    (transcript : CertifiedTranscript E g initial final) (w : E.World) : Prop :=
  match transcript with
  | .nil _ => True
  | .step history q r _ _ =>
      TranscriptMatches history w ∧ E.respond w q = r

theorem exactTranscript_iff
    (E : PublicGame) (X : ExactPosteriorCompiler E) (g : E.Goal)
    {initial final : E.State}
    (transcript : CertifiedTranscript E g initial final) (w : E.World) :
    Compatible E final w ↔
      Compatible E initial w ∧ TranscriptMatches transcript w := by
  induction transcript with
  | nil =>
      constructor
      · intro h
        exact ⟨h, True.intro⟩
      · intro h
        exact h.1
  | @step current history q r ha hr ih =>
      constructor
      · intro hfinal
        have hlocal := (exactPosterior_iff E X current g q r ha hr w).mp hfinal
        have hhistory := ih.mp hlocal.1
        exact ⟨hhistory.1, ⟨hhistory.2, hlocal.2⟩⟩
      · intro hfull
        have hcurrent : Compatible E current w :=
          ih.mpr ⟨hfull.1, hfull.2.1⟩
        exact (exactPosterior_iff E X current g q r ha hr w).mpr
          ⟨hcurrent, hfull.2.2⟩

theorem transcript_retains_matching_world
    (E : PublicGame) (X : ExactPosteriorCompiler E) (g : E.Goal)
    {initial final : E.State}
    (transcript : CertifiedTranscript E g initial final) (w : E.World)
    (hinitial : Compatible E initial w)
    (hmatches : TranscriptMatches transcript w) :
    Compatible E final w :=
  (exactTranscript_iff E X g transcript w).mpr ⟨hinitial, hmatches⟩

theorem transcript_eliminates_mismatch
    (E : PublicGame) (X : ExactPosteriorCompiler E) (g : E.Goal)
    {initial final : E.State}
    (transcript : CertifiedTranscript E g initial final) (w : E.World)
    (hmismatch : ¬ TranscriptMatches transcript w) :
    ¬ Compatible E final w := by
  intro hfinal
  exact hmismatch ((exactTranscript_iff E X g transcript w).mp hfinal).2

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.PublicGame.exactTranscript_iff
#print axioms Repairability.PublicGame.transcript_retains_matching_world
#print axioms Repairability.PublicGame.transcript_eliminates_mismatch
/- AXIOM_AUDIT_END -/
