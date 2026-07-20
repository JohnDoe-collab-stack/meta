import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch03

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch03 : SemanticBatchAlignmentData where
  batch := certifiedBatch03
  refs := [
    { head := .use, index := 9, inBounds := by decide },
    { head := .use, index := 8, inBounds := by decide },
    { head := .use, index := 4, inBounds := by decide },
    { head := .use, index := 3, inBounds := by decide },
    { head := .use, index := 2, inBounds := by decide },
    { head := .use, index := 1, inBounds := by decide },
    { head := .use, index := 0, inBounds := by decide },
    { head := .use, index := 20, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch03
/- AXIOM_AUDIT_END -/
