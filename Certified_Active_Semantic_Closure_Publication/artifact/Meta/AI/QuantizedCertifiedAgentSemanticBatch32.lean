import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch32
import Meta.AI.QuantizedCertifiedAgentSemanticBatch28

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch32 : SemanticBatchAlignmentData where
  batch := certifiedBatch32
  refs := [
    { head := .repair, index := 344, inBounds := by decide },
    { head := .repair, index := 343, inBounds := by decide },
    { head := .repair, index := 342, inBounds := by decide },
    { head := .repair, index := 341, inBounds := by decide },
    { head := .repair, index := 340, inBounds := by decide },
    { head := .repair, index := 339, inBounds := by decide },
    { head := .repair, index := 338, inBounds := by decide },
    { head := .repair, index := 337, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch32
/- AXIOM_AUDIT_END -/
