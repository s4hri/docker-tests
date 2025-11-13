#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

run() {
  local name="$1"
  local script="$2"
  echo "==> Running $name ($script)"
  bash "$SCRIPT_DIR/$script"
  echo
}

run "System info"         "log_system_info.sh"
run "X11 test"            "x11/test_x11.sh"
run "Pulse test"          "audio/test_pulse.sh"
run "ALSA playback test"  "audio/test_alsa_playback.sh"
run "ALSA recording test" "audio/test_alsa_record.sh"
run "OpenGL test"         "opengl/test_opengl.sh"
run "NVIDIA test"         "nvidia/test_nvidia.sh"

echo "ALL TESTS COMPLETED"
