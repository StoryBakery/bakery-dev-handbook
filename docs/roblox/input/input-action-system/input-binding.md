---
title: Input Binding
---

`InputBinding` 은 부모 `InputAction` 을 어떤 입력으로 발생시킬지 정하는 인스턴스입니다.
`InputAction.Type` 에 따라 활성화되는 속성이 달라집니다.

하나의 바인딩은 하나의 입력 조건과 모디파이어만 추가해야하며,
하나의 바인딩에 `KeyCode` 와 `UIButton` 을 둘 다 넣는 등은 불가능합니다.

## Type

`InputBinding.Type` 은 바인딩이 실제 입력을 직접 받을지, 스크립트가 값을 넣을지 결정합니다.

| 값 | 의미 | 사용 상황 |
| --- | --- | --- |
| `Enum.InputBindingType.Automatic` | 실제 하드웨어 입력이나 UI 버튼을 자동으로 감지합니다. 기본값입니다. | 일반적인 키보드, 마우스, 게임패드, 터치 버튼 |
| `Enum.InputBindingType.Scriptable` | 실제 입력을 무시하고 `InputBinding:Fire()` 로만 상태가 바뀝니다. | 복잡한 조합키, 커스텀 입력 계산, 플러그인/툴 입력, 별도 입력 시스템과 IAS 연결 |

## 속성 요약

| 속성 | 타입 | 주 용도 |
| --- | --- | --- |
| `KeyCode` | `Enum.KeyCode` | 키보드 키, 마우스 버튼, 게임패드 버튼/트리거/스틱, 마우스/터치 위치 계열 |
| `UIButton` | `GuiButton` | `Bool` 액션을 터치 UI 버튼으로 연결 |
| `UIModifier` | `GuiButton` | `UIButton` 또는 다른 바인딩을 발생시키기 전에 눌려 있어야 하는 UI modifier |
| `PrimaryModifier` | `Enum.KeyCode` | `Ctrl`, `Shift` 같은 첫 번째 modifier 키 |
| `SecondaryModifier` | `Enum.KeyCode` | 두 번째 modifier 키 |
| `Up`, `Down` | `Enum.KeyCode` | `Direction1D`, `Direction2D`, `Direction3D` 의 위/아래 축 |
| `Left`, `Right` | `Enum.KeyCode` | `Direction2D`, `Direction3D` 의 좌우 축 |
| `Forward`, `Backward` | `Enum.KeyCode` | `Direction3D` 의 앞/뒤 축 |
| `PressedThreshold` | `number` | 아날로그 입력이 `Bool` 액션의 `Pressed` 로 인정되는 기준 |
| `ReleasedThreshold` | `number` | 아날로그 입력이 `Bool` 액션의 `Released` 로 인정되는 기준 |
| `Scale` | `number` | 방향 값 전체에 곱하는 스케일 |
| `Vector2Scale` | `Vector2` | `Direction2D` 의 X/Y 성분별 스케일 |
| `Vector3Scale` | `Vector3` | `Direction3D` 의 X/Y/Z 성분별 스케일 |
| `ResponseCurve` | `number` | `Thumbstick1`, `Thumbstick2` 의 감도 곡선 |
| `ClampMagnitudeToOne` | `boolean` | 합성 방향 입력의 대각선 크기를 최대 `1` 로 제한 |

## Bool 바인딩

`KeyCode`, `UIButton` 를 사용할 수 있습니다.

- **키보드**: 모든 키 전부 가능
- **마우스**: `MouseLeft/Right/MiddleButton`, `GuiButton` 가능
- **게임패드**:
  - `Thumbstick1Up/Down/Left/Right`
  - `Thumbstick2Up/Down/Left/Right`
  - `DPadUp/Down/Left/Right`
  - `ButtonL1/L2/L3/R1/R2/R3`
  - `ButtonA/B/X/Y/Start/Select`
- **터치**: `GuiButton` 으로 가능

### GuiButton

터치용 버튼은 `UIButton` 속성에 `GuiButton` 을 연결합니다.

```luau
const Players = game:GetService("Players")

const localPlayer = Players.LocalPlayer
const playerGui = localPlayer.PlayerGui
const screenGui = playerGui:WaitForChild("ControlsGui")
const jumpButton = screenGui.JumpButton

const touchBinding = inputAction.TouchBinding
touchBinding.UIButton = jumpButton
```

