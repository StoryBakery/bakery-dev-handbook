---
sidebar_label: OOP Style
---

# OOP-Style

## 개요
Story-Bakery 에서 사용하는 객체지향(OOP) 패턴과 모듈 내부 구조에 대한 가이드입니다. 일관된 멤버 순서와 생명주기 관리 패턴을 유지하여 코드의 예측 가능성을 높입니다.

## 문서화

API 문서는 `moonwave` 를 기반으로 작성합니다. 상세한 규칙은 [document-based-comment](./document-based-comment.md) 를 참고하십시오.

## 예제

```lua
--[=[
    @class Class
    Class 객체에 대한 설명
]=]

local Class = {}
Class.__index = Class
Class.__type = "Class"

--[=[
    Class 객체의 새 인스턴스를 생성합니다.
]=]
function Class.new(params: ClassParams?): Class
    local self = setmetatable({}, Class)
    -- ...
    return self
end

function Class:Destroy()
end
```

## 블록-구분-규칙

- **생성자 이름**: 항상 `camelCase` 로 작성합니다. (`Class.new`)
- **내부 함수**: 생성자나 메서드 내부에서만 사용되는 헬퍼는, 해당 스코프 근처에 두거나 로컬 함수로 분리합니다.

## 정의-순서

비슷한 역할의 코드는 가까이 배치합니다. `Params` 타입 선언 → 지역 헬퍼 함수 → 메인 메서드(생성자) 순으로 배치하여 문맥 흐름을 자연스럽게 만듭니다.

### Params-와-지역-함수
- **타입 최상단**: 메서드가 사용하는 `Params` 타입은 해당 메서드 바로 위에 둡니다.
- **헬퍼 배치**: 그 아래에 지역 헬퍼 함수를 선언합니다. 깊은(의존성이 없는) 헬퍼가 먼저 오고, 메인 로직에 가까운 헬퍼가 나중에 옵니다.

### 헬퍼-메서드
- `_` 로 시작하는 프라이빗 메서드(`_helper`)는 이를 호출하는 **공개 메서드 바로 아래**에 배치합니다.
- 호출 관계가 눈에 보이도록 묶어두는 것이 핵심입니다.

## 생성자

### 기본-규칙
- 생성자는 파일 상단(메서드 영역 전)에 배치합니다.
- 이름은 `new`, `fromInstance` 처럼 `camelCase` 를 사용합니다.
- 단순 초기화 외에 복잡한 로직이 필요하다면 `Init` 메서드를 별도로 분리하는 것을 고려합니다.

### 싱글턴
- 싱글턴 패턴이라도 `.new()` 생성자를 정의하여 인스턴스를 만드는 구조를 유지합니다.
- 하단에서 `return Class.new()` 로 내보냅니다.
- 필요하다면 `Class.Global` 같은 정적 속성에 인스턴스를 담아 공유합니다.

### Params-사용
- 생성자 인자가 많거나 확장이 예상되면 `Params` 딕셔너리를 사용합니다.
- 필수 인자가 누락되면 `or error("Missing ...")` 로 명시적으로 에러를 발생시킵니다.

## 속성

### 생명주기-속성
- 모든 객체는 `IsDestroyed` (boolean) 와 `Maid` (Maid) 속성을 가집니다.
- **싱글턴 예외**: 절대 파괴되지 않는 싱글턴은 이 속성이 불필요할 수 있습니다.
- `Destroy()` 메서드에서 `IsDestroyed` 를 체크하고 `Maid` 를 청소합니다.

### 수동-연결-관리
- `Maid` 로 관리하기 어려운(매우 빈번하게 연결/해제되는) 경우에만 `_connection` 같은 내부 변수를 사용합니다. 그 외에는 항상 `Maid:GiveTask()` 를 사용하십시오.

## 메서드

- `:Destroy()` 는 메서드 목록의 **가장 위**에 둡니다.
- getter/setter 는 `Set` -> `Find` -> `Get` 순서로 그룹화하여 배치합니다.
    - `Find`: 없으면 `nil` 반환.
    - `Get`: 없으면 에러 발생 (주로 `Find` 를 호출하고 검증).

## 함수

- 모듈 레벨의 함수(`Class.Fn`)도 메서드와 동일하게 역할별로 그룹화합니다.