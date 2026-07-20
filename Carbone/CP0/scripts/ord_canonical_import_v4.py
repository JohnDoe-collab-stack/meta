#!/usr/bin/env python3
"""Export target-free ORD inputs to the constructive CP0 Lean language.

Only field 2 (``Reaction.inputs``) is copied into a sanitized protobuf before
deserialization.  Product structures, outcomes, target values, conditions,
reaction identifiers and provenance are never deserialized by this program.
"""

from __future__ import annotations

import argparse
from collections import Counter
import datetime as dt
import gzip
import hashlib
import importlib
import importlib.metadata
import json
from pathlib import Path
import platform
import random
import shlex
import sys
from typing import Any, Iterator


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
EXPECTED_SPECIES = 194
PERMUTATIONS_PER_SPECIES = 5
ALLOWED_REACTION_FIELDS = frozenset({2})
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
ELEMENT_TO_LEAN = {
    "H": "hydrogen",
    "B": "boron",
    "C": "carbon",
    "N": "nitrogen",
    "O": "oxygen",
    "F": "fluorine",
    "P": "phosphorus",
    "S": "sulfur",
    "Cl": "chlorine",
    "Br": "bromine",
}
BOND_TO_LEAN = {
    "SINGLE": "single",
    "DOUBLE": "double",
    "TRIPLE": "triple",
    "AROMATIC": "aromatic",
}
TETRA_TO_LEAN = {
    "CHI_UNSPECIFIED": "none",
    "CHI_TETRAHEDRAL_CW": "clockwise",
    "CHI_TETRAHEDRAL_CCW": "counterclockwise",
    "CHI_OTHER": "unspecified",
}
BOND_STEREO_TO_LEAN = {
    "STEREONONE": "none",
    "STEREOCIS": "cis",
    "STEREOZ": "cis",
    "STEREOTRANS": "trans",
    "STEREOE": "trans",
    "STEREOANY": "unspecified",
}


class WireField(tuple):
    """Minimal immutable protobuf wire field."""

    __slots__ = ()

    def __new__(cls, number: int, wire_type: int, raw: bytes, payload: bytes | None):
        return tuple.__new__(cls, (number, wire_type, raw, payload))

    number = property(lambda self: self[0])
    wire_type = property(lambda self: self[1])
    raw = property(lambda self: self[2])
    payload = property(lambda self: self[3])


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-pb-gz", required=True, type=Path)
    parser.add_argument("--ord-schema-python-root", required=True, type=Path)
    parser.add_argument("--out-jsonl", required=True, type=Path)
    parser.add_argument("--out-txt", required=True, type=Path)
    parser.add_argument("--out-lean", required=True, type=Path)
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


def canonical_json_bytes(value: Any) -> bytes:
    return json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")


def read_varint(data: bytes, position: int) -> tuple[int, int]:
    value = 0
    shift = 0
    while True:
        if position >= len(data):
            raise ValueError("truncated protobuf varint")
        byte = data[position]
        position += 1
        value |= (byte & 0x7F) << shift
        if byte < 0x80:
            return value, position
        shift += 7
        if shift >= 70:
            raise ValueError("protobuf varint exceeds 64 bits")


def iter_wire_fields(data: bytes) -> Iterator[WireField]:
    position = 0
    while position < len(data):
        start = position
        tag, position = read_varint(data, position)
        number = tag >> 3
        wire_type = tag & 7
        if number == 0:
            raise ValueError("zero protobuf field number")
        payload = None
        if wire_type == 0:
            _, position = read_varint(data, position)
        elif wire_type == 1:
            position += 8
        elif wire_type == 2:
            length, position = read_varint(data, position)
            end = position + length
            if end > len(data):
                raise ValueError("truncated length-delimited protobuf field")
            payload = data[position:end]
            position = end
        elif wire_type == 5:
            position += 4
        else:
            raise ValueError(f"unsupported protobuf wire type: {wire_type}")
        if position > len(data):
            raise ValueError("truncated fixed-width protobuf field")
        yield WireField(number, wire_type, data[start:position], payload)


