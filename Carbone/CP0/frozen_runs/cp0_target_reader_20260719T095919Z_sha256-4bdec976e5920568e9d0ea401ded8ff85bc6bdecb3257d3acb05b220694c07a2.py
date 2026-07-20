#!/usr/bin/env python3
"""Read CP0 yield targets under an explicit compartment gate.

The synthetic audit mode constructs protobuf wire messages in memory and never
opens the ORD source or the CP0-I0 manifest.  Real modes accept only
``construction`` or ``selection``; this reader has no held-out-test mode.
"""

from __future__ import annotations

import argparse
from collections import defaultdict
import csv
import datetime as dt
from fractions import Fraction
import gzip
import hashlib
import io
import json
import math
from pathlib import Path
import platform
import shlex
import struct
import sys
from typing import Any, Iterator


DATASET_ID = "ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41"
DATASET_NAME = "AIChemEco amide coupling conditions 47k dataset"
SOURCE_SHA256 = "103c485fc009ee66f525c140611c8596d31f0673cdbb2ec16ec497ea44a58f6f"
SOURCE_SIZE = 8_753_257
I0_MANIFEST_SHA256 = "da963892cf8caebf3ad5983773b866a13333260869805542b16d0be1aa01cb9b"
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

REACTION_FIELDS = frozenset(range(1, 11))
OUTCOME_FIELDS = frozenset(range(1, 5))
PRODUCT_FIELDS = frozenset(range(1, 8))
MEASUREMENT_FIELDS = frozenset(range(1, 16))
PERCENTAGE_FIELDS = frozenset({1, 2})
TARGET_VALUE_FIELDS = frozenset(range(8, 16))

REACTION_OUTCOME_FIELD = 8
REACTION_ID_FIELD = 10
OUTCOME_PRODUCT_FIELD = 3
PRODUCT_DESIRED_FIELD = 2
PRODUCT_MEASUREMENT_FIELD = 3
PRODUCT_ROLE_FIELD = 7
MEASUREMENT_TYPE_FIELD = 2
MEASUREMENT_PERCENTAGE_FIELD = 8
PERCENTAGE_VALUE_FIELD = 1
PRODUCT_ROLE_PRODUCT = 8
MEASUREMENT_TYPE_YIELD = 3

REAL_MODES = frozenset({"construction", "selection"})


class TargetReaderError(ValueError):
    """A protocol violation at the target-reading boundary."""


class WireField(tuple):
    """Minimal immutable protobuf wire field."""

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
        choices=("synthetic-audit", "construction", "selection"),
    )
    parser.add_argument("--source-pb-gz", type=Path)
    parser.add_argument("--i0-manifest-csv-gz", type=Path)
    parser.add_argument("--out-targets-csv-gz", required=True, type=Path)
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


def read_varint(data: bytes, position: int) -> tuple[int, int]:
    value = 0
    shift = 0
    while True:
        if position >= len(data):
            raise TargetReaderError("truncated protobuf varint")
        byte = data[position]
        position += 1
        value |= (byte & 0x7F) << shift
        if byte < 0x80:
            return value, position
        shift += 7
        if shift >= 70:
            raise TargetReaderError("protobuf varint exceeds 64 bits")


def iter_wire_fields(data: bytes) -> Iterator[WireField]:
    position = 0
    while position < len(data):
        start = position
        tag, position = read_varint(data, position)
        number = tag >> 3
        wire_type = tag & 7
        if number == 0:
            raise TargetReaderError("zero protobuf field number")
        payload = None
        scalar: int | bytes | None = None
        if wire_type == 0:
            scalar, position = read_varint(data, position)
        elif wire_type == 1:
            end = position + 8
            if end > len(data):
                raise TargetReaderError("truncated protobuf fixed64")
            scalar = data[position:end]
            position = end
        elif wire_type == 2:
            length, position = read_varint(data, position)
            end = position + length
            if end > len(data):
                raise TargetReaderError("truncated length-delimited field")
            payload = data[position:end]
            position = end
        elif wire_type == 5:
            end = position + 4
            if end > len(data):
                raise TargetReaderError("truncated protobuf fixed32")
            scalar = data[position:end]
            position = end
        else:
            raise TargetReaderError(f"unsupported protobuf wire type: {wire_type}")
        yield WireField(number, wire_type, data[start:position], payload, scalar)


