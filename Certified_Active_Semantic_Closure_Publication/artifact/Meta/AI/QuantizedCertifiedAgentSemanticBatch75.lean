import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch75
import Meta.AI.QuantizedCertifiedAgentSemanticBatch71

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch75 : SemanticBatchAlignmentData where
  batch := certifiedBatch75
  refs := [
    { head := .repair, index := 432, inBounds := by decide },
    { head := .repair, index := 479, inBounds := by decide },
    { head := .repair, index := 478, inBounds := by decide },
    { head := .repair, index := 477, inBounds := by decide },
    { head := .repair, index := 476, inBounds := by decide },
    { head := .repair, index := 475, inBounds := by decide },
    { head := .repair, index := 474, inBounds := by decide },
    { head := .repair, index := 473, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch75
/- AXIOM_AUDIT_END -/
