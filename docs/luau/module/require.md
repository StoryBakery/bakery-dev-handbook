---
title: Require Style
---

## 작성 원칙

- **경로 규칙**: 절대 경로 (인스턴스), 상대 경로(`./`, `../`), 자손 경로(`@self/`) 세 가지 방식만 사용합니다.
- **순서**: 블록 간 순서와 빈 줄 규칙을 고정해 가독성과 diff 안정성을 확보합니다.

## 경로 규칙

### 절대 경로

```luau
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Shared = ReplicatedStorage.Shared
const SharedConfig = require(Shared.Config)
```

### 상대 경로

- `script.Parent` 참조 대신 `./` 를 사용합니다.
- 상위로 여러 번 이동할 때는 `../../` 처럼 연결합니다. 부모 디렉토리를 벗어날 때마다 `/` 를 써줍니다.

#### 문자열 require과 인스턴스 경로 기반의 비교

| string-require | instance-require |
| --- | --- |
| `require("./X")` | `require(script.Parent.X)` |
| `require("../X")` | `require(script.Parent.Parent.X)` |
| `require("../../X")` | `require(script.Parent.Parent.Parent.X)` |
| `require("@self/X")` | `require(script.X)` |

#### init.luau

일반적인 파일에서 `./`는 "내가 들어있는 디렉토리"를 뜻하지만, `init.luau`에서는 의미가 조금 달라집니다.
`init.luau` 스크립트는 로블록스 스튜디오에서는 스크립트 안에 스크립트를 넣는다거나, 파일 안에 파일을 넣는 것이 가능하기에
컴퓨터 os 에서 이를 표현하기 위해선, 폴더를 만들고 아래에  `init.-` 을 넣는다면, 해당 폴더를 `init.-`의 진짜 기준으로 삼게됩니다.

그러므로 `./` 는 `init.luau` 의 상위 디렉토리의 상위 디렉토리가 됩니다.

```sh
src/
  GrandParent/
    Parent/
      Sibling.luau
      Script/
        init.client.luau
        Child.luau
    Uncle/
      Cousin/
        init.luau
```

```luau
-- src/GrandParent/Parent/Script/init.client.luau:
-- Good (Parent):
const Parent = require("./")
const GrandParent = require("../")

-- Good (Sibling):
const Sibling = require("./Sibling")
const Cousin = require("../Uncle/Cousin")

-- Bad:
const Parent = require(script.Parent)
```

##### @self

위 `init.luau` 의 특이점때문에, `@self` 란 alias 가 사용됩니다.
`init.luau` 는 파일 경로 기준이 상위 디렉토리 가 자신의 경로이기 때문에 os 기준으로의 형제이며, 로블록스 스튜디오 기준으로 자식인 모듈에 접근하려면,
`./Child` 가 아닌 `@self/Child` 를 해야하기 때문입니다.

현재 모듈의 하위(자식, 자손) 모듈을 불러올 때 사용합니다.
디렉토리가 자기 자신인 `init.luau` 에 쓰입니다.

```luau
-- Good:
const SubModule = require("@self/SubFolder/Module")

-- Bad:
const SubModule = require("./MyScript/SubFolder/Module")
```

## 정렬 규칙

- 같은 블록 안에서는 **알파벳 순**을 기본으로 합니다.
- Require 문 사이에 다른 코드(조건문, 함수 등)를 넣지 않습니다.

<Alert severity="note">
  <AlertTitle>특정 순서를 **강제**해야 한다면?</AlertTitle>

  모듈 간 의존성이 매우 정교하여 로드 순서가 중요한 경우에는 알파벳 정렬을 무시하고 의존 순서를 우선시할 수 있습니다.
  단 그 경우 자동 정렬을 막기위해, 한 줄 씩 띄워야합니다.

  Luau 코드 포매터인 StyLua 는 `sort_requires.enabled` 가 `false` 가 아닌 이상,
  require 문들을 알파벳 순으로 자동으로 정렬합니다.
  이는 바람직한 동작이지만 로드 순서가 중요한 require 블록을 서로 붙이면
  자동 정렬되어 순서가 바뀌게 수 있습니다

  ```luau
  -- Bad:
  const Boo1 = require("@self/Boo1")
  const Cat2 = require("@self/Cat2")
  const Aha3 = require("@self/Aha3")

  -- StyLua 자동 정렬 후:
  const Aha3 = require("@self/Aha3")
  const Boo1 = require("@self/Boo1")
  const Cat2 = require("@self/Cat2")
  ```

  그래서 로드 순서가 중요하다면 한 줄 씩 띄워주어야 합니다.
  가장 좋은 방법은 모듈의 로드 순서가 중요하지 않게 하거나,
  모듈이 `Init`, `Config` 와 같은 초기 설정 함수를 반환하는 객체인 것이 좋습니다

  ```luau
  -- Not Bad:
  const Boo1 = require("@self/Boo1")

  const Cat2 = require("@self/Cat2")

  const Aha3 = require("@self/Aha3")
  ```

  ```luau
  -- Good:
  const Aha3 = require("@self/Aha3")
  const Boo1 = require("@self/Boo1")
  const Cat2 = require("@self/Cat2")

  Boo1.Init()
  Cat2.Init()
  Aha3.Init()
  ```

</Alert>

## 외부 라이브러리 별칭 블록

Require 블록이 끝나면 바로 이어서 별칭 블록을 작성합니다.

1. Require 에서 등장한 모듈 순서를 그대로 따릅니다.
2. 불러온 모듈에서 자주 쓰는 멤버를 지역 `const` 로 캐싱합니다.
3. 새로운 연산 로직을 넣지 않고 단순 할당만 수행합니다.
