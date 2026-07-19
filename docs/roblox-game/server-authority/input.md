---
title: 서버 권한에서의 입력
---

서버 권한 모델에서 클라이언트가 게임 상태에 영향을 주는 방법은 자신의 입력을 보내는 것뿐입니다.
클라이언트는 입력 결과를 즉시 예측하고, 서버는 같은 프레임의 입력으로 권위 상태를 계산합니다.
클라이언트는 서버 상태가 도착하면 필요할 때 과거 입력을 다시 적용해 재시뮬레이션합니다.

따라서 이동, 점프, 공격, 조준처럼 코어 시뮬레이션에 영향을 주는 입력은 `InputAction`으로 처리합니다.
`UserInputService.InputBegan` 같은 전통 입력 이벤트는 UI, 디버그 단축키처럼
롤백과 무관한 로컬 작업에만 사용합니다.

## 서버 권한에서의 InputAction

서버 권한 모델에서는 클라이언트가 자신의 입력을 즉시 예측하고,
서버는 같은 입력을 받아 권위 상태를 계산합니다.
이후 클라이언트는 서버 권위 상태와 자신의 예측 상태를 비교하고 필요하면 롤백/재시뮬레이션합니다.

이때 시뮬레이션에 영향을 주는 입력은 `InputAction` 으로 읽어야 합니다.
`InputAction` 은 재시뮬레이션 중 같은 프레임의 입력을 다시 적용할 수 있는 구조에 맞춰져 있습니다.

```luau
const RunService = game:GetService("RunService")

const moveAction = player.PlayContext.Move
const jumpAction = player.PlayContext.Jump

RunService:BindToSimulation(function(dt)
    const move = moveAction:GetState()
    const isJumping = jumpAction:GetState()

    print(move, isJumping, dt)
end)
```

서버에 영향을 주는 모든 입력은 여전히 검증해야 합니다.
모든 `InputBinding` 자식이 `ClampMagnitudeToOne` 가 `true` 일 지라도, 해커는 조작할 수 있습니다

## 고정틱에서 읽기

입력 이벤트가 아니라 현재 상태를 `RunService:BindToSimulation()` 안에서 읽습니다.
이 콜백은 클라이언트와 서버 양쪽에서 같은 게임 로직을 실행하는 위치이며,
클라이언트가 롤백되면 과거 프레임부터 다시 호출됩니다.

```luau
const Players = game:GetService("Players")
const RunService = game:GetService("RunService")

const function simulatePlayer(player: Player, dt: number)
    const inputs = player.PlayerGui.Inputs
    const playContext = inputs.PlayContext

    const moveAction = playContext.Move
    const jumpAction = playContext.Jump

    const move = moveAction:GetState()
    const isJumpHeld = jumpAction:GetState()

    -- move와 isJumpHeld로 이 프레임의 이동·점프 시뮬레이션을 계산합니다.
    -- 결과를 바꾸는 상태는 Attribute 또는 Simulation Access 속성에 저장합니다.
    CharacterSimulation.step(player, move, isJumpHeld, dt)
end

if RunService:IsServer() then
    Players.PlayerAdded:Connect(function(player)
        const simulationConn = RunService:BindToSimulation(function(dt)
            simulatePlayer(player, dt)
        end)

        player.AncestryChanged:Once(function()
            simulationConn:Disconnect()
        end)
    end)
else
    RunService:BindToSimulation(function(dt)
        simulatePlayer(Players.LocalPlayer, dt)
    end)
end
```

`StateChanged`, `Pressed`, `Released`는 UI 갱신이나 한 번만 실행되는 로컬 표현에는 편리합니다.
하지만 고정틱 시뮬레이션의 입력 원천으로는 `GetState()`가 더 적합합니다.
입력이 유지되는 동안 이벤트가 다시 발생하지 않을 수 있고, 롤백 중에도 현재 프레임의 값을
명시적으로 읽어야 하기 때문입니다.

## 눌림 순간은 이전 입력 상태와 비교합니다

점프처럼 `Bool` 액션의 상승 에지가 필요한 경우, 이전 틱의 입력값도 롤백 가능한 상태에 저장하고 비교합니다.
일반 Luau 변수에 이전 값을 저장하면 롤백되어도 값이 되돌아가지 않아,
재시뮬레이션 때 점프가 빠지거나 중복될 수 있습니다.

```luau
const function simulateJump(character: Model, jumpAction: InputAction)
    const isJumpHeld = jumpAction:GetState()
    const wasJumpHeld = character:GetAttribute("WasJumpHeld") == true

    -- Attribute는 시뮬레이션 이력에 포함됩니다.
    character:SetAttribute("WasJumpHeld", isJumpHeld)

    if isJumpHeld and not wasJumpHeld then
        CharacterSimulation.tryJump(character)
    end
end
```

