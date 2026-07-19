---
title: vector
---

Luau 에서 로블록스 내장 라이브러리인 Vector3 를 대체하기 위한 네이티브 라이브러리.
보다 빠른 성능을 가집니다

**Functions**

- `create(x: number,y: number,z: number): vector`
- `magnitude(vec: vector):number`
- `normalize(vec: vector): vector`
- `cross(vec1: vector,vec2: vector): vector`
- `dot(vec1: vector,vec2: vector):number`
- `angle(vec1: vector,vec2: vector,axis: vector?):number`
- `floor(vec: vector): vector`
- `ceil(vec: vector): vector`
- `abs(vec: vector): vector`
- `sign(vec: vector): vector`
- `clamp(vec: vector,min: vector,max: vector): vector`
- `lerp(vec1: vector,vec2: vector,alpha: number): vector`
- `max(...: vector): vector`
- `min(...: vector): vector`

**Properties**

- `zero: vector`
- `one: vector`

## 로블록스에서는 `vector` 와 `Vector3` 와의 차이가 사라집니다

`vector.create` 로 생성한 `vector` 는 `Vector3` 로도 취급되어
`vector.create(1, 2, 3).Unit` 처럼 `Vector3` 에만 있는 `Unit` 속성을 사용할 수 있고,
`vector.magntinude( Vector3.one )` 도 가능합니다.

그렇기에 비로블록스 Luau 환경을 고려한다면 `vector` 라이브러리만 사용하는 것도 좋으며, `Vector3` 가 넘어와도 `vector` 로 취급해도 됩니다.

`type` 와 `typeof` 의 경우:

```luau
print(type(vector.one), type(Vector3.one)) -- vector vector
print(typeof(vector.one), typeof(Vector3.one)) -- Vector3 Vector3
```

단 `Vector2` 와는 호환이 되지 않습니다, 에러발생이 됩니다.
