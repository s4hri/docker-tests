#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../common.sh"

need glxinfo

# We need X for classic OpenGL via GLX
[[ -n "${DISPLAY:-}" ]] || die "DISPLAY is empty (needed for OpenGL/GLX)"
xset q >/dev/null 2>&1 || die "Cannot query X server via xset (needed for OpenGL tests)"

tmp_out="$(mktemp /tmp/glxinfo_B_XXXX.txt)"
trap 'rm -f "$tmp_out"' EXIT

# -B gives a compact summary: renderer, version, profile, etc.
glxinfo -B >"$tmp_out" 2>/dev/null || die "glxinfo -B failed (no OpenGL context?)"

renderer="$(grep -E 'OpenGL renderer string' "$tmp_out" | sed 's/.*: //')"
version="$(grep -E 'OpenGL version string'  "$tmp_out" | sed 's/.*: //')"

[[ -n "$renderer" ]] || die "OpenGL renderer string not found in glxinfo output"
[[ -n "$version"  ]] || die "OpenGL version string not found in glxinfo output"

ok "OpenGL context OK (renderer: ${renderer}, version: ${version})"
