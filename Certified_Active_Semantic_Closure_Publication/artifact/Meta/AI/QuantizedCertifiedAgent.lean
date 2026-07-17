import Meta.AI.QuantizedCertifiedAgentBatch84
import Meta.AI.QuantizedCertifiedAgentBatch85
import Meta.AI.QuantizedCertifiedAgentBatch86
import Meta.AI.QuantizedCertifiedAgentBatch87

/-!
# Exhaustively certified v23 quantized agent

Every batch module recomputes its affine maps, Int32 bounds, ties-to-even
rounding, Int8 saturation, reserved-class masks, canonical argmax and expected
finite decisions. The run below is their exact concatenation. No JSON verdict
is imported as a proposition.
-/

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

open Quantized
open FiniteQuantized

abbrev certifiedBatches : List (CertifiedBatchData quantizedModel) :=
  [certifiedBatch00, certifiedBatch01, certifiedBatch02, certifiedBatch03, certifiedBatch04, certifiedBatch05, certifiedBatch06, certifiedBatch07, certifiedBatch08, certifiedBatch09, certifiedBatch10, certifiedBatch11, certifiedBatch12, certifiedBatch13, certifiedBatch14, certifiedBatch15, certifiedBatch16, certifiedBatch17, certifiedBatch18, certifiedBatch19, certifiedBatch20, certifiedBatch21, certifiedBatch22, certifiedBatch23, certifiedBatch24, certifiedBatch25, certifiedBatch26, certifiedBatch27, certifiedBatch28, certifiedBatch29, certifiedBatch30, certifiedBatch31, certifiedBatch32, certifiedBatch33, certifiedBatch34, certifiedBatch35, certifiedBatch36, certifiedBatch37, certifiedBatch38, certifiedBatch39, certifiedBatch40, certifiedBatch41, certifiedBatch42, certifiedBatch43, certifiedBatch44, certifiedBatch45, certifiedBatch46, certifiedBatch47, certifiedBatch48, certifiedBatch49, certifiedBatch50, certifiedBatch51, certifiedBatch52, certifiedBatch53, certifiedBatch54, certifiedBatch55, certifiedBatch56, certifiedBatch57, certifiedBatch58, certifiedBatch59, certifiedBatch60, certifiedBatch61, certifiedBatch62, certifiedBatch63, certifiedBatch64, certifiedBatch65, certifiedBatch66, certifiedBatch67, certifiedBatch68, certifiedBatch69, certifiedBatch70, certifiedBatch71, certifiedBatch72, certifiedBatch73, certifiedBatch74, certifiedBatch75, certifiedBatch76, certifiedBatch77, certifiedBatch78, certifiedBatch79, certifiedBatch80, certifiedBatch81, certifiedBatch82, certifiedBatch83, certifiedBatch84, certifiedBatch85, certifiedBatch86, certifiedBatch87]

abbrev exhaustiveCertifiedInputs : List CertifiedExample :=
  certifiedBatches.flatMap fun batch => batch.inputs

abbrev certifiedRawTrace : RawTrace :=
  certifiedBatches.flatMap fun batch => batch.rawTrace

def validCertifiedRun :
    ValidCertifiedRun certifiableArchitecture quantizedModel
      exhaustiveCertifiedInputs certifiedRawTrace := by
  refine
    { architectureValid := ?_
      batches := certifiedBatches
      inputs_eq := rfl
      rawTrace_eq := rfl
      nonempty := ?_ }
  · decide
  · intro equality
    cases equality

theorem quantizedAgent_zeroError :
    ∀ batch ∈ certifiedBatches,
      traceZeroErrorB batch.rawTrace = true := by
  intro batch _membership
  exact batch.certificate.traceValid.1

theorem quantizedAgent_strictMargins :
    ∀ batch ∈ certifiedBatches,
      traceStrictB batch.rawTrace = true := by
  intro batch _membership
  exact batch.certificate.traceValid.2

theorem exhaustiveCertifiedInputs_count :
    exhaustiveCertifiedInputs.length = 697 := by
  decide

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.quantizedModel
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.exhaustiveCertifiedInputs
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.certifiedRawTrace
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.validCertifiedRun
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.quantizedAgent_zeroError
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.quantizedAgent_strictMargins
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.exhaustiveCertifiedInputs_count
/- AXIOM_AUDIT_END -/
