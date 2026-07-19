---
name: localization
description: StoryBakery의 게임, 플러그인, 에디터, UI 현지화를 설계, 작성, 수정, 리뷰할 때 사용합니다. 번역 키, 매개변수와 문장 구성, CSV LocalizationTable, 로케일, Roblox 번역 작업을 포함합니다.
---

# Localization

작업 대상과 소스 언어를 먼저 확인하고 관련 reference를 읽습니다.
문서 사이트의 Markdown 번역이 아니라 제품 내 콘텐츠 번역에 적용하며, 키와 원문을 변경할 때 기존 번역 및 호출부에 미치는 영향도 확인합니다.

## References

- `references/index.md`: StoryBakery 현지화 가이드의 범위와 Markdown 문서 번역과의 구분을 확인할 때
- `references/content.md`: 번역 문자열의 매개변수, 지정자, 문장 연결 방식을 작성하거나 검토할 때
- `references/key.md`: 목적과 계층을 드러내는 번역 키의 이름, 깊이, 케이싱, 맥락 분리를 결정할 때
- `references/localization-table.md`: CSV LocalizationTable의 구조, 필드 순서, `LocaleId`, 파일 이름을 작성하거나 변경할 때
- `references/roblox.md`: Roblox 프로젝트의 소스 언어, Translator 사용, 스크립트 출력, Context 필드 규칙을 다룰 때
