from __future__ import annotations
import argparse
import json
from pathlib import Path


FORBIDDEN_OVERCLAIMS = (
    "unbounded empirical infinity",
    "autonomous discovery",
    "formal theorem",
)

REQUIRED_FILES = (
    "render_aslmt_v22_perceptual_localglobal_dynamic_infinite.py",
    "aslmt_env_v22_perceptual_localglobal_dynamic_infinite.py",
    "aslmt_model_v22_perceptual_localglobal_dynamic_infinite.py",
    "aslmt_train_v22_perceptual_localglobal_dynamic_infinite.py",
    "certify_struct_aslmt_v22_perceptual.py",
    "verify_struct_aslmt_v22_perceptual.py",
    "certify_minproof_aslmt_v22_perceptual.py",
    "verify_minproof_aslmt_v22_perceptual.py",
    "certify_marginal_nogo_aslmt_v22_perceptual.py",
    "verify_marginal_nogo_aslmt_v22_perceptual.py",
    "certify_bridge_aslmt_v22.py",
    "verify_bridge_aslmt_v22.py",
    "falsify_v22_bridge_verifier.py",
    "aslmt_campaign_v22_perceptual_localglobal_dynamic_infinite.py",
    "README.md",
    "SCIENTIFIC_PROTOCOL.md",
)


def audit(base_dir: Path) -> dict:
    missing = [name for name in REQUIRED_FILES if not (base_dir / name).exists()]
    docs = "\n".join(
        (base_dir / name).read_text(encoding="utf-8")
        for name in ("README.md", "SCIENTIFIC_PROTOCOL.md")
        if (base_dir / name).exists()
    ).lower()
    forbidden_hits = [text for text in FORBIDDEN_OVERCLAIMS if text in docs]
    return {"ok": not missing and not forbidden_hits, "missing": missing, "forbidden_overclaims": forbidden_hits}


def main() -> int:
    p = argparse.ArgumentParser(description="Audit v22 file manifest and documentation claims.")
    p.add_argument("--base-dir", type=Path, default=Path(__file__).resolve().parent)
    p.add_argument("--out-json", type=Path, default=None)
    args = p.parse_args()
    report = audit(args.base_dir.resolve())
    if args.out_json:
        args.out_json.parent.mkdir(parents=True, exist_ok=True)
        args.out_json.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2, sort_keys=True))
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())


