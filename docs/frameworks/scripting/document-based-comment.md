---
sidebar_label: Document Based Comments
---

# Document-Based-Comments

## 개요
Story-Bakery 프로젝트는 [moonwave](https://github.com/evaera/moonwave) 를 사용하여 코드 주석으로부터 API 문서를 자동 생성합니다. Vide 컴포넌트 문서는 [vide-component-documentation](../vide/component-documentation.md) 규칙을 따릅니다.

## 작성-규칙

### 기본-형식
- 문서화 주석은 반드시 `--[=[ ... ]=]` 블록을 사용합니다.
- 한 줄 문서 주석(`---`)은 거의 사용하지 않습니다.
- 공개(Public) API 에만 문서 주석을 작성하며, 내부(Private) 함수나 모듈에는 일반 주석을 사용합니다.

### 자동-추론-원칙
Moonwave 는 코드를 분석하여 대부분의 정보를 자동으로 추론합니다. 따라서 **추론 가능한 정보에는 태그를 붙이지 않습니다.**

- **함수/메서드**: `function Object:Do()` 선언이 있다면 `@function`, `@method` 태그를 생략합니다.
- **프로퍼티**: 타입 정의(`type Foo = {}`)나 초기값 할당(`Foo.Bar = 1`)이 있다면 `@prop` 태그를 생략합니다.
- **타입**: `export type` 선언이 있다면 `@type` 태그를 생략합니다.

문맥을 추론할 수 없는 경우(예: 주석으로만 존재하는 가상 인터페이스, 런타임에 결정되는 이름)에만 최소한의 태그를 사용합니다.

## 작성-순서

### 코드-내-위치
1. **클래스 문서**: 파일 최상단 또는 클래스 정의 바로 위에 작성합니다.
2. **멤버 문서**: 각 함수, 메서드, 타입 정의 바로 윗줄에 작성합니다.
3. **다중 클래스**: 한 파일에 여러 클래스가 있다면, 메인 클래스는 최상단, 서브 클래스는 해당 정의 위에 작성합니다.

### 주석-내부-순서
주석 블록 내부는 다음 순서로 작성합니다.

1. **태그 정의** (`@class`, `@interface` 등 - 추론 불가능할 때만)
2. **설명 본문** (Description)
3. **세부 항목**:
    - `@yield` (함수가 yield 하는 경우)
    - `@param <name> [type] -- [설명]`
    - `@return <type> -- [설명]`
    - `@error <type> -- [설명]`

## 예제

```lua
--[=[
    @class Object
    오브젝트의 기본 클래스입니다.
]=]
local Object = {}

--[=[
    새로운 오브젝트를 생성합니다.
]=]
function Object.new(params: ObjectParams): Object
    -- ...
end

--[=[
    오브젝트에게 데미지를 입힙니다.
    
    @param amount number -- 입힐 데미지 양
    @return number -- 적용된 실제 데미지
]=]
function Object:TakeDamage(amount: number): number
    -- ...
end
```

## 어드머니션 (Admonitions)

강조하고 싶은 내용은 Docusaurus 스타일의 어드머니션 구문을 사용합니다.

```lua
--[=[
    :::warning
    이 메서드는 더 이상 사용되지 않습니다. (Deprecated)
    :::
]=]
```
