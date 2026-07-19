---
title: 서버 권한 동작
---

서버는 게임 상태의 최종 권위자입니다

클라이언트는 입력 결과를 서버 응답보다 먼저 예측해 보여줍니다.
이후 서버에서 해당 프레임의 권위 상태가 도착하면, 클라이언트는 과거에 자신이 예측했던 동일 프레임 상태와 비교합니다.

두 상태가 다르면 다음 순서로 처리됩니다.

1. 서버 권위 상태 수신
1. 과거 예측 상태와 비교
1. 불일치 감지
1. 권위 프레임으로 롤백
1. 해당 프레임 이후 입력 재적용
1. 현재 예측 프레임까지 재시뮬레이션

재시뮬레이션 중에는 `RunService:BindToSimulation()`에 등록된 함수가 과거 프레임부터 현재 프레임까지 다시 실행됩니다.
이는 한 프레임 안에서 바로 일어나게 됩니다.

## `BindToSimulation()`

`BindToSimulation` 은 `AuthorityMode` 를 `Server` 로 설정하면 롤백 기능까지 추가됩니다.

## Instance

### 예측 상태

`RunService:SetPredictionMode(context: Instance, mode: Enum.PredictionMode)`으로 예측 상태로 설정할 수 있습니다.

- `Enum.PredictionMode.Automatic`:

  엔진은 이 인스턴스를 예측해야 할지 여부를 자동으로 결정합니다.
  `LocalPlayer.Character` 로 할당된 휴머노이드 근처의 `BasePart` 들이 자동으로 미리 예측됩니다
  반경은 장치 성능에 따라 커집니다.

- `Enum.PredictionMode.On`: 해당 인스턴스를 미리 예측합니다
- `Enum.PredictionMode.Off`: 서버 상태에 맡깁니다

미리 예측되고 있지 않은 인스턴스라도 `studioAccess: true` 인 속성이 다르다면 롤백 됩니다.

### Property

예측되지 않은 인스턴스일지라도, `simulationAccess: true` 인 속성은 변경시마다 각 프레임마다의 값들이 저장되어
롤백 시 당시 프레임의 속성으로 돌아가 다시 계산됩니다.

`simulationAccess: true` 가 없는 속성은 프레임별 이력이 저장되지 않으므로,
롤백되어도 과거 시뮬레이션 프레임의 값으로 되돌아가지 않습니다.

예로 들자면 `Name`, `Parent` 등

### Attribute

Attribute는 기본적으로 `simulationAccess: true` 이기 때문에
사용자 정의 게임 상태를 롤백 가능한 형태로 저장하는 주된 방법입니다.

예측된 Instance의 Attribute를 `BindToSimulation()` 안에서 변경하면 서버와 클라이언트의 값이 비교되고,
불일치하면 롤백과 재시뮬레이션이 발생합니다.

```luau
RunService:BindToSimulation(function(dt)

    const health = object:GetAttribute("Health")
    object:SetAttribute("Health", health + HEALTH_REGENERATION_PER_SEC * dt)

end, Enum.StepFrequency.Hz30)

DamageRequested:Connect(function(damage)

    const health = object:GetAttribute("Health")
    object:SetAttribute("Health", health + HEALTH_REGENERATION_PER_SEC * dt)

end)
```

### 엔진은 인스턴스 접근만 롤백해주며, 일반 변수는 롤백되지 않습니다

```luau
const state = {
    health = 100,
}

local isDead = false
```

luau 환경에서 정의된 것들은 엔진이 롤백 환경에서도 롤백하지 않습니다.
이런 상태는 다음 중 하나가 필요합니다

- Attribute나 Simulation Access 속성으로 이동
- RunService.Rollback에서 직접 복원
- 자체 Snapshot/History 구현

## `RunService.Rollback`

엔진이 재시뮬레이션을 시작하기 전에 발동되는 이벤트입니다.

여러가지 용도로 사용할 수 있습니다.

- 사용자 정의 History 복원
- 롤백 감지

```luau
RunService.Rollback:Connect(function(rollbackTime)
    -- 사용자 정의 History 복원
end)
```

## 인스턴스 스티칭

클라이언트 스크립트가 `RunService:BindToSimulation()` 콜백 내에서 예측적으로 인스턴스를 생성할 수 있습니다.
클라이언트는 서버와의 왕복 통신을 기다리지 않고 즉시 인스턴스를 생성합니다.
이후 서버의 데이터가 도착하면, 클라이언트가 생성한 인스턴스와 서버의 공식 사본이 하나로 병합됩니다.
스크립트의 관점에서 보면 인스턴스는 즉시 존재하며 서버와도 일관성을 유지하게 됩니다.

인스턴스 스티칭은 클라이언트에서 인스턴스가 가능한 한 빨리 보이고 활성화되어야 하는 상황에서 유용합니다.
서버가 결국 클라이언트가 필요로 하는 모든 인스턴스를 복제하겠지만,
이 과정은 서버 통신으로 인해 최소 한 번의 왕복 네트워크 지연을 발생시킵니다.

대표적인 예로 로켓 런처 발사나 물리적 제약 조건 생성을 들 수 있습니다.
스티칭을 사용하지 않으면, 클라이언트는 로켓이 자신에게서 멀리 떨어진 곳에서 갑자기 나타나거나
새로운 제약 조건이 복제될 때 약간의 끊김 현상(jitter)을 보게 될 것입니다.