def validate_run_contract(args: argparse.Namespace) -> dict[str, str]:
    script_hash = sha256_file(Path(__file__))
    if script_hash != args.script_sha256:
        raise ValueError(f"script hash mismatch: {script_hash}")
    suffix = f"_{args.run_suffix}"
    expected_endings = {
        args.out_jsonl: f"{suffix}.jsonl",
        args.out_txt: f"{suffix}.txt",
        args.out_lean: f"{suffix}.lean",
        args.out_dependencies_json: f"{suffix}.json",
    }
    for output, ending in expected_endings.items():
        if not output.name.endswith(ending):
            raise ValueError(f"output does not share suffix {ending}: {output}")
        if output.exists():
            raise FileExistsError(f"refusing to overwrite {output}")
    if args.frozen_run and not Path(__file__).stem.endswith(suffix):
        raise ValueError("frozen script name does not contain run suffix")
    if args.source_pb_gz.stat().st_size != SOURCE_SIZE:
        raise ValueError("unexpected source size")
    if sha256_file(args.source_pb_gz) != SOURCE_SHA256:
        raise ValueError("unexpected source hash")
    reaction_pb2 = args.ord_schema_python_root / "ord_schema/proto/reaction_pb2.py"
    if sha256_file(reaction_pb2) != REACTION_PB2_SHA256:
        raise ValueError("unexpected reaction_pb2.py hash")
    if sys.version_info[:2] != (3, 10):
        raise ValueError(f"Python 3.10 required, got {platform.python_version()}")
    distributions = {
        name: importlib.metadata.version(name) for name in EXPECTED_DISTRIBUTIONS
    }
    if distributions != EXPECTED_DISTRIBUTIONS:
        raise ValueError(f"unexpected distributions: {distributions}")
    return {"script_sha256": script_hash, **distributions}


def import_dependencies(schema_root: Path) -> tuple[Any, Any, Any]:
    sys.path.insert(0, str(schema_root.resolve()))
    reaction_pb2 = importlib.import_module("ord_schema.proto.reaction_pb2")
    chemistry = importlib.import_module("rdkit.Chem")
    rd_base = importlib.import_module("rdkit.rdBase")
    if rd_base.rdkitVersion != EXPECTED_RDKIT_VERSION:
        raise ValueError(f"unexpected RDKit version: {rd_base.rdkitVersion}")
    return reaction_pb2, chemistry, rd_base


def parse_dataset(data: bytes) -> tuple[str, str, list[bytes]]:
    dataset_id = ""
    dataset_name = ""
    reactions = []
    for field in iter_wire_fields(data):
        if field.number == 1 and field.payload is not None:
            dataset_name = field.payload.decode("utf-8")
        elif field.number == 3 and field.payload is not None:
            reactions.append(field.payload)
        elif field.number == 5 and field.payload is not None:
            dataset_id = field.payload.decode("utf-8")
    if (dataset_id, dataset_name) != (DATASET_ID, DATASET_NAME):
        raise ValueError("unexpected Dataset identity")
    if len(reactions) != EXPECTED_REACTIONS:
        raise ValueError(f"expected {EXPECTED_REACTIONS} reactions")
    return dataset_id, dataset_name, reactions


def sanitized_inputs(
    reaction_wire: bytes,
    reaction_pb2: Any,
    skipped: Counter[str],
) -> Any:
    allowed = []
    for field in iter_wire_fields(reaction_wire):
        if field.number in ALLOWED_REACTION_FIELDS:
            allowed.append(field.raw)
        else:
            if field.number not in REACTION_FIELD_NAMES:
                raise ValueError(f"unknown Reaction field: {field.number}")
            skipped[REACTION_FIELD_NAMES[field.number]] += 1
    return reaction_pb2.Reaction.FromString(b"".join(allowed))


