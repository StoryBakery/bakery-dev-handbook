---
title: 고정틱에서 표현
---

고정틱은 게임 결과를 계산하고, 표현은 그 결과를 플레이어에게 보여줍니다.

- UI 갱신
- 카메라 갱신
- 캐릭터, 무기, 투사체의 시각적 보간
- 애니메이션, VFX, SFX 재생
- 히트마커, 데미지 숫자, 화면 흔들림 같은 로컬 피드백

## 히트박스와 시각 파트를 분리해요

런타임 도중 생성되고 사라지는 히트박스라면 물리, 히트스캔, 의 역할로만 처리하고 시각 용도로 사용하진 않습니다.

클라이언트에서 보는 파트들이 히트박스를 부드럽게 따라가는 식으로 보여주면 됩니다.

시각 용도로 사용해도 되는 경우는 서버 기반으로 스트리밍 LOD SLIM 을 적용해야하는 맵 파트들 등.

## 부드럽게 하기

### 보간으로 부드럽게 하기

고정틱은 일정한 간격으로 상태를 바꾸지만, 렌더링은 플레이어의 프레임 레이트에 따라 더 자주
일어날 수 있습니다. 위치, 회전, 게이지처럼 연속적으로 보이는 값은 이전 고정틱 상태와 현재
고정틱 상태 사이를 보간해서 보여줍니다.

보간은 시각용 대상에만 적용합니다.
판정 파트, 서버 권위 위치, 쿨다운 원본 값처럼 게임 결과에 쓰이는 값은 보간된 표시 값을
다시 읽어 결정하지 않습니다.

```luau
-- HitboxHandler.server.luau
RunService:BindToSimulation(function(dt)
    const newCFrame = hitboxPart.CFrame * CFrame.new(0, 0, -hitboxPart:GetAttribute("Speed") * dt)
    hitboxPart.CFrame = newCFrame
end, Enum.StepFrequency.Hz30)

-- HitboxVisulaizer.client.luau
local currentTick: number =
local currentHitboxCFrame: CFrame = CFrame.identity

-- priority 를 math.huge 로 줘서 가장 마지막에 실행되게 합니다.
RunService:BindToSimulation(function(dt)
    hitboxCFrameInLatestTick = hitboxPart.CFrame
end, Enum.StepFrequency.Hz30, math.huge)

RunService.RenderStepped:Connect(function(dt)
    visual.Elapsed = math.min(FIXED_DT, visual.Elapsed + dt)

    const alpha = visual.Elapsed / FIXED_DT
    ProjectileVisual:PivotTo(visual.previousCFrame:Lerp(visual.currentCFrame, alpha))
end)
```

위 예시의 `ProjectileVisual` 은 표시용 모델입니다.
실제 충돌 판정이나 데미지 계산은 `ProjectileState` 의 고정틱 상태를 기준으로 처리합니다.

## 결정론적 애니메이션과 VFX 를 사용합니다

예측 시뮬레이션에서는 클라이언트가 발생할 것이라고 예측했지만 서버에서 실제로 발생하지 않은 이벤트에 대해
효과나 사운드가 트리거될 수 있습니다.
렌더링 시스템은 잘못 예측된 효과를 "되돌릴" 수 있도록 준비되어 있어야 합니다.

그러므로 애니메이션이나 VFX 는 시간을 되돌릴 수 있거나 중지할 수 있는 것이 좋습니다.

### 지연 시간을 고려해 즉각 발동 보다 약간의 딜레이가 있는 것이 좋습니다

특정 게임플레이 메커니즘은 다른 메커니즘보다 네트워크 멀티플레이어에 더 적합합니다.
플레이어들은 다른 플레이어가 행동을 취한 후 그 입력을 수신하는 데 항상 약간의 지연 시간을 갖게 됩니다.
매우 매끄러운 멀티플레이어 경험을 구현하는 가장 좋은 방법은 이러한 제약 조건을 염두에 두고 게임을 설계하는 것입니다.

예를 들어, 플레이어 이동 가속도가 느린 환경은 가속도가 빠른 환경보다 더 부드럽게 느껴집니다.
이는 플레이어 입력의 네트워크 지연으로 인한 위치 차이가 가속도가 빠른 환경보다 작기 때문입니다.

또 다른 예로, 플레이어가 입력 버튼을 눌러 즉시 큰 폭발을 일으킬 수 있는 게임플레이 메커니즘은,
마치 도화선에 불을 붙이는 것처럼 입력 후 폭발이 지연되는 방식보다 네트워크 오류가 더 많이 발생합니다.

후자의 경우, 폭발 효과 대신 도화선 효과에 재시뮬레이션을 적용함으로써 네트워크 오류가 덜 두드러지게 나타납니다.
