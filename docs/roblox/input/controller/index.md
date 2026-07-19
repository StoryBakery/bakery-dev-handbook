---
title: 컨트롤러
---

플레이어가 어떻게 움직이는지, 행동하는지 결정하는 컨트롤러에 대해 이야기합니다

## `PlayerModule` 과 `Animate` 스크립트

일반적으로 `workspace.PlayerScriptsUseInputActionSystem = Enabled` 를 활성화해두는 것이 좋습니다.
`PlayerModule` 을 사용하지 않고 커스텀 컨트롤러를 사용해도, 다음 속성은 켜두는 것이 좋습니다.

### 새로운 `PlayerScriptsUseInputActionSystem` 의 동작

```sh
# 구 동작 (workspace.PlayerScriptsUseInputActionSystem = Disabled):
StarterPlayer
|- StarterCharacterScripts
|  |  # 게임 시작시 자동생성은 안되지만, 있으면 캐릭터 스폰시
|  |  # 생성되는 Animate 스크립트가 해당 스크립트로 대체됩니다.
|  |- Animate.local.luau
|- StarterPlayerScripts
   |  # 게임 시작시 자동생성됩니다, 이미 존재한다면 기존 모듈 스크립트가 덮어씌웠습니다.
   |  # Player.PlayerScripts 에 들어갑니다.
   |- PlayerModule.luau

# 현재 (workspace.PlayerScriptsUseInputActionSystem = Enabled):
StarterPlayer
|- StarterCharacterScripts
|  |  # 레거시 LocalScript 에서 Client 컨텍스트의 Script로 변경되었습니다.
|  |- Animate.luau
|     |- RunAnimate.Client.client.luau
|     |- RunAnimate.Server.server.luau
|     |- ...
|
|  # 이제 거의 사용되지 않습니다, 물론 복제 동작은 있으나 `Player.PlayerScripts` 자체가
|  # 복제 딜레이로 인한 한계로 크게 유용한 느낌은 아니게 됐습니다
|- StarterPlayerScripts
|  # 게임 시작시, StarterPlayer.CreateDefaultPlayerModule = true 이면 자동생성됩니다,
|  # 중복된 이름의 모듈 스크립트가 있다 하더라도 이제 자동생성합니다.
|  # 더이상 복제되지 않고 내부의 Client 컨텍스트(로컬 플레이어 하나)와
|  # Server 컨텍스트의 스크립트(모든 플레이어)가 다루게 됩니다
|- PlayerModule.luau
   |- InputContexts # 서버에서 Player 자식으로 복제함.
   |- InputSetup.server.luau
   |- PlayerScriptsLoader.client.luau
   |- ...
```

구 동작은 사용되지 않으며 추천되지 않습니다.

### PlayerModule 비활성화 방법

`workspace.PlayerScriptsUseInputActionSystem = Enabled` 활성화 후
`StarterPlayer.CreateDefaultPlayerModule = false` 를 합니다

그렇다면 커스텀화된 컨트롤러 시스템을 만들고 사용하면 됩니다.

### Animate 비활성화 방법

`Animate` 스크립트 같은 경우엔, 꼭 교체할 필요는 없지만 액션 게임과 같은
커스텀화된 애니메이션 시스템을 두는 경우,
자체적인 캐릭터 애니메이션 클라이언트 스크립트를 두는 것이 좋습니다.

`Animate` 란 똑같은 이름으로 비어있는 모듈을
`StarterCharacterScripts` 와 `StaterPlayer` 에 두는 것입니다.

혹은 `Player:LoadCharacterAsync` 가 아닌,
`Animate` 모듈이 없는 캐릭터 모델에 `HumanoidDescription` 을 적용하는 방법이 있습니다
