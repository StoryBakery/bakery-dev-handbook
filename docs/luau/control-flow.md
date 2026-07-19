---
title: 제어 흐름
---

## if 문

- 한 줄 `if` 문은 자제하고, 블록을 명확히 나눕니다.
- 조건이 길어지면 각 조건을 변수로 분리하여("도움 변수") 그 의미를 드러냅니다.

```luau
-- Good:
const shouldDoSomething = cond1 and cond2 and cond3
if shouldDoSomething then
    doSomething()
end

-- Bad:
if cond1 and cond2 and cond3 then -- 어떤 조건에서 실행되는건지 한 눈에 보기 어렵습니다
    doSomething()
end
```

## if-then-else 표현식

삼항 연산자(`a and b or c`) 대신 Luau 의 `if-then-else` 표현식을 사용합니다.
`nil` 안전성을 보장하고 가독성이 더 좋습니다.
표현식이 너무 길어지면(3줄 이상) 일반 `if-else` 문을 사용합니다.

```luau
-- Good:
const value = if condition then a else b
```

## 반복문

- `pairs`, `ipairs` 대신 일반화된 `in` 키워드를 사용합니다.
- 딕셔너리는 `k, v`, 배열은 `i, v` (또는 `index, value`) 로 변수명을 구분해 타입을 암시합니다.

```luau
for index, value in list do
    -- ...
end
```
