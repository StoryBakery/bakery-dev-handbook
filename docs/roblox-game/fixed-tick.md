---
title: 고정틱
---

모든 로블록스 게임은 `workspace.UseFixedSimulation = Enum.RolloutState.Enabled` 이어야합니다.
보다 안정적인 환경을 제공하며, ServerAuthority 를 사용할 수 있기 때문입니다.

`AuthorityMode` 가 `Server` 라고 가정하지 않은채 설명하는 문서입니다.
로블록스 기본 롤백 시스템 없이 고정틱만 사용하는 경우도 많기 때문입니다.

## 이벤트

### 가변프레임 시뮬레이션

구 게임들은 가변틱의 시뮬레이션으로 주기 이벤트로써 `Heartbeat`, `RenderStepped` 말고도,
물리 이전 시뮬레이션인 `PreSimulation`, `Stepped`
물리 이후 시뮬레이션인 `PostSimulation`, `Heartbeat` 들을 사용했습니다.

이 때 `Heartbeat`는 물리 시뮬레이션이 멈춰도 작동은 하는 물리 이전 이벤트로 쓰이는 이벤트이었습니다

그러나 고정틱 시뮬레이션인 `BindToSimulation` 이 추가되었기에 `Heartbeat`와 `RenderStepped` 를 제외하곤 사용하지 않습니다.

**현재 사용되는 이벤트**

- `Heartbeat`: 서버 및 클라이언트에서 매 프레임 실행되는 가변 프레임 이벤트. 롤백이나 고정 틱 시뮬레이션이 필요하지 않은 작업에 사용한다.
- `RenderStepped`: 클라이언트에서 매 프레임 실행되는 가변 프레임 이벤트. 롤백이나 고정 틱 시뮬레이션이 필요하지 않은 작업에 사용한다.
- `BindToRenderStep`: 실행 우선순위를 지정할 수 있는 클라이언트 전용 가변 프레임 이벤트. `RenderStepped`보다 우선 실행됩니다.
- `BindToSimulation`: 서버, 클라이언트에서 사용 가능한 고정틱 시뮬레이션

### 시그널은 외부에서

시뮬레이션 콜백 안에서 매 틱마다 Signal 연결을 만들거나 비동기 작업을 시작하지 않습니다.

```luau
-- Bad
RunService:BindToSimulation(function(dt)
    object:GetAttributeChangedSignal("Health"):Connect(onHealthChanged)
    task.spawn(expensiveWork)
end)
```

연결은 바깥에서 한 번 만들고, 고정틱 안에서는 현재 틱의 상태 계산만 수행합니다.

```luau
-- Good
object:GetAttributeChangedSignal("Health"):Connect(onHealthChanged)

RunService:BindToSimulation(function(dt)
    updateHealth(dt)
end)
```

### `GetPropertyChangedSignal()`의 한계

`GetPropertyChangedSignal()`은 모든 속성 변경의 완전히 감지하지 않습니다.

특히 엔진 자체로 물리로 인해 다음 속성이 바뀌는 경우 Signal이 발화하지 않습니다.

- `CFrame`
- `AssemblyLinearVelocity`
- `AssemblyAngularVelocity`

자주 변하는 속성도 모든 변경마다 Signal을 발생시키지 않거나 아예 발생시키지 않을 수 있습니다.

따라서 물리 상태 변화 자체를 감지하려면 다음이 더 적절합니다.

- BindToSimulation에서 매 틱 상태 확인
- 이전 틱 상태와 현재 틱 상태 직접 비교

## `BindToSimulation`

`BindToSimulation` 은 프레임 레이트와 독립된 고정 주기로 함수를 실행합니다.
`Workspace.UseFixedSimulation` 이 켜져 있을 때만 사용할 수 있습니다.

```luau
const RunService = game:GetService("RunService")

const simulationConn = RunService:BindToSimulation(function(dt)
    -- 게임 결과를 바꾸는 고정틱 로직
end, Enum.StepFrequency.Hz30, 2000)

simulationConn:Disconnect()
```

인자는 다음 순서로 받습니다.

- `function`: 시뮬레이션 틱마다 실행할 콜백 함수. `dt` 를 인자로 받습니다.
- `frequency`: 실행 주기. 기본값은 `Enum.StepFrequency.Hz30` 입니다.
- `priority`: 같은 시뮬레이션 틱 안에서의 실행 순서. 기본값은 `2000` 입니다.

`priority` 는 숫자가 낮을수록 먼저 실행됩니다.
같은 우선순위끼리의 실행 순서는 보장되지 않으므로, 순서가 중요한 로직은 명시적으로 다른 우선순위를 사용합니다.

```luau
const SIMULATION_PRIORITY = {
    Input = 1000,
    Movement = 2000,
    Hit = 3000,
    State = 4000,
}

RunService:BindToSimulation(function(dt)
    -- 입력 스냅샷 처리
end, Enum.StepFrequency.Hz30, SIMULATION_PRIORITY.Input)

RunService:BindToSimulation(function(dt)
    -- 이동 계산
end, Enum.StepFrequency.Hz30, SIMULATION_PRIORITY.Movement)
```

### 주파수 선택

기본값인 `Hz30` 을 기준으로 사용합니다.

