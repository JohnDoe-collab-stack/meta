import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch65
import Meta.AI.QuantizedCertifiedAgentSemanticBatch61

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch65 : SemanticBatchAlignmentData where
  batch := certifiedBatch65
  refs := [
    { head := .repair, index := 32, inBounds := by decide },
    { head := .repair, index := 31, inBounds := by decide },
    { head := .repair, index := 30, inBounds := by decide },
    { head := .repair, index := 29, inBounds := by decide },
    { head := .repair, index := 28, inBounds := by decide },
    { head := .repair, index := 27, inBounds := by decide },
    { head := .repair, index := 26, inBounds := by decide },
    { head := .repair, index := 25, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch65
/- AXIOM_AUDIT_END -/
