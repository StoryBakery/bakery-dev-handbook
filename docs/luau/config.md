---
title: Luau 설정
---

Luau 관련 프로젝트 설정 파일은 `.config.luau` 를 사용합니다.
`.luaurc` 는 대체로 피합니다. (미리 설정되어있다면 바꾸진 않습니다.)

## 배치 위치

단일 Luau 프로젝트는 프로젝트 루트에 `.config.luau` 를 둡니다.

워크스페이스에서는 워크스페이스 루트와 각 멤버 패키지 루트에 `.config.luau` 를 필요하다면 둘 수 있습니다.
루트 설정은 워크스페이스 공통 설정을, 멤버 패키지 설정은 해당 패키지의 Luau 설정을 담당합니다.

## 기본 형태

```luau
return {
    luau = {
        languagemode = "strict",
    },
}
```
