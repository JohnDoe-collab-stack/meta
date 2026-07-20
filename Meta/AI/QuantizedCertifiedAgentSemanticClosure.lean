import Meta.AI.QuantizedCertifiedAgentSemanticBatch84
import Meta.AI.QuantizedCertifiedAgentSemanticBatch85
import Meta.AI.QuantizedCertifiedAgentSemanticBatch86
import Meta.AI.QuantizedCertifiedAgentSemanticBatch87

/-!
# Intrinsic semantic closure of the quantized G3 certificate

Every inference batch is aligned with examples computed by the dependent
finite Lean semantics.  The aggregate reference list covers each semantic
head exactly, without omission or duplication.
-/

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

open Quantized
open FiniteQuantized

abbrev semanticBatchAlignments : List SemanticBatchAlignmentData :=
  [certifiedSemanticBatch00, certifiedSemanticBatch01, certifiedSemanticBatch02, certifiedSemanticBatch03, certifiedSemanticBatch04, certifiedSemanticBatch05, certifiedSemanticBatch06, certifiedSemanticBatch07, certifiedSemanticBatch08, certifiedSemanticBatch09, certifiedSemanticBatch10, certifiedSemanticBatch11, certifiedSemanticBatch12, certifiedSemanticBatch13, certifiedSemanticBatch14, certifiedSemanticBatch15, certifiedSemanticBatch16, certifiedSemanticBatch17, certifiedSemanticBatch18, certifiedSemanticBatch19, certifiedSemanticBatch20, certifiedSemanticBatch21, certifiedSemanticBatch22, certifiedSemanticBatch23, certifiedSemanticBatch24, certifiedSemanticBatch25, certifiedSemanticBatch26, certifiedSemanticBatch27, certifiedSemanticBatch28, certifiedSemanticBatch29, certifiedSemanticBatch30, certifiedSemanticBatch31, certifiedSemanticBatch32, certifiedSemanticBatch33, certifiedSemanticBatch34, certifiedSemanticBatch35, certifiedSemanticBatch36, certifiedSemanticBatch37, certifiedSemanticBatch38, certifiedSemanticBatch39, certifiedSemanticBatch40, certifiedSemanticBatch41, certifiedSemanticBatch42, certifiedSemanticBatch43, certifiedSemanticBatch44, certifiedSemanticBatch45, certifiedSemanticBatch46, certifiedSemanticBatch47, certifiedSemanticBatch48, certifiedSemanticBatch49, certifiedSemanticBatch50, certifiedSemanticBatch51, certifiedSemanticBatch52, certifiedSemanticBatch53, certifiedSemanticBatch54, certifiedSemanticBatch55, certifiedSemanticBatch56, certifiedSemanticBatch57, certifiedSemanticBatch58, certifiedSemanticBatch59, certifiedSemanticBatch60, certifiedSemanticBatch61, certifiedSemanticBatch62, certifiedSemanticBatch63, certifiedSemanticBatch64, certifiedSemanticBatch65, certifiedSemanticBatch66, certifiedSemanticBatch67, certifiedSemanticBatch68, certifiedSemanticBatch69, certifiedSemanticBatch70, certifiedSemanticBatch71, certifiedSemanticBatch72, certifiedSemanticBatch73, certifiedSemanticBatch74, certifiedSemanticBatch75, certifiedSemanticBatch76, certifiedSemanticBatch77, certifiedSemanticBatch78, certifiedSemanticBatch79, certifiedSemanticBatch80, certifiedSemanticBatch81, certifiedSemanticBatch82, certifiedSemanticBatch83, certifiedSemanticBatch84, certifiedSemanticBatch85, certifiedSemanticBatch86, certifiedSemanticBatch87]

abbrev alignedCertifiedBatches : List (CertifiedBatchData quantizedModel) :=
  semanticBatchAlignments.map fun alignment => alignment.batch

abbrev exhaustiveSemanticRefs : List SemanticInputRef :=
  semanticBatchAlignments.flatMap fun alignment => alignment.refs

def semanticIndicesFor (head : HeadKind) : List Nat :=
  exhaustiveSemanticRefs.filterMap fun reference =>
    if reference.head = head then some reference.index else none

def natMemberB (target : Nat) : List Nat -> Bool
  | [] => false
  | head :: tail => (target == head) || natMemberB target tail

structure SemanticHeadCoverage (head : HeadKind) (count : Nat) : Prop where
  semanticLength : (semanticInputsFor head).length = count
  referenceLength : (semanticIndicesFor head).length = count
  referencesNodup : (semanticIndicesFor head).Nodup
  referencesComplete :
    (List.range count).all
      (fun index => natMemberB index (semanticIndicesFor head)) = true

def gapSemanticCoverage : SemanticHeadCoverage .gap 15 := by
  constructor <;> decide

def useSemanticCoverage : SemanticHeadCoverage .use 22 := by
  constructor <;> decide

def transportSemanticCoverage : SemanticHeadCoverage .transport 44 := by
  constructor <;> decide

def querySemanticCoverage : SemanticHeadCoverage .query 88 := by
  constructor <;> decide

def repairSemanticCoverage : SemanticHeadCoverage .repair 528 := by
  constructor <;> decide

theorem alignedCertifiedBatches_eq :
    alignedCertifiedBatches = certifiedBatches := by
  rfl

structure SemanticallyClosedCertifiedRun where
  certified :
    ValidCertifiedRun certifiableArchitecture quantizedModel
      exhaustiveCertifiedInputs certifiedRawTrace
  alignments : List SemanticBatchAlignmentData
  alignments_eq : alignments = semanticBatchAlignments
  batches_eq : alignedCertifiedBatches = certifiedBatches
  gapCoverage : SemanticHeadCoverage .gap 15
  useCoverage : SemanticHeadCoverage .use 22
  transportCoverage : SemanticHeadCoverage .transport 44
  queryCoverage : SemanticHeadCoverage .query 88
  repairCoverage : SemanticHeadCoverage .repair 528

def semanticallyClosedCertifiedRun : SemanticallyClosedCertifiedRun where
  certified := validCertifiedRun
  alignments := semanticBatchAlignments
  alignments_eq := rfl
  batches_eq := alignedCertifiedBatches_eq
  gapCoverage := gapSemanticCoverage
  useCoverage := useSemanticCoverage
  transportCoverage := transportSemanticCoverage
  queryCoverage := querySemanticCoverage
  repairCoverage := repairSemanticCoverage

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.semanticBatchAlignments
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.natMemberB
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.SemanticHeadCoverage
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.SemanticallyClosedCertifiedRun
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.semanticallyClosedCertifiedRun
/- AXIOM_AUDIT_END -/
