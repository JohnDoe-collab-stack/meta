import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch66
import Meta.AI.QuantizedCertifiedAgentSemanticBatch62

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch66 : SemanticBatchAlignmentData where
  batch := certifiedBatch66
  refs := [
    { head := .repair, index := 24, inBounds := by decide },
    { head := .repair, index := 23, inBounds := by decide },
    { head := .repair, index := 22, inBounds := by decide },
    { head := .repair, index := 21, inBounds := by decide },
    { head := .repair, index := 20, inBounds := by decide },
    { head := .repair, index := 19, inBounds := by decide },
    { head := .repair, index := 18, inBounds := by decide },
    { head := .repair, index := 17, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch66
/- AXIOM_AUDIT_END -/
