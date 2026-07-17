import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch13
import Meta.AI.QuantizedCertifiedAgentSemanticBatch09

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch13 : SemanticBatchAlignmentData where
  batch := certifiedBatch13
  refs := [
    { head := .query, index := 48, inBounds := by decide },
    { head := .query, index := 87, inBounds := by decide },
    { head := .query, index := 86, inBounds := by decide },
    { head := .query, index := 85, inBounds := by decide },
    { head := .query, index := 84, inBounds := by decide },
    { head := .query, index := 47, inBounds := by decide },
    { head := .query, index := 46, inBounds := by decide },
    { head := .query, index := 45, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch13
/- AXIOM_AUDIT_END -/
