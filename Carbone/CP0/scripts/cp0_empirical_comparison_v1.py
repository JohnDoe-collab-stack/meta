#!/usr/bin/env python3
"""Compare a first intrinsic bilateral CP0 rule with frozen baselines.

Only Reaction.inputs, Reaction.conditions, and Reaction.reaction_id are
deserialized from the official source. Outcomes are never deserialized here;
targets come from compartment-specific exports produced by the frozen reader.

The candidate called C0-BIR is an operational hypothesis, not a theorem: its
gap, interaction, environmental-response, and repair feature blocks are fitted
by ridge regression. It never receives dataset, reaction, molecule, or
environment hashes as numeric features. Hashes are used only as lookup keys.
"""

from __future__ import annotations

import argparse
from collections import defaultdict
import csv
import datetime as dt
from fractions import Fraction
import gzip
import hashlib
import importlib
import importlib.metadata
import io
import json
import math
from pathlib import Path
import platform
import shlex
import sys
from typing import Any, Iterable, Iterator


SOURCE_SHA256 = "103c485fc009ee66f525c140611c8596d31f0673cdbb2ec16ec497ea44a58f6f"
SOURCE_SIZE = 8_753_257
I0_MANIFEST_SHA256 = "da963892cf8caebf3ad5983773b866a13333260869805542b16d0be1aa01cb9b"
CONSTRUCTION_TARGETS_SHA256 = (
    "9f9c80b1f3fd21e5dcea70b258a4a3c6d57cbe196dca4a42f0d3781d87f9e26b"
)
REACTION_PB2_SHA256 = (
    "1ed2befa91faf00e76e9fd1ef555bf0da51c69a0085e5d7dd4db6418751bdd9c"
)
EXPECTED_REACTIONS = 47_015
EXPECTED_MANIFEST_COLUMNS = (
    "reaction_id_sha256",
    "amine_sha256",
    "acid_sha256",
    "semantic_condition_sha256",
    "label_condition_sha256",
    "compartment",
)
TARGET_COLUMNS = (
    "amine_sha256",
    "acid_sha256",
    "semantic_condition_sha256",
    "target_numerator",
    "target_denominator",
    "row_count",
)
EXPECTED_DISTRIBUTIONS = {
    "joblib": "1.5.2",
    "numpy": "2.2.6",
    "rdkit": "2026.3.4",
    "scikit-learn": "1.7.2",
    "scipy": "1.15.3",
    "threadpoolctl": "3.6.0",
}
WHEEL_SHA256 = {
    "joblib-1.5.2-py3-none-any.whl": (
        "4e1f0bdbb987e6d843c70cf43714cb276623def372df3c22fe5266b2670bc241"
    ),
    "numpy-2.2.6-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl": (
        "fc7b73d02efb0e18c000e9ad8b83480dfcd5dfd11065997ed4c6747470ae8915"
    ),
    "rdkit-2026.3.4-cp310-cp310-manylinux_2_28_x86_64.whl": (
        "974830cdcdb95f825fc1038824af0031e7ac537e526485a5f30e58260d03bc39"
    ),
    "scikit_learn-1.7.2-cp310-cp310-manylinux2014_x86_64.manylinux_2_17_x86_64.whl": (
        "7a58814265dfc52b3295b1900cfb5701589d30a8bb026c7540f1e9d3499d5ec8"
    ),
    "scipy-1.15.3-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl": (
        "9e2abc762b0811e09a0d3258abee2d98e0c703eee49464ce0069590846f31d40"
    ),
    "threadpoolctl-3.6.0-py3-none-any.whl": (
        "43a0b8fd5a2928500110039e43a5eed8480b918967083ea48dc3ab9f13c4a7fb"
    ),
}
ALPHAS = (0.1, 1.0, 10.0, 100.0)
K_VALUES = (1, 3, 5, 10)
FP_SIZE = 2048
GROUPS = (
    "carboxylic acid",
    "additive",
    "activation agent",
    "amine",
    "base",
    "solvent",
)
GROUP_INDEX = {name: index for index, name in enumerate(GROUPS)}
REACTION_FIELDS = frozenset(range(1, 11))
SANITIZED_REACTION_FIELDS = frozenset({2, 4, 10})


class ProtocolError(ValueError):
    """A frozen CP0 empirical-comparison contract was violated."""


