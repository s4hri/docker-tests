#!/usr/bin/env bash
set -euo pipefail

# Env:
#   AUDIO_MUTED=yes|no (default yes)
#   ALSA_DEVICE=<pcm> (default: default)
#   PULSE_TEST_WAV=path/to/test.wav (optional)

AUDIO_MUTED="${AUDIO_MUTED:-no}"
ALSA_DEVICE="${ALSA_DEVICE:-default}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "MISSING: $1"; exit 2; }; }
die()  { echo "FAIL: $*" >&2; exit 1; }
ok()   { echo "OK: $*"; }