`Hz60` 은 입력감과 물리 제어가 민감한 캐릭터, 차량, 투사체처럼 더 촘촘한 시뮬레이션이 필요한 경우에만 사용합니다.
틱 주기를 올리면 서버와 클라이언트 모두 같은 로직을 더 자주 실행하므로 비용도 함께 증가합니다.

느린 시스템은 낮은 주기를 사용할 수 있습니다.
예를 들어 초 단위로만 변하는 환경 상태나 느린 재생성 타이머는 `Hz15`, `Hz10`, `Hz5`, `Hz1` 같은 낮은 주기가 더 적절할 수 있습니다.

서로 강하게 의존하는 게임 로직은 같은 주파수에 두는 편이 좋습니다.
서로 다른 주파수에 나누면 한 시스템은 이미 다음 상태로 넘어갔지만 다른 시스템은 아직 이전 상태를 보고 있는 틱 차이가 생길 수 있습니다.

### 무엇을 넣을지

게임 결과를 바꾸는 로직은 `BindToSimulation` 에 둡니다.

- 입력 스냅샷 처리
- 이동과 물리 제어
- 충돌 검사와 히트 판정
- 쿨다운과 지속시간 계산
- 체력, 탄약, 게이지 변경
- 게임 상태 머신
- 예측과 서버 검증에 필요한 상태 변경

반대로 표현 로직이나 외부 부작용은 고정틱에서 분리합니다.

- UI 갱신
- 카메라 갱신
- VFX 와 SFX
- `RemoteEvent` 전송
- DataStore 저장
- 분석 로그
- 업적, 결제, 보상 지급

이런 작업은 확정된 시점에서 한 번만 실행하거나, 중복 실행되어도 안전하도록 별도 큐와 중복 제거 키를 둡니다.
ServerAuthority 환경에서는 롤백 후 같은 틱이 다시 실행될 수 있기 때문입니다.

## 프레임

### 고정틱 프레임으로 계산하기

고정틱 로직은 실제 시각보다 고정틱으로 계산된 `dt` 를 기준으로 작성합니다.

```luau
local elapsed = 0

RunService:BindToSimulation(function(dt) -- 언제나 1/30 인 0.03333333333
    elapsed += dt

    if elapsed >= 1 then
        elapsed -= 1
        -- 1초마다 실행되는 시뮬레이션 로직
    end
end, Enum.StepFrequency.Hz30)
```

`time()` 은 `UseFixedSimulation` 환경에서 고정 스텝 프레임 시간을 따릅니다.
반면 `workspace:GetServerTimeNow()` 는 실제 서버 시간에 가까운 값을,
`os.clock` 은 컴퓨터 상 시간을 반환하므로, 고정틱의 상황에선 사용되지 않습니다.

```luau
-- 부적절할 수 있음: 실제 시간에 직접 의존
if workspace:GetServerTimeNow() >= cooldownEndTime then
    attack()
end
```

쿨다운, 지속시간, 예약 실행은 틱 기반 값으로 관리하는 편이 명확합니다.

```luau
const cooldown = tool:GetAttribute("Cooldown") or 0

if cooldown <= 0 then
    attack()
    tool:SetAttribute("Cooldown", 0.5)
end
```

### `time()`

#### `time()` 으로 `FrameNumber` 구하기

`RunService.FrameNumber` 로 현재 프레임 Id 정수값을 구할 수 있지만, 권한 부족으로 실패합니다.
그래서 `math.floor(time() * 60)`

#### 게임이 실행 중이 아닌 경우 `time()` 은 `0` 만 반환합니다

게임이 실행중이 아닌 경우 `time()` 은 `0` 만 반환하며
`BindToSimulation` 또한 작동되지않습니다.

#### `workspace:GetServerTimeNow()` 과의 차이

롤백 시뮬레이션에서는

## 게임 플레이

### 가변 프레임과 역할 분리

고정틱은 게임 결과를 계산하고, 가변 프레임은 그 결과를 보여줍니다.

```luau
RunService:BindToSimulation(function(dt)
    MovementSimulation.Step(dt)
    CombatSimulation.Step(dt)
end, Enum.StepFrequency.Hz30)

RunService:BindToRenderStep(
    `CameraControllerUpdate_{cameraManagerId}`,
    CAMERA_CONTROLLER_UPDATE_PRIORITY,
    function(dt)
        CameraController.Update(dt)
    end
)

RunService.RenderStepped:Connect(function(dt)
    HudController.Update(dt)
end)
```

`BindToSimulation` 안에서 직접 쓸 수 없는 표현용 속성은 `Attribute` 에 저장한 뒤,
`PostSimulation`, `Heartbeat`, `RenderStepped` 에서 읽어 반영합니다.

```luau
RunService:BindToSimulation(function(dt)
    const reloadTime = weapon:GetAttribute("ReloadTime") or 0
    weapon:SetAttribute("ReloadTime", math.max(0, reloadTime - dt))
end, Enum.StepFrequency.Hz30)

RunService.RenderStepped:Connect(function()
    reloadLabel.Text = `{weapon:GetAttribute("ReloadTime") or 0}`
end)

-- 자주 바뀌지 않는다면 ChangedSignal 을 사용하는 것이 성능 상 좋습니다
weapon:GetAttributeChangedSignal("ReloadTime"):Connect(function()
    reloadLabel.Text = `{weapon:GetAttribute("ReloadTime") or 0}`
end)
```