class WireField(tuple):
    __slots__ = ()

    def __new__(
        cls,
        number: int,
        wire_type: int,
        raw: bytes,
        payload: bytes | None,
        scalar: int | bytes | None,
    ) -> "WireField":
        return tuple.__new__(cls, (number, wire_type, raw, payload, scalar))

    number = property(lambda self: self[0])
    wire_type = property(lambda self: self[1])
    raw = property(lambda self: self[2])
    payload = property(lambda self: self[3])
    scalar = property(lambda self: self[4])


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--mode",
        required=True,
        choices=("construction-cv", "selection-eval"),
    )
    parser.add_argument("--source-pb-gz", required=True, type=Path)
    parser.add_argument("--i0-manifest-csv-gz", required=True, type=Path)
    parser.add_argument("--ord-schema-python-root", required=True, type=Path)
    parser.add_argument("--construction-targets-csv-gz", required=True, type=Path)
    parser.add_argument("--selection-targets-csv-gz", type=Path)
    parser.add_argument("--selection-targets-sha256")
    parser.add_argument("--include-b4", action="store_true")
    parser.add_argument("--out-predictions-csv-gz", required=True, type=Path)
    parser.add_argument("--out-jsonl", required=True, type=Path)
    parser.add_argument("--out-txt", required=True, type=Path)
    parser.add_argument("--out-dependencies-json", required=True, type=Path)
    parser.add_argument("--run-suffix", required=True)
    parser.add_argument("--script-sha256", required=True)
    parser.add_argument("--frozen-run", action="store_true")
    return parser.parse_args()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def domain_hash(domain: str, value: bytes | str) -> str:
    payload = value.encode("utf-8") if isinstance(value, str) else value
    return sha256_bytes(domain.encode("utf-8") + b"\0" + payload)


def canonical_json(value: Any) -> str:
    return json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    )


def canonical_json_bytes(value: Any) -> bytes:
    return canonical_json(value).encode("utf-8")


def read_varint(data: bytes, position: int) -> tuple[int, int]:
    value = 0
    shift = 0
    while True:
        if position >= len(data):
            raise ProtocolError("truncated protobuf varint")
        byte = data[position]
        position += 1
        value |= (byte & 0x7F) << shift
        if byte < 0x80:
            return value, position
        shift += 7
        if shift >= 70:
            raise ProtocolError("protobuf varint exceeds 64 bits")


def iter_wire_fields(data: bytes) -> Iterator[WireField]:
    position = 0
    while position < len(data):
        start = position
        tag, position = read_varint(data, position)
        number = tag >> 3
        wire_type = tag & 7
        if number == 0:
            raise ProtocolError("zero protobuf field number")
        payload = None
        scalar: int | bytes | None = None
        if wire_type == 0:
            scalar, position = read_varint(data, position)
        elif wire_type == 1:
            end = position + 8
            if end > len(data):
                raise ProtocolError("truncated fixed64")
            scalar = data[position:end]
            position = end
        elif wire_type == 2:
            length, position = read_varint(data, position)
            end = position + length
            if end > len(data):
                raise ProtocolError("truncated length-delimited field")
            payload = data[position:end]
            position = end
        elif wire_type == 5:
            end = position + 4
            if end > len(data):
                raise ProtocolError("truncated fixed32")
            scalar = data[position:end]
            position = end
        else:
            raise ProtocolError(f"unsupported protobuf wire type {wire_type}")
        yield WireField(number, wire_type, data[start:position], payload, scalar)


def validate_run(args: argparse.Namespace) -> dict[str, Any]:
    script_hash = sha256_file(Path(__file__))
    if script_hash != args.script_sha256:
        raise ProtocolError("script hash mismatch")
    suffix = f"_{args.run_suffix}"
    endings = {
        args.out_predictions_csv_gz: f"{suffix}.csv.gz",
        args.out_jsonl: f"{suffix}.jsonl",
        args.out_txt: f"{suffix}.txt",
        args.out_dependencies_json: f"{suffix}.json",
    }
    for output, ending in endings.items():
        if not output.name.endswith(ending):
            raise ProtocolError(f"output lacks common suffix: {output}")
        if output.exists():
            raise FileExistsError(f"refusing to overwrite {output}")
        output.parent.mkdir(parents=True, exist_ok=True)
    if args.frozen_run and not Path(__file__).stem.endswith(suffix):
        raise ProtocolError("frozen script name lacks run suffix")
    if sys.version_info[:2] != (3, 10):
        raise ProtocolError(f"Python 3.10 required, got {platform.python_version()}")
    if args.source_pb_gz.stat().st_size != SOURCE_SIZE:
        raise ProtocolError("unexpected source size")
    if sha256_file(args.source_pb_gz) != SOURCE_SHA256:
        raise ProtocolError("unexpected source hash")
    if sha256_file(args.i0_manifest_csv_gz) != I0_MANIFEST_SHA256:
        raise ProtocolError("unexpected I0 manifest hash")
    if sha256_file(args.construction_targets_csv_gz) != CONSTRUCTION_TARGETS_SHA256:
        raise ProtocolError("unexpected construction-target hash")
    if args.mode == "construction-cv":
        if args.selection_targets_csv_gz is not None or args.selection_targets_sha256:
            raise ProtocolError("construction-cv forbids selection targets")
    else:
        if args.selection_targets_csv_gz is None or not args.selection_targets_sha256:
            raise ProtocolError("selection-eval requires selection targets and hash")
        if sha256_file(args.selection_targets_csv_gz) != args.selection_targets_sha256:
            raise ProtocolError("selection-target hash mismatch")
    reaction_pb2 = args.ord_schema_python_root / "ord_schema/proto/reaction_pb2.py"
    if sha256_file(reaction_pb2) != REACTION_PB2_SHA256:
        raise ProtocolError("unexpected reaction_pb2.py hash")
    distributions = {
        name: importlib.metadata.version(name) for name in EXPECTED_DISTRIBUTIONS
    }
    if distributions != EXPECTED_DISTRIBUTIONS:
        raise ProtocolError(f"unexpected distributions: {distributions}")
    return {"script_sha256": script_hash, "distributions": distributions}