def require_known_fields(fields: list[WireField], allowed: frozenset[int], name: str) -> None:
    unknown = sorted({field.number for field in fields if field.number not in allowed})
    if unknown:
        raise TargetReaderError(f"unknown {name} fields: {unknown}")


def fields_numbered(fields: list[WireField], number: int) -> list[WireField]:
    return [field for field in fields if field.number == number]


def require_one(fields: list[WireField], number: int, name: str) -> WireField:
    selected = fields_numbered(fields, number)
    if len(selected) != 1:
        raise TargetReaderError(f"expected exactly one {name}, got {len(selected)}")
    return selected[0]


def require_varint(field: WireField, name: str) -> int:
    if field.wire_type != 0 or not isinstance(field.scalar, int):
        raise TargetReaderError(f"{name} is not a protobuf varint")
    return field.scalar


def require_payload(field: WireField, name: str) -> bytes:
    if field.wire_type != 2 or field.payload is None:
        raise TargetReaderError(f"{name} is not length-delimited")
    return field.payload


def extract_reaction_id(reaction_wire: bytes) -> str:
    fields = list(iter_wire_fields(reaction_wire))
    require_known_fields(fields, REACTION_FIELDS, "Reaction")
    field = require_one(fields, REACTION_ID_FIELD, "Reaction.reaction_id")
    payload = require_payload(field, "Reaction.reaction_id")
    try:
        reaction_id = payload.decode("utf-8")
    except UnicodeDecodeError as error:
        raise TargetReaderError("reaction_id is not valid UTF-8") from error
    if not reaction_id:
        raise TargetReaderError("reaction_id is empty")
    return reaction_id


def decode_percentage(percentage_wire: bytes) -> Fraction:
    fields = list(iter_wire_fields(percentage_wire))
    require_known_fields(fields, PERCENTAGE_FIELDS, "Percentage")
    value_field = require_one(fields, PERCENTAGE_VALUE_FIELD, "Percentage.value")
    if value_field.wire_type != 5 or not isinstance(value_field.scalar, bytes):
        raise TargetReaderError("Percentage.value is not float32")
    value = struct.unpack("<f", value_field.scalar)[0]
    if not math.isfinite(value):
        raise TargetReaderError("yield is not finite")
    if value < 0.0 or value > 100.0:
        raise TargetReaderError("yield is outside [0,100]")
    return Fraction.from_float(value)


def decode_yield_measurement(measurement_wire: bytes) -> Fraction | None:
    fields = list(iter_wire_fields(measurement_wire))
    require_known_fields(fields, MEASUREMENT_FIELDS, "ProductMeasurement")
    type_field = require_one(fields, MEASUREMENT_TYPE_FIELD, "measurement type")
    measurement_type = require_varint(type_field, "measurement type")
    if measurement_type != MEASUREMENT_TYPE_YIELD:
        return None
    target_fields = [field for field in fields if field.number in TARGET_VALUE_FIELDS]
    percentage_fields = [
        field for field in target_fields if field.number == MEASUREMENT_PERCENTAGE_FIELD
    ]
    if len(target_fields) != 1 or len(percentage_fields) != 1:
        raise TargetReaderError("YIELD must contain exactly one Percentage target")
    percentage_wire = require_payload(percentage_fields[0], "yield Percentage")
    return decode_percentage(percentage_wire)


