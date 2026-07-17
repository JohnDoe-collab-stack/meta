import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch38
import Meta.AI.QuantizedCertifiedAgentSemanticBatch34

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch38 : SemanticBatchAlignmentData where
  batch := certifiedBatch38
  refs := [
    { head := .repair, index := 296, inBounds := by decide },
    { head := .repair, index := 295, inBounds := by decide },
    { head := .repair, index := 294, inBounds := by decide },
    { head := .repair, index := 293, inBounds := by decide },
    { head := .repair, index := 292, inBounds := by decide },
    { head := .repair, index := 291, inBounds := by decide },
    { head := .repair, index := 290, inBounds := by decide },
    { head := .repair, index := 289, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch38
/- AXIOM_AUDIT_END -/
