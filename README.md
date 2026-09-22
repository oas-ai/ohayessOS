# ohayessOS

OAS 차량 소프트웨어 platform 및 runtime입니다. Host-side core는 Rust workspace로 구성하며, 차량 제어는 Safety 경계를 통과해야 합니다.

`ohayess-runtime [maximum-age-ms]`는 stdin에서 Gateway의 4-byte big-endian length-prefixed `VehicleState` protobuf stream을 읽고 속도·가속도·조향각·브레이크·freshness diagnostics를 stderr에 출력합니다. 최대 age는 기본 500ms입니다.

E2E 테스트는 정상 stream 종료, stale 상태, 손상·절단·초과 크기 snapshot의 fail-safe 처리를 실제 runtime binary에서 검증합니다.

애플리케이션은 blocking 구독 API로 SDK 내부 경로 없이 canonical 상태를 받을 수 있습니다.

운전자용 동영상 앱은 `Runtime::video_playback` 결과가 `Allowed`일 때만 재생해야 합니다. 기본 정책은 최신 상태, 정차(0.1 m/s 이하), P 기어를 모두 확인하며 하나라도 알 수 없으면 차단합니다. 따라서 현재 차량 어댑터가 기어를 제공하지 않으면 영상은 의도적으로 열리지 않습니다.

## HMI와 개발용 Viewer

실차 HMI는 [apps/hmi](apps/hmi)의 Qt/QML 애플리케이션입니다. 임베디드 Linux와 Qt 6.5 이상을 대상으로 하며, platform이 제공하는 `VehicleStateBridge`만 통해 canonical protobuf stream을 받습니다. 신뢰된 상태가 없으면 주행 값을 표시하거나 조작 기능을 활성화하지 않습니다.

`ohayess-viewer`는 별도의 loopback 전용 웹 Viewer입니다. 하드웨어 없이 `vcan` Gateway의 stdout을 연결하거나 fixture를 pipe해 개발·데모·browser CI에 사용합니다. Viewer는 제품 HMI가 아닙니다.

```sh
cargo run -p ohayess-viewer -- 127.0.0.1:8080 500 < vehicle-state-stream.bin
```

브라우저에서 `http://127.0.0.1:8080`을 열면 `/state`의 정책 결과를 250ms마다 반영합니다.

`#media/library`, `#vehicle/vision`, `#settings/safety`, `#diagnostics/can`처럼 URL fragment로 각 HMI menu와 in-menu view를 직접 열 수 있습니다. 이는 가상 CAN browser E2E와 kiosk 화면 복구에 사용합니다.

`#workspace`는 미디어와 공조를 동시에 표시하는 2분할 AVN 작업 공간입니다. Settings → Display에서 자동·라이트·다크 테마를 선택할 수 있습니다. 자동 테마는 HMI state stream의 `nightMode` 차량 신호를 우선하며, 신호가 없을 때는 Linux/WebView의 시스템 테마를 따릅니다.

운영 배포에서는 Gateway 패키지의 감독 서비스가 한 `VehicleState` stream을 runtime과 HMI bridge에 fan-out합니다. 설치·재연결·systemd 절차는 [gateway deployment guide](https://github.com/oas-ai/gateway/tree/main/packaging/systemd)를 따릅니다.

Viewer의 색상·간격·컴포넌트·안전 상태 규칙은 [design system](crates/viewer/DESIGN_SYSTEM.md)에 정의되어 있습니다.
화면 구조와 MVP 범위는 [information architecture](crates/viewer/INFORMATION_ARCHITECTURE.md)에 정의되어 있습니다.
화면 완성도와 빈 상태 점검 결과는 [UI/UX audit](crates/viewer/UI_UX_AUDIT.md)에 기록되어 있습니다.

정차 중 D 기어에서도 HMI 미디어를 열어야 할 경우에만 `OAS_ALLOW_MEDIA_IN_DRIVE_WHEN_STOPPED=true`으로 실행합니다. 기본값은 `false`이며, 이 예외를 켜도 움직임·stale·기어 상태 불명은 항상 차단됩니다.

```rust
use std::io::Read;

use ohayess_runtime::{Runtime, RuntimeError};

fn consume(stream: impl Read) -> Result<(), RuntimeError> {
    Runtime::new(stream).subscribe(|state| {
        println!("speed={:?}", state.vehicle_speed_mps);
    })
}
```
