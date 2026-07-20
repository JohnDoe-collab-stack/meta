#!/usr/bin/env python3
"""Audit CP0-DATA-I0 des entrées ORD sans décoder les valeurs cibles.

Le conteneur protobuf est parcouru au niveau binaire. Seuls ``Reaction.inputs``,
``Reaction.conditions`` et ``Reaction.reaction_id`` sont désérialisés. Les
identifiants réactionnels, produits et valeurs de mesure restent des enveloppes
protobuf opaques. Leur type et leur présence peuvent être comptés sans lire
leur contenu chimique ou numérique.
"""

from __future__ import annotations

import argparse
from collections import Counter, defaultdict
import csv
from dataclasses import dataclass
import datetime as dt
import gzip
import hashlib
import importlib
import importlib.metadata
import io
import json
from pathlib import Path
import platform
import shlex
import sys
from typing import Any, Iterable, Iterator


DATASET_ID = "ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41"
DATASET_NAME = "AIChemEco amide coupling conditions 47k dataset"
SOURCE_URL = (
    "https://media.githubusercontent.com/media/open-reaction-database/"
    "ord-data/ddb0d25770c80a0a6fcf9948c26e1c8f828cb8ad/data/47/"
    "ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41.pb.gz"
)
SOURCE_SHA256 = "103c485fc009ee66f525c140611c8596d31f0673cdbb2ec16ec497ea44a58f6f"
SOURCE_SIZE = 8_753_257
ORD_DATA_COMMIT = "ddb0d25770c80a0a6fcf9948c26e1c8f828cb8ad"
ORD_SCHEMA_COMMIT = "aeda34931f3a25497dccde0f68aa789b5830962b"
REACTION_PB2_SHA256 = "1ed2befa91faf00e76e9fd1ef555bf0da51c69a0085e5d7dd4db6418751bdd9c"
EXPECTED_RDKIT_VERSION = "2026.03.4"
EXPECTED_DISTRIBUTIONS = {
    "numpy": "2.2.6",
    "pillow": "12.3.0",
    "protobuf": "4.25.8",
    "rdkit": "2026.3.4",
}
WHEEL_SHA256 = {
    "numpy-2.2.6-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl": (
        "fc7b73d02efb0e18c000e9ad8b83480dfcd5dfd11065997ed4c6747470ae8915"
    ),
    "pillow-12.3.0-cp310-cp310-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl": (
        "f0606c8bf2cdefea14a43530f7657cbbb7ecf1c4222512492ef4a4434a9501ec"
    ),
    "protobuf-4.25.8-cp37-abi3-manylinux2014_x86_64.whl": (
        "83e6e54e93d2b696a92cad6e6efc924f3850f82b52e1563778dfab8b355101b0"
    ),
    "rdkit-2026.3.4-cp310-cp310-manylinux_2_28_x86_64.whl": (
        "974830cdcdb95f825fc1038824af0031e7ac537e526485a5f30e58260d03bc39"
    ),
}

EXPECTED_REACTIONS = 47_015
EXPECTED_AMINES = 70
EXPECTED_ACIDS = 66
EXPECTED_PAIRS = 632
EXPECTED_LABEL_CONDITIONS = 95
EXPECTED_SEMANTIC_CONDITIONS = 94
ALLOWED_REACTION_FIELDS = frozenset({2, 4, 10})
REACTION_FIELD_NAMES = {
    1: "identifiers",
    2: "inputs",
    3: "setup",
    4: "conditions",
    5: "notes",
    6: "observations",
    7: "workups",
    8: "outcomes",
    9: "provenance",
    10: "reaction_id",
}
TARGET_VALUE_FIELD_NAMES = {
    8: "percentage",
    9: "float_value",
    10: "string_value",
    11: "amount",
    12: "retention_time",
    13: "mass_spec_details",
    14: "selectivity",
    15: "wavelength",
}
FORBIDDEN_INPUT_ROLES = frozenset({"PRODUCT", "BYPRODUCT", "SIDE_PRODUCT"})
MANIFEST_COLUMNS = (
    "reaction_id_sha256",
    "amine_sha256",
    "acid_sha256",
    "semantic_condition_sha256",
    "label_condition_sha256",
    "compartment",
)
VERDICT = "GO-DYNAMIC"


@dataclass(frozen=True)
class WireField:
    """Champ protobuf découpé sans interprétation de ses messages imbriqués."""

    number: int
    wire_type: int
    raw: bytes
    payload: bytes | None
    scalar: int | None


@dataclass(frozen=True)
class MoleculeProfile:
    """Propriétés ontologiques d'une structure d'entrée canonicalisée."""

    elements: tuple[str, ...]
    bond_types: tuple[str, ...]
    total_formal_charge: int
    has_aromatic_bond: bool
    has_chiral_center: bool
    has_stereo_bond: bool
    has_isotope: bool
    has_radical: bool
    fragment_count: int
    cw1_compatible: bool


