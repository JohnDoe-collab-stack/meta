#!/usr/bin/env python3
"""Audit strictement les métadonnées publiques de jeux ORD candidats.

Ce programme refuse tout champ autre que les cinq champs de DatasetInfo
exposés par ``GET /api/datasets``. Il ne télécharge donc ni réaction, ni
réactif, ni produit, ni mesure expérimentale.
"""

from __future__ import annotations

import argparse
import dataclasses
import datetime as dt
import hashlib
import json
from pathlib import Path
import shlex
import sys
from typing import Any
import urllib.request


DEFAULT_URL = "https://open-reaction-database.org/api/datasets"
ALLOWED_FIELDS = frozenset(
    {"dataset_id", "name", "description", "num_reactions", "submitted_at"}
)
OVERALL_VERDICT = "GO-INPUT-AUDIT"
RECOMMENDED_DATASET_ID = "ord_dataset-47eaacc46c3a4487bbdf99adb1a15e41"


@dataclasses.dataclass(frozen=True)
class CandidateSpec:
    dataset_id: str
    priority: int
    decision: str
    required_fragments: tuple[str, ...]
    rationale: str


CANDIDATES = (
    CandidateSpec(
        dataset_id=RECOMMENDED_DATASET_ID,
        priority=1,
        decision="ADVANCE_INPUT_AUDIT",
        required_fragments=(
            "70 amines",
            "66 acids",
            "632 product pairs",
            "95 different coupling conditions",
        ),
        rationale=(
            "Le nombre d'identites de chaque partenaire et le plan multi-conditions "
            "rendent possible en principe un test groupe par molecules. Les lignes, "
            "structures et reponses doivent encore etre auditees sans cible."
        ),
    ),
    CandidateSpec(
        dataset_id="ord_dataset-805ad863feef48579d95d86a728035f4",
        priority=2,
        decision="RESERVE_TOO_FEW_SUBSTRATE_IDENTITIES",
        required_fragments=("2 amines", "4 aryl halides", "50,688"),
        rationale=(
            "Le volume de lignes est eleve, mais six identites de substrats declarees "
            "sont trop peu nombreuses pour le test principal tenu hors molecules."
        ),
    ),
    CandidateSpec(
        dataset_id="ord_dataset-dc0249930af34d17a3c76881a762aebf",
        priority=3,
        decision="RESERVE_SPARSE_PAIRINGS",
        required_fragments=("26 pairings", "136 reaction datapoints"),
        rationale=(
            "Vingt-six paires permettent un holdout conceptuel, mais 136 lignes offrent "
            "peu de repetitions par paire pour separer identite et conditions."
        ),
    ),
    CandidateSpec(
        dataset_id="ord_dataset-c703268ea43a4c7e802c6048b6166b34",
        priority=4,
        decision="RESERVE_SMALL_IDENTITY_SET",
        required_fragments=("5 pairings", "120 reaction datapoints"),
        rationale=(
            "Cinq paires seulement rendent le decoupage par identites trop fragile pour "
            "le test principal, mais le jeu peut servir de controle de pipeline."
        ),
    ),
    CandidateSpec(
        dataset_id="ord_dataset-1ec2807f02fa4beda27d2a81b86eb843",
        priority=5,
        decision="REJECT_NO_SUBSTRATE_HOLDOUT",
        required_fragments=("uni-molecular rearrangement", "2 products"),
        rationale=(
            "Une seule transformation unimoleculaire declaree varie surtout les "
            "conditions; elle ne teste pas la generalisation a de nouveaux substrats."
        ),
    ),
    CandidateSpec(
        dataset_id="ord_dataset-5c9a10329a8a48968d18879a48bb8ab2",
        priority=6,
        decision="RESERVE_ONTOLOGY_COMPLEX",
        required_fragments=("44 sulfonamides", "2 boronic acids", "4 copper catalysts"),
        rationale=(
            "Le partenaire boronique varie trop peu et l'ontologie soufre-bore-cuivre "
            "elargirait fortement le premier fragment chimique."
        ),
    ),
    CandidateSpec(
        dataset_id="ord_dataset-c5b00523487a4211a194160edf45e9ab",
        priority=7,
        decision="RESERVE_STEREOCHEMISTRY_COMPLEX",
        required_fragments=(
            "10 bromoacetophenones",
            "13 photocatalysts",
            "11 organocatalysts",
        ),
        rationale=(
            "La stereoselectivite et les deux familles de catalyseurs imposeraient une "
            "ontologie disproportionnee pour CP0."
        ),
    ),
    CandidateSpec(
        dataset_id="ord_dataset-7acd6ad2bf4d4cff841cad008ab726d5",
        priority=8,
        decision="RESERVE_FIXED_ACID_CORE",
        required_fragments=("10 anilines", "fixed indomethacin carboxylic core"),
        rationale=(
            "Le coeur acide fixe ne permet pas un holdout bilateral des deux partenaires "
            "de couplage."
        ),
    ),
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--url", default=DEFAULT_URL)
    parser.add_argument("--out-jsonl", required=True, type=Path)
    parser.add_argument("--out-txt", required=True, type=Path)
    parser.add_argument("--out-source-json", required=True, type=Path)
    parser.add_argument("--run-suffix", required=True)
    parser.add_argument("--script-sha256", required=True)
    parser.add_argument("--ord-interface-commit", required=True)
    parser.add_argument("--ord-data-commit", required=True)
    parser.add_argument("--ord-schema-commit", required=True)
    parser.add_argument(
        "--frozen-run",
        action="store_true",
        help="Exige que le nom du script porte le meme suffixe que les sorties.",
    )
    return parser.parse_args()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def current_script_sha256() -> str:
    return sha256_bytes(Path(__file__).read_bytes())


def validate_run_contract(args: argparse.Namespace, script_sha256: str) -> None:
    if script_sha256 != args.script_sha256:
        raise ValueError(
            f"hash du script inattendu: calcule={script_sha256} "
            f"attendu={args.script_sha256}"
        )
    expected_tail = f"_{args.run_suffix}"
    for output in (args.out_jsonl, args.out_txt, args.out_source_json):
        if not output.stem.endswith(expected_tail):
            raise ValueError(
                f"sortie sans suffixe commun {args.run_suffix!r}: {output}"
            )
        if output.exists():
            raise FileExistsError(f"refus d'ecraser une sortie existante: {output}")
    if args.frozen_run and not Path(__file__).stem.endswith(expected_tail):
        raise ValueError(
            "le nom du script fige ne porte pas le suffixe timestamp+hash des sorties"
        )


def fetch_metadata(url: str) -> tuple[bytes, str]:
    request = urllib.request.Request(
        url,
        headers={"User-Agent": "meta-carbon-cp0-metadata-audit/1.0"},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        if response.status != 200:
            raise RuntimeError(f"HTTP inattendu: {response.status}")
        return response.read(), response.headers.get("Content-Type", "")


def validate_dataset_row(row: Any, index: int) -> dict[str, Any]:
    if not isinstance(row, dict):
        raise TypeError(f"ligne {index}: objet JSON attendu")
    fields = set(row)
    if fields != ALLOWED_FIELDS:
        added = sorted(fields - ALLOWED_FIELDS)
        missing = sorted(ALLOWED_FIELDS - fields)
        raise ValueError(
            f"ligne {index}: schema metadata refuse; ajouts={added}, manquants={missing}"
        )
    textual_fields = ("dataset_id", "name", "description", "submitted_at")
    if not all(isinstance(row[key], str) for key in textual_fields):
        raise TypeError(f"ligne {index}: types textuels invalides")
    if not isinstance(row["num_reactions"], int) or isinstance(row["num_reactions"], bool):
        raise TypeError(f"ligne {index}: num_reactions doit etre un entier")
    if row["num_reactions"] < 0:
        raise ValueError(f"ligne {index}: num_reactions negatif")
    return row


def load_metadata(source_bytes: bytes) -> list[dict[str, Any]]:
    decoded = json.loads(source_bytes)
    if not isinstance(decoded, list):
        raise TypeError("la racine JSON doit etre une liste de metadonnees")
    rows = [validate_dataset_row(row, index) for index, row in enumerate(decoded)]
    ids = [row["dataset_id"] for row in rows]
    if len(ids) != len(set(ids)):
        raise ValueError("dataset_id duplique dans la reponse")
    return rows


def evaluate_candidates(rows: list[dict[str, Any]]) -> list[dict[str, Any]]:
    by_id = {row["dataset_id"]: row for row in rows}
    results: list[dict[str, Any]] = []
    for spec in sorted(CANDIDATES, key=lambda item: item.priority):
        if spec.dataset_id not in by_id:
            raise ValueError(f"candidat absent de la reponse: {spec.dataset_id}")
        row = by_id[spec.dataset_id]
        searchable = f"{row['name']}\n{row['description']}".casefold()
        missing_fragments = [
            fragment
            for fragment in spec.required_fragments
            if fragment.casefold() not in searchable
        ]
        if missing_fragments:
            raise ValueError(
                f"metadonnees modifiees pour {spec.dataset_id}; "
                f"fragments absents={missing_fragments}"
            )
        results.append(
            {
                "record_type": "candidate",
                "priority": spec.priority,
                "decision": spec.decision,
                "rationale": spec.rationale,
                "required_fragments_verified": list(spec.required_fragments),
                **row,
            }
        )
    advanced = [row for row in results if row["decision"] == "ADVANCE_INPUT_AUDIT"]
    if [row["dataset_id"] for row in advanced] != [RECOMMENDED_DATASET_ID]:
        raise AssertionError("la recommandation metadata doit etre unique et preenregistree")
    return results


def canonical_json_line(value: dict[str, Any]) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def render_text(
    command: str,
    script_sha256: str,
    source_sha256: str,
    content_type: str,
    dataset_count: int,
    candidates: list[dict[str, Any]],
    args: argparse.Namespace,
    retrieved_at_utc: str,
) -> str:
    selected = next(
        row for row in candidates if row["dataset_id"] == RECOMMENDED_DATASET_ID
    )
    lines = [
        f"command: {command}",
        f"script_sha256: {script_sha256}",
        f"source_sha256: {source_sha256}",
        f"retrieved_at_utc: {retrieved_at_utc}",
        f"source_url: {args.url}",
        f"source_content_type: {content_type}",
        f"dataset_count: {dataset_count}",
        f"allowed_fields: {','.join(sorted(ALLOWED_FIELDS))}",
        f"ord_interface_commit: {args.ord_interface_commit}",
        f"ord_data_commit: {args.ord_data_commit}",
        f"ord_schema_commit: {args.ord_schema_commit}",
        "target_rows_opened: 0",
        "reaction_rows_opened: 0",
        "product_rows_opened: 0",
        f"verdict: {OVERALL_VERDICT}",
        f"recommended_dataset_id: {RECOMMENDED_DATASET_ID}",
        f"recommended_num_reactions: {selected['num_reactions']}",
        "",
        "candidate_decisions:",
    ]
    for row in candidates:
        lines.append(
            f"{row['priority']:02d} {row['dataset_id']} "
            f"{row['decision']} n={row['num_reactions']}"
        )
    lines.extend(
        [
            "",
            "interpretation:",
            "Le candidat prioritaire passe uniquement la porte des metadonnees.",
            "Le verdict autorise l'audit des entrees et interdit encore l'entrainement,",
            "la lecture des cibles de test et toute revendication predictive.",
            "",
        ]
    )
    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    script_sha256 = current_script_sha256()
    validate_run_contract(args, script_sha256)
    command = shlex.join([sys.executable, *sys.argv])

    source_bytes, content_type = fetch_metadata(args.url)
    source_sha256 = sha256_bytes(source_bytes)
    rows = load_metadata(source_bytes)
    candidates = evaluate_candidates(rows)
    retrieved_at_utc = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat()

    run_record = {
        "record_type": "run",
        "command": command,
        "script_sha256": script_sha256,
        "source_sha256": source_sha256,
        "source_url": args.url,
        "source_content_type": content_type,
        "retrieved_at_utc": retrieved_at_utc,
        "dataset_count": len(rows),
        "allowed_fields": sorted(ALLOWED_FIELDS),
        "ord_interface_commit": args.ord_interface_commit,
        "ord_data_commit": args.ord_data_commit,
        "ord_schema_commit": args.ord_schema_commit,
        "reaction_rows_opened": 0,
        "product_rows_opened": 0,
        "target_rows_opened": 0,
    }
    selected = next(
        row for row in candidates if row["dataset_id"] == RECOMMENDED_DATASET_ID
    )
    pair_condition_capacity = 632 * 95
    verdict_record = {
        "record_type": "verdict",
        "verdict": OVERALL_VERDICT,
        "recommended_dataset_id": RECOMMENDED_DATASET_ID,
        "recommended_num_reactions": selected["num_reactions"],
        "declared_pair_condition_capacity": pair_condition_capacity,
        "row_count_over_declared_pair_condition_capacity": (
            selected["num_reactions"] / pair_condition_capacity
        ),
        "authorization": "INPUT_ONLY_AUDIT",
        "forbidden_next_actions": [
            "TRAIN_MODEL",
            "OPEN_HELD_OUT_TARGETS",
            "CLAIM_PREDICTION",
        ],
    }
    jsonl = "\n".join(
        canonical_json_line(record)
        for record in [run_record, *candidates, verdict_record]
    ) + "\n"
    text_report = render_text(
        command=command,
        script_sha256=script_sha256,
        source_sha256=source_sha256,
        content_type=content_type,
        dataset_count=len(rows),
        candidates=candidates,
        args=args,
        retrieved_at_utc=retrieved_at_utc,
    )

    for output in (args.out_jsonl, args.out_txt, args.out_source_json):
        output.parent.mkdir(parents=True, exist_ok=True)
    args.out_source_json.write_bytes(source_bytes)
    args.out_jsonl.write_text(jsonl, encoding="utf-8")
    args.out_txt.write_text(text_report, encoding="utf-8")
    print(f"{OVERALL_VERDICT}: {RECOMMENDED_DATASET_ID}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
