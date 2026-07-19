---
title: 마우스
---

## 움직임 델타값 구하기

IAS 에서의 `MouseDelta` 와 UserInputService 의 `GetMouseDelta()` 는
마우스가 락된 상태에서만 이전 프레임에서 마우스 움직임 델타를 반환합니다

`UserInputService.InputChanged` 에서 마우스 움직임은 마우스 락 상태에서도 작동됩니다

## 스크롤

IAS 에서 `InputBinding.KeyCode` 를 `MouseWheel` 로 하면
마우스 휠의 델타값으로 주었다가 0으로 되돌아갑니다.

그러나 `UserInputType == MouseWheel` 인 `InputObject` 의 `Position` 속성은 -Z 값으로 스크롤 델타값 (주로 -1, 0, 1, 혹은 그 근처의 실수값들) 을 주지만,
IAS 의 `MouseWheel` 은 IAS 에서의 속도값이기에 매 프레임마다 `deltaTime` 을 곱해야합니다.

`RunService:BindToRenderStep` 기준으로 `dt` 를 곱하면 윈도우 디바이스 기준으로 1, -0.5, 0, 0.5, 1 등이 나옵니다.
좀 복잡하게 하드 코딩된 모양, `InputAction.StateChanged` 에 연결하면
`RunService:BindToRenderStep` 에 잡히지 않는 값들도 나오나, 신경쓸 것까진 아닙니다.

:::warn
`UserInputType == MouseWheel` 인 `InputObject` 의
`KeyCode` 는 `Enum.KeyCode.MouseWheel` 가 아니라 `Enum.KeyCode.Unknown` 입니다.
:::
