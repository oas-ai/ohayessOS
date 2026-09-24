# Changelog
## Unreleased

### Changed
- 디자인 시스템을 **Grid**로 다시 잡았습니다. 떠 있는 카드 대신 맞닿는 셀과 1px 규칙선, 반경 0, 그림자·blur 없음, 모노크롬이며 색은 안전 상태에만 남습니다. Light가 기본이고 Dark는 같은 언어의 야간 반전입니다.
- 내비게이션을 상시 Dock에서 **좌측 하단 런처 하나**로 바꿨습니다. 누르면 12개 목적지가 한 번에 펼쳐지고, 버튼은 항상 현재 화면명을 표시하며, 주행 중 잠긴 목적지는 사유와 함께 남습니다.
- 하단 재생 스트립은 **재생 중일 때만** 나타납니다. 런처는 행에 그대로 남아 화면 내용을 가리지 않습니다.
- `apps/hmi/design/` 문서 4종을 새 시스템 기준으로 다시 썼습니다.

### Fixed
- 레이아웃 안에서 자식을 앵커링해 화면이 무너지던 문제를 고쳤습니다. `Cell`에 오버레이 전용 슬롯을 두고, 중첩 레이아웃의 `fillHeight` 기본값(true) 때문에 런처 행이 스테이지 높이를 전부 가져가던 것을 고정했습니다.
- `Metric`이 남는 높이를 값 아래로 모아, 짧은 셀과 긴 셀이 같은 상단 기준선에서 읽힙니다.

### Added
- `apps/hmi/design/`에 Automotive OS 설계 기준 4종(UX 아키텍처·디자인 토큰·컴포넌트 시스템·상호작용 규격)을 추가했습니다.
- HMI를 12개 화면(홈·내비게이션·공조·미디어·전화·카메라·차량·설정·주행 보조·에너지·소프트웨어·진단)으로 확장하고, 8개 목적지의 상주 Control Dock과 Status Rail로 하나의 OS처럼 연결했습니다.
- Genesis 계열 copper accent 기반 디자인 토큰 singleton(`Tokens.qml`)과 22개 공통 컴포넌트를 추가했습니다.
- 계약에 없는 도메인(지도·공조·에너지·ADAS·카메라·미디어·조명·잠금·타이어·전화·업데이트)을 `Providers.qml` 공급자 계층으로 분리했습니다. `connected`가 false인 영역은 합성값 대신 빈 상태를 표시합니다.
- `VehicleStateBridge`가 도어·안전벨트·조향각·브레이크·가속페달·크루즈·휠속도·원시 신호를 신호 단위 유효성과 함께 노출합니다. 차량 시각화가 이 값들을 실시간 반영합니다.
- R 기어 자동 카메라 전면화와 `--expect-page` 검증 옵션을 추가했습니다.

### Changed
- 렌더 테스트가 12개 화면 전부, 라이트 테마 3종, 1280×720 / 1920×1080 / 2560×1440 / 3840×1200 네 해상도를 검증합니다.
- `UX_ARCHITECTURE.ko.md`를 `design/`으로 통합하고 `DESIGN.md`를 진입점으로 바꿨습니다.

### Fixed
- `stale` 상태가 속도·기어 외 모든 주행 신호와 원시 신호를 함께 비웁니다.

### Earlier in this cycle
- Add white-based light and black-based dark appearance modes to the production HMI.
- Translate the production Qt HMI into Korean and add injected demo speed and gear values for product previews.
- Add Calm Future Mobility QML tokens, reusable panels, accessible navigation and an original concept vehicle illustration.
- Distinguish synthetic demo, waiting and stale states; remove unsupported vehicle-health claims.
- Add drive/park/waiting/stale previews, PNG capture and actual QML launch tests at 720p/1080p.
- Close expired capabilities even when speed is missing, and reject oversized unsigned frame lengths.

- Split the production Qt/QML HMI target from the loopback web VehicleState Viewer.
- Redesign Home as a vehicle-first drive brief with prioritized driving, media, vehicle, and diagnostics entry points.
- Label Palisade diagnostics as DBC raw values that are excluded from control and safety decisions.
- Show DBC-trusted Palisade body, seatbelt, door, and climate raw diagnostics in the read-only HMI.
- Add the Gateway protobuf stream consumer, latest-state freshness check, and vehicle-state diagnostics binary.
- Add runtime binary fail-safe end-to-end tests for disconnects, stale state, and invalid snapshots.
- Add a dependency-free blocking VehicleState subscription API for applications.
- Add a fail-closed driver-video playback policy: fresh stationary state and P gear are required.
- Add a hardware-independent loopback HMI shell with Park-to-Drive and stale-state media-lock E2E coverage.
- Allow an explicit, default-off HMI setting for media while stationary in D; motion and stale-state locks remain mandatory.
- Establish HMI design tokens, core components, responsive layout, and semantic safety-state presentation.
- Define the HMI information architecture, safety overlay priority, MVP destinations, and settings ownership.
- Design the five top-level HMI destinations and route them in the virtual HMI shell.
- Add local-only HVAC and vehicle-audio Comfort Control UI previews to Vehicle.
- Complete the virtual HMI's in-menu screen inventory and add a global safety state banner.
- Document the Gateway-supervised runtime and HMI fan-out deployment path.
- Add hash-addressable HMI destinations for browser end-to-end verification and kiosk recovery.
- Add light/dark appearance preferences and an AVN split workspace to the HMI.
- Feed the optional vehicle night-mode signal into automatic HMI appearance.

## [0.1.0] - 2026-09-21

- Rust runtime workspace 초기 구조와 CI를 추가했습니다.
