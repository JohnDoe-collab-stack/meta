import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch14
import Meta.AI.QuantizedCertifiedAgentSemanticBatch10

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch14 : SemanticBatchAlignmentData where
  batch := certifiedBatch14
  refs := [
    { head := .query, index := 44, inBounds := by decide },
    { head := .query, index := 43, inBounds := by decide },
    { head := .query, index := 42, inBounds := by decide },
    { head := .query, index := 41, inBounds := by decide },
    { head := .query, index := 40, inBounds := by decide },
    { head := .query, index := 39, inBounds := by decide },
    { head := .query, index := 38, inBounds := by decide },
    { head := .query, index := 37, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch14
/- AXIOM_AUDIT_END -/
