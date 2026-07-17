import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch28
import Meta.AI.QuantizedCertifiedAgentSemanticBatch24

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch28 : SemanticBatchAlignmentData where
  batch := certifiedBatch28
  refs := [
    { head := .repair, index := 376, inBounds := by decide },
    { head := .repair, index := 375, inBounds := by decide },
    { head := .repair, index := 374, inBounds := by decide },
    { head := .repair, index := 373, inBounds := by decide },
    { head := .repair, index := 372, inBounds := by decide },
    { head := .repair, index := 371, inBounds := by decide },
    { head := .repair, index := 370, inBounds := by decide },
    { head := .repair, index := 369, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch28
/- AXIOM_AUDIT_END -/
