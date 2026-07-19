---
title: Luau 패키지 테스트하기
---

이 문서는 luau-package 를 만들 때의 테스트 작성법에 대해 다룹니다.

## 권장 구조

기본 구조는 다음과 같습니다.

```sh
Package/
  .github/
    workflows/
      ci.yml
  src/
    init.luau
    Submodule.luau
  tests/
    TestUtil.luau
    Submodule.spec.luau
  pesde.toml
```

생략 및 수정 가능합니다.

## 유닛 테스트

### 테스트 패키지

Lute 의 기본 테스트 러너와 `@std/test` 는 사용하지 않습니다, 대신 `StoryBakery/sitest` 를 사용합니다.

커뮤니티에서 자주 쓰이지만 `TestEZ` 나 `JestRoblox` 는 사용하지 않습니다,
오래되었으며 Lute 환경에서 바로 실행하기 어렵기 때문입니다.

### tests 폴더

`tests` 는 패키지의 spec 이나 테스트 코드를 모아둡니다.
유닛 테스트나 스펙 검사에 쓰이는 코드들을 사용합니다.

#### `.spec.luau` 또는 `.test.luau` 접미사가 붙여진 스크립트가 실행됩니다

Lute 는 `tests` 폴더에서 `.spec.luau` 또는 `.test.luau` 접미사가 붙은 테스트 파일을 발견해 실행합니다.

그 외의 접미사가 붙인 스크립트들은 실행되지 않으며 따로 실행되어야합니다.
