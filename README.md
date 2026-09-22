# ohayessOS

OAS 차량 소프트웨어 platform 및 runtime입니다. Host-side core는 Rust workspace로 구성하며, 차량 제어는 Safety 경계를 통과해야 합니다.

`ohayess-runtime [maximum-age-ms]`는 stdin에서 Gateway의 4-byte big-endian length-prefixed `VehicleState` protobuf stream을 읽고 속도·가속도·조향각·브레이크·freshness diagnostics를 stderr에 출력합니다. 최대 age는 기본 500ms입니다.

E2E 테스트는 정상 stream 종료, stale 상태, 손상·절단·초과 크기 snapshot의 fail-safe 처리를 실제 runtime binary에서 검증합니다.

애플리케이션은 blocking 구독 API로 SDK 내부 경로 없이 canonical 상태를 받을 수 있습니다.

운전자용 동영상 앱은 `Runtime::video_playback` 결과가 `Allowed`일 때만 재생해야 합니다. 이 정책은 최신 상태, 정차(0.1 m/s 이하), P 기어를 모두 확인하며 하나라도 알 수 없으면 차단합니다. 따라서 현재 차량 어댑터가 기어를 제공하지 않으면 영상은 의도적으로 열리지 않습니다.

```rust
use std::io::Read;

use ohayess_runtime::{Runtime, RuntimeError};

fn consume(stream: impl Read) -> Result<(), RuntimeError> {
    Runtime::new(stream).subscribe(|state| {
        println!("speed={:?}", state.vehicle_speed_mps);
    })
}
```
