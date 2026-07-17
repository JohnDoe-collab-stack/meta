import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch77
import Meta.AI.QuantizedCertifiedAgentSemanticBatch73

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch77 : SemanticBatchAlignmentData where
  batch := certifiedBatch77
  refs := [
    { head := .repair, index := 464, inBounds := by decide },
    { head := .repair, index := 463, inBounds := by decide },
    { head := .repair, index := 462, inBounds := by decide },
    { head := .repair, index := 461, inBounds := by decide },
    { head := .repair, index := 460, inBounds := by decide },
    { head := .repair, index := 459, inBounds := by decide },
    { head := .repair, index := 458, inBounds := by decide },
    { head := .repair, index := 457, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch77
/- AXIOM_AUDIT_END -/
