#!/usr/bin/env python3
"""Generate the exact Lean alignment between G3 examples and finite semantics."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Sequence

from certifiable_agent_v23 import (
    HEAD_ORDER,
    HeadExample,
    _agent_states,
    _gap_one_hot,
    _query_one_hot,
    _response_one_hot,
    _transport_one_hot,
    _use_one_hot,
    authorize,
    build_repair,
    certification_examples,
    detect_gap,
    encode_agent_state,
    enumerate_gaps,
    enumerate_queries,
    enumerate_responses,
    enumerate_transports,
    enumerate_uses,
    execute_transport,
    gap_class,
    patch_class,
    query_admissible,
    query_class,
    select_query,
    transport_class,
    use_class,
)


def semantic_examples() -> tuple[HeadExample, ...]:
    """Mirror the intrinsic Lean enumeration while retaining first occurrence."""

    rows: dict[str, dict[tuple[tuple[int, ...], int], HeadExample]] = {
        head: {} for head in HEAD_ORDER
    }

    def add(example: HeadExample) -> None:
        key = (example.features, example.target)
        conflicts = [
            previous
            for (features, target), previous in rows[example.head].items()
            if features == example.features and target != example.target
        ]
        if conflicts:
            raise AssertionError("one semantic input received incompatible labels")
        rows[example.head][key] = example

    for view in _agent_states():
        state_features = encode_agent_state(view)
        detected = detect_gap(view)
        if detected is not None:
            add(HeadExample("gap", state_features, gap_class(detected), "detect"))
        for gap in enumerate_gaps(view):
            gap_features = state_features + _gap_one_hot(gap)
            natural_use = authorize(view, gap)
            add(HeadExample("use", gap_features, use_class(natural_use), "authorize"))
            for use in enumerate_uses(gap):
                use_features = gap_features + _use_one_hot(use)
                natural_transport = execute_transport(view, gap, use)
                add(
                    HeadExample(
                        "transport",
                        use_features,
                        transport_class(natural_transport),
                        "executeTransport",
                    )
                )
                for transport in enumerate_transports(gap, use):
                    transport_features = use_features + _transport_one_hot(transport)
                    natural_query = select_query(transport)
                    add(
                        HeadExample(
                            "query",
                            transport_features,
                            query_class(natural_query),
                            "selectQuery",
                        )
                    )
                    for query in enumerate_queries(gap.index):
                        if not query_admissible(gap, use, transport, query):
                            continue
                        query_features = transport_features + _query_one_hot(query)
                        for response in enumerate_responses(query):
                            repair = build_repair(
                                view, gap, use, transport, query, response
                            )
                            add(
                                HeadExample(
                                    "repair",
                                    query_features + _response_one_hot(response),
                                    patch_class(repair.candidate_patch),
                                    "buildRepair",
                                )
                            )
    return tuple(item for head in HEAD_ORDER for item in rows[head].values())


def exported_examples() -> tuple[HeadExample, ...]:
    grouped = certification_examples()
    return tuple(item for head in HEAD_ORDER for item in grouped[head])


def semantic_permutation() -> tuple[int, ...]:
    semantic = semantic_examples()
    exported = exported_examples()
    semantic_lookup = {
        (item.head, item.features, item.target): index
        for index, item in enumerate(semantic)
    }
    exported_keys = [(item.head, item.features, item.target) for item in exported]
    if len(semantic_lookup) != len(semantic):
        raise AssertionError("the intrinsic semantic enumeration contains duplicates")
    try:
        permutation = tuple(semantic_lookup[key] for key in exported_keys)
    except KeyError as error:
        raise AssertionError("an exported example has no intrinsic semantic source") from error
    expected = tuple(range(len(semantic)))
    if tuple(sorted(permutation)) != expected:
        raise AssertionError("the exported table is not a full semantic permutation")
    if len(semantic) != 697:
        raise AssertionError(f"semantic table has {len(semantic)} examples, expected 697")
    return permutation


def semantic_references() -> tuple[tuple[str, int], ...]:
    permutation = semantic_permutation()
    grouped = certification_examples()
    counts = {head: len(grouped[head]) for head in HEAD_ORDER}
    offsets: dict[str, int] = {}
    offset = 0
    for head in HEAD_ORDER:
        offsets[head] = offset
        offset += counts[head]
    references = []
    for global_index in permutation:
        for head in HEAD_ORDER:
            start = offsets[head]
            stop = start + counts[head]
            if start <= global_index < stop:
                references.append((head, global_index - start))
                break
        else:
            raise AssertionError(f"semantic index {global_index} is out of range")
    return tuple(references)


def _lean_ref(reference: tuple[str, int]) -> str:
    head, index = reference
    return (
        f"{{ head := .{head}, index := {index}, "
        "inBounds := by decide }"
    )


def lean_modules() -> dict[str, str]:
    references = semantic_references()
    batches = [references[offset : offset + 8] for offset in range(0, 697, 8)]
    generated: dict[str, str] = {}
    generated["QuantizedCertifiedAgentSemanticCore.lean"] = """import Meta.AI.QuantizedCertifiedAgent

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
"""

    batch_names = []
    for number, references_in_batch in enumerate(batches):
        name = f"certifiedSemanticBatch{number:02d}"
        batch_names.append(name)
        imports = [
            "import Meta.AI.QuantizedCertifiedAgentSemanticCore",
            f"import Meta.AI.QuantizedCertifiedAgentBatch{number:02d}",
        ]
        if number >= 4:
            imports.append(
                f"import Meta.AI.QuantizedCertifiedAgentSemanticBatch{number - 4:02d}"
            )
        refs = ",\n    ".join(_lean_ref(reference) for reference in references_in_batch)
        generated[f"QuantizedCertifiedAgentSemanticBatch{number:02d}.lean"] = f"""{chr(10).join(imports)}

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

def {name} : SemanticBatchAlignmentData where
  batch := certifiedBatch{number:02d}
  refs := [
    {refs}
  ]
  inputs_eq := by
    rfl

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.{name}
/- AXIOM_AUDIT_END -/
"""

    last_batch = len(batches) - 1
    chain_ends = sorted(
        last_batch - ((last_batch - residue) % 4)
        for residue in range(min(4, len(batches)))
    )
    imports = "\n".join(
        f"import Meta.AI.QuantizedCertifiedAgentSemanticBatch{number:02d}"
        for number in chain_ends
    )
    alignment_list = ", ".join(batch_names)
    generated["QuantizedCertifiedAgentSemanticClosure.lean"] = f"""{imports}

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
  [{alignment_list}]

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
"""
    return generated


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out-lean", type=Path, required=True)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    generated = lean_modules()
    args.out_lean.parent.mkdir(parents=True, exist_ok=True)
    for filename, output in generated.items():
        (args.out_lean.parent / filename).write_text(output, encoding="utf-8")
    print(
        f"semantic_examples=697 permutation=complete "
        f"modules={len(generated)} output={args.out_lean.parent}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
