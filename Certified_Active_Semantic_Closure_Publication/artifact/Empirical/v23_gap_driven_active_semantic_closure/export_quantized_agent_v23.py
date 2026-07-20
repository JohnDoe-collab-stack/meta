#!/usr/bin/env python3
"""Export a verified v23 Int8 checkpoint as a constructive Lean module."""

from __future__ import annotations

import argparse
import hashlib
import sys
from pathlib import Path
from typing import Sequence

from certifiable_agent_v23 import (
    HEAD_ORDER,
    QuantizedHead,
    canonical_argmax,
    certification_examples,
    checkpoint_from_dict,
    infer_logits,
)
from trace_schema_v23 import canonical_json, parse_json_strict
from verify_quantized_inference_v23 import verify_checkpoint


LEAN_HEAD_NAMES = {
    "gap": "gapHead",
    "use": "useHead",
    "transport": "transportHead",
    "query": "queryHead",
    "repair": "repairHead",
}

BATCH_SIZE = 8
BATCH_CHAINS = 4


def _lean_int(value: int) -> str:
    return str(value) if value >= 0 else f"({value})"


def _lean_vector(values: Sequence[int]) -> str:
    return "[" + ", ".join(_lean_int(value) for value in values) + "]"


def _head_definition(name: str, head: QuantizedHead) -> str:
    prefix = LEAN_HEAD_NAMES[name]
    hidden_names = [
        f"{prefix}HiddenWeight{index:02d}" for index in range(len(head.hidden_weights))
    ]
    output_names = [
        f"{prefix}OutputWeight{index:02d}" for index in range(len(head.output_weights))
    ]
    rows = "\n\n".join(
        f"def {row_name} : List Int := {_lean_vector(row)}"
        for row_name, row in zip(hidden_names, head.hidden_weights, strict=True)
    )
    rows += "\n\n" + "\n\n".join(
        f"def {row_name} : List Int := {_lean_vector(row)}"
        for row_name, row in zip(output_names, head.output_weights, strict=True)
    )
    hidden_matrix = "[" + ", ".join(hidden_names) + "]"
    output_matrix = "[" + ", ".join(output_names) + "]"
    return f"""{rows}

abbrev {prefix} : QuantizedHead where
  inputDim := {head.input_dim}
  outputDim := {head.output_dim}
  hiddenWeights := {hidden_matrix}
  hiddenBias := {_lean_vector(head.hidden_bias)}
  outputWeights := {output_matrix}
  outputBias := {_lean_vector(head.output_bias)}
  hiddenShift := {head.hidden_shift}
  outputShift := {head.output_shift}
  validClasses := {_lean_vector(head.valid_classes)}
"""


def _example_definition(name: str, features: Sequence[int], target: int) -> str:
    return (
        f"{{ head := .{name}, input := {_lean_vector(features)}, "
        f"expected := {target} }}"
    )


def _decision_definition(
    name: str,
    target: int,
    logits: Sequence[int],
) -> str:
    predicted = canonical_argmax(logits)
    return (
        f"{{ head := .{name}, predicted := {predicted}, expected := {target}, "
        f"logits := {_lean_vector(logits)} }}"
    )


