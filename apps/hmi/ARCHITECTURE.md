# HMI runtime boundary

`ohayess-hmi` is a Qt/QML process owned by the embedded-Linux image. It does not read CAN, DBC files, or Gateway internals.

The platform provides one read-only `VehicleStateBridge` with this contract. The current implementation reads `/run/ohayess/vehicle-state` by default; `--stream` changes that path.

1. Subscribe to the canonical 4-byte big-endian length-prefixed `HmiState` protobuf stream.
2. Preserve the runtime's freshness and capability decisions; QML never recreates safety policy.
3. Publish an empty/unavailable model on disconnect, decode failure, or stale state.
4. Expose only presentation values and policy outcomes to QML; no vehicle command API is present.

The Gateway supervisor sends Runtime-produced `HmiState` frames to that FIFO and `ohayess-hmi.service` owns its lifecycle. `crates/viewer` deliberately uses a loopback HTTP endpoint only for development and browser CI; it is not a dependency of the production HMI.
