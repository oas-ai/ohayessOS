# OAS Automotive OS — Component System

화면보다 먼저 존재한다. 화면은 컴포넌트를 조합할 뿐이며, 두 화면 이상에서 필요해질 때만 새 컴포넌트를 만든다.

모든 컴포넌트는 [Design Tokens](01-DESIGN-TOKENS.md)만 참조하고, 차량 상태를 직접 읽지 않는다 — 값은 property로 주입받는다. 이것이 UI State / Vehicle State 분리의 컴포넌트 수준 구현이다.

## Foundation

### `Tokens` (singleton)
색·타이포·간격·모션·breakpoint의 단일 공급원. `dark` 하나만 가변이며 나머지는 파생된다.

### `Icon`
```
name: string    // 아이콘 식별자
size: int       // Tokens.iconMd 기본
tone: color     // Tokens.textSecondary 기본
active: bool    // true면 tone → accent, stroke 1.75 → 2.25
```
Canvas 기반 line icon. software renderer에서 동일하게 그려진다.

수록: `home` `navigation` `climate` `media` `phone` `camera` `vehicle` `settings` `play` `pause` `next` `prev` `fan` `seatHeat` `seatVent` `defrostFront` `defrostRear` `lock` `unlock` `light` `battery` `fuel` `adas` `wrench` `download` `pulse` `chevronRight` `chevronLeft` `close` `check` `warning` `plus` `minus` `volume` `mic` `search` `star` `charge` `turnLeft` `turnRight` `turnStraight` `uTurn`

### `Panel`
Level 1 컨테이너. `surface` + `borderSubtle` + `rXl`. 내부 패딩 `s5`.
**Panel 안에 Panel을 중첩하지 않는다.** 구획이 필요하면 `Divider` 또는 `surfaceAlt` 블록을 쓴다.

### `Caption` / `Readout` / `Divider`
- `Caption` — `caption` 토큰, UPPERCASE, `textTertiary`. 섹션 레이블.
- `Readout` — 수치 + 단위 쌍. `value`가 `valid: false`면 `—`를 그린다. 0으로 대체하지 않는다.
- `Divider` — 1px `borderSubtle`.

### `EmptyState`
```
title: string       // "지도 공급자 연결 전"
detail: string      // 연결되면 무엇이 보이는지
icon: string
action: string      // 선택. 복구 동작이 있을 때만
```
Provider `connected == false`인 모든 영역이 쓴다. 빈 패널을 그대로 두지 않는다.

## Control

| 컴포넌트 | 높이 | 규격 |
| --- | --- | --- |
| `OasButton` | 56 / 72 | `variant`: primary(accent 배경, accentHi 텍스트) · secondary(surfaceAlt) · ghost(투명 + borderStrong) · danger(critical). `enabled=false`면 `textDisabled` + `lockReason` 툴팁. |
| `OasIconButton` | 56 / 72 / 96 | 정사각. `badge: int` 선택. hit area 최소 48 보장. |
| `OasToggle` | 행 48, 트랙 72×40 | knob 32. on이면 트랙 `accent`, knob `accentHi`. 전환 `mFast`. 레이블 전체가 hit area. |
| `OasSlider` | 트랙 56 | 트랙 `surfaceAlt` `rLg`, 채움 `accent`. 핸들 없이 **채움 막대 전체를 드래그**한다 — 주행 중 정밀 조준 불필요. `step` 지원. 값은 우측에 `Readout`. |
| `OasSegmented` | 56 | 2–5 세그먼트. 선택 배경 `surfaceRaised` + border `accent`. 선택 인디케이터 이동 `mBase`. |
| `OasStepper` | 72 | `−` `값` `+`. − 와 + 사이 간격 `s4`. 길게 누르면 250ms 후 반복. |

## Navigation & Shell

### `ControlDock`
Floating. 하단 margin `s5`, 높이 breakpoint별 80/88/96. `rDock`. Level 3.
8개 항목 균등 분할, 각 항목 = 아이콘 `iconLg` + 레이블 `label`. 선택 항목은 `accentWash` 배경 + `accent` 아이콘 + `textPrimary` 레이블.
선택 인디케이터는 `mBase` OutCubic으로 이동한다. 항목 자체는 이동하지 않는다.

### `StatusRail`
상단 56(ultrawide 64). 배경 없음(투명). 좌: 시각·연결 상태. 중앙: 제품 마크. 우: SYNTHETIC 배지·실외 온도·테마 토글.
**어떤 화면도 Status Rail을 덮지 않는다.**

### `SidePanel`
우측 slide-over. 폭 420(compact 360). 진입 `mSlow` InOutCubic. 바깥 탭으로 닫힘. 주행 중에는 열리지 않는다.

### `OasModal`
중앙. 폭 최대 560. scrim `rgba(0,0,0,0.6)`. **주행 중에는 안전 경고만 modal로 띄운다.** 확인 버튼은 `touchLarge`.

