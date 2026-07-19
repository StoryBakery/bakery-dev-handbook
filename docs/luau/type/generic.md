---
title: 제너릭
---

제너릭은 타입을 값처럼 매개변수화하는 문법입니다.

`any` 는 타입 정보를 잃어버리지만, 제너릭은 들어온 타입을 기억해 반환값이나 다른 필드까지 이어줍니다.

## 타입 별칭

타입 별칭에는 이름 뒤에 `<T>` 를 붙여 타입 매개변수를 선언합니다.

```luau
type Array<T> = { T }
type Dictionary<K, V> = { [K]: V }

type Result<T, E> =
    { ok: true, value: T }
    | { ok: false, error: E }
```

타입 매개변수 이름은 보통 짧게 두기도 하며 길게 풀기도 합니다.

짧게 두는 경우는, 크게 의미가 강하지 않거나 범용적으로 사용되는 경우.
주로 의미를 둔 단어의 앞글자를 하나 따옵니다.

- `T`, `U`, `V`: 크게 의미없는 일반 타입
- `K`: 키 Key
- `V`: 값 Value
- `E`: Element/Event/Error
- `R`: Return/Result
- `P`: Props/Parameters
- `S`: State/Schema/Source 등

의미가 강하면 `Value`, `Name`, `Object` 처럼 풀어서 씁니다

```luau
-- Bad:
type ApiResponse<T, U, V> = {
    Data: T,
    Meta: U,
    ErrorContext: V,
}

-- Good:
type ApiResponse<Data, Meta, ErrorContext> = {
  Data: Data,
  Meta: Meta,
  ErrorContext: ErrorContext,
}
```

## 함수

함수도 데이터 매개변수와 별도로 타입 매개변수를 받을 수 있습니다.

```luau
const function identity<T>(value: T): T
    return value
end

const a = identity("hello") -- string
const b = identity(10) -- number
```

배열을 받아 같은 원소 타입의 배열을 반환해야 하는 경우처럼, 입력과 출력의 관계를 보존할 때 사용합니다.

```luau
const function first<T>(values: { T }): T?
    return values[1]
end

const name = first({ "A", "B" }) -- string?
const count = first({ 1, 2 }) -- number?
```

반대로 입력과 출력의 타입 관계가 없으면 제너릭을 쓰지 않습니다.

```luau
const function toString(value: unknown): string
    return tostring(value)
end
```

## 함수 타입

함수 값을 타입으로 표현할 때는 함수 타입 앞에 `<T>` 를 둡니다.

```luau
type Mapper<T, U> = (T) -> U
type Identity = <T>(T) -> T

const id: Identity = function(value)
    return value
end
```

제너릭 위치는 의미가 다릅니다.

```luau
type ReturnsGenericFunction = () -> <T>(T) -> T
type GenericFunctionReturningFunction<T> = () -> (T) -> T
```

`ReturnsGenericFunction` 은 호출 결과로 나온 함수가 매 호출마다 타입을 새로 받을 수 있습니다.
`GenericFunctionReturningFunction<T>` 는 바깥 타입의 `T` 가 안쪽 함수까지 고정됩니다.

## 명시적 타입 인스턴스화

대부분은 Luau 가 호출 인자를 보고 타입을 추론합니다.

```luau
const value = identity(10) -- T 를 number 로 추론
```

추론이 모호하거나 더 넓은 타입으로 고정하고 싶을 때는 `함수명<<타입>>` 문법으로 명시합니다.

```luau
const numberOrString = identity<<number | string>>(10)
```

여러 타입 매개변수는 쉼표로 구분합니다.

```luau
const function pair<T, U>(left: T, right: U): (T, U)
    return left, right
end

const left, right = pair<<string, number>>("score", 10)
```

함수 제너릭에는 기본 타입 인자를 줄 수 없습니다.

```luau
-- Invalid:
-- const function getValue<T = string>(value: T): T
--     return value
-- end
```

## 타입 팩

가변 인자나 여러 반환값의 타입 관계를 유지해야 하면 타입 팩을 사용합니다.

```luau
const function pass<T...>(...: T...): T...
    return ...
end

const name, count = pass("coin", 3) -- string, number
```

일반적인 컨테이너 타입에는 거의 필요하지 않습니다.
여러 인자를 그대로 전달하거나 감싸는 함수에서만 사용합니다.

## 사용 기준

제너릭은 타입 사이의 관계를 표현할 때 사용합니다.

```luau
type Store<T> = {
    get: () -> T,
    set: (value: T) -> (),
}
```

`get` 과 `set` 이 같은 타입을 공유한다는 것이 핵심입니다.
단순히 여러 타입을 받을 수 있다는 이유만으로 제너릭을 쓰지는 않습니다.

```luau
-- Bad:
type Event<T> = {
    name: string,
    timestamp: number,
}

-- Good:
type Event = {
    name: string,
    timestamp: number,
}
```

타입 매개변수가 한 번만 등장한다면 대부분 제너릭이 필요하지 않습니다.