def decode_product_target(product_wire: bytes) -> Fraction:
    fields = list(iter_wire_fields(product_wire))
    require_known_fields(fields, PRODUCT_FIELDS, "ProductCompound")
    desired_field = require_one(fields, PRODUCT_DESIRED_FIELD, "is_desired_product")
    if require_varint(desired_field, "is_desired_product") != 1:
        raise TargetReaderError("product is not the desired product")
    role_field = require_one(fields, PRODUCT_ROLE_FIELD, "product reaction role")
    if require_varint(role_field, "product reaction role") != PRODUCT_ROLE_PRODUCT:
        raise TargetReaderError("desired compound does not have PRODUCT role")
    values: list[Fraction] = []
    for measurement_field in fields_numbered(fields, PRODUCT_MEASUREMENT_FIELD):
        measurement_wire = require_payload(measurement_field, "ProductMeasurement")
        value = decode_yield_measurement(measurement_wire)
        if value is not None:
            values.append(value)
    if len(values) != 1:
        raise TargetReaderError(f"expected exactly one YIELD measurement, got {len(values)}")
    return values[0]


def decode_reaction_target(reaction_wire: bytes) -> Fraction:
    fields = list(iter_wire_fields(reaction_wire))
    require_known_fields(fields, REACTION_FIELDS, "Reaction")
    outcome_field = require_one(fields, REACTION_OUTCOME_FIELD, "Reaction.outcomes")
    outcome_wire = require_payload(outcome_field, "Reaction.outcomes")
    outcome_fields = list(iter_wire_fields(outcome_wire))
    require_known_fields(outcome_fields, OUTCOME_FIELDS, "ReactionOutcome")
    product_field = require_one(
        outcome_fields,
        OUTCOME_PRODUCT_FIELD,
        "ReactionOutcome.products",
    )
    product_wire = require_payload(product_field, "ReactionOutcome.products")
    return decode_product_target(product_wire)


def ensure_real_mode(mode: str) -> None:
    if mode not in REAL_MODES:
        raise TargetReaderError(
            "real target reader permits construction or selection only"
        )


def encode_varint(value: int) -> bytes:
    if value < 0:
        raise ValueError("synthetic varint cannot be negative")
    output = bytearray()
    while True:
        byte = value & 0x7F
        value >>= 7
        if value:
            output.append(byte | 0x80)
        else:
            output.append(byte)
            return bytes(output)


def encode_tag(number: int, wire_type: int) -> bytes:
    return encode_varint((number << 3) | wire_type)


def encode_varint_field(number: int, value: int) -> bytes:
    return encode_tag(number, 0) + encode_varint(value)


def encode_payload_field(number: int, payload: bytes) -> bytes:
    return encode_tag(number, 2) + encode_varint(len(payload)) + payload


def encode_fixed32_float_field(number: int, value: float) -> bytes:
    return encode_tag(number, 5) + struct.pack("<f", value)


def encode_fixed64_float_field(number: int, value: float) -> bytes:
    return encode_tag(number, 1) + struct.pack("<d", value)


def synthetic_measurement(
    measurement_type: int = MEASUREMENT_TYPE_YIELD,
    percentage_values: tuple[float, ...] = (50.0,),
    percentage_wire_type: int = 5,
    include_percentage: bool = True,
    include_alternate_target: bool = False,
) -> bytes:
    output = bytearray(encode_varint_field(MEASUREMENT_TYPE_FIELD, measurement_type))
    if include_percentage:
        percentage = bytearray()
        for value in percentage_values:
            if percentage_wire_type == 5:
                percentage.extend(
                    encode_fixed32_float_field(PERCENTAGE_VALUE_FIELD, value)
                )
            elif percentage_wire_type == 1:
                percentage.extend(
                    encode_fixed64_float_field(PERCENTAGE_VALUE_FIELD, value)
                )
            else:
                raise ValueError("unsupported synthetic Percentage wire type")
        output.extend(
            encode_payload_field(MEASUREMENT_PERCENTAGE_FIELD, bytes(percentage))
        )
    if include_alternate_target:
        output.extend(encode_payload_field(9, b"\x0d\x00\x00\x20\x42"))
    return bytes(output)


