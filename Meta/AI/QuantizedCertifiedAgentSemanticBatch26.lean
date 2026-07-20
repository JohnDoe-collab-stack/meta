import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch26
import Meta.AI.QuantizedCertifiedAgentSemanticBatch22

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch26 : SemanticBatchAlignmentData where
  batch := certifiedBatch26
  refs := [
    { head := .repair, index := 392, inBounds := by decide },
    { head := .repair, index := 391, inBounds := by decide },
    { head := .repair, index := 390, inBounds := by decide },
    { head := .repair, index := 389, inBounds := by decide },
    { head := .repair, index := 388, inBounds := by decide },
    { head := .repair, index := 387, inBounds := by decide },
    { head := .repair, index := 386, inBounds := by decide },
    { head := .repair, index := 385, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch26
/- AXIOM_AUDIT_END -/
