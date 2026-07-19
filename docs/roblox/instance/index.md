---
title: Instance
---

인스턴스에 대해 다루는 문서입니다.

## 병렬 철학

인스턴스는 모델 단위마다 독립적인 형태로 작동하는 것이 좋습니다.

## 같은 기능 단위들 끼리는 최대한 같은 계층 구조로 묶어요

```sh
# Bad:
ReplicatedStorage
|- ControlModules
   |- init.luau
   |- Controller.luau
   |- Server.server.luau
   |- Client.client.luau

StarterGui
|- ControlGui

StarterPlayer
|- StarterPlayerScripts
   |- InputContexts
      |- PrimaryContext
      |- SecondaryContext

# Good:
ReplicatedStorage
|- ControlModules
   |- init.luau
   |- Controller.luau
   |- Server.server.luau # Inputcontexts 를 Player 자식으로 복제함
   |- Client.client.luau # ControlGui 를 Player.PlayerGui 자식으로 복제함
   |- ControlGui
   |- InputContexts
      |- PrimaryContext
      |- SecondaryContext
```

물론 어쩔 수 없이 계층 구조를 나눠야할 경우도 많겠지만,
패키지처럼 한 기능은 한 폴더나 모델 단위 안에 두는 것을 추천합니다.
