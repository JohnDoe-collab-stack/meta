import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch08
import Meta.AI.QuantizedCertifiedAgentSemanticBatch04

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch08 : SemanticBatchAlignmentData where
  batch := certifiedBatch08
  refs := [
    { head := .transport, index := 4, inBounds := by decide },
    { head := .transport, index := 3, inBounds := by decide },
    { head := .transport, index := 2, inBounds := by decide },
    { head := .transport, index := 1, inBounds := by decide },
    { head := .transport, index := 0, inBounds := by decide },
    { head := .transport, index := 41, inBounds := by decide },
    { head := .transport, index := 40, inBounds := by decide },
    { head := .transport, index := 37, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch08
/- AXIOM_AUDIT_END -/
