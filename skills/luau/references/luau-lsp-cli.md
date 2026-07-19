
title: Luau LSP CLI

### 설치하기

rokit 혹은 mise 로 설치하면 됩니다.

`rokit add JohnnyMorganz/luau-lsp`

`mise use "github:JohnnyMorganz/luau-lsp"`

### 명령어

```sh
luau-lsp analyze [OPTIONS] FILES...
luau-lsp lsp [OPTIONS]
luau-lsp require-graph [OPTIONS] FILES...
```

추가로 루트 명령에는 다음 기능이 있습니다.

```sh
luau-lsp --help
luau-lsp --version
luau-lsp --show-flags
```

### 옵션 값 전달 문법

각 서브커맨드는 `:`와 `=`를 옵션 할당 문자로 등록한다.

따라서 일반적으로 다음 세 가지 형태를 사용할 수 있다.

```sh
luau-lsp analyze --platform standard .
luau-lsp analyze --platform=standard .
luau-lsp analyze --platform:standard .
```

정의 파일도 다음과 같이 전달할 수 있다.

```sh
luau-lsp analyze --definitions @roblox=globalTypes.d.luau .
luau-lsp analyze --definitions=@roblox=globalTypes.d.luau .
luau-lsp analyze --definitions:@roblox=globalTypes.d.luau .
```

## `analyze`

다음에 사용합니다:

- 문법 오류
- 타입 오류
- Luau lint 오류
- Luau lint 경고
- 정의 파일 및 플랫폼 구성 과정에서 발생한 진단

기본 구문:

```sh
luau-lsp analyze [OPTIONS] FILES...
```

표준 Luau 검사 명령:

```sh
luau-lsp analyze --platform standard --formatter gnu .
```

sourcemap 이 없는 Roblox/Rojo 프로젝트:

```sh
luau-lsp analyze --platform roblox --definitions @roblox=globalTypes.d.luau --formatter gnu .
```

sourcemap 이 있는 Roblox/Rojo 프로젝트:

```sh
luau-lsp analyze --platform roblox --sourcemap sourcemap.json --definitions @roblox=globalTypes.d.luau --formatter gnu .
```

### 입력 파일 및 디렉터리

`FILES...`에는 파일 또는 디렉터리를 하나 이상 전달해야 합니다.

```sh
luau-lsp analyze src
luau-lsp analyze src/main.luau src/util.luau
luau-lsp analyze .
```

디렉터리를 전달하면 재귀적으로 순회하며 다음 확장자만 수집한다.

```sh
.lua
.luau
```

파일 경로를 직접 전달하면 확장자를 검사하지 않고 입력 목록에 추가한다.
따라서 `.txt` 같은 파일도 명시적으로 전달하면 분석 대상으로 넘어갈 수 있다.

입력 목록을 별도로 중복 제거하지 않는다. 디렉터리와 그 안의 파일을 동시에 전달하면 같은 파일이 여러 번 분석될 수 있다.

파일 수집 로직은 현재 작업 디렉터리를 기준으로 경로를 해석한다.

### `analyze --platform`

지원 값:

```sh
standard
roblox
```

예시:

```sh
luau-lsp analyze --platform standard .
luau-lsp analyze --platform roblox .
```

`--platform`을 생략하면 Standard Luau가 아니라 Roblox 플랫폼 구성이 사용됩니다.

`analyze` 명령은 Roblox 정의 파일을 자동 다운로드하지 않습니다.

### `analyze --definitions`, `--defs`

전역 타입 정의 파일을 등록한다.

```sh
luau-lsp analyze --definitions @roblox=globalTypes.d.luau .
```

`analyze`에서는 다음 두 이름을 모두 사용할 수 있다.

```sh
--definitions
--defs
```

여러 정의 파일을 반복해서 전달할 수 있습니다.

```sh
luau-lsp analyze --definitions @roblox=globalTypes.d.luau --definitions @lune=luneTypes.d.luau .
```

### `analyze --sourcemap`

Rojo 기반 `sourcemap.json` 경로를 지정합니다.

```sh
luau-lsp analyze --platform roblox --sourcemap sourcemap.json .
```

