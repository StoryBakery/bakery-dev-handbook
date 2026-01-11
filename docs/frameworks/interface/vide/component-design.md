---
id: vide-component-design
sidebar_label: Component Design
---

# Component Design

이 문서는 Vide 기반 UI 컴포넌트를 설계할 때의 의사결정 원칙을 요약합니다. 구현·호출 규칙은 [vide-kit](./vide-kit.md)와 [scripting-guide](../../scripting/scripting-guide.md)의 지침을 그대로 따르며, 여기서는 상속과 조합 선택 기준처럼 설계 단계에서 필요한 최소한의 규칙만을 명시합니다.


## 상속과 조합의 기준

- 로우레벨 베이스 클래스는 상속을 사용합니다.
  - Roblox 기본 인스턴스의 얇은 래퍼, 공통 인터랙션(예: Hover, Press)처럼 상태가 단순하고 재사용도가 높은 최소 추상화에 한정합니다.
  - 공통 속성·콜백을 한 곳에서 강제하려는 목적일 때만 허용합니다. 상속 계층은 얕게 유지합니다.

- 어느 정도 복잡한 컴포넌트부터는 조합을 우선합니다.
  - 아이콘/텍스트/툴팁/레이아웃 등 하위 요소가 여러 개인 위젯은 기존 컴포넌트(예: `Components.Frame`, `Components.TextLabel`, `Components.UIComponent.*`)를 조합해 구성합니다.
  - 동작 재사용이 필요하면 상속 대신 작은 헬퍼 함수나 `vide.source`/`vide.effect` 기반 내부 로직으로 분리합니다.

- 판단 기준(권장):
  - “단일 책임 + 얇은 공통 레이어” → 상속
  - “하위 구조 다수 + 상태/효과 결합” → 조합


## 상태와 효과

- 시각·입력 상태는 `vide.source`, `vide.effect`, `vide.action`, `vide.cleanup`으로만 관리합니다.
- 지연 표시 등 비동기는 가드 플래그로 취소 가능하게 작성하고, 정리는 `vide.effect`의 정리 함수 또는 `Maid`를 사용합니다.


## 반환과 문서화

- 반환은 `create "Class" { ... }` 또는 videKit 래퍼 호출로 통일합니다.
- 모든 Vide 컴포넌트는 파일 최상단에 `@class`와 `@tag vide`를 포함한 문서 주석을 둡니다. 세부 주석 규칙은 [vide-component-documentation](./component-documentation.md)를 따릅니다.

