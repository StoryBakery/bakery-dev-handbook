---
title: 테이블 타입
---

## 배열

키가 숫자인 딕셔너리가 아닌 이상 배열을 정의할 때는 `{ T }` 로 합니다

```luau
-- 딕셔너리 뉘앙스가 강한 타입, table.insert 가 아닌 t[key] = item 으로 하는 경우에 좋음
type ItemsByNumber = { [number]: Item }

-- 배열 뉘앙스가 강한 타입, table.insert/table.remove 를 사용하기 좋음
type Items = { Item }
```

### read 와 write

자주 쓰이는 문법은 아니지만 구분이 필요한 경우 사용이 필요할 수 있습니다.

```luau
type ReadOnlyMap<K, V> = { read [K]: V }
type WriteOnlyMap<K, V> = { write [K]: V }

type ReadOnlyArray<T> = { read T }
type WriteOnlyArray<T> = { write T }
```

read 는 읽기만 가능하고, write 는 쓰기만 가능하다는 의미입니다.
