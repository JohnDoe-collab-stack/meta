import Meta.LatentRepair.ProblemResolutionAudit

/-!
Standalone entry point for the certified active-semantic-closure publication
artifact.
-/

def certifiedActiveSemanticClosurePublication :
    Meta.ActiveSemanticClosure.LatentRepair.CertifiedLatentRepairPublication :=
  Meta.ActiveSemanticClosure.LatentRepair.certifiedLatentRepairPublication

/- AXIOM_AUDIT_BEGIN -/
#print axioms certifiedActiveSemanticClosurePublication
/- AXIOM_AUDIT_END -/
