import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch00

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch00 : SemanticBatchAlignmentData where
  batch := certifiedBatch00
  refs := [
    { head := .gap, index := 12, inBounds := by decide },
    { head := .gap, index := 11, inBounds := by decide },
    { head := .gap, index := 10, inBounds := by decide },
    { head := .gap, index := 9, inBounds := by decide },
    { head := .gap, index := 8, inBounds := by decide },
    { head := .gap, index := 14, inBounds := by decide },
    { head := .gap, index := 7, inBounds := by decide },
    { head := .gap, index := 6, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch00
/- AXIOM_AUDIT_END -/
