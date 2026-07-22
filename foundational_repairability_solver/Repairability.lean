import Repairability.Abstraction
import Repairability.ActionConflict
import Repairability.CostOptimality
import Repairability.DepthOptimal
import Repairability.LearnedTransfer
import Repairability.LeastFixedPoint
import Repairability.Transcript
import Repairability.Examples.AdaptiveTwoStep
import Repairability.Examples.CostOptimal
import Repairability.Examples.OneStep
import Repairability.Examples.Impossible
import Repairability.Examples.LearnedPacket

namespace Repairability

/-- Version marker for the first constructive executable kernel. -/
def implementationVersion : String := "2.0.0"

/- AXIOM_AUDIT_BEGIN -/
#print axioms Repairability.implementationVersion
/- AXIOM_AUDIT_END -/
