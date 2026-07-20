"""Command-line entry points for smoke, planning, runs and audits."""

from __future__ import annotations

import argparse
import dataclasses
import json
import sys
from pathlib import Path

import torch

from .audit import audit_all_gates
from .campaign import (
    campaign_dag,
    estimate_matrix,
    evaluation_matrix,
    final_training_matrix,
    tuning_matrix,
)
from .certifiable import certify_catalog, verify_catalog
from .canonical import content_sha256, write_new_json
from .domains import FiniteReferenceDomain, PerceptualDomain, SymbolicDomain
from .data import build_public_data_manifest
from .encoding import BYTE_VOCAB_SIZE, encode_episode_batch
from .evaluation import EvaluationConfig, evaluate_checkpoint
from .falsification import run_mutation_suite
from .interventions import INTERVENTIONS
from .intervention_runner import InterventionRunConfig, run_paired_interventions
from .models import CATALOG_SIZES, CausalAgent
from .ood import open_records, seal_records
from .preflight import run_preflight
from .reference_agent import ExactActiveAgent
from .splits import OOD_FAMILIES, audit_structural_disjointness, make_ood_episode
from .statistics import exact_sign_flip_pvalue, hierarchical_paired_bootstrap, holm_adjust
from .traces import audit_trace_jsonl, write_trace_jsonl
from .training import TrainConfig, train_one_run


PROJECT_ROOT = Path(__file__).resolve().parent.parent


def _json_print(value: object) -> None:
    print(json.dumps(value, indent=2, sort_keys=True, default=str))


def _domain(name: str) -> object:
    if name == "finite":
        return FiniteReferenceDomain()
    if name == "perceptual":
        return PerceptualDomain()
    if name == "symbolic":
        return SymbolicDomain()
    raise ValueError(f"unknown domain {name}")


def _model_smoke(domain: object, episode: object) -> dict[str, object]:
    torch.manual_seed(23)
    model = CausalAgent(size="small", vocab_size=BYTE_VOCAB_SIZE, dropout=0.0)
    model.eval()
    encoded = encode_episode_batch(domain, [episode])
    masks = {
        name: torch.ones(1, size, dtype=torch.bool)
        for name, size in CATALOG_SIZES.items()
    }
    with torch.no_grad():
        context = model.encode_public(
            encoded.observation,
            encoded.candidate,
            encoded.history,
            encoded.symbolic,
        )
        pre = model.decide_pre_response(context, masks)
    return {
        "context_shape": tuple(context.shape),
        "pre_heads": tuple(pre),
        "parameter_count": sum(parameter.numel() for parameter in model.parameters()),
        "bypass_violations": model.forbidden_bypass_audit(),
    }


def command_smoke(output_directory: str) -> dict[str, object]:
    output = Path(output_directory)
    output.mkdir(parents=True, exist_ok=False)
    exact = ExactActiveAgent()
    domains = {
        "finite": FiniteReferenceDomain(),
        "symbolic": SymbolicDomain(),
        "perceptual": PerceptualDomain(),
    }
    reports: dict[str, object] = {}
    for domain_index, (name, domain) in enumerate(domains.items()):
        episodes = [
            domain.generate_episode(23_000 + domain_index, actual_index=index)
            for index in (0, 7, 13, 31)
        ]
        traces = [exact.run(domain, episode, 23_000 + index) for index, episode in enumerate(episodes)]
        trace_path = output / f"{name}_smoke_traces.jsonl"
        trace_hash = write_trace_jsonl(trace_path, traces)
        reports[name] = {
            "episodes": len(episodes),
            "all_closed": all(trace.closed for trace in traces),
            "maximum_steps": max(len(trace.steps) for trace in traces),
            "trace_hash": trace_hash,
            "trace_audit": audit_trace_jsonl(trace_path),
        }
        if name in {"symbolic", "perceptual"}:
            reports[name]["model"] = _model_smoke(domain, episodes[0])
    key = bytes(range(32))
    seal_manifest = seal_records(
        ({"smoke_id": index, "private": index * index} for index in range(4)),
        output / "sealed_ood_smoke",
        key,
        {"family": "smoke-only", "not_scientific": True},
        record_count=4,
    )
    opened = open_records(output / "sealed_ood_smoke", key)
    raw_holm = holm_adjust({"a": 0.01, "b": 0.04, "c": 0.5})
    statistics = {
        "exact_sign_p_micros": int(round(exact_sign_flip_pvalue([1.0] * 10) * 1_000_000)),
        "holm_micros": {
            name: int(round(value * 1_000_000)) for name, value in raw_holm.items()
        },
        "bootstrap": hierarchical_paired_bootstrap(
            {seed: [0.1, 0.2, 0.3] for seed in range(10)}, repetitions=200
        ),
    }
    report = {
        "schema": "v23-smoke-1",
        "scientific_result": False,
        "domains": reports,
        "intervention_count": len(INTERVENTIONS),
        "ood": {"manifest": seal_manifest, "opened_records": len(opened)},
        "statistics": statistics,
        "ok": all(item["all_closed"] for item in reports.values())
        and len(opened) == 4,
    }
    write_new_json(output / "smoke_report.json", report)
    return report


