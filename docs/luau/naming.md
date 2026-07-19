---
title: Naming Style
---

일관된 네이밍 규칙은 코드의 의도를 명확히 전달하고, 협업 효율을 높입니다.
약어 사용을 지양하고, 풀 네임을 사용하여 가독성을 확보하는 것을 원칙으로 합니다.

기본 규칙:

- **PascalCase**: Roblox API, 클래스, 타입, 모듈 반환 객체, 테이블의 공개 멤버(속성/메서드).
- **camelCase**: 지역 변수/함수, private 멤버, 생성자 함수.
- **LOUD_SNAKE_CASE**: 기준 설정값.

## 모듈 이름

### 객체 반환과 이름 동기화

모듈이 객체 하나를 반환한다면, 모듈 파일명과 객체명을 일치시킵니다.

이를 통해 `luau-lsp` 의 `completion.imports.enabled` 자동완성으로
간편하게 모듈을 임포트할 수 있게되며 일관적이게 됩니다.

**예시**:

```luau
-- PlayerController/pkgs/CameraModules/CameraManager.luau:
-- 테이블로 반환시:
const CameraManager = {}

-- ...

return CameraManager
```

### 단일 함수 반환

모듈이 **단일 함수**만 반환한다면, `camelCase` 파일명을 사용합니다.

**예시**:

```luau
-- PlayerController/pkgs/CameraModules/initializeCamera.luau:
const function initializeCamera()
    -- ...
end

return initializeCamera
```

### 자식 모듈을 반환하는 인터페이스 모듈에서

패키지는 외부 사용자가 자식 모듈을 사용해야할 경우,
루트에서 자식이나 자손을 가져와서 반환해주는 인터페이스 역할을 해야합니다.

그런 경우, 부모의 접두사로 속성에 할당된 자식 이름을 축약할 수 있습니다.

**예시**:

```luau
-- PlayerController/pkgs/CameraModules/init.luau:
const CameraManager = require("@self/CameraManager")

const CameraModules = {}

CameraModules.Manager = CameraManager

-- CameraModules.CameraManager 보단 CameraModules.Manager 로 줄일 수 있습니다

return CameraModules
```

### 해당 패키지를 사용하는 외부 소비자에서

주로 해당 패키지를 의존성 삼는 스크립트입니다.

**플레이스에서의 예시**:
절대 경로를 사용합니다.

```luau
-- Project/src/Game/ControllerConfig.client.luau
const PlayerController = require(Packages.PlayerController)

const CameraModules = PlayerController.CameraModules
const CameraManager = CameraModules.Manager
```

**또 다른 패키지에서의 예시**:
상대 경로를 사용합니다.

```luau
-- ControllerUtil/src/init.luau
const PlayerController = require("../roblox_packages/PlayerController")

const CameraModules = PlayerController.CameraModules
const CameraManager = CameraModules.Manager
```

### 패키지 워크스페이스 프로젝트 내의 다른 패키지에서

의존성 중첩을 피하기 위해 자식 모듈을 반환하는 인터페이스 모듈이 아니라 직접 require 해야하거나,
루트 모듈이 자식 모듈을 반환하지 않는 경우 사용하는 패턴입니다.

