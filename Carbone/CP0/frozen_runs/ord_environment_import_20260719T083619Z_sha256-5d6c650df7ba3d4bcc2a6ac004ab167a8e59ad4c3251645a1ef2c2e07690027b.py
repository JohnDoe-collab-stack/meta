#!/usr/bin/env python3
"""Import CP0 quantities and environments without decoding any target value."""

from __future__ import annotations

import argparse
from collections import Counter
import csv
import datetime as dt
import gzip
import hashlib
import importlib
import importlib.metadata
import json
import math
from pathlib import Path
import platform
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
I0_MANIFEST_SHA256 = "da963892cf8caebf3ad5983773b866a13333260869805542b16d0be1aa01cb9b"
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
EXPECTED_ENVIRONMENTS = 94
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
GROUP_TO_LEAN = {
    "carboxylic acid": "carboxylicAcid",
    "additive": "additive",
    "activation agent": "activationAgent",
    "amine": "amine",
    "base": "base",
    "solvent": "solvent",
}
GROUP_CODE = {name: index for index, name in enumerate(GROUP_TO_LEAN)}
ROLE_TO_LEAN = {"REAGENT": "reagent", "SOLVENT": "solvent"}
AMOUNT_UNIT_TO_LEAN = {
    ("moles", "MILLIMOLE"): "millimole",
    ("volume", "MICROLITER"): "microliter",
}


class WireField(tuple):
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
    parser.add_argument("--i0-manifest-csv-gz", required=True, type=Path)
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
    expected = {
        args.out_jsonl: f"{suffix}.jsonl",
        args.out_txt: f"{suffix}.txt",
        args.out_lean: f"{suffix}.lean",
        args.out_dependencies_json: f"{suffix}.json",
    }
    for output, ending in expected.items():
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
    if sha256_file(args.i0_manifest_csv_gz) != I0_MANIFEST_SHA256:
        raise ValueError("unexpected CP0-DATA-I0 manifest hash")
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


