## 개요

설계도를 어떻게 작성하는지 에 대한 문서입니다
기본은 [document-guide](./document-guide.md)를 따릅니다.

### 아키텍처-폴더

프로젝트 초기 설계 단계에서 `architectures` 폴더를 루트에 생성하여 설계를 구체화하는 것을 권장합니다.
이 폴더의 관습적인 파일 구조는 다음과 같습니다.

```text
|- architectures
   |- main.md -- 전체 아키텍처 개요 및 진입점
   |- ...
```

## 모듈

내부 방식을 다루는 섹션이나 문서가 아닌 경우,
내부에서만 사용되는 함수나, 작동 방식에 대해선 작성하지않습니다.

### 헤더 계층 구조

각 항목을 `####`로 정의하고, 주요 분류를 `##`로 정의하는 이유는 **문서의 확장성**을 위해서입니다.

*   `##` (Section): 속성, 메소드 등의 **주요 분류**를 정의합니다.
*   `###` (Subsection): 항목이 너무 많아 정리가 필요할 때 등, **꼭 필요한 경우에만 제한적으로** 하위 그룹을 나눌 때 사용합니다.
*   `####` (Item): 개별 **함수 및 속성**을 정의합니다.

이러한 구조는 `###` 레벨을 예약해둠으로써, 추후 문서 정리가 필요할 때 유연하게 섹션을 나눌 수 있도록 돕습니다.

### 종류에-따른-마크다운

모듈/객체의 함수나 속성을 정리해야할 땐 종류에 따라 정리합니다.
정리 할 때 순서는 다음과 같습니다, 없으면 생략합니다.
1. 생성자
2. 속성
3. 메소드
4. 함수

또한 설명은 이름만으로도 알 수 있다면 생략해도 됩니다.


#### 생성자

생성자는 생성하거나, `camelCase` 로 시작해 객체를 반환하는 함수들입니다.
```md
## Constructors
#### new
{type}

new 함수에 대한 설명

#### otherConstructor
...
```

#### 속성

모듈이나 객체에 `.` 으로 인덱스하며, 함수가 아닌 변수들을 말합니다.

```md
## Properties
#### Property1
{type}

Property 에 대한 설명

#### Property2
...
```

#### 메소드

메소드는 객체에 `:` 으로 작동하는 함수들입니다.
```lua
function Object:Method()
```

```md
## Methods
#### Method1
{type}

Method 함수에 대한 설명

#### Method2
...
```

#### 모듈 함수1
모듈 함수들은 모듈에 `.` 으로 작동하는 함수들입니다.
```lua
function Object.FindExistingObjectFromName(name: string): Object?
```

```md
## Functions
#### Function1
{type}

Function 함수에 대한 설명

#### Function2
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
#### SpeedVbp
ValueByPriority<number> -- ValueByPriority.ValueByPriority 는 서로 동일하므로, 모듈 이름 생략

#### Subtitle
SubtitleContainer.Subtitle -- SubtitleContainer 와 동일하지 않기에 모듈 이름 유지
```


아래는 각 설명에 쓰일 타입을 어떻게 작성하는 지에 대한 설명입니다.

#### 생성자와-모듈-함수

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
```md
#### AutoSync
`boolean`

설명

#### ContextText
`string`

설명

#### RowInfo

\`\`\`lua
{
	RowIndex: number,
	Name: string,
	_debugId: string,
}
\`\`\`
%% 해당 타입은 한 줄로 표기할 수 없으니, 다른 양식처럼 린팅해줍니다. %%

설명
```

#### 메소드1

self 를 제외하고 인수 타입과 반환 타입을 적어줍니다
```lua
-- 기존 코드
function Object:GetVelocityAtPosition(position: Vector3, depth: number?): Vector3

-- {type} 에 쓸 양식
(position: Vector3, depth: number?) -> (Vector3)
```