def import_dependencies(schema_root: Path) -> dict[str, Any]:
    sys.path.insert(0, str(schema_root.resolve()))
    return {
        "reaction_pb2": importlib.import_module("ord_schema.proto.reaction_pb2"),
        "Chem": importlib.import_module("rdkit.Chem"),
        "Crippen": importlib.import_module("rdkit.Chem.Crippen"),
        "Descriptors": importlib.import_module("rdkit.Chem.Descriptors"),
        "Lipinski": importlib.import_module("rdkit.Chem.Lipinski"),
        "rdFingerprintGenerator": importlib.import_module(
            "rdkit.Chem.rdFingerprintGenerator"
        ),
        "rdMolDescriptors": importlib.import_module("rdkit.Chem.rdMolDescriptors"),
        "np": importlib.import_module("numpy"),
        "sparse": importlib.import_module("scipy.sparse"),
        "stats": importlib.import_module("scipy.stats"),
        "Ridge": importlib.import_module("sklearn.linear_model").Ridge,
        "StandardScaler": importlib.import_module(
            "sklearn.preprocessing"
        ).StandardScaler,
        "ExtraTreesRegressor": importlib.import_module(
            "sklearn.ensemble"
        ).ExtraTreesRegressor,
    }


def parse_dataset(source_path: Path) -> list[bytes]:
    with gzip.open(source_path, "rb") as handle:
        dataset_wire = handle.read()
    reactions = []
    for field in iter_wire_fields(dataset_wire):
        if field.number == 3 and field.payload is not None:
            reactions.append(field.payload)
    if len(reactions) != EXPECTED_REACTIONS:
        raise ProtocolError("unexpected official reaction count")
    return reactions


def sanitize_reaction(reaction_wire: bytes, reaction_pb2: Any) -> Any:
    fields = list(iter_wire_fields(reaction_wire))
    unknown = sorted({field.number for field in fields} - REACTION_FIELDS)
    if unknown:
        raise ProtocolError(f"unknown Reaction fields: {unknown}")
    allowed = [field.raw for field in fields if field.number in SANITIZED_REACTION_FIELDS]
    return reaction_pb2.Reaction.FromString(b"".join(allowed))


def enum_name(enum: Any, value: int) -> str:
    return enum.Name(value)


def canonical_component(
    component: Any,
    reaction_pb2: Any,
    chemistry: Any,
) -> tuple[str, str, Any]:
    role = enum_name(
        reaction_pb2.ReactionRole.ReactionRoleType,
        component.reaction_role,
    )
    if role in {"PRODUCT", "BYPRODUCT", "SIDE_PRODUCT"}:
        raise ProtocolError("target role appeared in Reaction.inputs")
    smiles = [
        identifier.value
        for identifier in component.identifiers
        if enum_name(
            reaction_pb2.CompoundIdentifier.CompoundIdentifierType,
            identifier.type,
        )
        == "SMILES"
    ]
    if len(smiles) != 1:
        raise ProtocolError("expected exactly one input SMILES")
    molecule = chemistry.MolFromSmiles(smiles[0])
    if molecule is None:
        raise ProtocolError("RDKit rejected an input SMILES")
    canonical = chemistry.MolToSmiles(
        molecule,
        canonical=True,
        isomericSmiles=True,
    )
    return canonical, role, molecule


def amount_value(component: Any) -> tuple[float, float]:
    kind = component.amount.WhichOneof("kind")
    if kind not in {"moles", "volume"}:
        raise ProtocolError(f"unsupported amount kind {kind}")
    value = getattr(component.amount, kind)
    if not value.HasField("value") or not math.isfinite(value.value):
        raise ProtocolError("invalid component amount")
    if kind == "moles":
        return float(value.value), 0.0
    return 0.0, float(value.value)


def molecule_descriptors(molecule: Any, deps: dict[str, Any]) -> tuple[float, ...]:
    chemistry = deps["Chem"]
    crippen = deps["Crippen"]
    descriptors = deps["Descriptors"]
    lipinski = deps["Lipinski"]
    rdmd = deps["rdMolDescriptors"]
    atoms = list(molecule.GetAtoms())
    aromatic_fraction = (
        sum(atom.GetIsAromatic() for atom in atoms) / len(atoms) if atoms else 0.0
    )
    return (
        float(descriptors.MolWt(molecule)),
        float(crippen.MolLogP(molecule)),
        float(rdmd.CalcTPSA(molecule)),
        float(lipinski.NumHDonors(molecule)),
        float(lipinski.NumHAcceptors(molecule)),
        float(lipinski.NumRotatableBonds(molecule)),
        float(rdmd.CalcNumRings(molecule)),
        float(rdmd.CalcFractionCSP3(molecule)),
        float(molecule.GetNumHeavyAtoms()),
        float(chemistry.GetFormalCharge(molecule)),
        float(rdmd.CalcNumAromaticRings(molecule)),
        float(rdmd.CalcNumHeteroatoms(molecule)),
        float(rdmd.CalcLabuteASA(molecule)),
        float(aromatic_fraction),
    )


