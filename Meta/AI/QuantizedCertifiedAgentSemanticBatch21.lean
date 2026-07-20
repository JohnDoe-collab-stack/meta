import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch21
import Meta.AI.QuantizedCertifiedAgentSemanticBatch17

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch21 : SemanticBatchAlignmentData where
  batch := certifiedBatch21
  refs := [
    { head := .query, index := 20, inBounds := by decide },
    { head := .repair, index := 431, inBounds := by decide },
    { head := .repair, index := 430, inBounds := by decide },
    { head := .repair, index := 429, inBounds := by decide },
    { head := .repair, index := 428, inBounds := by decide },
    { head := .repair, index := 427, inBounds := by decide },
    { head := .repair, index := 426, inBounds := by decide },
    { head := .repair, index := 425, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch21
/- AXIOM_AUDIT_END -/
