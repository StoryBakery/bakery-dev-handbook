---
title: Structure Style
---

스크립트 파일의 내부 레이아웃과, 코드를 함수/모듈 단위로 나누는
구조적 원칙을 정의합니다.

## 코드 블록 순서

스크립트 파일은 아래 순서를 따릅니다.

### 1. 지시어

`--!strict`, `--!native`, `--!nolint` 등.

Luau 파일은 기본적으로 `--!strict` 를 사용합니다.
다른 지시어가 있다면 `--!strict` 를 가장 위에 둡니다.

### 2. 블록 주석

파일의 설명입니다.
API 문서의 경우 bakerywave 의 문서 주석을 사용합니다

### 3. 서비스

`const ... = game:GetService("...")` 의 모음입니다.

알파벳 순으로 정렬합니다.

### 4. Require

모듈스크립트 require 블록의 모음입니다.

require 블록의 순서는 다음과 같습니다.

#### 4-1. 공통 조상

`const MyProject = script.Parent.Parent` 같은 형태를 의미합니다.

공통 조상이 필요없이 문자열 상대경로만으로 전부 `require` 할 수 있다면 정의하지 않습니다.
luau 스크립트가 아닌, 로블록스에서 상대경로로 공통 조상에서 인스턴스 참조를 해야하는 경우에 쓰입니다.

```luau
const MyProject = script.Parent.Parent.Parent

const Package1 = require("../../../Packages/Package1")
const Package2 = require("../../../Packages/Package2")
const Package3 = require("../../../Packages/Package3")

const LocalizationTable = MyProject.LocalizationTable
```

 `MyProject` 는 예시일 뿐, 공통 조상의 주소를 담은 변수의 이름은, 상황에 맞게 변경합니다.

플러그인의 경우, 프로젝트의 이름이 플러그인의 이름이 되고
패키지의 경우, `Package` 가 됩니다.

```luau
-- repo/SomeEditor
-- 플러그인의 경우, 공통 조상 이름은 플러그인 이름
const SomeEditor = script.Parent.Parent.Parent

-- repo/SomeUtil
-- 패키지의 경우, 공통 조상 이름은 Package
const Package = script.Parent.Parent.Parent
```

<Alert severity="warning">
  <AlertTitle>이 패턴은 최대한 피하는 것이 좋은 패턴입니다</AlertTitle>

  무조건적으로 피할 패턴은 아니지만,
  인스턴스 참조를 해야하는 경우면 공통 조상에 두는 것보다 자신의 폴더나 자식으로 두는 것이 더 바람직하기 때문입니다.

  만일 MyProject 의 자식이면 경로가 가깝기에 코드가 더러워보이지 않지만, 먼 자손이면 코드가 보기 어렵게 되기 때문입니다.
  프로젝트 전반으로 공용으로 쓸 수 밖에 없는 인스턴스가 있을 경우에만 사용합니다.

  ```luau
  -- Better:

  const Package1 = require("../../../Packages/Package1")
  const Package2 = require("../../../Packages/Package2")
  const Package3 = require("../../../Packages/Package3")

  const LocalizationTable = script.LocalizationTable
  ```

  단 위의 방식은 더이상 LocalizationTable이 공용으로 쓰지 않게되기에,
  해당 스크립트의 범위만 다루는 식의 로컬리제이션 테이블로 설정해야합니다.
  혹은 MyProject 보다 더 가까운 공통 경로로 얕게 나눠도 됩니다

  ```luau
  -- Even Better:

  const Package1 = require("../../../Packages/Package1")
  const Package2 = require("../../../Packages/Package2")
  const Package3 = require("../../../Packages/Package3")

  -- Parent 가 2번 이기에 MyProject 보다 역할 분담이 더 잘됩니다
  const LocalizationTable = script.Parent.Parent.LocalizationTable
  ```

</Alert>

#### 4-2. 외부 패키지

프로젝트 외부에서 가져온 모듈입니다.

외부 패키지를 가져오는 경로 방식은 다음과 같습니다.

##### 상대 경로 외부 패키지

`roblox_packages` 와 같은 폴더 아래의 패키지들, 주로 패키지나 플러그인 프로젝트에서 사용됩니다.

```luau
-- repo/SomePackage or repo/SomePlugin:

const bide = require("../../roblox_packages/bide")
const promise = require("../../roblox_packages/promise")
```