def synthetic_product(
    desired: bool = True,
    role: int = PRODUCT_ROLE_PRODUCT,
    measurements: tuple[bytes, ...] | None = None,
) -> bytes:
    if measurements is None:
        measurements = (synthetic_measurement(),)
    output = bytearray(encode_varint_field(PRODUCT_DESIRED_FIELD, int(desired)))
    for measurement in measurements:
        output.extend(encode_payload_field(PRODUCT_MEASUREMENT_FIELD, measurement))
    output.extend(encode_varint_field(PRODUCT_ROLE_FIELD, role))
    return bytes(output)


def synthetic_outcome(products: tuple[bytes, ...] | None = None) -> bytes:
    if products is None:
        products = (synthetic_product(),)
    return b"".join(
        encode_payload_field(OUTCOME_PRODUCT_FIELD, product) for product in products
    )


def synthetic_reaction(
    reaction_id: str | None = "synthetic-reaction",
    outcomes: tuple[bytes, ...] | None = None,
    extra: bytes = b"",
) -> bytes:
    if outcomes is None:
        outcomes = (synthetic_outcome(),)
    output = bytearray()
    for outcome in outcomes:
        output.extend(encode_payload_field(REACTION_OUTCOME_FIELD, outcome))
    if reaction_id is not None:
        output.extend(encode_payload_field(REACTION_ID_FIELD, reaction_id.encode()))
    output.extend(extra)
    return bytes(output)


def synthetic_hash(label: str) -> str:
    return domain_hash("cp0-synthetic-identity-v1", label)


def synthetic_positive_rows() -> tuple[list[bytes], dict[str, dict[str, str]]]:
    specifications = [
        ("boundary-zero", "amine-a", "acid-a", "env-a", 0.0),
        ("boundary-hundred", "amine-b", "acid-b", "env-a", 100.0),
        ("duplicate-left", "amine-c", "acid-c", "env-b", 10.0),
        ("duplicate-right", "amine-c", "acid-c", "env-b", 30.0),
        ("binary-tenth", "amine-d", "acid-d", "env-c", 0.1),
        ("exact-eighth", "amine-e", "acid-e", "env-c", 50.125),
    ]
    reactions: list[bytes] = []
    manifest: dict[str, dict[str, str]] = {}
    for reaction_id, amine, acid, environment, target in specifications:
        measurement = synthetic_measurement(percentage_values=(target,))
        reaction = synthetic_reaction(
            reaction_id,
            (synthetic_outcome((synthetic_product(measurements=(measurement,)),)),),
        )
        reaction_hash = domain_hash("cp0-reaction-id-v1", reaction_id)
        reactions.append(reaction)
        manifest[reaction_hash] = {
            "reaction_id_sha256": reaction_hash,
            "amine_sha256": synthetic_hash(amine),
            "acid_sha256": synthetic_hash(acid),
            "semantic_condition_sha256": synthetic_hash(environment),
            "label_condition_sha256": synthetic_hash("label-" + environment),
            "compartment": "synthetic-audit",
        }
    return reactions, manifest


def decode_manifest_row(
    reaction_wire: bytes,
    manifest: dict[str, dict[str, str]],
    compartment: str,
) -> tuple[dict[str, str], Fraction] | None:
    reaction_id = extract_reaction_id(reaction_wire)
    reaction_hash = domain_hash("cp0-reaction-id-v1", reaction_id)
    reference = manifest.get(reaction_hash)
    if reference is None:
        raise TargetReaderError("reaction_id is absent from the frozen manifest")
    if reference["compartment"] != compartment:
        return None
    return reference, decode_reaction_target(reaction_wire)


def aggregate_targets(
    rows: list[tuple[dict[str, str], Fraction]],
) -> list[dict[str, int | str]]:
    grouped: dict[tuple[str, str, str], list[Fraction]] = defaultdict(list)
    for reference, value in rows:
        key = (
            reference["amine_sha256"],
            reference["acid_sha256"],
            reference["semantic_condition_sha256"],
        )
        grouped[key].append(value)
    output: list[dict[str, int | str]] = []
    for key in sorted(grouped):
        values = grouped[key]
        mean = sum(values, Fraction(0, 1)) / len(values)
        output.append(
            {
                "amine_sha256": key[0],
                "acid_sha256": key[1],
                "semantic_condition_sha256": key[2],
                "target_numerator": mean.numerator,
                "target_denominator": mean.denominator,
                "row_count": len(values),
            }
        )
    return output