만일 의존성 문제가 없다면 [외부 소비자](#해당 패키지를 사용하는 외부 소비자에서)의
상대 경로 예시처럼 동일하게 작성해도 됩니다.

**예시**:

```luau
-- PlayerController/pkgs/ControlModules/ControlManager.luau:

const CameraManager = require("../CameraModules/CameraManager")
```

## 변수명

### 복수형

문법적으로 어색하더라도 배열/리스트 변수 뒤에는 `s`, `es` 를 붙여 복수임을 명시합니다. (`infos`, `datas`)

### 구분 규칙

- **일반 변수**: 지역 변수 등엔 `camelCase` 가 기본입니다.
- **PascalCase 변수**: Roblox 서비스, 또는 내부 모듈(`require`)의 반환값을 담을 때 사용합니다.
- **예외**: 외부 패키지(`@vide` 등)가 소문자 네이밍을 권장한다면, 그에 맞춰 `const vide = require(...)` 처럼 소문자를 사용할 수 있습니다.
- **기준 설정값**: 사람이 직접 조정하는 제한값, 기본값, 튜닝 값이라면 `LOUD_SNAKE_CASE` 를 사용합니다.

```luau
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const ObjectClass = require(ObjectModules.Class)

const MAX_COUNT = 100

const player = Player.LocalPlayer

local count = 0
```

#### 기준 설정값에만 LOUD_SNAKE_CASE 를 사용합니다

`const` 를 쓴다고 해서 `LOUD_SNAKE_CASE` 를 써야하진 않습니다

일반 객체, 계산 결과, 참조값은 `const` 로 선언하더라도 `camelCase` 혹은 `PascalCase` 를 사용합니다.
`LOUD_SNAKE_CASE` 는 사람이 직접 조정하는 설정값, 제한값, 기본값처럼
코드의 기준값으로 읽혀야 하는 값에만 사용합니다.

## 테이블

### 배열

`{ItemName}s` 또는 `{ItemName}es` 형태를 사용합니다.

2차원 배열은 구조 의미에 따라 `{ItemName}Rows`, `{ItemName}Grid`, `{ItemName}Matrix` 를 사용합니다.
3차원 이상 배열은 구조 의미에 따라 `{ItemName}Layers`, `{ItemName}Volume`, `{ItemName}Frames` 등 축 의미를 사용합니다.

다차원 배열은 변수명에 차원 수를 직접 드러내기보다 데이터의 의미를 우선해 짓습니다.
차원 수나 축 구조를 명시해야 한다면 타입 별칭에서 표현합니다.

### 딕셔너리

딕셔너리의 키는 **PascalCase** 를 사용합니다.

#### 키-값 쌍

`<Item>By<Key>` 패턴을 사용합니다.

- `monsterInfosByMonsterId: { [MonsterId] = MonsterInfo }`
- `levelsByPlayer: {[Player]: number}`
- `LayerCollector.LayersByName: {[string]: Layer}`

키가 중첩된 경우 `<Item>By<Key1>And<Key2>And...` 패턴을 사용합니다.

### 집합

집합은 딕셔너리지만, 키만 필요하고, 값은 사용하지 않는 딕셔너리를 의미합니다
즉 키를 통해, 해당 딕셔너리에 있는지 없는지 정도만 확인하는 용도.

`-Set` 을 접미사로 활용합니다
주로 `ClassSet: {[Class]: true} = {}` 로 선언합니다

```luau
const playerSet: {[Player]: true} = {}

if playerSet[player] then
	print("플레이어가 있습니다.")
else
	print("플레이어가 없습니다.")
end

const function onPlayerRemoving(player: Player)
	playerSet[player] = nil
end
```

## 데이터

### 리소스 식별자

로블록스에서는 이미지, 사운드등 다양한 리소스는 `Content` 라는 객체를 사용해 적용합니다.
하지만 서버에 등록된 `id` 나 `uri` 로 주소를 알아서 가져와야할 경우도 있습니다,
이 때를 위해 리소스 식별자를 접미사 형태를 표시합니다.

- **Id**: 숫자 (`number`) -> `IMAGE_ID`, `ImageId`
- **Uri**: `rbxassetid://{id}` -> `IMAGE_URI`, `ImageUri`
- **Content**: `Datatype.Content` 타입 객체 -> `IMAGE_CONTENT`, `ImageContent`

## 타입

### 시그널

이벤트의 시그널 담는 변수는 접미사 `-Conn` 을 붙여 `Connection` 임을 명시합니다.

- `const touchedConn = part.Touched:Connect(fn)`
- `const destroyingConn = part.Destroying:Connect(fn)`
- `const signalConn = object.Signal:Connect(fn)`

**Updated vs Changed**: `Changed` 는 일반적인 변경, `Updated` 는 더 구체적인 갱신/로직 수행을 의미할 때 사용합니다.

## 함수 이름

### 찾기 함수의 Find 와 Get 의 차이

- `Find...`: 대상을 반환하거나, 없으면 `nil` 을 반환합니다. 조회 실패 가능성이 있는 경우에 사용합니다.
- `Get...`: 대상을 무조건 반환하거나, 없으면 에러를 발생시킵니다. 대상이 반드시 존재해야 하는 경우에 사용합니다.

### 찾기 함수에서의 From vs By 의 차이

B 를 받고 그에 대한 값 A 를 반환할 때 `{A}From{B}` 혹은 `{A}By{B}` 를 자주 사용합니다.
둘은 비슷한 의미를 가지지만, 디테일하게는 의미는 다음과 같이 나뉩니다.

- `{A}From{B}`: 복잡한 과정을 거쳐 대상을 추출/변환할 때. (`FindCharacterFromPlayer`)
- `{A}By{B}`: 딕셔너리 키 조회 등 직접적인 식별자로 찾을 때. (`FindCharacterByPlayer`)

By 는 딕셔너리에서 바로 캐시/인덱스할 수 있는 것
From 은 어딘가를 거치고 여러 계산을 통해서 찾는다는 의미가 강합니다

만약 플레이어와 캐릭터가 속성으로 연결되어있어서, 즉시 캐싱이나 찾기가 가능하다면
`FindCharacterByPlayer` 으로 지을 수 있고
플레이어와 캐릭터가 즉시 캐싱할 수 없는 구조, 캐릭터는 월드맵에 저장되고, 월드맵은 플레이어로부터 색인하는 복잡한 과정을 거친다면
`FindCharacterFromPlayer` 라고 지을 수 있습니다.

### 매개변수

선택적 옵션은 `Options`, 필수 설정은 `Params` 접미사를 사용하여 구분합니다.

## 생명 주기 함수 이름

초기 설정 시에 대한 이름 관습입니다, 설정을 의미하는 함수 이름은 많기에 모호함을 줄이기에 역할을 고정합니다.

- `Init`: 한 번만 필요한 초기화를 수행합니다.
- `Config`: 옵션, 의존성, 외부 입력을 적용해 구성을 확정합니다.
- `Start`: 실제 동작을 시작합니다.
- `Stop`: 시작된 동작을 중단합니다.

### Parallel Luau 에서 각 생명 주기 함수 이름들의 역할

Parallel Luau 에선 모듈 스크립트를 require 하면 모듈 스크립트가 각 액터마다 재실행되기에,
전역적으로 한 번만 실행되어야할 초기 함수, 각 액터마다 실행되어야할 초기 함수를 나눠야합니다

`Init` 은 전역적으로 한 번만 실행되는 역할입니다.
반대로 `Config`, `Start` 는 각 모든 쓰레드, 액터에서 작동되는 역할입니다

**Init 예시**:

```luau
--[[
    병렬로도 작동되는 객체나 스크립트에서 전역으로 Init 이 작동되었는지 감지하는 법은 여러가지가 있습니다.
    스크립트나 특정 경로의 인스턴스의 Attribute 로 감지하던가, SharedTable 로 감지합니다.
    가장 최적의 방법으로 감지하면 됩니다.

    주로 메인쓰레드나, 자체 자식 스크립트가 실행시킵니다.
]]

const LifeCycler = require("./")

if script:GetAttribute("IsInitialized") then
    return
end

LifeCycler.Init()
script:SetAttribute("IsInitialized", true)
```

**Config 예시**:

```luau
-- 지역변수나 SharedTable 이 아닌 테이블의 속성으로부터 감지하면,
-- 해당 쓰레드/액터에서 이미 실행되었는지 아닌지를 알 수 있습니다.
-- 단 Attribute, BindableFunction, SharedTable 와 같은
-- 쓰레드/액터 간에 공유되는 데이터로 감지하면 전역적으로 실행되기에 논리 영역이 분리되지 않습니다
local isConfigured = false

if isConfigured then
    return
end

LifeCycler.Config({
    ActorId = script:GetAttribute("ActorId")
})
isConfigured = true
```

## 용어

- **개수/인덱스**: `count`, `index` 사용. (`number` 등 모호한 이름 지양)
- **단위**: `Seconds`, `Meters` 등 단위 접미사 사용. (`delaySeconds`)
- **상태 동사**: `IsVisible`, `CanCollide` 등 3인칭 단수 동사 또는 상태형 사용.
- **이벤트**: `Touched`, `Changed` 등 과거분사형 사용. 핸들러는 `onTouched` 등 `on` 접두사 사용.

**시간 용어**

- `Date` 대신 `Time` 접미사 사용. (`UpdatedTime`)
- `Time` 은 가변프레임의 실수 시간, `Tick` 은 고정틱의 실수 시간, `FrameNumber` 는 고정틱의 정수 시간 `floor(tick * 60)`
