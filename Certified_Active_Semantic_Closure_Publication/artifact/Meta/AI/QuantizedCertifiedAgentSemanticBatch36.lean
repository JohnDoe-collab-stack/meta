import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch36
import Meta.AI.QuantizedCertifiedAgentSemanticBatch32

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch36 : SemanticBatchAlignmentData where
  batch := certifiedBatch36
  refs := [
    { head := .repair, index := 312, inBounds := by decide },
    { head := .repair, index := 311, inBounds := by decide },
    { head := .repair, index := 310, inBounds := by decide },
    { head := .repair, index := 309, inBounds := by decide },
    { head := .repair, index := 308, inBounds := by decide },
    { head := .repair, index := 307, inBounds := by decide },
    { head := .repair, index := 306, inBounds := by decide },
    { head := .repair, index := 305, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch36
/- AXIOM_AUDIT_END -/
