---
title: CLI 문서 작성 스타일
---

CLI(Command Line Interface) 문서를 작성하는 경우의 스타일입니다.
기본은 [document-guide](./index.md)를 따릅니다.

## 기본 원칙

- 예시는 복사하여 바로 실행할 수 있어야 합니다.
- 레퍼런스 문서와 튜토리얼 문서를 섞지 않습니다.
- 사용자가 빠르게 훑어도 핵심을 찾을 수 있게 구성합니다.
- 도구의 실제 동작(`--help`, 실제 출력)과 문서를 항상 일치시킵니다.

## 문서 종류 분리

CLI 문서는 목적에 따라 나눕니다.

- Reference: 명령 시그니처, 옵션, 인수, 반환 코드 같은 사실 정리
- How-to: 특정 목표를 달성하는 절차 중심 안내
- Explanation: 설계 이유, 동작 원리, 트레이드오프 설명

한 문서에서 역할을 섞기보다, 역할을 분리한 뒤 링크로 연결합니다.

## 권장 섹션 순서

명령 레퍼런스 문서는 아래 순서를 기본으로 합니다.
해당 항목이 없으면 생략합니다.

1. Synopsis
1. Description
1. Arguments
1. Options
1. Subcommands
1. Exit Status
1. Config Files
1. Environment
1. Examples
1. See Also

## 명령 문법 표기

문법 기호 의미를 문서 전체에서 일관되게 유지합니다.

| 표기 | 의미 | 예시 |
| --- | --- | --- |
| `<name>` | 필수 값 자리 | `<path>` |
| `[<name>]` | 선택 값 자리 | `[<profile>]` |
| `...` | 앞 요소 반복 | `<file>...` |
| `a \| b` | 둘 중 하나 선택 | `json \| yaml` |
| `--` | 옵션 종료 구분자 | `cmd -- -raw-value` |

### 옵션 이름 표기

- 긴 옵션은 `--long-name` 형식으로 작성합니다.
- 짧은 옵션은 `-x` 형식으로 작성합니다.
- 긴 옵션 이름은 소문자 kebab-case를 사용합니다.
- 값이 필요한 옵션은 `--output <dir>`처럼 값을 명시합니다.
- `--output=<dir>` 구문을 지원하더라도 기본 표기는 한 가지로 고정합니다.
- 부정형 옵션을 제공하는 경우 `--no-color`처럼 명확히 표기합니다.

### Synopsis 작성 규칙

- `Synopsis`는 실제 실행 예시가 아닌 문법 요약입니다.
- 코드 블록 언어는 `text`를 사용합니다.
- 한 줄이 너무 길면 구조를 유지한 채 줄을 나눕니다.

```text
bakery build [--watch] [--output <dir>] <project-path>
```

## 섹션별 작성 규칙

### Description

- 명령이 무엇을 하는지 첫 문장에서 명확히 설명합니다.
- 부작용이 있으면 명확히 씁니다.
- 위험한 동작(삭제, 덮어쓰기, 외부 호출)은 별도로 경고합니다.

### Arguments

- 각 인수는 기본적으로 `###` 헤딩으로 분리합니다.
- 인수를 그룹으로 묶는 경우에만 `####`를 사용합니다.
- 타입 또는 값 형식을 코드 스타일로 표기합니다.
- 필요하면 필수 여부, 허용 값, 기본값을 함께 씁니다.

````md
## Arguments

### `<project-path>`

`path`

빌드 대상 프로젝트 경로입니다.
`rojo.json` 파일이 있는 디렉터리를 지정합니다.
````

### Options

- 각 옵션은 기본적으로 `###` 헤딩으로 분리합니다.
- 옵션을 그룹으로 묶는 경우에만 `####`를 사용합니다.
- 짧은/긴 옵션을 모두 제공하면 같은 헤딩에 함께 씁니다.
- 옵션은 긴 옵션 이름 기준으로 정렬합니다.
- 기본값과 우선순위를 명시합니다.
- 폐기 예정 옵션은 버전 또는 날짜를 명시합니다.

옵션이 많다면 아래 구조를 권장합니다.

- Command Options: 현재 명령 전용 옵션
- Global Options: 모든 하위 명령에서 공통 지원하는 옵션
- Inherited Options: 상위 명령에서 상속된 옵션

````md
## Options

### `-o`, `--output <dir>`

