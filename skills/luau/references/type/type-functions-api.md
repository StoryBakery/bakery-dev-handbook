---
name: Luau Type Functions API
---

# Luau 타입 함수 API

이 레퍼런스는 Luau 타입 함수를 다루는 AI 에이전트를 위한 문서입니다.
존재하지 않는 API 이름을 만들거나 런타임 Luau API 와 타입 함수 API 를 섞어 쓰지 않기 위해 사용합니다.

**참조**:

- <https://luau.org/types/type-functions/>
- <https://luau.org/types-library/>

## 문법

타입 함수는 `type function` 으로 선언합니다.

```luau
type function Optional(value)
    return types.optional(value)
end

type MaybeString = Optional<string>
```

타입 함수는 타입 위치에서 `<...>` 로 호출합니다.
런타임 함수 호출 문법으로 호출하지 않습니다.

```luau
type A = Optional<string> -- 올바름
-- type B = Optional(string) -- 잘못됨
```

타입 함수는 분석 시간에 실행되며, 런타임 값이 아니라 `type` userdata 값을 받습니다.

## 타입 함수 환경

타입 함수에서는 `types` 라이브러리와 제한된 Luau 환경을 사용할 수 있습니다.

- `assert`, `error`, `print`
- `next`, `ipairs`, `pairs`
- `select`, `unpack`
- `getmetatable`, `setmetatable`
- `rawget`, `rawset`, `rawlen`, `raweq`
- `tonumber`, `tostring`
- `type`, `typeof`
- `math`, `table`, `string`, `bit32`, `utf8`, `buffer`

타입 함수 안에서 런타임 지역 변수, Instance, 서비스, 모듈 상태, 게임 데이터에 의존하지 않습니다.

## `types` 상수

```luau
types.any
types.unknown
types.never
types.boolean
types.buffer
types.number
types.string
types.thread
```

## `types` 생성자

```luau
types.singleton(arg: string | boolean | nil): type
types.negationof(arg: type): type
types.optional(arg: type): type
types.unionof(first: type, second: type, ...: type): type
types.intersectionof(first: type, second: type, ...: type): type
types.newtable(
    props: { [type]: type | { read: type?, write: type? } }?,
    indexer: { index: type, readresult: type, writeresult: type? }?,
    metatable: type?
): type
types.newfunction(
    parameters: { head: { type }?, tail: type? },
    returns: { head: { type }?, tail: type? }?,
    generics: { type }?
): type
types.copy(arg: type): type
types.generic(name: string?, ispack: boolean?): type
```

참고:

- `types.optional(T)` 는 `T | nil` 을 반환합니다.
- `types.unionof` 와 `types.intersectionof` 는 최소 두 개의 타입 인자가 필요합니다.
- `types.generic(name, true)` 는 제너릭 타입 팩을 만듭니다.
- `types.copy` 는 테이블 타입이나 함수 타입을 변경하기 전에 복사할 때 유용합니다.

## 기본 `type` 인스턴스

모든 타입 인스턴스는 다음 API 를 공유합니다.

```luau
type.tag:
    "nil"
    | "unknown"
    | "never"
    | "any"
    | "boolean"
    | "number"
    | "string"
    | "singleton"
    | "negation"
    | "union"
    | "intersection"
    | "table"
    | "function"
    | "extern"
    | "thread"
    | "buffer"

type:is(tag: string): boolean
```

`==` 연산자는 문법적 동일성을 확인합니다.
의미적으로 같은 타입이 항상 같다고 비교된다고 가정하지 않습니다.

```luau
if value:is("table") then
    -- 여기서 value 는 테이블 타입 API 를 사용할 수 있습니다.
end
```

## 싱글턴 타입

```luau
singletontype:value(): boolean | nil | string
```

`types.singleton("name")` 에서 `"name"` 같은 싱글턴 값을 읽을 때 사용합니다.

## 제너릭 타입

```luau
generictype:name(): string?
generictype:ispack(): boolean
```

제너릭 타입은 `types.generic("T")`, 제너릭 타입 팩은 `types.generic("T", true)` 로 만듭니다.

## 테이블 타입

속성 API:

```luau
tabletype:setproperty(key: type, value: type?)
tabletype:setreadproperty(key: type, value: type?)
tabletype:setwriteproperty(key: type, value: type?)
tabletype:readproperty(key: type): type?
tabletype:writeproperty(key: type): type?
tabletype:properties(): { [type]: { read: type?, write: type? } }
```

