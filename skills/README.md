# Bakery Skills

이 폴더는 에이전트가 사용할 수 있는 스킬 원본을 모아둡니다.

Bakery Dev Handbook 은 사람이 읽는 문서와 에이전트가 따르는 절차를 함께 관리합니다.
사람용 설명과 상세 레퍼런스는 `docs/` 에 두고, 에이전트가 스킬로 발견해야 하는 진입점은 `skills/` 에 둡니다.

## 구조

스킬은 다음 구조를 기준으로 둡니다.

```txt
skills/
  <name>/
    SKILL.md
    references/
```

- `SKILL.md`: 스킬의 진입점입니다. 트리거용 `name`, `description` 과 핵심 절차만 둡니다.
- `references/`: 스킬이 필요할 때 읽는 상세 문서입니다. `storybakery-project` 는 스킬 설치 시 `docs/` 에 있는 같은 이름의 폴더를 이 위치로 복제하고 병합합니다.

개별 스킬 폴더 안에는 별도 `README.md` 를 두지 않습니다.
스킬 사용 설명은 `SKILL.md` 에, 사람이 읽는 긴 설명은 `docs/` 에 둡니다.

## 문서와 스킬의 관계

`docs/` 는 사람이 읽는 원본 문서입니다.
`skills/` 는 에이전트가 읽는 스킬 패키지입니다.

같은 내용을 두 번 길게 쓰지 않습니다.
`SKILL.md` 는 필요한 문서를 언제 읽어야 하는지만 안내하고, 세부 내용은 `references/` 또는 `docs/` 로 분리합니다.

예를 들어 Rojo 스킬은 다음처럼 둡니다.

```sh
docs/
  rojo/
    index.md
    project-json.md
    file.md
    syncback/
      index.md
      reference.md

skills/
  rojo/
    SKILL.md
    references/
      # storybakery-project 로 설치 시 docs/rojo 의 파일들이 이 위치로 복제되고 병합됩니다.
      syncback/
        agent-rule.md
```

```sh
# 최종 설치시
rojo/
  SKILL.md
  references/
    index.md
    project-json.md
    file.md
    syncback/
      agent-rule.md
      index.md
      reference.md
```

## 작성 규칙

- 스킬 폴더 이름은 소문자, 숫자, 하이픈을 사용합니다.
- `SKILL.md` frontmatter 에는 `name` 과 `description` 만 둡니다.
- `description` 에는 언제 이 스킬을 써야 하는지 구체적으로 적습니다.
- 본문은 짧게 유지하고, 상세한 지식은 reference 문서로 분리합니다.

reference 문서는 일반적으로 `## References` 아래에 불릿 목록으로 나열합니다.
문서가 여러 영역으로 나뉘는 경우 `###` 헤딩으로 분류할 수 있습니다.

```md
## References

### Project

- `references/project-json.md`: `*.project.json` 구조나 Rojo 매핑을 다룰 때 읽습니다.
- `references/file.md`: `.rbxm` 또는 `.rbxl` 파일의 배치를 판단할 때 읽습니다.

### Syncback

- `references/syncback/reference.md`: syncback 옵션이나 제한사항을 확인할 때 읽습니다.
- `references/syncback/agent.md`: syncback을 계획하거나 실행할 때 반드시 읽고 따릅니다.
```

모든 항목은 가능한 한 다음 형식을 따릅니다.

문서 경로: 이 문서를 읽어야 하는 조건

`docs/<name>/`의 내용은 `storybakery-project` 로 설치 시 `references/`로 복제 및 머지되므로,
`SKILL.md` 에서는 항상 설치된 스킬을 기준으로 `references/...` 상대 경로를 사용합니다.

## 설치 스크립트

저장소를 체크아웃한 환경에서는 Lute로 설치 스크립트를 실행할 수 있습니다.

```sh
lute run scripts/install-skills.luau --project <project-directory>
```

혹은 원하는 프로젝트 위치로 이동한 뒤, `scripts/install-skills.luau` 의
절대 경로를 붙여넣는 방법도 있습니다.

```sh
lute run path/to/bakery-dev-handbook/scripts/install-skills.luau --project .
```

- `--project`는 지정한 프로젝트의 `.agents/skills`에 설치합니다.
- 설치 경로를 직접 지정하려면 `--dest <agent-skills-directory>`를 사용합니다.
- 스킬 이름을 생략하면 체크리스트를 표시합니다. `--project` 에서는 스킬 이름만, `--dest` 에서는 설명도 함께 표시합니다.
- 모든 스킬을 비대화식으로 설치하려면 `--all`을 사용합니다.
- 스킬 이름을 명령 뒤에 나열해 선택 과정을 생략할 수도 있습니다.
- `--list`로 설치 가능한 스킬 이름을 확인합니다..
- 이미 같은 이름의 스킬이 대상 경로에 있으면 기존 디렉터리를 유지한 채 같은 경로의 파일을 덮어써 업데이트합니다.

## 필수 컨텍스트량은 짧게 하는 것을 추구합니다

에이전트는 이미 매우 똑똑하다는 가정을 합니다.
이미 가지고 있지 않은 맥락만 추가합니다.
심화된 로블록스 개발의 경우 부족한 오픈소스 생태계와 문서로,
상세히 써줘야하는 경향이 있지만 즉 이는 사람에게도 부족한 지식이란 의미이기에, docs 에 충분히 설명하는 식으로 접근합니다.
추후 ai 발전으로 보다 학습될 가능성이 높기에,
효율적인 컨텍스트량에 보다 더 신경씁니다.

SKILL.md 는 간단한 설명용이며, 대부분의 지식은 `skills/` 가 아닌 `docs/` 에 담아두는 것을 추천합니다.