`path`

출력 디렉터리입니다.
기본값은 현재 작업 디렉터리입니다.

### `--color <when>`

`auto | always | never`

색상 출력 정책입니다.
````

````md
## Options

### Global Options

#### `--profile <name>`

`string`

실행 프로파일 이름입니다.

### Inherited Options

#### `--verbose`

`boolean`

상위 명령에서 상속된 상세 로그 옵션입니다.
````

### Subcommands

- 하위 명령은 한 줄 요약과 내부 링크를 같이 제공합니다.
- 문서가 분리되어 있다면 상대 경로 링크를 사용합니다.

```md
## Subcommands

- [build](./commands/build.md): 프로젝트를 빌드합니다.
- [deploy](./commands/deploy.md): 빌드 결과를 배포합니다.
```

### Exit Status

- 종료 코드는 표로 관리합니다.
- `0`은 성공, 그 외는 실패로 구분합니다.
- 실패 코드는 원인별로 의미를 분리해 유지보수성을 높입니다.

```md
## Exit Status

| 코드 | 의미 |
| --- | --- |
| `0` | 성공 |
| `2` | 사용법 오류(인수, 옵션 검증 실패) |
| `3` | 런타임 오류(외부 리소스 접근 실패 등) |
```

### Config Files

- 설정 파일 경로 탐색 순서를 명시합니다.
- 다중 설정 병합 시 우선순위와 충돌 해결 규칙을 명시합니다.
- 기본 경로와 파일 포맷을 명시합니다.
- 스키마 버전 키와 호환 정책을 명시합니다.

```md
## Config Files

### 검색 경로

1. `--config <path>` 로 지정한 파일
1. 현재 디렉터리의 `bakery.config.json`
1. 사용자 홈 디렉터리의 `.bakery/config.json`

### 병합/우선순위

CLI option > Environment variable > Config file > Default value

### 스키마

- 포맷: JSON
- 버전 키: `schemaVersion`
```

### Environment

- 환경 변수는 기본적으로 `###` 헤딩으로 분리합니다.
- 성격에 따라 그룹으로 묶는 경우에만 `####`를 사용합니다.
- 값 형식, 기본값, 우선순위 관계를 명시합니다.
- 보안 민감 값은 로그/예시에 평문으로 넣지 않습니다.

````md
## Environment

### `BAKERY_TOKEN`

`string`

인증 토큰입니다.
명령 인수로 전달한 토큰이 있으면 해당 값이 우선합니다.
````

### Examples

- 예시는 기본적으로 `###` 헤딩으로 "목표" 기준 제목을 붙입니다.
- 예시를 그룹으로 묶는 경우에만 `####`를 사용합니다.
- 한 예시에는 한 가지 작업만 담습니다.
- 프롬프트(`$`) 없이 명령만 제공합니다.
- 필요 시 예상 출력은 별도 블록으로 분리합니다.
- 재현 가능한 예시를 위해 경로, 값, 버전을 명확히 씁니다.
- 플랫폼별 문법이 다르면 운영체제별 예시를 분리합니다.

운영체제별 차이가 있으면 아래처럼 분리합니다.

````md
## Examples

### Linux/macOS (bash)

```sh
bakery build ./game --output ./dist
```

### Windows (pwsh)

```pwsh
bakery build .\\game --output .\\dist
```
````

````md
## Examples

### 기본 빌드

```sh
bakery build ./game
```

### JSON 출력

```sh
bakery inspect ./game --format json
```

```json
{
  "project": "game",
  "status": "ok"
}
```
````

### See Also

- 관련 문서, 상위 개념 문서, 인접 명령 문서를 연결합니다.
- 내부 문서는 상대 경로 링크를 사용합니다.

## 출력과 오류 메시지 기록 방식

- 표준 출력(`stdout`)과 표준 오류(`stderr`)를 구분해 설명합니다.
- 사람이 읽는 오류와 기계가 읽는 출력 형식을 분리합니다.
- 오류 메시지 예시는 원인과 해결 방향을 함께 제공합니다.

### 기계 판독 출력 계약

- `--format json` 같은 출력은 안정성 계약을 명시합니다.
- 필드 이름 변경/삭제는 호환성 깨짐으로 간주합니다.
- 확장은 필드 추가 방식으로만 진행합니다.
- 자동화 대상 출력은 `stdout`, 진단 메시지는 `stderr`로 분리합니다.
- 날짜/시간은 `UTC` 기준 `ISO-8601` 형식을 권장합니다.

