import Meta.AI.QuantizedCertifiedAgentGapWeights
import Meta.AI.QuantizedCertifiedAgentUseWeights
import Meta.AI.QuantizedCertifiedAgentTransportWeights
import Meta.AI.QuantizedCertifiedAgentQueryWeights
import Meta.AI.QuantizedCertifiedAgentRepairWeights

/-!
# Reified v23 certifiable-agent weights

Generated from `quantized_checkpoint_v23.json` with SHA-256 `16a625dc3638bda0fb24f7ed61b8c7c294c706591dccd160d74e2181f0d344c0`.
-/

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

open Quantized
open FiniteQuantized

def trainingSeed : Nat := 0
def trainingUpdate : Nat := 156

abbrev quantizedModel : QuantizedModel where
  gap := gapHead
  use := useHead
  transport := transportHead
  query := queryHead
  repair := repairHead

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.quantizedModel
/- AXIOM_AUDIT_END -/