##### 절대 경로의 서비스 자손

`ReplicatedStorage`나 `ServerScriptService` 와 같은 서비스 아래의
`Packages` 와 같은 폴더로부터 정의합니다

주로 빌드되는 로블록스 플레이스(게임 플레이스, 테스트 플레이스 등)에서 자주 사용됩니다.
로컬 파일의 경로와 `default.project.json` 의 인스턴스 빌드 경로가 다른 경우가 많기 때문이며,
상대 경로로 전부 `require` 하기엔 굉장히 범위가 넓은 경우가 많기 때문입니다

```luau
-- repo/SomePlace:

const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Packages = ReplicatedStorage.Packages
const bide = require(Packages.bide)
const promise = require(Packages.promise)
```

#### 4-3. 플레이스 내의 모듈

프로젝트 내부에서 공용으로 사용하는 모듈입니다.
주로 방대한 스크립트들을 가진 빌드되는 플레이스에서 사용합니다.
외부 패키지를 가져오는 것처럼 절대 경로의 서비스 자손으로부터 나아가 정의합니다.

중간 경로의 묶음 폴더도 있다면 변수로 정의하고 블록을 나눕니다.

```luau
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GameModules = ReplicatedStorage.GameModules
const DialogueManager = require(GameModules.DialogueManager)

const WaveModules = GameModules.WaveModules
const WaveManager = require(WaveModules.WaveManager)
const WaveRegistry = require(WaveModules.WaveRegistry)

const UIModules = GameModules.UIModules
const UIManager = require(UIModules.UIManager)
const UIRegistry = require(UIModules.UIRegistry)
```

#### 4-4. 프로젝트 모듈

현재 스크립트를 기준으로 부모 또는 형제 위치의 모듈을 불러올 때 사용합니다.

상대 문자열 경로(`./`, `../`)를 사용합니다.

예: `require("./Sibling")`
예: `require("../Shared/Util")`

#### 4-5. 자식 모듈

현재 모듈의 자식 또는 자손 모듈을 불러올 때 사용합니다.

`@self/...` 경로를 사용합니다.

예: `require("@self/Child")`
예: `require("@self/Components/Button")`

### 5. 기준 설정값

변하지 않는 기준 설정값을 정의합니다.
일반 `const` 값이나 지역 함수보다 위에 정의되어서, 설정값이 어디있는지 보기 좋아지며 수치를 한번에 조작하기 쉬워집니다.

### 6. 변수와 함수

상태가 변하는 지역 변수와 지역 함수들입니다.

### 7. 현재 모듈이 반환하는 오브젝트

이 모듈이 반환하는 오브젝트를 정의합니다.

```luau
const Module = {}

-- ...
```

자세한 것은 [객체 지향 규칙](./object/index.md)을 참고해주세요.

### 8. 메인 로직

모듈의 실행 로직입니다.

### 9. 반환

최종적으로 이 모듈 스크립트가 반환할 값 (테이블, 함수, 클래스 등)

## ModuleScript

의존성을 정적으로 파악하기 위해 `require` 는 가급적 최상단에 모아둡니다.
모듈 내부에서 반환값을 담는 지역 이름은 가능하면 파일명과 맞추고,
공개 API 이름이 더 짧아야 한다면 인터페이스 모듈에서 별칭으로 분리합니다.

## 코드 분리

### 함수 나누기

- 하나의 거대한 함수 대신, 역할별로 작은 함수로 나눕니다.
- **Orchestration**: 상위 함수는 흐름만 제어하고, 실제 작업은 하위 함수에 위임합니다.
- 상태값은 상위에서 준비하고, 하위 함수에는 필요한 인자만 전달하여 순수 함수에 가깝게 유지합니다.

```luau
const function processOrder(params)
    -- 준비
    const items = normalizeItems(params.Items)
    -- 계산
    const total = calcOrderTotal(items)
    -- 결과 생성
    return createInvoice(items, total)
end
```

### 재사용과 통일

- 반복되는 로직(기준값, 검증, 유틸리티)은 공용 모듈로 분리합니다.
- 새로운 헬퍼를 만들기 전에 `TableUtil` 등과 같은 패키지의 기능이나 Roblox 내장 기능을 먼저 검토합니다.