def sanitized_reaction(
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


def enum_name(enum: Any, value: int) -> str:
    return enum.Name(value)


def canonical_component(
    component: Any,
    reaction_pb2: Any,
    chemistry: Any,
) -> tuple[str, str]:
    role = enum_name(
        reaction_pb2.ReactionRole.ReactionRoleType,
        component.reaction_role,
    )
    if role in {"PRODUCT", "BYPRODUCT", "SIDE_PRODUCT"}:
        raise ValueError(f"target role in Reaction.inputs: {role}")
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
        raise ValueError(f"expected exactly one input SMILES, got {len(smiles)}")
    molecule = chemistry.MolFromSmiles(smiles[0])
    if molecule is None:
        raise ValueError("RDKit rejected input SMILES")
    canonical = chemistry.MolToSmiles(
        molecule,
        canonical=True,
        isomericSmiles=True,
    )
    return canonical, role


def exact_ratio(value: float, positive: bool = True) -> dict[str, int]:
    if not math.isfinite(value):
        raise ValueError("non-finite numeric input")
    numerator, denominator = value.as_integer_ratio()
    if positive and numerator <= 0:
        raise ValueError("non-positive quantity")
    return {"numerator": numerator, "denominator": denominator}


def amount_record(amount: Any, reaction_pb2: Any) -> tuple[dict[str, Any], str]:
    kind = amount.WhichOneof("kind")
    if kind not in {"moles", "volume"}:
        raise ValueError(f"unsupported amount kind: {kind}")
    value = getattr(amount, kind)
    if not value.HasField("value"):
        raise ValueError("amount without numeric value")
    enum = (
        reaction_pb2.Moles.MolesUnit
        if kind == "moles"
        else reaction_pb2.Volume.VolumeUnit
    )
    unit_name = enum.Name(value.units)
    unit_key = (kind, unit_name)
    if unit_key not in AMOUNT_UNIT_TO_LEAN:
        raise ValueError(f"unsupported amount unit: {unit_key}")
    record = {
        "value": exact_ratio(value.value),
        "unit": AMOUNT_UNIT_TO_LEAN[unit_key],
    }
    return record, amount.SerializeToString(deterministic=True).hex()


def addition_step(group: str, reaction_input: Any, reaction_pb2: Any) -> dict[str, Any]:
    if group not in GROUP_TO_LEAN:
        raise ValueError(f"unsupported input group: {group}")
    if reaction_input.addition_order <= 0:
        raise ValueError("missing positive addition order")
    device_type = reaction_pb2.ReactionInput.AdditionDevice.AdditionDeviceType.Name(
        reaction_input.addition_device.type
    )
    if device_type != "PIPETTE":
        raise ValueError(f"unsupported addition device: {device_type}")
    delay = None
    if reaction_input.HasField("addition_time"):
        if not reaction_input.addition_time.HasField("value"):
            raise ValueError("addition time without value")
        unit = reaction_pb2.Time.TimeUnit.Name(reaction_input.addition_time.units)
        if unit != "HOUR":
            raise ValueError(f"unsupported addition time unit: {unit}")
        delay = exact_ratio(reaction_input.addition_time.value)
    return {
        "group": GROUP_TO_LEAN[group],
        "order": reaction_input.addition_order,
        "delay_hours": delay,
        "device": "pipette",
    }


def physical_condition(conditions: Any, reaction_pb2: Any) -> dict[str, Any]:
    temperature = conditions.temperature
    if not temperature.setpoint.HasField("value"):
        raise ValueError("temperature setpoint without value")
    temperature_unit = reaction_pb2.Temperature.TemperatureUnit.Name(
        temperature.setpoint.units
    )
    temperature_control = (
        reaction_pb2.TemperatureConditions.TemperatureControl.TemperatureControlType.Name(
            temperature.control.type
        )
    )
    pressure_control = (
        reaction_pb2.PressureConditions.PressureControl.PressureControlType.Name(
            conditions.pressure.control.type
        )
    )
    atmosphere = (
        reaction_pb2.PressureConditions.Atmosphere.AtmosphereType.Name(
            conditions.pressure.atmosphere.type
        )
    )
    stirring = reaction_pb2.StirringConditions.StirringMethodType.Name(
        conditions.stirring.type
    )
    observed = (
        temperature_unit,
        temperature_control,
        pressure_control,
        atmosphere,
        stirring,
        conditions.reflux,
    )
    expected = (
        "CELSIUS",
        "DRY_ALUMINUM_PLATE",
        "AMBIENT",
        "AIR",
        "STIR_BAR",
        False,
    )
    if observed != expected:
        raise ValueError(f"unsupported physical condition: {observed}")
    return {
        "temperature": exact_ratio(temperature.setpoint.value, positive=False),
        "temperature_unit": "celsius",
        "temperature_control": "dryAluminumPlate",
        "pressure_control": "ambient",
        "atmosphere": "air",
        "stirring": "stirBar",
        "reflux": False,
    }


def load_i0_manifest(path: Path) -> dict[str, dict[str, str]]:
    with gzip.open(path, "rt", encoding="utf-8", newline="") as handle:
        rows = list(csv.DictReader(handle))
    if len(rows) != EXPECTED_REACTIONS:
        raise ValueError("unexpected I0 manifest row count")
    indexed = {row["reaction_id_sha256"]: row for row in rows}
    if len(indexed) != len(rows):
        raise ValueError("duplicate reaction hash in I0 manifest")
    return indexed


def raw_row_and_template(
    reaction: Any,
    reaction_pb2: Any,
    chemistry: Any,
) -> tuple[dict[str, str], dict[str, Any], set[str]]:
    if not reaction.reaction_id:
        raise ValueError("missing reaction_id")
    semantic_items = []
    partner_hashes: dict[str, str] = {}
    partner_amounts: dict[str, dict[str, Any]] = {}
    auxiliaries = []
    additions = []
    species_hashes = set()
    for group, reaction_input in sorted(reaction.inputs.items()):
        if group not in GROUP_TO_LEAN:
            raise ValueError(f"unexpected input group: {group}")
        meta = reaction_pb2.ReactionInput()
        meta.CopyFrom(reaction_input)
        meta.ClearField("components")
        meta_hex = meta.SerializeToString(deterministic=True).hex()
        if meta_hex:
            semantic_items.append((group, "input_meta", meta_hex))
        additions.append(addition_step(group, reaction_input, reaction_pb2))
        for component in reaction_input.components:
            canonical, role = canonical_component(
                component,
                reaction_pb2,
                chemistry,
            )
            identity_hash = domain_hash("cp0-molecule-v1", canonical)
            species_hashes.add(identity_hash)
            amount, amount_hex = amount_record(component.amount, reaction_pb2)
            if role == "REACTANT" and group in {"amine", "carboxylic acid"}:
                if group in partner_hashes:
                    raise ValueError(f"duplicate partner: {group}")
                partner_hashes[group] = identity_hash
                partner_amounts[group] = amount
                semantic_items.append((group, role, "PARTNER", amount_hex))
            else:
                if role not in ROLE_TO_LEAN:
                    raise ValueError(f"unsupported auxiliary role: {role}")
                semantic_items.append((group, role, canonical, amount_hex))
                auxiliaries.append(
                    {
                        "group": GROUP_TO_LEAN[group],
                        "species_identity_sha256": identity_hash,
                        "role": ROLE_TO_LEAN[role],
                        "amount": amount,
                    }
                )
    if set(partner_hashes) != {"amine", "carboxylic acid"}:
        raise ValueError("missing reaction partners")
    conditions_hex = reaction.conditions.SerializeToString(deterministic=True).hex()
    semantic_hash = domain_hash(
        "cp0-semantic-condition-v1",
        canonical_json_bytes([sorted(semantic_items), conditions_hex]).decode("utf-8"),
    )
    additions.sort(key=lambda value: value["order"])
    raw_template = {
        "semantic_condition_sha256": semantic_hash,
        "amine_amount": partner_amounts["amine"],
        "acid_amount": partner_amounts["carboxylic acid"],
        "auxiliaries": auxiliaries,
        "addition_steps": additions,
        "condition": physical_condition(reaction.conditions, reaction_pb2),
    }
    row = {
        "reaction_id_sha256": domain_hash(
            "cp0-reaction-id-v1", reaction.reaction_id
        ),
        "amine_sha256": partner_hashes["amine"],
        "acid_sha256": partner_hashes["carboxylic acid"],
        "semantic_condition_sha256": semantic_hash,
    }
    return row, raw_template, species_hashes


def finalize_template(
    raw: dict[str, Any],
    species_index: dict[str, int],
) -> dict[str, Any]:
    value = json.loads(json.dumps(raw))
    for component in value["auxiliaries"]:
        identity_hash = component.pop("species_identity_sha256")
        component["species_index"] = species_index[identity_hash]
    value["auxiliaries"].sort(
        key=lambda component: (
            GROUP_CODE[
                next(
                    name
                    for name, lean_name in GROUP_TO_LEAN.items()
                    if lean_name == component["group"]
                )
            ],
            component["role"],
            component["species_index"],
            canonical_json_bytes(component["amount"]),
        )
    )
    content = {key: item for key, item in value.items() if key != "semantic_condition_sha256"}
    value["canonical_content_sha256"] = domain_hash(
        "cp0-environment-content-v1", canonical_json_bytes(content)
    )
    return value


def lean_ratio(value: dict[str, int], signed: bool = False) -> str:
    numerator = value["numerator"]
    rendered_numerator = f"({numerator} : Int)" if signed else str(numerator)
    return (
        "{ numerator := " + rendered_numerator
        + ", denominator := " + str(value["denominator"]) + " }"
    )


def lean_amount(value: dict[str, Any]) -> str:
    return (
        "{ value := " + lean_ratio(value["value"])
        + ", unit := ." + value["unit"] + " }"
    )


def render_list(values: list[str], indent: str) -> str:
    if not values:
        return "[]"
    separator = "\n" + indent + ", "
    return "[ " + separator.join(values) + "\n" + indent[:-2] + "]"


def render_component(component: dict[str, Any]) -> str:
    return (
        "{ group := ." + component["group"]
        + ", speciesIndex := " + str(component["species_index"])
        + ", role := ." + component["role"]
        + ", amount := " + lean_amount(component["amount"]) + " }"
    )


def render_addition(step: dict[str, Any]) -> str:
    delay = (
        "none"
        if step["delay_hours"] is None
        else "some " + lean_ratio(step["delay_hours"])
    )
    return (
        "{ group := ." + step["group"]
        + ", order := " + str(step["order"])
        + ", delayHours := " + delay
        + ", device := ." + step["device"] + " }"
    )


def render_condition(condition: dict[str, Any]) -> str:
    return (
        "{ temperature := " + lean_ratio(condition["temperature"], signed=True)
        + ", temperatureUnit := ." + condition["temperature_unit"]
        + ", temperatureControl := ." + condition["temperature_control"]
        + ", pressureControl := ." + condition["pressure_control"]
        + ", atmosphere := ." + condition["atmosphere"]
        + ", stirring := ." + condition["stirring"]
        + ", reflux := " + str(condition["reflux"]).lower() + " }"
    )


def render_environment(environment: dict[str, Any], indent: str) -> str:
    auxiliaries = render_list(
        [render_component(value) for value in environment["auxiliaries"]],
        indent + "  ",
    )
    additions = render_list(
        [render_addition(value) for value in environment["addition_steps"]],
        indent + "  ",
    )
    return (
        "{ semanticConditionSha256 := \"" + environment["semantic_condition_sha256"] + "\""
        + "\n" + indent + "  canonicalContentSha256 := \""
        + environment["canonical_content_sha256"] + "\""
        + "\n" + indent + "  amineAmount := " + lean_amount(environment["amine_amount"])
        + "\n" + indent + "  acidAmount := " + lean_amount(environment["acid_amount"])
        + "\n" + indent + "  auxiliaries := " + auxiliaries
        + "\n" + indent + "  additionSteps := " + additions
        + "\n" + indent + "  condition := " + render_condition(environment["condition"])
        + " }"
    )


def render_lean(
    environments: list[dict[str, Any]],
    known_row: dict[str, str],
    amine_hashes: list[str],
    acid_hashes: list[str],
) -> str:
    rendered = render_list(
        [render_environment(value, "    ") for value in environments],
        "    ",
    )
    rendered_amines = render_list(
        [f'"{value}"' for value in amine_hashes],
        "    ",
    )
    rendered_acids = render_list(
        [f'"{value}"' for value in acid_hashes],
        "    ",
    )
    return f"""import Carbone.CP0.Lean.EnvironmentImport

/-! Generated target-free CP0 environment data.  Do not edit by hand. -/

namespace Meta
namespace Carbone
namespace CP0
namespace EnvironmentImport

def importedEnvironments : List EnvironmentTemplate :=
  {rendered}

def importedAmineIdentityHashes : List String :=
  {rendered_amines}

def importedAcidIdentityHashes : List String :=
  {rendered_acids}

def validatedEnvironmentImport : ValidatedEnvironmentImport where
  environments := importedEnvironments
  count94 := by rfl
  allValid := by rfl
  semanticHashesUnique := by rfl
  contentHashesUnique := by rfl

def validatedInputDomainImport : ValidatedInputDomainImport where
  environments := importedEnvironments
  amineIdentityHashes := importedAmineIdentityHashes
  acidIdentityHashes := importedAcidIdentityHashes
  environmentCount94 := by rfl
  amineCount70 := by rfl
  acidCount66 := by rfl
  allEnvironmentsValid := by rfl
  environmentSemanticHashesUnique := by rfl
  environmentContentHashesUnique := by rfl
  amineHashesUnique := by rfl
  acidHashesUnique := by rfl
  allAmineHashesImported := by rfl
  allAcidHashesImported := by rfl

def resolveImportedInput?
    (amineIdentitySha256 acidIdentitySha256 semanticConditionSha256 : String) :
    Option InputOrganization :=
  resolveQualifiedInput?
    importedEnvironments
    importedAmineIdentityHashes
    importedAcidIdentityHashes
    amineIdentitySha256 acidIdentitySha256 semanticConditionSha256

def knownInputOrganization? : Option InputOrganization :=
  resolveImportedInput?
    "{known_row['amine_sha256']}"
    "{known_row['acid_sha256']}"
    "{known_row['semantic_condition_sha256']}"

def knownInputProjection? : Option InputProjection :=
  knownInputOrganization?.map projectInput

theorem knownInputOrganization_resolves :
    knownInputOrganization?.isSome = true := by
  rfl

theorem knownInputProjection_resolves :
    knownInputProjection?.isSome = true := by
  rfl

end EnvironmentImport
end CP0
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CP0.EnvironmentImport.importedEnvironments
#print axioms Meta.Carbone.CP0.EnvironmentImport.validatedEnvironmentImport
#print axioms Meta.Carbone.CP0.EnvironmentImport.validatedInputDomainImport
#print axioms Meta.Carbone.CP0.EnvironmentImport.resolveImportedInput?
#print axioms Meta.Carbone.CP0.EnvironmentImport.knownInputOrganization_resolves
#print axioms Meta.Carbone.CP0.EnvironmentImport.knownInputProjection_resolves
/- AXIOM_AUDIT_END -/
"""


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
    i0_manifest = load_i0_manifest(args.i0_manifest_csv_gz)

    skipped: Counter[str] = Counter()
    rows = []
    raw_templates: dict[str, dict[str, Any]] = {}
    all_species_hashes = set()
    for reaction_wire in reaction_wires:
        reaction = sanitized_reaction(reaction_wire, reaction_pb2, skipped)
        row, raw_template, species_hashes = raw_row_and_template(
            reaction,
            reaction_pb2,
            chemistry,
        )
        rows.append(row)
        all_species_hashes.update(species_hashes)
        semantic_hash = raw_template["semantic_condition_sha256"]
        previous = raw_templates.setdefault(semantic_hash, raw_template)
        if previous != raw_template:
            raise ValueError("semantic hash collision between environment templates")

    if len(all_species_hashes) != EXPECTED_SPECIES:
        raise ValueError(f"expected {EXPECTED_SPECIES} species")
    if len(raw_templates) != EXPECTED_ENVIRONMENTS:
        raise ValueError(f"expected {EXPECTED_ENVIRONMENTS} environments")
    species_index = {
        identity_hash: index
        for index, identity_hash in enumerate(sorted(all_species_hashes))
    }
    environments = [
        finalize_template(raw, species_index) for raw in raw_templates.values()
    ]
    environments.sort(key=lambda value: value["semantic_condition_sha256"])
    content_hashes = {value["canonical_content_sha256"] for value in environments}
    if len(content_hashes) != EXPECTED_ENVIRONMENTS:
        raise ValueError("normalized environment content collision")

    matched = 0
    unique_input_keys = set()
    for row in rows:
        reference = i0_manifest.get(row["reaction_id_sha256"])
        if reference is None:
            raise ValueError("reaction absent from I0 manifest")
        for key in ("amine_sha256", "acid_sha256", "semantic_condition_sha256"):
            if row[key] != reference[key]:
                raise ValueError(f"I0 manifest mismatch for {key}")
        matched += 1
        unique_input_keys.add(
            (row["amine_sha256"], row["acid_sha256"], row["semantic_condition_sha256"])
        )
    if matched != EXPECTED_REACTIONS:
        raise AssertionError("incomplete manifest comparison")

    amine_hashes = sorted({row["amine_sha256"] for row in rows})
    acid_hashes = sorted({row["acid_sha256"] for row in rows})
    if len(amine_hashes) != 70 or len(acid_hashes) != 66:
        raise ValueError("unexpected partner-domain cardinality")

    known_row = sorted(rows, key=lambda value: value["reaction_id_sha256"])[0]
    lean = render_lean(environments, known_row, amine_hashes, acid_hashes)
    lean_sha256 = sha256_bytes(lean.encode("utf-8"))
    auxiliary_counts = [len(value["auxiliaries"]) for value in environments]
    quantity_values = {
        canonical_json_bytes(component["amount"]).decode("utf-8")
        for environment in environments
        for component in environment["auxiliaries"]
    }
    records = [
        {
            "record_type": "run",
            "command": command,
            "run_at_utc": run_at_utc,
            "script_sha256": provenance["script_sha256"],
            "source_sha256": SOURCE_SHA256,
            "i0_manifest_sha256": I0_MANIFEST_SHA256,
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
        {
            "record_type": "qualification",
            "rows": len(rows),
            "i0_manifest_rows_matched": matched,
            "species_referenced": len(all_species_hashes),
            "amine_identities": len(amine_hashes),
            "acid_identities": len(acid_hashes),
            "semantic_environments": len(environments),
            "content_hashes_unique": len(content_hashes),
            "unique_input_keys": len(unique_input_keys),
            "physical_conditions": 1,
            "auxiliaries_per_environment_min": min(auxiliary_counts),
            "auxiliaries_per_environment_max": max(auxiliary_counts),
            "unique_auxiliary_amounts": len(quantity_values),
            "skipped_reaction_field_counts": dict(sorted(skipped.items())),
            "product_structures_decoded": 0,
            "target_numeric_values_decoded": 0,
            "reaction_structure_identifiers_decoded": 0,
            "reaction_id_strings_hashed": matched,
        },
    ]
    jsonl = "\n".join(
        canonical_json_bytes(record).decode("utf-8") for record in records
    ) + "\n"
    text = "\n".join(
        [
            f"command: {command}",
            f"script_sha256: {provenance['script_sha256']}",
            f"source_sha256: {SOURCE_SHA256}",
            f"i0_manifest_sha256: {I0_MANIFEST_SHA256}",
            f"lean_sha256: {lean_sha256}",
            f"run_at_utc: {run_at_utc}",
            f"rows: {len(rows)}",
            f"i0_manifest_rows_matched: {matched}",
            f"species_referenced: {len(all_species_hashes)}",
            f"amine_identities: {len(amine_hashes)}",
            f"acid_identities: {len(acid_hashes)}",
            f"semantic_environments: {len(environments)}",
            f"unique_input_keys: {len(unique_input_keys)}",
            "physical_conditions: 1",
            "product_structures_decoded: 0",
            "target_numeric_values_decoded: 0",
            "reaction_structure_identifiers_decoded: 0",
            f"reaction_id_strings_hashed: {matched}",
            "verdict: QUALIFIED_ENVIRONMENT_IMPORT_94_OF_94",
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
    print("QUALIFIED_ENVIRONMENT_IMPORT_94_OF_94")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
