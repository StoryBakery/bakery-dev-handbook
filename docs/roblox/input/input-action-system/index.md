---
title: Input Action System
---

Input Action System(IAS)은 Roblox 의 크로스 플랫폼 입력 시스템입니다.

키보드, 마우스, 게임패드, 터치 입력을 각각 직접 처리하기보다,
플레이어가 수행하려는 행동을 `InputAction` 으로 정의하고 플랫폼별 입력을 `InputBinding` 으로 연결합니다.

## 구조

기본 구조는 다음과 같습니다.

```sh
Inputs
|- PlayContext # InputContext
  |- JumpAction # Type = Bool
  |  |- KeyboardBinding # KeyCode = Space
  |  |- GamepadBinding # KeyCode = ButtonA
  |  |- TouchBinding # UIButton = JumpButton
  |- MoveAction # Type = Direction2D
     |- KeyboardBinding1 # Up/Down/Left/Right = W/A/S/D
     |- KeyboardBinding2 # Up/Down/Left/Right = Up/Down/Left/Right
     |- GamepadBinding # KeyCode = Thumbstick1
     |- TouchBinding # Scriptable
```

공식 문서에서는 여러 `InputContext` 를 담는 `Inputs` 폴더를 `ReplicatedStorage` 아래에 두는 예시를 사용합니다.

- `InputContext`: 입력 묶음입니다. 게임 플레이, UI, 차량, 관전 모드처럼 상황 단위로 나눕니다.
- `InputAction`: 실제 게임 행동입니다. `Jump`, `Shoot`, `Sprint`, `Interact` 처럼 이름을 붙입니다.
- `InputBinding`: 행동을 발생시키는 물리 입력입니다. 키보드 키, 게임패드 버튼, 터치 버튼 등을 연결합니다.

액션 이름은 입력 장치가 아니라 게임 행동을 기준으로 짓고,
바인딩 이름은 장치나 입력 방식 기준으로 짓습니다.

## InputContext

입력은 상황마다 다르게 동작해야 합니다.

예를 들어 같은 `ButtonA` 입력이라도 게임 플레이 중에는 점프이고,
메뉴가 열린 상태에서는 선택일 수 있습니다.

이런 경우 `InputContext` 를 나눕니다.

```sh
Inputs
|- PlayContext
|- MenuContext
|- VehicleContext
|- SpectatorContext
```

컨텍스트는 `Enabled`, `Priority`, `Sink` 로 제어합니다.

- `Enabled`: 해당 컨텍스트를 켜거나 끕니다.
- `Priority`: 여러 컨텍스트가 같은 입력을 받을 때 우선순위를 정합니다.
- `Sink`: 해당 컨텍스트에 바인딩된 입력이 낮은 우선순위 컨텍스트로 전달되는 것을 막습니다.

## 서버와의 복제가 필요한 경우 `InputContext` 를 `Player` 의 자손으로 둡니다

`Player` 의 자손인 `InputAction` 은 롤백 가능한 값을 가지게 되며,
State 값이 클라이언트로부터 서버와 동기화됩니다.

```sh
PlayerController.luau
|- InputReplicator.server.luau
|- PlayerControllerInputContexts # InputReplicator 가 Player 의 자식으로 복제함
  |- PlayContext
     |- MoveAction
     |- JumpAction
     |- InteractAction
```

그렇기에 `InputAction` 의 `State` 동기화는 단순히 입력 전송 뿐만 아니라 커스텀화된 값들도
서버에 전송하는데 유용합니다.

서버는 클라이언트로부터 입력값이 너무 지연되면 이전의 입력을 유지하고,
클라이언트는 지연되지 않게 예측하며 보내는 등의 기능이 있습니다.

:::warn
`InputAction` 는 조상에 `InputContext` 가 없으면, 플레이어의 자손일지라도 동기화되지 않습니다
:::

## 사용 기준

Input Action System 은 다음 경우에 우선 사용합니다.

- 여러 플랫폼 입력을 같은 행동으로 묶어야 하는 경우
- 게임 상태에 따라 입력 맵을 바꿔야 하는 경우
- 터치 버튼과 키보드/게임패드 입력을 같은 코드 경로로 처리하고 싶은 경우
- 입력 설정을 Studio 인스턴스 구조로 관리하고 싶은 경우

다음 경우에는 `UserInputService` 를 직접 사용하는 편이 나을 수 있습니다.

- 임시 디버그 단축키
- 텍스트 입력처럼 UI 컴포넌트가 직접 처리하는 입력
- 매우 낮은 수준의 입력 상태를 직접 조사해야 하는 도구 코드
