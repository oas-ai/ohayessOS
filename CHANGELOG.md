# Changelog
## Unreleased

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
