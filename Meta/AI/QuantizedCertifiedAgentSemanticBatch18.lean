import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch18
import Meta.AI.QuantizedCertifiedAgentSemanticBatch14

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch18 : SemanticBatchAlignmentData where
  batch := certifiedBatch18
  refs := [
    { head := .query, index := 0, inBounds := by decide },
    { head := .query, index := 83, inBounds := by decide },
    { head := .query, index := 82, inBounds := by decide },
    { head := .query, index := 81, inBounds := by decide },
    { head := .query, index := 80, inBounds := by decide },
    { head := .query, index := 75, inBounds := by decide },
    { head := .query, index := 74, inBounds := by decide },
    { head := .query, index := 73, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch18
/- AXIOM_AUDIT_END -/
