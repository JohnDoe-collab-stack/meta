import Meta.AI.QuantizedCertifiedAgent

/-!
# Semantic alignment kernel for the quantized G3 certificate

Every exported input is related to a value recomputed by the dependent finite
semantics.  Alignment batches carry exact equalities, not hashes or imported
validity flags.
-/

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

open Quantized
open FiniteQuantized

def semanticInputsFor : HeadKind -> List CertifiedExample
  | .gap => semanticGapInputs
  | .use => semanticUseInputs
  | .transport => semanticTransportInputs
  | .query => semanticQueryInputs
  | .repair => semanticRepairInputs

structure SemanticInputRef where
  head : HeadKind
  index : Nat
  inBounds : index < (semanticInputsFor head).length

def semanticInputOfRef (reference : SemanticInputRef) : CertifiedExample :=
  (semanticInputsFor reference.head).get
    ⟨reference.index, reference.inBounds⟩

structure SemanticBatchAlignmentData where
  batch : CertifiedBatchData quantizedModel
  refs : List SemanticInputRef
  inputs_eq : batch.inputs = refs.map semanticInputOfRef

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.semanticInputsFor
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.semanticInputOfRef
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.SemanticBatchAlignmentData
/- AXIOM_AUDIT_END -/
