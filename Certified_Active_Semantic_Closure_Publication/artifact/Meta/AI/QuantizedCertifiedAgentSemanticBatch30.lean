import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch30
import Meta.AI.QuantizedCertifiedAgentSemanticBatch26

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch30 : SemanticBatchAlignmentData where
  batch := certifiedBatch30
  refs := [
    { head := .repair, index := 360, inBounds := by decide },
    { head := .repair, index := 359, inBounds := by decide },
    { head := .repair, index := 358, inBounds := by decide },
    { head := .repair, index := 357, inBounds := by decide },
    { head := .repair, index := 356, inBounds := by decide },
    { head := .repair, index := 355, inBounds := by decide },
    { head := .repair, index := 354, inBounds := by decide },
    { head := .repair, index := 353, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch30
/- AXIOM_AUDIT_END -/
