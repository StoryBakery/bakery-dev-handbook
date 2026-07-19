---
title: Luau 패키지 만들기
---

Luau 패키지를 어떻게 다루는지에 대한 문서입니다.
기본적으로 Luau 패키지는 pesde 를 사용해서 만듭니다.

## 왜 pesde를 사용하나요?

pesde 는 Wally 보다 더 확장성 높은 패키지 매니저입니다.
로블록스의 패키지 매니저들은 대부분 pesde 를 사용하기에, pesde 를 맞춥니다

### pesde 로 Wally 의존성을 사용할 수 있습니다

Wally 는 과거 로블록스 패키지의 기본 매니저였습니다, 그러나 최근엔 유지보수가 잘 되지 않아
사용할 메리트가 줄어듦과 동시에 pesde 가 사실상 기본 매니저가 되었습니다.
그러나 여전히 Wally 에만 호스팅하는 패키지들이 존재합니다.

대표적인 예시가 evaera 님의 [promise](https://github.com/evaera/roblox-lua-promise) 패키지 입니다.

패키지를 만들 때 Wally 에 올리지 않고, 기본으로 쓰지않는 것일 뿐.
필요한 패키지에 pesde 가 아니라 Wally 에만 호스팅하고 있다면 Wally 주소로 패키지 의존성을 설정합니다.

```toml
[wally_indices]
default = "https://github.com/UpliftGames/wally-index"

[dependencies]
foo = { wally = "scope/package", version = "^1.0.0" }
```

## *.project.json 은 어떻게 하나요?

패키지 작성자의 `default.project.json`을 배포 계약으로 취급하지만
pesde Roblox 패키지는 소비자가 동기화 도구를 선택할 수 있도록 `build_files`를 사용한다.
프로젝트 파일은 로컬 개발 또는 앱 수준 Rojo 동기화용으로 유지할 수 있지만, 문서와 프로젝트 의도가 명확하지 않다면 배포 패키지 내용에 포함하지 않는다.

## 워크스페이스 패키지를 만들기

워크스페이스 패키지를 만들면, 서로 비슷한 주제를 다루지만 설치는 따로 나뉘게 되어야하는 패키지들을
한 레포에서 관리하면서, 개발시 서로 의존성도 즉시 설치돼 로컬에서 테스트하기 좋습니다.

```sh
pkgs/
  PackageA/
    luau_packages
    src
    pesde.toml
  PackageB/
    luau_packages
    src
    pesde.toml
.config.luau
pesde.toml
```

Lute 로 실행하는 일반 Luau 패키지는 pesde 의 `luau` target 을 사용하고, 설치된 의존성 폴더도
`luau_packages` 로 둡니다.

절대적인 규칙은 아니지만 워크스페이스 내 멤버 패키지들은 `pkgs` 란 폴더 내에 둡니다.

또한 루트의 `pesde.toml` 에선 `workspace_members` 를 glob 패턴으로 정의해주어야합니다.

```toml
workspace_members = ["pkgs/*"]
```

## packages 폴더 내부에 있는 파일들은 직접 수정하지 않습니다

`*_packages/` 내부에 있는 파일들이나 `pesde.lock`은 직접 편집하지 않습니다.
