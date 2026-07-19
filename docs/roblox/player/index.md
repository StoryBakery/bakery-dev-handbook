---
title: 플레이어
---

플레이어에 대한 정리 문서입니다.

## LocalPlayer 는 `localPlayer` 로 저장합니다

일반적으로 클라이언트 스크립트에서 `Players.LocalPlayer` 를 `player` 변수에 저장하는 경우가 많으나,
이 경우 다른 플레이어와 구분하기 어렵습니다.
일관성을 위해 해당 커뮤니티 관습은 사용하지 않습니다. `localPlayer` 로 고정합니다.

```luau
-- Bad:
const Players = game:GetService("Players")

const player = Players.LocalPlayer

-- Good:
const Players = game:GetService("Players")

const localPlayer = Players.LocalPlayer
```

## 플레이어 자식 복제

`PlayerGui` 는 어떠한 상황에서도 `WaitForChild` 를 사용할 필요가 없습니다.

다음과 같은 상황을 고려해 `WaitForChild` 사용 여부를 결정하세요.

**`ReplicatedFirst` 에 있지않은 클라이언트 스크립트가 바로 `LocalPlayer` 에 접근시**:

- `PlayerGui` 와 `PlayerScripts` 에 접근 가능
- `StarterGui` 와 `StarterPlayerScripts` 에 있는 인스턴스들이 전부 복제돼있음

**`ReplicatedFirst` 에 있는 클라이언트 스크립트가 바로 `LocalPlayer` 에 접근시**:

- `PlayerGui` 와 `PlayerScripts` 에 접근 가능
- `StarterGui` 와 `StarterPlayerScripts` 에 있는 인스턴스들이 복제되지 않음

**서버 스크립트가 `PlayerAdded` 로 넘겨진 `Player` 에 바로 접근시**:

- `PlayerGui` 만 접근 가능
- `StarterGui` 에 있는 인스턴스들이 복제되지 않음
- `PlayerScript` 는 생성되지 않음

**에딧모드에서 `LocalPlayer` 접근시**

- 스튜디오 에딧모드에선 `PlayerGui` 는 생성되지 않음

그러나 에딧모드에선 접근할 이유가 없습니다.
만약 플러그인이 에딧모드에서 `PlayerGui` 에 접근해야할 이유가 있다면
`PlayerGui` 대신 `CoreGui` 에 접근하면 됩니다.

```luau
-- 플러그인이 접근하지 않을 모듈이라면 할 필요 없습니다
const playerGui = if RunService:IsRunning()
    then localPlayer.PlayerGui
    else game:GetService("CoreGui")
```

## `StarterPlayerScripts` 와 `StarterCharacterScripts` 는 더이상 사용하지 않아요

`Script.RunContext` 과 `ServerAuthority` 의 도입으로 사용되지 않고 있어요.

`PlayerModule` 은 `StarterPlayer` 서비스의 자식으로만 되어서
복제되는 것이 아닌, 플레이어 전용 스크립트란 의미를 두고만 있고요.

심지어 `PlayerScripts` 는 `Not Replicated` 클래스로 서버에는 플레이어 자식으로 복제되지 않아,
레거시 로컬스크립트나 모듈스크립트만 둘 수 있었는데
기본 `PlayerModule` 도 서버권한 모델에선 StarterPlayer 에 위치되었기 때문에, 사용할 이유가 사라졌습니다.

또한 `StarterCharacterScripts` 또한 기능 단위의 묶음으로는 굉장히 별로인 컨테이너이며,
기본 로블록스 캐릭터 생성 기능은 부족한 면이 많은 만큼, 클라이언트 컨텍스트의 스크립트가 더 좋습니다.
