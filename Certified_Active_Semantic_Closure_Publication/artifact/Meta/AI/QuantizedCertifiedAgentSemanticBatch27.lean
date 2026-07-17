import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch27
import Meta.AI.QuantizedCertifiedAgentSemanticBatch23

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch27 : SemanticBatchAlignmentData where
  batch := certifiedBatch27
  refs := [
    { head := .repair, index := 384, inBounds := by decide },
    { head := .repair, index := 383, inBounds := by decide },
    { head := .repair, index := 382, inBounds := by decide },
    { head := .repair, index := 381, inBounds := by decide },
    { head := .repair, index := 380, inBounds := by decide },
    { head := .repair, index := 379, inBounds := by decide },
    { head := .repair, index := 378, inBounds := by decide },
    { head := .repair, index := 377, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch27
/- AXIOM_AUDIT_END -/
