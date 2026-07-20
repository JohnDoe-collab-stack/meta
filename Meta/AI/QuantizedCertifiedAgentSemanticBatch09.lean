import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch09
import Meta.AI.QuantizedCertifiedAgentSemanticBatch05

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch09 : SemanticBatchAlignmentData where
  batch := certifiedBatch09
  refs := [
    { head := .transport, index := 36, inBounds := by decide },
    { head := .transport, index := 39, inBounds := by decide },
    { head := .transport, index := 38, inBounds := by decide },
    { head := .transport, index := 15, inBounds := by decide },
    { head := .transport, index := 14, inBounds := by decide },
    { head := .transport, index := 13, inBounds := by decide },
    { head := .transport, index := 12, inBounds := by decide },
    { head := .transport, index := 11, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch09
/- AXIOM_AUDIT_END -/