이 옵션은 플랫폼이 `roblox`일 때만 적용됩니다.
없는 경우 생략 가능

### `analyze --formatter`

지원 값:

```sh
default
plain
gnu
```

#### `default`

출력 스트림: `stderr`

형식:

```sh
file.luau(3,12): TypeError: message
file.luau(8,1): SyntaxError: message
```

#### `plain`

Luacheck 호환 형태다.

출력 스트림: `stdout`

형식:

```sh
file.luau:3:12-20: (W0) TypeError: message
```

여러 줄 범위의 진단은 끝 열을 임의로 `100`으로 표시한다.

`plain` 포맷은 분석 실패 수와 관계없이 분석 단계 마지막에 항상 종료 코드 `0`을 반환한다.
즉, 타입 오류나 lint 오류가 있어도 다음 명령은 성공으로 인식될 수 있다.

```sh
luau-lsp analyze --formatter plain .
```

CI, 에이전트 검증, Git hook에서는 `plain`을 사용하면 안 된다.

#### `gnu`

출력 스트림: `stderr`

형식:

```sh
file.luau:3.12-3.20: TypeError: message
```

에이전트나 CI에서는 다음 형식을 권장한다.

```sh
luau-lsp analyze --formatter gnu --platform standard .
```

출력 형식과 `plain`의 종료 코드 예외는 분석 구현에 직접 정의되어 있다.

### 분석 성공 및 실패 기준

`default` 또는 `gnu` 포맷에서는 다음 항목이 있으면 종료 코드 `1`을 반환한다.

- 보고된 문법 오류
- 보고된 타입 오류
- lint 오류
- 클라이언트 또는 플랫폼 설정 과정에서 수집된 진단
- 파일을 열지 못한 경우

다음 항목은 출력되지만 자체적으로 실패 조건이 되지 않는다.

- 일반 lint 경고

정상적으로 모든 검사를 통과하면 종료 코드 `0`이다.

`plain` 포맷은 앞서 설명한 것처럼 최종 실패 집계를 무시하고 `0`을 반환한다.
다만 파일 누락, 잘못된 설정 파일 경로, 잘못된 `.luaurc`처럼 분석 시작 전 발생한 오류는 여전히 `1`을 반환할 수 있다.

### `analyze --ignore`

오류 출력을 무시할 파일 glob을 추가한다.

```sh
luau-lsp analyze --ignore "**/generated/**" --ignore "**/vendor/**" .
```

반복해서 사용할 수 있다.

`--settings`에서 가져온 `ignoreGlobs` 뒤에 CLI의 glob들이 추가된다.

기본 `ClientConfiguration`에는 다음 ignore glob도 포함되어 있다.

```sh
**/_Index/**
```

### `analyze --settings`

VS Code 스타일의 설정 JSON 파일을 읽는다.

```sh
luau-lsp analyze --settings luau-lsp-settings.json .
```

예시 파일:

```json
{
  "luau-lsp.platform.type": "standard",
  "luau-lsp.ignoreGlobs": [
    "**/generated/**"
  ],
  "luau-lsp.types.definitionFiles": {
    "@project": "types/project.d.luau"
  },
  "luau-lsp.fflags.enableNewSolver": true,
  "luau-lsp.fflags.override": {
    "LuauSolverV2": "true"
  }
}
```

### `analyze --base-luaurc`

기본 `.luaurc` 구성 파일을 지정한다.

```sh
luau-lsp analyze --base-luaurc config/base.luaurc .
```

이 파일은 프로젝트별 `.luaurc`가 적용되기 전의 기본 구성 역할을 한다.

### `analyze --annotate`

타입 검사 후 추론된 타입 주석을 포함한 소스를 `stdout`에 출력한다.

```sh
luau-lsp analyze --annotate --platform standard src/main.luau
```

`--annotate`를 사용하면 일반 분석 경로 대신 `checkStrict()`를 사용한다.
타입 그래프를 유지한 뒤 `attachTypeData()`와 `prettyPrintWithTypes()`로 결과를 생성한다.

주의점:

