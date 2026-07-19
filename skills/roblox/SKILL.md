---
name: roblox
description: StoryBakery의 Roblox 코드를 작성, 수정, 리뷰하거나 Roblox 데이터 타입, Script 실행 컨텍스트, Instance 접근과 속성, 플레이어, 입력 시스템 규칙을 적용할 때 사용합니다.
---

# Roblox

작업 영역에 해당하는 reference를 먼저 읽고 Luau 코드에는 `luau` 스킬도 함께 적용합니다.
API 동작과 프로젝트 규칙을 구분하고, 변경 후에는 프로젝트가 제공하는 테스트와 정적 검사를 실행합니다.

## References

### Core

- `references/index.md`: StoryBakery Roblox 개발 가이드의 범위를 확인할 때
- `references/anti-pattern.md`: Roblox 코드에서 오류를 숨기는 과도한 분기와 방어 코드를 검토할 때
- `references/environment.md`: `RunService`로 Studio, 서버, 클라이언트 실행 환경을 구분할 때
- `references/script.md`: `RunContext`와 `.server.luau`, `.client.luau`, `.plugin.luau` 접미사를 결정할 때

### Data types

- `references/data-type/index.md`: Roblox 데이터 타입의 기본 선택 원칙을 확인할 때
- `references/data-type/cframe.md`: `CFrame` 생성, 연산, 회전, 비교와 오류 사례를 다룰 때
- `references/data-type/vector.md`: `Vector3`와 네이티브 `vector`의 선택 및 벡터 연산을 다룰 때

### Instance

- `references/instance/index.md`: Instance를 다루는 기본 철학과 병렬 실행 관점을 확인할 때
- `references/instance/access.md`: 직접 접근, `WaitForChild`, `FindFirstChild`, 자손 탐색, 외부 Instance 검증을 판단할 때
- `references/instance/create.md`: Instance 생성/복제를 다룰 때
- `references/instance/property.md`: `Content`, `CFrame`, 사용자 정의 속성의 타입과 이름을 정할 때
- `references/instance/attribute.md`: 인스턴스 Attribute 에 관련해 설정할 때
- `references/instance/tag.md`: 인스턴스 감지/태그를 사용할 때
- `references/instance/lifecycle/index.md`: 인스턴스 삭제 감지는 `AncestryChanged` 사용하기, `Destroy` 상세 동작 등
- `references/instance/instnace-handle.md`: 인스턴스를 어떻게 서버와 클라이언트 사이로 통신하고, `Attribute` 에 저장하는지

### Input

- `references/input/index.md`: Roblox 입력 처리의 전체 구조와 선택 기준을 확인할 때
- `references/input/display.md`: 키보드 키코드를 사용자에게 표시할 때
- `references/input/user-input-service.md`: `UserInputService`, `InputObject`, 입력 이벤트와 장치별 처리를 다룰 때
- `references/input/controller/index.md`: 기본 `PlayerModule`, `Animate`, Input Action System 전환과 비활성화를 다룰 때
- `references/input/devices/gamepad.md`: 게임패드 키코드, 동작 매핑, 다중 게임패드 입력을 다룰 때
- `references/input/devices/keyboard.md`: 키보드 입력을 다룰 때
- `references/input/devices/mouse.md`: 마우스 이동 델타와 스크롤을 다룰 때
- `references/input/devices/touch.md`: 터치 입력을 다룰 때
- `references/input/input-action-system/index.md`: Input Action System의 구조, 컨텍스트, 이벤트, 바인딩과 사용 기준을 다룰 때
- `references/input/input-action-system/input-action.md`: `InputAction`의 타입, 상태, 이벤트, 활성화와 서버 권한 연동을 구현할 때
- `references/input/input-action-system/input-binding.md`: `InputBinding`의 타입별 구성, 조합키, 보정, 리바인딩을 구현할 때
- `references/input/input-action-system/rojo.md`: Input Action System 인스턴스를 Rojo 프로젝트에 배치할 때

### Player

- `references/player/index.md`: `LocalPlayer` 저장 방식이나 플레이어 자식의 복제를 다룰 때
