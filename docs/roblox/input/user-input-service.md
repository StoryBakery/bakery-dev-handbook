---
title: UserInputService
---

UserInputService 는 다양한 입력 기기 및 입력 감지 기능을 제공합니다.

IAS 출시 이후, UserInputService 를 통한 감지는 크게 쓰이지 않지만
복잡한 입력 계산 시스템에서나 InputBinding 의 값을 설정하는 경우 아직까지도 유용하게 사용됩니다.

서버권한에서의 롤백 기능만을 제외한다면, 기본 IAS 기능보다 훨씬 더 심화된 기능을 제공합니다.

## InputObject

인스턴스입니다, 그렇기에 여타 인스턴스처럼
`Position` 과 `Delta` 속성에 `GetPropertyChangedSignal` 를 사용해 감지할 수 있습니다.

키보드와 게임 패드의 `InputObject` 들은 `KeyCode` 속성을 가집니다.

### InputObject 는 입력 시작 후 끝날 때 까지 같은 객체입니다

**예시 코드**:

```luau
local boundInputObject

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.A then
        boundInputObject = input
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.A then
        print(boundInputObject == input) --> true
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.A then
        print(boundInputObject == input) --> true
    end
end)
```

키보드가 2개가 된다거나, 여러가지 상황에서 무조건 `true` 라고 할 수 없지만,
`InputObject` 는 한 번 이어진 것은 계속 이어지게 됩니다.

### `InputObject.Position`

`Vector3` 값으로 InputType 에 따라 여러가지 값으로 표현됩니다.

- 마우스와 터치의 경우: 화면 x y 좌표
- 마우스 휠의 경우: Z 값이 세기에 따라 커지거나 작아집니다
  - 앞 스크롤링: 양수의 Z 값
  - 뒤 스크롤링: 음수의 Z 값
  - 스크롤링 안하는 경우: 0의 Z 값

### `InputObject.Delta`

Position 속성 변화량, Vector3
마우스나 조이스틱으로 작동하는 카메라나 컨트롤 스크립트 만들때 유용

### UserInputState

- 버튼/키 누르기: `Begin` -> `End`
- 게임 패드 트리거 버튼: 버튼/키와 동일, 단 버튼 State 변경시 `Change`
- 마우스 움직임: `Begin` (mouse-over) -> `Change` -> `End` (mouse-leave)
- 터치 입력: 마우스 움직임과 같음, 동일 터치 포인트에는 동일 InputObject가 쓰인다
- 게임패드 Thumbstick 컨트롤: 위치가 변할 때마다 `Change`

ContextActionService의 경우, 입력 중인 키와 연관된 액션이 unbound되거나 다른 입력과 관련되면 Cancel로 주어진다.

## 이벤트

### InputBegan/Changed/Ended

```luau
UserInputService.InputBegan(
    input: InputObject, gameProcessedEvent: boolean
): RBXScriptSignal
```

두번째 매개변수 `gameProcessedEvent` 는 엔진이 자체적으로 감지해서 이미 어떠한 동작을 치뤘는지 여부입니다

`버튼 클릭`, `스크롤 내림`, `ContextActionService` 등이 발동했을 때 `true` 가 됩니다

## 장치

`UserInputService.GetLastInputType`와 `LastInputTypeChanged`
가장 마지막으로 누른 장치 타입을 알 수 있습니다.

### 마우스

`InputBegan` 에서 감지된 `MouseButton1/2` 의 `InputObject` 는 입력이 종료될 때를 제외하고,
`InputObject.Position` 과 `Delta` 는 업데이트 되지 않습니다.

마우스 위치를 얻을 거면 `InputChanged` 로 감지된 `InputObject` 를 참조하거나 `GetMouseDelta()` 를 사용해야합니다.

마우스와 달리 `Touch` 인 `InputObject` 의 `Position` 는 계속해 업데이트됩니다

### 키보드

`UserInputService:IsKeyDown()` 나 `UserInputService:GetKeysPressed()` 로 구할 수 있습니다.

#### 온스크린 키보드

모바일 전용 키보드입니다.

`OnScreenKeyboardVisible` 현재 보이는지 여부 확인 가능, Read Only 속성입니다.

- `UserInputService.OnScreenKeyboardPosition`: 키보드 위치
- `UserInputService.OnScreenKeyboardSize`: 키보드 크기

키보드와 달리 입력을 감지하는 것이 아닌 `TextBox` 의 텍스트를 입력하는데에만 사용됩니다.

### 게임패드

`IsGamepadButtonDown(UserInputType.Gamepad[n], KeyCode)`로 해당 게임패드의 입력 여부를 확인할 수 있습니다.