def command_conformance(output_directory: str) -> dict[str, object]:
    output = Path(output_directory)
    output.mkdir(parents=True, exist_ok=False)
    agent = ExactActiveAgent()
    reports: dict[str, object] = {}
    for domain_index, domain in enumerate(
        (FiniteReferenceDomain(), SymbolicDomain(), PerceptualDomain())
    ):
        traces = []
        for actual_index in range(32):
            seed = 230_000 + domain_index * 100 + actual_index
            episode = domain.generate_episode(seed, actual_index)
            traces.append(agent.run(domain, episode, seed))
        name = domain.kind.value
        path = output / f"{name}_conformance_traces.jsonl"
        digest = write_trace_jsonl(path, traces)
        audit = audit_trace_jsonl(path)
        reports[name] = {
            "traces": len(traces),
            "all_closed": all(trace.closed for trace in traces),
            "trace_sha256": digest,
            "audit": audit,
        }
    report = {
        "schema": "v23-finite-conformance-1",
        "reports": reports,
        "ok": all(value["all_closed"] and value["audit"]["ok"] for value in reports.values()),
    }
    write_new_json(output / "conformance_report.json", report)
    return report


def command_matrix(kind: str, output_path: str | None) -> dict[str, object]:
    if kind == "tune":
        cells = tuning_matrix()
    elif kind == "final":
        cells = final_training_matrix()
    elif kind == "evaluate":
        cells = evaluation_matrix()
    elif kind == "replicate-eval":
        cells = evaluation_matrix(replication=True)
    else:
        raise ValueError("unknown matrix kind")
    report = {
        "schema": "v23-campaign-matrix-1",
        "kind": kind,
        "estimates": estimate_matrix(cells),
        "dag": campaign_dag(),
        "cells": [dataclasses.asdict(cell) | {"run_id": cell.run_id} for cell in cells],
        "matrix_sha256": content_sha256([dataclasses.asdict(cell) for cell in cells]),
    }
    if output_path is not None:
        write_new_json(output_path, report)
    return report


def command_train(config_path: str) -> dict[str, object]:
    config_payload = json.loads(Path(config_path).read_text(encoding="utf-8"))
    config = TrainConfig(**config_payload)
    domain = _domain(config.domain)
    return train_one_run(config, domain)


def command_evaluate(config_path: str) -> dict[str, object]:
    config_payload = json.loads(Path(config_path).read_text(encoding="utf-8"))
    config = EvaluationConfig(**config_payload)
    domain = _domain(config.domain)
    return evaluate_checkpoint(config, domain)


