import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch35
import Meta.AI.QuantizedCertifiedAgentSemanticBatch31

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch35 : SemanticBatchAlignmentData where
  batch := certifiedBatch35
  refs := [
    { head := .repair, index := 320, inBounds := by decide },
    { head := .repair, index := 319, inBounds := by decide },
    { head := .repair, index := 318, inBounds := by decide },
    { head := .repair, index := 317, inBounds := by decide },
    { head := .repair, index := 316, inBounds := by decide },
    { head := .repair, index := 315, inBounds := by decide },
    { head := .repair, index := 314, inBounds := by decide },
    { head := .repair, index := 313, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch35
/- AXIOM_AUDIT_END -/
