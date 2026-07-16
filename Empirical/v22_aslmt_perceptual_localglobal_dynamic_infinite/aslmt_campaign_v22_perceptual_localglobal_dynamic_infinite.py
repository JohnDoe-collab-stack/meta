from __future__ import annotations
import argparse
import hashlib
import json
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path


HERE = Path(__file__).resolve().parent
ASLMT_DIR = HERE.parent
RUNS_DIR = ASLMT_DIR / "runs"
SNAP_DIR = RUNS_DIR / "snapshots"


def _sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    h.update(p.read_bytes())
    return h.hexdigest()


def _bundle_hash(paths: list[Path]) -> str:
    h = hashlib.sha256()
    for p in paths:
        h.update(p.name.encode("utf-8"))
        h.update(_sha256_file(p).encode("utf-8"))
    return h.hexdigest()


def _parse_int_list(s: str) -> list[int]:
    out: list[int] = []
    for part in str(s).split(","):
        part = part.strip()
        if not part:
            continue
        out.append(int(part))
    if not out:
        raise ValueError("empty list")
    return out


def _now_ts() -> str:
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def _run_with_timestamped_log(*, cmd: list[str], out: Path, allow_fail: bool = False) -> int:
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, "w", encoding="utf-8") as f:
        f.write(f"{_now_ts()} CMD: {' '.join(cmd)}\n")
        f.flush()
        p = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )
        assert p.stdout is not None
        for line in p.stdout:
            f.write(f"{_now_ts()} {line.rstrip()}\n")
            f.flush()
        rc = p.wait()
        f.write(f"{_now_ts()} RC={int(rc)}\n")
        f.flush()
        if int(rc) != 0 and not bool(allow_fail):
            raise SystemExit(2)
        return int(rc)