def command_falsify(output_directory: str) -> dict[str, object]:
    output = Path(output_directory)
    output.mkdir(parents=True, exist_ok=False)
    agent = ExactActiveAgent()
    domains = (FiniteReferenceDomain(), SymbolicDomain(), PerceptualDomain())
    results: dict[str, object] = {}
    for index, domain in enumerate(domains):
        episode = domain.generate_episode(240_000 + index, actual_index=7)
        trace = agent.run(domain, episode, 240_000 + index)
        results[domain.kind.value] = run_mutation_suite(trace, episode, domain)
    report = {
        "schema": "v23-cross-domain-falsification-1",
        "domains": results,
        "all_rejected": all(result["all_rejected"] for result in results.values()),
    }
    write_new_json(output / "falsification_report.json", report)
    return report


def command_intervention_registry(output_directory: str) -> dict[str, object]:
    output = Path(output_directory)
    output.mkdir(parents=True, exist_ok=False)
    report = {
        "schema": "v23-intervention-registry-1",
        "count": len(INTERVENTIONS),
        "interventions": {
            key: dataclasses.asdict(value) | {
                "fixed_variables": value.fixed_variables,
                "recomputed_variables": value.recomputed_variables,
            }
            for key, value in INTERVENTIONS.items()
        },
        "causal_effects_run": False,
        "status": "NOT_RUN",
    }
    write_new_json(output / "intervention_registry.json", report)
    return report


def _read_aes256_key(path: str) -> bytes:
    raw = Path(path).read_bytes().strip()
    if len(raw) == 64:
        try:
            raw = bytes.fromhex(raw.decode("ascii"))
        except (ValueError, UnicodeDecodeError) as error:
            raise ValueError("64-byte campaign key files must be valid hexadecimal") from error
    if len(raw) != 32:
        raise ValueError("campaign key file must contain 32 raw bytes or 64 hexadecimal characters")
    return raw


def command_seal_ood(
    output_directory: str,
    campaign_key_file: str,
    episodes_per_family: int,
) -> dict[str, object]:
    if episodes_per_family <= 0:
        raise ValueError("episodes_per_family must be positive")
    output = Path(output_directory)
    output.mkdir(parents=True, exist_ok=False)
    key = _read_aes256_key(campaign_key_file)
    domains = (SymbolicDomain(), PerceptualDomain())
    disjointness = audit_structural_disjointness(domains)
    if not disjointness["ok"]:
        raise RuntimeError("OOD structural fingerprints are not disjoint")
    manifests: dict[str, object] = {}
    for domain_index, domain in enumerate(domains):
        for family_index, family in enumerate(OOD_FAMILIES):
            label = f"{domain.kind.value}__{family}"

            def records() -> object:
                for index in range(episodes_per_family):
                    seed = 234_000 + domain_index * 100_000_000 + family_index * 10_000_000 + index
                    iid = domain.generate_episode(seed, actual_index=index % 32)
                    yield dataclasses.asdict(make_ood_episode(domain, iid, family))

            manifests[label] = seal_records(
                records(),
                output / label,
                key,
                {
                    "domain": domain.kind.value,
                    "family": family,
                    "seed_root": 234_000,
                    "episodes": episodes_per_family,
                },
                record_count=episodes_per_family,
            )
    report = {
        "schema": "v23-sealed-ood-master-1",
        "episodes_per_family": episodes_per_family,
        "family_count": len(manifests),
        "structural_disjointness": disjointness,
        "manifests": manifests,
        "status": "sealed",
    }
    write_new_json(output / "sealed_ood_master_manifest.json", report)
    return report


