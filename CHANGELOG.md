# Changelog

## Unreleased

- Add the Gateway protobuf stream consumer, latest-state freshness check, and vehicle-state diagnostics binary.
- Add runtime binary fail-safe end-to-end tests for disconnects, stale state, and invalid snapshots.
- Add a dependency-free blocking VehicleState subscription API for applications.
- Add a fail-closed driver-video playback policy: fresh stationary state and P gear are required.

## [0.1.0] - 2026-09-21

- Rust runtime workspace 초기 구조와 CI를 추가했습니다.
