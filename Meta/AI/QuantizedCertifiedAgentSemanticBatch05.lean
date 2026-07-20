import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch05
import Meta.AI.QuantizedCertifiedAgentSemanticBatch01

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch05 : SemanticBatchAlignmentData where
  batch := certifiedBatch05
  refs := [
    { head := .transport, index := 32, inBounds := by decide },
    { head := .transport, index := 31, inBounds := by decide },
    { head := .transport, index := 30, inBounds := by decide },
    { head := .transport, index := 29, inBounds := by decide },
    { head := .transport, index := 28, inBounds := by decide },
    { head := .transport, index := 27, inBounds := by decide },
    { head := .transport, index := 26, inBounds := by decide },
    { head := .transport, index := 25, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch05
/- AXIOM_AUDIT_END -/