@dataclass(frozen=True)
class InputRow:
    """Manifest sans cible d'une réaction admissible."""

    reaction_id_sha256: str
    amine: str
    acid: str
    semantic_condition_sha256: str
    label_condition_sha256: str
    target_envelope_complete: bool


def parse_args() -> argparse.Namespace:
    """Lit le contrat complet du run reproductible."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-pb-gz", required=True, type=Path)
    parser.add_argument("--ord-schema-python-root", required=True, type=Path)
    parser.add_argument("--out-jsonl", required=True, type=Path)
    parser.add_argument("--out-txt", required=True, type=Path)
    parser.add_argument("--out-manifest-csv-gz", required=True, type=Path)
    parser.add_argument("--out-dependencies-json", required=True, type=Path)
    parser.add_argument("--run-suffix", required=True)
    parser.add_argument("--script-sha256", required=True)
    parser.add_argument(
        "--frozen-run",
        action="store_true",
        help="Exige le suffixe timestamp+hash dans le nom du script exécuté.",
    )
    return parser.parse_args()


def sha256_bytes(data: bytes) -> str:
    """Calcule un SHA-256 hexadécimal."""
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    """Calcule le SHA-256 d'un fichier sans le charger entièrement."""
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def domain_hash(domain: str, value: str) -> str:
    """Hash à séparation de domaine pour identités et partitions."""
    return sha256_bytes(domain.encode("utf-8") + b"\0" + value.encode("utf-8"))


def canonical_json_bytes(value: Any) -> bytes:
    """Sérialise du JSON canonique UTF-8."""
    return json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")


def canonical_json_line(value: dict[str, Any]) -> str:
    """Sérialise un enregistrement JSONL canonique."""
    return canonical_json_bytes(value).decode("utf-8")


def read_varint(data: bytes, position: int) -> tuple[int, int]:
    """Lit un varint protobuf borné à 64 bits."""
    value = 0
    shift = 0
    while True:
        if position >= len(data):
            raise ValueError("varint protobuf tronqué")
        byte = data[position]
        position += 1
        value |= (byte & 0x7F) << shift
        if byte < 0x80:
            return value, position
        shift += 7
        if shift >= 70:
            raise ValueError("varint protobuf trop long")


def iter_wire_fields(data: bytes) -> Iterator[WireField]:
    """Découpe les champs protobuf usuels, en refusant les groupes obsolètes."""
    position = 0
    while position < len(data):
        start = position
        tag, position = read_varint(data, position)
        number = tag >> 3
        wire_type = tag & 0x07
        if number == 0:
            raise ValueError("numéro de champ protobuf nul")
        payload = None
        scalar = None
        if wire_type == 0:
            scalar, position = read_varint(data, position)
        elif wire_type == 1:
            position += 8
        elif wire_type == 2:
            length, position = read_varint(data, position)
            end = position + length
            if end > len(data):
                raise ValueError("champ protobuf length-delimited tronqué")
            payload = data[position:end]
            position = end
        elif wire_type == 5:
            position += 4
        else:
            raise ValueError(f"wire type protobuf refusé: {wire_type}")
        if position > len(data):
            raise ValueError("champ protobuf fixe tronqué")
        yield WireField(number, wire_type, data[start:position], payload, scalar)


def validate_run_contract(args: argparse.Namespace) -> dict[str, str]:
    """Vérifie source, script, dépendances et noms avant tout calcul."""
    script_sha256 = sha256_file(Path(__file__))
    if script_sha256 != args.script_sha256:
        raise ValueError(
            f"hash script inattendu: calculé={script_sha256}, "
            f"attendu={args.script_sha256}"
        )
    suffix = f"_{args.run_suffix}"
    expected_outputs = {
        args.out_jsonl: f"{suffix}.jsonl",
        args.out_txt: f"{suffix}.txt",
        args.out_manifest_csv_gz: f"{suffix}.csv.gz",
        args.out_dependencies_json: f"{suffix}.json",
    }
    for output, ending in expected_outputs.items():
        if not output.name.endswith(ending):
            raise ValueError(f"sortie sans suffixe commun {ending}: {output}")
        if output.exists():
            raise FileExistsError(f"refus d'écraser une sortie: {output}")
    if args.frozen_run and not Path(__file__).stem.endswith(suffix):
        raise ValueError("le script figé ne porte pas le suffixe du run")
    if not args.source_pb_gz.is_file():
        raise FileNotFoundError(args.source_pb_gz)
    if args.source_pb_gz.stat().st_size != SOURCE_SIZE:
        raise ValueError("taille du fichier source inattendue")
    source_sha256 = sha256_file(args.source_pb_gz)
    if source_sha256 != SOURCE_SHA256:
        raise ValueError(f"hash source inattendu: {source_sha256}")
    reaction_pb2_path = (
        args.ord_schema_python_root / "ord_schema" / "proto" / "reaction_pb2.py"
    )
    if sha256_file(reaction_pb2_path) != REACTION_PB2_SHA256:
        raise ValueError("reaction_pb2.py ne correspond pas au commit ORD figé")
    if sys.version_info[:2] != (3, 10):
        raise ValueError(f"Python 3.10 requis, reçu {platform.python_version()}")
    distributions = {
        name: importlib.metadata.version(name) for name in EXPECTED_DISTRIBUTIONS
    }
    if distributions != EXPECTED_DISTRIBUTIONS:
        raise ValueError(
            f"versions Python inattendues: {distributions}, "
            f"attendues={EXPECTED_DISTRIBUTIONS}"
        )
    return {
        "script_sha256": script_sha256,
        "source_sha256": source_sha256,
        "reaction_pb2_sha256": REACTION_PB2_SHA256,
        **{f"distribution_{key}": value for key, value in distributions.items()},
    }