### 세기를 받는 입력값을 Bool 로 쓰기

게임패드 트리거 등은 0부터 1 사이의 실수 값을 주기도 합니다.

- `Thumbstick1Up/Down/Left/Right`
- `Thumbstick2Up/Down/Left/Right`
- `ButtonL2/R2`

부모 액션이 `Bool` 이면 `PressedThreshold`, `ReleasedThreshold` 로 눌림/떼짐 기준을 정합니다.

```luau
triggerBinding.KeyCode = Enum.KeyCode.ButtonR2
triggerBinding.PressedThreshold = 0.55
triggerBinding.ReleasedThreshold = 0.2
```

`PressedThreshold` 는 `ReleasedThreshold` 보다 크거나 같아야 합니다.
두 값을 다르게 두면 트리거가 기준 근처에서 흔들릴 때 눌림/떼짐이 빠르게 반복되는 일을 줄일 수 있습니다.

## Direction1D 바인딩

`Enum.InputActionType.Direction1D` 는 한 축의 값입니다.
가속, 브레이크, 줌, 위/아래 선택 같은 입력에 사용합니다.

`KeyCode`, `Up`, `Down` 를 사용할 수 있습니다.

추가적으로 `Scale` 를 설정할 수 있습니다.

### Direction1D 의 `KeyCode`

- **키보드**: 모든 키 전부 가능
- **마우스**: `MouseLeft/Right/MiddleButton`, `MouseWheel`
- **게임패드**:

  - `Thumbstick1Up/Down/Left/Right`
  - `Thumbstick2Up/Down/Left/Right`
  - `DPadUp/Down/Left/Right`
  - `ButtonL1/L2/L3/R1/R2/R3`
  - `ButtonA/B/X/Y/Start/Select`
- **터치**: `TouchPinch`
- **트랙패드 (노트북)**: `TrackpadPinch`

### Direction1D 의 `Up/Down`

`Up`: `0` 에서 `1`
`Down`: `0` 에서 `-1`

```luau
keyboardBinding.Up = Enum.KeyCode.W -- 1
keyboardBinding.Down = Enum.KeyCode.S -- -1

gamepadBinding1.KeyCode = Enum.KeyCode.ButtonR2 -- [0, 1]

gamepadBinding2.Up = Enum.KeyCode.Thumbstick1Up -- [0, 1]
gamepadBinding2.Down = Enum.KeyCode.Thumbstick1Down -- [-1, 0]
```

키보드 `W` 는 양수값, `S` 는 음수값으로 들어옵니다.

사용가능한 `KeyCode` 값은 `Direction1D` 의 `KeyCode` 와 같습니다.

## Direction2D 바인딩

`Enum.InputActionType.Direction2D` 는 `Vector2` 를 반환합니다.
캐릭터 이동, 카메라 회전, 메뉴 내비게이션, 커서 이동에 사용합니다.

### Direction2D 의 `KeyCode` 속성

2차원 벡터 값을 내놓는 `KeyCode` 만 가능합니다.

- **키보드**: 불가
- **마우스**: `MouseDelta`
- **게임패드**: `Thumbstick1`, `Thumbstick2` 사용 가능

  `Bool` 과 `Direction1D` 에서 사용가능한 `Enum.KeyCode.Thumbstick1Up/Down/Left/Right` 는 Direction2D 에선 사용 불가

- **터치**: `TouchPan`/`TouchDelta`
- **트랙패드 (노트북)**: `TrackpadPan`

### Direction2D 의 `Up/Down/Left/Right`

| 입력 | 합성 성분 |
| --- | --- |
| `Up` | +Y |
| `Down` | -Y |
| `Left` | -X |
| `Right` | +X |

`Up` 와 `Right` 를 동시에 누르면 `(1, 1)` 방향이 됩니다.
`Up` 와 `Down` 를 동시에 누르면 `(0, 0)` 이 됩니다.

`ClampMagnitudeToOne` 이 `true` 이면 대각선 입력의 최대 크기가 `1` 로 됩니다.

사용가능한 `KeyCode` 값은 `Direction1D` 의 `KeyCode` 와 같습니다.

