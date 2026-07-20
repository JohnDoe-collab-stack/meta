import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch20
import Meta.AI.QuantizedCertifiedAgentSemanticBatch16

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch20 : SemanticBatchAlignmentData where
  batch := certifiedBatch20
  refs := [
    { head := .query, index := 28, inBounds := by decide },
    { head := .query, index := 27, inBounds := by decide },
    { head := .query, index := 26, inBounds := by decide },
    { head := .query, index := 25, inBounds := by decide },
    { head := .query, index := 24, inBounds := by decide },
    { head := .query, index := 23, inBounds := by decide },
    { head := .query, index := 22, inBounds := by decide },
    { head := .query, index := 21, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch20
/- AXIOM_AUDIT_END -/
