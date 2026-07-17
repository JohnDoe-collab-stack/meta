import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch64
import Meta.AI.QuantizedCertifiedAgentSemanticBatch60

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch64 : SemanticBatchAlignmentData where
  batch := certifiedBatch64
  refs := [
    { head := .repair, index := 40, inBounds := by decide },
    { head := .repair, index := 39, inBounds := by decide },
    { head := .repair, index := 38, inBounds := by decide },
    { head := .repair, index := 37, inBounds := by decide },
    { head := .repair, index := 36, inBounds := by decide },
    { head := .repair, index := 35, inBounds := by decide },
    { head := .repair, index := 34, inBounds := by decide },
    { head := .repair, index := 33, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch64
/- AXIOM_AUDIT_END -/
