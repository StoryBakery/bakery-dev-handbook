---
name: luau
description: StoryBakery의 Luau 코드를 작성, 수정, 리뷰하거나 포맷, 구조, 네이밍, 모듈, 객체, 타입, 타입 함수 규칙을 적용할 때 사용합니다.
---

# Luau

작업과 관련된 reference를 먼저 읽고 기존 프로젝트의 더 구체적인 규칙과 함께 적용합니다.
코드를 변경한 뒤에는 포맷과 타입 검사를 포함해 프로젝트에서 제공하는 검증을 실행합니다.

## References

### Core

- `references/index.md`: StoryBakery Luau 가이드의 목적과 적용 범위를 확인할 때
- `references/config.md`: `.luaurc`의 위치와 기본 설정을 작성하거나 변경할 때
- `references/formatting.md`: 들여쓰기, 줄 길이, 공백, 줄바꿈, 따옴표 등 코드 형식을 다룰 때
- `references/structure.md`: Luau 파일의 블록 순서, ModuleScript 구성, 코드 분리 기준을 다룰 때
- `references/comment.md`: 주석 문장과 구두점 규칙을 적용할 때
- `references/naming.md`: 모듈, 변수, 컬렉션, 타입, 함수, 생명 주기 함수의 이름을 정할 때
- `references/variable.md`: 변수 선언, 함수 주석, 문자열, 숫자, 오류 메시지를 작성할 때
- `references/control-flow.md`: 조건문, if 표현식, 반복문을 작성하거나 정리할 때
- `references/optimization.md`: Luau 코드의 성능을 최적화하거나 성능 관련 리뷰를 할 때
- `references/anti-pattern.md`: Luau 안티패턴을 볼 때. 과도한 분기를 지양합니다.
- `references/agent-anti-pattern.md`: 에이전트가 자주하는 Luau 안티패턴들.

### Module

- `references/module/require.md`: `require` 경로, 선언 순서, 외부 라이브러리 별칭을 다룰 때

### Object-Oriented-Programming

- `references/object/index.md`: Luau 객체 설계의 기본 규칙을 확인할 때
- `references/object/table-object.md`: 테이블 기반 객체의 정의 순서, 생성자, 속성, 메서드를 작성할 때

### Library

- `references/library/buffer.md`: Luau `buffer` 라이브러리를 사용할 때
- `references/library/vector.md`: Luau `vector` 라이브러리와 Roblox `Vector3`의 관계를 판단할 때
- `references/library/vector.md`: Luau `table` 라이브러리와 테이블을 사용할 때

### Type

- `references/type/index.md`: 타입 검사 모드, 상속, 외부 타입의 기본 규칙을 다룰 때
- `references/type/generic.md`: 제네릭 타입, 함수, 함수 타입, 타입 팩을 작성할 때
- `references/type/interface.md`: 읽기와 쓰기를 구분하는 인터페이스 타입을 설계할 때
- `references/type/table.md`: 배열 등 테이블 타입의 읽기와 쓰기 규칙을 다룰 때
- `references/type/type-functions.md`: 타입 함수를 도입, 작성, 리뷰하거나 복잡도와 오류 처리를 판단할 때
- `references/type/type-functions-api.md`: 타입 함수에서 사용할 수 있는 `types` 라이브러리 API의 정확한 동작을 확인할 때

## Rules

### Luau 문법 검증

매 코드 작성시마다 검증하는 것이 아닌, 모든 작업이 다 끝난 뒤에 한 번 검증합니다.

For a standard Luau project, run:

```sh
luau-lsp analyze --platform standard
```

For a Roblox/Rojo project, use the repository's existing definitions and sourcemap configuration:

먼저 `.d.luau` 파일을 설치해야합니다. 현재 프로젝트에 맞는 `.d.luau` 를 설치합니다.

```sh
curl -fsSL "https://luau-lsp.pages.dev/type-definitions/globalTypes.None.d.luau" -o "globalTypes.None.d.luau"
```

- `globalTypes.None.d.luau`: 일반 Roblox 게임 코드
- `globalTypes.LocalUserSecurity.d.luau`: 로컬 사용자 권한 API가 필요한 특수 도구
- `globalTypes.PluginSecurity.d.luau`: Roblox Studio 플러그인
- `globalTypes.RobloxScriptSecurity.d.luau`: Roblox 내부·CoreScript 수준 코드
- `globalTypes.d.luau`: 보안 수준 이름이 없는 기본 생성본

```sh
luau-lsp analyze --platform roblox --sourcemap sourcemap.jso --definitions @roblox=globalTypes.d.luau
```

타입 에러를 최대한 해결하려고 노력합니다.