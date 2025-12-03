#!/usr/bin/env bash
set -u  # Keep undefined variable protection (but NOT -e)

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

failures=0

run() {
  local name="$1"
  local script="$2"

  echo -e "${YELLOW}==> Running $name ($script)${RESET}"

  if bash "$SCRIPT_DIR/$script"; then
    echo -e "${GREEN}[OK] $name${RESET}"
  else
    echo -e "${RED}[FAILED] $name${RESET}"
    failures=$((failures + 1))
  fi

  echo
}

run "System info"         "log_system_info.sh"
run "X11 test"            "x11/test_x11.sh"
run "Pulse test"          "audio/test_pulse.sh"
run "ALSA playback test"  "audio/test_alsa_playback.sh"
run "ALSA recording test" "audio/test_alsa_record.sh"
run "OpenGL test"         "opengl/test_opengl.sh"
run "NVIDIA test"         "nvidia/test_nvidia.sh"

