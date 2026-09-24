# OAS Automotive OS — Interaction & Animation Specification

## 1. Interaction 원칙

| 규칙 | 근거 |
| --- | --- |
| 주요 기능은 2 touch 이내 | Dock 1 touch + 화면 내 1 touch. 3단계 depth를 만들지 않는다. |
| Modal 최소화 | 주행 중 modal은 안전 경고만. 그 외는 SidePanel 또는 인라인 확장. |
| Scroll 최소화 | 각 화면의 기본 조작은 스크롤 없이 보인다. 스크롤은 목록형(플레이리스트·통화기록·진단)에만 허용. |
| 주행 중 텍스트 입력 금지 | 목적지·검색은 음성/즐겨찾기/최근으로 대체. 키보드를 띄우지 않는다. |
| 즉각 시각 피드백 | 모든 press는 150ms 이내에 시각 변화가 시작된다. |
| 되돌릴 수 있게 | 파괴적 동작(업데이트 설치, 초기화)만 확인을 요구한다. 그 외는 확인 없이 실행하고 Toast로 알린다. |

## 2. Touch / Gesture

| 제스처 | 사용처 | 비사용 |
| --- | --- | --- |
| Tap | 모든 주 조작 | — |
| Vertical drag | 온도, 팬, 볼륨, 밝기 | 화면 전환 |
| Horizontal drag | 진행바 seek, 카메라 뷰 전환 | 화면 전환 |
| Long press (250ms) | Stepper 반복, 즐겨찾기 등록 | 숨은 기능 |
| Swipe | — | **쓰지 않는다.** 주행 중 오조작과 발견 가능성 문제. |
| Pinch | 지도 확대만 | 그 외 전부 |

Dock 항목 사이의 swipe 전환을 제공하지 않는다. 화면 전환은 명시적 tap만이다.

## 3. Animation

