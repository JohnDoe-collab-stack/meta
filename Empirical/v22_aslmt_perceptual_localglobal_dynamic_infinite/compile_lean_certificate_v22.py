from __future__ import annotations

import argparse
import hashlib
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

from audit_v22_scientific_contract import audit as audit_source_contract
from verify_bridge_aslmt_v22 import verify as verify_bridge_rows


CERT_KIND = "v22_to_lean_certificate"
SPLITS = ("iid", "ood")
REJECTED_OVERCLAIMS = (
    "empirical success is not exported as an unbounded theorem",
    "finite prefixes are not treated as global state enumeration",
    "z<n negative controls are not accepted as refined observables",
    "automatic interface selection is certified as supervised binary policy selection, not free interface discovery",
    "the generated Lean file uses explicit certificate axioms in mode A",
)


@dataclass(frozen=True)
class CompilerError:
    kind: str
    detail: str
    payload: dict[str, Any]


def _read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _read_jsonl(path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def _write_json(path: Path, obj: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def _write_jsonl(path: Path, rows: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        for row in rows:
            f.write(json.dumps(row, sort_keys=True) + "\n")


def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def _fail(errors: list[CompilerError], kind: str, detail: str, payload: dict[str, Any] | None = None) -> None:
    errors.append(CompilerError(kind=kind, detail=detail, payload={} if payload is None else payload))


def _find_one(run_dir: Path, pattern: str, errors: list[CompilerError]) -> Path | None:
    matches = sorted(run_dir.glob(pattern))
    if len(matches) != 1:
        _fail(errors, "file_discovery", f"expected exactly one match for {pattern}", {"matches": [str(p) for p in matches]})
        return None
    return matches[0]


def _infer_run_shape(summary: list[dict[str, Any]], errors: list[CompilerError]) -> tuple[int, int, int]:
    n_values = {int(row.get("n_classes", -1)) for row in summary}
    seed_values = {int(row.get("seed", -1)) for row in summary}
    if len(n_values) != 1 or len(seed_values) != 1:
        _fail(errors, "summary_shape", "summary must contain one n_classes and one seed", {
            "n_classes": sorted(n_values),
            "seeds": sorted(seed_values),
        })
        return 0, 0, 0
    n_classes = next(iter(n_values))
    seed = next(iter(seed_values))
    final_z = n_classes
    if n_classes <= 0:
        _fail(errors, "summary_shape", "n_classes must be positive", {"n_classes": n_classes})
    expected = {(z, split) for z in range(1, n_classes + 1) for split in SPLITS}
    observed = {(int(row.get("z_classes", -1)), str(row.get("split"))) for row in summary}
    missing = sorted(expected - observed)
    extra = sorted(observed - expected)
    if missing or extra:
        _fail(errors, "summary_shape", "summary does not cover exactly z=1..n for iid/ood", {
            "missing": missing,
            "extra": extra,
        })
    return n_classes, final_z, seed


def _summary_row(summary: list[dict[str, Any]], z: int, split: str) -> dict[str, Any] | None:
    for row in summary:
        if int(row.get("z_classes", -1)) == z and str(row.get("split")) == split:
            return row
    return None


def _check_summary_gates(summary: list[dict[str, Any]], n_classes: int, errors: list[CompilerError]) -> list[dict[str, Any]]:
    negative_controls: list[dict[str, Any]] = []
    for split in SPLITS:
        final = _summary_row(summary, n_classes, split)
        if final is None:
            _fail(errors, "final_gate", f"missing final summary row for {split}", {})
            continue
        if int(final.get("rc_verify_struct", -1)) != 0:
            _fail(errors, "final_gate", f"final structural verifier failed for {split}", final)
        if int(final.get("rc_verify_marginal", -1)) != 0:
            _fail(errors, "final_gate", f"final marginal verifier failed for {split}", final)
        if int(final.get("rc_verify_minproof", -1)) != 0:
            _fail(errors, "final_gate", f"final minproof verifier failed for {split}", final)

    for z in range(1, n_classes):
        for split in SPLITS:
            row = _summary_row(summary, z, split)
            if row is None:
                _fail(errors, "negative_control", f"missing z<{n_classes} control for {split} z={z}", {})
                continue
            struct_failed = int(row.get("rc_verify_struct", 0)) != 0
            marginal_ok = int(row.get("rc_verify_marginal", -1)) == 0
            minproof_ok = int(row.get("rc_verify_minproof", -1)) == 0
            if not struct_failed:
                _fail(errors, "negative_control", f"z<{n_classes} structural verifier unexpectedly passed", row)
            if not marginal_ok or not minproof_ok:
                _fail(errors, "negative_control", "z<n controls must keep marginal/minproof checks verified", row)
            negative_controls.append({
                "z_classes": z,
                "split": split,
                "struct_ok": not struct_failed,
                "struct_rejected": struct_failed,
                "marginal_nogo_ok": marginal_ok,
                "minproof_ok": minproof_ok,
            })
    return negative_controls


def _check_verify_json(path: Path, errors: list[CompilerError], *, expected_ok: bool = True) -> dict[str, Any]:
    obj = _read_json(path)
    if bool(obj.get("ok")) is not expected_ok:
        _fail(errors, "verify_json", f"{path.name} ok field mismatch", {
            "expected_ok": expected_ok,
            "actual_ok": obj.get("ok"),
            "path": str(path),
        })
    if expected_ok and int(obj.get("violations", obj.get("violation_count", 0))) != 0:
        _fail(errors, "verify_json", f"{path.name} reports violations", obj)
    return obj


def _mandatory_files(run_dir: Path, tag: str, n_classes: int, seed: int, errors: list[CompilerError]) -> dict[str, Path]:
    final_suffix = f"{tag}_n{n_classes}_z{n_classes}_seed{seed}"
    files: dict[str, Path] = {}
    names = {
        "summary": "summary.json",
        "bridge_cert": f"cert_bridge_v22_{final_suffix}.jsonl",
        "bridge_verify": f"verify_bridge_v22_{final_suffix}.json",
        "bridge_falsification": f"falsification_bridge_v22_{final_suffix}.json",
        "final_master": f"v22_perceptual_master_{final_suffix}.jsonl",
    }
    for split in SPLITS:
        names[f"verify_struct_{split}_final"] = f"verify_{split}_{final_suffix}.json"
        names[f"verify_marginal_{split}_final"] = f"verify_marginal_{split}_{final_suffix}.json"
        names[f"verify_minproof_{split}_final"] = f"verify_minproof_{split}_{final_suffix}.json"
    for z in range(1, n_classes):
        suffix = f"{tag}_n{n_classes}_z{z}_seed{seed}"
        for split in SPLITS:
            names[f"verify_struct_{split}_z{z}"] = f"verify_{split}_{suffix}.json"
            names[f"verify_minproof_{split}_z{z}"] = f"verify_minproof_{split}_{suffix}.json"
            names[f"cert_minproof_{split}_z{z}"] = f"cert_minproof_{split}_{suffix}.jsonl"

    for key, name in names.items():
        path = run_dir / name
        if not path.exists():
            _fail(errors, "mandatory_file", f"missing mandatory file {name}", {"key": key})
        else:
            files[key] = path
    return files


def _extract_tag_from_master(master: Path, n_classes: int, seed: int) -> str:
    prefix = "v22_perceptual_master_"
    suffix = f"_n{n_classes}_z{n_classes}_seed{seed}.jsonl"
    name = master.name
    if not name.startswith(prefix) or not name.endswith(suffix):
        raise ValueError(f"cannot infer tag from {name}")
    return name[len(prefix) : -len(suffix)]


def _extract_bridge_schema(bridge_rows: list[dict[str, Any]], n_classes: int) -> dict[str, Any]:
    contract = next((r for r in bridge_rows if r.get("kind") == "infinite_schema_contract"), {})
    cover = next((r for r in bridge_rows if r.get("kind") == "local_global_infinite_cover_schema"), {})
    dynamic = next((r for r in bridge_rows if r.get("kind") == "dynamic_infinite_zero_elimination_schema"), {})
    prefixes = [r for r in bridge_rows if r.get("kind") == "filtered_prefix_level"]
    basis = [r for r in bridge_rows if r.get("kind") == "pointwise_finite_separation_basis_schema"]
    levels = [int(r.get("ctx_prefix", 0)) for r in prefixes]
    return {
        "ctx_domain": contract.get("ctx_domain"),
        "time_domain": contract.get("time_domain"),
        "global_state_enumeration": contract.get("global_state_enumeration"),
        "finite_exhaustive_global_reduction": contract.get("finite_exhaustive_global_reduction"),
        "local_global_alignment": contract.get("local_global_alignment"),
        "lean_targets": {
            "local_global": cover.get("lean_target"),
            "dynamic_profile": dynamic.get("dynamic_profile_target"),
            "coordinate": dynamic.get("coordinate_target"),
            "stable_section": dynamic.get("stable_section_target"),
        },
        "levels": levels,
        "basis": [
            {
                "distinction_kind": row.get("distinction_kind"),
                "witness_interface": row.get("witness_interface"),
                "finite_window_size": row.get("finite_window_size"),
                "finite_class_cases_per_ctx_time": row.get("finite_class_cases_per_ctx_time"),
            }
            for row in basis
        ],
        "case_count_per_ctx_time": 4 * n_classes * n_classes,
    }


def _extract_final_metrics(master_rows: list[dict[str, Any]], errors: list[CompilerError]) -> dict[str, Any]:
    if len(master_rows) != 1:
        _fail(errors, "master_jsonl", "final master jsonl must contain exactly one row", {"rows": len(master_rows)})
        return {}
    row = master_rows[0]
    return {
        "metrics": row.get("metrics", {}),
        "pair_eval": row.get("pair_eval", {}),
        "weights": {
            key: row.get(key)
            for key in ("w_z", "w_k", "w_q", "w_pos", "w_rank_img", "w_rank_cue", "w_bce", "w_dice")
            if key in row
        },
    }


def _extract_interface_policy(final_metrics: dict[str, Any], errors: list[CompilerError]) -> dict[str, Any]:
    metrics = final_metrics.get("metrics", {})
    q_acc_by_split: dict[str, float] = {}
    z_acc_by_split: dict[str, float] = {}
    res_acc_by_split: dict[str, float] = {}
    query_action_rate_by_split: dict[str, float] = {}
    for split in SPLITS:
        split_metrics = metrics.get(split, {})
        q_acc = float(split_metrics.get("q_acc", -1.0))
        z_acc = float(split_metrics.get("z_acc", -1.0))
        res_acc = float(split_metrics.get("res_acc", -1.0))
        query_action_rate = float(split_metrics.get("query_action_rate", -1.0))
        q_acc_by_split[split] = q_acc
        z_acc_by_split[split] = z_acc
        res_acc_by_split[split] = res_acc
        query_action_rate_by_split[split] = query_action_rate
        if q_acc < 1.0:
            _fail(errors, "interface_policy", f"{split}: query/action policy is not exact", split_metrics)
        if z_acc < 1.0:
            _fail(errors, "interface_policy", f"{split}: z mediator is not exact", split_metrics)
        if res_acc < 1.0:
            _fail(errors, "interface_policy", f"{split}: selected action does not recover the dynamic response", split_metrics)
        if not (0.0 < query_action_rate < 1.0):
            _fail(errors, "interface_policy", f"{split}: selected action collapsed to a constant branch", split_metrics)

    return {
        "kind": "automatic_next_interface_selection",
        "status": "certified_supervised_binary_policy",
        "causal_chain": ["cue", "z", "query_action", "res_bit", "decoder"],
        "policy_source": "query_logits := query_from_z(one_hot(argmax(z_logits.detach())))",
        "policy_supervision": "_policy_action_from_h(h)",
        "environment_response": "res_bit := _env_res_bit(h, k, action)",
        "action_space": ["0", "1"],
        "semantic_reading": "the learned refined observable carries the action selecting the next dynamic query branch",
        "formal_contract": [
            "the selected interface reveals the dynamic diagonal hidden by the poor observable",
            "the selected interface and response bit determine a certified continuation step",
        ],
        "not_free_interface_search": True,
        "q_acc_by_split": q_acc_by_split,
        "z_acc_by_split": z_acc_by_split,
        "res_acc_by_split": res_acc_by_split,
        "query_action_rate_by_split": query_action_rate_by_split,
    }


def _lean_file_text(normalized: dict[str, Any]) -> str:
    n_classes = normalized["n_classes"]
    seed = normalized["seed"]
    tag = normalized["run_tag"]
    return f"""/- Generated from v22 certificate.
   Source run: {tag}
   n_classes={n_classes}, final_z_classes={n_classes}, seed={seed}

   Mode A certificate: empirical artifacts are exported as explicit audited
   hypotheses, then discharged through already-proved Lean bridge theorems.
   Do not edit by hand. -/

import COFRS.Examples.MythosProblem
import COFRS.MultiInterfaceModular.LocalGlobal
import COFRS.MultiInterfaceModular.DynamicResidualProfile

namespace PrimitiveHolonomy
namespace Empirical
namespace V22LeanCertificate

open PrimitiveHolonomy.Examples.GeometryDynamicsIndependence.MythosProblem
open PrimitiveHolonomy.MultiInterfaceModular

/-! ## Certificate metadata -/

def nClasses : Nat := {n_classes}
def finalZClasses : Nat := {n_classes}
def seed : Nat := {seed}

theorem finalZ_eq_nClasses : finalZClasses = nClasses := rfl

/-! ## Mythos refined-observable bridge -/

axiom V22State : Type
axiom V22PoorVisible : Type
axiom V22RefinedVisible : Type
axiom V22Interface : Type

axiom phiPoor : V22State -> V22PoorVisible
axiom dynamicPredicate : V22State -> Prop
axiom rhoRefined : V22State -> V22RefinedVisible
axiom forgetRefined : V22RefinedVisible -> V22PoorVisible

axiom certificate_commutes :
  forall s : V22State, forgetRefined (rhoRefined s) = phiPoor s

axiom certificate_separates_visible_diagonal :
  forall {{s t : V22State}},
    phiPoor s = phiPoor t ->
      dynamicPredicate s ->
        Not (dynamicPredicate t) ->
          Not (rhoRefined s = rhoRefined t)

axiom certificate_separates_all_dynamic_diagonals :
  SeparatesAllDynamicDiagonals rhoRefined dynamicPredicate

theorem v22_refined_observable_preserves_phi :
    forall s : V22State, forgetRefined (rhoRefined s) = phiPoor s :=
  certificate_commutes

theorem v22_refined_dynamic_factorization :
    MythosPropFactorsThrough rhoRefined dynamicPredicate := by
  let href : TrueRefinedObservable phiPoor dynamicPredicate := {{
    R := V22RefinedVisible
    refined := rhoRefined
    forget := forgetRefined
    commutes := certificate_commutes
    separatesDiagonal := by
      intro s t hPhi hDs hnDt
      exact certificate_separates_visible_diagonal hPhi hDs hnDt
  }}
  exact
    true_refined_observable_global_factorization
      href
      certificate_separates_all_dynamic_diagonals

/-! ## Automatic next-interface selection bridge -/

axiom V22Action : Type
axiom V22ResponseBit : Type

structure InterfacePolicyCertificate where
  actionFromRefined : V22RefinedVisible -> V22Action
  interfaceFromAction : V22Action -> V22Interface
  certifiedAction : V22State -> V22Action
  responseFromAction : V22State -> V22Action -> V22ResponseBit
  certifiedResponse : V22State -> V22ResponseBit
  revealsDynamicDistinction : V22Interface -> V22State -> V22State -> Prop
  continuationStep :
    V22State -> V22Interface -> V22ResponseBit -> V22State -> Prop
  certifiedNextState : V22State -> V22State
  action_selected :
    forall s : V22State,
      actionFromRefined (rhoRefined s) = certifiedAction s
  selected_interface :
    forall s : V22State,
      interfaceFromAction (actionFromRefined (rhoRefined s)) =
        interfaceFromAction (certifiedAction s)
  response_selected :
    forall s : V22State,
      responseFromAction s (actionFromRefined (rhoRefined s)) =
        certifiedResponse s
  selected_interface_reveals_diagonal :
    forall {{s t : V22State}},
      phiPoor s = phiPoor t ->
        dynamicPredicate s ->
          Not (dynamicPredicate t) ->
            revealsDynamicDistinction
              (interfaceFromAction (actionFromRefined (rhoRefined s)))
              s
              t
  selected_response_continues :
    forall s : V22State,
      continuationStep
        s
        (interfaceFromAction (actionFromRefined (rhoRefined s)))
        (responseFromAction s (actionFromRefined (rhoRefined s)))
        (certifiedNextState s)

axiom certificate_interface_policy :
  InterfacePolicyCertificate

theorem v22_refined_selects_next_interface :
    forall s : V22State,
      certificate_interface_policy.interfaceFromAction
        (certificate_interface_policy.actionFromRefined (rhoRefined s)) =
          certificate_interface_policy.interfaceFromAction
            (certificate_interface_policy.certifiedAction s) :=
  certificate_interface_policy.selected_interface

theorem v22_refined_action_produces_certified_response :
    forall s : V22State,
      certificate_interface_policy.responseFromAction s
        (certificate_interface_policy.actionFromRefined (rhoRefined s)) =
          certificate_interface_policy.certifiedResponse s :=
  certificate_interface_policy.response_selected

theorem v22_selected_interface_reveals_dynamic_diagonal :
    forall {{s t : V22State}},
      phiPoor s = phiPoor t ->
        dynamicPredicate s ->
          Not (dynamicPredicate t) ->
            certificate_interface_policy.revealsDynamicDistinction
              (certificate_interface_policy.interfaceFromAction
                (certificate_interface_policy.actionFromRefined (rhoRefined s)))
              s
              t :=
  certificate_interface_policy.selected_interface_reveals_diagonal

theorem v22_selected_interface_response_continues :
    forall s : V22State,
      certificate_interface_policy.continuationStep
        s
        (certificate_interface_policy.interfaceFromAction
          (certificate_interface_policy.actionFromRefined (rhoRefined s)))
        (certificate_interface_policy.responseFromAction s
          (certificate_interface_policy.actionFromRefined (rhoRefined s)))
        (certificate_interface_policy.certifiedNextState s) :=
  certificate_interface_policy.selected_response_continues

/-! ## Local-finite closure bridge -/

axiom V22Target : Type

axiom decEqRefinedVisible : DecidableEq V22RefinedVisible
axiom decEqTarget : DecidableEq V22Target
attribute [instance] decEqRefinedVisible decEqTarget

axiom v22Obs : V22Interface -> V22State -> V22RefinedVisible
axiom v22Sigma : V22State -> V22Target
axiom v22Subfamily : Subfamily V22Interface

axiom certificate_local_finite_closure_cover :
  LocalFiniteClosureCover v22Obs v22Sigma v22Subfamily

theorem v22_closed_of_local_finite_cover :
    Closed v22Obs v22Sigma v22Subfamily :=
  closed_of_localFiniteClosureCover
    v22Obs
    v22Sigma
    v22Subfamily
    certificate_local_finite_closure_cover

/-! ## Dynamic residual bridge -/

axiom V22Horizon : Type
axiom V22DynamicTime : Type
axiom V22Window : Type

axiom v22DynamicProfile :
  DynamicResidualProfile V22State V22Horizon V22DynamicTime V22Window

axiom v22DynamicCoordinate :
  DynamicResidualCoordinate v22DynamicProfile

theorem v22_no_residualAt_of_zero
    {{r : V22Horizon}} {{W : V22Window}} {{x : V22State}} :
    v22DynamicCoordinate.rhoAt r W = 0 ->
      v22DynamicProfile.InWindow W x ->
        Not (v22DynamicProfile.ResidualAt r W x) :=
  no_residualAt_of_rhoAt_eq_zero v22DynamicCoordinate

axiom v22ClosureBridge :
  DynamicResidualClosureBridge v22DynamicProfile

axiom certificate_no_stable_residual_section :
  NoStableResidualSection v22DynamicProfile

theorem v22_global_closure :
    v22ClosureBridge.GlobalClosure :=
  globalClosure_of_noStableResidualSection
    v22ClosureBridge
    certificate_no_stable_residual_section

/-!
## Trust boundary

The `certificate_*` declarations above are the only generated trusted facts.
They correspond to the normalized v22 artifact:

* final z=n structural, marginal and minproof gates pass on IID/OOD;
* every z<n structural gate is rejected while minproof collisions verify;
* the bridge verifier accepts the local-finite schema;
* falsification rejects all registered bridge mutations;
* no global empirical infinity is claimed.
-/

end V22LeanCertificate
end Empirical
end PrimitiveHolonomy
"""


def compile_certificate(run_dir: Path, source_dir: Path, out_dir: Path) -> tuple[dict[str, Any], dict[str, Any], str]:
    errors: list[CompilerError] = []
    warnings: list[str] = []
    run_dir = run_dir.resolve()
    source_dir = source_dir.resolve()
    out_dir = out_dir.resolve()

    summary_path = run_dir / "summary.json"
    if not summary_path.exists():
        _fail(errors, "mandatory_file", "missing summary.json", {})
        summary: list[dict[str, Any]] = []
    else:
        summary = _read_json(summary_path)
        if not isinstance(summary, list):
            _fail(errors, "summary_shape", "summary.json must be a JSON list", {"type": type(summary).__name__})
            summary = []

    n_classes, final_z, seed = _infer_run_shape(summary, errors)
    final_master_guess = _find_one(run_dir, f"v22_perceptual_master_*_n{n_classes}_z{final_z}_seed{seed}.jsonl", errors)
    tag = _extract_tag_from_master(final_master_guess, n_classes, seed) if final_master_guess else "UNKNOWN"
    files = _mandatory_files(run_dir, tag, n_classes, seed, errors) if tag != "UNKNOWN" else {}

    negative_controls = _check_summary_gates(summary, n_classes, errors) if n_classes > 0 else []

    checked_files: list[str] = []
    checked_hashes: dict[str, str] = {}
    for key, path in sorted(files.items()):
        checked_files.append(str(path))
        checked_hashes[key] = _sha256(path)

    final_reports: dict[str, Any] = {}
    for split in SPLITS:
        for key_base in ("verify_struct", "verify_marginal", "verify_minproof"):
            key = f"{key_base}_{split}_final"
            if key in files:
                final_reports[key] = _check_verify_json(files[key], errors)

    for z in range(1, n_classes):
        for split in SPLITS:
            key = f"verify_minproof_{split}_z{z}"
            if key in files:
                _check_verify_json(files[key], errors)
            key_struct = f"verify_struct_{split}_z{z}"
            if key_struct in files:
                struct_obj = _read_json(files[key_struct])
                if bool(struct_obj.get("ok")):
                    _fail(errors, "negative_control", f"{files[key_struct].name} unexpectedly passed", struct_obj)

    bridge_rows = _read_jsonl(files["bridge_cert"]) if "bridge_cert" in files else []
    bridge_report, bridge_violations = verify_bridge_rows(bridge_rows)
    if not bridge_report.get("ok"):
        _fail(errors, "bridge_verify", "bridge certificate does not verify", {
            "report": bridge_report,
            "violations": [asdict(vio) for vio in bridge_violations],
        })
    if "bridge_verify" in files:
        disk_bridge_report = _read_json(files["bridge_verify"])
        if not disk_bridge_report.get("ok") or int(disk_bridge_report.get("violation_count", -1)) != 0:
            _fail(errors, "bridge_verify", "stored bridge verification report is not clean", disk_bridge_report)

    falsification = _read_json(files["bridge_falsification"]) if "bridge_falsification" in files else {}
    if not falsification.get("ok"):
        _fail(errors, "bridge_falsification", "falsification report is not ok", falsification)
    for mutation, result in falsification.get("mutations", {}).items():
        if not result.get("rejected"):
            _fail(errors, "bridge_falsification", f"mutation was not rejected: {mutation}", result)

    source_audit = audit_source_contract(source_dir)
    if not source_audit.get("ok"):
        _fail(errors, "source_contract", "v22 source contract audit failed", source_audit)

    master_rows = _read_jsonl(files["final_master"]) if "final_master" in files else []
    final_metrics = _extract_final_metrics(master_rows, errors)
    interface_policy = _extract_interface_policy(final_metrics, errors)
    bridge_schema = _extract_bridge_schema(bridge_rows, n_classes) if bridge_rows else {}

    normalized = {
        "kind": CERT_KIND,
        "run_dir": str(run_dir),
        "run_tag": tag,
        "n_classes": n_classes,
        "seed": seed,
        "final_z_classes": final_z,
        "splits": list(SPLITS),
        "observables": {
            "poor": ["image", "cue"],
            "refined": ["image", "cue", "z", "res_bit"],
        },
        "dynamic_predicate": "hidden_target_compatibility",
        "interface_policy": interface_policy,
        "trust_mode": "mode_A_certificate_as_explicit_Lean_hypotheses",
        "final_gate": {
            "struct_ok": all(int((_summary_row(summary, n_classes, split) or {}).get("rc_verify_struct", -1)) == 0 for split in SPLITS),
            "marginal_nogo_ok": all(int((_summary_row(summary, n_classes, split) or {}).get("rc_verify_marginal", -1)) == 0 for split in SPLITS),
            "minproof_ok": all(int((_summary_row(summary, n_classes, split) or {}).get("rc_verify_minproof", -1)) == 0 for split in SPLITS),
            "bridge_ok": bool(bridge_report.get("ok")),
            "falsification_ok": bool(falsification.get("ok")) and all(v.get("rejected") for v in falsification.get("mutations", {}).values()),
        },
        "negative_controls": negative_controls,
        "final_metrics": final_metrics,
        "local_finite_schema": bridge_schema,
        "lean_targets": [
            "PrimitiveHolonomy.Examples.GeometryDynamicsIndependence.MythosProblem.true_refined_observable_global_factorization",
            "PrimitiveHolonomy.Empirical.V22LeanCertificate.v22_refined_selects_next_interface",
            "PrimitiveHolonomy.Empirical.V22LeanCertificate.v22_refined_action_produces_certified_response",
            "PrimitiveHolonomy.Empirical.V22LeanCertificate.v22_selected_interface_reveals_dynamic_diagonal",
            "PrimitiveHolonomy.Empirical.V22LeanCertificate.v22_selected_interface_response_continues",
            "PrimitiveHolonomy.MultiInterfaceModular.LocalFiniteClosureCover",
            "PrimitiveHolonomy.MultiInterfaceModular.closed_of_localFiniteClosureCover",
            "PrimitiveHolonomy.MultiInterfaceModular.DynamicResidualProfile",
            "PrimitiveHolonomy.MultiInterfaceModular.no_residualAt_of_rhoAt_eq_zero",
            "PrimitiveHolonomy.MultiInterfaceModular.globalClosure_of_noStableResidualSection",
        ],
        "accepted_claims": [
            "v22 final z=n passes checked IID/OOD finite perceptual gates",
            "z<n controls witness that lower refined dimensions are rejected",
            "the refined observable carries a supervised automatic next-interface/action policy",
            "the selected interface is certified as revealing the dynamic diagonal and supporting a continuation step",
            "the exported Lean bridge is relative to explicit certificate hypotheses",
            "the local-finite schema is aligned with Lean local-global and dynamic residual targets",
        ],
        "rejected_overclaims": list(REJECTED_OVERCLAIMS),
    }

    audit = {
        "ok": not errors,
        "errors": [asdict(err) for err in errors],
        "warnings": warnings,
        "checked_files": checked_files,
        "checked_hashes": checked_hashes,
        "source_contract": source_audit,
        "bridge_report_recomputed": bridge_report,
        "accepted_claims": normalized["accepted_claims"],
        "rejected_overclaims": normalized["rejected_overclaims"],
    }

    lean_text = _lean_file_text(normalized)

    out_dir.mkdir(parents=True, exist_ok=True)
    _write_json(out_dir / "certificate.normalized.json", normalized)
    _write_json(out_dir / "certificate.audit.json", audit)
    (out_dir / "certificate.lean").write_text(lean_text, encoding="utf-8")
    manifest = {
        "kind": "v22_lean_certificate_manifest",
        "ok": audit["ok"],
        "run_dir": str(run_dir),
        "outputs": {
            "normalized": str(out_dir / "certificate.normalized.json"),
            "audit": str(out_dir / "certificate.audit.json"),
            "lean": str(out_dir / "certificate.lean"),
        },
        "output_hashes": {
            "certificate.normalized.json": _sha256(out_dir / "certificate.normalized.json"),
            "certificate.audit.json": _sha256(out_dir / "certificate.audit.json"),
            "certificate.lean": _sha256(out_dir / "certificate.lean"),
        },
    }
    _write_json(out_dir / "certificate_manifest.json", manifest)
    _write_jsonl(out_dir / "counterexamples_z_lt_n.jsonl", negative_controls)
    traceability = {
        "summary": str(summary_path),
        "source_files": checked_files,
        "lean_certificate_axioms": [
            "certificate_commutes",
            "certificate_separates_visible_diagonal",
            "certificate_separates_all_dynamic_diagonals",
            "certificate_interface_policy",
            "certificate_local_finite_closure_cover",
            "certificate_no_stable_residual_section",
        ],
    }
    _write_json(out_dir / "traceability_map.json", traceability)
    return normalized, audit, lean_text


def main() -> int:
    parser = argparse.ArgumentParser(description="Compile a v22 empirical proofpack into an audited Lean certificate shell.")
    parser.add_argument("--run-dir", type=Path, required=True)
    parser.add_argument("--source-dir", type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument("--out-dir", type=Path, default=None)
    args = parser.parse_args()

    out_dir = args.out_dir
    if out_dir is None:
        out_dir = args.run_dir / "lean_certificate"

    normalized, audit, _lean_text = compile_certificate(args.run_dir, args.source_dir, out_dir)
    print(json.dumps({
        "ok": audit["ok"],
        "out_dir": str(out_dir.resolve()),
        "n_classes": normalized.get("n_classes"),
        "final_z_classes": normalized.get("final_z_classes"),
        "errors": audit["errors"],
    }, indent=2, sort_keys=True))
    return 0 if audit["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
