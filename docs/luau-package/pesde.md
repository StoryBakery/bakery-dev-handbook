---
title: 패키지 매니저 pesde
---

깃허브 링크: <https://github.com/pesde-pkg/pesde>

## 기본 자세

pesde는 런타임별 타깃을 지원하는 Luau 패키지 매니저로 사용합니다.

`pesde.toml`이 이미 있으면 `pesde init`을 실행하기 전에 먼저 내용을 확인합니다.
`pesde.toml`은 `pesde add`, `pesde remove`, 또는 신중한 매니페스트 편집으로 바꾸고,
이후 `pesde install`을 실행합니다.

## 자주 쓰는 작업 흐름

### 의존성 추가 또는 업데이트

가능하면 CLI를 사용합니다

```bash
pesde add scope/package
pesde add --dev scope/tool
pesde add --peer scope/package
pesde add wally#scope/package
pesde add gh#owner/repo#rev
pesde add workspace:scope/package
pesde install
```
