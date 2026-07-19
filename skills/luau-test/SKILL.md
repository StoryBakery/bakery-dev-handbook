---
name: luau-test
description: StoryBakery의 Luau 또는 Roblox 패키지 테스트를 설계, 작성, 수정, 실행하거나 tests, playground, *.spec.luau, *.test.luau, test.project.json 구성을 다룰 때 사용합니다.
---

# Luau Test

테스트 대상의 런타임과 자동·수동 테스트 범위를 먼저 확인하고 관련 reference를 읽습니다.
테스트 코드에는 `luau` 스킬을, 패키지와 Roblox 환경에는 각각 `luau-package`, `roblox`, `rojo` 스킬의 관련 규칙도 적용합니다.
테스트 실행 경로와 도구 탐색은 특정 운영체제나 설치 위치에 맞춰 하드코딩하지 않습니다.

## References

- `references/luau.md`: 일반 Luau 패키지의 테스트 구조, 테스트 러너, tests 폴더와 테스트 파일 접미사를 다룰 때
- `references/roblox.md`: Roblox 패키지의 test.project.json, Studio 실행 테스트, playground와 수동 테스트를 다룰 때