예시:

```luau
keyboardBinding1.Up = Enum.KeyCode
keyboardBinding1.Down = Enum.KeyCode
keyboardBinding1.Left = Enum.KeyCode
keyboardBinding1.Right = Enum.KeyCode
```

## Direction3D 바인딩

`Enum.InputActionType.Direction3D` 는 `Vector3` 를 반환합니다.
비행, 자유 이동 카메라, 우주선 조작처럼 3차원 이동이 필요한 입력에 사용합니다.

### Direction3D 의 `Forward/Backward/Left/Right/Up/Down`

| 바인딩 속성 | 합성 성분 |
| --- | --- |
| `Left` | -X |
| `Right` | +X |
| `Up` | +Y |
| `Down` | -Y |
| `Forward` | -Z |
| `Backward` | +Z |

Roblox 좌표계에서 앞 방향을 `-Z` 로 다루는에 `Forward` 는 Z 음수, `Backward` 는 Z 양수로 들어옵니다.

사용가능한 `KeyCode` 값은 `Direction1D` 의 `KeyCode` 와 같습니다.

예시:

```luau
const flyAction = script.FlyAction
flyAction.Type = Enum.InputActionType.Direction3D

const keyboardBinding = flyAction.KeyboardBinding
keyboardBinding.Forward = Enum.KeyCode.W
keyboardBinding.Backward = Enum.KeyCode.S
keyboardBinding.Left = Enum.KeyCode.A
keyboardBinding.Right = Enum.KeyCode.D
keyboardBinding.Up = Enum.KeyCode.E
keyboardBinding.Down = Enum.KeyCode.Q
keyboardBinding.ClampMagnitudeToOne = true
```

## ViewportPosition 바인딩

`Enum.InputActionType.ViewportPosition` 은 화면 좌표 `Vector2` 를 반환합니다.
커스텀 커서, 월드 선택 raycast, 드래그 시작 위치 같은 기능에 사용합니다.

- **마우스**: `MousePosition`, `MouseDelta`
- **터치**: `TouchPosition`, `TouchDelta`, `TouchPinch`

`UIModifier` 속성을 통해 특정 GuiButton 을 **누르고** 있을때만 위에 있을 때만 작동되게 할 수 있습니다.
특정 UI 에서 감지해야한다한다면, `UIModifier` 보단 `Scriptable` 로 감지하는 것이 더 좋습니다.

## Scale

`Scale` 은 방향 값 전체에 곱해집니다.
`Vector2Scale` 과 `Vector3Scale` 은 축별로 다른 감도를 줄 때 사용합니다.

```luau
const binding = cameraAction.MouseBinding

binding.KeyCode = Enum.KeyCode.MouseDelta
binding.Scale = 0.01
binding.Vector2Scale = Vector2.new(1, 0.75)
```

위 예시는 마우스 X 이동은 그대로 두고 Y 이동만 75% 로 줄입니다.
`Scale` 과 `Vector2Scale` 을 함께 설정하면 둘 다 적용됩니다.

3D 이동에서는 `Vector3Scale` 로 축별 세기를 조정합니다.

```luau
const binding = flyAction.KeyboardBinding

binding.Vector3Scale = Vector3.new(1, 0.6, 1)
```

## Modifier

`PrimaryModifier` 와 `SecondaryModifier` 는 `Ctrl + C`, `Ctrl + Shift + C` 같은 조합 입력을 만들 때 사용합니다.

```luau
keyboardBinding.KeyCode = Enum.KeyCode.C
keyboardBinding.PrimaryModifier = Enum.KeyCode.LeftControl
keyboardBinding.SecondaryModifier = Enum.KeyCode.LeftShift
```

이 바인딩은 `LeftControl` 과 `LeftShift` 가 눌린 상태에서 `C` 를 눌렀을 때만 발생합니다.

주의할 점은 modifier 가 본 입력보다 먼저 눌려 있어야 한다는 것입니다.
`PrimaryModifier` 와 `SecondaryModifier` 사이의 순서는 상관없지만,
`C` 를 먼저 누른 뒤 `Ctrl` 을 누르는 방식은 같은 입력으로 보지 않습니다.

