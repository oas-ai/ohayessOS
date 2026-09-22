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

The Qt HMI previews the production `HmiState` contract. Start it before writing a fixture stream:

```sh
mkfifo /tmp/oas-hmi-state
./build/hmi/ohayess-hmi --stream /tmp/oas-hmi-state &
OAS_HMI_STATE_OUTPUT=true cargo run -p ohayess-runtime -- 500 < vehicle-state-stream.bin > /tmp/oas-hmi-state
```

`ohayess-viewer` is the separate Web Viewer for the raw `VehicleState` fixture and browser CI:

```sh
cargo run -p ohayess-viewer -- 127.0.0.1:8080 500 < vehicle-state-stream.bin
```

Open `http://127.0.0.1:8080` for that Viewer. It is not the product Qt HMI and does not preview the `HmiState` routes.
