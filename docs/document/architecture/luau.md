---
title: Luau 설계도 작성하기
---

Luau 프로그램의 설계도를 작성하는 경우의 스타일입니다

## 모듈

내부 방식을 다루는 섹션이나 문서가 아닌 경우,
내부에서만 사용되는 함수나, 작동 방식에 대해선 작성하지않습니다.

### 헤더 계층 구조

주요 분류를 `##`로 정의하고, 기본 항목을 `###`로 정의합니다.

- `##` (Section): 속성, 메서드 등의 **주요 분류**를 정의합니다.
- `###` (Item/Subsection): 개별 **함수 및 속성**을 정의합니다.
- `####` (Item in Group): `###`를 그룹으로 사용한 경우, 그룹 내부 항목을 정의합니다.

즉, 기본 구조는 `## -> ###` 이고,
그룹이 필요할 때만 `## -> ###(그룹) -> ####(항목)`을 사용합니다.

```md
## Properties

### AutoSync

설명

### ContextText

설명
```

```md
## Properties

### 동기화 관련

#### AutoSync

설명

#### SyncInterval

설명
```

### 종류에 따른 마크다운

모듈/객체의 함수나 속성을 정리해야할 땐 종류에 따라 정리합니다.
정리 할 때 순서는 다음과 같습니다, 없으면 생략합니다.

1. 생성자
2. 속성
3. 메서드
4. 함수

또한 설명은 이름만으로도 알 수 있다면 생략해도 됩니다.

#### 생성자

생성자는 생성하거나, `camelCase` 로 시작해 객체를 반환하는 함수들입니다.

```md
## Constructors

### new

`{type}`

new 함수에 대한 설명

### otherConstructor
...
```

#### 속성

모듈이나 객체에 `.` 으로 인덱스하며, 함수가 아닌 변수들을 말합니다.

```md
## Properties

### Property1

`{type}`

Property 에 대한 설명

### Property2

`type`

...

```

#### 메서드

메서드는 객체에 `:` 으로 작동하는 함수들입니다.

```lua
function Object:Method()
```

```md
## Methods

### Method1

`{type}`

Method 함수에 대한 설명

### Method2

...

```

#### 모듈 함수1

모듈 함수들은 모듈에 `.` 으로 작동하는 함수들입니다.

```lua
function Object.FindExistingObjectFromName(name: string): Object?
```

```md
## Functions

### Function1
{type}

Function 함수에 대한 설명

### Function2
...
```

### 타입 작성

#### 타입 속 타입

인수의 타입이 `params` 같이 **모듈 내부**에서 정의된 또다른 타입이면
`{type}` 에 함수 타입을 작성한 뒤, 코드 아래에 적어둡니다.

```lua
-- 기존 코드
export type FindObjectParams = {
 IgnoresDestroyedObjects: boolean?
 Recursive: boolean?,
 TargetAncestorObject: Object?,
}
function Object.FindObject(params: FindObjectParams?): Object?

-- {type} 에 쓸 양식
(params: FindObjectParams?) -> (Object?)

FindObjectParams = {
 IgnoresDestroyedObjects: boolean?
 Recursive: boolean?,
 TargetAncestorObject: Object?,
}
```

하지만 이미 문서 내에 설명되어있는 타입일 경우, 생략합니다.
`Object` 나 `Subobject` 타입이, 문서 전체적으로 혹은 어딘가에서 설명했다면, 넣지 않습니다.

```lua
function Object:GetSubobjects() -> {Subobject}

-- {type} 에 쓸 양식
() -> ({Subobject})

-- 만일 Subobject 객체에 대한 설명이 문서 다른 곳에 있을 경우, 생략.
```

**다른 모듈**에서 export된 타입의 경우, 타입의 이름이 모듈과 동일하다면, 구분 없이 합니다

```lua
-- 기존 코드
export type Object = {
 SpeedVbp: ValueByPriority.ValueByPriority<number>,
 Subtitle: SubtitleContainer.Subtitle,
}


-- {type} 에 쓸 양식
### SpeedVbp
ValueByPriority<number> -- ValueByPriority.ValueByPriority 는 서로 동일하므로, 모듈 이름 생략

### Subtitle
SubtitleContainer.Subtitle -- SubtitleContainer 와 동일하지 않기에 모듈 이름 유지
```

아래는 각 설명에 쓰일 타입을 어떻게 작성하는 지에 대한 설명입니다.

#### 생성자와 모듈 함수

그대로 인수 타입과 반환 타입을 적어줍니다

```lua
-- 기존 코드
function Object.new(arg1: T, arg2: U): Object

-- {type} 에 쓸 양식
(arg1: T, arg2: U) -> (Object)
```

#### 속성1

속성의 타입을 씁니다

```lua
-- 기존 코드
Object.SpeedVbp = ValueByPriority.new(...)

--  {type} 에 쓸 양식
ValueByPriority<number>
```

양식에서 따로 추가해야할 타입이 없고 한 줄로 표기 가능하다면,

```md
`type`
```

로 표기합니다.

공간을 아끼고, 속성의 타입은 대체로 린팅이 필요없기 때문입니다.

**예시**:

````md
### AutoSync

`boolean`

설명

### ContextText

`string`

설명

### RowInfo

```lua
{
 RowIndex: number,
 Name: string,
 _debugId: string,
}
```

%% 해당 타입은 한 줄로 표기할 수 없으니, 다른 양식처럼 린팅해줍니다. %%

설명

````

### 메서드1

self 를 제외하고 인수 타입과 반환 타입을 적어줍니다

```lua
-- 기존 코드
function Object:GetVelocityAtPosition(position: Vector3, depth: number?): Vector3

-- {type} 에 쓸 양식
(position: Vector3, depth: number?) -> (Vector3)
```
