import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch11
import Meta.AI.QuantizedCertifiedAgentSemanticBatch07

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch11 : SemanticBatchAlignmentData where
  batch := certifiedBatch11
  refs := [
    { head := .query, index := 64, inBounds := by decide },
    { head := .query, index := 63, inBounds := by decide },
    { head := .query, index := 62, inBounds := by decide },
    { head := .query, index := 61, inBounds := by decide },
    { head := .query, index := 60, inBounds := by decide },
    { head := .query, index := 59, inBounds := by decide },
    { head := .query, index := 58, inBounds := by decide },
    { head := .query, index := 57, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch11
/- AXIOM_AUDIT_END -/
