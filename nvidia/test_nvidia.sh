#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../common.sh"

need nvidia-smi

# 1) Basic nvidia-smi call
tmp_smi="$(mktemp /tmp/nvidia_smi_XXXX.txt)"
trap 'rm -f "$tmp_smi"' EXIT

if ! nvidia-smi >"$tmp_smi" 2>&1; then
  cat "$tmp_smi" >&2
  die "nvidia-smi failed (driver/GPU not reachable from container)"
fi

# 2) Check GPUs list
tmp_list="$(mktemp /tmp/nvidia_smi_L_XXXX.txt)"
trap 'rm -f "$tmp_list"' EXIT

if ! nvidia-smi -L >"$tmp_list" 2>&1; then
  cat "$tmp_list" >&2
  die "nvidia-smi -L failed"
fi

if ! grep -q '^GPU 0:' "$tmp_list"; then
  echo "nvidia-smi -L output:" >&2
  cat "$tmp_list" >&2
  die "No GPU 0 visible inside container"
fi

# 3) Basic /dev nodes check (common issue if runtime not configured)
if [ ! -e /dev/nvidia0 ]; then
  die "/dev/nvidia0 not present inside container (check nvidia-container-runtime / --gpus flag)"
fi

ok "NVIDIA GPU visible: $(head -n1 "$tmp_list")"
