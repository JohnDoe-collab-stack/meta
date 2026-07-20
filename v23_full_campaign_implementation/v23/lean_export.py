"""Generate constructive Lean trace blocks with mandatory axiom audits."""

from __future__ import annotations

from pathlib import Path
from typing import Iterable

from .canonical import sha256_file, write_new_bytes
from .contracts import EpisodeTrace


def _nat_id(value: str) -> int:
    return int.from_bytes(__import__("hashlib").sha256(value.encode()).digest()[:8], "big")


def _lean_nat_list(values: Iterable[str]) -> str:
    return "[" + ", ".join(str(_nat_id(value)) for value in values) + "]"


def _render_trace_definitions(trace: EpisodeTrace, module_index: int) -> tuple[str, str]:
    trace.validate()
    if trace.actual_world_id not in set(trace.initial_fiber):
        raise ValueError("Lean export rejected a trace whose initial fiber omits the real world")
    for index, step in enumerate(trace.steps):
        if trace.actual_world_id not in set(step.fiber_after):
            raise ValueError(f"Lean export rejected step {index}: real world removed")
        if len(step.fiber_after) >= len(step.fiber_before):
            raise ValueError(f"Lean export rejected step {index}: no strict refinement")
        if len(step.repair.retained_closures) != index:
            raise ValueError(f"Lean export rejected step {index}: retention count mismatch")
    steps = []
    for step in trace.steps:
        steps.append(
            "{ beforeFiber := " + _lean_nat_list(step.fiber_before)
            + ", afterFiber := " + _lean_nat_list(step.fiber_after)
            + ", query := " + str(_nat_id(step.query_id))
            + ", response := " + str(_nat_id(step.response_id))
            + ", repair := " + str(_nat_id(step.repair.repair_id))
            + ", provenance := " + _lean_nat_list(step.repair.provenance)
            + ", retainedClosures := " + str(len(step.repair.retained_closures))
            + ", memoryBefore := " + _lean_nat_list(step.memory_before)
            + ", memoryAfter := " + _lean_nat_list(step.memory_after)
            + ", transitionDerivedFromRepair := true }"
        )
    trace_name = f"rawTrace{module_index:06d}"
    certified_name = f"certifiedRun{module_index:06d}"
    source = (
        f"def {trace_name} : V23.RawTrace :=\n"
        "  { initialFiber := " + _lean_nat_list(trace.initial_fiber) + "\n"
        "    , actualWorld := " + str(_nat_id(trace.actual_world_id)) + "\n"
        "    , steps := [\n      " + ",\n      ".join(steps) + "\n    ]\n"
        "    , finalFiber := " + _lean_nat_list(trace.final_fiber) + "\n"
        "    , requiredAction := " + str(_nat_id(trace.required_action)) + "\n"
        "    , predictedAction := " + str(_nat_id(trace.predicted_action)) + "\n"
        "    , closed := " + ("true" if trace.closed else "false") + " }\n\n"
        f"def {certified_name} : V23.ValidCertifiedRun :=\n"
        f"  {{ trace := {trace_name}, valid := by decide }}\n\n"
    )
    return source, certified_name


def render_trace_block(traces: list[EpisodeTrace], first_index: int) -> str:
    if not traces:
        raise ValueError("a generated Lean block cannot be empty")
    definitions = []
    names = []
    for offset, trace in enumerate(traces):
        source, name = _render_trace_definitions(trace, first_index + offset)
        definitions.append(source)
        names.append(name)
    block_name = f"certifiedBlock{first_index // 256:06d}"
    return (
        "import V23.Kernel\n\n"
        "namespace V23.Generated\n\n"
        + "".join(definitions)
        + f"def {block_name} : List V23.ValidCertifiedRun :=\n  ["
        + ", ".join(names)
        + "]\n\n"
        + "end V23.Generated\n\n"
        + "/- AXIOM_AUDIT_BEGIN -/\n"
        + f"#print axioms V23.Generated.{block_name}\n"
        + "/- AXIOM_AUDIT_END -/\n"
    )


def render_trace_module(trace: EpisodeTrace, module_index: int) -> str:
    return render_trace_block([trace], module_index)


def export_trace_blocks(
    traces: Iterable[EpisodeTrace],
    output_directory: str | Path,
    block_size: int = 256,
) -> dict[str, object]:
    if block_size != 256:
        raise ValueError("publication protocol fixes Lean blocks at 256 traces")
    output = Path(output_directory)
    output.mkdir(parents=True, exist_ok=False)
    modules = []
    materialized = list(traces)
    for block_index, start in enumerate(range(0, len(materialized), block_size)):
        block = materialized[start : start + block_size]
        relative = Path("V23") / "Generated" / f"Block{block_index:06d}.lean"
        target = output / relative
        write_new_bytes(target, render_trace_block(block, start).encode("utf-8"))
        modules.append(
            {
                "module": ".".join(relative.with_suffix("").parts),
                "sha256": sha256_file(target),
                "first_trace": start,
                "trace_count": len(block),
            }
        )
    return {
        "schema": "v23-lean-export-1",
        "block_size": block_size,
        "modules": modules,
        "traces": len(materialized),
    }
