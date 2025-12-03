# Docker Tests

A comprehensive test suite for validating Docker container capabilities including graphics (X11, OpenGL, NVIDIA), audio (ALSA, PulseAudio), multimedia frameworks (GStreamer, YARP), and system integration.

## Overview

This repository provides automated tests to verify that Docker containers are properly configured with access to:

- **X11 Display Server** - GUI window system
- **Audio Systems** - ALSA and PulseAudio/PipeWire
- **OpenGL** - Hardware-accelerated graphics
- **NVIDIA GPUs** - GPU computing and graphics acceleration
- **GStreamer** - Multimedia framework for video processing
- **YARP** - Robotics middleware platform

## Quick Start

Run all system tests:

```bash
./run_system_tests.sh
```

This will execute all available tests and report success/failure for each component.

## Test Categories

### System Information

- **`log_system_info.sh`** - Logs comprehensive system information including kernel version, distro, Docker detection, user/group info, display configuration, audio devices, and GPU information.

### X11 Tests

- **`x11/test_x11.sh`** - Verifies X11 connection by checking the `DISPLAY` environment variable and querying the X server with `xset`.

### Audio Tests

- **`audio/test_pulse.sh`** - Tests PulseAudio/PipeWire connectivity and audio playback using `paplay`.
- **`audio/test_alsa_playback.sh`** - Tests ALSA playback capability.
- **`audio/test_alsa_record.sh`** - Tests ALSA recording capability.

### Graphics Tests

- **`opengl/test_opengl.sh`** - Validates OpenGL context creation and reports renderer/version information using `glxinfo`.
- **`nvidia/test_nvidia.sh`** - Checks NVIDIA GPU accessibility via `nvidia-smi` and verifies driver functionality.

### Multimedia Tests

- **`gstreamer/`** - Contains GStreamer pipeline tests:
  - `videotestsrc.sh` - Video test source
  - `h264enc.sh` - H.264 encoding
  - `camera.sh` - Camera capture
  - `serverh264.sh` / `clienth264.sh` - H.264 streaming tests

### Robotics Tests

- **`yarp/test_yarp.sh`** - Comprehensive YARP middleware test including server startup, CLI verification, plugin checks, port communication, RPC calls, and Python bindings.

## Configuration

Tests can be configured using environment variables:

### Audio Configuration

```bash
export AUDIO_MUTED=yes          # Mute audio during playback tests (default: no)
export ALSA_DEVICE=default      # ALSA PCM device (default: default)
export PULSE_TEST_WAV=/path/to/test.wav  # Custom test audio file
```

### Common Variables

The `common.sh` file provides shared utilities and default configurations used across tests.

## Requirements

### Host System Requirements

- Docker with X11 socket access
- Audio system (ALSA/PulseAudio/PipeWire)
- Optional: NVIDIA Docker runtime for GPU tests
- Optional: GStreamer for multimedia tests
- Optional: YARP for robotics tests

### Container Requirements

Tests expect the following tools to be installed in the container:

- **Core**: `bash`, `xset`
- **Audio**: `aplay`, `arecord`, `pactl`, `paplay`
- **Graphics**: `glxinfo`, `nvidia-smi` (for NVIDIA tests)
- **Multimedia**: `gst-launch-1.0` (for GStreamer tests)
- **Robotics**: `yarp`, `yarpserver`, `yarp-config`, `python3` (for YARP tests)

## Docker Integration

### Example Docker Run Command

```bash
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v /run/user/$UID/pulse:/run/user/1000/pulse \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  --device /dev/snd \
  --device /dev/dri \
  --gpus all \
  your-image:tag \
  /path/to/run_system_tests.sh
```

### Key Docker Flags

- `-e DISPLAY=$DISPLAY` - Pass display variable
- `-v /tmp/.X11-unix:/tmp/.X11-unix:rw` - X11 socket access
- `-v /run/user/$UID/pulse:...` - PulseAudio socket access
- `--device /dev/snd` - ALSA audio devices
- `--device /dev/dri` - Direct Rendering Infrastructure (GPU)
- `--gpus all` - NVIDIA GPU access (requires nvidia-docker2)

## Exit Codes

- **0** - All tests passed
- **1** - One or more tests failed
- **2** - Missing required command/dependency

## Output Format

Tests use color-coded output:

- 🟡 **Yellow** - Test starting
- 🟢 **Green** - Test passed `[OK]`
- 🔴 **Red** - Test failed `[FAILED]`

## Development

### Adding New Tests

1. Create test script in appropriate category folder
2. Source `common.sh` for shared utilities (`need`, `die`, `ok`)
3. Add test to `run_system_tests.sh`
4. Follow the pattern:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   
   SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
   source "$SCRIPT_DIR/../common.sh"
   
   need required_command
   
   # Your test logic here
   [[ condition ]] || die "Error message"
   ok "Success message"
   ```

### Utility Functions

From `common.sh`:

- **`need <command>`** - Check if command exists, exit with code 2 if missing
- **`die <message>`** - Print error message and exit with code 1
- **`ok <message>`** - Print success message

## License

BSD 2-Clause License

Copyright (c) 2020, Social Cognition in Human-Robot Interaction

See [LICENSE](LICENSE) for full details.

## Contributing

Contributions are welcome! Please ensure:

1. Tests are idempotent and don't require user interaction
2. Tests clean up any temporary resources
3. Error messages are clear and actionable
4. Tests follow the existing patterns and utilities

## Troubleshooting

### X11 Connection Fails

- Verify `DISPLAY` is set correctly
- Check X11 socket is mounted: `-v /tmp/.X11-unix:/tmp/.X11-unix:rw`
- Run `xhost +local:` on host if permission denied

### Audio Not Working

- Verify audio devices: `--device /dev/snd`
- Check PulseAudio socket path matches host UID
- Try `AUDIO_MUTED=yes` to test without actual playback

### NVIDIA Tests Fail

- Ensure nvidia-docker2 is installed
- Use `--gpus all` flag
- Verify driver version matches host: `nvidia-smi`

### Permission Issues

- Check user/group IDs match between host and container
- Verify device permissions: `ls -l /dev/snd /dev/dri`
- Add user to required groups (audio, video)

## Acknowledgments

Developed with love by the Social Cognition in Human-Robot Interaction (S4HRI) team.