def command_run_interventions(config_path: str) -> dict[str, object]:
    payload = json.loads(Path(config_path).read_text(encoding="utf-8"))
    payload["seeds"] = tuple(payload["seeds"])
    config = InterventionRunConfig(**payload)
    return run_paired_interventions(config, _domain(config.domain))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="v23-campaign")
    subparsers = parser.add_subparsers(dest="command", required=True)
    preflight = subparsers.add_parser("preflight")
    preflight.add_argument("--scientific", action="store_true")
    smoke = subparsers.add_parser("smoke")
    smoke.add_argument("--out-dir", required=True)
    conformance = subparsers.add_parser("finite-conformance")
    conformance.add_argument("--out-dir", required=True)
    certifiable = subparsers.add_parser("certifiable-agent")
    certifiable.add_argument("--out-dir", required=True)
    matrix = subparsers.add_parser("matrix")
    matrix.add_argument("--kind", choices=("tune", "final", "evaluate", "replicate-eval"), required=True)
    matrix.add_argument("--out")
    train = subparsers.add_parser("train-one")
    train.add_argument("--config", required=True)
    evaluate = subparsers.add_parser("evaluate-one")
    evaluate.add_argument("--config", required=True)
    falsify = subparsers.add_parser("falsify")
    falsify.add_argument("--out-dir", required=True)
    interventions = subparsers.add_parser("interventions")
    interventions.add_argument("--out-dir", required=True)
    run_interventions = subparsers.add_parser("run-interventions")
    run_interventions.add_argument("--config", required=True)
    seal = subparsers.add_parser("sealed-ood")
    seal.add_argument("--out-dir", required=True)
    seal.add_argument("--campaign-key-file", required=True)
    seal.add_argument("--episodes-per-family", type=int, default=8192)
    data = subparsers.add_parser("build-data-manifest")
    data.add_argument("--out", required=True)
    data.add_argument("--without-commitments", action="store_true")
    audit = subparsers.add_parser("audit")
    audit.add_argument("--run-root", required=True)
    audit.add_argument("--require-all-gates", action="store_true")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if args.command == "preflight":
        report = run_preflight(PROJECT_ROOT, args.scientific)
        _json_print(report)
        return 0 if report["ok"] else 2
    if args.command == "smoke":
        report = command_smoke(args.out_dir)
        _json_print(report)
        return 0 if report["ok"] else 2
    if args.command == "finite-conformance":
        report = command_conformance(args.out_dir)
        _json_print(report)
        return 0 if report["ok"] else 2
    if args.command == "certifiable-agent":
        report = certify_catalog(args.out_dir)
        verification = verify_catalog(args.out_dir)
        _json_print(
            {
                "certificate_ok": report["ok"],
                "verification": verification,
                "cases": report["cases"],
            }
        )
        return 0 if report["ok"] and verification["ok"] else 2
    if args.command == "matrix":
        report = command_matrix(args.kind, args.out)
        _json_print({key: value for key, value in report.items() if key != "cells"})
        return 0
    if args.command == "train-one":
        report = command_train(args.config)
        _json_print({key: value for key, value in report.items() if key != "metrics"})
        return 0
    if args.command == "evaluate-one":
        report = command_evaluate(args.config)
        _json_print({key: value for key, value in report.items() if key != "outcomes"})
        return 0
    if args.command == "falsify":
        report = command_falsify(args.out_dir)
        _json_print(report)
        return 0 if report["all_rejected"] else 2
    if args.command == "interventions":
        report = command_intervention_registry(args.out_dir)
        _json_print(report)
        return 0
    if args.command == "run-interventions":
        report = command_run_interventions(args.config)
        _json_print(report)
        return 0 if report["complete"] else 2
    if args.command == "sealed-ood":
        report = command_seal_ood(
            args.out_dir, args.campaign_key_file, args.episodes_per_family
        )
        _json_print({key: value for key, value in report.items() if key != "manifests"})
        return 0
    if args.command == "build-data-manifest":
        report = build_public_data_manifest(
            args.out, materialize_commitments=not args.without_commitments
        )
        _json_print(
            {
                "schema": report["schema"],
                "structural_disjointness": report["structural_disjointness"],
                "contains_ood": report["contains_ood"],
            }
        )
        return 0
    if args.command == "audit":
        report = audit_all_gates(args.run_root)
        _json_print(report)
        return 2 if args.require_all_gates and not report["all_pass"] else 0
    raise AssertionError("unreachable command")


if __name__ == "__main__":
    sys.exit(main())
