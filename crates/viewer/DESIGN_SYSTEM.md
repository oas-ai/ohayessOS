# OAS VehicleState Viewer — design system

Viewer는 제품 HMI가 아니지만 **HMI와 같은 디자인 시스템(Grid)** 을 쓴다. 두 화면이 다른 언어로 보이면 개발 중 판단이 흔들린다.

시스템의 원본 정의는 [apps/hmi/design/01-DESIGN-TOKENS.md](../../apps/hmi/design/01-DESIGN-TOKENS.md)와 [02-COMPONENT-SYSTEM.md](../../apps/hmi/design/02-COMPONENT-SYSTEM.md)다. 이 문서는 웹으로 옮기며 달라진 부분만 기록한다.

## Foundations

- 떠 있는 카드가 아니라 **맞닿는 셀과 1px 규칙선**으로 구성한다. `--radius`는 0이며 예외가 없다.
- 그림자와 blur를 쓰지 않는다. 레이어는 `--line`과 surface 대비로만 표현한다.
- 색은 `--warning` `--critical` `--success` 셋뿐이고 **안전 의미일 때만** 쓴다. 선택·활성은 `--ink` 채움이다.
- Light가 기본이고 `body[data-theme="dark"]`가 야간 반전을 담당한다.
- 데이터는 DemiBold, 라벨은 문장형 소문자 회색이다. 대문자 변환과 자간 확대를 쓰지 않는다.
- 셸은 `--ground` 위에 놓인 한 장의 지면처럼 보이게 한다.

## Components

- `.board` — 그리드를 만드는 유일한 장소다. 보드를 `--line`으로 칠하고 `gap: 1px`으로 셀을 올리므로, 모든 구분선이 정확히 1px이고 셀은 자기 위치를 모른다. `.board--2/3/4/split`로 열을 정한다.
- `.cell` — 그리드의 한 칸. `--surface` 배경, 반경 0, 패딩 24px.
- `.metric` — 작은 회색 라벨 + DemiBold 값.
- `.safety-banner` — 좌측 8px 세로 바가 경보이고 배경은 평범하게 둔다. `[data-safety]`가 바의 색만 바꾼다.
- `.button` / `.fan-button` — 사각. 활성은 `--ink` 채움 + `--on-ink` 텍스트.
- `.nav-button` / `.sub-nav-button` — 텍스트 탭. 활성은 색과 굵기만 바꾼다. 알약도 밑줄도 상자도 없다.
- `.is-empty` — 값이 없을 때 `—`를 tertiary ink로 그리고, display 크기로는 세우지 않는다. 118px의 대시는 "값 없음"이 아니라 검은 막대로 읽힌다.

## Navigation

HMI는 좌측 하단 런처를 쓰지만 Viewer는 **상단 텍스트 탭**을 유지한다. 브라우저 도구는 운전석 인체공학의 제약을 받지 않고, 상단 탭이 레퍼런스의 구조에 더 가깝다.

## 규칙

- 조작 요소의 최소 높이는 `--touch-target`(56px)이다.
- 키보드 포커스는 항상 보이며(`--ink` 2px 외곽선), 정보 전달에 색상만 쓰지 않는다.
- `.setting-row > div` 같은 자식 선택자는 형제 컨테이너(`.choice-row`)까지 잡지 않도록 범위를 좁힌다.
- 화면 구조와 안전 상태의 우선순위는 [information architecture](INFORMATION_ARCHITECTURE.md)를 따른다.