def canonical_smiles_from_component(
    component: Any,
    reaction_pb2: Any,
    chemistry: Any,
) -> str:
    role = reaction_pb2.ReactionRole.ReactionRoleType.Name(component.reaction_role)
    if role in {"PRODUCT", "BYPRODUCT", "SIDE_PRODUCT"}:
        raise ValueError(f"target role in Reaction.inputs: {role}")
    smiles = [
        identifier.value
        for identifier in component.identifiers
        if reaction_pb2.CompoundIdentifier.CompoundIdentifierType.Name(
            identifier.type
        )
        == "SMILES"
    ]
    if len(smiles) != 1:
        raise ValueError(f"expected exactly one input SMILES, got {len(smiles)}")
    molecule = chemistry.MolFromSmiles(smiles[0])
    if molecule is None:
        raise ValueError("RDKit rejected input SMILES")
    return chemistry.MolToSmiles(molecule, canonical=True, isomericSmiles=True)


def canonical_bfs_order(molecule: Any, chemistry: Any) -> tuple[list[int], list[int]]:
    count = molecule.GetNumAtoms()
    if count == 0:
        raise ValueError("empty molecular fragment")
    ranks = list(
        chemistry.CanonicalRankAtoms(
            molecule,
            breakTies=True,
            includeChirality=True,
            includeIsotopes=True,
        )
    )
    root = min(range(count), key=lambda index: (ranks[index], index))
    order = [root]
    parents_old = {root: root}
    queued = {root}
    cursor = 0
    while cursor < len(order):
        current = order[cursor]
        cursor += 1
        neighbors = sorted(
            (atom.GetIdx() for atom in molecule.GetAtomWithIdx(current).GetNeighbors()),
            key=lambda index: (ranks[index], index),
        )
        for neighbor in neighbors:
            if neighbor not in queued:
                queued.add(neighbor)
                parents_old[neighbor] = current
                order.append(neighbor)
    if len(order) != count:
        raise ValueError("RDKit returned a disconnected fragment")
    new_index = {old: new for new, old in enumerate(order)}
    parents = [new_index[parents_old[old]] for old in order]
    if parents[0] != 0 or any(parent >= index for index, parent in enumerate(parents[1:], 1)):
        raise AssertionError("invalid canonical parent vector")
    return order, parents


def atom_record(atom: Any, potential_tetrahedral: bool) -> dict[str, Any]:
    symbol = atom.GetSymbol()
    if symbol not in ELEMENT_TO_LEAN:
        raise ValueError(f"unsupported element: {symbol}")
    if atom.GetIsotope() != 0:
        raise ValueError("isotopic input is outside CP0-ONTOLOGY-1")
    if atom.GetNumRadicalElectrons() != 0:
        raise ValueError("radical input is outside CP0-ONTOLOGY-1")
    tag = str(atom.GetChiralTag())
    if tag not in TETRA_TO_LEAN:
        raise ValueError(f"unsupported tetrahedral tag: {tag}")
    tetra_stereo = TETRA_TO_LEAN[tag]
    if tetra_stereo == "none" and potential_tetrahedral:
        tetra_stereo = "unspecified"
    return {
        "element": ELEMENT_TO_LEAN[symbol],
        "formal_charge": atom.GetFormalCharge(),
        "implicit_hydrogens": atom.GetNumImplicitHs() + atom.GetNumExplicitHs(),
        "aromatic": bool(atom.GetIsAromatic()),
        "tetra_stereo": tetra_stereo,
    }


def bond_record(bond: Any) -> dict[str, Any]:
    kind = str(bond.GetBondType())
    stereo = str(bond.GetStereo())
    if kind not in BOND_TO_LEAN:
        raise ValueError(f"unsupported bond type: {kind}")
    if stereo not in BOND_STEREO_TO_LEAN:
        raise ValueError(f"unsupported bond stereo: {stereo}")
    left, right = sorted((bond.GetBeginAtomIdx(), bond.GetEndAtomIdx()))
    return {
        "left": left,
        "right": right,
        "kind": BOND_TO_LEAN[kind],
        "stereo": BOND_STEREO_TO_LEAN[stereo],
    }


