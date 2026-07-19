---
title: 타입 함수
---

타입 함수는 타입 검사 중에 실행되는 함수입니다.

일반 함수가 런타임 값을 받아 런타임 값을 반환한다면, 타입 함수는 타입을 받아 새 타입을 계산합니다.
복잡한 타입 관계를 `any` 캐스팅으로 뭉개지 않고 재사용 가능한 타입 규칙으로 만들 때 사용합니다.

## 사용 기준

타입 함수는 고급 기능이므로 일반적인 타입 모델링에는 먼저 타입 별칭과 제너릭을 사용합니다.

```luau
type Array<T> = { T }
type Dictionary<K, V> = { [K]: V }
```

타입 함수는 다음 경우에만 고려합니다.

- 테이블 타입의 키나 속성을 읽어 새 타입을 만들어야 하는 경우
- 여러 속성에 같은 변환을 적용해야 하는 경우
- 라이브러리 API 의 타입 관계를 일반 제너릭만으로 표현하기 어려운 경우

단순히 짧게 쓰기 위한 별칭이면 타입 함수가 아니라 `type` 별칭을 사용합니다.

## 문법

타입 함수는 `type function` 으로 선언합니다.

```luau
type function Optional(value)
    return types.optional(value)
end

type MaybeString = Optional<string> -- string?
```

타입 함수의 호출은 타입 문맥에서 `<...>` 를 사용합니다.
일반 함수 호출처럼 `Optional(string)` 으로 호출하지 않습니다.

## 함수 제너릭과 함께 쓰기

타입 함수는 함수 제너릭의 인자나 반환 타입 자리에서도 사용할 수 있습니다.

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

const function get<T, K>(object: T, key: K): ReadProp<T, K>
    return object[key]
end

type Person = {
    name: string,
    age: number,
}

const person: Person = {
    name = "Cake",
    age = 10,
}

const name = get(person, "name") -- string
const age = get(person, "age") -- number
```

여기서 `T` 와 `K` 는 런타임 값이 아니라 함수 제너릭의 타입 매개변수입니다.
`ReadProp<T, K>` 는 그 타입 매개변수를 받아 반환 타입을 계산합니다.
키 타입이 `string` 처럼 넓게 추론되어 속성을 찾지 못한다면 명시적 타입 인스턴스화로 고정합니다.

```luau
const name = get<<Person, "name">>(person, "name")
```

이 패턴은 `rawget`, `pick`, `pluck`, `mapValues` 처럼 입력 타입의 일부를 읽어 결과 타입을 만들어야 하는 함수에 유용합니다.
다만 타입 함수는 정적 타입만 계산하므로 런타임 안전성을 대신 보장하지 않습니다.
런타임 구현은 별도로 올바르게 작성해야 합니다.

함수 타입 자체를 타입 함수에서 만들어야 한다면 `types.generic` 과 `types.newfunction` 을 사용합니다.

```luau
type function IdentityFunction()
    const T = types.generic("T")
    return types.newfunction(
        { head = { T } },
        { head = { T } },
        { T }
    )
end

type Identity = IdentityFunction<> -- <T>(T) -> T
```

보통은 `type Identity = <T>(T) -> T` 처럼 직접 쓰는 편이 낫습니다.
타입 함수로 함수 타입을 만드는 방식은 함수 타입의 일부를 조건에 따라 조립해야 할 때만 사용합니다.

## 타입 런타임

타입 함수 본문은 타입 분석 시간에 별도의 제한된 환경에서 실행됩니다.
타입 함수 안에서 다루는 값은 실제 게임 런타임 값이 아니라 타입을 표현하는 `type` userdata 입니다.
예를 들어 `ReadProp<Person, "name">` 으로 호출하면 `Person` 과 `"name"` 이 타입 함수 안에서 `type` userdata 로 전달됩니다.

따라서 외부 스크립트의 지역 변수나 런타임 함수에 의존하지 않습니다.

## `types` 라이브러리

타입 함수에서는 `types` 라이브러리로 타입을 만들거나 변환합니다.

자주 쓰는 값과 함수는 다음과 같습니다.

```luau
types.any
types.unknown
types.never
types.boolean
types.number
types.string

types.singleton("name")
types.optional(types.string)
types.unionof(types.string, types.number)
types.intersectionof(a, b)
types.newtable(props, indexer, metatable)
types.newfunction(parameters, returns, generics)
types.copy(value)
types.generic("T")
```

반환값은 성공 시 하나의 타입이어야 합니다.
여러 값을 반환하는 타입 함수는 피합니다.

## 타입 검사와 에러

타입 함수의 에러는 타입 분석 에러로 사용자에게 표시됩니다.

```luau
type function Element(value)
    if not value:is("table") then
        error("Element<T> expects an array-like table type")
    end

    const indexer = value:indexer()
    if indexer == nil then
        error("Element<T> expects a table with an indexer")
    end

    return indexer.readresult
end

type Names = { string }
type Name = Element<Names> -- string
```

에러 메시지는 호출자가 고칠 수 있게 작성합니다.
`invalid type` 처럼 짧게 끝내지 말고, 기대한 타입 모양을 같이 적습니다.

## 성능과 복잡도

타입 함수는 IDE 와 타입 검사 과정에서 실행됩니다.
무거운 반복, 재귀, 넓은 union 조합은 타입 분석을 느리게 만들 수 있습니다.

따라서 luau-lsp 가 버거워할 정도로 복잡하다면,
차라리 타입을 굽는 스크립트를 만드는 것도 하나의 방법이 될 수 있습니다.
