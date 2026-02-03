---
title: 주석 기반 문서
sidebar_label: Document Based Comments
---

## 개요

[moonwave](https://github.com/evaera/moonwave) 를 기반으로 주석을 작성합니다.


## 작성

### 규칙

대부분의 경우에 `--[=[ 문서 주석 ]=]` 을 사용합니다,
대시 3개로 정의하는 `---` 패턴은 매우 희귀한 케이스인 한줄 문서 주석 경우를 제외하곤 사용하지 않습니다.

`@interface` 의 경우, `.` 으로 내부 키 정의, `@field` 는 사용하지 않습니다

Moonwave 는 함수/메서드 선언을 직접 읽어 자동으로 정보를 추적합니다.  
따라서 `function Object:DoSomething()` 혹은 `function Object.new()` 처럼 코드로 명확히 드러나는 경우에는 `@function`, `@method`, `@constructor` 를 적지 않습니다. 문서 주석만 존재하거나, Moonwave 가 문맥을 추적할 수 없는 특별한 경우에만 태그를 추가합니다.  
`function t.new()` 위에 `@function new @within t` 를 붙이지 않는 것이 기본 규칙입니다. (Moonwave PR #197 내용을 반영)

내부 모듈/함수처럼 패키지 외부에 공개되지 않는 정의는 API 문서 주석 대신 일반 주석을 사용합니다.

만일 프로젝트 자체가 단일 패키지라서, 내부 모듈/함수 일지라도 동작 설명이 필요한 경우가 아니라면, 
이 경우 문서 빌드 대상이 아니므로 Moonwave 주석 태그를 붙이지 않습니다.

- **함수/메서드 타입**: @function/@method 태그가 있어도 선언부에서 매개변수·반환 타입을 추론합니다.  
  필요하다면 `@param`/`@return` 을 직접 작성해 기본 추론 값을 덮어씁니다.
- **프로퍼티**: `Foo.Bar = value` 와 같은 대입식에서 `@prop` 과 `@within Foo` 를 추론합니다.  
  이미 선언된 테이블의 속성도 동일하게 처리하므로, 수동 태그를 추가하지 않습니다.
- **타입 정의**: `type Foo = { ... }` 또는 함수 타입 표현에서 구조를 추론하여 `@type Foo { ... }` 를 자동 구성합니다.

정리하면 **Moonwave 가 추론할 수 있는 정보에는 태그를 붙이지 않는다** 가 기본 원칙입니다.  
문맥을 추론할 수 없는 경우(예: 주석으로만 존재하는 설명, 런타임에 조립되는 이름, 타입을 직접 다른 값으로 덮어쓰고 싶을 때) 에만 필요한 최소 태그를 작성합니다.


### 순서

코드 내의 순서
- 맨 위에 블록 주석으로 현재 모듈이 반환하는 객체의 클래스 문서 주석
- API 를 외부 모듈에 보여주는 정의의 위 줄에 API 문서 주석 작성
- 현재 모듈이 2개 이상의 클래스를 반환하는 경우:
  우선순위가 제일 높은 클래스는 스크립트 맨 위의 코드 블록에 작성
  이후 클래스들은 각자 Constructors Region 위에 문서 주석 작성

표기에서 `< >` 로 감싼 항목은 **모두 필수**이므로 항상 값을 채워 넣습니다.
`[ ]` 로 감싼 항목은 선택 사항입니다.

문서 주석 내부의 순서:
차례대로 작성합니다.

- `@class <name>`/`@function <name>`/`@method <name>`/
`@prop <class.name> <type>`/`@type <name> <type>`/`@interface <name>`
  (뺄 수 있는 경우 가능한 뺍니다)
- 특히 `@method`, `@function` 태그는 테이블이나 모듈 내에서 바로 함수 정의가 드러나는 경우(예: `function Object:DoSomething()` 같은 선언)에는 생략합니다. 코드와 주석이 같은 블록에 있으면 Moonwave 가 자동으로 문맥을 추적하므로, 생략이 가능한 순간에는 **무조건** 태그를 추가하지 않습니다.
- 클래스 나 prop 정의가 아닌 모든 문서 주석의 `@within <class>`
  (뺄 수 있는 경우 가능한 뺍니다)
- 줄바꿈
- 내용 주석
- 아래 항목을 추가 작성시 줄바꿈
- `@interface` 의 경우:
  - 그것의 키와 타입 `.Key <type> -- [내용]`
- `@function` 의 경우, 문서 주석으로만 정의되었거나, 매개변수와 리턴값 내용을 적어야한다면:
  - `@yield`
  - 그것의 `@param <name> [type] -- [내용]`
  - 그것의 `@return <type> -- [내용]`
  - `@error <type> -- [description]` 목록들 
    중요도 와 빈도수가 높을 수록 위로 두며, 목록 작성 시작줄에서 한 줄 줄넘김합니다.



예시:
```lua
--[=[
    @class Object
    
    오브젝트에 대한 설명
]=]

local Object = {}
Object.__index = Object

export type Object = setmetatable<{
    --[=[
        @prop Object.Name string
        
        오브젝트의 이름.
    ]=]
    Name: string,
    
    --[=[
        @prop Object.Health number
        
        오브젝트의 체력.
    ]=]
    Health: number,
    
    --[=[
        @prop Object.Speed number
        
        오브젝트의 이동 속도.
    ]=]
    Speed: number,
}, typeof(Object)>

--[=[
    @interface ObjectParams
    @within Object
    
    오브젝트 생성에 필요한 매개변수
    
    .Name string? -- 오브젝트의 이름
    .Health number -- 오브젝트의 체력
    .Speed number -- 오브젝트의 이동 속도
]=]
export type ObjectParams = {
    Name: string?,
    Health: number,
    Speed: number,
}

--[=[
    새로운 오브젝트를 생성합니다.
]=]
function Object.new(params: ObjectParams): Object
end

--[=[
    오브젝트가 데미지를 입습니다.
    
    @param amount number -- 입는 데미지 양
]=]
function Object:TakeDamage(amount: number)
end

--[=[
    오브젝트를 파괴합니다.
]=]
function Object:Destroy()    
end










```

주석으로만 문서 주석을 작성해야하는 경우:
- 일반적인 방식으로 클래스를 정의한 경우가 아닌 경우
- 그 외


### 어드머니션

```lua
--[=[
    :::note
    강조하고 싶은 정보
    :::

    :::tip
    유용한 팁
    :::

    :::info
    추가 정보나 참고용 내용
    :::

    :::warning
    주의해야 할 내용
    :::

    :::danger
    위험하거나 아주 중요해서 “하지 마세요” 수준의 경고를 적어요.
    :::
]=]
```