def _write_summary(path: Path, summary: list[dict]) -> None:
    path.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def main() -> None:
    p = argparse.ArgumentParser(
        description="v22 perceptual local-global dynamic infinite: train â†’ certify â†’ verify (IID+OOD) + marginal no-go + strengthened minproof; trained baselines are checkpointed and verified."
    )
    p.add_argument("--profile", type=str, default="solid", choices=["smoke", "solid"])
    p.add_argument("--device", type=str, default="cpu")
    p.add_argument("--python", type=str, default=str(sys.executable))
    p.add_argument("--seed-from", type=int, default=0)
    p.add_argument("--seed-to", type=int, default=0)
    p.add_argument("--n-classes-list", type=str, required=True)
    p.add_argument("--z-classes-list", type=str, required=True)
    p.add_argument("--steps", type=int, default=9000)
    p.add_argument("--batch-size", type=int, default=64)
    p.add_argument("--lr", type=float, default=1e-3)
    p.add_argument("--train-ood-ratio", type=float, default=0.5)
    p.add_argument("--pair-n-ctx", type=int, default=64)
    p.add_argument("--episodes", type=int, default=64)
    p.add_argument("--seed-base", type=int, default=0)
    p.add_argument("--img-size", type=int, default=64)
    p.add_argument("--w-z", type=float, default=5.0)
    p.add_argument("--w-q", type=float, default=1.0)
    p.add_argument("--w-pos", type=float, default=0.25)
    p.add_argument("--w-rank-img", type=float, default=1.0)
    p.add_argument("--w-rank-cue", type=float, default=0.25)
    p.add_argument("--rank-n-ctx", type=int, default=64)
    p.add_argument("--rank-margin", type=float, default=2.0)
    p.add_argument("--rank-ood-ratio", type=float, default=0.5)
    p.add_argument("--w-bce", type=float, default=1.0)
    p.add_argument("--w-dice", type=float, default=1.0)
    p.add_argument("--bce-pos-weight", type=str, default="auto")
    args = p.parse_args()

    # Preserve venv interpreter path (do not resolve symlink).
    py_arg = str(args.python)
    if not ("/" in py_arg or "\\" in py_arg):
        found = shutil.which(py_arg)
        if found is None:
            raise SystemExit(f"--python not found on PATH: {py_arg!r}")
        py = Path(found)
    else:
        py = Path(py_arg).expanduser()
    if not py.exists():
        raise SystemExit(f"--python does not exist: {str(py)!r}")

    # Snapshot inputs.
    paths = [
        HERE / "README.md",
        HERE / "SCIENTIFIC_PROTOCOL.md",
        HERE / "aslmt_env_v22_perceptual_localglobal_dynamic_infinite.py",
        HERE / "aslmt_model_v22_perceptual_localglobal_dynamic_infinite.py",
        HERE / "render_aslmt_v22_perceptual_localglobal_dynamic_infinite.py",
        HERE / "audit_v22_scientific_contract.py",
        HERE / "verify_v22_scientific_contract.py",
        HERE / "aslmt_train_v22_perceptual_localglobal_dynamic_infinite.py",
        HERE / "certify_struct_aslmt_v22_perceptual.py",
        HERE / "verify_struct_aslmt_v22_perceptual.py",
        HERE / "certify_minproof_aslmt_v22_perceptual.py",
        HERE / "verify_minproof_aslmt_v22_perceptual.py",
        HERE / "certify_marginal_nogo_aslmt_v22_perceptual.py",
        HERE / "verify_marginal_nogo_aslmt_v22_perceptual.py",
        HERE / "certify_bridge_aslmt_v22.py",
        HERE / "verify_bridge_aslmt_v22.py",
        HERE / "falsify_v22_bridge_verifier.py",
        HERE / Path(__file__).name,
    ]
    bundle = _bundle_hash(paths)
    bundle_short = bundle[:12]
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")

    run_dir = RUNS_DIR / f"aslmt_v22_perceptual_localglobal_dynamic_infinite_{ts}_{bundle_short}"
    run_dir.mkdir(parents=True, exist_ok=False)
    snap_root = SNAP_DIR / f"aslmt_v22_perceptual_localglobal_dynamic_infinite_{ts}_{bundle_short}"
    snap_root.mkdir(parents=True, exist_ok=False)
    for pth in paths:
        shutil.copy2(pth, snap_root / pth.name)

    train = snap_root / "aslmt_train_v22_perceptual_localglobal_dynamic_infinite.py"
    certify = snap_root / "certify_struct_aslmt_v22_perceptual.py"
    verify = snap_root / "verify_struct_aslmt_v22_perceptual.py"
    certify_min = snap_root / "certify_minproof_aslmt_v22_perceptual.py"
    verify_min = snap_root / "verify_minproof_aslmt_v22_perceptual.py"
    certify_marg = snap_root / "certify_marginal_nogo_aslmt_v22_perceptual.py"
    verify_marg = snap_root / "verify_marginal_nogo_aslmt_v22_perceptual.py"
    certify_bridge = snap_root / "certify_bridge_aslmt_v22.py"
    verify_bridge = snap_root / "verify_bridge_aslmt_v22.py"
    falsify_bridge = snap_root / "falsify_v22_bridge_verifier.py"

    n_list = _parse_int_list(args.n_classes_list)
    z_list_in = _parse_int_list(args.z_classes_list)
    z_max = int(max(z_list_in))
    z_list = list(range(1, int(z_max) + 1))
    seeds = list(range(int(args.seed_from), int(args.seed_to) + 1))

    summary: list[dict] = []

    for n in n_list:
        for z in z_list:
            for seed in seeds:
                tag = f"{ts}_{bundle_short}_n{int(n)}_z{int(z)}_seed{int(seed)}"
                master_jsonl = run_dir / f"v22_perceptual_master_{tag}.jsonl"
                train_log = run_dir / f"train_{tag}.txt"
                ckpt = run_dir / f"ckpt_{tag}.pt"

                train_cmd = [
                    str(py),
                    "-u",
                    str(train),
                    "--profile",
                    str(args.profile),
                    "--seed",
                    str(int(seed)),
                    "--steps",
                    str(int(args.steps)),
                    "--batch-size",
                    str(int(args.batch_size)),
                    "--lr",
                    str(float(args.lr)),
                    "--train-ood-ratio",
                    str(float(args.train_ood_ratio)),
                    "--pair-n-ctx",
                    str(int(args.pair_n_ctx)),
                    "--img-size",
                    str(int(args.img_size)),
                    "--n-classes",
                    str(int(n)),
                    "--z-classes",
                    str(int(z)),
                    "--w-z",
                    str(float(args.w_z)),
                    "--w-k",
                    "0.0",
                    "--w-q",
                    str(float(args.w_q)),
                    "--w-pos",
                    str(float(args.w_pos)),
                    "--w-rank-img",
                    str(float(args.w_rank_img)),
                    "--w-rank-cue",
                    str(float(args.w_rank_cue)),
                    "--rank-n-ctx",
                    str(int(args.rank_n_ctx)),
                    "--rank-ood-ratio",
                    str(float(args.rank_ood_ratio)),
                    "--rank-margin",
                    str(float(args.rank_margin)),
                    "--w-bce",
                    str(float(args.w_bce)),
                    "--w-dice",
                    str(float(args.w_dice)),
                    "--bce-pos-weight",
                    str(args.bce_pos_weight),
                    "--device",
                    str(args.device),
                    "--out-jsonl",
                    str(master_jsonl),
                    "--out-ckpt",
                    str(ckpt),
                ]
                _run_with_timestamped_log(cmd=train_cmd, out=train_log, allow_fail=False)

                for split in ["iid", "ood"]:
                    cert_jsonl = run_dir / f"cert_{split}_{tag}.jsonl"
                    cert_log = run_dir / f"cert_{split}_{tag}.txt"
                    cert_cmd = [
                        str(py),
                        "-u",
                        str(certify),
                        "--out-jsonl",
                        str(cert_jsonl),
                        "--split",
                        split,
                        "--episodes",
                        str(int(args.episodes)),
                        "--seed-base",
                        str(int(args.seed_base)),
                        "--n-classes",
                        str(int(n)),
                        "--img-size",
                        str(int(args.img_size)),
                        "--z-classes",
                        str(int(z)),
                        "--pair-n-ctx",
                        str(int(args.pair_n_ctx)),
                        "--device",
                        str(args.device),
                        "--ckpt",
                        str(ckpt),
                    ]
                    _run_with_timestamped_log(cmd=cert_cmd, out=cert_log, allow_fail=False)

                    rep_json = run_dir / f"verify_{split}_{tag}.json"
                    rep_txt = run_dir / f"verify_{split}_{tag}.txt"
                    viol_jsonl = run_dir / f"violations_{split}_{tag}.jsonl"
                    verify_log = run_dir / f"verify_{split}_{tag}.log.txt"
                    verify_cmd = [
                        str(py),
                        "-u",
                        str(verify),
                        "--cert-jsonl",
                        str(cert_jsonl),
                        "--ckpt",
                        str(ckpt),
                        "--device",
                        str(args.device),
                        "--expect-lines",
                        str(int(args.episodes)),
                        "--out-report-json",
                        str(rep_json),
                        "--out-report-txt",
                        str(rep_txt),
                        "--out-violations-jsonl",
                        str(viol_jsonl),
                    ]
                    rc_verify = _run_with_timestamped_log(cmd=verify_cmd, out=verify_log, allow_fail=True)

                    cert_marg_jsonl = run_dir / f"cert_marginal_{split}_{tag}.jsonl"
                    cert_marg_log = run_dir / f"cert_marginal_{split}_{tag}.txt"
                    cert_marg_cmd = [
                        str(py),
                        "-u",
                        str(certify_marg),
                        "--out-jsonl",
                        str(cert_marg_jsonl),
                        "--split",
                        split,
                        "--episodes",
                        str(int(args.episodes)),
                        "--seed-base",
                        str(int(args.seed_base)),
                        "--n-classes",
                        str(int(n)),
                        "--img-size",
                        str(int(args.img_size)),
                        "--pair-n-ctx",
                        str(int(args.pair_n_ctx)),
                    ]
                    _run_with_timestamped_log(cmd=cert_marg_cmd, out=cert_marg_log, allow_fail=False)

                    rep_marg_json = run_dir / f"verify_marginal_{split}_{tag}.json"
                    rep_marg_txt = run_dir / f"verify_marginal_{split}_{tag}.txt"
                    viol_marg_jsonl = run_dir / f"violations_marginal_{split}_{tag}.jsonl"
                    verify_marg_log = run_dir / f"verify_marginal_{split}_{tag}.log.txt"
                    verify_marg_cmd = [
                        str(py),
                        "-u",
                        str(verify_marg),
                        "--cert-jsonl",
                        str(cert_marg_jsonl),
                        "--expect-lines",
                        str(int(args.episodes)),
                        "--out-report-json",
                        str(rep_marg_json),
                        "--out-report-txt",
                        str(rep_marg_txt),
                        "--out-violations-jsonl",
                        str(viol_marg_jsonl),
                    ]
                    rc_marg = _run_with_timestamped_log(cmd=verify_marg_cmd, out=verify_marg_log, allow_fail=True)

                    cert_min_jsonl = run_dir / f"cert_minproof_{split}_{tag}.jsonl"
                    cert_min_log = run_dir / f"cert_minproof_{split}_{tag}.txt"
                    cert_min_cmd = [
                        str(py),
                        "-u",
                        str(certify_min),
                        "--out-jsonl",
                        str(cert_min_jsonl),
                        "--split",
                        split,
                        "--episodes",
                        str(int(args.episodes)),
                        "--seed-base",
                        str(int(args.seed_base)),
                        "--n-classes",
                        str(int(n)),
                        "--img-size",
                        str(int(args.img_size)),
                        "--z-classes",
                        str(int(z)),
                        "--pair-n-ctx",
                        str(int(args.pair_n_ctx)),
                        "--device",
                        str(args.device),
                        "--ckpt",
                        str(ckpt),
                    ]
                    _run_with_timestamped_log(cmd=cert_min_cmd, out=cert_min_log, allow_fail=False)

                    rep_min_json = run_dir / f"verify_minproof_{split}_{tag}.json"
                    rep_min_txt = run_dir / f"verify_minproof_{split}_{tag}.txt"
                    viol_min_jsonl = run_dir / f"violations_minproof_{split}_{tag}.jsonl"
                    verify_min_log = run_dir / f"verify_minproof_{split}_{tag}.log.txt"
                    verify_min_cmd = [
                        str(py),
                        "-u",
                        str(verify_min),
                        "--cert-jsonl",
                        str(cert_min_jsonl),
                        "--ckpt",
                        str(ckpt),
                        "--device",
                        str(args.device),
                        "--expect-lines",
                        str(int(args.episodes)),
                        "--out-report-json",
                        str(rep_min_json),
                        "--out-report-txt",
                        str(rep_min_txt),
                        "--out-violations-jsonl",
                        str(viol_min_jsonl),
                    ]
                    rc_min = _run_with_timestamped_log(cmd=verify_min_cmd, out=verify_min_log, allow_fail=True)

                    summary.append(
                        {
                            "n_classes": int(n),
                            "z_classes": int(z),
                            "seed": int(seed),
                            "split": str(split),
                            "rc_verify_struct": int(rc_verify),
                            "rc_verify_marginal": int(rc_marg),
                            "rc_verify_minproof": int(rc_min),
                        }
                    )
                    _write_summary(run_dir / "summary_partial.json", summary)

    _write_summary(run_dir / "summary.json", summary)

    for n in n_list:
        for seed in seeds:
            z_final = int(n)
            if z_final not in z_list:
                continue
            bridge_cert = run_dir / f"cert_bridge_v22_{ts}_{bundle_short}_n{int(n)}_z{z_final}_seed{int(seed)}.jsonl"
            bridge_verify = run_dir / f"verify_bridge_v22_{ts}_{bundle_short}_n{int(n)}_z{z_final}_seed{int(seed)}.json"
            bridge_viol = run_dir / f"violations_bridge_v22_{ts}_{bundle_short}_n{int(n)}_z{z_final}_seed{int(seed)}.jsonl"
            bridge_falsify = run_dir / f"falsification_bridge_v22_{ts}_{bundle_short}_n{int(n)}_z{z_final}_seed{int(seed)}.json"
            _run_with_timestamped_log(
                cmd=[
                    str(py),
                    "-u",
                    str(certify_bridge),
                    "--run-dir",
                    str(run_dir),
                    "--n-classes",
                    str(int(n)),
                    "--z-classes",
                    str(z_final),
                    "--seed",
                    str(int(seed)),
                    "--out-jsonl",
                    str(bridge_cert),
                ],
                out=run_dir / f"cert_bridge_v22_{ts}_{bundle_short}_n{int(n)}_z{z_final}_seed{int(seed)}.txt",
                allow_fail=False,
            )
            _run_with_timestamped_log(
                cmd=[
                    str(py),
                    "-u",
                    str(verify_bridge),
                    "--cert-jsonl",
                    str(bridge_cert),
                    "--out-json",
                    str(bridge_verify),
                    "--violations-jsonl",
                    str(bridge_viol),
                ],
                out=run_dir / f"verify_bridge_v22_{ts}_{bundle_short}_n{int(n)}_z{z_final}_seed{int(seed)}.txt",
                allow_fail=False,
            )
            _run_with_timestamped_log(
                cmd=[
                    str(py),
                    "-u",
                    str(falsify_bridge),
                    "--cert-jsonl",
                    str(bridge_cert),
                    "--out-json",
                    str(bridge_falsify),
                ],
                out=run_dir / f"falsify_bridge_v22_{ts}_{bundle_short}_n{int(n)}_z{z_final}_seed{int(seed)}.txt",
                allow_fail=False,
            )

    print(f"[OK] v22 run_dir={str(run_dir)} snapshot_dir={str(snap_root)} bundle_hash={bundle_short}")


if __name__ == "__main__":
    main()



