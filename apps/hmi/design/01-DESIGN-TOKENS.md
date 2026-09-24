# OAS Automotive OS — Design Tokens

구현: `apps/hmi/qml/Tokens.qml` (singleton). **QML에 hex 리터럴·매직 넘버를 직접 쓰지 않는다.** 모든 값은 이 토큰을 경유한다.

## 1. Color

### 1.1 Palette — Dark (기본 테마)

| Token | Value | 용도 |
| --- | --- | --- |
| `bg` | `#0B0C0E` | 화면 바탕. 유일한 최하위 레이어. |
| `surface` | `#16181C` | Panel, Dock, Card |
| `surfaceAlt` | `#202329` | Panel 내부 구획, 입력 트랙, 비활성 세그먼트 |
| `surfaceRaised` | `#2A2E36` | hover, 선택된 세그먼트, 슬라이더 핸들 |
| `borderSubtle` | `#24272E` | Panel 외곽 1px |
| `borderStrong` | `#363B44` | 구획선, 비활성 컨트롤 외곽 |
| `textPrimary` | `#FFFFFF` | 값, 제목 |
| `textSecondary` | `#A5A7AB` | 레이블, 보조 설명 |
| `textTertiary` | `#6E7176` | 캡션, 단위 |
| `textDisabled` | `#4A4D53` | 잠긴 컨트롤 |

### 1.2 Palette — Light (정차 중 선호)

| Token | Value |
| --- | --- |
| `bg` | `#F2F3F5` |
| `surface` | `#FFFFFF` |
| `surfaceAlt` | `#E9EBEE` |
| `surfaceRaised` | `#DDE0E4` |
| `borderSubtle` | `#E2E5E9` |
| `borderStrong` | `#C9CDD3` |
| `textPrimary` | `#101215` |
| `textSecondary` | `#5A5E66` |
| `textTertiary` | `#7E838B` |
| `textDisabled` | `#B0B4BA` |

### 1.3 Accent — Genesis Copper

| Token | Dark | Light | 용도 |
| --- | --- | --- | --- |
| `accent` | `#C08B5C` | `#8A6039` | 활성 상태, 선택, 강조 값, 진행률 |
| `accentHi` | `#E8C39E` | `#C08B5C` | 활성 위의 텍스트·아이콘, 최상위 강조 |
| `accentDeep` | `#7A5433` | `#5E3F24` | 진행률 트랙의 채워진 하단, 그라디언트 끝 |
| `accentWash` | `rgba(192,139,92,0.12)` | `rgba(138,96,57,0.10)` | 선택 배경, 활성 타일 |

Copper는 **활성·선택·강조**에만 쓴다. 경고 의미를 갖지 않는다. 화면 한 곳에서 Copper가 차지하는 면적은 stage 면적의 10%를 넘지 않는다.

### 1.4 Semantic

| Token | Dark | Light | 의미 |
| --- | --- | --- | --- |
| `warning` | `#F2A93B` | `#B97708` | 주의 필요. 주행 계속 가능. |
| `critical` | `#E5484D` | `#C62A2F` | 즉시 대응. 주행 위험. |
| `success` | `#4CC38A` | `#1F8F5B` | 정상·허용·활성 완료 |
| `info` | `#7FA8C9` | `#41688A` | 중립 안내 |
| `warningWash` / `criticalWash` / `successWash` | 각 색 12% alpha | 동일 | 배지·배너 배경 |

`warning`(amber)과 `accent`(copper)는 색상환에서 인접하다. **두 색을 같은 시각적 그룹 안에 동시에 배치하지 않는다.** 경고 배지가 있는 타일은 accent 강조를 해제한다.

### 1.5 색 사용 규칙

- 색만으로 정보를 전달하지 않는다. 상태 색에는 항상 텍스트 또는 아이콘 형태 차이를 동반한다.
- `textPrimary` 대비는 dark에서 18.1:1, light에서 17.4:1. `textSecondary`는 각각 7.2:1, 6.1:1 — 모두 WCAG AA 이상.
- `textTertiary`는 13px 캡션 전용이며 조작 대상 텍스트에 쓰지 않는다.
- Blur/Glass는 Dock과 Critical Overlay **두 곳에만** 쓴다. 임베디드 GPU와 software renderer에서 동일하게 보이도록 blur 대신 `surface` + 1px border + 미세 그라디언트로 구현한다.

## 2. Typography

시스템 sans-serif. 숫자는 항상 tabular (`font.features: { "tnum": 1 }`).

| Token | Size | Weight | Letter | 용도 |
| --- | --- | --- | --- | --- |
| `speedHero` | 140 | Light (300) | -3 | Home 중앙 속도 |
| `speedLarge` | 104 | Light | -2 | compact 속도, Energy 잔량 |
| `displayMd` | 72 | Light | -1.5 | Climate 온도, 화면 대표 수치 |
| `displaySm` | 48 | Light | -1 | 타일 대표 수치 |
| `titlePage` | 32 | Medium (500) | -0.2 | 화면 제목 |
| `titleSection` | 24 | Medium | 0 | 패널 제목 |
| `bodyLg` | 20 | Medium | 0 | 주 조작 레이블, 버튼 |
| `bodyMd` | 18 | Regular (400) | 0 | 본문, 목록 항목 |
| `label` | 15 | Medium | 0.2 | 보조 정보, 컨트롤 레이블 |
| `caption` | 13 | Medium | 1.6 | 섹션 캡션 (UPPERCASE), 단위 |

