---
name: document
description: StoryBakery의 Markdown 문서를 작성, 수정, 리뷰하거나 문서 구조, 헤딩, 목록, 코드 블록, 링크, 자산, 한국어 표현, 아키텍처, CLI 및 TOML 레퍼런스 규칙을 적용할 때 사용합니다.
---

# Document

관련 reference를 먼저 읽고 문서는 작고 정확하며 현재 상태와 일치하도록 유지합니다.
예시의 경로와 명령은 특정 운영체제에 종속시키지 않으며, 운영체제별 차이가 문서의 주제일 때만 명시적으로 구분합니다.

## References

### Core

- `references/index.md`: StoryBakery 문서의 기본 철학과 전체 작성 방향을 확인할 때
- `references/heading.md`: 헤딩 계층, ATX 스타일, 제목의 고유성과 간격을 다룰 때
- `references/list.md`: 불릿·번호 목록, 테이블, 파일이나 객체 트리를 작성할 때
- `references/code.md`: 펜스 코드 블록, 줄바꿈 이스케이프, 목록 안의 코드를 작성할 때
- `references/link.md`: 경로 표기, 외부·내부 링크, 링크 제목, 참조 링크를 작성할 때
- `references/asset.md`: 이미지·비디오의 상대 경로, 대체 텍스트, Markdown 또는 HTML 표기를 다룰 때
- `references/naming.md`: 문서의 이미지, 비디오, 다운로드 자산 파일명을 정하거나 교체할 때

### Architecture

- `references/architecture/index.md`: 프로젝트 초기 설계 문서와 `architectures` 폴더를 작성할 때
- `references/architecture/luau.md`: Luau 모듈, 생성자, 속성, 메서드, 함수와 타입의 설계 문서를 작성할 때

### Language and references

- `references/localization/korean.md`: 한국어 문서에서 의미나 발음이 모호한 용어와 영문 병기 여부를 판단할 때
- `references/reference/cli.md`: CLI 레퍼런스의 섹션, 문법, 옵션, 환경 변수, 예시, 출력 계약을 작성할 때
- `references/reference/manifest/toml.md`: TOML manifest의 섹션과 키-값을 문서화할 때
