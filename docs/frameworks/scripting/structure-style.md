---
sidebar_label: Structure Style
---

# Structure-Style

## 개요

스크립트 파일의 내부 레이아웃과, 코드를 함수/모듈 단위로 나누는 구조적 원칙을 정의합니다.

## 파일-레이아웃

스크립트 파일은 아래 순서를 따릅니다.

1. **지시어 (Directives)**: `--!native`, `--!nolint` 등. (`--!strict` 는 생략)
2. **블록 주석**: 파일의 용도 설명. (API 문서는 문서 주석 사용)
3. **서비스**: `game:GetService` 호출부.
4. **Require**: 외부 모듈 로드. (세부 규칙은 [require-style](./require-style.md) 참고)
5. **상수**: `LOUD_SNAKE_CASE` 상수 정의.
6. **변수와 함수**: 로컬 변수 및 헬퍼 함수.
7. **메인 로직/반환**: 모듈 반환 객체 또는 실행 로직.

### ModuleScript
- 의존성을 정적으로 파악하기 위해 `require` 는 가급적 최상단에 모아둡니다.
- 모듈이 반환하는 테이블/함수의 이름은 파일명과 일치시키는 것을 권장합니다.

### RunContext
- `LocalScript` 와 `Script` 를 폴더로 구분하기보다, `Script` 의 **RunContext** 속성을 활용하여 동일한 기능 단위(폴더) 안에서 관리하는 것을 선장합니다.

## 코드-분리

### 함수-나누기
- 하나의 거대한 함수 대신, 역할별로 작은 함수로 나눕니다.
- **오케스트레이션(Orchestration)**: 상위 함수는 흐름만 제어하고, 실제 작업은 하위 함수에 위임합니다.
- 상태값은 상위에서 준비하고, 하위 함수에는 필요한 인자만 전달하여 순수 함수에 가깝게 유지합니다.

```lua
local function processOrder(params)
    -- 준비
    local items = normalizeItems(params.Items)
    -- 계산
    local total = calcOrderTotal(items)
    -- 결과 생성
    return createInvoice(items, total)
end
```

### 재사용과-통일
- 반복되는 로직(상수, 검증, 유틸리티)은 공용 모듈로 분리합니다.
- 새로운 헬퍼를 만들기 전에 `TableUtil` 등 기존 라이브러리나 Roblox 내장 기능을 먼저 검토합니다.