def fragment_record(fragment: Any, chemistry: Any) -> dict[str, Any]:
    order, parents = canonical_bfs_order(fragment, chemistry)
    canonical = chemistry.RenumberAtoms(fragment, order)
    potential_tetrahedral = {
        index
        for index, _ in chemistry.FindMolChiralCenters(
            canonical,
            includeUnassigned=True,
            includeCIP=False,
            useLegacyImplementation=False,
        )
    }
    atoms = [
        atom_record(atom, atom.GetIdx() in potential_tetrahedral)
        for atom in canonical.GetAtoms()
    ]
    bonds = sorted(
        (bond_record(bond) for bond in canonical.GetBonds()),
        key=lambda value: (
            value["left"],
            value["right"],
            value["kind"],
            value["stereo"],
        ),
    )
    endpoints = [(bond["left"], bond["right"]) for bond in bonds]
    if len(endpoints) != len(set(endpoints)):
        raise ValueError("duplicate bond endpoints")
    for index, parent in enumerate(parents[1:], 1):
        if (parent, index) not in set(endpoints):
            raise AssertionError("parent vector edge is absent")
    return {"atoms": atoms, "bonds": bonds, "parents": parents}


def species_graph(molecule: Any, chemistry: Any) -> list[dict[str, Any]]:
    fragments = chemistry.GetMolFrags(molecule, asMols=True, sanitizeFrags=True)
    records = [fragment_record(fragment, chemistry) for fragment in fragments]
    records.sort(key=canonical_json_bytes)
    if not records:
        raise ValueError("species without fragment")
    if not any(
        atom["element"] == "carbon"
        for fragment in records
        for atom in fragment["atoms"]
    ):
        raise ValueError("input species without carbon")
    return records


def permutation_audit(
    molecule: Any,
    expected: list[dict[str, Any]],
    chemistry: Any,
    seed: int,
) -> int:
    generator = random.Random(seed)
    count = molecule.GetNumAtoms()
    for _ in range(PERMUTATIONS_PER_SPECIES):
        order = list(range(count))
        generator.shuffle(order)
        permuted = chemistry.RenumberAtoms(molecule, order)
        if species_graph(permuted, chemistry) != expected:
            raise ValueError("canonical graph depends on RDKit atom ordering")
    return PERMUTATIONS_PER_SPECIES


def build_species(canonical_smiles: str, chemistry: Any) -> tuple[dict[str, Any], int]:
    molecule = chemistry.MolFromSmiles(canonical_smiles)
    if molecule is None:
        raise ValueError("RDKit rejected its own canonical SMILES")
    roundtrip_smiles = chemistry.MolToSmiles(
        molecule, canonical=True, isomericSmiles=True
    )
    if roundtrip_smiles != canonical_smiles:
        raise ValueError("canonical SMILES is not idempotent")
    graph = species_graph(molecule, chemistry)
    seed = int(domain_hash("cp0-permutation-seed-v1", canonical_smiles)[:16], 16)
    permutation_checks = permutation_audit(molecule, graph, chemistry, seed)
    graph_bytes = canonical_json_bytes(graph)
    return (
        {
            "identity_sha256": domain_hash("cp0-molecule-v1", canonical_smiles),
            "canonical_graph_sha256": domain_hash(
                "cp0-canonical-graph-v1", graph_bytes
            ),
            "fragments": graph,
        },
        permutation_checks,
    )


def lean_bool(value: bool) -> str:
    return "true" if value else "false"


def lean_int(value: int) -> str:
    return f"({value} : Int)" if value >= 0 else f"({value} : Int)"


def render_atom(atom: dict[str, Any]) -> str:
    return (
        "Atom.mk ." + atom["element"]
        + " " + lean_int(atom["formal_charge"])
        + " " + str(atom["implicit_hydrogens"])
        + " " + lean_bool(atom["aromatic"])
        + " ." + atom["tetra_stereo"]
    )


