---
title: Rojo syncback
---

Rojo `syncback`은 저장된 Roblox place 또는 model 파일의 변경 내용을 기존 Rojo 프로젝트 파일 구조로 다시 써 줍니다.
즉, `syncback`은 일반적인 동기화 방향의 반대 작업입니다.

`rojo syncback`은 Rojo `7.7.0-rc.1` 계열에서 도입되었습니다.

## syncback이란?

`rojo syncback`은 Roblox 파일 안의 변경 내용을 Rojo가 이해하는 파일/폴더 구조로 변환합니다.
개발자가 Roblox Studio에서 모델, UI, 값 객체, 폴더, LocalizationTable, 기타 Instance를 편집한 뒤 그 변경 내용을 디스크의
Rojo 프로젝트에 반영하고 싶을 때 유용합니다.

`syncback`은 모든 기존 게임을 자동으로 완벽히 Rojo 프로젝트로 마이그레이션하는 도구가 아닙니다.
프로젝트 파일이 어떤 Roblox 트리를 syncback 대상으로 삼을지, 그리고 각 Instance를 어디에 써야 할지를 결정합니다

## 핵심 개념

syncback은 두 개의 트리를 비교합니다.

첫 번째는 **기존 트리**입니다.
현재 파일 시스템에서 로드한 Rojo 프로젝트입니다.

두 번째는 **새 트리**입니다.
`--input`으로 전달한 Roblox 파일에서 읽은 트리입니다.

프로젝트 파일은 Rojo가 어떤 부분을 고려할 수 있는지 결정합니다.
Instance는 프로젝트 파일에 명시된 노드이거나 그 노드의 하위 항목일 때만 되가져올 수 있습니다.
예를 들어 프로젝트 파일에 `Workspace`가 포함되어 있으면 syncback은 `Workspace` 하위 항목을 처리할 수 있습니다.
프로젝트 파일에 `Workspace`가 없다면 Studio에서 `Workspace`에 만든 변경은 syncback 범위 밖입니다.

출력 경로는 가장 가까운 `$path` 프로젝트 노드, 기존 미들웨어 메타데이터, 또는 Rojo의 기본 직렬화 규칙에 따라 결정됩니다.
실무적으로는 프로젝트 트리가 "어떤 Instance를 어디에 쓸지 정하는 라우팅 테이블" 역할을 합니다.

## 제한사항

### syncback은 저장된 Roblox 파일이 필요합니다

라이브 Studio 세션에서 직접 가져오지는 않습니다.
그러므로 작업 시 각자의 로컬 플레이스 혹은 모델을 가져야하며, 로블록스 스튜디오에서 작업한 뒤
`Ctrl + S` 로 로컬 파일에 저장 후, `rojo syncback` 을 실행해야합니다.

### 중복 형제 이름 불가

로블록스 스튜디오에서는 동일한 이름의 인스턴스가 형제로 있어도 되지만
파일 시스템에 항상 직렬화할 수는 없습니다. 대소문자만 다른 이름도 대소문자 구분이 없는 파일 시스템에서는 충돌할 수 있습니다.

```sh
# 허용
Workspace
|- Part1
|- Part2

# 거부
Workspace
|- Part
|- Part

# 가장 좋은 접근법
Workspace
|- ModelA
|  |- Part1
|  |- Part2
|- ModelB
```

그러므로 `Explorer > Increment names for new instance` 를 항상 활성화합니다.
혹은 서로 다른 이름의 폴더로 자주 묶어둡니다.

### `.rbxm`, `.rbxmx` 모델 입력은 최상위 Instance가 하나여야 합니다

rbxm 파일과 rbxmx 파일은 여러 인스턴스를 가질 수 있으나, Rojo 프로젝트에서는 아직

### 참조 대상이 syncback 범위 밖이면 참조 속성이 사라지거나 nil이 될 수 있습니다

## 문제 해결

`Could not detect what kind of file was inputted`

입력 파일 확장자가 `.rbxl`, `.rbxlx`, `.rbxm`, `.rbxmx` 중 하나가 아닙니다.

`Rojo does not currently support models with more than one Instance at the Root`

모델 입력의 최상위 Instance가 여러 개입니다. 최상위 Instance가 하나인 모델로 다시 내보내거나 place 파일을 사용해야 합니다.

**중복 자식 이름 오류**

두 형제 Instance가 같은 파일 시스템 이름으로 매핑되는 상황입니다.
Studio에서 이름을 바꾸거나 프로젝트 구조를 조정합니다.
대소문자만 다른 이름도 충돌할 수 있습니다.

**예상 밖의 삭제**

`--dry-run --list`로 실행하고 `Removing` 경로를 확인합니다.
`ignorePaths` 또는 `ignoreTrees`로 보호합니다.
입력 Roblox 파일에 기존 Instance가 실제로 포함되어 있는지도 확인해야 합니다.

**예상 밖의 카메라 출력**

카메라가 프로젝트 데이터가 아니라면 `syncCurrentCamera`를 `false`로 설정하거나 입력 파일에서 카메라를 제거합니다.

**예상 밖의 속성 변경**

노이즈가 많은 특정 속성은 `ignoreProperties`로 제외합니다.
non-scriptable 속성이 불필요한 diff를 만들면 `syncUnscriptable: false`를 고려합니다.

**`PrimaryPart` 또는 `ObjectValue.Value` 누락**

참조 대상이 syncback 범위 안에 있고 무시 규칙으로 제외되지 않았는지 확인합니다.
참조 메타데이터를 의도적으로 버리는 상황이 아니라면 `ignoreReferents`는 `false`로 둡니다.
