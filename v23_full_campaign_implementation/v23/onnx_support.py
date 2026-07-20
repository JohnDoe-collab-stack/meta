"""Optional ONNX export and strict CPU parity checks."""

from __future__ import annotations

import importlib.util
from pathlib import Path
from typing import Mapping

import numpy as np
import torch
from torch import Tensor, nn

from .models import CausalAgent


class SymbolicPreResponseWrapper(nn.Module):
    def __init__(self, model: CausalAgent) -> None:
        super().__init__()
        self.model = model

    def forward(
        self,
        observation: Tensor,
        candidate: Tensor,
        history: Tensor,
        gap_mask: Tensor,
        use_mask: Tensor,
        transport_mask: Tensor,
        query_mask: Tensor,
    ) -> tuple[Tensor, Tensor, Tensor, Tensor]:
        context = self.model.encode_public(
            observation, candidate, history, symbolic=True
        )
        outputs = self.model.decide_pre_response(
            context,
            {
                "gap": gap_mask,
                "use": use_mask,
                "transport": transport_mask,
                "query": query_mask,
            },
        )
        return tuple(outputs[name][0] for name in ("gap", "use", "transport", "query"))  # type: ignore[return-value]


def export_symbolic_pre_response(
    model: CausalAgent,
    sample_inputs: tuple[Tensor, ...],
    output_path: str | Path,
) -> None:
    if importlib.util.find_spec("onnx") is None:
        raise RuntimeError("onnx is required for the publication parity gate")
    wrapper = SymbolicPreResponseWrapper(model).eval()
    torch.onnx.export(
        wrapper,
        sample_inputs,
        str(output_path),
        input_names=("observation", "candidate", "history", "gap_mask", "use_mask", "transport_mask", "query_mask"),
        output_names=("gap_logits", "use_logits", "transport_logits", "query_logits"),
        dynamic_axes={
            "observation": {0: "batch", 1: "observation_length"},
            "candidate": {0: "batch", 1: "candidate_length"},
            "history": {0: "batch", 1: "history_length"},
        },
        opset_version=18,
        dynamo=False,
    )


def verify_onnx_parity(
    model: CausalAgent,
    onnx_path: str | Path,
    named_inputs: Mapping[str, np.ndarray],
    tolerance: float = 1e-5,
) -> dict[str, object]:
    if importlib.util.find_spec("onnxruntime") is None:
        raise RuntimeError("onnxruntime is required for the publication parity gate")
    import onnxruntime as ort

    session = ort.InferenceSession(str(onnx_path), providers=["CPUExecutionProvider"])
    onnx_outputs = session.run(None, dict(named_inputs))
    tensor_inputs = tuple(torch.from_numpy(named_inputs[name]) for name in (
        "observation", "candidate", "history", "gap_mask", "use_mask", "transport_mask", "query_mask"
    ))
    with torch.no_grad():
        torch_outputs = SymbolicPreResponseWrapper(model)(*tensor_inputs)
    maximum_error = max(
        float(np.max(np.abs(expected.detach().cpu().numpy() - actual)))
        for expected, actual in zip(torch_outputs, onnx_outputs)
    )
    decisions_equal = all(
        np.array_equal(np.argmax(expected.detach().cpu().numpy(), axis=-1), np.argmax(actual, axis=-1))
        for expected, actual in zip(torch_outputs, onnx_outputs)
    )
    return {
        "schema": "v23-onnx-parity-1",
        "maximum_absolute_error_nanos": int(round(maximum_error * 1_000_000_000)),
        "tolerance_nanos": int(round(tolerance * 1_000_000_000)),
        "decisions_equal": decisions_equal,
        "ok": decisions_equal and maximum_error <= tolerance,
    }
