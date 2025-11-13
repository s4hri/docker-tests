#!/usr/bin/env bash
set -euo pipefail

echo "==============================="
echo "=== SYSTEM INFO (env check) ==="
echo "==============================="

# OS + Kernel + Distro
echo "- Kernel: $(uname -a)"
if [[ -f /etc/os-release ]]; then
  echo "- Distro: $(awk -F= '/^PRETTY_NAME/ {print $2}' /etc/os-release | tr -d '"')"
fi

# Docker detection
if grep -q docker /proc/1/cgroup 2>/dev/null; then
  echo "- Environment: Inside Docker"
else
  echo "- Environment: Host / non-Docker"
fi

# Current user info
echo "- User: $(whoami) (UID: $(id -u))"
echo "- Groups: $(id -nG)"

# X / Wayland / DISPLAY
echo "- DISPLAY: ${DISPLAY:-<empty>}"
echo "- WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:-<empty>}"
echo "- XDG_SESSION_TYPE: ${XDG_SESSION_TYPE:-<empty>}"

# ALSA information
if command -v aplay >/dev/null 2>&1; then
  echo "- ALSA Playback Hardware (aplay -l):"
  aplay -l 2>/dev/null | sed 's/^/    /' || echo "    <unavailable>"
else
  echo "- ALSA Playback: aplay not installed"
fi

# PulseAudio / PipeWire info
if command -v pactl >/dev/null 2>&1; then
  sink="$(pactl get-default-sink 2>/dev/null || true)"
  echo "- Pulse Default Sink: ${sink:-<none>}"
else
  echo "- Pulse: pactl not installed"
fi

# NVIDIA info
if command -v nvidia-smi >/dev/null 2>&1; then
  if nvidia-smi -L >/dev/null 2>&1; then
    echo "- NVIDIA GPUs: $(nvidia-smi -L | tr '\n' '; ')"
  else
    echo "- NVIDIA: nvidia-smi installed but GPU not visible"
  fi
else
  echo "- NVIDIA: nvidia-smi not installed"
fi

# OpenGL info
if command -v glxinfo >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" ]]; then
  renderer=$(glxinfo -B 2>/dev/null | awk -F': ' '/renderer string/ {print $2}')
  version=$(glxinfo -B 2>/dev/null | awk -F': ' '/version string/ {print $2}')
  echo "- OpenGL Renderer: ${renderer:-<unknown>}"
  echo "- OpenGL Version: ${version:-<unknown>}"
else
  echo "- OpenGL: glxinfo not available or DISPLAY empty"
fi

echo "==============================="
echo