def import_chemistry_dependencies(schema_root: Path) -> tuple[Any, Any, Any]:
    """Importe les dépendances après validation de leur emplacement."""
    sys.path.insert(0, str(schema_root.resolve()))
    reaction_pb2 = importlib.import_module("ord_schema.proto.reaction_pb2")
    chemistry = importlib.import_module("rdkit.Chem")
    rd_base = importlib.import_module("rdkit.rdBase")
    if rd_base.rdkitVersion != EXPECTED_RDKIT_VERSION:
        raise ValueError(f"version RDKit inattendue: {rd_base.rdkitVersion}")
    return reaction_pb2, chemistry, rd_base


def parse_dataset_envelope(data: bytes) -> tuple[str, str, list[bytes]]:
    """Extrait les réactions brutes et les deux métadonnées sûres du Dataset."""
    dataset_name = ""
    dataset_id = ""
    reaction_wires = []
    for field in iter_wire_fields(data):
        if field.number == 1 and field.payload is not None:
            dataset_name = field.payload.decode("utf-8")
        elif field.number == 3 and field.payload is not None:
            reaction_wires.append(field.payload)
        elif field.number == 5 and field.payload is not None:
            dataset_id = field.payload.decode("utf-8")
    if dataset_id != DATASET_ID or dataset_name != DATASET_NAME:
        raise ValueError(
            f"identité Dataset inattendue: id={dataset_id!r}, name={dataset_name!r}"
        )
    if len(reaction_wires) != EXPECTED_REACTIONS:
        raise ValueError(f"nombre de réactions inattendu: {len(reaction_wires)}")
    return dataset_id, dataset_name, reaction_wires


def sanitized_reaction(
    reaction_wire: bytes,
    reaction_pb2: Any,
    skipped_fields: Counter[str],
) -> Any:
    """Désérialise exclusivement les champs autorisés d'une Reaction."""
    allowed = []
    for field in iter_wire_fields(reaction_wire):
        if field.number in ALLOWED_REACTION_FIELDS:
            allowed.append(field.raw)
        else:
            name = REACTION_FIELD_NAMES.get(field.number, f"unknown_{field.number}")
            skipped_fields[name] += 1
            if field.number not in REACTION_FIELD_NAMES:
                raise ValueError(f"champ Reaction inconnu: {field.number}")
    return reaction_pb2.Reaction.FromString(b"".join(allowed))


def measurement_type_name(reaction_pb2: Any, scalar: int | None) -> str:
    """Résout un enum de type de mesure, jamais sa valeur."""
    if scalar is None:
        raise ValueError("enum de mesure absent")
    return reaction_pb2.ProductMeasurement.ProductMeasurementType.Name(scalar)


def product_role_name(reaction_pb2: Any, scalar: int | None) -> str:
    """Résout un enum de rôle produit, jamais sa structure."""
    if scalar is None:
        raise ValueError("enum de rôle produit absent")
    return reaction_pb2.ReactionRole.ReactionRoleType.Name(scalar)


