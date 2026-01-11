---
sidebar_label: Syntax Style
---

# Syntax-Style

## 개요

Luau 의 언어적 기능(조건문, 루프, 타입 등)을 안전하고 명확하게 사용하기 위한 가이드입니다.

## 제어문

### If-문
- 한 줄 `if` 문은 자제하고, 블록을 명확히 나눕니다.
- 조건이 길어지면 각 조건을 변수로 분리하여("도움 변수") 그 의미를 드러냅니다.

```lua
-- Good:
local shouldDoSomething = cond1 and cond2 and cond3
if shouldDoSomething then
    doSomething()
end
```

### If-Then-Else-표현식
- 삼항 연산자(`a and b or c`) 대신 Luau 의 `if-then-else` 표현식을 사용합니다.
- `nil` 안전성을 보장하고 가독성이 더 좋습니다.
- 표현식이 너무 길어지면(3줄 이상) 일반 `if-else` 문을 사용합니다.

```lua
-- Good:
local value = if condition then a else b
```

### 반복문
- `pairs`, `ipairs` 대신 일반화된 `in` 키워드를 사용합니다.
- 딕셔너리는 `k, v`, 배열은 `i, v` (또는 `index, value`) 로 변수명을 구분해 타입을 암시합니다.

```lua
for index, value in list do
    -- ...
end
```

## 함수
- 외부에서 호출되는(Non-member) 함수는 가급적 `local function` 으로 정의합니다.
- 매개변수가 너무 많으면(3개 이상 권장, 최대 7개) `Params` 딕셔너리로 묶습니다.

### 함수-주석
- 함수 이름만으로 의도가 명확하지 않을 때, 혹은 API 문서를 작성할 때만 주석을 답니다.
- 일반적인 동작 설명은 함수 이름(`Get...`, `Validate...`)에 녹여내는 것을 우선합니다.

## 타입

### 타입-조합
- Luau 교집합(`&`)을 사용해 상속 구조를 표현합니다.
- 가장 구체적인 타입(Child) → 추상적인 타입(Ancestor) 순으로 나열합니다.

### 외부-타입
- `MyModule.Something` 처럼 외부 모듈 네임스페이스를 그대로 노출하여 출처를 명확히 합니다. 불필요하게 `type Something = MyModule.Something` 으로 재정의(alias) 하지 않습니다.

## 문자열과-숫자

### 문자열-보간
- `string.format` 이나 `..` 연산자 대신 `{var}` 보간법을 사용합니다.
- 긴 문자열은 `\z` 이스케이프 시퀀스를 사용해 코드 상에서 여러 줄로 표현합니다.

```lua
print(`Bob has {count} apples!`)
```

### 숫자-리터럴
- 1 미만 소수는 `0.5` 처럼 0을 명시합니다.
- 큰 숫자는 `1_000_000` 처럼 언더스코어로 자릿수를 구분합니다.

## 출력과-에러

### 에러-처리
- 잘못된 입력(`Validate-`) 등 명백한 오류는 `error()` 를 호출하여 실행을 중단합니다.
- 실패 가능성이 있는 로직(`IsAllowed-`)은 `success, result` (또는 `Result` 타입) 패턴을 사용합니다.

### 메세지-형식
- 객체 이름이나 중요한 값은 따옴표로 감싸 식별하기 쉽게 만듭니다.
- `error(\`Invalid property "{property}"\`)`

## 주석-구문
- 3줄 이하는 `--`, 그 이상은 `--[[ ... ]]` 을 사용합니다.
- API 문서화가 필요한 경우에만 moonwave 스타일(`--[=[ ... ]=]`)을 사용합니다.