modifier 를 비활성화하려면 해당 속성을 `Enum.KeyCode.Unknown` 으로 둘 수 있습니다.

## Scriptable 바인딩

대부분의 입력은 `Automatic` 으로 처리합니다.
하지만 다음 경우에는 `Scriptable` 바인딩이 더 명확합니다.

- `PrimaryModifier`/`SecondaryModifier` 로 표현하기 어려운 3개 이상의 조합키
- 키 입력 순서가 중요한 커맨드
- `UserInputService` 로 보다 복잡하게 직접 해석해야 하는 도구
- 플러그인, 에디터 툴, 커스텀 입력 시스템에서 계산한 상태를 IAS 액션으로 넘겨야 하는 경우
- 여러 입력 소스를 합쳐 하나의 보정된 값으로 만들고 싶은 경우

`Scriptable` 바인딩은 하드웨어 입력을 직접 감지하지 않습니다.
반드시 스크립트에서 `InputBinding:Fire(state)` 를 호출해야 합니다.

```luau
const inputAction = script.Parent
const scriptBinding = inputAction.ScriptBinding

scriptBinding.Type = Enum.InputBindingType.Scriptable

-- Bool 액션 누름
scriptBinding:Fire(true)

-- Bool 액션 뗌
scriptBinding:Fire(false)
```

`Fire()` 로 넘기는 값의 타입은 부모 `InputAction.Type` 과 맞아야 합니다.

| 부모 `InputAction.Type` | `Fire()` 값 |
| --- | --- |
| `Bool` | `boolean` |
| `Direction1D` | `number` |
| `Direction2D` | `Vector2` |
| `Direction3D` | `Vector3` |
| `ViewportPosition` | `Vector2` |

타입이 맞지 않으면 에러가 납니다.
같은 값을 연속해서 `Fire()` 해도 상태가 바뀌지 않았으면 `StateChanged`, `Pressed`, `Released` 는 다시 발생하지 않습니다.

### 복잡한 조합키 예시

단순한 `Ctrl + Shift + C` 는 modifier 속성으로 처리할 수 있습니다.
하지만 `Ctrl + Shift + Alt + C` 처럼 modifier 가 더 많거나,
입력 순서와 UI 처리 여부까지 직접 정해야 한다면 `UserInputService` 로 감지한 뒤 `Scriptable` 바인딩에 전달합니다.

```luau
const UserInputService = game:GetService("UserInputService")

const inputAction = script.Parent
const scriptBinding = inputAction.ScriptBinding

scriptBinding.Type = Enum.InputBindingType.Scriptable

const watchedKeys = {
    [Enum.KeyCode.LeftControl] = true,
    [Enum.KeyCode.LeftShift] = true,
    [Enum.KeyCode.LeftAlt] = true,
    [Enum.KeyCode.C] = true,
}

const function isChordDown()
    return UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
        and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
        and UserInputService:IsKeyDown(Enum.KeyCode.C)
end

const function refresh()
    scriptBinding:Fire(isChordDown())
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then
        return
    end

    if watchedKeys[input.KeyCode] then
        refresh()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if watchedKeys[input.KeyCode] then
        refresh()
    end
end)
```

`StoryBakery/UserInputManager` 와 같은 복잡한 UIS 를
보다 더 심화되게 이용할 수 있는 패키지를 사용하는 것도 좋습니다.

## 런타임 리바인딩

키 설정을 바꿀 때는 새 액션을 만들지 말고 기존 바인딩의 속성을 바꿉니다.

서버와 동기화되는 액션일지라도, 액션의 상태 값만 동기화되는 것이기에
클라이언트는 바인딩은 생성하거나 삭제하거나 속성을 바꾸어도 됩니다.

```luau
const interactBinding = interactAction.KeyboardBinding

interactBinding.KeyCode = Enum.KeyCode.F
```

## 델타값을 주는 바인딩은 속도값입니다

`UserInputService` 의 `InputObject` 의 `Position.Z` 이나 `Delta` 값과는 다르게 초당 속도 값으로
`InputAction:GetState() * deltaTime` 을 곱해줘야합니다.

- `MouseDelta`
- `MouseWheel`
- `TouchDelta`
- `TouchPinch`
- `TouchPan`
- `TrackpadPinch`
- `TrackpadPan`
