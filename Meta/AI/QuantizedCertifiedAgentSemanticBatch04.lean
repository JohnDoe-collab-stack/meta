import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch04
import Meta.AI.QuantizedCertifiedAgentSemanticBatch00

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch04 : SemanticBatchAlignmentData where
  batch := certifiedBatch04
  refs := [
    { head := .use, index := 18, inBounds := by decide },
    { head := .use, index := 19, inBounds := by decide },
    { head := .use, index := 7, inBounds := by decide },
    { head := .use, index := 6, inBounds := by decide },
    { head := .use, index := 5, inBounds := by decide },
    { head := .transport, index := 35, inBounds := by decide },
    { head := .transport, index := 34, inBounds := by decide },
    { head := .transport, index := 33, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch04
/- AXIOM_AUDIT_END -/
