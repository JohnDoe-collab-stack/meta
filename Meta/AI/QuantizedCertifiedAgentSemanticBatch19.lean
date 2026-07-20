import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch19
import Meta.AI.QuantizedCertifiedAgentSemanticBatch15

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch19 : SemanticBatchAlignmentData where
  batch := certifiedBatch19
  refs := [
    { head := .query, index := 72, inBounds := by decide },
    { head := .query, index := 79, inBounds := by decide },
    { head := .query, index := 78, inBounds := by decide },
    { head := .query, index := 77, inBounds := by decide },
    { head := .query, index := 76, inBounds := by decide },
    { head := .query, index := 31, inBounds := by decide },
    { head := .query, index := 30, inBounds := by decide },
    { head := .query, index := 29, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch19
/- AXIOM_AUDIT_END -/
