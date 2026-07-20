"""Deterministic public split manifests; training remains generated online."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from .canonical import content_sha256, write_new_json
from .domains import PerceptualDomain, SymbolicDomain
from .seeds import derive_seed
from .splits import OOD_FAMILIES, audit_structural_disjointness, structural_fingerprint


SPLIT_SPEC = {
    "iid_validation": (231_000, 4096),
    "structural_validation": (232_000, 4096),
    "iid_test": (233_000, 8192),
}


def _episode_commitments(domain: object, root_seed: int, count: int) -> tuple[str, ...]:
    commitments = []
    for index in range(count):
        seed = derive_seed(root_seed, f"{domain.kind.value}-episode", index)
        episode = domain.generate_episode(seed, actual_index=index % 32)
        commitments.append(content_sha256(episode))
    return tuple(commitments)


def build_public_data_manifest(
    output_path: str | Path,
    materialize_commitments: bool = True,
) -> dict[str, Any]:
    domains = (SymbolicDomain(), PerceptualDomain())
    disjointness = audit_structural_disjointness(domains)
    splits: dict[str, Any] = {}
    for domain in domains:
        domain_splits = {}
        for split_name, (root_seed, count) in SPLIT_SPEC.items():
            commitments = (
                _episode_commitments(domain, root_seed, count)
                if materialize_commitments
                else ()
            )
            domain_splits[split_name] = {
                "root_seed": root_seed,
                "count": count,
                "episode_commitments": commitments,
                "commitment_root": content_sha256(commitments),
                "materialized": materialize_commitments,
            }
        splits[domain.kind.value] = domain_splits
    manifest = {
        "schema": "v23-public-data-manifest-1",
        "online_training": {
            "horizons": (3, 4, 5),
            "generator": "closed-family-v23.1",
            "contains_fixed_test_records": False,
        },
        "splits": splits,
        "ood_families": {
            f"{domain.kind.value}:{family}": structural_fingerprint(domain, family)
            for domain in domains
            for family in OOD_FAMILIES
        },
        "structural_disjointness": disjointness,
        "contains_ood": False,
        "sealed_ood_key_access": False,
    }
    write_new_json(output_path, manifest)
    return manifest
