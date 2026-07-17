import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch80
import Meta.AI.QuantizedCertifiedAgentSemanticBatch76

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch80 : SemanticBatchAlignmentData where
  batch := certifiedBatch80
  refs := [
    { head := .repair, index := 176, inBounds := by decide },
    { head := .repair, index := 175, inBounds := by decide },
    { head := .repair, index := 174, inBounds := by decide },
    { head := .repair, index := 173, inBounds := by decide },
    { head := .repair, index := 172, inBounds := by decide },
    { head := .repair, index := 171, inBounds := by decide },
    { head := .repair, index := 170, inBounds := by decide },
    { head := .repair, index := 169, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch80
/- AXIOM_AUDIT_END -/