`tryJump()`도 점프 가능 여부와 결과 상태를 결정하는 순수한 시뮬레이션 로직으로 작성합니다.

## 다른 플레이어의 입력

기본적으로 한 플레이어의 `InputAction` 상태는 다른 클라이언트에 전달되지 않습니다.
따라서 다른 플레이어의 차량처럼 입력값 자체가 원격 객체의 예측에 필요한 게임이라면,
서버가 입력을 롤백 가능한 `Attribute`에 기록하고 모든 클라이언트가 그 속성을 읽게 합니다.

```luau
const function storeThrottle(player: Player, vehicle: Model)
    const throttleAction = player.Inputs.VehicleContext.Throttle
    const throttle = throttleAction:GetState()

    -- 서버에서 기록한 Attribute는 다른 클라이언트에도 동기화됩니다.
    vehicle:SetAttribute("Throttle", throttle)
end

RunService:BindToSimulation(function(dt)
    if RunService:IsServer() then
        for _, player in Players:GetPlayers() do
            const vehicle = VehicleService.getVehicle(player)

            if vehicle ~= nil then
                storeThrottle(player, vehicle)
            end
        end
    end

    for _, vehicle in VehicleService.getActiveVehicles() do
        const throttle = vehicle:GetAttribute("Throttle") or 0
        VehicleSimulation.step(vehicle, throttle, dt)
    end
end)
```

이 방식에서는 `Throttle`도 시뮬레이션 상태이므로 `BindToSimulation()` 안에서만 갱신합니다.
입력 값이 필요 없는 다른 플레이어 캐릭터는 서버 권위 상태만 렌더링하는 편이 더 단순하며,
불필요한 예측을 줄일 수 있습니다.

## `RemoteEvent`와의 역할 분리

`RemoteEvent`는 득점 알림, UI 요청, 월드 오브젝트 클릭처럼 개별 메시지를 주고받는 데 계속 사용할 수 있습니다.
그러나 고정틱 시뮬레이션을 매 프레임 구동하는 입력의 대체 수단으로 사용하지 않습니다.
`RemoteEvent`는 속성 및 `Attribute` 복제와 항상 같은 순서로 도착한다고 보장되지 않고,
입력 프레임을 엔진이 재시뮬레이션하도록 만들지도 않습니다.

원격 이벤트로 별도 요청을 보내야 한다면 다음을 지킵니다.

- 요청은 의도만 전달하고, 결과와 보상은 서버에서 결정합니다.
- 요청에 프레임 순서나 시뮬레이션 상태가 필요하다면 입력 시스템과 섞지 말고 별도 프로토콜을 설계합니다.
- 롤백으로 다시 실행될 수 있는 `BindToSimulation()` 안에서 원격 이벤트를 보내지 않습니다.

## 디버깅

Server Authority Visualizer에서 다음 값을 함께 확인합니다.

- `Input accept rate`: 서버가 제시간에 처리한 입력의 비율입니다.
- `Input drop reason counts`: 너무 오래된 입력, 순서가 뒤바뀐 입력, 버퍼가 찬 경우처럼 서버가 입력을 버린 이유입니다.
- `Client-server step delta`: 클라이언트와 서버의 프레임 차이입니다. 값이 안정적인지 봅니다.

`Input accept rate`가 낮거나 입력 드롭이 늘면, 클라이언트가 고정틱을 따라가지 못하거나
네트워크 지연이 크게 흔들리는 상황일 수 있습니다. 이런 상태에서 입력을 보완하려고
`RemoteEvent`를 추가하기보다 시뮬레이션 비용, 고정틱 주파수, 입력 처리량을 먼저 점검합니다.

## 작성 기준

- 코어 시뮬레이션 입력은 `Player`의 자손 `InputContext` 아래 `InputAction`으로 만듭니다.
- 입력은 `BindToSimulation()`에서 `GetState()`로 읽습니다.
- 이전 입력값, 쿨다운, 탄약처럼 재시뮬레이션에 필요한 값은 `Attribute` 또는 Simulation Access 상태로 둡니다.
- `InputAction`은 의도만 나타냅니다. 서버가 입력값과 결과를 모두 검증합니다.
- 다른 플레이어의 입력 예측이 필요할 때만 서버가 `Attribute`로 중계합니다.
- 커스텀 `Scriptable` 입력은 렌더 단계에서 넣고, 시뮬레이션 콜백 안에서 주입하지 않습니다.
- 롤백 가능한 시뮬레이션 안에서 `RemoteEvent` 전송, UI 갱신, 효과 재생 같은 외부 부작용을 만들지 않습니다.
