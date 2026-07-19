---
title: rojo-syncback Reference
---

이 문서는 `rojo syncback`의 명령어 옵션, 동작, 제한사항을 정리한 레퍼런스입니다.

**기본 미리보기**

```bash
rojo syncback path/to/default.project.json --input path/to/game.rbxl --dry-run --list
```

**검토 후 실제 반영**

```bash
rojo syncback path/to/default.project.json --input path/to/game.rbxl --list --non-interactive
```

**짧은 옵션을 사용한 예시**

```bash
rojo syncback path/to/default.project.json -i path/to/model.rbxm -l -y
```

인자와 옵션은 다음과 같습니다.

- `project`: 프로젝트 파일 또는 프로젝트 위치를 나타내는 위치 인자입니다. 생략하면 Rojo가 현재 디렉터리 기준으로 프로젝트를 찾습니다.
- `--input`, `-i`: 읽어올 Roblox 파일 경로입니다. 필수입니다.
- `--list`, `-l`: 추가/삭제 예정 경로를 stdout에 `Writing ...`, `Removing ...` 형식으로 출력합니다.
- `--dry-run`: 비교만 수행하고 디스크에는 쓰지 않습니다.
- `--non-interactive`, `-y`: 실제 쓰기 전에 나오는 확인 프롬프트를 건너뜁니다.
- `--color`: Rojo 전역 색상 옵션입니다. 로그를 기계적으로 처리하려면 `--color never`를 사용하는 것이 좋습니다.
- `-v`: Rojo 전역 상세 로그 옵션입니다. 여러 번 붙이면 더 자세한 로그가 나옵니다.

지원하는 입력 파일 형식은 다음과 같습니다.

- `.rbxl`: 바이너리 Roblox place 파일입니다.
- `.rbxlx`: XML Roblox place 파일입니다.
- `.rbxm`: 바이너리 Roblox model 파일입니다.
- `.rbxmx`: XML Roblox model 파일입니다.

모델 입력 제한이 있습니다. `.rbxm`, `.rbxmx` 입력은 최상위 Instance가 정확히 하나여야 합니다. 모델 파일에 최상위 Instance가 여러 개 있으면 Rojo가 오류를 냅니다.

## 출력 동작

syncback은 실제로 쓰기 전에 메모리 안에서 파일 시스템 스냅샷을 만듭니다.
`--list`를 사용하면 쓰거나 삭제할 경로를 출력합니다. `--dry-run`을 사용하면 디스크에 쓰기 전에 종료합니다.
`--dry-run`이 없으면 기본적으로 확인 프롬프트가 나오며, `--non-interactive` 또는 `-y`를 사용하면 프롬프트 없이 진행합니다.

명령의 일반 진단 출력은 stderr로 기록됩니다. 따라서 `--list`의 stdout 출력을 별도로 파이프하거나 파싱할 수 있습니다.

Rojo는 syncback 경로 변경에서 항상 `.git/**`을 보호합니다.

## `syncbackRules`

`syncbackRules`는 Rojo 프로젝트 파일의 최상위 필드입니다. 어떤 Roblox 하위 트리, 파일 시스템 경로, 속성을 syncback에서 무시하거나 포함할지 제어합니다.

예시입니다.

```json
{
  "name": "MyGame",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "$path": "src/ReplicatedStorage"
    },
    "Workspace": {
      "$path": "src/Workspace"
    }
  },
  "syncbackRules": {
    "ignoreTrees": [
      "ServerStorage/ImportantSecrets"
    ],
    "ignorePaths": [
      "src/Workspace/Generated/**",
      "!src/Workspace/Generated/KeepMe.model.json"
    ],
    "ignoreProperties": {
      "BasePart": ["Color"],
      "Workspace": ["Gravity"]
    },
    "syncCurrentCamera": false,
    "syncUnscriptable": true,
    "ignoreReferents": false,
    "createIgnoreDirPaths": true
  }
}
```

### `ignoreTrees`

무시할 Roblox Instance 경로입니다. 이 경로는 파일 시스템 경로가 아니라 Roblox 트리 기준 경로입니다.

입력 place나 model에 어떤 하위 트리가 존재하지만 프로젝트로 되가져오면 안 되는 경우 사용합니다.
예를 들어 `ServerStorage` 전체가 syncback 범위 안에 있더라도 `ServerStorage/ImportantSecrets`는 건너뛸 수 있습니다.

매칭은 접두사 기반입니다. 어떤 Instance 경로가 무시 대상 트리 경로로 시작하면 syncback은 그 Instance를 건너뛰고, 해당 무시 트리에 대응하는 기존 파일도 삭제하지 않도록 처리합니다.

### `ignorePaths`

무시할 파일 시스템 glob 패턴입니다. 이 경로는 프로젝트 파일이 있는 폴더를 기준으로 한 상대 경로입니다.

생성 파일, 직접 관리하는 파일, 패키지 출력물, 또는 syncback이 건드리면 안 되는 폴더를 보호할 때 사용합니다.

현재 소스는 gitignore 방식의 “마지막 매칭 우선” 동작을 지원하며, `!`로 시작하는 부정 패턴도 지원합니다.

