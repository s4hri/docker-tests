#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../common.sh"

need xset

[[ -n "${DISPLAY:-}" ]] || die "DISPLAY is empty"
xset q >/dev/null 2>&1 || die "Cannot query X server via xset"
ok "X connection (xset q)"