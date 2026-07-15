import Meta.Core.DynamicCore

/-!
# Compatibility facade for dynamic stability

Import `Meta.Core.DynamicCore` in new code.
-/

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ClosedStabilityTheorem.FormedDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.TemporalExcessDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.LocallyRecoveredDynamicReturn
#print axioms Meta.ClosedStabilityTheorem.locallyRecoveredClosedStabilityOfDynamicReturn
/- AXIOM_AUDIT_END -/
