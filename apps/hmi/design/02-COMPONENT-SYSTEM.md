# OAS Automotive OS — Component System

화면보다 먼저 존재한다. 화면은 컴포넌트를 조합할 뿐이며, 두 화면 이상에서 필요해질 때만 새 컴포넌트를 만든다.

모든 컴포넌트는 [Design Tokens](01-DESIGN-TOKENS.md)만 참조하고 차량 상태를 직접 읽지 않는다 — 값은 property로 주입받는다. 이것이 UI State / Vehicle State 분리의 컴포넌트 수준 구현이다.

## Foundation

### `Tokens` (singleton)
색·타이포·간격·모션·breakpoint의 단일 공급원. `dark`, `viewportWidth`, `viewportHeight` 세 개만 가변이며 나머지는 파생된다.

### `GridBoard`
**그리드를 만드는 유일한 장소다.** 보드를 `line` 색으로 칠하고 그 위에 셀을 1px 간격·1px 여백으로 올린다. 결과적으로 모든 구분선이 정확히 1px이고, 셀은 자기가 몇 번째 열인지 알 필요가 없다.

```
GridBoard { columns: 4 ; Cell {...} Cell {...} ... }
```

### `Cell`
그리드의 한 칸. `surface` 배경, 반경 0, 패딩 `cellPadding`.
기본 슬롯은 세로 ColumnLayout이다. **셀 전체를 덮는 요소(포커스 링, hit area)는 `overlay` 슬롯에 넣는다** — 레이아웃 안에서 `anchors`를 쓰면 동작이 정의되지 않고 실제로 화면이 무너진다.

### `Metric`
**시스템 전체가 이 단위로 만들어진다.** 작은 회색 문장형 라벨 + 우측 변화량 + 굵은 값 + 그 아래 차트 자리.
```
label · delta · deltaTone · value · unit · valid · valueTone · valueSize
```
남는 높이는 값 **아래**로 모이므로, 짧은 셀과 긴 셀이 같은 상단 기준선에서 읽힌다. 호출자가 추가한 차트는 그 뒤에 붙어 셀 하단에 앉는다.
`valid == false`면 `—`를 그린다. 0이나 마지막 값으로 대체하지 않는다.

### `Caption` / `Divider`
- `Caption` — 13px, 문장형, `inkSecondary`. 대문자 변환·자간 확대 없음.
- `Divider` — 1px `line`.

### `BarSeries`
평평한 막대 열. `highlight` 인덱스 하나만 `ink`로 칠하고 나머지는 `surfaceInk`. 축도 격자도 없다 — 셀의 행이 이미 구조를 제공한다.

### `MeterBar`
채워진 구간 + **사선 해칭 투영 구간** + 목표 눈금.
해칭이 예측을 사실로 읽히지 않게 막는 장치다. 해칭을 생략하지 않는다.

### `EmptyState`
Provider `connected == false`인 모든 영역이 쓴다. 무엇을 기다리는지 항상 말한다. 빈 셀을 그대로 두지 않는다.

### `Icon`
Canvas 기반 line icon. software renderer와 임베디드 GPU가 동일하게 그린다. 활성은 stroke를 `ink`로 바꾸고 굵기만 올린다.

## Control

| 컴포넌트 | 높이 | 규격 |
| --- | --- | --- |
| `OasButton` | 56 / 72 | `variant`: primary(`ink` 채움 + `onInk`) · secondary(`surfaceAlt`) · ghost(투명 + `lineStrong` 외곽) · danger. 반경 0. `enabled=false`면 `lockReason` 표시. |
| `OasIconButton` | 48 / 56 / 72 / 96 | 정사각. `active`면 `ink` 채움. `badge: int` 선택. hit area 최소 48 보장. |
| `OasToggle` | 행 48, 트랙 64×32 | knob 24 정사각. on이면 트랙 `ink`, knob `onInk`. 레이블 전체가 hit area. |
| `OasSlider` | 56 / 72 | 트랙 `surfaceAlt`, 채움 `ink`. **핸들 없이 채움 막대 전체를 드래그**한다. 라벨은 채움 위에 `onInk`로, 값은 트랙 우측에 `ink`로 둔다. |
| `OasSegmented` | 56 | 2–5 세그먼트. 세그먼트 사이는 1px `line`. 선택은 `ink` 채움 + `onInk` 텍스트. |
| `TabRow` | 48 | 텍스트 전용 탭. 선택은 `ink` + DemiBold. 알약도 밑줄도 상자도 없다. |
| `TempZone` | `touchLarge`×3 | 세로 드래그로 0.5°씩. −/+ 는 하단 양끝의 보조 경로. |

## Shell

### `TopBar`
상단 72(compact 64). 제품 마크(4분할 체커) · 현재 화면명 · 연결 상태 · SYNTHETIC · 실외 온도 · 시각 · 테마 토글. 하단에 1px `line`.
**어떤 화면도 TopBar를 덮지 않는다.**

### `Launcher`
**시스템의 유일한 내비게이션.** 좌측 하단 버튼 하나이며, 항상 현재 화면명을 표시한다. 누르면 `LauncherMenu`가 펼쳐진다.
열려 있으면 버튼이 `ink`로 반전된다.

