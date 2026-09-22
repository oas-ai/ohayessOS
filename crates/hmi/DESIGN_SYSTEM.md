# OAS HMI design system

목표는 운전 중 짧게 봐도 안전 상태와 다음 행동을 알 수 있는 다크 HMI다. 장식보다 상태의 명확성, 대비, 큰 터치 영역을 우선한다.

## Foundations

- 색상은 `design.css`의 `--color-*` 토큰만 사용한다. 의미색은 `accent`, `success`, `danger`로 한정한다.
- 간격은 8px 단위 `--space-1`부터 `--space-4`까지 사용한다.
- 컨트롤의 최소 높이는 `--touch-target`(56px)이다.
- 본문은 시스템 글꼴 18px 이상, 숫자는 tabular 숫자를 사용한다.
- 키보드 포커스는 항상 보이며, 정보 전달에 색상만 사용하지 않는다.

## Components

- `app-shell`: 화면 전체 여백과 최대 폭을 담당한다.
- `top-bar`와 `status-pill`: 제품 식별과 현재 안전 상태를 표시한다.
- `card`: 독립된 기능·정보 그룹이다. 카드 안에 카드 중첩은 하지 않는다.
- `metric`: label/value 쌍으로 차량 상태를 표시한다.
- `safety-banner`: 허용·잠금·불명 상태를 텍스트와 함께 표시한다.
- `button`: 최소 56px 터치 영역을 유지하며 `:focus-visible`을 제공한다.

## Safety states

`data-safety`는 `allowed`, `locked`, `unknown` 중 하나다. `unknown`과 `locked`는 기능을 열지 않는다. 서버의 `videoPlayback` 정책 결과만 이 속성을 변경할 수 있으며, HMI의 표현 코드는 정책을 재구현하지 않는다.

## Screen baseline

기준 해상도는 가로형 1280×720 이상이다. 720px 이하에서는 한 열로 전환한다. 다음 화면도 이 토큰과 컴포넌트를 먼저 사용하고, 새 컴포넌트가 두 화면 이상에 필요할 때만 공통화한다.
