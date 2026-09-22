# ohayess HMI

This is the production HMI target: a Qt 6 / QML application for embedded Linux, not a browser application.

The HMI receives the canonical length-prefixed `HmiState` protobuf stream through a platform-owned `VehicleStateBridge`. It renders no driving value until that bridge reports a trusted state. Safety policy remains in `ohayess-runtime`; QML only presents its result.

Build on a target or SDK image with Qt 6.2 or later. Pass the checked-out SDK schema explicitly outside the multi-repository workspace:

```sh
cmake -S apps/hmi -B build/hmi -DOAS_SDK_PROTO_DIR=/path/to/sdk/proto
cmake --build build/hmi
```

`crates/viewer` is intentionally separate: it is the loopback web viewer used for development, demos, and browser CI.

## Local preview

Install the macOS development dependencies once:

```sh
brew install qt protobuf
```

Then configure CMake with Homebrew Qt:

```sh
cmake -S apps/hmi -B build/hmi -DCMAKE_PREFIX_PATH="$(brew --prefix qt)" -DOAS_SDK_PROTO_DIR=/Users/sy/VSCodeProjects/oas-ai/sdk/proto
cmake --build build/hmi
```

For a screen-only preview, use the explicit read-only demo mode:

```sh
./build/hmi/ohayess-hmi --demo
```

Additional synthetic states and reproducible PNG capture use the same QML views:

```sh
./build/hmi/ohayess-hmi --demo --scenario park
./build/hmi/ohayess-hmi --demo --scenario stale --size 1280x720 --capture /tmp/oas-stale.png
./build/hmi/ohayess-hmi --demo --scenario waiting
./build/hmi/ohayess-hmi --demo --page diagnostics --size 1920x1080 --capture /tmp/oas-signals.png
ctest --test-dir build/hmi --output-on-failure
```

`--scenario` accepts drive, park, stale and waiting. Demo never reads live frames and is visibly marked synthetic. `--page` accepts drive, media, diagnostics and vehicle. For headless capture, set `QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software`. See [design and state rules](DESIGN.md). CI uploads screenshots under `hmi-previews`.

If preserving an existing build directory, configure with a new `-B` directory and use the same path for build, CTest and executable commands.

## Runtime FIFO on Linux

The following is a real Gateway → Runtime → HMI connection; it does not require a missing `vehicle-state-stream.bin`. Run from the multi-repository workspace after building the Rust and Qt targets and configuring a receive-only CAN interface (or `vcan0` for simulation):

```sh
cargo build --manifest-path gateway/Cargo.toml -p oas-gateway-host
cargo build --manifest-path ohayessOS/Cargo.toml -p ohayess-runtime
session_dir=$(mktemp -d)
mkfifo "$session_dir/hmi-state"
ohayessOS/build/hmi/ohayess-hmi --stream "$session_dir/hmi-state" &
OAS_HMI_STREAM="$session_dir/hmi-state" bash gateway/scripts/run-gateway-runtime.sh \
  ohayessOS/target/debug/ohayess-runtime gateway/target/debug/oas-gateway-host vcan0 0
```

Only test fixtures inject frames into `vcan0`; product SocketCAN is receive-only. The default HMI FIFO path remains `/run/ohayess/vehicle-state`, overridden by `--stream`. The gateway systemd configuration supplies its own path.

For an existing recorded length-prefixed VehicleState stream (not bundled with the repository), start the HMI before writing it:

```sh
session_dir=$(mktemp -d)
mkfifo "$session_dir/hmi-state"
./build/hmi/ohayess-hmi --stream "$session_dir/hmi-state" &
OAS_HMI_STATE_OUTPUT=true cargo run -p ohayess-runtime --bin ohayess-runtime -- 500 < vehicle-state-stream.bin > "$session_dir/hmi-state"
```

`ohayess-viewer` is the separate Web Viewer for the raw `VehicleState` fixture and browser CI:

```sh
cargo run -p ohayess-viewer -- 127.0.0.1:8080 500 < vehicle-state-stream.bin
```

Open `http://127.0.0.1:8080` for that Viewer. It is not the product Qt HMI and does not preview the `HmiState` routes.