def render_bond(bond: dict[str, Any]) -> str:
    return (
        "Bond.mk " + str(bond["left"])
        + " " + str(bond["right"])
        + " ." + bond["kind"]
        + " ." + bond["stereo"]
    )


def render_list(values: list[str], indent: str) -> str:
    if not values:
        return "[]"
    separator = "\n" + indent + ", "
    return "[ " + separator.join(values) + "\n" + indent[:-2] + "]"


def render_fragment(fragment: dict[str, Any], indent: str) -> str:
    atoms = render_list([render_atom(atom) for atom in fragment["atoms"]], indent + "  ")
    bonds = render_list([render_bond(bond) for bond in fragment["bonds"]], indent + "  ")
    parents = render_list([str(parent) for parent in fragment["parents"]], indent + "  ")
    return (
        "ImportedFragment.mk (" + atoms
        + ") (" + bonds
        + ") (" + parents + ")"
    )


def render_species(species: dict[str, Any], indent: str) -> str:
    fragments = render_list(
        [render_fragment(fragment, indent + "  ") for fragment in species["fragments"]],
        indent + "  ",
    )
    return (
        "ImportedSpecies.mk \"" + species["identity_sha256"] + "\""
        + " \"" + species["canonical_graph_sha256"] + "\""
        + " (" + fragments + ")"
    )


def render_lean(species: list[dict[str, Any]]) -> str:
    rendered = render_list([render_species(value, "    ") for value in species], "    ")
    return f"""import Carbone.CP0.Lean.CanonicalImport

/-! Generated target-free CP0 input graph data.  Do not edit by hand. -/

namespace Meta
namespace Carbone
namespace CP0
namespace CanonicalImport

def importedSpecies : List ImportedSpecies :=
  {rendered}

def validatedSpeciesImport : ValidatedImport where
  species := importedSpecies
  count194 := by rfl
  allValid := by rfl
  identityHashesUnique := by rfl
  graphHashesUnique := by rfl

end CanonicalImport
end CP0
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CP0.CanonicalImport.importedSpecies
#print axioms Meta.Carbone.CP0.CanonicalImport.validatedSpeciesImport
/- AXIOM_AUDIT_END -/
"""


def summary_record(
    species: list[dict[str, Any]],
    permutation_checks: int,
    skipped: Counter[str],
) -> dict[str, Any]:
    fragments = [fragment for value in species for fragment in value["fragments"]]
    atoms = [atom for fragment in fragments for atom in fragment["atoms"]]
    bonds = [bond for fragment in fragments for bond in fragment["bonds"]]
    return {
        "record_type": "qualification",
        "species": len(species),
        "fragments": len(fragments),
        "atoms": len(atoms),
        "bonds": len(bonds),
        "elements": sorted({atom["element"] for atom in atoms}),
        "aromatic_atoms": sum(atom["aromatic"] for atom in atoms),
        "formally_charged_atoms": sum(atom["formal_charge"] != 0 for atom in atoms),
        "implicit_hydrogens": sum(atom["implicit_hydrogens"] for atom in atoms),
        "tetrahedral_atoms": sum(atom["tetra_stereo"] != "none" for atom in atoms),
        "stereo_bonds": sum(bond["stereo"] != "none" for bond in bonds),
        "identity_hashes_unique": len({v["identity_sha256"] for v in species})
        == len(species),
        "graph_hashes_unique": len({v["canonical_graph_sha256"] for v in species})
        == len(species),
        "canonical_smiles_roundtrips": len(species),
        "atom_permutation_checks": permutation_checks,
        "skipped_reaction_field_counts": dict(sorted(skipped.items())),
        "product_structures_decoded": 0,
        "target_numeric_values_decoded": 0,
        "reaction_identifiers_decoded": 0,
        "conditions_decoded": 0,
    }