전 구간 `duration ≤ 300ms`. 모든 값은 [Design Tokens §6](01-DESIGN-TOKENS.md#6-motion)에서 온다.

| 전환 | Duration | Easing | 속성 |
| --- | --- | --- | --- |
| 화면 전환 | 300 | InOutCubic | opacity 0→1 + y +12→0 |
| Dock 선택 인디케이터 | 200 | OutCubic | x, width |
| 버튼 press | 150 | OutCubic | scale 1→0.97, color |
| Toggle knob | 150 | OutCubic | x, track color |
| Slider 값(외부 변경) | 200 | OutCubic | 채움 width |
| Slider 값(드래그 중) | 0 | — | 손가락 추종. 애니메이션 금지. |
| Segmented 인디케이터 | 200 | OutCubic | x |
| SidePanel | 300 | InOutCubic | x |
| Modal | 200 | OutCubic | opacity + scale 0.96→1 |
| Toast | 200 | OutCubic | opacity + y |
| 수치 변경 (속도·온도) | 200 | OutCubic | 숫자 색 flash 없음. 값만 교체. |
| Critical 경고 출현 | **0** | — | 지연 없음 |
| Critical 경고 소멸 | 200 | OutCubic | opacity |
| 도어 열림/닫힘 | 300 | InOutCubic | 패널 위치 + 외곽선 색 |
| 조향각 반영 | 200 | OutCubic | 바퀴 rotation |

### 반복 애니메이션 허용 목록

1. **충전 중 배터리 채움** — 1400ms loop. 충전 상태의 유일한 동적 표현.
2. **방향지시등** — 500ms on/off. 법규상 점멸이 의미다.

이 둘 외 어떤 반복 애니메이션도 만들지 않는다. shimmer, pulse, breathing, parallax, 배경 그라디언트 이동 전부 금지한다.

### 성능 제약

임베디드 GPU와 `QT_QUICK_BACKEND=software` 양쪽에서 같은 레이아웃이어야 한다.
- blur shader를 쓰지 않는다 (Dock/Overlay는 surface + border로 표현).
- 동시 진행 애니메이션은 화면당 3개 이하.
- 차량 시각화의 노면 흐름은 30fps 상한으로 제한한다.

## 4. 즉각 피드백 규칙

| 동작 | 피드백 | 시점 |
| --- | --- | --- |
| 온도 변경 | 수치 즉시 갱신 + 존 테두리 `accent` 150ms | 드래그 중 |
| 팬 단계 변경 | 막대 즉시 + Toast 없음 | 즉시 |
| 시트 열선 | 아이콘 단계 색 변경 | 즉시 |
| 도어 잠금 | 차량 시각화 잠금 아이콘 + Toast "전체 잠금" | 200ms 이내 |
| 미디어 재생/정지 | 아이콘 즉시 교체 | 즉시 |
| 잠긴 컨트롤 탭 | 사유 Toast 1회. 컨트롤은 반응하지 않음 | 즉시 |
| 설정 변경 | 화면에 즉시 반영. 저장 버튼 없음 | 즉시 |
| 업데이트 설치 | Modal 확인 → 진행률 | 확인 후 |

명령이 차량에 도달했는지 확인되지 않는 동작은 **"보냄"이 아니라 UI 상태만 바뀌었음**을 표시한다. 현재 설치는 차량 제어 전송이 없으므로 모든 제어는 로컬 UI 상태다.

## 5. 주행 중 잠금 규칙

`driving = speedValid && speed > 3 km/h`

| 대상 | 주행 중 |
| --- | --- |
| 목적지 텍스트 입력 | 잠금. 음성·즐겨찾기·최근만 |
| 전화 다이얼 패드 | 잠금. 최근·즐겨찾기만 |
| 플레이리스트 | 최근 8개로 제한, 스크롤 비활성 |
| Vehicle → Service / Software / Diagnostics | 잠금 |
| Settings 세부 항목 | 표시·오디오만 허용 |
| 영상 재생 surface | **Runtime 정책 결과만 따른다.** HMI는 재판단하지 않는다. |
| Modal | 안전 경고만 |

잠금은 **비활성 + 사유 표시**다. 항목을 제거하지 않는다. 운전자가 기능이 사라졌다고 오인하면 주행 중 탐색이 길어진다.

## 6. 상태 전이

### Freshness

| 상태 | 표시 |
| --- | --- |
| `fresh` | 실제 값 표시. 연결 인디케이터 `success`. |
| `stale` | **주행 수치를 숨긴다.** `—` + "업데이트 지연" + 마지막 수신 경과. 인디케이터 `warning`. |
| `unavailable` | 전부 `—` + "차량 상태 연결 대기 중". 인디케이터 `textTertiary`. |

`stale`에서 마지막 값을 계속 보여주지 않는다. 오래된 속도는 없는 속도보다 위험하다.

### Capability (Runtime 소유)

| 값 | HMI 동작 |
| --- | --- |
| `allowed` | 기능 노출 |
| `locked` | 기능 비활성 + Runtime이 준 사유 문자열 표시 |
| `unavailable` / `unspecified` | 기능 비활성 + "권한을 확인할 수 없습니다" |

**HMI는 어떤 경우에도 정책을 재계산하지 않는다.** `media_playback_reason`을 그대로 표시한다.

### Provider

| 값 | 화면 동작 |
| --- | --- |
| `connected == false` | `EmptyState`. 해당 영역의 조작 컨트롤을 그리지 않는다. |
| `connected && synthetic` | 정상 렌더 + Status Rail에 SYNTHETIC 배지 상주 |
| `connected && !synthetic` | 정상 렌더 |

## 7. 자동 전면화

| 조건 | 동작 |
| --- | --- |
| 기어 R | Camera 화면으로 즉시 전환. 기어 해제 시 직전 화면으로 복귀. |
| Critical 경고 | 현재 화면 유지 + `CriticalOverlay`. 화면을 바꾸지 않는다. |
| 안내 지점 200m 이내 | `NavInstruction`을 Home 우열 최상단으로 승격. 화면 전환 없음. |

**자동 화면 전환은 R 기어 하나뿐이다.** 시스템이 운전자의 화면을 임의로 빼앗지 않는다.

## 8. 접근성

- 모든 조작 요소에 `Accessible.name`.
- `activeFocus`는 `accent` 2px 외곽선으로 항상 보인다. `focus: false` 스타일을 만들지 않는다.
- 키보드 Tab 순서는 시각 순서와 일치한다 (Status Rail → 좌열 → stage → 우열 → Dock).
- 색만으로 상태를 구분하지 않는다. 형태 또는 텍스트를 동반한다.
- Dock은 숫자키 1–8로 직접 이동한다.