```json
{
  "ignorePaths": [
    "src/Workspace/Generated/**",
    "!src/Workspace/Generated/KeepMe.model.json"
  ]
}
```

이 규칙은 파일 쓰기와 삭제 모두에 영향을 줍니다. `.git/**`은 명시하지 않아도 항상 무시됩니다.

### `ignoreProperties`

syncback하지 않을 Roblox 클래스 이름과 속성 이름의 매핑입니다.

Studio에서 자주 변하거나, 생성되거나, 환경에 따라 달라지거나, 코드로 관리되는 속성을 제외하고 싶을 때 사용합니다.
이 필터는 상속을 고려합니다. 예를 들어 `BasePart`의 특정 속성을 무시하면 `BasePart`를 상속한 하위 클래스에도 적용됩니다.

필터는 해시 비교와 직렬화 전에 기존 트리와 새 트리 모두에 적용됩니다. 그래서 무시한 속성 때문에 불필요한 파일 재작성이나 diff가 생기는 것을 줄일 수 있습니다.

### `syncCurrentCamera`

`Workspace.CurrentCamera`를 포함할지 제어합니다. 기본값은 `false`입니다.

`false`이면 syncback은 `Workspace.CurrentCamera`가 가리키는 Camera Instance를 입력 DOM에서 제거한 뒤 직렬화합니다.
Studio 세션의 카메라 상태가 프로젝트에 커밋되는 일을 막기 위한 기본 동작입니다.

카메라 Instance 자체가 의도적으로 프로젝트 데이터일 때만 `true`로 설정합니다.

### `syncUnscriptable`

스크립트에서 수정할 수 없는 속성을 syncback할지 제어합니다. 기본값은 `true`입니다.

`false`이면 Roblox reflection 메타데이터에서 non-scriptable로 표시된 속성을 생략합니다.
프로젝트를 더 깔끔하게 유지하고 싶거나 Studio 내부 데이터로 인한 불필요한 변경을 피하고 싶을 때 유용합니다.

### `ignoreReferents`

참조 속성 연결을 건너뛸지 제어합니다. 기본값은 `false`입니다.

참조 속성은 다른 Instance를 가리키는 속성입니다. 예를 들면 `Model.PrimaryPart`, `ObjectValue.Value`가 있습니다.
`ignoreReferents`가 `false`이면 syncback은 Rojo 참조 attribute를 할당하거나 재사용하고,
직렬화된 파일에 포인터 메타데이터를 기록해 이런 연결을 보존하려고 시도합니다.

프로젝트가 Rojo 참조 attribute를 원하지 않거나 참조 연결을 다른 방식으로 관리할 때만 `true`로 설정합니다.

참조 속성이 syncback 범위 밖의 Instance를 가리키면 직렬화 결과에서 nil이 되거나 링크가 생략될 수 있습니다.
중요한 참조는 양쪽 Instance가 모두 프로젝트 트리 안에 들어오도록 하고,
`ignoreTrees`와 `ignorePaths`가 해당 대상을 제외하지 않는지 확인해야 합니다.

### `createIgnoreDirPaths`

`/**`로 끝나는 ignore glob이 디렉터리 자체도 무시할지 제어합니다. 기본값은 `true`입니다.

예를 들어 `createIgnoreDirPaths: true`이면 `src/Generated/**`는 `src/Generated` 디렉터리 자체도 보호합니다.

하위 항목은 무시하되 디렉터리 경로 자체는 매칭 가능해야 하는 고급 워크플로가 아니라면 기본값을 유지합니다.

## 기능 목록

### 프로젝트 기반 배치

syncback은 프로젝트 트리를 사용해 무엇이 범위 안인지, 그리고 어디에 출력할지 결정합니다.
이 기능이 가장 중요합니다. 일반 프로젝트 파일의 범위가 너무 좁거나 넓다면 syncback 전용 프로젝트 파일을 따로 만드는 것이 좋습니다.

### 하위 항목 syncback

프로젝트 노드가 범위 안에 있으면, Roblox 파일에 있는 그 하위 Instance들을 되가져올 수 있습니다.
예를 들어 프로젝트에 `ReplicatedStorage` 서비스를 포함해 두면 그 아래 새로 생긴 자식이나 변경된 자식도 받을 수 있습니다.

### 기존 미들웨어 보존

Instance가 이미 디스크에 존재하면 syncback은 보통 기존 미들웨어 또는 파일 표현 방식을 유지합니다.
예를 들어 기존 `.rbxm`, `.rbxmx`, `.model.json`, 스크립트 파일이 있으면 Rojo 기본 선택으로 바꾸기보다는 기존 표현을 유지하려고 합니다.

### 기본 미들웨어 선택

새 Instance에 대해서 Rojo는 클래스와 구조에 따라 직렬화 형식을 고릅니다.

- `Folder`, `Configuration`, `Tool`: 디렉터리
- `StringValue`: `.txt`
- `Script`: `.server.luau`
- `LocalScript`: `.client.luau`
- `ModuleScript`: `.luau`
- `LocalizationTable`: `.csv`
- 여러 effect, chat, sound, actor, remote, bindable, value 계열 클래스: `.model.json`
- 알 수 없거나 복잡한 Instance: `.rbxm`

