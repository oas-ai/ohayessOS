# OAS Automotive OS — design entry point

설계 기준은 [design/](design/)에 있으며, 구현보다 먼저 확정된다. 화면을 바꾸기 전에 해당 문서를 먼저 갱신한다.

| 문서 | 내용 |
| --- | --- |
| [00-UX-ARCHITECTURE.md](design/00-UX-ARCHITECTURE.md) | 제품 원칙, 시스템 계층, Provider 계약, 정보 구조, 메인 화면 와이어프레임, 반응형 규칙, 12개 화면 목록 |
| [01-DESIGN-TOKENS.md](design/01-DESIGN-TOKENS.md) | 색·타이포·간격·반경·터치·모션·아이콘·breakpoint 토큰 |
| [02-COMPONENT-SYSTEM.md](design/02-COMPONENT-SYSTEM.md) | 공통 컴포넌트 규격과 도메인 컴포넌트 계약 |
| [03-INTERACTION-SPEC.md](design/03-INTERACTION-SPEC.md) | 제스처, 애니메이션 duration, 즉각 피드백, 주행 중 잠금, 상태 전이, 접근성 |

## 시스템 이름: Grid

떠 있는 카드가 아니라 **맞닿는 셀과 1px 규칙선**으로 화면을 만든다. 반경 0, 그림자 없음, blur 없음. 강조는 대비와 굵기이며 **색은 안전 상태에만 남는다.** Light가 기본이고 Dark는 같은 언어의 야간 반전이다.

## 구현 구조

`qml/Tokens.qml`이 색·타이포·간격·모션의 단일 공급원이다. `qml/Nav.qml`은 유일한 목적지 정의이고, `qml/Providers.qml`은 계약에 없는 도메인(지도·공조·에너지·ADAS·카메라·미디어·조명·잠금·타이어·전화·업데이트)의 공급자 계층이다.

그리드는 `GridBoard` 한 곳에서 만들어진다 — 보드를 규칙선 색으로 칠하고 셀을 1px 간격으로 올리므로, 모든 구분선이 정확히 1px이고 셀은 자기 위치를 알 필요가 없다. `Metric`이 시스템의 기본 단위(라벨 · 변화량 · 값 · 차트)이며 `BarSeries`와 `MeterBar`가 차트를 담당한다. `MeterBar`는 투영 구간을 사선 해칭으로 그려 측정값으로 오인되지 않게 한다.

내비게이션은 좌측 하단 `Launcher` 하나다. 누르면 `LauncherMenu`가 12개 목적지를 한 번에 펼친다. 버튼은 항상 현재 화면명을 표시하고, 주행 중 잠긴 목적지는 사유와 함께 흐리게 남는다.

나머지 공통 컴포넌트는 `Cell` `Caption` `Divider` `StatusBadge` `EmptyState` `Icon`, 컨트롤 `OasButton` `OasIconButton` `OasToggle` `OasSlider` `OasSegmented` `TabRow`, 셸 `TopBar` `SidePanel` `OasModal` `Toast` `NotificationItem` `CriticalOverlay` `CategoryTile`, 도메인 `VehicleVisual` `VehicleStatusIndicator` `TempZone` `MediaMiniPlayer` `NavInstruction` `MapSurface`다. 12개 화면은 `qml/Screen*.qml`이며 조합만 담당한다.

## 정직한 상태

데모는 항상 SYNTHETIC을 표기한다. `fresh`는 상태가 도착했다는 뜻이지 모든 차량 시스템이 정상이라는 뜻이 아니다. `stale`과 `waiting`은 주행 수치를 숨긴다 — 오래된 속도는 없는 속도보다 위험하다. 진단 값은 Runtime capability가 허용된 동안에만 표시한다.

차량 시각화는 도어·안전벨트·조향·기어를 canonical `VehicleState`에서 직접 받는다. 신호 단위 `*Valid`가 false인 항목은 채우지 않고 외곽선으로만 그려 "불명"을 "정상"으로 오인시키지 않는다. 지도·ADAS·공조·에너지 값은 Provider `connected`가 false인 동안 `EmptyState`로만 표시하며 합성하지 않는다.

Runtime이 재생 정책을 소유한다. HMI는 `media_playback_reason`을 그대로 표시할 뿐 정책을 재계산하지 않는다. 이 설치 환경에는 차량 제어 전송 경로가 없으므로 모든 제어는 로컬 UI 상태다.

## 검증

CTest가 drive·park·waiting·stale 상태와 12개 화면 전부, 다크 테마 3종, 1280×720 / 1920×1080 / 2560×1440 / 3840×1200 네 해상도, 런처 메뉴(정차·주행), R 기어 자동 전면화를 렌더링한다. QML 바인딩 오류·타입 로드 실패·바인딩 루프는 테스트 실패로 처리한다. 스크린샷은 CI 아티팩트이며, 테스트 상태뿐 아니라 이미지도 확인한다.

렌더러는 blur도 그림자도 쓰지 않고 규칙선과 surface 대비로만 레이어를 표현하므로 software renderer와 임베디드 GPU가 같은 결과를 만든다. 매 프레임 움직이는 요소는 전부 Canvas 밖의 QML 아이템이며, Canvas는 차량 신호가 바뀔 때만 다시 그린다. 반복 애니메이션은 충전 표시와 방향지시등 두 곳뿐이다.
