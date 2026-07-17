import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch15
import Meta.AI.QuantizedCertifiedAgentSemanticBatch11

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch15 : SemanticBatchAlignmentData where
  batch := certifiedBatch15
  refs := [
    { head := .query, index := 36, inBounds := by decide },
    { head := .query, index := 35, inBounds := by decide },
    { head := .query, index := 34, inBounds := by decide },
    { head := .query, index := 33, inBounds := by decide },
    { head := .query, index := 32, inBounds := by decide },
    { head := .query, index := 19, inBounds := by decide },
    { head := .query, index := 18, inBounds := by decide },
    { head := .query, index := 17, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch15
/- AXIOM_AUDIT_END -/