def audit_target_envelopes(
    reaction_wire: bytes,
    reaction_pb2: Any,
    counters: Counter[str],
) -> bool:
    """Vérifie présence/type des cibles sans décoder structure ou nombre."""
    outcome_payloads = [
        field.payload
        for field in iter_wire_fields(reaction_wire)
        if field.number == 8 and field.payload is not None
    ]
    counters[f"outcomes_per_reaction_{len(outcome_payloads)}"] += 1
    products = 0
    desired_products = 0
    yield_measurements = 0
    identity_measurements = 0
    yield_percentage_values = 0
    for outcome_payload in outcome_payloads:
        for outcome_field in iter_wire_fields(outcome_payload):
            if outcome_field.number == 2:
                counters["conversion_envelopes_skipped"] += 1
            if outcome_field.number != 3 or outcome_field.payload is None:
                continue
            products += 1
            product_role = None
            for product_field in iter_wire_fields(outcome_field.payload):
                if product_field.number == 1:
                    counters["product_identifier_envelopes_skipped"] += 1
                elif product_field.number == 2:
                    desired_products += int(bool(product_field.scalar))
                elif product_field.number == 7:
                    product_role = product_role_name(
                        reaction_pb2,
                        product_field.scalar,
                    )
                elif product_field.number == 3 and product_field.payload is not None:
                    measurement_type = None
                    value_fields: list[WireField] = []
                    for measurement_field in iter_wire_fields(product_field.payload):
                        if measurement_field.number == 2:
                            measurement_type = measurement_type_name(
                                reaction_pb2,
                                measurement_field.scalar,
                            )
                        if measurement_field.number in TARGET_VALUE_FIELD_NAMES:
                            value_fields.append(measurement_field)
                    if measurement_type is None:
                        raise ValueError("mesure produit sans type")
                    counters[f"measurement_type_{measurement_type}"] += 1
                    if measurement_type == "YIELD":
                        yield_measurements += 1
                        percentage_fields = [
                            field for field in value_fields if field.number == 8
                        ]
                        if len(percentage_fields) == 1:
                            percentage_payload = percentage_fields[0].payload
                            if percentage_payload is None:
                                raise ValueError("pourcentage sans enveloppe")
                            numeric_envelopes = [
                                field
                                for field in iter_wire_fields(percentage_payload)
                                if field.number == 1
                            ]
                            yield_percentage_values += int(len(numeric_envelopes) == 1)
                            counters["yield_numeric_envelopes_skipped"] += len(
                                numeric_envelopes
                            )
                    elif measurement_type == "IDENTITY":
                        identity_measurements += 1
                    for value_field in value_fields:
                        value_name = TARGET_VALUE_FIELD_NAMES[value_field.number]
                        counters[f"target_value_envelope_{value_name}_skipped"] += 1
            if product_role != "PRODUCT":
                raise ValueError(f"rôle de produit inattendu: {product_role}")
    counters[f"products_per_reaction_{products}"] += 1
    counters[f"desired_products_per_reaction_{desired_products}"] += 1
    counters[f"yield_measurements_per_reaction_{yield_measurements}"] += 1
    counters[f"identity_measurements_per_reaction_{identity_measurements}"] += 1
    counters[f"yield_numeric_values_per_reaction_{yield_percentage_values}"] += 1
    return (
        len(outcome_payloads) == 1
        and products == 1
        and desired_products == 1
        and yield_measurements == 1
        and identity_measurements == 1
        and yield_percentage_values == 1
    )


def enum_name(enum: Any, value: int) -> str:
    """Résout un enum protobuf en texte stable."""
    return enum.Name(value)


def canonicalize_component(
    component: Any,
    reaction_pb2: Any,
    chemistry: Any,
) -> tuple[str, str, MoleculeProfile, list[tuple[str, str]]]:
    """Canonicalise un composant d'entrée et calcule son profil ontologique."""
    identifiers = [
        (
            enum_name(
                reaction_pb2.CompoundIdentifier.CompoundIdentifierType,
                identifier.type,
            ),
            identifier.value,
        )
        for identifier in component.identifiers
    ]
    smiles_values = [value for kind, value in identifiers if kind == "SMILES"]
    if len(smiles_values) != 1:
        raise ValueError(f"un SMILES exact requis, reçu {len(smiles_values)}")
    molecule = chemistry.MolFromSmiles(smiles_values[0])
    if molecule is None:
        raise ValueError("RDKit refuse un SMILES d'entrée")
    canonical = chemistry.MolToSmiles(
        molecule,
        canonical=True,
        isomericSmiles=True,
    )
    role = enum_name(
        reaction_pb2.ReactionRole.ReactionRoleType,
        component.reaction_role,
    )
    if role in FORBIDDEN_INPUT_ROLES:
        raise ValueError(f"rôle cible trouvé dans Reaction.inputs: {role}")
    elements = tuple(sorted({atom.GetSymbol() for atom in molecule.GetAtoms()}))
    bond_types = tuple(sorted({str(bond.GetBondType()) for bond in molecule.GetBonds()}))
    has_aromatic_bond = any(bond.GetIsAromatic() for bond in molecule.GetBonds())
    has_chiral_center = bool(
        chemistry.FindMolChiralCenters(molecule, includeUnassigned=True)
    )
    has_stereo_bond = any(
        str(bond.GetStereo()) != "STEREONONE" for bond in molecule.GetBonds()
    )
    has_isotope = any(atom.GetIsotope() != 0 for atom in molecule.GetAtoms())
    has_radical = any(atom.GetNumRadicalElectrons() != 0 for atom in molecule.GetAtoms())
    fragment_count = len(chemistry.GetMolFrags(molecule))
    total_formal_charge = sum(atom.GetFormalCharge() for atom in molecule.GetAtoms())
    cw1_compatible = (
        set(elements) <= {"C", "N", "O"}
        and total_formal_charge == 0
        and not has_aromatic_bond
        and not has_chiral_center
        and not has_stereo_bond
        and not has_isotope
        and not has_radical
        and fragment_count == 1
        and set(bond_types) <= {"SINGLE", "DOUBLE", "TRIPLE"}
    )
    profile = MoleculeProfile(
        elements=elements,
        bond_types=bond_types,
        total_formal_charge=total_formal_charge,
        has_aromatic_bond=has_aromatic_bond,
        has_chiral_center=has_chiral_center,
        has_stereo_bond=has_stereo_bond,
        has_isotope=has_isotope,
        has_radical=has_radical,
        fragment_count=fragment_count,
        cw1_compatible=cw1_compatible,
    )
    return canonical, role, profile, sorted(identifiers)


