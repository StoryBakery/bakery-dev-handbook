# Bakery Dev Handbook

스토리 베이커리 개발자 가이드입니다.

다양한 분야의 공통 개발 가이드를 다루고 있음으로, 필요한 내용을 찾아보세요.

## 에이전트 스킬

Bakery Dev Handbook 은 사람이 읽는 규칙 뿐만이 아니라, 에이전트가 읽는 규칙까지 포함합니다.

`skills` 폴더는 docs 에서 같은 이름의 폴더를 `references` 로 받고, 스킬로 설치할 수 있게 둔 폴더들이 있습니다.

> [!WARNING]
> 공식 [agent-skills](https://github.com/StoryBakery/agent-skills) 레포지토리와 다르게 이 레포지토리의 스킬들과 문서는 굉장히 실험적으로 운영되며, 자주 변경됩니다.
> 보다 편한 개발을 위해 한국어로 작성되었으며,
> 안정적인 스킬을 사용하고 싶거나, 관습을 알고 알고싶다면 영어로 작성된 agent-skills 레포지토리를 참고해주세요.

### 스킬 설치

스킬을 설치하는 방법은 다양합니다.

가장 쉬운 방법은 AI 에이전트에게,

```txt
`$skill-installer https://github.com/StoryBakery/bakery-dev-handbook/skills/README.md 에 따라 [skill] 을 설치해줘`
```

란 프롬프트를 전송하는 식으로 설치할 수 있습니다.
AI 는 그만큼 유동적이고 똑똑하니까요.

StoryBakery 의 레포들을 작업하기위해서라면 `storybakery-project` 로 설치하는 것을 추천합니다.
StoryBakery 의 작업방식에 맞춰진 스킬과 함께 기본 템플릿을 제공합니다.

혹은 레포지토리를 로컬 컴퓨터에 설치 후 다음 커맨드를 실행해서 설치할 수 있습니다.

```sh
lute run scripts/install-skills.luau --project path/to/your-project
```
