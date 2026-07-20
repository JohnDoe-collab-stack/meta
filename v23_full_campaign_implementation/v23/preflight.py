"""Fail-closed environment and protocol checks."""

from __future__ import annotations

import importlib.util
import json
import os
import platform
import shutil
import sys
from pathlib import Path
from typing import Any

import torch

from .canonical import content_sha256, sha256_file
from .planning import campaign_resource_estimate


def _module_version(name: str) -> str | None:
    if importlib.util.find_spec(name) is None:
        return None
    module = __import__(name)
    return str(getattr(module, "__version__", "present"))


def run_preflight(
    project_root: str | Path,
    require_scientific_resources: bool = True,
) -> dict[str, Any]:
    root = Path(project_root)
    checks: dict[str, dict[str, Any]] = {}
    lock_path = root / "protocol.lock.json"
    try:
        lock = json.loads(lock_path.read_text(encoding="utf-8"))
        checks["protocol_lock"] = {
            "ok": lock.get("implementation_contract") == "v23.1",
            "sha256": sha256_file(lock_path),
        }
    except (OSError, json.JSONDecodeError) as error:
        checks["protocol_lock"] = {"ok": False, "error": str(error)}
        lock = {}
    versions = {
        name: _module_version(name)
        for name in ("numpy", "torch", "cryptography", "onnx", "onnxruntime")
    }
    checks["python"] = {
        "ok": (3, 10) <= sys.version_info[:2] < (3, 13),
        "version": platform.python_version(),
    }
    checks["required_modules"] = {
        "ok": all(versions[name] is not None for name in ("numpy", "torch", "cryptography")),
        "versions": versions,
    }
    checks["onnx_parity_modules"] = {
        "ok": versions["onnx"] is not None and versions["onnxruntime"] is not None,
        "versions": {"onnx": versions["onnx"], "onnxruntime": versions["onnxruntime"]},
    }
    cuda_memory = 0
    if torch.cuda.is_available():
        cuda_memory = int(torch.cuda.get_device_properties(0).total_memory)
    checks["cuda"] = {
        "ok": torch.cuda.is_available() and cuda_memory >= 20 * 1024**3,
        "available": torch.cuda.is_available(),
        "compiled_cuda": torch.version.cuda,
        "memory_bytes": cuda_memory,
    }
    resource_estimate = campaign_resource_estimate()
    free_disk = shutil.disk_usage(root).free
    required_disk = resource_estimate["required_free_storage_bytes"]
    checks["disk"] = {
        "ok": free_disk >= required_disk,
        "free_bytes": free_disk,
        "required_bytes": required_disk,
        "multiplier_ppm": 1_500_000,
    }
    image_digest = os.environ.get("V23_OCI_IMAGE_DIGEST", "")
    checks["oci_image"] = {
        "ok": image_digest.startswith("sha256:") and len(image_digest) == 71,
        "digest": image_digest or None,
    }
    cublas_config = os.environ.get("CUBLAS_WORKSPACE_CONFIG")
    checks["cuda_determinism"] = {
        "ok": cublas_config in {":4096:8", ":16:8"},
        "CUBLAS_WORKSPACE_CONFIG": cublas_config,
    }
    assignment_path = root / "configs" / "resource_assignments.json"
    benchmark_path = root / "configs" / "smoke_benchmark.json"
    benchmark_ok = False
    assignment_ok = False
    benchmark_error = None
    assignment_error = None
    if benchmark_path.is_file():
        try:
            benchmark_payload = json.loads(benchmark_path.read_text(encoding="utf-8"))
            benchmark_ok = (
                benchmark_payload.get("schema") == "v23-smoke-benchmark-1"
                and bool(benchmark_payload.get("results"))
            )
        except (OSError, json.JSONDecodeError) as error:
            benchmark_error = str(error)
    if assignment_path.is_file() and benchmark_path.is_file():
        try:
            assignment_payload = json.loads(assignment_path.read_text(encoding="utf-8"))
            assignment_ok = (
                assignment_payload.get("schema") == "v23-resource-assignment-1"
                and assignment_payload.get("complete") is True
                and assignment_payload.get("cell_count")
                == resource_estimate["tuning_cells"] + resource_estimate["final_training_cells"]
                and assignment_payload.get("benchmark_sha256") == sha256_file(benchmark_path)
                and len(assignment_payload.get("assignments", {}))
                == assignment_payload.get("cell_count")
            )
        except (OSError, json.JSONDecodeError) as error:
            assignment_error = str(error)
    checks["resource_assignment"] = {
        "ok": assignment_ok,
        "path": str(assignment_path),
        "sha256": sha256_file(assignment_path) if assignment_path.is_file() else None,
        "error": assignment_error,
    }
    checks["smoke_benchmark"] = {
        "ok": benchmark_ok,
        "path": str(benchmark_path),
        "sha256": sha256_file(benchmark_path) if benchmark_path.is_file() else None,
        "error": benchmark_error,
    }
    mandatory = ("protocol_lock", "python", "required_modules")
    if require_scientific_resources:
        mandatory += (
            "onnx_parity_modules",
            "cuda",
            "disk",
            "oci_image",
            "cuda_determinism",
            "resource_assignment",
            "smoke_benchmark",
        )
    ok = all(bool(checks[name]["ok"]) for name in mandatory)
    return {
        "schema": "v23-preflight-1",
        "scientific_resources_required": require_scientific_resources,
        "ok": ok,
        "checks": checks,
        "resource_estimate": resource_estimate,
        "lock_contract": lock.get("implementation_contract"),
        "report_sha256": content_sha256(
            {"checks": checks, "resource_estimate": resource_estimate}
        ),
    }