def serialize_amount(component: Any) -> tuple[str, bool, str]:
    """Sérialise la quantité d'entrée et rapporte sa complétude sans la publier."""
    amount_kind = component.amount.WhichOneof("kind") or "missing"
    has_numeric_value = False
    if amount_kind not in {"missing", "unmeasured"}:
        amount_value = getattr(component.amount, amount_kind)
        has_numeric_value = amount_value.HasField("value")
    serialized = component.amount.SerializeToString(deterministic=True).hex()
    return amount_kind, has_numeric_value, serialized


def profile_record(
    name: str,
    identities: Iterable[str],
    profiles: dict[str, MoleculeProfile],
) -> dict[str, Any]:
    """Agrège l'ontologie d'un ensemble d'identités sans exposer les structures."""
    selected = [profiles[identity] for identity in sorted(set(identities))]
    elements = sorted({element for profile in selected for element in profile.elements})
    bond_types = sorted(
        {bond_type for profile in selected for bond_type in profile.bond_types}
    )
    properties = {
        "aromatic_bond": sum(profile.has_aromatic_bond for profile in selected),
        "chiral_center": sum(profile.has_chiral_center for profile in selected),
        "stereo_bond": sum(profile.has_stereo_bond for profile in selected),
        "formal_charge_nonzero": sum(
            profile.total_formal_charge != 0 for profile in selected
        ),
        "isotope": sum(profile.has_isotope for profile in selected),
        "radical": sum(profile.has_radical for profile in selected),
        "multifragment": sum(profile.fragment_count != 1 for profile in selected),
    }
    molecules_by_element = {
        element: sum(element in profile.elements for profile in selected)
        for element in elements
    }
    return {
        "record_type": "ontology",
        "scope": name,
        "unique_molecules": len(selected),
        "elements": elements,
        "bond_types": bond_types,
        "molecules_by_element": molecules_by_element,
        "property_counts": properties,
        "cw1_compatible_molecules": sum(
            profile.cw1_compatible for profile in selected
        ),
    }


def allocate_identities(values: Iterable[str], domain: str) -> dict[str, str]:
    """Alloue exactement 60/20/20 % par rang de hash, sans cible."""
    ordered = sorted(set(values), key=lambda value: domain_hash(domain, value))
    construction_end = len(ordered) * 60 // 100
    selection_end = construction_end + len(ordered) * 20 // 100
    allocation = {}
    for index, value in enumerate(ordered):
        if index < construction_end:
            compartment = "construction"
        elif index < selection_end:
            compartment = "selection"
        else:
            compartment = "held_out_test"
        allocation[value] = compartment
    return allocation


def assign_rows(rows: list[InputRow]) -> tuple[list[dict[str, str]], dict[str, Any]]:
    """Applique le split bilatéral et construit le manifest sans cible."""
    amine_allocation = allocate_identities(
        (row.amine for row in rows),
        "cp0-amine-split-v1",
    )
    acid_allocation = allocate_identities(
        (row.acid for row in rows),
        "cp0-acid-split-v1",
    )
    manifest_rows = []
    row_counts: Counter[str] = Counter()
    pair_sets: defaultdict[str, set[tuple[str, str]]] = defaultdict(set)
    semantic_conditions: defaultdict[str, set[str]] = defaultdict(set)
    complete_targets: Counter[str] = Counter()
    for row in rows:
        amine_compartment = amine_allocation[row.amine]
        acid_compartment = acid_allocation[row.acid]
        compartment = (
            amine_compartment
            if amine_compartment == acid_compartment
            else "excluded_cross"
        )
        row_counts[compartment] += 1
        pair_sets[compartment].add((row.amine, row.acid))
        semantic_conditions[compartment].add(row.semantic_condition_sha256)
        complete_targets[compartment] += int(row.target_envelope_complete)
        manifest_rows.append(
            {
                "reaction_id_sha256": row.reaction_id_sha256,
                "amine_sha256": domain_hash("cp0-molecule-v1", row.amine),
                "acid_sha256": domain_hash("cp0-molecule-v1", row.acid),
                "semantic_condition_sha256": row.semantic_condition_sha256,
                "label_condition_sha256": row.label_condition_sha256,
                "compartment": compartment,
            }
        )
    manifest_rows.sort(key=lambda row: row["reaction_id_sha256"])
    allocation_counts = {
        "amine": dict(sorted(Counter(amine_allocation.values()).items())),
        "acid": dict(sorted(Counter(acid_allocation.values()).items())),
    }
    split_record = {
        "record_type": "split",
        "algorithm": "rank_sha256_60_20_20_bilateral_v1",
        "allocation_counts": allocation_counts,
        "row_counts": dict(sorted(row_counts.items())),
        "pair_counts": {
            key: len(value) for key, value in sorted(pair_sets.items())
        },
        "semantic_condition_counts": {
            key: len(value) for key, value in sorted(semantic_conditions.items())
        },
        "complete_target_envelope_counts": dict(sorted(complete_targets.items())),
        "construction_test_amine_overlap": 0,
        "construction_test_acid_overlap": 0,
    }
    return manifest_rows, split_record


