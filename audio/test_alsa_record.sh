#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../common.sh"

need aplay
need arecord

rec_file="$(mktemp /tmp/alsa_rec_test_XXXX.wav)"

# Small, safe format: mono, 16kHz, 1s
if arecord -q -D "$ALSA_DEVICE" -f S16_LE -r 16000 -c 1 -d 1 "$rec_file" >/dev/null 2>&1; then
  ok "ALSA recording (-D $ALSA_DEVICE, 1s test)"
  # Optional playback of recorded sample
  if [[ "$AUDIO_MUTED" == "yes" ]]; then
    aplay -q "$rec_file" >/dev/null 2>&1 || ok "Recorded playback skipped (aplay failed, but recording worked)"
  else
    aplay -q "$rec_file" >/dev/null 2>&1 || ok "Recorded playback failed, but recording succeeded"
  fi
else
  rm -f "$rec_file"
  die "ALSA recording failed (-D $ALSA_DEVICE)"
fi

rm -f "$rec_file"