**13px 미만을 쓰지 않는다.** 주행 중 읽어야 하는 값은 `bodyLg` 이상이다.

수치와 단위는 baseline을 맞추고 단위는 한 단계 아래 토큰 + `textTertiary`를 쓴다 (`87` `km/h`).

## 3. Space

4px base grid.

| Token | px | 용도 |
| --- | --- | --- |
| `s1` | 4 | 아이콘-텍스트 간격 |
| `s2` | 8 | 밀접 요소 |
| `s3` | 12 | 컨트롤 내부 패딩 |
| `s4` | 16 | 기본 간격 |
| `s5` | 24 | Panel 내부 패딩, 컴포넌트 간격 |
| `s6` | 32 | 화면 외곽 여백 (regular) |
| `s7` | 40 | 화면 외곽 여백 (wide/ultrawide) |
| `s8` | 64 | 대형 구획 |

Grid: 12 column. gutter `s5`(24). margin은 breakpoint별 `s6`/`s7`. compact은 `s5`(24).

## 4. Radius

| Token | px | 용도 |
| --- | --- | --- |
| `rSm` | 10 | 배지, 소형 칩 |
| `rMd` | 16 | 버튼, 세그먼트 |
| `rLg` | 22 | Tile, 입력 트랙 |
| `rXl` | 28 | Panel |
| `rDock` | 30 | Control Dock |
| `rPill` | 999 | Toggle, StatusBadge |

## 5. Touch Target

| Token | px | 규칙 |
| --- | --- | --- |
| `touchMin` | 48 | **절대 하한.** 모든 조작 가능 요소. |
| `touchBase` | 56 | 기본 버튼, 목록 행 |
| `touchLarge` | 72 | 주행 중 빈번 조작 (온도, 팬, 재생) |
| `touchHero` | 96 | Dock 항목, Camera 뷰 전환 |

시각적 크기가 `touchMin` 미만인 아이콘 버튼은 투명 hit area를 확장해 48px를 확보한다.

인접한 서로 다른 동작 사이의 최소 간격은 `s2`(8px)다. 온도 −/+ 처럼 반대 동작이 인접하면 `s4`(16px)를 쓴다.

## 6. Motion

| Token | ms | Easing | 용도 |
| --- | --- | --- | --- |
| `mInstant` | 0 | — | 안전 경고 출현. 지연 없음. |
| `mFast` | 150 | OutCubic | 버튼 press, 토글 knob, hover |
| `mBase` | 200 | OutCubic | 선택 이동, 값 변경, 색 전환 |
| `mSlow` | 300 | InOutCubic | 화면 전환, 패널 slide, 모달 |

**300ms를 넘는 애니메이션을 만들지 않는다.** 반복(loop) 애니메이션은 충전 진행 표시 **하나만** 허용한다. 장식 목적의 pulse·shimmer·parallax는 금지한다.

차량 시각화의 상태 변화(도어 열림, 방향지시등)는 `mBase` fade 또는 위치 이동으로만 표현한다.

## 7. Elevation

다크 배경에서 그림자는 보이지 않는다. **레이어는 surface 단계와 border로 표현한다.**

| Level | 구성 |
| --- | --- |
| 0 | `bg` |
| 1 | `surface` + `borderSubtle` 1px |
| 2 | `surfaceAlt` + `borderStrong` 1px |
| 3 (Dock / Modal) | `surface` + `borderStrong` 1px + 상단 3% 화이트 그라디언트 |

Light 테마에서만 level 3에 `0 2px 12px rgba(16,18,21,0.08)` 그림자를 허용한다.

## 8. Icon

| Token | px | 용도 |
| --- | --- | --- |
| `iconSm` | 20 | 인라인, 배지 |
| `iconMd` | 24 | 버튼, 목록 |
| `iconLg` | 32 | Dock, 타일 |
| `iconXl` | 48 | 카테고리 타일, Turn arrow |

스타일: **1.75px stroke, round cap/join, fill 없음.** 24×24 그리드에서 설계하고 배율로 확대한다. 활성 상태는 stroke를 `accent`로 바꾸고 굵기를 2.25px로 올린다. 채우기로 활성을 표현하지 않는다.

## 9. Breakpoint

| Token | 조건 |
| --- | --- |
| `compact` | `width < 1600` |
| `regular` | `1600 ≤ width < 2300` 그리고 `aspect < 2.2` |
| `wide` | `2300 ≤ width < 3200` 그리고 `aspect < 2.6` |
| `ultrawide` | `width ≥ 3200` 또는 `aspect ≥ 2.6` |

검증 해상도: 1280×720 · 1920×1080 · 2560×1440 · 3840×1200.

## 10. 토큰 적용 검사

구현이 다음을 만족해야 한다.

- [ ] QML 어디에도 `#RRGGBB` 리터럴이 없다 (`Tokens.qml` 제외). 차량·지도 일러스트의 재질색도 `Tokens`의 illustration 섹션을 경유한다.
- [ ] 조작 가능한 모든 항목의 `implicitHeight ≥ 48`.
- [ ] 모든 전환 `Behavior`/`Animation`의 `duration ≤ 300`. 예외는 Interaction Spec이 허용한 충전 채움(1400ms)과 방향지시등(500ms) 두 곳뿐이다.
- [ ] 모든 텍스트의 `font.pixelSize ≥ 13`.
- [ ] 1280×720과 3840×1200 양쪽에서 Dock과 주요 조작이 스크롤 없이 보인다.
