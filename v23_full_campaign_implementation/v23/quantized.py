"""Exact Int8/Int32 primitives for certifiable catalog inference."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import numpy as np
import torch
from torch import Tensor

from .canonical import content_sha256


@dataclass(frozen=True)
class QuantizedTensor:
    shape: tuple[int, ...]
    values: tuple[int, ...]
    scale_nanos: int

    def array(self) -> np.ndarray:
        return np.asarray(self.values, dtype=np.int8).reshape(self.shape)


def quantize_symmetric(tensor: Tensor) -> QuantizedTensor:
    values = tensor.detach().cpu().to(torch.float64).numpy()
    maximum = float(np.max(np.abs(values))) if values.size else 0.0
    scale = maximum / 127.0 if maximum > 0 else 1.0
    quantized = np.clip(np.rint(values / scale), -127, 127).astype(np.int8)
    return QuantizedTensor(
        shape=tuple(int(size) for size in quantized.shape),
        values=tuple(int(item) for item in quantized.reshape(-1)),
        scale_nanos=max(1, int(round(scale * 1_000_000_000))),
    )


def int8_linear(
    inputs: np.ndarray,
    weights: np.ndarray,
    bias: np.ndarray | None = None,
) -> np.ndarray:
    if inputs.dtype != np.int8 or weights.dtype != np.int8:
        raise ValueError("certifiable linear inputs and weights must be Int8")
    if inputs.shape[-1] != weights.shape[-1]:
        raise ValueError("linear dimensions do not align")
    accumulation = inputs.astype(np.int64) @ weights.astype(np.int64).T
    if bias is not None:
        if bias.dtype != np.int32:
            raise ValueError("certifiable bias must be Int32")
        accumulation += bias.astype(np.int64)
    if np.any(accumulation < -(2**31)) or np.any(accumulation > 2**31 - 1):
        raise OverflowError("Int32 accumulator bound exceeded")
    return accumulation.astype(np.int32)


def canonical_argmax_int32(logits: np.ndarray, mask: np.ndarray) -> np.ndarray:
    if logits.dtype != np.int32 or mask.dtype != np.bool_:
        raise ValueError("argmax expects Int32 logits and a boolean mask")
    if logits.shape != mask.shape or logits.ndim != 2:
        raise ValueError("argmax tensors must align as [batch, catalog]")
    if np.any(~np.any(mask, axis=1)):
        raise ValueError("each row needs an allowed catalog value")
    minimum = np.iinfo(np.int32).min
    return np.argmax(np.where(mask, logits, minimum), axis=1).astype(np.int32)


def quantized_linear_certificate(
    inputs: Tensor,
    weights: Tensor,
    bias: Tensor | None = None,
) -> dict[str, Any]:
    q_inputs = quantize_symmetric(inputs)
    q_weights = quantize_symmetric(weights)
    if bias is None:
        q_bias = None
    else:
        combined_scale = q_inputs.scale_nanos * q_weights.scale_nanos
        bias_values = np.rint(
            bias.detach().cpu().numpy() * 10**18 / combined_scale
        ).astype(np.int64)
        if np.any(bias_values < -(2**31)) or np.any(bias_values > 2**31 - 1):
            raise OverflowError("quantized bias exceeds Int32")
        q_bias = bias_values.astype(np.int32)
    output = int8_linear(q_inputs.array(), q_weights.array(), q_bias)
    payload = {
        "schema": "v23-quantized-linear-1",
        "inputs": q_inputs,
        "weights": q_weights,
        "bias": None if q_bias is None else tuple(int(item) for item in q_bias.reshape(-1)),
        "output_shape": tuple(int(size) for size in output.shape),
        "output_int32": tuple(int(item) for item in output.reshape(-1)),
    }
    return payload | {"certificate_sha256": content_sha256(payload)}
