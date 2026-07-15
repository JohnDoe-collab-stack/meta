import Meta.Core.ProjectiveCore

/-!
# Compatibility facade for referential gaps

Import `Meta.Core.ProjectiveCore` in new code.
-/

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.ContractibleReferentialGap
#print axioms Meta.ClosedStabilityTheorem.StructuralReferentialGap
#print axioms Meta.ClosedStabilityTheorem.OperationalReferentialGap
#print axioms Meta.ClosedStabilityTheorem.structuralGapOfOperationalGap
#print axioms Meta.ClosedStabilityTheorem.structuralGap_not_contractible
#print axioms Meta.ClosedStabilityTheorem.structuralGap_not_informationConserving
#print axioms Meta.ClosedStabilityTheorem.operationalGap_not_contractible
#print axioms Meta.ClosedStabilityTheorem.operationalGap_not_informationConserving
#print axioms Meta.ClosedStabilityTheorem.noProjectiveReconstructionOfOperationalGap
/- AXIOM_AUDIT_END -/
