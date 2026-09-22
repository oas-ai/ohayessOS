# Changelog

## Unreleased

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