## Status & Feedback

### `StatusBadge`
```
text: string
tone: color     // accent | warning | critical | success | info | textTertiary
```
`rPill`, 높이 34, 배경 tone 12%, border tone 25%, 텍스트 tone. `caption` 토큰.

### `VehicleStatusIndicator`
차량 실루엣 주변의 상태 점 클러스터. 도어 4, 트렁크, 후드, 안전벨트 4, 타이어 4.
```
items: [{ id, label, state, valid }]
// state: ok | open | warn | critical
```
`valid == false`인 항목은 회색 외곽선만 그리고 채우지 않는다 — "정상"으로 오인시키지 않는다.

### `Toast`
Dock 위 중앙. 폭 auto(최대 480), 높이 56. 3000ms 후 자동 소멸. 진입/퇴장 `mBase` fade + 8px 상승.
조작을 가리지 않으며 탭으로 즉시 닫힌다. **안전 정보는 Toast로 전달하지 않는다.**

### `NotificationItem`
목록 행. 높이 72. 아이콘 + 제목(`bodyMd`) + 시각(`caption`). 미확인은 좌측 3px `accent` 바.

### `CriticalOverlay`
전면. `critical` 12% 배경 + 상단 4px `critical` 바. 아이콘 + 사유 + 해제 조건.
닫기 버튼 없음. 조건 해제로만 사라진다. 출현은 `mInstant`(지연 없음), 소멸은 `mBase` fade.

## Domain

### `VehicleVisual`
차량 3/4 후면 실루엣. **장식이 아니라 상태 표면이다.**
```
gear, steeringAngle, doorStates[], trunkOpen, hoodOpen
turnSignal: none|left|right|hazard
lightsOn, charging, driving, adasActive
lanes: bool          // AdasProvider 연결 시
surroundings: []     // AdasProvider 연결 시
parkingSensors: []   // CameraProvider 연결 시
```
반응 규칙:
- 도어 열림 → 해당 패널이 `warning` 외곽선 + 12px 바깥으로 열리는 `mSlow` 전환
- 방향지시등 → 해당 인디케이터 `warning` 500ms 점멸 (법규 표현이므로 반복 애니메이션 예외)
- 충전 → 배터리 아이콘 채움 상승 반복 (허용된 유일한 loop)
- 주행 → 하단 노면 그리드가 속도 비례로 흐름. `speedValid == false`면 정지.
- 조향 → 앞바퀴 각도 반영, 최대 ±35°, `mBase`
- `valid == false`인 신호는 기본 상태로 그리되, 그 위에 dot indicator를 그리지 않는다.

### `ClimateControl`
듀얼존 온도. 각 존은 `displayMd` 온도 + 세로 드래그 영역(높이 `touchLarge` × 3).
**드래그 우선**: 영역 전체를 위/아래로 끌어 0.5°씩 변경. −/+ 버튼은 보조로 좌우 끝에 둔다.
하단에 팬(`OasSlider`), 시트 열선·통풍(`OasSegmented` 0–3), 디프로스트(`OasToggle` ×2), SYNC, AUTO.

### `MediaMiniPlayer`
높이 96. 아트 72×72 `rLg` + 트랙(`bodyLg`) + 아티스트(`label`) + `prev` `play/pause` `next` (`touchLarge`).
**이 6개 외 아무것도 넣지 않는다.** 확장은 탭으로 Media 화면 진입.

### `MediaExpanded`
아트 대형 + 진행 `OasSlider` + 플레이리스트 + 소스 `OasSegmented` + 사운드 설정. Media 화면 전용.

### `NavInstruction`
Turn arrow(`iconXl`) + 거리(`displaySm`) + 도로명(`bodyLg`) + 보조 안내(`label`).
지도 위 overlay로 배치한다. 카드 배경은 `surface` 88% 1겹만 쓴다.

### `MapSurface`
지도 표면. 연결 전에는 `EmptyState`. 연결 시 전체를 채우고 UI는 overlay로만 올린다.
**지도 위에 카드를 쌓지 않는다.** overlay 최대 4개: 안내(좌상), 요약/ETA(좌하), 충전·POI(우상), 재중심 버튼(우하).

### `CategoryTile`
Vehicle 허브의 2차 목적지 타일. 높이 ≥ 140. 아이콘 `iconXl` + 제목(`bodyLg`) + 현재 값 요약(`label`).
잠긴 항목은 `textDisabled` + 사유 캡션. 숨기지 않는다.

## 컴포넌트 검사

- [ ] 모든 컴포넌트가 `Tokens`만 참조한다.
- [ ] 모든 조작 요소가 `Accessible.name`을 가진다.
- [ ] 모든 조작 요소가 `activeFocus`에서 `accent` 외곽선을 보인다.
- [ ] 값 표시 컴포넌트가 `valid: false`에서 `—`를 그린다.
- [ ] 반복 애니메이션은 충전 표시와 방향지시등 두 곳뿐이다.
