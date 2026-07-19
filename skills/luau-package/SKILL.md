---
name: luau-package
description: StoryBakery의 Luau 패키지를 생성, 구성, 배포하거나 의존성을 추가·업데이트하고 pesde manifest, workspace, target, build_files를 다룰 때 사용합니다.
---

# Luau Package

패키지의 실행 환경, 배포 대상, 워크스페이스 여부를 먼저 확인하고 관련 reference를 읽습니다.
Luau 코드에는 `luau` 스킬을 함께 적용하고, Roblox 패키지에는 `roblox`와 `rojo` 스킬의 관련 규칙도 적용합니다.
`*_packages/`와 lockfile은 직접 편집하지 않으며, 경로나 도구 실행 위치를 특정 운영체제에 맞춰 하드코딩하지 않습니다.

## References

- `references/index.md`: Luau 패키지 구조, pesde 선택, `build_files`, workspace와 설치 결과물의 편집 제한을 다룰 때
- `references/pesde.md`: pesde manifest나 의존성을 추가, 제거, 업데이트, 설치할 때
