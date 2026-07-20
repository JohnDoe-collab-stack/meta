import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch44
import Meta.AI.QuantizedCertifiedAgentSemanticBatch40

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch44 : SemanticBatchAlignmentData where
  batch := certifiedBatch44
  refs := [
    { head := .repair, index := 272, inBounds := by decide },
    { head := .repair, index := 271, inBounds := by decide },
    { head := .repair, index := 270, inBounds := by decide },
    { head := .repair, index := 269, inBounds := by decide },
    { head := .repair, index := 268, inBounds := by decide },
    { head := .repair, index := 267, inBounds := by decide },
    { head := .repair, index := 266, inBounds := by decide },
    { head := .repair, index := 265, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch44
/- AXIOM_AUDIT_END -/