Instance에 자식이 있으면 필요한 경우 디렉터리와 init 파일 조합을 사용할 수 있습니다.

### 스크립트 추출

스크립트의 `Source`는 Luau 파일로 저장됩니다.

- `Script` → `name.server.luau`
- `LocalScript` → `name.client.luau`
- `ModuleScript` → `name.luau`
- 스크립트 디렉터리 표현에서는 `init.server.luau`, `init.client.luau`, `init.luau`, `init.plugin.luau`를 사용할 수 있습니다.

소스 코드가 아닌 메타데이터가 필요하면 인접한 `.meta.json` 또는 `init.meta.json`에 기록될 수 있습니다.

### 디렉터리와 init 파일 syncback

디렉터리는 단순 폴더를 나타낼 수도 있고, 자식을 가진 Instance를 나타낼 수도 있습니다.
스크립트, LocalizationTable, 또는 호환 가능한 Instance에 자식이 있으면
syncback은 디렉터리 내부에 init 파일을 만들고 그 옆에 하위 항목을 함께 동기화할 수 있습니다.

빈 디렉터리는 디스크에서 유지되도록 `.gitkeep`을 받을 수 있습니다.

### LocalizationTable syncback

`LocalizationTable` Instance는 CSV로 직렬화됩니다. 디렉터리 형태로 표현될 경우 테이블 내용은 `init.csv`에 들어갑니다.

### JSON model syncback

`.model.json`은 지원되는 Instance의 클래스 이름, 속성, attribute, 자식, schema, 참조 메타데이터를 저장합니다.
단순 폴더나 텍스트 값이 아닌 여러 비스크립트 객체에 적합한 구조화 형식입니다.

현재 소스 기준으로 새 Instance가 기본적으로 JSON model로 매핑되는 주요 클래스는 다음과 같습니다.

- `Actor`
- `Sound`, `SoundGroup`
- `Sky`, `Atmosphere`
- `BloomEffect`, `BlurEffect`, `ColorCorrectionEffect`, `DepthOfFieldEffect`, `SunRaysEffect`
- `ParticleEmitter`
- `TextChannel`, `TextChatCommand`
- `ChatWindowConfiguration`, `ChatInputBarConfiguration`, `BubbleChatConfiguration`, `ChannelTabsConfiguration`
- `RemoteEvent`, `UnreliableRemoteEvent`, `RemoteFunction`
- `BindableEvent`, `BindableFunction`
- 이름이 `-Value`로 끝나는 클래스

### RBXM/RBXMX fallback

알 수 없거나 복잡한 Instance는 기본적으로 `.rbxm`으로 저장됩니다.
디렉터리 직렬화가 실패하는 경우, 예를 들어 자식 이름이 파일 시스템에서 충돌하는 경우, syncback은 모델 직렬화로 fallback할 수 있습니다.

내부 환경 변수 `ROJO_SYNCBACK_DEBUG`는 새 모델 fallback 출력을 `.rbxmx` 또는 `.model.json`으로 강제할 수 있지만,
일반 사용자 워크플로에서는 이 기능에 의존하지 않는 것이 좋습니다.

### 속성 필터링

syncback은 관련 있고 직렬화 가능한 속성만 기록합니다.
기본값과 동일한 속성, reflection 메타데이터에서 직렬화하지 않는 것으로 표시된 속성,
`ignoreProperties`로 차단된 속성은 생략합니다. `syncUnscriptable`이 `false`이면 non-scriptable 속성도 생략합니다.

### 참조 속성 보존

기본적으로 syncback은 `Model.PrimaryPart` 같은 참조 속성을 보존하려고 합니다.
이를 위해 참조 attribute를 통해 링크를 만들고, 중복되거나 누락된 Rojo reference ID를 필요에 따라 다시 작성합니다.

### 해시 기반 no-op 감지

syncback은 필터를 적용한 뒤 기존 하위 트리와 새 하위 트리를 해시로 비교합니다. 동일하다고 판단되면 해당 하위 트리의 불필요한 재작성을 건너뜁니다.

### 삭제 처리

기존 Rojo 프로젝트에는 자식이 있지만 입력 Roblox 파일에는 대응되는 자식이 없으면,
syncback은 해당 기존 파일 표현을 삭제 대상으로 예약할 수 있습니다.
`ignorePaths`와 `ignoreTrees`는 삭제로부터 경로를 보호할 수 있습니다.

### 중첩 프로젝트 지원

syncback은 다른 프로젝트 구조 안에서 참조되는 프로젝트 파일과도 함께 동작할 수 있습니다. 지원되는 경우 기존 schema 필드와 프로젝트 파일 구조가 왕복 보존됩니다.

### syncRules 인식

기존 `syncRules`와 이전 미들웨어 선택은 파일 인식과 보존 방식에 영향을 줍니다. 프로젝트가 커스텀 확장자나 sync rule을 사용한다면, 계획된 출력을 해석하기 전에 해당 규칙을 먼저 확인해야 합니다.
