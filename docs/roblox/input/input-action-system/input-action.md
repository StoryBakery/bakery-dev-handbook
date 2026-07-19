---
title: Input Action
---

`InputAction` 은 플레이어가 하려는 행동을 표현하는 인스턴스입니다.

키보드의 `E`, 게임패드의 `ButtonX`, 터치 버튼 같은 물리 입력을 직접 게임 로직에 연결하지 않고,
먼저 `Interact`, `Jump`, `Sprint`, `Move`, `CameraRotate` 같은 행동을 `InputAction` 으로 정의합니다.
그 다음 실제 입력은 자식 `InputBinding` 으로 연결합니다.

## 위치와 등록

`InputAction` 은 가장 가까운 조상 `InputContext` 에 등록됩니다.
조상에 `InputContext` 가 없으면 기본 컨텍스트에 등록됩니다.

그래도 실제 프로젝트에서는 명시적인 `InputContext` 아래에 두는 편이 좋습니다.
컨텍스트가 있어야 게임 플레이, 메뉴, 차량, 관전 모드처럼 상황별 입력을
`Enabled`, `Priority`, `Sink` 로 제어할 수 있습니다.

## Type

`InputAction.Type` 은 액션이 어떤 값을 내보내는지 결정합니다.
자식 `InputBinding` 에서 어떤 속성을 써야 하는지도 이 타입에 따라 달라집니다.

| 타입 | 값 | 용도 |
| --- | --- | --- |
| `InputActionType.Bool` | `boolean` | 점프, 공격, 상호작용, 스프린트 |
| `InputActionType.Direction1D` | `number` | 가속, 브레이크, 줌, 위/아래 선택 |
| `InputActionType.Direction2D` | `Vector2` | 이동, 카메라 회전, 메뉴 내비게이션 |
| `InputActionType.Direction3D` | `Vector3` | 비행, 자유 이동, 3D 조작 |
| `InputActionType.ViewportPosition` | `Vector2` | 마우스/터치 화면 좌표, 월드 선택 |

타입은 액션을 사용하는 코드보다 먼저 결정합니다.
예를 들어 `Sprint` 는 `Bool`, `Move` 는 `Direction2D`, `AimAtScreen` 은 `ViewportPosition` 처럼 행동의 의미에 맞춰 고릅니다.

## Bool 액션

`Bool` 은 눌렸는지 아닌지를 나타냅니다.
버튼 입력처럼 시작과 끝이 분명한 행동에 맞습니다.

`Bool` 액션은 `Pressed` 와 `Released` 란 이벤트도 제공합니다.

```luau
const sprintAction = script.Parent

sprintAction.Pressed:Connect(function()
    print("Sprint start")
end)

sprintAction.Released:Connect(function()
    print("Sprint end")
end)
```

## Direction1D 액션

`Direction1D` 는 한 축의 숫자 값입니다.
값은 보통 `-1` 부터 `1` 사이에서 다루지만, 실제 범위는 바인딩과 스케일 설정에 따라 달라질 수 있습니다.

## Direction2D 액션

`Direction2D` 는 `Vector2` 값을 반환합니다.
캐릭터 이동, 카메라 회전, UI 내비게이션처럼 2차원 방향이 필요한 행동에 사용합니다.

```luau
RunService:BindToSimulation(function()
    -- 액션은 조작가능함으로 clamp 합니다
    -- .Unit 이 아닌 이유는, MoveVector 는 천천히 걷는 강도도 반영해야할 때가 있기 때문입니다
    -- e.g. 터치 컨트롤러를 살살 움직여 느리게 걷기
    const moveVector = clampMagnitudeToOne(moveAction:GetState())
end)
```

## Direction3D 액션

`Direction3D` 는 `Vector3` 값을 반환합니다.
비행, 자유 카메라, 6축 이동처럼 3차원 방향이 필요한 행동에 사용합니다.

대각선이나 여러 축을 동시에 누를 수 있으면 자식 `InputBinding` 에서 `ClampMagnitudeToOne` 을 켜는 것을 고려합니다.

## ViewportPosition 액션

