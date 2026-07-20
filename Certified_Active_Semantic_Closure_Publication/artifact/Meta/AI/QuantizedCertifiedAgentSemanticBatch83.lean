import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch83
import Meta.AI.QuantizedCertifiedAgentSemanticBatch79

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch83 : SemanticBatchAlignmentData where
  batch := certifiedBatch83
  refs := [
    { head := .repair, index := 152, inBounds := by decide },
    { head := .repair, index := 151, inBounds := by decide },
    { head := .repair, index := 150, inBounds := by decide },
    { head := .repair, index := 149, inBounds := by decide },
    { head := .repair, index := 148, inBounds := by decide },
    { head := .repair, index := 147, inBounds := by decide },
    { head := .repair, index := 146, inBounds := by decide },
    { head := .repair, index := 145, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch83
/- AXIOM_AUDIT_END -/
