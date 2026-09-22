# ohayess HMI

This is the production HMI target: a Qt 6 / QML application for embedded Linux, not a browser application.

The HMI must receive the canonical length-prefixed `VehicleState` protobuf stream through a platform-owned `VehicleStateBridge`. It renders no driving value until that bridge reports a trusted state. Safety policy remains in `ohayess-runtime`; QML only presents its result.

Build on a target or SDK image with Qt 6.5 or later:

```sh
cmake -S apps/hmi -B build/hmi
cmake --build build/hmi
```

`crates/viewer` is intentionally separate: it is the loopback web viewer used for development, demos, and browser CI.
