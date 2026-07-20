import Meta.AI.QuantizedCertifiedAgentSemanticCore
import Meta.AI.QuantizedCertifiedAgentBatch37
import Meta.AI.QuantizedCertifiedAgentSemanticBatch33

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def certifiedSemanticBatch37 : SemanticBatchAlignmentData where
  batch := certifiedBatch37
  refs := [
    { head := .repair, index := 304, inBounds := by decide },
    { head := .repair, index := 303, inBounds := by decide },
    { head := .repair, index := 302, inBounds := by decide },
    { head := .repair, index := 301, inBounds := by decide },
    { head := .repair, index := 300, inBounds := by decide },
    { head := .repair, index := 299, inBounds := by decide },
    { head := .repair, index := 298, inBounds := by decide },
    { head := .repair, index := 297, inBounds := by decide }
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedSemanticBatch37
/- AXIOM_AUDIT_END -/
