---
title: Luau 타입 설정
---

## 타입 검사 모드

Luau 파일은 기본적으로 strict 모드로 작성합니다.

`.config.luau` 로 기본적으로 `languagemode = "strict"` 으로 두는 것을 관습으로 하기에
`--!strict` 를 파일 맨 위 코드에 둘 필요는 없습니다.

## 상속

교차 타입 `&` 를 사용해 정의 합니다.

```luau
type SuperClass = ...
type Subclass = {} & SuperClass
```

속성을 덮어씌우는 대상이 `&` 의 앞에 오기에, 상위 클래스를 오른쪽으로 배치합니다.

```luau
type A = {
    ClassName: string,
    OverlappedProp: string,
    OverlappedMethod: (self: any, value: number | string): (number | string)
}

type B = {
    OverlappedProp: 'SomeProp1' | 'SomeProp2',
    OverlappedMethod: (self: any, value: string): (string)
}

type InheritedB = B & A

const b: InheritedB -- B 가 A 보다 앞에 옴으로, 중복된 키는 B 가 A 를 덮어씌웁니다
b.ClassName -- string
b.OverlappedProp -- 'SomeProp1' | 'SomeProp2'
b.OverlappedMethod -- (self: any, value: string): (string)
```

## 외부 타입

`MyModule.Something` 처럼 외부 모듈 네임스페이스를 그대로 노출하여 출처를 명확히 합니다.
재노출이 필요하지 않는한, `type Something = MyModule.Something` 으로 재정의하지 않습니다.

```luau
-- Bad:
-- Module.luau
const Child = require("./Child")

type Child = Child.Child

const a: Child -- Child 를 쓰겠다고 위에서 한 줄 더 정의하는 것은 비효율적

-- Good:
-- Module.luau
const Child = require("./Child")

const a: Child.Child -- 보다 더 명시적이게 됨, 또한 f12 키로 타입 이름을 전체적으로 바꿀 때도 잘 바꿔짐

-- Interface.luau
const Child = require("./Child")

export type Child = Child.Child -- 패키지의 인터페이스 모듈이라면 명시적으로 노출할 필요가 있기에 좋은 행동
```

## 타입 에러 해결을 위한 any 덮어씌우기는 는 필수부가결할 때만 사용합니다

`:: any` 와 같이 타입을 캐스팅하기보다, 미리 명확한 타입 구조를 정의하는 것이 좋습니다.

```luau
-- Bad:
const manifest: any = getManifest() -- 어딘가에서 잘못된 타입 에러가 난다고 any 로 그냥 해버림

-- Good:
-- Manifest 란 타입을 반환해주게 만듦.
-- getManifest 의 소유권이 현재 프로젝트에 없어서 수정하기 번거롭거나
-- luau-lsp 가 버그가 발생한 것이 아닌 이상,
-- :any 혹은 :: any 사용은 자제합니다.
const manifest = getManifest()
```

## 괄호로 묶으면 튜플 중 하나만 전송할 수 있어 타입 에러를 방지할 수 있습니다

```luau
const function normalizePath(path: string): string
	return path:gsub("\\", "/") --> TypeError: Expected this to be 'string', but got 'string, number'
end


const function normalizePath(path: string): string
	return (path:gsub("\\", "/"))
end
```

타입을 하나만 반환하기로 했는데, 함수에서 따로 반환하는 튜플이 있다면, 괄호로 감쌀 수 있습니다.
짧은 구문에 유용하지만, 코드가 길어지거나 복잡해진다면 변수로 나누는 것이 도 효과적입니다.