def run_synthetic_audit() -> tuple[list[dict[str, int | str]], dict[str, Any], dict[str, Any]]:
    reactions, manifest = synthetic_positive_rows()
    decoded: list[tuple[dict[str, str], Fraction]] = []
    for reaction in reactions:
        row = decode_manifest_row(reaction, manifest, "synthetic-audit")
        if row is None:
            raise AssertionError("synthetic positive row was unexpectedly sealed")
        decoded.append(row)
    grouped = aggregate_targets(decoded)
    means = {
        (
            row["amine_sha256"],
            row["acid_sha256"],
            row["semantic_condition_sha256"],
        ): Fraction(int(row["target_numerator"]), int(row["target_denominator"]))
        for row in grouped
    }
    duplicate_key = (
        synthetic_hash("amine-c"),
        synthetic_hash("acid-c"),
        synthetic_hash("env-b"),
    )
    if means[duplicate_key] != Fraction(20, 1):
        raise AssertionError("exact grouped mean is not 20")
    values = [value for _, value in decoded]
    if Fraction(0, 1) not in values or Fraction(100, 1) not in values:
        raise AssertionError("closed-interval boundaries were not accepted")
    float32_tenth = Fraction.from_float(struct.unpack("<f", struct.pack("<f", 0.1))[0])
    if float32_tenth not in values:
        raise AssertionError("float32 target was not preserved exactly")

    valid_outcome = synthetic_outcome()
    valid_product = synthetic_product()
    negative_cases: list[tuple[str, bytes]] = [
        (
            "below_zero",
            synthetic_reaction(
                outcomes=(synthetic_outcome((synthetic_product(measurements=(
                    synthetic_measurement(percentage_values=(-0.25,)),
                )),)),),
            ),
        ),
        (
            "above_hundred",
            synthetic_reaction(
                outcomes=(synthetic_outcome((synthetic_product(measurements=(
                    synthetic_measurement(percentage_values=(100.25,)),
                )),)),),
            ),
        ),
        (
            "nan",
            synthetic_reaction(
                outcomes=(synthetic_outcome((synthetic_product(measurements=(
                    synthetic_measurement(percentage_values=(float("nan"),)),
                )),)),),
            ),
        ),
        (
            "infinity",
            synthetic_reaction(
                outcomes=(synthetic_outcome((synthetic_product(measurements=(
                    synthetic_measurement(percentage_values=(float("inf"),)),
                )),)),),
            ),
        ),
        ("missing_outcome", synthetic_reaction(outcomes=())),
        ("duplicate_outcome", synthetic_reaction(outcomes=(valid_outcome, valid_outcome))),
        ("missing_product", synthetic_reaction(outcomes=(synthetic_outcome(()),))),
        (
            "duplicate_product",
            synthetic_reaction(outcomes=(synthetic_outcome((valid_product, valid_product)),)),
        ),
        (
            "not_desired",
            synthetic_reaction(outcomes=(synthetic_outcome((synthetic_product(False),)),)),
        ),
        (
            "wrong_product_role",
            synthetic_reaction(outcomes=(synthetic_outcome((synthetic_product(role=9),)),)),
        ),
        (
            "missing_yield",
            synthetic_reaction(outcomes=(synthetic_outcome((synthetic_product(
                measurements=(synthetic_measurement(
                    measurement_type=2,
                    include_percentage=False,
                ),),
            ),)),)),
        ),
        (
            "duplicate_yield",
            synthetic_reaction(outcomes=(synthetic_outcome((synthetic_product(
                measurements=(synthetic_measurement(), synthetic_measurement()),
            ),)),)),
        ),
        (
            "missing_percentage",
            synthetic_reaction(outcomes=(synthetic_outcome((synthetic_product(
                measurements=(synthetic_measurement(include_percentage=False),),
            ),)),)),
        ),
        (
            "duplicate_percentage_value",
            synthetic_reaction(outcomes=(synthetic_outcome((synthetic_product(
                measurements=(synthetic_measurement(percentage_values=(10.0, 20.0)),),
            ),)),)),
        ),
        (
            "wrong_percentage_wire_type",
            synthetic_reaction(outcomes=(synthetic_outcome((synthetic_product(
                measurements=(synthetic_measurement(percentage_wire_type=1),),
            ),)),)),
        ),
        (
            "alternate_target_field",
            synthetic_reaction(outcomes=(synthetic_outcome((synthetic_product(
                measurements=(synthetic_measurement(include_alternate_target=True),),
            ),)),)),
        ),
        ("missing_reaction_id", synthetic_reaction(reaction_id=None)),
        (
            "duplicate_reaction_id",
            synthetic_reaction(extra=encode_payload_field(REACTION_ID_FIELD, b"second")),
        ),
        ("unknown_reaction_field", synthetic_reaction(extra=encode_varint_field(11, 1))),
        ("truncated_wire", synthetic_reaction()[:-1]),
    ]
    rejected: list[dict[str, str]] = []
    for name, reaction in negative_cases:
        try:
            extract_reaction_id(reaction)
            decode_reaction_target(reaction)
        except TargetReaderError as error:
            rejected.append({"case": name, "error": str(error)})
        else:
            raise AssertionError(f"negative case was accepted: {name}")

    unknown_reaction = synthetic_reaction("not-in-manifest")
    try:
        decode_manifest_row(unknown_reaction, manifest, "synthetic-audit")
    except TargetReaderError as error:
        rejected.append({"case": "manifest_miss", "error": str(error)})
    else:
        raise AssertionError("reaction absent from manifest was accepted")

    try:
        ensure_real_mode("held_out_test")
    except TargetReaderError as error:
        rejected.append({"case": "held_out_mode", "error": str(error)})
    else:
        raise AssertionError("held_out_test mode was accepted")

    sealed_id = "sealed-malformed-target"
    sealed_hash = domain_hash("cp0-reaction-id-v1", sealed_id)
    sealed_manifest = {
        sealed_hash: {
            "reaction_id_sha256": sealed_hash,
            "amine_sha256": synthetic_hash("sealed-amine"),
            "acid_sha256": synthetic_hash("sealed-acid"),
            "semantic_condition_sha256": synthetic_hash("sealed-env"),
            "label_condition_sha256": synthetic_hash("sealed-label"),
            "compartment": "held_out_test",
        }
    }
    sealed_wire = synthetic_reaction(sealed_id, outcomes=(b"\xff",))
    if decode_manifest_row(sealed_wire, sealed_manifest, "construction") is not None:
        raise AssertionError("unselected malformed target was decoded")

    positive = {
        "record_type": "synthetic_positive_audit",
        "synthetic_rows_decoded": len(decoded),
        "synthetic_groups": len(grouped),
        "duplicate_group_rows": 2,
        "duplicate_group_exact_mean_numerator": 20,
        "duplicate_group_exact_mean_denominator": 1,
        "zero_boundary_accepted": True,
        "hundred_boundary_accepted": True,
        "float32_exact_rational_preserved": True,
    }
    negative = {
        "record_type": "synthetic_negative_audit",
        "negative_cases": len(rejected),
        "negative_cases_rejected": len(rejected),
        "rejections": rejected,
        "held_out_mode_absent": True,
        "unselected_malformed_target_skipped_without_decode": True,
        "real_source_opened": False,
        "i0_manifest_opened": False,
        "real_target_values_decoded": 0,
    }
    return grouped, positive, negative


