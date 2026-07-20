import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch40
import Meta.AI.QuantizedCertifiedAgentSemanticBatch36

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch40 : SemanticBatchAlignmentData where
  batch := certifiedBatch40
  refs := [
    { head := .repair, index := 520, inBounds := by decide },
    { head := .repair, index := 519, inBounds := by decide },
    { head := .repair, index := 518, inBounds := by decide },
    { head := .repair, index := 517, inBounds := by decide },
    { head := .repair, index := 516, inBounds := by decide },
    { head := .repair, index := 515, inBounds := by decide },
    { head := .repair, index := 514, inBounds := by decide },
    { head := .repair, index := 513, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch40
/- AXIOM_AUDIT_END -/
