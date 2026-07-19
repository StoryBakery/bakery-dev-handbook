---
title: 시뮬레이션 액세스
---

속성/메소드의 사용은 메타데이터 `simulationAccess: boolean` 에 따라 동작이 달라집니다

[로블록스 엔진 API]를 확인하면 클래스의 속성이나 메서드에 `simulationAccess: true` 가 있는 경우에만
시뮬레이션 함수에서 올바르게 사용할 수 있습니다.

`simulationAccess: true` 인 속성들의 예시는 다음과 같습니다

- `BasePart.CFrame`
- `BasePart.AssemblyLinearVelocity`
- `BasePart.AssemblyAngularVelocity`

`simulationAccess: true` 인 메소드들의 예시는 다음과 같습니다

- `Instance:GetAttribute()`
- `Instance:SetAttribute()`
- `Workspace:GetPartsInPart()`
- `Workspace:Shapecast()`

[로블록스 엔진 API]: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/

## `simulationAccess: true` 인 속성

`BindToSimulation` 콜백 함수 내에서 쓰기 가능, 읽기 가능합니다.

또한 해당 속성들은 롤백 시작 시, 과거에 기록된 값으로 인덱스됩니다.

## `simulationAccess: null` 인 속성

`simulationAccess: true` 가 있지 않은 속성을 `BindToSimulation` 콜백 함수 내에서 쓰기 시 오류가 발생합니다

```text
Writing to Instance.Name is not allowed for simulation callbacks
```

읽기는 가능하나 변화가 기록되지 않기에, 롤백 도중에도 동일한 값으로 가져와지며 써집니다.

<Alert severnity="note">
<AlertTitle>`BindToSimulation` 콜백 내에서 발동된 코루틴에서는 쓰기가 가능합니다</AlertTitle>

`BindToSimulation` 을 통해 또다른 코루틴에서 `simulationAccess: true` 가 아닌 속성을
쓰려고 한다면 오류는 나지 않지만, 롤백 환경에서 이전의 속성이 기록되진 않아 재시뮬레이션시,
그 프레임에서 기록된 값으로 나오진 않습니다.

그렇기에 `BindToSimulation` 내에서 다음 콜백함수가 또 다른 코루틴에서 실행되게 만들고

- `task.spawn(callback)`
- `task.defer(callback)`
- `coroutine.wrap(callback)()`
- `Signal:Fire() -> Signal:Connect(callback)`

```luau
const setBallNameRequested = Signal.Immediate.new() -- task.spawn 으로 만들어진 커스텀 Signal 라이브러리
const Ball = getBall()

const function getFrameNumber(): number
    return math.floor(time() * 60)
end

setBallNameRequested:Connect(function(newName: string)
    Ball.Name = newName
end)

RunService:BindToSimulation(function()
    const frameNumber = getFrameNumber()

    setBallNameRequested:Fire( `Ball_{frameNumber}` )
    print(Ball.Name) --> Ball_{frameNumber} 출력, 재시뮬레이션 되는 동안에도
end)

RunService.Rollbacked:Connect(function()
    print("Rollbacking!")
end)
```

로블록스가 완전 엄격하게까지 막으려고 하진 않는 모양입니다.
</Alert>

## `simulationAccess: true` 인 메소드

BindToSimulation 콜백 함수 내에서 쓰기 가능, 읽기 가능합니다

## `simulationAccess: null` 인 메소드

쓰기 시 오류 대상, 읽기는 가능하나 과거의 값으로 반환되지 않음.
