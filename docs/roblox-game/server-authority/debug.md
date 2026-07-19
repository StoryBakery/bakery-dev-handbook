---
title: 서버 권한 디버그
---

## Misprediction

```luau
RunService.Misprediction(
    time: number, instances: {any}, stats: Dictionary
): RBXScriptSignal
```

플러그인 혹은 OpenCloud 를 통한 테스트에서만 사용할 수 있습니다

**매개변수**

**time**

시뮬레이션이 시작된 시점부터 클라이언트의 예측 상태가 서버의 권한 있는 상태와 처음으로 달라진 시점까지의 시간입니다. 단위는 초입니다.

**instances**

```luau
{
    Instance: Instance,
    Properties: {
        [string]: {
            Authoritative: any,
            Predicted: any,
        },
    }?,
    Attributes: {
        [string]: {
            Authoritative: any,
            Predicted: any,
        },
    }?
}
```

상태 불일치가 발생한 인스턴스와 해당 인스턴스의 속성 및 특성 정보를 담고 있습니다.

- `Authoritative`: 서버에서 확정한 권한 있는 값
- `Predicted`: 클라이언트가 예측한 값

**stats**

```luau
{
    ResimulationTime: number -- 재시뮬레이션에 소요된 시간 또는 상태가 되돌려진 시간의 양입니다.
}
```