- 원본 파일을 수정하지 않는다.
- 결과를 `stdout`에 출력한다.
- 여러 파일을 전달하면 파일명 구분자를 추가하지 않고 결과가 순서대로 출력된다.
- 진단은 선택한 formatter의 스트림으로 별도 출력된다.
- `--formatter plain`도 `stdout`을 사용하므로 `--annotate`와 함께 사용하면 결과가 섞일 수 있다.
- 타입 또는 lint 오류가 있으면 `default`·`gnu` 포맷에서는 여전히 실패한다.

### `analyze --timetrace`

Luau 컴파일러 시간 추적을 활성화하고 `trace.json` 생성을 요청한다.

```sh
luau-lsp analyze --timetrace .
```

이 기능은 실행 파일이 다음 CMake 옵션으로 빌드된 경우에만 사용할 수 있다.

```sh
LUAU_ENABLE_TIME_TRACE=ON
```

기본 CMake 값은 `OFF`다.

지원 없이 빌드된 실행 파일에서 사용하면 다음 메시지를 출력하고 종료 코드 `1`을 반환한다.

```sh
To run with --timetrace, Luau has to be built with LUAU_ENABLE_TIME_TRACE enabled
```

## `lsp`

Language Server Protocol 서버를 시작한다.

```sh
luau-lsp lsp [OPTIONS]
```

이 명령은 타입 검사를 한 번 실행하고 종료하는 명령이 아니다.
LSP 클라이언트와 JSON-RPC 메시지를 교환하는 장기 실행 프로세스다.

LSP 입력 루프가 끝났을 때 클라이언트가 정상적인 `shutdown` 요청을 보냈다면 종료 코드 `0`을 반환한다.
`shutdown` 요청 없이 입력 루프가 종료되면 비정상 종료로 판단하여 종료 코드 `1`을 반환한다.

### `lsp --pipe`

Unix domain socket을 통해 LSP 메시지를 교환한다.

```sh
luau-lsp lsp --pipe /tmp/luau-lsp.sock
```

중요한 점은 `luau-lsp`가 소켓 서버를 생성해서 listen하는 것이 아니라, 지정된 Unix domain socket에 클라이언트로 연결한다는 것이다.

내부적으로 다음 소켓을 생성한다.

```sh
AF_UNIX
SOCK_STREAM
```

소켓 생성 또는 연결 실패 시 예외가 발생한다.

```sh
Failed to create socket
Failed to connect to socket at <PATH>
```

`--pipe`와 `--stdio`를 동시에 지정하면 종료 코드 `1`을 반환한다.

```sh
both --stdio and --pipe cannot be specified at the same time
```

Windows에서는 `--pipe`를 지원하지 않으며 종료 코드 `1`을 반환한다.

```sh
--pipe is not supported on windows
```

### `lsp --definitions`

LSP 서버가 사용할 전역 정의 파일을 등록한다.

```sh
luau-lsp lsp --definitions @roblox=globalTypes.d.luau
```

반복해서 사용할 수 있다.

```sh
luau-lsp lsp --definitions @roblox=globalTypes.d.luau --definitions @project=projectTypes.d.luau
```

`analyze`와 달리 `lsp`에는 `--defs` 별칭이 등록되어 있지 않다.

정의 경로 파싱 규칙은 Analyze와 동일하다.

- `@NAME=PATH` 권장

- `@`가 없으면 자동 추가

- 경로만 전달하는 레거시 문법 지원

- 같은 패키지 키가 반복되면 첫 값이 유지됨

### `lsp --docs`, `--documentation`

정의 파일에 대응하는 문서 데이터베이스 JSON 파일을 불러온다.

두 옵션 이름은 동일한 기능이다.

```sh
luau-lsp lsp --docs docs.json
luau-lsp lsp --documentation docs.json
```

반복해서 여러 파일을 전달할 수 있다.

문서 파일을 하나도 주지 않으면 서버는 문서가 제공되지 않는다는 경고 메시지를 보낸다.

문서 파일을 읽지 못하거나 JSON 파싱에 실패하면 LSP 로그와 창 메시지로 오류를 보내지만, 해당 함수 자체는 서버 프로세스를 즉시 종료하지 않는다.

