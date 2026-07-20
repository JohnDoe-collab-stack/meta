import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch17
import Meta.AI.QuantizedCertifiedAgentSemanticBatch13

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch17 : SemanticBatchAlignmentData where
  batch := certifiedBatch17
  refs := [
    { head := .query, index := 8, inBounds := by decide },
    { head := .query, index := 7, inBounds := by decide },
    { head := .query, index := 6, inBounds := by decide },
    { head := .query, index := 5, inBounds := by decide },
    { head := .query, index := 4, inBounds := by decide },
    { head := .query, index := 3, inBounds := by decide },
    { head := .query, index := 2, inBounds := by decide },
    { head := .query, index := 1, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch17
/- AXIOM_AUDIT_END -/
