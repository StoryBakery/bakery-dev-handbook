---
sidebar_label: Require Style
---

# Require-Style

## 개요

`require` 블록은 Story-Bakery 코드 스타일의 핵심 축입니다. 모든 Require 문은 **문자열 리터럴(String Literal)** 경로만을 사용해야 하며, 인스턴스를 직접 참조하는 방식은 엄격히 금지됩니다. 이를 통해 코드의 의존성을 정적으로 분석 가능하게 만들고, 외부 툴링(Rojo, Luau LSP 등)과의 호환성을 보장합니다.

## 작성-원칙

- **문자열 전용**: `require` 에는 오직 문자열 리터럴만 허용됩니다. `script.Parent`, `game.ReplicatedStorage` 등 인스턴스 참조는 사용할 수 없습니다.
- **경로 규칙**: 절대 경로(`@game/`), 상대 경로(`./`, `../`), 자손 경로(`@self/`) 세 가지 방식만 사용합니다.
- **순서**: 블록 간 순서와 빈 줄 규칙을 고정해 가독성과 diff 안정성을 확보합니다.

## 블록-우선순위

Require 문은 아래 네 가지 묶음으로 나누고, 목록 순서를 반드시 지킵니다.

1. **외부 패키지**
  프로젝트 외부에서 들고온 모듈
  
  주로 `@game/` 접두사로 불러옵니다.
  예: `require("@game/ReplicatedStorage/Packages/vide")`
  
  만약 `default.project.json` 이 없는 파일의 구조일 경우나 패키지의 경우 상대 문자열 require 로 들고옵니다.
  예: `require("../../robhlox_packages/vide")`
  
1. **게임 모듈**
  프로젝트 전체에서 공용으로 쓰이는 모듈
  
  주로 `@game/` 접두사로 불러옵니다. 
  Rojo 의 `default.project.json` 구조를 따릅니다.
  예: `require("@game/ReplicatedStorage/GameModules/BossController")`
  
  만약 `default.project.json` 이 없는 파일의 구조일 경우나 패키지의 경우 상대 문자열 require 로 들고옵니다.
  예: `require("../../GameModules/BossController")`
  
3. **프로젝트 모듈**
  현재 스크립트를 기준으로 부모나 형제 모듈을 불러옵니다.
  예: `require("./Sibling")`, `require("@self/Child")`

4. **자손 모듈**
  패키지 내부에서 깊은 곳에 있는 자식/자손 모듈을 불러올 때 `@self/` 를 사용합니다.
  예: `require("@self/Components/Button")`

## 경로-규칙

### 절대-경로-@game
- Roblox Studio 에서는 `.luaurc` 기반 별칭을 완벽히 지원하지 않으므로, 게임 루트를 의미하는 `@game` 을 사용해 경로를 명시합니다.
- `@game` 은 `game` 서비스(DataModel)를 가리킵니다.
- 주로 `ReplicatedStorage`, `ServerScriptService` 등 최상위 컨테이너에 접근할 때 사용합니다.

```lua
-- Good:
local GlobalConfig = require("@game/ReplicatedStorage/Shared/Config")

-- Bad:
local GlobalConfig = require(game.ReplicatedStorage.Shared.Config)
```

### 상대-경로
- `script.Parent` 참조 대신 `./` 를 사용합니다.
- 상위로 여러 번 이동할 때는 `../../` 처럼 연결합니다. 부모 디렉토리를 벗어날 때마다 `/` 를 써줍니다.

#### 문자열-require과-인스턴스-경로-기반

| string-require       | instance-require                         |
| -------------------- | ---------------------------------------- |
| `require("./X")`     | `require(script.Parent.X)`               |
| `require("../X")`    | `require(script.Parent.Parent.X)`        |
| `require("../../X")` | `require(script.Parent.Parent.Parent.X)` |
| `require("@self/X")` | `require(script.X)`                      |

#### init.luau
일반적인 파일에서 `./`는 "내가 들어있는 디렉토리"를 뜻하지만, `init.luau`에서는 의미가 조금 달라집니다. 
`init.luau` 스크립트는 로블록스 스튜디오에서는 스크립트 안에 스크립트를 넣는다거나, 파일 안에 파일을 넣는 것이 가능하기에
컴퓨터 os 에서 이를 표현하기 위해선, 폴더를 만들고 아래에  `init.-` 을 넣는다면, 해당 폴더를 `init.-`의 진짜 기준으로 삼게됩니다.

그러므로 `./` 는 `init.luau` 의 상위 디렉토리의 상위 디렉토리가 됩니다.

```
src
└── GrandParent
    ├── Parent
    │   ├── Sibling.luau
    │   └── Script
    │       └── init.client.luau
    │       └── Child.luau
    └── Uncle
        └── Cousin
            └── init.luau
```

```lua
-- src/GrandParent/Parent/Script/init.client.luau:
-- Good (Parent):
local Parent = require("./") 
local GrandParent = require("../")

-- Good (Sibling):
local Sibling = require("./Sibling")
local Cousin = require("../Uncle/Cousin")

-- Bad:
local Parent = require(script.Parent)
```

##### @self

위 `init.luau` 의 특이점때문에, `@self` 란 alias 가 사용됩니다.
`init.luau` 는 파일 경로 기준이 상위 디렉토리 가 자신의 경로이기 때문에 os 기준으로의 형제이며, 로블록스 스튜디오 기준으로 자식인 모듈에 접근하려면, `./Child` 가 아닌 `@self/Child` 를 해야하기 때문입니다

현재 모듈의 하위(자식, 자손) 모듈을 불러올 때 사용합니다.
디렉토리가 자기 자신인 `init.luau` 에 쓰입니다.

```lua
-- Good:
local SubModule = require("@self/SubFolder/Module")

-- Bad:
local SubModule = require("./MyScript/SubFolder/Module")
```

## 정렬-규칙

- 같은 블록 안에서는 **알파벳 순**을 기본으로 합니다.
- Require 문 사이에 다른 코드(조건문, 함수 등)를 넣지 않습니다.

## 외부-라이브러리-별칭-블록

Require 블록이 끝나면 바로 이어서 별칭(Alias) 블록을 작성합니다.

1. Require 에서 등장한 모듈 순서를 그대로 따릅니다.
2. 불러온 모듈에서 자주 쓰는 멤버를 로컬 변수로 캐싱합니다.
3. 새로운 연산 로직을 넣지 않고 단순 할당만 수행합니다.

## 작성-절차

1. 필요한 모듈을 **외부 → 게임 모듈 → 프로젝트 모듈 -> 자손** 순으로 분류합니다.
2. 모든 경로는 문자열 리터럴로 작성합니다. 인스턴스 체이닝(`script.Parent...`)이 보이면 즉시 수정합니다.
3. 각 묶음 안에서 알파벳 순으로 정렬합니다.

```lua
-- 예시
local vide = require("@game/ReplicatedStorage/Packages//vide") -- 1. 외부 패키지

local BossController = require("@game/ReplicatedStorage/GameModules/BossController") -- 2. 절대 경로
local UserData = require("@game/ServerScriptService/Data/UserData")

local ParentContext = require("./Context") -- 3. 상대 경로
local Strings = require("./Strings")

local Child = require("@self/Child") -- 4. 자손 경로
```