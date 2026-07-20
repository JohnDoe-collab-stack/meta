import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch81
import Meta.AI.QuantizedCertifiedAgentSemanticBatch77

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch81 : SemanticBatchAlignmentData where
  batch := certifiedBatch81
  refs := [
    { head := .repair, index := 168, inBounds := by decide },
    { head := .repair, index := 167, inBounds := by decide },
    { head := .repair, index := 166, inBounds := by decide },
    { head := .repair, index := 165, inBounds := by decide },
    { head := .repair, index := 164, inBounds := by decide },
    { head := .repair, index := 163, inBounds := by decide },
    { head := .repair, index := 162, inBounds := by decide },
    { head := .repair, index := 161, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch81
/- AXIOM_AUDIT_END -/