def main() -> int:
    args = parse_args()
    provenance = validate_run_contract(args)
    reaction_pb2, chemistry, rd_base = import_dependencies(
        args.ord_schema_python_root
    )
    command = shlex.join([sys.executable, *sys.argv])
    run_at_utc = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat()
    with gzip.open(args.source_pb_gz, "rb") as handle:
        dataset_wire = handle.read()
    dataset_id, dataset_name, reaction_wires = parse_dataset(dataset_wire)

    canonical_smiles: set[str] = set()
    skipped: Counter[str] = Counter()
    for reaction_wire in reaction_wires:
        reaction = sanitized_inputs(reaction_wire, reaction_pb2, skipped)
        for reaction_input in reaction.inputs.values():
            for component in reaction_input.components:
                canonical_smiles.add(
                    canonical_smiles_from_component(
                        component, reaction_pb2, chemistry
                    )
                )
    if len(canonical_smiles) != EXPECTED_SPECIES:
        raise ValueError(f"expected {EXPECTED_SPECIES} species, got {len(canonical_smiles)}")

    species = []
    permutation_checks = 0
    for smiles in sorted(canonical_smiles):
        value, checks = build_species(smiles, chemistry)
        species.append(value)
        permutation_checks += checks
    species.sort(key=lambda value: value["identity_sha256"])
    summary = summary_record(species, permutation_checks, skipped)
    if not summary["identity_hashes_unique"] or not summary["graph_hashes_unique"]:
        raise ValueError("non-unique canonical import hashes")

    lean = render_lean(species)
    lean_sha256 = sha256_bytes(lean.encode("utf-8"))
    records = [
        {
            "record_type": "run",
            "command": command,
            "run_at_utc": run_at_utc,
            "script_sha256": provenance["script_sha256"],
            "source_sha256": SOURCE_SHA256,
            "lean_sha256": lean_sha256,
            "python_version": platform.python_version(),
            "rdkit_version": rd_base.rdkitVersion,
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
        summary,
    ]
    jsonl = "\n".join(
        canonical_json_bytes(record).decode("utf-8") for record in records
    ) + "\n"
    text = "\n".join(
        [
            f"command: {command}",
            f"script_sha256: {provenance['script_sha256']}",
            f"source_sha256: {SOURCE_SHA256}",
            f"lean_sha256: {lean_sha256}",
            f"run_at_utc: {run_at_utc}",
            f"species: {summary['species']}",
            f"fragments: {summary['fragments']}",
            f"atoms: {summary['atoms']}",
            f"bonds: {summary['bonds']}",
            f"canonical_smiles_roundtrips: {summary['canonical_smiles_roundtrips']}",
            f"atom_permutation_checks: {summary['atom_permutation_checks']}",
            "product_structures_decoded: 0",
            "target_numeric_values_decoded: 0",
            "reaction_identifiers_decoded: 0",
            "conditions_decoded: 0",
            "verdict: QUALIFIED_INPUT_IMPORT_194_OF_194",
            "",
        ]
    )
    dependencies = {
        "command": command,
        "python_version": platform.python_version(),
        "ord_data_commit": ORD_DATA_COMMIT,
        "ord_schema_commit": ORD_SCHEMA_COMMIT,
        "reaction_pb2_sha256": REACTION_PB2_SHA256,
        "distributions": EXPECTED_DISTRIBUTIONS,
        "wheel_sha256": WHEEL_SHA256,
    }
    dependencies_json = json.dumps(
        dependencies, ensure_ascii=False, indent=2, sort_keys=True
    ) + "\n"
    outputs = {
        args.out_jsonl: jsonl.encode("utf-8"),
        args.out_txt: text.encode("utf-8"),
        args.out_lean: lean.encode("utf-8"),
        args.out_dependencies_json: dependencies_json.encode("utf-8"),
    }
    for output in outputs:
        output.parent.mkdir(parents=True, exist_ok=True)
    for output, payload in outputs.items():
        output.write_bytes(payload)
    print("QUALIFIED_INPUT_IMPORT_194_OF_194")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