def load_manifest(path: Path) -> dict[str, dict[str, str]]:
    if sha256_file(path) != I0_MANIFEST_SHA256:
        raise TargetReaderError("unexpected CP0-I0 manifest hash")
    with gzip.open(path, "rt", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        if tuple(reader.fieldnames or ()) != EXPECTED_MANIFEST_COLUMNS:
            raise TargetReaderError("unexpected CP0-I0 manifest columns")
        rows = list(reader)
    if len(rows) != EXPECTED_REACTIONS:
        raise TargetReaderError("unexpected CP0-I0 manifest row count")
    indexed = {row["reaction_id_sha256"]: row for row in rows}
    if len(indexed) != len(rows):
        raise TargetReaderError("duplicate reaction hash in CP0-I0 manifest")
    return indexed


def load_official_reactions(path: Path) -> list[bytes]:
    if path.stat().st_size != SOURCE_SIZE or sha256_file(path) != SOURCE_SHA256:
        raise TargetReaderError("unexpected official ORD source")
    with gzip.open(path, "rb") as handle:
        dataset_wire = handle.read()
    fields = list(iter_wire_fields(dataset_wire))
    dataset_name = ""
    dataset_id = ""
    reactions: list[bytes] = []
    for field in fields:
        if field.number == 1:
            dataset_name = require_payload(field, "Dataset.name").decode("utf-8")
        elif field.number == 3:
            reactions.append(require_payload(field, "Dataset.reactions"))
        elif field.number == 5:
            dataset_id = require_payload(field, "Dataset.dataset_id").decode("utf-8")
    if dataset_name != DATASET_NAME or dataset_id != DATASET_ID:
        raise TargetReaderError("unexpected ORD Dataset identity")
    if len(reactions) != EXPECTED_REACTIONS:
        raise TargetReaderError("unexpected official reaction count")
    return reactions


def run_real_partition(
    mode: str,
    source_path: Path,
    manifest_path: Path,
) -> tuple[list[dict[str, int | str]], dict[str, Any]]:
    ensure_real_mode(mode)
    manifest = load_manifest(manifest_path)
    reactions = load_official_reactions(source_path)
    seen: set[str] = set()
    decoded: list[tuple[dict[str, str], Fraction]] = []
    skipped_target_envelopes = 0
    for reaction in reactions:
        reaction_id = extract_reaction_id(reaction)
        reaction_hash = domain_hash("cp0-reaction-id-v1", reaction_id)
        if reaction_hash in seen:
            raise TargetReaderError("duplicate reaction_id in official source")
        seen.add(reaction_hash)
        reference = manifest.get(reaction_hash)
        if reference is None:
            raise TargetReaderError("official reaction absent from CP0-I0 manifest")
        if reference["compartment"] != mode:
            skipped_target_envelopes += 1
            continue
        decoded.append((reference, decode_reaction_target(reaction)))
    if len(seen) != len(manifest):
        raise TargetReaderError("official source does not cover CP0-I0 manifest")
    grouped = aggregate_targets(decoded)
    report = {
        "record_type": "real_partition",
        "compartment": mode,
        "official_reactions": len(reactions),
        "target_rows_decoded": len(decoded),
        "target_groups": len(grouped),
        "target_envelopes_not_decoded": skipped_target_envelopes,
        "held_out_mode_available": False,
    }
    return grouped, report


def write_deterministic_csv_gz(
    path: Path,
    rows: list[dict[str, int | str]],
) -> None:
    fieldnames = (
        "amine_sha256",
        "acid_sha256",
        "semantic_condition_sha256",
        "target_numerator",
        "target_denominator",
        "row_count",
    )
    with path.open("wb") as raw:
        with gzip.GzipFile(filename="", mode="wb", fileobj=raw, mtime=0) as compressed:
            with io.TextIOWrapper(compressed, encoding="utf-8", newline="") as text:
                writer = csv.DictWriter(text, fieldnames=fieldnames, lineterminator="\n")
                writer.writeheader()
                writer.writerows(rows)


def validate_run_contract(args: argparse.Namespace) -> str:
    script_hash = sha256_file(Path(__file__))
    if script_hash != args.script_sha256:
        raise TargetReaderError("script hash mismatch")
    suffix = f"_{args.run_suffix}"
    expected = {
        args.out_targets_csv_gz: f"{suffix}.csv.gz",
        args.out_jsonl: f"{suffix}.jsonl",
        args.out_txt: f"{suffix}.txt",
        args.out_dependencies_json: f"{suffix}.json",
    }
    for output, ending in expected.items():
        if not output.name.endswith(ending):
            raise TargetReaderError(f"output does not share suffix {ending}: {output}")
        if output.exists():
            raise FileExistsError(f"refusing to overwrite {output}")
        output.parent.mkdir(parents=True, exist_ok=True)
    if args.frozen_run and not Path(__file__).stem.endswith(suffix):
        raise TargetReaderError("frozen script name does not contain run suffix")
    if sys.version_info[:2] != (3, 10):
        raise TargetReaderError(
            f"Python 3.10 required, got {platform.python_version()}"
        )
    if args.mode == "synthetic-audit":
        if args.source_pb_gz is not None or args.i0_manifest_csv_gz is not None:
            raise TargetReaderError("synthetic audit forbids real source arguments")
    else:
        ensure_real_mode(args.mode)
        if args.source_pb_gz is None or args.i0_manifest_csv_gz is None:
            raise TargetReaderError("real mode requires source and manifest")
    return script_hash


def main() -> None:
    args = parse_args()
    script_hash = validate_run_contract(args)
    command = shlex.join(sys.argv)
    run_at = dt.datetime.now(dt.timezone.utc).isoformat()
    if args.mode == "synthetic-audit":
        targets, positive, negative = run_synthetic_audit()
        records = [positive, negative]
        verdict = "T2_SYNTHETIC_TARGET_READER_FROZEN"
    else:
        assert args.source_pb_gz is not None
        assert args.i0_manifest_csv_gz is not None
        targets, partition_report = run_real_partition(
            args.mode,
            args.source_pb_gz,
            args.i0_manifest_csv_gz,
        )
        records = [partition_report]
        verdict = f"TARGET_PARTITION_READ_{args.mode.upper()}"

    write_deterministic_csv_gz(args.out_targets_csv_gz, targets)
    targets_hash = sha256_file(args.out_targets_csv_gz)
    run_record = {
        "record_type": "run",
        "command": command,
        "run_at_utc": run_at,
        "mode": args.mode,
        "script_sha256": script_hash,
        "targets_csv_gz_sha256": targets_hash,
        "python_version": platform.python_version(),
        "verdict": verdict,
    }
    with args.out_jsonl.open("x", encoding="utf-8", newline="\n") as handle:
        for record in (run_record, *records):
            handle.write(canonical_json(record) + "\n")

    dependencies = {
        "command": command,
        "mode": args.mode,
        "python_version": platform.python_version(),
        "implementation": platform.python_implementation(),
        "script_sha256": script_hash,
        "stdlib_only": True,
        "official_source_sha256_declared_not_opened_in_synthetic": SOURCE_SHA256,
        "i0_manifest_sha256_declared_not_opened_in_synthetic": I0_MANIFEST_SHA256,
        "reaction_pb2_sha256_schema_contract": REACTION_PB2_SHA256,
    }
    with args.out_dependencies_json.open("x", encoding="utf-8", newline="\n") as handle:
        json.dump(dependencies, handle, indent=2, sort_keys=True)
        handle.write("\n")

    summary = [
        f"command: {command}",
        f"script_sha256: {script_hash}",
        f"mode: {args.mode}",
        f"run_at_utc: {run_at}",
        f"targets_csv_gz_sha256: {targets_hash}",
        f"target_groups: {len(targets)}",
    ]
    if args.mode == "synthetic-audit":
        summary.extend(
            [
                f"synthetic_rows_decoded: {records[0]['synthetic_rows_decoded']}",
                f"negative_cases_rejected: {records[1]['negative_cases_rejected']}",
                "real_source_opened: false",
                "i0_manifest_opened: false",
                "real_target_values_decoded: 0",
            ]
        )
    summary.append(f"verdict: {verdict}")
    args.out_txt.write_text("\n".join(summary) + "\n", encoding="utf-8")
    print(verdict)


if __name__ == "__main__":
    main()
