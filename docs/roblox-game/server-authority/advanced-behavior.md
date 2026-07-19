---
title: 서버 권한 동작 (심화)
---

서버 권한의 동작을 보다 상세하고 복잡한 상황에서 다룹니다.

## 재시뮬레이션 환경

`BindToSimulation` 에 재시뮬레이션 중인 경우 연결된 콜백함수에서 파생된 코루틴들은
전부 재시뮬레이션 환경으로 전파됩니다.

```luau
const RunService = game:GetService("RunService")

const bindableEvent = Instance.new("BindableEvent")

RunService:BindToSimulation(function()
	task.spawn(function()
		print(RunService:IsResimulating())
	end)

	task.defer(function()
		print(RunService:IsResimulating())

        task.defer(function()
            print(RunService:IsResimulating())
        end)
	end)

	bindableEvent:Fire(RunService:IsResimulating())
end)

bindableEvent.Event:Connect(function(state)
	print(state, RunService:IsResimulating())
end)
```

### Signal

시그널은 재시뮬레이션 환경에서도 작동됩니다.

예시:

1. 과거 프레임으로 롤백
1. BindToSimulation 재실행
1. SetAttribute 다시 실행
1. Attribute가 다시 변화

### 상태 저장

고정틱 안에서 계산되는 상태는 가능하면 틱 단위로 다시 계산할 수 있어야 합니다.
ServerAuthority 를 사용할 가능성이 있다면, 재시뮬레이션 가능한 상태는 `Attribute` 나 Simulation Access 속성에 둡니다.

```luau
RunService:BindToSimulation(function(dt)
    const currentCooldown = tool:GetAttribute("Cooldown") or 0
    tool:SetAttribute("Cooldown", math.max(0, currentCooldown - dt))
end, Enum.StepFrequency.Hz30)
```

일반 Luau 변수와 테이블은 엔진이 자동으로 롤백하지 않습니다.

```luau
const state = {
    Cooldown = 0,
}
```

고정틱만 사용하는 구조에서는 이런 테이블을 사용할 수 있지만,
추후 ServerAuthority 나 커스텀 롤백으로 옮길 상태라면 다음 중 하나를 선택합니다.

- `Attribute` 로 옮깁니다.
- Simulation Access 속성으로 표현합니다.
- 직접 Snapshot/History 를 구현합니다.

  ```luau
  const currentState = {}
  const statesByFrameNumber = {} :: {
      [number]: State
  }

  RunService:BindToSimulation(function(dt)
      const isResimulating = RunService:IsResimulating()
      const currentCooldown = if not isResimulating
          then statesByFrameNumber[ math.floor(time() * 60) ].Cooldown
          else currentState.Cooldown
  end)
  ```

## 미리 예측되는 프레임 범위는 클라이언트의 핑에 기반합니다

ServerAuthority 에서 클라이언트는 서버 응답을 기다리지 않고,
마지막으로 받은 서버 권위 상태에서 몇 프레임 앞을 미리 시뮬레이션합니다.

이때 몇 프레임을 앞서갈지는 고정된 상수가 아니라 클라이언트와 서버 사이의 지연 시간에 따라 달라집니다.
핑이 높을수록 클라이언트는 더 먼 프레임까지 예측해야 입력 결과를 즉시 보여줄 수 있습니다.

**낮은 지연**:

```
Server  100 101 102 103
Client      102 103 104 105
```

**높은 지연**:

```
Server  100 101 102 103
Client          105 106 107 108
```

위 그림은 정확한 엔진 내부 공식을 뜻하지 않습니다.
중요한 점은 핑이 높을수록 클라이언트가 더 긴 예측 구간을 유지하고,
서버 보정이 오면 더 긴 구간을 되감아 재실행할 수 있다는 것입니다.

## 디버깅

디버깅할 때는 서버 권한 visualizer 의 다음 값을 같이 봅니다.

- `Client-server step delta`: 클라이언트와 서버가 몇 프레임 벌어져 있는지 보여줍니다.
- `Input accept rate`: 서버가 플레이어 입력을 제때 받아 처리한 비율입니다.
- `Input drop reason counts`: 입력이 너무 오래되었거나, 순서가 어긋났거나, 버퍼 문제로 버려진 횟수입니다.

`Client-server step delta` 가 안정적이면 예측 구간도 비교적 안정적입니다.
값이 계속 흔들리면 네트워크 지연이 흔들리거나 서버 시뮬레이션이 안정적으로 따라가지 못하는 상황일 수 있습니다.