def fingerprint_indices(molecule: Any, generator: Any) -> tuple[int, ...]:
    return tuple(int(index) for index in generator.GetFingerprint(molecule).GetOnBits())


def load_manifest(path: Path) -> dict[str, dict[str, str]]:
    with gzip.open(path, "rt", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        if tuple(reader.fieldnames or ()) != EXPECTED_MANIFEST_COLUMNS:
            raise ProtocolError("unexpected manifest columns")
        rows = list(reader)
    if len(rows) != EXPECTED_REACTIONS:
        raise ProtocolError("unexpected manifest row count")
    indexed = {row["reaction_id_sha256"]: row for row in rows}
    if len(indexed) != len(rows):
        raise ProtocolError("duplicate manifest reaction hash")
    return indexed


def build_intrinsic_maps(
    source_path: Path,
    manifest_path: Path,
    deps: dict[str, Any],
) -> tuple[
    dict[str, tuple[int, ...]],
    dict[str, tuple[float, ...]],
    dict[str, dict[int, float]],
    dict[str, tuple[float, ...]],
    dict[str, Any],
]:
    reaction_pb2 = deps["reaction_pb2"]
    chemistry = deps["Chem"]
    generator = deps["rdFingerprintGenerator"].GetMorganGenerator(
        radius=2,
        fpSize=FP_SIZE,
    )
    manifest = load_manifest(manifest_path)
    species_smiles: dict[str, str] = {}
    species_fp: dict[str, tuple[int, ...]] = {}
    species_desc: dict[str, tuple[float, ...]] = {}
    env_sparse: dict[str, dict[int, float]] = {}
    env_dense: dict[str, tuple[float, ...]] = {}
    seen_reactions: set[str] = set()
    identity_mismatches = 0

    for reaction_wire in parse_dataset(source_path):
        reaction = sanitize_reaction(reaction_wire, reaction_pb2)
        if not reaction.reaction_id:
            raise ProtocolError("missing reaction_id")
        reaction_hash = domain_hash("cp0-reaction-id-v1", reaction.reaction_id)
        if reaction_hash in seen_reactions:
            raise ProtocolError("duplicate reaction_id")
        seen_reactions.add(reaction_hash)
        reference = manifest.get(reaction_hash)
        if reference is None:
            raise ProtocolError("reaction absent from manifest")

        semantic_items: list[Any] = []
        partners: dict[str, str] = {}
        group_sparse: defaultdict[int, float] = defaultdict(float)
        group_dense = [
            [0.0] * (5 + 14 + 2)
            for _ in GROUPS
        ]
        for group, reaction_input in sorted(reaction.inputs.items()):
            if group not in GROUP_INDEX:
                raise ProtocolError(f"unexpected input group {group}")
            group_index = GROUP_INDEX[group]
            meta = reaction_pb2.ReactionInput()
            meta.CopyFrom(reaction_input)
            meta.ClearField("components")
            meta_hex = meta.SerializeToString(deterministic=True).hex()
            if meta_hex:
                semantic_items.append((group, "input_meta", meta_hex))
            group_dense[group_index][-2] = float(reaction_input.addition_order)
            if reaction_input.HasField("addition_time"):
                addition_time = reaction_input.addition_time
                if not addition_time.HasField("value"):
                    raise ProtocolError("addition time lacks value")
                group_dense[group_index][-1] = float(addition_time.value)

            for component in reaction_input.components:
                canonical, role, molecule = canonical_component(
                    component,
                    reaction_pb2,
                    chemistry,
                )
                identity = domain_hash("cp0-molecule-v1", canonical)
                previous = species_smiles.setdefault(identity, canonical)
                if previous != canonical:
                    raise ProtocolError("molecule-hash collision")
                if identity not in species_fp:
                    species_fp[identity] = fingerprint_indices(molecule, generator)
                    species_desc[identity] = molecule_descriptors(molecule, deps)
                amount_moles, amount_volume = amount_value(component)
                amount_hex = component.amount.SerializeToString(
                    deterministic=True
                ).hex()
                if role == "REACTANT" and group in {"amine", "carboxylic acid"}:
                    if group in partners:
                        raise ProtocolError("duplicate reaction partner")
                    partners[group] = identity
                    semantic_items.append((group, role, "PARTNER", amount_hex))
                else:
                    semantic_items.append((group, role, canonical, amount_hex))
                    dense = group_dense[group_index]
                    dense[0] += 1.0
                    dense[1] += float(role == "REAGENT")
                    dense[2] += float(role == "SOLVENT")
                    dense[3] += amount_moles
                    dense[4] += amount_volume
                    for index, value in enumerate(species_desc[identity]):
                        dense[5 + index] += value
                    for bit in species_fp[identity]:
                        group_sparse[group_index * FP_SIZE + bit] += 1.0
        if set(partners) != {"amine", "carboxylic acid"}:
            raise ProtocolError("reaction partners missing")
        conditions_hex = reaction.conditions.SerializeToString(
            deterministic=True
        ).hex()
        semantic_hash = domain_hash(
            "cp0-semantic-condition-v1",
            canonical_json_bytes([sorted(semantic_items), conditions_hex]).decode(
                "utf-8"
            ),
        )
        observed = (
            partners["amine"],
            partners["carboxylic acid"],
            semantic_hash,
        )
        expected = (
            reference["amine_sha256"],
            reference["acid_sha256"],
            reference["semantic_condition_sha256"],
        )
        if observed != expected:
            identity_mismatches += 1
        dense_flat = tuple(value for group in group_dense for value in group)
        old_sparse = env_sparse.setdefault(semantic_hash, dict(group_sparse))
        old_dense = env_dense.setdefault(semantic_hash, dense_flat)
        if old_sparse != dict(group_sparse) or old_dense != dense_flat:
            raise ProtocolError("semantic environment maps to unequal intrinsic features")

    if identity_mismatches != 0 or len(seen_reactions) != len(manifest):
        raise ProtocolError("source/manifest intrinsic identity mismatch")
    audit = {
        "record_type": "intrinsic_input_audit",
        "official_reactions": len(seen_reactions),
        "species": len(species_fp),
        "environments": len(env_sparse),
        "source_manifest_mismatches": identity_mismatches,
        "outcome_fields_deserialized": 0,
        "target_values_deserialized_from_source": 0,
        "hashes_used_as_numeric_features_by_c0_bir": False,
    }
    return species_fp, species_desc, env_sparse, env_dense, audit


def load_targets(path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    with gzip.open(path, "rt", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        if tuple(reader.fieldnames or ()) != TARGET_COLUMNS:
            raise ProtocolError("unexpected target columns")
        for row in reader:
            numerator = int(row["target_numerator"])
            denominator = int(row["target_denominator"])
            count = int(row["row_count"])
            if denominator <= 0 or count <= 0 or not 0 <= numerator <= 100 * denominator:
                raise ProtocolError("invalid exact target")
            rows.append(
                {
                    "amine": row["amine_sha256"],
                    "acid": row["acid_sha256"],
                    "environment": row["semantic_condition_sha256"],
                    "target": float(Fraction(numerator, denominator)),
                    "target_numerator": numerator,
                    "target_denominator": denominator,
                    "row_count": count,
                }
            )
    keys = {(row["amine"], row["acid"], row["environment"]) for row in rows}
    if len(keys) != len(rows):
        raise ProtocolError("duplicate grouped target key")
    return rows


def internal_bilateral_split(
    construction: list[dict[str, Any]],
) -> tuple[list[dict[str, Any]], list[dict[str, Any]], dict[str, Any]]:
    amines = sorted({row["amine"] for row in construction})
    acids = sorted({row["acid"] for row in construction})
    ranked_amines = sorted(
        amines,
        key=lambda value: domain_hash("cp0-cv-amine-v1", value),
    )
    ranked_acids = sorted(
        acids,
        key=lambda value: domain_hash("cp0-cv-acid-v1", value),
    )
    validation_amines = set(ranked_amines[: max(1, len(amines) // 5)])
    validation_acids = set(ranked_acids[: max(1, len(acids) // 5)])
    train = [
        row
        for row in construction
        if row["amine"] not in validation_amines
        and row["acid"] not in validation_acids
    ]
    validation = [
        row
        for row in construction
        if row["amine"] in validation_amines and row["acid"] in validation_acids
    ]
    if not train or not validation:
        raise ProtocolError("empty internal bilateral split")
    audit = {
        "record_type": "evaluation_split",
        "mode": "construction-cv",
        "train_groups": len(train),
        "evaluation_groups": len(validation),
        "train_amines": len({row["amine"] for row in train}),
        "train_acids": len({row["acid"] for row in train}),
        "evaluation_amines": len({row["amine"] for row in validation}),
        "evaluation_acids": len({row["acid"] for row in validation}),
        "evaluation_amine_overlap": len(
            {row["amine"] for row in train} & {row["amine"] for row in validation}
        ),
        "evaluation_acid_overlap": len(
            {row["acid"] for row in train} & {row["acid"] for row in validation}
        ),
    }
    return train, validation, audit


def csr_from_index_lists(index_lists: Iterable[Iterable[int]], width: int, deps: dict[str, Any]) -> Any:
    np = deps["np"]
    sparse = deps["sparse"]
    indices: list[int] = []
    indptr = [0]
    for row in index_lists:
        indices.extend(row)
        indptr.append(len(indices))
    data = np.ones(len(indices), dtype=np.float64)
    return sparse.csr_matrix(
        (data, np.asarray(indices), np.asarray(indptr)),
        shape=(len(indptr) - 1, width),
    )


def csr_from_maps(maps: Iterable[dict[int, float]], width: int, deps: dict[str, Any]) -> Any:
    np = deps["np"]
    sparse = deps["sparse"]
    indices: list[int] = []
    values: list[float] = []
    indptr = [0]
    for mapping in maps:
        for index, value in sorted(mapping.items()):
            indices.append(index)
            values.append(value)
        indptr.append(len(indices))
    return sparse.csr_matrix(
        (
            np.asarray(values, dtype=np.float64),
            np.asarray(indices),
            np.asarray(indptr),
        ),
        shape=(len(indptr) - 1, width),
    )


def feature_matrices(
    rows: list[dict[str, Any]],
    species_fp: dict[str, tuple[int, ...]],
    species_desc: dict[str, tuple[float, ...]],
    env_sparse: dict[str, dict[int, float]],
    env_dense: dict[str, tuple[float, ...]],
    environment_order: dict[str, int],
    deps: dict[str, Any],
) -> tuple[Any, Any]:
    np = deps["np"]
    sparse = deps["sparse"]
    for row in rows:
        if row["amine"] not in species_fp or row["acid"] not in species_fp:
            raise ProtocolError("target refers to unknown molecular structure")
        if row["environment"] not in env_sparse:
            raise ProtocolError("target refers to unknown environment")
    amine_fp = csr_from_index_lists(
        (species_fp[row["amine"]] for row in rows),
        FP_SIZE,
        deps,
    )
    acid_fp = csr_from_index_lists(
        (species_fp[row["acid"]] for row in rows),
        FP_SIZE,
        deps,
    )
    env_onehot = csr_from_index_lists(
        ((environment_order[row["environment"]],) for row in rows),
        len(environment_order),
        deps,
    )
    baseline = sparse.hstack((amine_fp, acid_fp, env_onehot), format="csr")

    shared = amine_fp.multiply(acid_fp)
    symmetric_gap = amine_fp + acid_fp - 2.0 * shared
    environment_response = csr_from_maps(
        (env_sparse[row["environment"]] for row in rows),
        len(GROUPS) * FP_SIZE,
        deps,
    )
    amine_desc = np.asarray([species_desc[row["amine"]] for row in rows])
    acid_desc = np.asarray([species_desc[row["acid"]] for row in rows])
    environment_desc = np.asarray([env_dense[row["environment"]] for row in rows])
    dense_causal = np.hstack(
        (
            amine_desc,
            acid_desc,
            np.abs(amine_desc - acid_desc),
            amine_desc * acid_desc,
            environment_desc,
        )
    )
    causal = sparse.hstack(
        (
            amine_fp,
            acid_fp,
            symmetric_gap,
            shared,
            environment_response,
            sparse.csr_matrix(dense_causal),
        ),
        format="csr",
    )
    return baseline, causal


def tanimoto(left: tuple[int, ...], right: tuple[int, ...]) -> float:
    left_set = set(left)
    right_set = set(right)
    union = len(left_set | right_set)
    return len(left_set & right_set) / union if union else 1.0


def b2_predictions(
    train: list[dict[str, Any]],
    evaluation: list[dict[str, Any]],
    species_fp: dict[str, tuple[int, ...]],
) -> dict[int, list[float]]:
    by_environment: defaultdict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in train:
        by_environment[row["environment"]].append(row)
    similarity_cache: dict[tuple[str, str], float] = {}

    def similarity(left: str, right: str) -> float:
        key = (left, right)
        if key not in similarity_cache:
            similarity_cache[key] = tanimoto(species_fp[left], species_fp[right])
        return similarity_cache[key]

    predictions = {k: [] for k in K_VALUES}
    for row in evaluation:
        candidates = []
        for candidate in by_environment[row["environment"]]:
            pair_similarity = (
                similarity(row["amine"], candidate["amine"])
                + similarity(row["acid"], candidate["acid"])
            ) / 2.0
            candidates.append((pair_similarity, candidate["target"]))
        candidates.sort(key=lambda value: (-value[0], value[1]))
        if not candidates:
            raise ProtocolError("B2 has no exact-condition neighbor")
        for k in K_VALUES:
            selected = candidates[:k]
            weights = [max(similarity_value, 1e-6) ** 2 for similarity_value, _ in selected]
            predictions[k].append(
                sum(weight * target for weight, (_, target) in zip(weights, selected))
                / sum(weights)
            )
    return predictions


def fit_ridge_predictions(
    x_train: Any,
    y_train: Any,
    x_evaluation: Any,
    deps: dict[str, Any],
) -> dict[float, Any]:
    results = {}
    for alpha in ALPHAS:
        scaler = deps["StandardScaler"](with_mean=False)
        scaled_train = scaler.fit_transform(x_train)
        scaled_evaluation = scaler.transform(x_evaluation)
        model = deps["Ridge"](alpha=alpha, solver="lsqr")
        model.fit(scaled_train, y_train)
        results[alpha] = model.predict(scaled_evaluation)
    return results


def metrics(observed: Any, predicted: Any, deps: dict[str, Any]) -> dict[str, float]:
    np = deps["np"]
    clipped = np.clip(np.asarray(predicted, dtype=np.float64), 0.0, 100.0)
    residual = clipped - observed
    correlation = deps["stats"].spearmanr(observed, clipped).statistic
    return {
        "mae": float(np.mean(np.abs(residual))),
        "rmse": float(np.sqrt(np.mean(residual**2))),
        "spearman": float(correlation) if math.isfinite(correlation) else 0.0,
        "median_absolute_error": float(np.median(np.abs(residual))),
        "p90_absolute_error": float(np.quantile(np.abs(residual), 0.9)),
    }


def evaluate(
    train: list[dict[str, Any]],
    evaluation: list[dict[str, Any]],
    species_fp: dict[str, tuple[int, ...]],
    species_desc: dict[str, tuple[float, ...]],
    env_sparse: dict[str, dict[int, float]],
    env_dense: dict[str, tuple[float, ...]],
    include_b4: bool,
    deps: dict[str, Any],
) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    np = deps["np"]
    environment_keys = sorted(env_sparse)
    environment_order = {value: index for index, value in enumerate(environment_keys)}
    x_train_baseline, x_train_causal = feature_matrices(
        train,
        species_fp,
        species_desc,
        env_sparse,
        env_dense,
        environment_order,
        deps,
    )
    x_eval_baseline, x_eval_causal = feature_matrices(
        evaluation,
        species_fp,
        species_desc,
        env_sparse,
        env_dense,
        environment_order,
        deps,
    )
    y_train = np.asarray([row["target"] for row in train], dtype=np.float64)
    observed = np.asarray([row["target"] for row in evaluation], dtype=np.float64)
    predictions: dict[tuple[str, str], Any] = {}

    predictions[("B0", "global_mean")] = np.full(
        len(evaluation),
        float(np.mean(y_train)),
    )
    condition_targets: defaultdict[str, list[float]] = defaultdict(list)
    for row in train:
        condition_targets[row["environment"]].append(row["target"])
    predictions[("B1", "condition_mean")] = np.asarray(
        [
            float(np.mean(condition_targets[row["environment"]]))
            for row in evaluation
        ]
    )
    for k, values in b2_predictions(train, evaluation, species_fp).items():
        predictions[("B2", f"k={k}")] = np.asarray(values)
    for alpha, values in fit_ridge_predictions(
        x_train_baseline,
        y_train,
        x_eval_baseline,
        deps,
    ).items():
        predictions[("B3", f"alpha={alpha:g}")] = values
    for alpha, values in fit_ridge_predictions(
        x_train_causal,
        y_train,
        x_eval_causal,
        deps,
    ).items():
        predictions[("C0-BIR", f"alpha={alpha:g}")] = values

    if include_b4:
        dense_train = x_train_baseline.toarray().astype(np.float32, copy=False)
        dense_eval = x_eval_baseline.toarray().astype(np.float32, copy=False)
        for max_features in ("sqrt", 0.25):
            for min_samples_leaf in (1, 2, 5):
                model = deps["ExtraTreesRegressor"](
                    n_estimators=500,
                    bootstrap=False,
                    random_state=0,
                    n_jobs=1,
                    max_features=max_features,
                    min_samples_leaf=min_samples_leaf,
                )
                model.fit(dense_train, y_train)
                variant = (
                    f"max_features={max_features},min_samples_leaf={min_samples_leaf}"
                )
                predictions[("B4", variant)] = model.predict(dense_eval)

    metric_rows = []
    prediction_rows = []
    for (method, variant), raw_predictions in sorted(predictions.items()):
        clipped = np.clip(np.asarray(raw_predictions), 0.0, 100.0)
        metric_rows.append(
            {
                "record_type": "metric",
                "method": method,
                "variant": variant,
                "evaluation_groups": len(evaluation),
                **metrics(observed, clipped, deps),
            }
        )
        for row, predicted in zip(evaluation, clipped):
            prediction_rows.append(
                {
                    "amine_sha256": row["amine"],
                    "acid_sha256": row["acid"],
                    "semantic_condition_sha256": row["environment"],
                    "method": method,
                    "variant": variant,
                    "observed": format(row["target"], ".17g"),
                    "predicted": format(float(predicted), ".17g"),
                    "absolute_error": format(abs(float(predicted) - row["target"]), ".17g"),
                }
            )
    return metric_rows, prediction_rows


def write_predictions(path: Path, rows: list[dict[str, Any]]) -> None:
    fieldnames = (
        "amine_sha256",
        "acid_sha256",
        "semantic_condition_sha256",
        "method",
        "variant",
        "observed",
        "predicted",
        "absolute_error",
    )
    with path.open("xb") as raw:
        with gzip.GzipFile(filename="", mode="wb", fileobj=raw, mtime=0) as compressed:
            with io.TextIOWrapper(compressed, encoding="utf-8", newline="") as text:
                writer = csv.DictWriter(text, fieldnames=fieldnames, lineterminator="\n")
                writer.writeheader()
                writer.writerows(rows)


def main() -> None:
    args = parse_args()
    provenance = validate_run(args)
    deps = import_dependencies(args.ord_schema_python_root)
    command = shlex.join(sys.argv)
    run_at = dt.datetime.now(dt.timezone.utc).isoformat()
    species_fp, species_desc, env_sparse, env_dense, input_audit = build_intrinsic_maps(
        args.source_pb_gz,
        args.i0_manifest_csv_gz,
        deps,
    )
    construction = load_targets(args.construction_targets_csv_gz)
    if args.mode == "construction-cv":
        train, evaluation, split_audit = internal_bilateral_split(construction)
        selection_targets_opened = False
    else:
        if args.selection_targets_csv_gz is None:
            raise ProtocolError("selection path vanished after validation")
        train = construction
        evaluation = load_targets(args.selection_targets_csv_gz)
        split_audit = {
            "record_type": "evaluation_split",
            "mode": "selection-eval",
            "train_groups": len(train),
            "evaluation_groups": len(evaluation),
            "evaluation_amine_overlap": len(
                {row["amine"] for row in train}
                & {row["amine"] for row in evaluation}
            ),
            "evaluation_acid_overlap": len(
                {row["acid"] for row in train}
                & {row["acid"] for row in evaluation}
            ),
        }
        if split_audit["evaluation_amine_overlap"] != 0:
            raise ProtocolError("selection amine leaked into construction")
        if split_audit["evaluation_acid_overlap"] != 0:
            raise ProtocolError("selection acid leaked into construction")
        selection_targets_opened = True

    metric_rows, prediction_rows = evaluate(
        train,
        evaluation,
        species_fp,
        species_desc,
        env_sparse,
        env_dense,
        args.include_b4,
        deps,
    )
    write_predictions(args.out_predictions_csv_gz, prediction_rows)
    predictions_hash = sha256_file(args.out_predictions_csv_gz)
    run_record = {
        "record_type": "run",
        "command": command,
        "run_at_utc": run_at,
        "mode": args.mode,
        "script_sha256": provenance["script_sha256"],
        "construction_targets_sha256": CONSTRUCTION_TARGETS_SHA256,
        "selection_targets_sha256": args.selection_targets_sha256,
        "selection_targets_opened": selection_targets_opened,
        "held_out_test_targets_opened": False,
        "include_b4": args.include_b4,
        "predictions_csv_gz_sha256": predictions_hash,
        "verdict": "CP0_EMPIRICAL_COMPARISON_COMPLETED",
    }
    with args.out_jsonl.open("x", encoding="utf-8", newline="\n") as handle:
        for record in (run_record, input_audit, split_audit, *metric_rows):
            handle.write(canonical_json(record) + "\n")

    dependencies = {
        "command": command,
        "python_version": platform.python_version(),
        "script_sha256": provenance["script_sha256"],
        "source_sha256": SOURCE_SHA256,
        "i0_manifest_sha256": I0_MANIFEST_SHA256,
        "reaction_pb2_sha256": REACTION_PB2_SHA256,
        "construction_targets_sha256": CONSTRUCTION_TARGETS_SHA256,
        "selection_targets_sha256": args.selection_targets_sha256,
        "distributions": provenance["distributions"],
        "wheel_sha256": WHEEL_SHA256,
    }
    with args.out_dependencies_json.open("x", encoding="utf-8", newline="\n") as handle:
        json.dump(dependencies, handle, indent=2, sort_keys=True)
        handle.write("\n")

    ranked = sorted(metric_rows, key=lambda row: (row["mae"], row["method"], row["variant"]))
    summary = [
        f"command: {command}",
        f"script_sha256: {provenance['script_sha256']}",
        f"mode: {args.mode}",
        f"run_at_utc: {run_at}",
        f"train_groups: {len(train)}",
        f"evaluation_groups: {len(evaluation)}",
        f"selection_targets_opened: {str(selection_targets_opened).lower()}",
        "held_out_test_targets_opened: false",
        f"predictions_csv_gz_sha256: {predictions_hash}",
    ]
    for row in ranked:
        summary.append(
            f"{row['method']} {row['variant']} MAE={row['mae']:.8f} "
            f"RMSE={row['rmse']:.8f} Spearman={row['spearman']:.8f}"
        )
    summary.append("verdict: CP0_EMPIRICAL_COMPARISON_COMPLETED")
    args.out_txt.write_text("\n".join(summary) + "\n", encoding="utf-8")
    print(summary[-1])


if __name__ == "__main__":
    main()
