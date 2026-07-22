#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

mapfile -t lean_files < <(find Repairability -type f -name '*.lean' -print | sort)
lean_files+=(Repairability.lean AuditProbe.lean)

for lean_file in "${lean_files[@]}"; do
  begin_count="$(rg -c 'AXIOM_AUDIT_BEGIN' "$lean_file" || true)"
  end_count="$(rg -c 'AXIOM_AUDIT_END' "$lean_file" || true)"
  if [[ "$begin_count" != "1" || "$end_count" != "1" ]]; then
    echo "invalid AXIOM_AUDIT count: $lean_file" >&2
    exit 1
  fi

  last_nonempty="$(awk 'NF { line=$0 } END { print line }' "$lean_file")"
  if [[ "$last_nonempty" != '/- AXIOM_AUDIT_END -/' ]]; then
    echo "AXIOM_AUDIT is not final: $lean_file" >&2
    exit 1
  fi
done

if rg -n '^[[:space:]]*(axiom|sorry|admit)([[:space:]]|$)' \
    Repairability Repairability.lean AuditProbe.lean; then
  echo "forbidden proof escape found" >&2
  exit 1
fi

if rg -n 'Classical\.|open[[:space:]]+Classical|propext|Quot\.sound' \
    Repairability Repairability.lean AuditProbe.lean; then
  echo "forbidden logical dependency found" >&2
  exit 1
fi

audit_log="$(mktemp)"
trap 'rm -f "$audit_log"' EXIT

lake build 2>&1 | tee "$audit_log"
lake env lean AuditProbe.lean 2>&1 | tee -a "$audit_log"

if rg -n 'depends on axioms:' "$audit_log"; then
  echo "nonconstructive declaration detected" >&2
  exit 1
fi

echo "constructive audit passed for ${#lean_files[@]} Lean files"
