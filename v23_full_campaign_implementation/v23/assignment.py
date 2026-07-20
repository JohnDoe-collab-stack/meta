"""Deterministic complete assignment of registered cells to declared resources."""

from __future__ import annotations

from typing import Any

from .campaign import final_training_matrix, tuning_matrix
from .canonical import content_sha256


def assign_resources(
    resources: list[dict[str, Any]],
    benchmark_sha256: str,
) -> dict[str, Any]:
    if not resources:
        raise ValueError("at least one compute resource must be declared")
    identifiers = []
    for resource in resources:
        identifier = resource.get("resource_id")
        if not isinstance(identifier, str) or not identifier:
            raise ValueError("every resource needs a non-empty resource_id")
        if int(resource.get("cuda_memory_bytes", 0)) < 20 * 1024**3:
            raise ValueError(f"resource {identifier} has insufficient CUDA memory")
        identifiers.append(identifier)
    if len(identifiers) != len(set(identifiers)):
        raise ValueError("resource ids must be unique")
    cells = tuning_matrix() + final_training_matrix()
    assignments = {
        cell.run_id: identifiers[index % len(identifiers)]
        for index, cell in enumerate(cells)
    }
    return {
        "schema": "v23-resource-assignment-1",
        "benchmark_sha256": benchmark_sha256,
        "resources": resources,
        "assignments": assignments,
        "cell_count": len(cells),
        "matrix_sha256": content_sha256(
            tuple((cell.run_id, assignments[cell.run_id]) for cell in cells)
        ),
        "complete": len(assignments) == len(cells),
    }
