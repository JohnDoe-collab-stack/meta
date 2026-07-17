import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch02

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch02 : SemanticBatchAlignmentData where
  batch := certifiedBatch02
  refs := [
    { head := .use, index := 16, inBounds := by decide },
    { head := .use, index := 15, inBounds := by decide },
    { head := .use, index := 14, inBounds := by decide },
    { head := .use, index := 13, inBounds := by decide },
    { head := .use, index := 12, inBounds := by decide },
    { head := .use, index := 21, inBounds := by decide },
    { head := .use, index := 11, inBounds := by decide },
    { head := .use, index := 10, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch02
/- AXIOM_AUDIT_END -/
