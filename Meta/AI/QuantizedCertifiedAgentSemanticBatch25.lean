import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch25
import Meta.AI.QuantizedCertifiedAgentSemanticBatch21

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch25 : SemanticBatchAlignmentData where
  batch := certifiedBatch25
  refs := [
    { head := .repair, index := 400, inBounds := by decide },
    { head := .repair, index := 399, inBounds := by decide },
    { head := .repair, index := 398, inBounds := by decide },
    { head := .repair, index := 397, inBounds := by decide },
    { head := .repair, index := 396, inBounds := by decide },
    { head := .repair, index := 395, inBounds := by decide },
    { head := .repair, index := 394, inBounds := by decide },
    { head := .repair, index := 393, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch25
/- AXIOM_AUDIT_END -/
