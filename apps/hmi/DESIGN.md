# Calm Future Mobility

제품 수준의 UX 구조, 정보 구조, 와이어프레임, 토큰, 반응형·상호작용 기준은 [UX_ARCHITECTURE.ko.md](UX_ARCHITECTURE.ko.md)에 정의한다. 구현 가능한 VehicleState/HmiState 계약만 표현하며, 향후 지도·ADAS·공조·에너지 공급자가 추가되기 전에는 해당 정보를 합성하지 않는다.

The production UI uses `Theme.qml` for midnight, cyan, violet and semantic state colors. `GlassPanel`, `StatusPill`, `NavDock` and the original Canvas `VehicleVisual` share this vocabulary. The illustration is decorative: it is not a Palisade model, camera view or detected surroundings.

Drive prioritizes speed and gear. The middle has a concept vehicle and restrained lighting; the right has connection and video permission. The dock uses real Qt buttons for keyboard, touch and accessibility. All destinations remain inspectable when capabilities are locked; no playback or vehicle-control action is exposed.

## Truthful states

Demo always says SYNTHETIC. Fresh means a state arrived, not that every vehicle system is healthy. Waiting and stale hide driving values; diagnostics values are shown only while the Runtime capability is allowed. Unknown information is not filled with fuel, range or cabin values. Runtime owns playback policy; the bridge only invalidates expired transport data.

## Review

Run CTest for rendered drive, park, waiting and stale at 1280×720, and Media, Signals and Vehicle at 1920×1080. Binding errors fail the tests; screenshots are CI artifacts. Inspect screenshots as well as test status. The current renderer uses gradients and Canvas rather than blur shaders so software and embedded renderers share the same layout. Dock changes use a 240ms transition; there is no distracting repeating animation.
