---
title: project.json 사용법
---

`*.project.json` 은 로컬 파일을 로블록스에서 어떻게 나타날지에 대해 정의하는 파일입니다.

## 사실 Rojo 의 `json` 파일들은 `jsonc` 포맷입니다

Rojo 는 기본적으로 `*.json` 으로 데이터를 표시하는 경우가 많습니다.
그러나 `.json` 이라고 확장자를 지을 뿐 실제 처리하는 방식은 후행 콤마를 지원하는 `jsonc` 입니다.

## `project.json` 은 상황에 따라 모델 혹은 플레이스 로 나타냅니다

### `project.json` 에 매핑된 폴더의 자손 폴더에 `default.project.json` 이 있다면 또다른 인스턴스로 취급됩니다

```sh
src/
  Game
    GameManager.luau
    CharacterNetworkManager/
      default.project.json
      Packages/
      src/
        init.client.luau
        Module.luau
        Remotes.model.json
        Character.rbxm
default.project.json
```

```sh
game
|- ReplicatedStorage
   |- Game
      |- GameManager (ModuleScript)
      |- CharacterNetworkManager (Model)
         |- Packages
         |- src
            |- init (Client Script)
            |- Module (ModuleScript)
            |- Remotes (Folder)
            |- Character (Model)
```

```jsonc
// default.project.json
{
  "name": "Game",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "$path": "src"
    }
  }
}

// CharacterNetworkManager/default.project.json
{
  "name": "CharacterNetworkManager",
  "tree": {
    "$className": "Folder",
    "src": {
      "$path": "src"
    },
    "Packages": {
      "$path": "Packages"
    }
  }
}
```

이 때 내부의 default.project.json 이 절대 경로의 플레이스 형태의,
`tree` 내 `className` 을 `DataModel` 로 하게 되면 동기화시 정상 작동되지 않습니다.
`DataModel` 이 서로 합성 되는 게 아니라, `DataModel` 안에 `DataModel` 이 있게되기 때문입니다

### 패키지에서의 `*.project.json` 형식

패키지 프로젝트의 루트에 위치한 `default.project.json` 이나 그 외 `*.project.json` 은
주로 모델/폴더로 나타내는 형식으로 작성합니다.

예시:

```jsonc
{
  "name": "Package",
  "tree": {
    "$className": "Folder",
    "src": {
      "$path": "src"
    },
    "roblox_packages": {
      "$path": "roblox_packages"
    }
  }
}
```

pesde 를 사용하는 경우 패키지 설치시,
`roblox_sync_config_generator` 가 `default.project.json` 을 자동 생성 및 덮어씌우지만,
그럼에도 루트에서 정의해주면 좋습니다.

### 플레이스에서의 `*.project.json` 형식

플레이스 프로젝트의 루트에 위치한 `default.project.json` 이나 그 외 `*.project.json` 은
주로 데이터모델로 나타내는 형식으로 작성합니다.

예시:

```jsonc
{
  "name": "Game",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "Game": {
        "$path": "src/Game"
      },
      "GameModules": {
        "$path": "src/GameModules"
      },
    },
    "ServerScriptService": {
      "Server": {
        "$path": "src/Server"
      },
    },
  },
  "emitLegacyScripts": false,
}
```

## 빌드 플레이스의 위치

빌드된 플레이스 파일은 소스 폴더가 아닌 프로젝트 루트의 `build.rbxl` 를 두는 것을 권장합니다.

```sh
src/
default.project.json
build.rbxl
```

모노레포의 경우에는 각 구성 요소 자신만의 플레이스이면 `build.rbxl` 를 둡니다.

```sh
src/
default.project.json
build.rbxl

tests/
test.project.json
test.rbxl

playground/
  project/
    src/
    default.project.json
    build.rbxl
```

## `project.json` 설정

### "emitLegacyScripts": false 를 무조건 넣어주세요

`"emitLegacyScripts": false` 를 넣어야 `LegacyScript` 가 아닌 `RunContext` 기반의 `Script` 로 설치됩니다.

## 스타일

### 상대주소 사용

언제나 `*.project.json` 의 경로는 자신이 있는 위치를 기준으로 상대경로로 잡아,
폴더를 매핑해야합니다.

```sh
roblox_packages/
src/
playground/
  project/
    src/
    default.project.json
```

```jsonc
{
  "name": "LayeredValueManual",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "src": {
        "$path": "../../src"
      },
      "roblox_packages": {
        "$path": "../../roblox_packages"
      },
      "Test": {
        "$path": "src" // ./src 와 같음
      }
    },
  },
  "emitLegacyScripts": false
}
```
