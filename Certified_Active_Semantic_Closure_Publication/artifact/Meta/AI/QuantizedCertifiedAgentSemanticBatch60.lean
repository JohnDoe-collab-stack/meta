import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch60
import Meta.AI.QuantizedCertifiedAgentSemanticBatch56

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch60 : SemanticBatchAlignmentData where
  batch := certifiedBatch60
  refs := [
    { head := .repair, index := 72, inBounds := by decide },
    { head := .repair, index := 71, inBounds := by decide },
    { head := .repair, index := 70, inBounds := by decide },
    { head := .repair, index := 69, inBounds := by decide },
    { head := .repair, index := 68, inBounds := by decide },
    { head := .repair, index := 67, inBounds := by decide },
    { head := .repair, index := 66, inBounds := by decide },
    { head := .repair, index := 65, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch60
/- AXIOM_AUDIT_END -/
