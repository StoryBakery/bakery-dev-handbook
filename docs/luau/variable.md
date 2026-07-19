---
title: 변수
---

Luau 의 변수를 안전하고 명확하게 사용하기 위한 가이드입니다.

## 선언

### 재할당되지 않는 변수는 `const` 를 사용합니다

`local` 만으로 변수를 선언하는 것은 **오래된 관습**입니다.
`const` 를 이용해 명확한 구분을 하는 것이 좋습니다.

ts 처럼 기본적으로 변수 할당은 `const` 로 합니다.

**예시 코드**:

```luau
const Players = game:GetService("Players")

const CameraManager = require("@self/CameraManager")

const CameraModules = {
    Manager = CameraManager,
}

-- LOUD_SNAKE_CASE 인 이유는 기준 설정값이기 때문입니다.
const DEFAULT_ZOOM = 12

local currentTarget = nil
currentTarget = target

local count = 0
count += 1

local result
if ok then
    result = value
end
```

### 초기 환경에 따라 변경되는 const 의 경우 if-then-else 혹은 익명함수 실행을 사용합니다

두 개의 조건에 따라 나뉘는 `const` 라면 `if-then-else` 로
세 개 이상의 조건 혹은 복잡한 조건일 경우 익명함수 실행으로 const 를 정의합니다

```luau
-- 크게 추천되진 않는 패턴이지만, 복잡하게 const 를 정의해야하는 경우
const isDead = (function()
    const isInitiated = script:GetAttribute("IsInitiated")
    if not isInitiated then
        return false
    end

    const isRunning = script:GetAttribute("IsRunning")
    const hasNoChildren = #script:GetChildren() == 0

    return not isRunning and hasNoChildren
end)()
```

## 함수

외부에서 호출되는 함수는 가급적 `const function` 으로 정의합니다.
매개변수가 너무 많으면(3개 이상 권장) `Params` 딕셔너리로 묶습니다.

### 함수 주석

- 함수 이름만으로 의도가 명확하지 않을 때, 혹은 API 문서를 작성할 때만 주석을 답니다.
- 일반적인 동작 설명은 함수 이름(`Get...`, `Validate...`)에 녹여내는 것을 우선합니다.

## 문자열

### 문자열 보간

- `string.format` 이나 `..` 연산자 대신 `{var}` 보간법을 사용합니다.
- 긴 문자열은 `\z` 이스케이프 시퀀스를 사용해 코드 상에서 여러 줄로 표현합니다.

```luau
print(`Bob has {count} apples!`)
```

## 숫자

### 숫자 리터럴

- 1 미만 소수는 `0.5` 처럼 0을 명시합니다.
- 큰 숫자는 `1_000_000` 처럼 언더스코어로 자릿수를 구분합니다.

## 출력과 에러

### 에러 처리

- 잘못된 입력(`Validate-`) 등 명백한 오류는 `error()` 를 호출하여 실행을 중단합니다.
- 실패 가능성이 있는 로직(`IsAllowed-`)은 `success, result` (또는 `Result` 타입) 패턴을 사용합니다.

### 메시지 형식

객체 이름이나 중요한 값은 따옴표로 감싸 식별하기 쉽게 만듭니다.

```luau
error(`Invalid property "{property}"`)
```