def render_manifest(manifest_rows: list[dict[str, str]]) -> bytes:
    """Produit un CSV gzip déterministe, mtime nulle."""
    buffer = io.BytesIO()
    compressed = gzip.GzipFile(filename="", mode="wb", fileobj=buffer, mtime=0)
    text = io.TextIOWrapper(compressed, encoding="utf-8", newline="")
    writer = csv.DictWriter(text, fieldnames=MANIFEST_COLUMNS, lineterminator="\n")
    writer.writeheader()
    writer.writerows(manifest_rows)
    text.flush()
    text.detach()
    compressed.close()
    return buffer.getvalue()


def render_text(
    command: str,
    records: list[dict[str, Any]],
    manifest_sha256: str,
) -> str:
    """Rend le rapport humain en gardant les limites explicites."""
    by_type = {record["record_type"]: record for record in records}
    factorization = by_type["factorization"]
    target = by_type["target_envelopes"]
    split = by_type["split"]
    verdict = by_type["verdict"]
    lines = [
        f"command: {command}",
        f"script_sha256: {by_type['run']['script_sha256']}",
        f"source_sha256: {SOURCE_SHA256}",
        f"manifest_sha256: {manifest_sha256}",
        f"retrieved_run_at_utc: {by_type['run']['run_at_utc']}",
        f"ord_data_commit: {ORD_DATA_COMMIT}",
        f"ord_schema_commit: {ORD_SCHEMA_COMMIT}",
        "product_structures_decoded: 0",
        "target_numeric_values_decoded: 0",
        "reaction_identifiers_decoded: 0",
        f"reactions: {factorization['reactions']}",
        f"amines: {factorization['amines']}",
        f"acids: {factorization['acids']}",
        f"pairs: {factorization['pairs']}",
        f"semantic_conditions: {factorization['semantic_conditions']}",
        f"label_conditions: {factorization['label_conditions']}",
        f"complete_yield_envelopes: {target['complete_yield_envelopes']}",
        f"split_rows: {json.dumps(split['row_counts'], sort_keys=True)}",
        f"split_pairs: {json.dumps(split['pair_counts'], sort_keys=True)}",
        f"verdict: {verdict['verdict']}",
        f"target: {verdict['target']}",
        f"ontology_status: {verdict['ontology_status']}",
        "",
        "interpretation:",
        "Le corpus passe la porte de faisabilite dynamique, pas le test predictif.",
        "Les valeurs de rendement et structures produit restent non decodees.",
        "Le fragment CW1 doit etre etendu avant de representer toutes les entrees.",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    """Exécute l'audit, puis écrit les artefacts uniquement après tous les checks."""
    args = parse_args()
    provenance = validate_run_contract(args)
    reaction_pb2, chemistry, rd_base = import_chemistry_dependencies(
        args.ord_schema_python_root
    )
    command = shlex.join([sys.executable, *sys.argv])
    run_at_utc = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat()

    with gzip.open(args.source_pb_gz, "rb") as handle:
        dataset_wire = handle.read()
    dataset_id, dataset_name, reaction_wires = parse_dataset_envelope(dataset_wire)

    skipped_fields: Counter[str] = Counter()
    target_counters: Counter[str] = Counter()
    input_role_counts: Counter[str] = Counter()
    identifier_type_counts: Counter[str] = Counter()
    amount_counts: Counter[str] = Counter()
    condition_field_counts: Counter[str] = Counter()
    input_meta_field_counts: Counter[str] = Counter()
    raw_smiles: set[str] = set()
    profiles: dict[str, MoleculeProfile] = {}
    molecule_scopes: defaultdict[str, set[str]] = defaultdict(set)
    reaction_id_hashes: set[str] = set()
    rows: list[InputRow] = []
    label_to_semantic: defaultdict[str, Counter[str]] = defaultdict(Counter)

    for reaction_wire in reaction_wires:
        target_complete = audit_target_envelopes(
            reaction_wire,
            reaction_pb2,
            target_counters,
        )
        reaction = sanitized_reaction(
            reaction_wire,
            reaction_pb2,
            skipped_fields,
        )
        if not reaction.reaction_id:
            raise ValueError("reaction_id absent")
        reaction_id_sha256 = domain_hash("cp0-reaction-id-v1", reaction.reaction_id)
        if reaction_id_sha256 in reaction_id_hashes:
            raise ValueError("reaction_id dupliqué")
        reaction_id_hashes.add(reaction_id_sha256)

        for field, _ in reaction.conditions.ListFields():
            condition_field_counts[field.name] += 1

        partners: dict[str, str] = {}
        semantic_items: list[Any] = []
        label_items: list[Any] = []
        for key, reaction_input in sorted(reaction.inputs.items()):
            input_meta = reaction_pb2.ReactionInput()
            input_meta.CopyFrom(reaction_input)
            input_meta.ClearField("components")
            for field, _ in input_meta.ListFields():
                input_meta_field_counts[f"{key}:{field.name}"] += 1
            input_meta_hex = input_meta.SerializeToString(deterministic=True).hex()
            if input_meta_hex:
                item = (key, "input_meta", input_meta_hex)
                semantic_items.append(item)
                label_items.append(item)

            for component in reaction_input.components:
                canonical, role, profile, identifiers = canonicalize_component(
                    component,
                    reaction_pb2,
                    chemistry,
                )
                profiles.setdefault(canonical, profile)
                if profiles[canonical] != profile:
                    raise AssertionError("profil incohérent pour un SMILES canonique")
                raw_smiles.update(value for kind, value in identifiers if kind == "SMILES")
                for kind, _ in identifiers:
                    identifier_type_counts[f"{key}:{role}:{kind}"] += 1
                input_role_counts[f"{key}:{role}"] += 1
                amount_kind, has_numeric_amount, amount_hex = serialize_amount(component)
                amount_counts[f"{key}:{role}:{amount_kind}"] += 1
                amount_counts[
                    f"{key}:{role}:{amount_kind}:numeric_{has_numeric_amount}"
                ] += 1
                molecule_scopes["all_inputs"].add(canonical)

                if role == "REACTANT" and key in {"amine", "carboxylic acid"}:
                    if key in partners:
                        raise ValueError(f"partenaire réactant dupliqué: {key}")
                    partners[key] = canonical
                    scope = "amine_reactants" if key == "amine" else "acid_reactants"
                    molecule_scopes[scope].add(canonical)
                    placeholder = (key, role, "PARTNER", amount_hex)
                    semantic_items.append(placeholder)
                    label_items.append(placeholder)
                else:
                    molecule_scopes["condition_components"].add(canonical)
                    semantic_items.append((key, role, canonical, amount_hex))
                    label_items.append((key, role, identifiers, amount_hex))

        if set(partners) != {"amine", "carboxylic acid"}:
            raise ValueError(f"partenaires requis absents: {sorted(partners)}")
        conditions_hex = reaction.conditions.SerializeToString(
            deterministic=True
        ).hex()
        semantic_condition = domain_hash(
            "cp0-semantic-condition-v1",
            canonical_json_bytes([sorted(semantic_items), conditions_hex]).decode(
                "utf-8"
            ),
        )
        label_condition = domain_hash(
            "cp0-label-condition-v1",
            canonical_json_bytes([sorted(label_items), conditions_hex]).decode("utf-8"),
        )
        label_to_semantic[semantic_condition][label_condition] += 1
        rows.append(
            InputRow(
                reaction_id_sha256=reaction_id_sha256,
                amine=partners["amine"],
                acid=partners["carboxylic acid"],
                semantic_condition_sha256=semantic_condition,
                label_condition_sha256=label_condition,
                target_envelope_complete=target_complete,
            )
        )

    amines = {row.amine for row in rows}
    acids = {row.acid for row in rows}
    pairs = {(row.amine, row.acid) for row in rows}
    semantic_conditions = {row.semantic_condition_sha256 for row in rows}
    label_conditions = {row.label_condition_sha256 for row in rows}
    pair_semantic_conditions = {
        (row.amine, row.acid, row.semantic_condition_sha256) for row in rows
    }
    pair_label_conditions = {
        (row.amine, row.acid, row.label_condition_sha256) for row in rows
    }
    observed = (
        len(rows),
        len(amines),
        len(acids),
        len(pairs),
        len(label_conditions),
        len(semantic_conditions),
    )
    expected = (
        EXPECTED_REACTIONS,
        EXPECTED_AMINES,
        EXPECTED_ACIDS,
        EXPECTED_PAIRS,
        EXPECTED_LABEL_CONDITIONS,
        EXPECTED_SEMANTIC_CONDITIONS,
    )
    if observed != expected:
        raise ValueError(f"factorisation inattendue: {observed}, attendu={expected}")
    if not all(row.target_envelope_complete for row in rows):
        raise ValueError("au moins une enveloppe cible est incomplète")

    manifest_rows, split_record = assign_rows(rows)
    for compartment in ("construction", "selection", "held_out_test"):
        if split_record["row_counts"].get(compartment, 0) < 500:
            raise ValueError(f"split trop petit en lignes: {compartment}")
        if split_record["pair_counts"].get(compartment, 0) < 10:
            raise ValueError(f"split trop petit en paires: {compartment}")
    manifest_bytes = render_manifest(manifest_rows)
    manifest_sha256 = sha256_bytes(manifest_bytes)

    split_label_groups = [
        sorted(counter.values())
        for counter in label_to_semantic.values()
        if len(counter) > 1
    ]
    records: list[dict[str, Any]] = [
        {
            "record_type": "run",
            "command": command,
            "run_at_utc": run_at_utc,
            "script_sha256": provenance["script_sha256"],
            "source_sha256": provenance["source_sha256"],
            "manifest_sha256": manifest_sha256,
            "python_version": platform.python_version(),
            "rdkit_version": rd_base.rdkitVersion,
            "protobuf_distribution_version": provenance["distribution_protobuf"],
        },
        {
            "record_type": "source",
            "dataset_id": dataset_id,
            "dataset_name": dataset_name,
            "source_url": SOURCE_URL,
            "source_size": SOURCE_SIZE,
            "source_sha256": SOURCE_SHA256,
            "ord_data_commit": ORD_DATA_COMMIT,
            "ord_schema_commit": ORD_SCHEMA_COMMIT,
            "reaction_pb2_sha256": REACTION_PB2_SHA256,
        },
        {
            "record_type": "isolation",
            "decoded_reaction_fields": ["inputs", "conditions", "reaction_id"],
            "skipped_reaction_field_counts": dict(sorted(skipped_fields.items())),
            "product_structures_decoded": 0,
            "target_numeric_values_decoded": 0,
            "reaction_identifiers_decoded": 0,
            "setup_decoded": 0,
        },
        {
            "record_type": "input_completeness",
            "input_role_counts": dict(sorted(input_role_counts.items())),
            "identifier_type_counts": dict(sorted(identifier_type_counts.items())),
            "amount_counts": dict(sorted(amount_counts.items())),
            "condition_field_counts": dict(sorted(condition_field_counts.items())),
            "input_meta_field_counts": dict(sorted(input_meta_field_counts.items())),
            "raw_unique_smiles": len(raw_smiles),
            "canonical_unique_smiles": len(profiles),
            "canonicalization_collisions": len(raw_smiles) - len(profiles),
        },
        {
            "record_type": "factorization",
            "reactions": len(rows),
            "amines": len(amines),
            "acids": len(acids),
            "pairs": len(pairs),
            "semantic_conditions": len(semantic_conditions),
            "label_conditions": len(label_conditions),
            "duplicate_pair_semantic_condition_rows": len(rows)
            - len(pair_semantic_conditions),
            "duplicate_pair_label_condition_rows": len(rows)
            - len(pair_label_conditions),
            "semantic_groups_split_by_labels": len(split_label_groups),
            "split_label_group_frequencies": split_label_groups,
        },
        {
            "record_type": "target_envelopes",
            "complete_yield_envelopes": sum(
                row.target_envelope_complete for row in rows
            ),
            "target_type": "desired_product_yield_percentage",
            "counters": dict(sorted(target_counters.items())),
            "product_structures_decoded": 0,
            "target_numeric_values_decoded": 0,
        },
        profile_record("all_inputs", molecule_scopes["all_inputs"], profiles),
        profile_record(
            "amine_reactants",
            molecule_scopes["amine_reactants"],
            profiles,
        ),
        profile_record(
            "acid_reactants",
            molecule_scopes["acid_reactants"],
            profiles,
        ),
        profile_record(
            "condition_components",
            molecule_scopes["condition_components"],
            profiles,
        ),
        split_record,
        {
            "record_type": "verdict",
            "verdict": VERDICT,
            "target": "desired_product_yield_percentage",
            "ontology_status": "EXTENSION_REQUIRED",
            "authorization": "FREEZE_TARGET_PROTOCOL_AND_BUILD_INPUT_LANGUAGE",
            "forbidden_next_actions": [
                "OPEN_HELD_OUT_TARGET_VALUES",
                "OPEN_PRODUCT_STRUCTURES",
                "CLAIM_PREDICTIVE_SUCCESS",
            ],
        },
    ]
    dependencies = {
        "command": command,
        "python_version": platform.python_version(),
        "ord_data_commit": ORD_DATA_COMMIT,
        "ord_schema_commit": ORD_SCHEMA_COMMIT,
        "reaction_pb2_sha256": REACTION_PB2_SHA256,
        "distributions": EXPECTED_DISTRIBUTIONS,
        "wheel_sha256": WHEEL_SHA256,
    }
    jsonl = "\n".join(canonical_json_line(record) for record in records) + "\n"
    text_report = render_text(command, records, manifest_sha256)
    dependencies_json = json.dumps(
        dependencies,
        ensure_ascii=False,
        indent=2,
        sort_keys=True,
    ) + "\n"

    for output in (
        args.out_jsonl,
        args.out_txt,
        args.out_manifest_csv_gz,
        args.out_dependencies_json,
    ):
        output.parent.mkdir(parents=True, exist_ok=True)
    args.out_manifest_csv_gz.write_bytes(manifest_bytes)
    args.out_jsonl.write_text(jsonl, encoding="utf-8")
    args.out_txt.write_text(text_report, encoding="utf-8")
    args.out_dependencies_json.write_text(dependencies_json, encoding="utf-8")
    print(f"{VERDICT}: {DATASET_ID}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