def lean_modules(
    checkpoint_path: Path,
    checkpoint_hash: str,
    value: object,
) -> dict[str, str]:
    checkpoint = checkpoint_from_dict(value)
    examples = certification_examples()
    input_rows = [
        _example_definition(name, example.features, example.target)
        for name in HEAD_ORDER
        for example in examples[name]
    ]
    trace_rows = []
    for name in HEAD_ORDER:
        for example in examples[name]:
            logits = infer_logits(checkpoint.heads[name], example.features)
            trace_rows.append(_decision_definition(name, example.target, logits))
    generated: dict[str, str] = {}
    batch_names: list[str] = []
    for batch_number, start in enumerate(range(0, len(input_rows), BATCH_SIZE)):
        suffix = f"{batch_number:02d}"
        name = f"certifiedBatch{suffix}"
        batch_names.append(name)
        batch_inputs = "[\n    " + ",\n    ".join(
            input_rows[start : start + BATCH_SIZE]
        ) + "\n  ]"
        batch_trace = "[\n    " + ",\n    ".join(
            trace_rows[start : start + BATCH_SIZE]
        ) + "\n  ]"
        if batch_number < BATCH_CHAINS:
            batch_import = "import Meta.AI.QuantizedCertifiedAgentWeights"
        else:
            previous = batch_number - BATCH_CHAINS
            batch_import = (
                f"import Meta.AI.QuantizedCertifiedAgentBatch{previous:02d}"
            )
        generated[f"QuantizedCertifiedAgentBatch{suffix}.lean"] = f"""{batch_import}

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

open Quantized

abbrev {name}Inputs : List CertifiedExample := {batch_inputs}

abbrev {name}Trace : RawTrace := {batch_trace}

def {name} : CertifiedBatchData quantizedModel where
  inputs := {name}Inputs
  rawTrace := {name}Trace
  certificate := by
    refine
      {{ inputsValid := ?_
        accumulatorsValid := ?_
        run_eq := ?_
        traceValid := ?_
        nonempty := ?_ }}
    · rfl
    · rfl
    · rfl
    · exact And.intro (by decide) (by decide)
    · intro equality
      cases equality

end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.{name}
/- AXIOM_AUDIT_END -/
"""
    batch_list = "[" + ", ".join(batch_names) + "]"
    head_module_names: list[str] = []
    for name in HEAD_ORDER:
        title = name.capitalize()
        module_name = f"QuantizedCertifiedAgent{title}Weights"
        head_module_names.append(module_name)
        lean_name = LEAN_HEAD_NAMES[name]
        generated[f"{module_name}.lean"] = f"""import Meta.AI.FiniteQuantizedAgentSemantics

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

open Quantized

{_head_definition(name, checkpoint.heads[name])}
end QuantizedCertified
end ActiveSemanticClosure
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.ActiveSemanticClosure.QuantizedCertified.{lean_name}
/- AXIOM_AUDIT_END -/
"""
    head_imports = "\n".join(
        f"import Meta.AI.{module_name}" for module_name in head_module_names
    )
    generated["QuantizedCertifiedAgentWeights.lean"] = f"""{head_imports}

/-!
# Reified v23 certifiable-agent weights

Generated from `{checkpoint_path.name}` with SHA-256 `{checkpoint_hash}`.
-/

set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Meta
namespace ActiveSemanticClosure
namespace QuantizedCertified

open Quantized
open FiniteQuantized

def trainingSeed : Nat := {checkpoint.seed}
def trainingUpdate : Nat := {checkpoint.update}

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
"""
    last_batch = len(batch_names) - 1
    chain_ends = sorted(
        last_batch - ((last_batch - residue) % BATCH_CHAINS)
        for residue in range(min(BATCH_CHAINS, len(batch_names)))
    )
    imports = "\n".join(
        f"import Meta.AI.QuantizedCertifiedAgentBatch{number:02d}"
        for number in chain_ends
    )
    generated["QuantizedCertifiedAgent.lean"] = f"""{imports}

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
  {batch_list}

abbrev exhaustiveCertifiedInputs : List CertifiedExample :=
  certifiedBatches.flatMap fun batch => batch.inputs

abbrev certifiedRawTrace : RawTrace :=
  certifiedBatches.flatMap fun batch => batch.rawTrace

def validCertifiedRun :
    ValidCertifiedRun certifiableArchitecture quantizedModel
      exhaustiveCertifiedInputs certifiedRawTrace := by
  refine
    {{ architectureValid := ?_
      batches := certifiedBatches
      inputs_eq := rfl
      rawTrace_eq := rfl
      nonempty := ?_ }}
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
"""
    return generated


def lean_module(checkpoint_path: Path, checkpoint_hash: str, value: object) -> str:
    return lean_modules(checkpoint_path, checkpoint_hash, value)[
        "QuantizedCertifiedAgent.lean"
    ]


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("checkpoint", type=Path)
    parser.add_argument("--out-lean", type=Path, required=True)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        raw = args.checkpoint.read_bytes()
        text = raw.decode("utf-8")
        if not text.endswith("\n") or "\r" in text:
            raise ValueError("checkpoint must be canonical LF-terminated UTF-8")
        value = parse_json_strict(text[:-1], require_canonical=True)
        report = verify_checkpoint(value)
        checkpoint_hash = hashlib.sha256(raw).hexdigest()
        outputs = lean_modules(args.checkpoint, checkpoint_hash, value)
        for filename, output in outputs.items():
            (args.out_lean.parent / filename).write_text(
                output, encoding="utf-8", newline="\n"
            )
        report.update(
            {
                "checkpoint_sha256": checkpoint_hash,
                "lean_module": str(args.out_lean),
                "lean_module_sha256": hashlib.sha256(
                    args.out_lean.read_bytes()
                ).hexdigest(),
                "lean_modules": {
                    filename: hashlib.sha256(
                        (args.out_lean.parent / filename).read_bytes()
                    ).hexdigest()
                    for filename in sorted(outputs)
                },
            }
        )
    except (OSError, UnicodeDecodeError, ValueError) as error:
        print(canonical_json({"error": str(error), "valid": False}), file=sys.stderr)
        return 1
    print(canonical_json(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