문서 데이터베이스는 기본 문서, 함수 매개변수 및 반환값, 테이블 키, 오버로드, 학습 링크, 코드 예제 등을 읽을 수 있다.

### `lsp --settings`

LSP 서버 시작 시 사용할 기본 클라이언트 설정 JSON을 지정한다.

```sh
luau-lsp lsp --settings luau-lsp-settings.json
```

Analyze와 동일한 점 표기 JSON 파서를 사용한다.

파일 자체를 읽지 못하면 종료 코드 `1`이다.

```sh
Failed to read base LSP settings at '<PATH>'
```

JSON 구문 오류는 파서가 메시지를 출력한 뒤 빈 설정 객체로 계속 진행할 수 있다.

실제 LSP 클라이언트가 초기화 이후 전송하는 설정이 이 기본값을 변경할 수도 있다.

### `lsp --base-luaurc`

LSP 워크스페이스의 기본 Luau 설정을 지정한다.

```sh
luau-lsp lsp --base-luaurc config/base.luaurc
```

파일 읽기 또는 파싱 실패 시 서버를 시작하지 않고 종료 코드 `1`을 반환한다.

### `lsp --delay-startup`

디버거가 프로세스에 연결될 시간을 주기 위한 개발용 옵션이다.

```sh
luau-lsp lsp --delay-startup
```

구현은 단순한 무한 busy loop다.

```cpp
auto d = 4;
while (d == 4)
{
    d = 4;
}
```

디버거에서 변수 값을 직접 변경하지 않는 이상 서버가 시작되지 않는다.

일반 실행, 에이전트, CI에서는 절대 사용하지 않는다.

### `lsp --enable-crash-reporting`

Sentry 기반 crash reporting을 활성화한다.

```sh
luau-lsp lsp --enable-crash-reporting
```

이 기능은 실행 파일이 다음 옵션으로 빌드된 경우에만 동작한다.

```sh
LSP_BUILD_WITH_SENTRY=ON
```

CMake 기본값은 `OFF`다.

Sentry 지원 없이 빌드된 실행 파일에서는 다음 경고만 출력하고 서버 실행을 계속한다.

```sh
Ignoring '--enable-crash-reporting' as this server was not built with crash reporting features
```

### `lsp --crash-report-directory`

Sentry crash reporting 데이터베이스를 저장할 경로를 지정한다.

```sh
luau-lsp lsp --enable-crash-reporting --crash-report-directory .crash-reports
```

다음 두 조건이 모두 충족될 때만 사용된다.

- 실행 파일이 Sentry 지원으로 빌드됨
- `--enable-crash-reporting`이 지정됨

단독으로 전달하면 실질적으로 사용되지 않는다.

## `require-graph`

Luau 모듈의 `require` 의존성 그래프를 생성한다.

```sh
luau-lsp require-graph [OPTIONS] FILES...
```

### 기본 사용법

JSON 출력:

```sh
luau-lsp require-graph --platform standard --output-format json .
```

DOT 출력:

```sh
luau-lsp require-graph --platform standard --output-format dot .
```

파일로 저장:

```sh
luau-lsp require-graph --platform standard --output-format json . > require-graph.json
```

```sh
luau-lsp require-graph --platform standard --output-format dot . > require-graph.dot
```

## 에이전트용 권장 명령

### Standard Luau 프로젝트

```sh
luau-lsp analyze --platform standard --formatter gnu .
```

### Roblox 프로젝트

```sh
luau-lsp analyze --platform roblox --sourcemap sourcemap.json --definitions @roblox=globalTypes.d.luau --formatter gnu .
```

### 특정 파일만 빠르게 검사

```sh
luau-lsp analyze --platform standard --formatter gnu src/main.luau src/util.luau
```

### 타입 주석 결과 생성

```sh
luau-lsp analyze --platform standard --annotate src/main.luau > annotated-main.luau
```

### 의존성 그래프 생성

```sh
luau-lsp require-graph --platform standard --output-format json . > require-graph.json
```