```md
## Machine-readable Output

### `--format json`

- 안정 버전: `v1`
- 호환 정책: 기존 필드 삭제/이름 변경 없음
- 신규 정보는 필드 추가로만 제공
```

```text
error: profile "prod" was not found
hint: run `bakery profile list` to see available profiles
```

## 우선순위 규칙 명시

옵션, 환경 변수, 설정 파일이 함께 존재하면 우선순위를 문서에 씁니다.

```text
CLI option > Environment variable > Config file > Default value
```

우선순위가 명확하면 디버깅 시간과 운영 중 오해를 줄일 수 있습니다.

## 변경 이력 표기

- 동작 변경은 버전 단위로 기록합니다.
- 상대 표현(최근, 곧, 이후)은 피합니다.
- 날짜를 쓸 때는 `YYYY-MM-DD` 형식을 사용합니다.

예시:

- `v1.4.0`: `--format` 기본값이 `text`에서 `json`으로 변경
- `2026-02-26`: `--legacy-sync` 옵션 사용 중단(deprecated) 표시 추가

### 사용 중단과 제거 정책

- 사용 중단 시점에 대체 경로를 함께 명시합니다.
- 사용 중단 표시는 문서와 `--help`에 동시에 반영합니다.
- 제거 예정 시점은 버전 또는 날짜로 명시합니다.
- 제거 뒤에는 명확한 오류와 전환 가이드를 제공합니다.

```text
error: `--legacy-sync` has been removed in v2.0.0
hint: use `--sync-mode=compat` instead
```

## 리뷰 체크리스트

- `Synopsis`가 실제 파서 동작과 일치하는가
- `--help` 출력과 옵션 설명이 일치하는가
- 옵션 기본값과 우선순위가 문서에 있는가
- 예시 명령이 현재 버전에서 실제로 실행되는가
- 종료 코드가 구현과 일치하는가
- Global/Inherited options 구분이 명확한가
- Config file 탐색 경로와 병합 규칙이 명시되어 있는가
- `--format json` 안정성 계약이 명시되어 있는가
- 사용 중단 항목에 제거 시점과 대체 경로가 있는가
- 플랫폼별 예시가 필요한 항목은 분리되어 있는가
- 내부 링크 경로와 확장자가 올바른가
- 문서 역할(Reference/How-to/Explanation)이 섞이지 않았는가

## 템플릿

새 명령 레퍼런스 문서를 시작할 때 아래 뼈대를 사용할 수 있습니다.

````md
---
title: <command-name>
---

<명령 한 줄 설명>

## Synopsis

```text
<command> [options] <arguments>
```

## Description

<상세 설명>

## Arguments

### `<arg-name>`

`<type>`

<설명>

## Options

### `-x`, `--example <value>`

`<type>`

<설명>

## Exit Status

| 코드 | 의미 |
| --- | --- |
| `0` | 성공 |
| `2` | 사용법 오류 |

## Config Files

### 검색 경로

1. `<우선순위 1>`
1. `<우선순위 2>`

### 병합/우선순위

`CLI option > Environment variable > Config file > Default value`

## Environment

### `EXAMPLE_ENV`

`string`

<설명>

## Examples

### <예시 제목>

```sh
<command example>
```

### <Windows 예시 제목>

```pwsh
<command example>
```

## See Also

- [관련 문서](./related.md)
````

## 참조

- [POSIX Utility Conventions][posix-utility-conventions]
- [GNU: Command-Line Interfaces][gnu-cli]
- [GNU: Option Table][gnu-option-table]
- [Google Developer Style: Code Syntax][google-code-syntax]
- [man-pages(7)][man-pages-7]
- [Microsoft Command-Line Syntax Key][microsoft-command-line-syntax-key]
- [Diátaxis][diataxis]

[posix-utility-conventions]: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html
[gnu-cli]: https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html
[gnu-option-table]: https://www.gnu.org/prep/standards/html_node/Option-Table.html
[google-code-syntax]: https://developers.google.com/style/code-syntax
[man-pages-7]: https://man7.org/linux/man-pages/man7/man-pages.7.html
[microsoft-command-line-syntax-key]: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/command-line-syntax-key
[diataxis]: https://diataxis.fr/
