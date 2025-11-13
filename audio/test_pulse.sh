#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../common.sh"

need pactl
need paplay

# 1) Pulse/pipewire control reachable
pactl info >/dev/null 2>&1 || die "pactl cannot reach Pulse/pipewire (check PULSE_SERVER/socket)"
ok "Pulse control reachable"

# 2) Pick a WAV sample
wav=""
[[ -f /usr/share/sounds/alsa/Front_Center.wav ]] && wav=/usr/share/sounds/alsa/Front_Center.wav
[[ -n "${PULSE_TEST_WAV:-}" && -f "${PULSE_TEST_WAV:-}" ]] && wav="$PULSE_TEST_WAV"
[[ -n "$wav" ]] || die "No test WAV found (provide PULSE_TEST_WAV or install a system sample)"

if [[ "$AUDIO_MUTED" == "yes" ]]; then
  sink="$(pactl get-default-sink 2>/dev/null || pactl info 2>/dev/null | awk -F': ' '/Default Sink/ {print $2}')"
  [[ -n "$sink" ]] || die "Cannot determine default Pulse sink"
  pactl set-sink-mute "$sink" 1 >/dev/null 2>&1 || die "Failed to mute sink"
  paplay "$wav" >/dev/null 2>&1 || { pactl set-sink-mute "$sink" 0 >/dev/null 2>&1 || true; die "paplay failed"; }
  pactl set-sink-mute "$sink" 0 >/dev/null 2>&1 || die "Failed to unmute sink"
  ok "Pulse playback (muted) via paplay"
else
  paplay "$wav" >/dev/null 2>&1 || die "paplay failed"
  ok "Pulse playback via paplay"
fi
