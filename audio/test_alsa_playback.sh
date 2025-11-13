#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../common.sh"

need aplay
need timeout

# speaker-test is nice to have but not strictly required
if command -v speaker-test >/dev/null 2>&1; then
  HAVE_SPEAKER_TEST=1
else
  HAVE_SPEAKER_TEST=0
fi

# 1) ALSA devices visible at all
aplay -l >/dev/null 2>&1 || die "ALSA devices not visible (aplay -l)"
ok "ALSA devices visible"

alsa_beep_ok=false

# 2) Helper: try beep with speaker-test if available
_try_speaker_test() {
  local dev="$1"
  [[ "$HAVE_SPEAKER_TEST" -eq 1 ]] || return 1
  timeout 3s speaker-test -c 2 -t sine -l 1 -D "$dev" >/dev/null 2>&1
}

# 3) Helper: try beep/test with aplay on a sample wav
_try_aplay_sample() {
  local dev="$1"
  local wav=""

  [[ -f /usr/share/sounds/alsa/Front_Center.wav ]] && wav=/usr/share/sounds/alsa/Front_Center.wav
  [[ -n "${PULSE_TEST_WAV:-}" && -f "${PULSE_TEST_WAV:-}" ]] && wav="$PULSE_TEST_WAV"

  [[ -n "$wav" ]] || return 1

  timeout 3s aplay -D "$dev" "$wav" >/dev/null 2>&1
}

# 4) First, try the user-provided ALSA_DEVICE
if _try_speaker_test "$ALSA_DEVICE" || _try_aplay_sample "$ALSA_DEVICE"; then
  ok "ALSA playback (-D $ALSA_DEVICE) short test"
  alsa_beep_ok=true
else
  echo "WARN: ALSA playback failed on ALSA_DEVICE='$ALSA_DEVICE'" >&2
fi

# 5) If that failed, try to auto-detect a plughw device from aplay -l
if [[ "$alsa_beep_ok" = false ]]; then
  # Grab first card/device from aplay -l
  if card_line="$(aplay -l | awk '/^card [0-9]+:/ {c=$2} /device [0-9]+:/ && c {print c,$2; exit}' 2>/dev/null)"; then
    card_num="$(echo "$card_line" | awk '{print $1}' | tr -d ':')"
    dev_num="$(echo "$card_line" | awk '{print $2}' | tr -d ':')"
    auto_dev="plughw:${card_num},${dev_num}"

    if _try_speaker_test "$auto_dev" || _try_aplay_sample "$auto_dev"; then
      ok "ALSA playback auto-detected (-D $auto_dev) short test"
      alsa_beep_ok=true
    else
      echo "WARN: ALSA playback failed on auto-detected device '$auto_dev'" >&2
    fi
  else
    echo "WARN: Could not auto-detect ALSA card/device from aplay -l" >&2
  fi
fi

# 6) Final status
if [[ "$alsa_beep_ok" = false ]]; then
  echo "WARN: ALSA beep/playback test skipped (no working PCM found)" >&2
fi