인덱서 API:

```luau
tabletype:setindexer(index: type, result: type)
tabletype:setreadindexer(index: type, result: type)
tabletype:setwriteindexer(index: type, result: type)
tabletype:indexer(): { index: type, readresult: type, writeresult: type }?
tabletype:readindexer(): { index: type, result: type }?
tabletype:writeindexer(): { index: type, result: type }?
```

메타테이블 API:

```luau
tabletype:setmetatable(arg: type)
tabletype:metatable(): type?
```

속성 키는 문자열 싱글턴 타입이어야 합니다.

```luau
const key = types.singleton("Name")
const value = tableType:readproperty(key)
```

새 테이블 타입을 만들 때는 `types.newtable` 을 사용합니다.
기존 테이블 타입을 수정할 때는 명시적으로 변경하려는 경우가 아니라면 먼저 `types.copy` 로 복사합니다.

## 함수 타입

```luau
functiontype:setparameters(head: { type }?, tail: type?)
functiontype:parameters(): { head: { type }?, tail: type? }
functiontype:setreturns(head: { type }?, tail: type?)
functiontype:returns(): { head: { type }?, tail: type? }
functiontype:generics(): { type }
functiontype:setgenerics(generics: { type }?)
```

고정 위치 인자는 `head`, 가변 타입 팩은 `tail` 로 표현합니다.

```luau
type function IdentityFunction()
    const T = types.generic("T")
    return types.newfunction(
        { head = { T } },
        { head = { T } },
        { T }
    )
end
```

가능하면 함수 타입 문법을 직접 사용합니다.

```luau
type Identity = <T>(T) -> T
```

함수 타입을 계산해야 하는 경우에만 타입 함수 안에서 함수 타입을 조립합니다.

## 부정 타입

```luau
negationtype:inner(): type
```

## 유니온 타입

```luau
uniontype:components(): { type }
```

유니온의 각 분기를 순회할 때 사용합니다.

## 교차 타입

```luau
intersectiontype:components(): { type }
```

교차 타입의 각 분기를 순회할 때 사용합니다.

## Extern 타입

```luau
externtype:properties(): { [type]: { read: type?, write: type? } }
externtype:readparent(): type?
externtype:writeparent(): type?
externtype:metatable(): type?
externtype:indexer(): { index: type, readresult: type, writeresult: type }?
externtype:readindexer(): { index: type, result: type }?
externtype:writeindexer(): { index: type, result: type }?
```

Extern 타입은 embedder 에서 제공됩니다.
Roblox Luau 에서는 모든 extern 타입이 일반 테이블처럼 동작한다고 가정하지 않습니다.

## 자주 쓰는 패턴

### 속성 타입 읽기

```luau
type function ReadProp(tableType, keyType)
    if not tableType:is("table") then
        error("ReadProp<T, K> expects T to be a table type")
    end

    const value = tableType:readproperty(keyType)
    if value == nil then
        error("ReadProp<T, K> could not find the property")
    end

    return value
end
```

### 읽기 전용 객체 타입 만들기

```luau
type function Readonly(tableType)
    if not tableType:is("table") then
        error("Readonly<T> expects T to be a table type")
    end

    const result = types.newtable()

    for key, property in tableType:properties() do
        if property.read ~= nil then
            result:setreadproperty(key, property.read)
        end
    end

    const indexer = tableType:readindexer()
    if indexer ~= nil then
        result:setreadindexer(indexer.index, indexer.result)
    end

    return result
end
```

### 제너릭 함수 관계 유지하기

```luau
type function ReturnsInput()
    const T = types.generic("T")
    return types.newfunction(
        { head = { T } },
        { head = { T } },
        { T }
    )
end
```

## 주의점

- 타입 함수를 런타임 문법으로 호출하지 않습니다.
- 타입 함수 안에서 런타임 값을 사용하지 않습니다.
- 태그별 메서드를 호출하기 전에 `value:is("...")` 를 확인합니다.
- 속성 키는 원시 문자열이 아니라 문자열 싱글턴 타입을 사용합니다.
- 타입 함수보다 타입 별칭과 제너릭을 먼저 고려합니다.
- 타입 함수는 작게 유지하면 좋습니다. 큰 유니온 변환이나 재귀 변환은 분석을 느리게 만들 수 있습니다.
