# OAS Automotive OS — Design Tokens

시스템 이름은 **Grid**다. 떠 있는 카드가 아니라 **맞닿는 셀과 1px 규칙선**으로 화면을 구성한다. 반경 0, 그림자 없음, blur 없음. 강조는 대비와 굵기로 만들고, **색은 안전 상태에만 남긴다.**

구현: `apps/hmi/qml/Tokens.qml` (singleton). **다른 QML 파일은 색·duration·터치 치수를 직접 쓰지 않는다.**

## 1. Color

### 1.1 Light — 기본 테마

| Token | Value | 용도 |
| --- | --- | --- |
| `bg` | `#EDEDEB` | 화면 바탕. 셀 사이로 비치지 않는 최하위 레이어 |
| `surface` | `#F4F4F2` | 셀 |
| `surfaceAlt` | `#E4E4E0` | 눌린 셀, 입력 트랙, 지도·차량 지면 |
| `surfaceInk` | `#DCDCD7` | 차트 빈 막대, 미터 트랙 |
| `line` | `#D6D6D2` | **그리드의 모든 구분선** |
| `lineStrong` | `#B9B9B3` | 주요 영역 경계, 고스트 컨트롤 외곽 |
| `ink` | `#111111` | 값, 제목, 활성 채움 |
| `inkSecondary` | `#6E6E68` | 라벨, 보조 설명 |
| `inkTertiary` | `#9A9A93` | 캡션, 불명 상태 |
| `inkDisabled` | `#BEBEB7` | 잠긴 컨트롤 |
| `onInk` | `#F4F4F2` | **잉크 채움 위의 텍스트·아이콘** |

### 1.2 Dark — 야간

| Token | Value |
| --- | --- |
| `bg` | `#0E0E0D` |
| `surface` | `#161615` |
| `surfaceAlt` | `#201F1E` |
| `surfaceInk` | `#2C2B29` |
| `line` | `#2A2A28` |
| `lineStrong` | `#43423F` |
| `ink` | `#F2F2F0` |
| `inkSecondary` | `#A3A29B` |
| `inkTertiary` | `#77776F` |
| `inkDisabled` | `#4E4E48` |
| `onInk` | `#0E0E0D` |

**Light가 기본이다.** Dark는 같은 그리드 언어의 반전이며 명암 역할만 뒤집는다. 자동 모드는 차량의 `nightMode` 신호를 우선하고, 신호가 없으면 Light를 유지한다.

### 1.3 Safety — 시스템에 남은 유일한 색

| Token | Light | Dark | 의미 |
| --- | --- | --- | --- |
| `warning` | `#9A5B00` | `#E2A244` | 주의. 주행 계속 가능 |
| `critical` | `#B3261E` | `#F2635A` | 즉시 대응. 주행 위험 |
| `success` | `#2E6B4F` | `#5BC08D` | 정상·허용·활성 완료 |

**색이 보이면 그것은 안전 정보다.** 브랜드 강조, 선택 상태, 장식에 색을 쓰지 않는다. 선택은 `ink` 채움으로 표현한다.

### 1.4 Illustration

차량·지도 표면의 재질색은 `Tokens`의 illustration 섹션을 경유한다: `ground` `videoInk` `glazing` `bodyHigh/Mid/Low` `doorPanel` `tyre` `mapBlock` `mapRoad`. UI chrome이 아니라 렌더링 재료이므로 분리해 둔다.

### 1.5 색 사용 규칙

- 색만으로 정보를 전달하지 않는다. 상태 색에는 항상 텍스트 또는 형태 차이를 동반한다.
- 지도 정체 구간은 색 + **끊긴 선 텍스처**로 이중 표현한다.
- 유효하지 않은 신호는 채우지 않고 **외곽선**으로 그린다. "불명"이 "정상"으로 보이면 안 된다.
- `MeterBar`의 투영 구간은 **사선 해칭**이다. 측정값과 예측값이 같은 채움으로 보이면 안 된다.

## 2. Typography

시스템 sans-serif. 데이터는 **DemiBold**, 라벨은 **문장형 소문자 회색**이다. 대문자 변환과 자간 확대를 쓰지 않는다.

