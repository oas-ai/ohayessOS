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

화면 미리보기에는 읽기 전용 데모 모드를 사용합니다.

```sh
./build/hmi/ohayess-hmi --demo
```

좌측 하단 런처 버튼으로 화면을 이동하고, 숫자키 1–8은 앞의 여덟 목적지로 직행합니다. 상단 TopBar의 테마 버튼으로 밝은 화면과 어두운 화면을 즉시 바꿉니다. Settings → 화면에서 자동·밝은 화면·어두운 화면을 선택하며, 자동은 차량의 `nightMode` 신호를 우선합니다. 기본값은 밝은 화면입니다. 재현 가능한 캡처는 `--appearance light` 또는 `--appearance dark`를 사용합니다.

Additional synthetic states and reproducible PNG capture use the same QML views:

```sh
./build/hmi/ohayess-hmi --demo --scenario park
./build/hmi/ohayess-hmi --demo --scenario stale --size 1280x720 --capture /tmp/oas-stale.png
./build/hmi/ohayess-hmi --demo --scenario waiting
./build/hmi/ohayess-hmi --demo --page vehicle --size 1920x1080 --capture /tmp/oas-vehicle.png
# 초광폭 디스플레이 레이아웃
./build/hmi/ohayess-hmi --demo --page home --size 3840x1200 --capture /tmp/oas-ultrawide.png
# 주행 프리셋에서 정차 P 상태를 직접 주입
./build/hmi/ohayess-hmi --demo --demo-speed-kph 0 --demo-gear P
# R 기어의 12.5 km/h 상태를 주입
./build/hmi/ohayess-hmi --demo --demo-speed-kph 12.5 --demo-gear R
ctest --test-dir build/hmi --output-on-failure
```

제품 UX 구조, 디자인 토큰, 컴포넌트 시스템, 상호작용 규격은 [design/](design/)에 있습니다. 진입점은 [DESIGN.md](DESIGN.md)입니다.

`--scenario`은 drive, park, stale, waiting 프리셋을 지원합니다. `--demo-speed-kph`는 0~400 km/h, `--demo-gear`는 P/R/N/D를 받으며 프리셋 값을 덮어씁니다. 데모는 실제 프레임을 읽지 않고 화면에 합성 상태임을 표시합니다. `--page`는 home, navigation, climate, media, phone, camera, vehicle, settings, adas, energy, software, diagnostics를 지원합니다. `--expect-page`는 자동 전면화가 실제로 화면을 바꾼 뒤에 캡처합니다. `--menu`는 런처 메뉴를 펼친 상태로 시작합니다. 헤드리스 캡처에는 `QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software`를 설정합니다. 자세한 기준은 [디자인과 상태 규칙](DESIGN.md)을 참고하세요. CI는 `hmi-previews`에 캡처를 보관합니다.

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
