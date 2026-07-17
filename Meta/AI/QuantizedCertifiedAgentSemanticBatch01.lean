import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch01

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch01 : SemanticBatchAlignmentData where
  batch := certifiedBatch01
  refs := [
    { head := .gap, index := 5, inBounds := by decide },
    { head := .gap, index := 3, inBounds := by decide },
    { head := .gap, index := 2, inBounds := by decide },
    { head := .gap, index := 1, inBounds := by decide },
    { head := .gap, index := 0, inBounds := by decide },
    { head := .gap, index := 13, inBounds := by decide },
    { head := .gap, index := 4, inBounds := by decide },
    { head := .use, index := 17, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch01
/- AXIOM_AUDIT_END -/
