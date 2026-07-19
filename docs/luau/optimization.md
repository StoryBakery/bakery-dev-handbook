---
title: Luau 최적화
---

Luau 는 Lua 와 달리 최적화가 더 진보되었습니다.
그렇기에 Lua 의 기존 최적화 관습이 큰 의미가 없는 경우가 많습니다.

- `object:method(arg)` 를 `const method = object.method` 로 정의 후 `method(object, arg)` 를 실행하는 것.

  비록 후자가 빠르지만, luau 에서 큰 차이는 없습니다.
