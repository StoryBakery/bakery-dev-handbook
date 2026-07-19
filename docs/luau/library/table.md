---
title: table
---

**Functions**

- `clear(table: table): ()`
- `clone(t: table): table`
- `concat(t: {any}, sep: string, i: number, j: number): string`
- `create(count: number, value: Variant): table`
- `find(haystack: table, needle: Variant, init: number): Variant`
- `freeze(t: table): table`
- `insert(t: {any}, pos: number, value: Variant): ()`
- `insert(t: {any}, value: Variant): ()`
- `isfrozen(t: table): boolean`
- `maxn(t: table): number`
- `move(src: table, a: number, b: number, t: number, dst: table): table`
- `pack(values...: Variant): Variant`
- `remove(t: {any}, pos: number): Variant`
- `sort(t: {any}, comp: function): ()`
- `unpack(list: table, i: number, j: number): Tuple`

## 테이블 변수는 재정의하기보다 `table.clear` 을 사용합니다

테이블을 객체 재정의가 필요한 경우, 재선언을 하는 것이 유용하지만
(ReactLua 의 의존성 업데이트, 혹은 다른 객체로 선언해야하는 경우 등)
만일 동일 객체로 계속 이어지는 데이터를 담는 식의 테이블이라면 `table.clear` 가 보다 유용합니다.

성능면에서도 똑같고 객체가 달라지지 않습니다.

```luau
-- Bad:
local someTable = {}

someTable = {}

-- Good:
const someTable = {}

table.clear(someTable)
```
