# ohayessOS

OAS 차량 소프트웨어 platform 및 runtime입니다. Host-side core는 Rust workspace로 구성하며, 차량 제어는 Safety 경계를 통과해야 합니다.

`ohayess-runtime [maximum-age-ms]`는 stdin에서 Gateway의 4-byte big-endian length-prefixed `VehicleState` protobuf stream을 읽고 속도·가속도·조향각·브레이크·freshness diagnostics를 stderr에 출력합니다. 최대 age는 기본 500ms입니다.
