---
sidebar_label: Naming Style
---

# Naming-Style

## 개요
일관된 네이밍 규칙은 코드의 의도를 명확히 전달하고, 협업 효율을 높입니다. 약어 사용을 지양하고, 풀 네임(Full Name)을 사용하여 가독성을 확보하는 것을 원칙으로 합니다.

기본 규칙:
- **PascalCase**: Roblox API, 클래스, 타입, 모듈 반환 객체, 테이블의 공개 멤버(속성/메서드).
- **camelCase**: 지역 변수/함수, private 멤버, 생성자 함수.
- **LOUD_SNAKE_CASE**: 상수.

## 모듈-이름

- 모듈이 **객체(테이블) 하나**를 반환한다면, 모듈 파일명과 객체명을 **일치**시킵니다.
- 모듈이 **단일 함수**만 반환하더라도, `PascalCase` 파일명을 사용합니다.
- 상위 폴더가 맥락을 제공한다면, 파일명에서 중복 접두사를 생략하여 간결하게 유지합니다. (예: `CameraModules/Manager.luau` -> `CameraManager` 로 사용)

## 변수명

### 복수형
문법적으로 어색하더라도 배열/리스트 변수 뒤에는 `s`, `es` 를 붙여 복수임을 명시합니다. (`infos`, `datas`)

### 구분-규칙
- **지역 변수**: `camelCase` 가 기본입니다.
- **PascalCase 변수**: Roblox 서비스, 또는 내부 모듈(`require`)의 반환값을 담을 때 사용합니다.
- **예외**: 외부 패키지(`@vide` 등)가 소문자 네이밍을 권장한다면, 그에 맞춰 `local vide = require(...)` 처럼 소문자를 사용할 수 있습니다.
- **상수**: 값이 변하지 않는다면 `LOUD_SNAKE_CASE` 를 사용합니다.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObjectClass = require(ObjectModules.Class)
local player = Player.LocalPlayer

local MAX_COUNT = 100
```

## 테이블

### 배열
- `{ItemName}s` 또는 `{ItemName}es` 형태를 사용합니다.
- 배열의 배열은 `{ItemName}Lists` 를 사용합니다.

### 딕셔너리
- 키(Key)는 **PascalCase** 를 사용합니다.
- **키-값 쌍**: `<Item>By<Key>` 패턴을 사용합니다.
    - 예: `monsterInfosByMonsterId`
- **중첩**: `<Item>By<Key1>And<Key2>` 패턴을 사용합니다.

### 집합-Set
- 값(Value)이 `true` 인 딕셔너리는 집합으로 취급합니다.
- 변수명 접미사로 `Set` 을 붙입니다. (예: `PlayerSet`)

## 클래스

### 속성-Property

- **Property**: 내재된 속성.
- **Attribute**: 커스텀 상수/설정값.
- **CustomProperty**: 동적으로 추가/제거되는 속성.
- 한국어 문서에서도 정확한 구분을 위해 영어 원문을 그대로 사용합니다.

### 리소스-식별자
변수가 리소스를 가리킬 때는 접미사로 형태를 명시합니다.
- `Id`: 숫자 ID (`number`) -> `IMAGE_ID`
- `Uri`: `rbxassetid://` 문자열 -> `IMAGE_URI`
- `Content`: `Content` 타입 객체 -> `IMAGE_CONTENT`

## 타입

### Enums
- Enum 키는 **PascalCase** 를 사용합니다.

### 시그널
- 이벤트(`RBXScriptSignal`)를 담는 변수는 접미사 `Conn` 을 붙여 연결(Connection) 임을 명시합니다. (`touchedConn`)
- **Updated vs Changed**: `Changed` 는 일반적인 변경, `Updated` 는 더 구체적인 갱신/로직 수행을 의미할 때 사용합니다.

## 함수명

### 찾기-함수
- `Get...`: 대상을 무조건 반환하거나, 없으면 **에러**를 발생시킵니다.
- `Find...`: 대상을 반환하거나, 없으면 **nil** 을 반환합니다. (Optional)

### From-vs-By
- `From`: 복잡한 과정을 거쳐 대상을 추출/변환할 때. (`FindCharacterFromPlayer`)
- `By`: 딕셔너리 키 조회 등 직접적인 식별자로 찾을 때. (`FindCharacterByPlayer`)

### 매개변수
- 선택적 옵션은 `Options`, 필수 설정은 `Params` 접미사를 사용하여 구분합니다.

## 생명주기-메서드
- `Init`: 초기화.
- `Configure`: 설정 재구성.
- `Start`: 실행 시작.
- `Stop`: 실행 중단.

## 기타
- **개수/인덱스**: `count`, `index` 사용. (`number` 등 모호한 이름 지양)
- **시간**: `Date` 대신 `Time` 접미사 사용. (`UpdatedTime`)
- **단위**: `Seconds`, `Meters` 등 단위 접미사 사용. (`delaySeconds`)
- **상태 동사**: `IsVisible`, `CanCollide` 등 3인칭 단수 동사 또는 상태형 사용.
- **이벤트**: `Touched`, `Changed` 등 과거분사형 사용. 핸들러는 `onTouched` 등 `on` 접두사 사용.
