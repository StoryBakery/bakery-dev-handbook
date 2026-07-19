---
title: 스크립트
---

## RunContext

`LocalScript` 와 `Script` 를 폴더로 구분하기보다, `Script` 의 **RunContext** 속성을 활용하여
동일한 기능 폴더 안에서 관리하는 것을 권장합니다.

Rojo 사용 시 `default.project.json` 의 `"emitLegacyScripts": false` 를 하면
레거시 스크립트에서 `RunContext` 로 사용 변환 됩니다.

## `.luau` `.server.luau`, `.client.luau`, `.plugin.luau` 를 접미사로 사용합니다

`.luau` 는 로블록스에선 모듈 스크립트로 변환되기에 가장 일반적인 형태입니다.

- `.server.luau`: 서버 스크립트
- `.client.luau`: 클라이언트 스크립트
- `.plugin.luau`: 플러그인 스크립트

구 스크립트는 극도로 쓰이지 않게됐지만:

- `.legacy.luau`: 기존 조상의 위치에 따라 작동 여부가 결정되는 레거시 스크립트
- `.local.luau`: 기존 조상의 위치에 따라 작동 여부가 결정되는 로컬 스크립트
