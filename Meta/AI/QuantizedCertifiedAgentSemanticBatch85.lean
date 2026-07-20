import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch85
import Meta.AI.QuantizedCertifiedAgentSemanticBatch81

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch85 : SemanticBatchAlignmentData where
  batch := certifiedBatch85
  refs := [
    { head := .repair, index := 136, inBounds := by decide },
    { head := .repair, index := 135, inBounds := by decide },
    { head := .repair, index := 134, inBounds := by decide },
    { head := .repair, index := 133, inBounds := by decide },
    { head := .repair, index := 132, inBounds := by decide },
    { head := .repair, index := 131, inBounds := by decide },
    { head := .repair, index := 130, inBounds := by decide },
    { head := .repair, index := 129, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch85
/- AXIOM_AUDIT_END -/