### `LauncherMenu`
런처 위로 펼쳐지는 전체 목적지 격자(`Nav.all` 12개, compact 3열 / 그 외 4열). 타일 높이 ≥ 120.
- 현재 화면 타일은 `ink` 채움.
- 주행 중 잠긴 목적지는 흐리게 + **사유 표시**. 제거하지 않는다.
- scrim 바깥 탭 또는 `Esc`로 닫는다.
- 진입은 `mBase` 상승 + fade.

이 구조는 목적지 도달을 1터치에서 2터치로 늘린다. 대신 화면이 분할되지 않고, 메뉴 타깃이 크며, 어디에 있는지 항상 라벨로 보인다.

### `SidePanel`
우측 slide-over. 폭 440(compact 380). `mSlow` InOutCubic. 좌측 경계에 1px `lineStrong`.
**위치는 `x`만으로 제어한다** — `anchors.right`를 걸면 열린 상태로 고정된다.

### `OasModal`
중앙. 폭 최대 620. scrim. **주행 중에는 안전 경고만 modal로 띄운다.**

## Status & Feedback

### `StatusBadge`
8px 정사각 마크 + 단어. 알약도 배경 블록도 없다. 색은 안전 의미일 때만 쓴다.

### `VehicleStatusIndicator`
코너 단위 상태 점 묶음. `valid == false`인 항목은 채우지 않고 외곽선만 그린다.

### `Toast`
런처 위 중앙. `ink` 채움 + `onInk` 텍스트. 3000ms 후 소멸. 탭으로 즉시 닫힘.
**안전 정보는 Toast로 전달하지 않는다.**

### `NotificationItem`
목록 행 72. 미확인은 좌측 3px 바.

### `CriticalOverlay`
TopBar 아래 전폭 밴드. 좌측 8px 세로 바가 경보이고 패널 자체는 평범하게 둔다.
닫기 버튼 없음. 조건 해제로만 사라진다. 출현은 `mInstant`, 소멸만 `mBase` fade.

### `CategoryTile`
Vehicle 허브 항목. `Cell` 기반. 아이콘 + chevron 행, 제목, 요약 순으로 상단 정렬.
잠긴 항목은 `inkDisabled` + 사유. 숨기지 않는다.

## Domain

### `VehicleVisual`
탑뷰 차량 상태 표면. **장식이 아니라 상태 표면이다.** 평평한 모노크롬으로 그린다.

반응 규칙:
- 도어 열림 → 해당 패널이 `warning`으로 채워지고 30° 열린다 (`mSlow`)
- 안전벨트 → 정사각 마크. 미착용은 `critical` + ✕. **불명은 외곽선만**
- 방향지시등 → 500ms 점멸 (법규 표현이므로 예외)
- 충전 → 배터리 채움 상승 반복 (허용된 유일한 loop)
- 주행 → 노면 규칙선이 속도 비례로 흐름. `speedValid == false`면 정지
- 조향 → 앞바퀴 각도 반영, 최대 ±35°

보드는 차선·주변 차량이 있을 때만 3차로 폭으로 넓어지고, 없으면 차체 바운딩 박스로 좁혀 차를 크게 그린다.

**매 프레임 움직이는 요소는 전부 QML 아이템이다.** Canvas는 차량 신호가 바뀔 때만 다시 그리고 타이머로는 절대 그리지 않는다 — software renderer와 임베디드 GPU의 프레임 예산을 같게 유지하기 위한 조건이다.

### `MapSurface`
지도 표면. 연결 전에는 `EmptyState`. 연결 시 전체를 채우고 UI는 overlay로만 올린다.
**지도 위에 카드를 쌓지 않는다.** overlay 최대 4개: 안내(좌상), 요약(좌하), POI(우상), 목적지 입력(우하).

### `MediaMiniPlayer`
아트 · 트랙 · 아티스트 · prev/play/next. **이 6개 외 아무것도 넣지 않는다.**
폭 420 미만이면 skip 버튼을, 360 미만이면 아트를 접는다. 트랙명이 0px로 눌리지 않게 하기 위한 조건이다.
**재생 중일 때만 하단에 나타난다.** 런처는 행에 그대로 남으므로 화면 내용이 가려지지 않는다.

### `NavInstruction`
Turn arrow + 거리 + 도로명 + 보조. 지도 위 단일 레이어로 올린다.

## 컴포넌트 검사

- [ ] 모든 컴포넌트가 `Tokens`만 참조한다.
- [ ] 레이아웃 자식에 `anchors`가 없다 (`Cell.overlay` 사용).
- [ ] 모든 조작 요소가 `Accessible.name`을 가진다.
- [ ] 모든 조작 요소가 `activeFocus`에서 `ink` 외곽선을 보인다.
- [ ] 값 표시 컴포넌트가 `valid: false`에서 `—`를 그린다.
- [ ] 반복 애니메이션은 충전과 방향지시등 두 곳뿐이다.
- [ ] Positioner를 상속한 컴포넌트에 `implicitWidth/Height`를 대입하지 않는다 (read-only).
