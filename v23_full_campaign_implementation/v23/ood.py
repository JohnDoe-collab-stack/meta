"""Authenticated OOD sealing with nonce and Merkle audits."""

from __future__ import annotations

import os
from pathlib import Path
from typing import Any, Iterable

from cryptography.hazmat.primitives.ciphers.aead import AESGCM

from .canonical import (
    canonical_bytes,
    content_sha256,
    merkle_root_hex,
    merkle_root_from_hashes,
    write_new_bytes,
    write_new_json,
)


def _require_key(key: bytes, label: str) -> None:
    if len(key) != 32:
        raise ValueError(f"{label} must be an AES-256 key")


def seal_records(
    records: Iterable[Any],
    output_directory: str | Path,
    campaign_key: bytes,
    public_descriptor: dict[str, Any],
    record_count: int | None = None,
) -> dict[str, Any]:
    _require_key(campaign_key, "campaign_key")
    output = Path(output_directory)
    output.mkdir(parents=True, exist_ok=False)
    if record_count is None:
        try:
            record_count = len(records)  # type: ignore[arg-type]
        except TypeError as error:
            raise ValueError("streaming seal requires an explicit record_count") from error
    aad_manifest = {
        "schema": "v23-ood-aad-1",
        "count": record_count,
        "descriptor": public_descriptor,
    }
    aad = canonical_bytes(aad_manifest)
    data_key = AESGCM.generate_key(bit_length=256)
    cipher = AESGCM(data_key)
    nonces: set[bytes] = set()
    leaf_hashes: list[bytes] = []
    entries: list[dict[str, Any]] = []
    seen = 0
    for index, record in enumerate(records):
        nonce = os.urandom(12)
        while nonce in nonces:
            nonce = os.urandom(12)
        nonces.add(nonce)
        ciphertext = cipher.encrypt(nonce, canonical_bytes(record), aad)
        blob = nonce + ciphertext
        name = f"blob_{index:08d}.aesgcm"
        write_new_bytes(output / name, blob)
        leaf_hashes.append(__import__("hashlib").sha256(blob).digest())
        entries.append(
            {"name": name, "bytes": len(blob), "sha256": content_sha256(blob)}
        )
        seen += 1
    if seen != record_count:
        raise ValueError(f"sealed record count mismatch: expected {record_count}, saw {seen}")
    wrapping_nonce = os.urandom(12)
    wrapped_key = wrapping_nonce + AESGCM(campaign_key).encrypt(
        wrapping_nonce, data_key, aad
    )
    write_new_bytes(output / "wrapped_data_key.aesgcm", wrapped_key)
    public_manifest = {
        "schema": "v23-ood-public-1",
        "aad_manifest": aad_manifest,
        "aad_sha256": content_sha256(aad_manifest),
        "entries": entries,
        "merkle_root": merkle_root_from_hashes(leaf_hashes),
        "nonce_count": len(nonces),
        "nonce_unique": len(nonces) == seen,
        "status": "sealed",
    }
    write_new_json(output / "public_manifest.json", public_manifest)
    return public_manifest


def open_records(
    sealed_directory: str | Path,
    campaign_key: bytes,
) -> list[bytes]:
    import json

    _require_key(campaign_key, "campaign_key")
    root = Path(sealed_directory)
    with (root / "public_manifest.json").open("r", encoding="utf-8") as handle:
        manifest = json.load(handle)
    aad_manifest = manifest["aad_manifest"]
    if content_sha256(aad_manifest) != manifest["aad_sha256"]:
        raise ValueError("OOD associated-data manifest hash mismatch")
    aad = canonical_bytes(aad_manifest)
    wrapped = (root / "wrapped_data_key.aesgcm").read_bytes()
    data_key = AESGCM(campaign_key).decrypt(wrapped[:12], wrapped[12:], aad)
    cipher = AESGCM(data_key)
    records: list[bytes] = []
    leaf_hashes: list[bytes] = []
    nonces: set[bytes] = set()
    for entry in manifest["entries"]:
        blob = (root / entry["name"]).read_bytes()
        if content_sha256(blob) != entry["sha256"]:
            raise ValueError("sealed blob hash mismatch")
        nonce, ciphertext = blob[:12], blob[12:]
        if nonce in nonces:
            raise ValueError("nonce reuse detected")
        nonces.add(nonce)
        records.append(cipher.decrypt(nonce, ciphertext, aad))
        leaf_hashes.append(__import__("hashlib").sha256(blob).digest())
    if merkle_root_from_hashes(leaf_hashes) != manifest["merkle_root"]:
        raise ValueError("sealed OOD Merkle root mismatch")
    return records