`ViewportPosition` 은 화면 픽셀 좌표를 `Vector2` 로 반환합니다.

터치 입력은 여러 포인터가 있을 수 있으므로,
별도 입력 계산 후 `Scriptable` 바인딩으로 넘기는 편이 관리하는 것도 괜찮습니다.

## 이벤트

`InputAction` 의 이벤트는 상태가 바뀔 때만 발생합니다.
같은 값으로 다시 업데이트되면 다시 발생하지 않습니다.

| 이벤트 | 사용 타입 | 발생 조건 |
| --- | --- | --- |
| `Pressed` | `Bool` | 상태가 `false` 에서 `true` 로 바뀔 때 |
| `Released` | `Bool` | 상태가 `true` 에서 `false` 로 바뀔 때 |
| `StateChanged(value)` | 모든 타입 | 상태 값이 이전 값과 달라질 때 |

이벤트가 적합한 경우:

- 버튼을 누른 순간 한 번 실행되는 행동
- 상태가 바뀔 때 UI 표시를 갱신하는 행동
- 토글, 선택, 메뉴 이동처럼 변화 순간이 중요한 행동

`GetState()` 폴링이 적합한 경우:

- 이동 속도, 카메라 회전처럼 매 프레임 적용되는 행동
- Thumbstick 을 같은 각도로 계속 유지하는 동안에도 처리해야 하는 행동
- 고정틱 시뮬레이션에서 같은 프레임 입력 상태를 반복적으로 읽어야 하는 행동

## GetState

`InputAction:GetState()` 는 액션의 현재 상태를 반환합니다.
반환 타입은 `InputAction.Type` 에 따라 달라집니다.

```luau
const RunService = game:GetService("RunService")

const moveAction = script.Parent.Move

RunService:BindToSimulation(function(dt)
    const moveVector = moveAction:GetState()

    if moveVector.Magnitude == 0 then
        return
    end

    print(moveVector, dt)
end)
```

## Enabled

`InputAction.Enabled` 는 특정 액션만 켜거나 끌 때 사용합니다.
컨텍스트 전체를 바꿔야 하면 `InputContext.Enabled` 를 우선 고려하고,
같은 컨텍스트 안에서 특정 행동만 잠그고 싶을 때 액션의 `Enabled` 를 사용합니다.

```luau
const interactAction = playContext.Interact

interactAction.Enabled = false
```

`Enabled` 를 `false` 로 바꾸면 액션 상태가 reset 됩니다.
예를 들어 누르고 있던 `Bool` 액션을 비활성화하면 계속 눌린 상태로 남지 않습니다.
비활성화 이후 코드가 이전 입력 상태를 계속 유지한다고 가정하면 안 됩니다.

UI 메뉴를 열 때 이동, 점프, 공격을 전부 막아야 한다면 각 액션을 하나씩 끄기보다
`PlayContext.Enabled = false` 또는 더 높은 우선순위의 `MenuContext` 와 `Sink` 를 사용합니다.

## 여러 바인딩과 액션 분리

하나의 `InputAction` 에 여러 `InputBinding` 을 두는 이유는 같은 행동을 여러 장치에서 실행하기 위해서입니다.

```sh
JumpAction
|- KeyboardBinding # Space
|- GamepadBinding # ButtonA
|- TouchBinding # JumpButton
```

이 구조에서 코드는 `Space` 인지 `ButtonA` 인지 몰라도 됩니다.
그저 `Jump.Pressed` 또는 `Jump:GetState()` 만 처리합니다.

```luau
const jumpAction = script.InputContexts.PlayContext.JumpAction

jumpAction.Pressed:Connect(function()
    print("Jump")
end)
```

반대로 같은 물리 입력이라도 의미가 다르면 액션을 나눕니다.

```sh
PlayContext
|- InteractAction # E

MenuContext
|- ConfirmAction # E
```

같은 입력을 상황에 따라 다르게 처리해야 한다면 액션 하나에서 조건문을 늘리기보다,
컨텍스트를 나누고 `Priority`, `Sink`, `Enabled` 로 전환하는 편이 유지보수하기 좋습니다.