| Token | Size | Weight | 용도 |
| --- | --- | --- | --- |
| `dataHero` | 118 | DemiBold | 에너지 잔량 등 화면 대표 수치 |
| `dataXl` | 72 | DemiBold | 공조 온도, 크루즈 설정 속도 |
| `dataLg` | 46 | DemiBold | 주 메트릭 값, 다음 안내 거리 |
| `dataMd` | 32 | DemiBold | 보조 메트릭 값 |
| `titleLg` | 30 | DemiBold | 차량명, 트랙명 |
| `titleMd` | 22 | DemiBold | 섹션 제목, 모달 제목 |
| `bodyLg` | 19 | Medium | 주 조작 레이블 |
| `bodyMd` | 17 | Regular | 본문, 목록 항목, 버튼 |
| `label` | 15 | Regular | 보조 정보 |
| `caption` | 13 | Regular | 셀 라벨, 변화량, 단위 |

수치 옆 단위는 baseline을 맞추고 값의 약 52% 크기로 둔다. **13px 미만을 쓰지 않는다.**

`typeScale`은 breakpoint에 따라 0.84 / 1.0 / 1.06 / 1.10이며, `caption`만 13px로 고정한다.

## 3. Space

4px base grid. `s1` 4 · `s2` 8 · `s3` 12 · `s4` 16 · `s5` 24 · `s6` 32 · `s7` 40 · `s8` 64.

`cellPadding`은 compact 16, 그 외 24다. **화면 외곽 여백은 0이다** — 그리드가 가장자리까지 간다.

## 4. Radius

`radius` = **0**. 예외 없다. 구분은 선이 하고 모서리는 하지 않는다.

## 5. Rule

`hairline` = 1px. 그리드는 `GridBoard`가 만든다 — 보드를 `line` 색으로 칠하고 셀을 1px 간격으로 올린다. 따라서 **모든 구분선이 정확히 1px이고, 셀은 자기 위치를 알 필요가 없다.**

## 6. Touch Target

`touchMin` 48 · `touchBase` 56 · `touchLarge` 72 · `touchHero` 96.

시각 크기가 48px 미만인 아이콘 버튼은 투명 hit area를 확장한다. 인접한 반대 동작 사이 최소 간격은 `s4`(16px)다.

## 7. Motion

| Token | ms | Easing | 용도 |
| --- | --- | --- | --- |
| `mInstant` | 0 | — | 안전 경고 출현 |
| `mFast` | 120 | OutCubic | press, 토글 knob, 세그먼트 |
| `mBase` | 180 | OutCubic | 값 변경, 색 전환, 런처 메뉴 |
| `mSlow` | 260 | InOutCubic | 화면 전환, 사이드 패널, 도어 |

**260ms를 넘는 전환을 만들지 않는다.** 반복 애니메이션은 **충전 채움(1400ms)** 과 **방향지시등(500ms)** 두 곳뿐이다. 둘 다 의미를 가진 움직임이다.

## 8. Elevation

**없다.** 그림자도 blur도 쓰지 않는다. 레이어는 `line`과 `surface`/`bg` 대비로만 표현한다. 런처 메뉴와 모달은 `scrim`(light 22%, dark 55%)으로 뒤를 눌러 분리한다.

## 9. Icon

`iconSm` 18 · `iconMd` 22 · `iconLg` 28 · `iconXl` 40.

24×24 그리드, **1.6px stroke, round cap/join, fill 없음.** 활성은 `ink`로 바꾸고 굵기를 2.1px로 올린다. 채우기로 활성을 표현하지 않는다.

## 10. Breakpoint

| Token | 조건 | 메트릭 열 |
| --- | --- | --- |
| `compact` | `width < 1600` | 2 |
| `regular` | `1600–2299`, aspect < 2.2 | 4 |
| `wide` | `2300–3199`, aspect < 2.6 | 4 |
| `ultrawide` | `width ≥ 3200` 또는 aspect ≥ 2.6 | 6 |

검증 해상도: 1280×720 · 1920×1080 · 2560×1440 · 3840×1200.

## 11. 토큰 적용 검사

- [ ] QML 어디에도 `#RRGGBB` 리터럴이 없다 (`Tokens.qml` 제외).
- [ ] 반경을 쓰는 곳이 없다.
- [ ] `accent`라는 개념이 없다. 선택은 `ink` 채움이다.
- [ ] 색이 쓰인 곳은 전부 안전 의미를 가진다.
- [ ] 조작 가능한 모든 항목의 높이 ≥ 48.
- [ ] 모든 전환 `duration ≤ 260`. 예외는 충전(1400ms)과 방향지시등(500ms)뿐이다.
- [ ] 모든 텍스트의 `font.pixelSize ≥ 13`.
- [ ] 레이아웃 안의 자식에 `anchors`를 걸지 않는다 (`Cell.overlay` 슬롯 사용).
