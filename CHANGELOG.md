# Changelog

## Unreleased

- Add the Gateway protobuf stream consumer, latest-state freshness check, and vehicle-state diagnostics binary.
- Add runtime binary fail-safe end-to-end tests for disconnects, stale state, and invalid snapshots.
- Add a dependency-free blocking VehicleState subscription API for applications.
- Add a fail-closed driver-video playback policy: fresh stationary state and P gear are required.
- Add a hardware-independent loopback HMI shell with Park-to-Drive and stale-state media-lock E2E coverage.
- Allow an explicit, default-off HMI setting for media while stationary in D; motion and stale-state locks remain mandatory.
- Establish HMI design tokens, core components, responsive layout, and semantic safety-state presentation.
- Define the HMI information architecture, safety overlay priority, MVP destinations, and settings ownership.

## [0.1.0] - 2026-09-21

- Rust runtime workspace 초기 구조와 CI를 추가했습니다.
