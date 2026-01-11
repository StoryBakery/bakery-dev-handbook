---
sidebar_label: Require Style
---


# Require-Style

## 개요

`require` 블록은 Story-Bakery 코드 스타일의 핵심 축입니다. 외부 패키지, 공용 조상, 내부 모듈을 predictable 하게 불러와야 코드 리뷰가 쉬워지고, alias 충돌이나 잘못된 경로로 인한 런타임 오류를 예방할 수 있습니다. 이 문서는 이전 코드 스타일 가이드에서 다루던 `require` 규칙을 세분화해, 어떤 상황에서도 동일한 패턴을 유지하도록 가이드를 제공합니다.

- 모든 `require` 는 **가능한 한** 문자열 literal 과 사전에 등록된 alias 를 사용하지만, 모듈 인스턴스를 외부에서 주입받아야 하는 경우에는 해당 `ModuleScript` 참조를 그대로 `require` 할 수 있습니다.
- 블록 간 순서와 빈 줄 규칙을 고정해 diff 잡음과 merge conflict 를 줄입니다.
- Require 직후 등장하는 별칭 블록도 동일한 순서를 따릅니다.

## 작성-원칙

## 블록-우선순위

Require 문은 아래 네 가지 묶음으로 나누고, 목록 순서를 반드시 지킵니다. 묶음 내부는 같은 종류일 때만 붙여 쓰며, 묶음이 바뀌면 한 줄을 비워 가독성을 확보합니다.

1. **외부/패키지 레벨 의존성**  
   `require("@Promise")`, `require("@DynamicTween")` 처럼 `rokit`, `pesde`, `roblox_packages` 등에서 배포된 공용 패키지 alias 를 먼저 적습니다. 같은 패키지 이름이라도 경로가 다르면 사전식으로 정렬합니다.
2. **공통 조상(common ancestor)**  
   `local ItemModules = script.Parent` 또는 `local GameModules = ReplicatedStorage.GameModules` 처럼 현재 스크립트에서 여러 번 참조할 상위 노드를 정의합니다. 이후에 이 조상으로부터 상대 경로를 잡아야 하므로 외부 require 다음에 바로 둡니다.
3. **조상 내부 하위 모듈**  
   공통 조상으로부터 파생되는 서브 모듈(`local FruitDefinition = require(ItemModules.Food.Fruit)`)을 묶습니다. 디렉터리 구조를 반영해 하위 폴더명 → 모듈명 순으로 사전식 정렬합니다.
4. **동일 프로젝트의 나머지 모듈**  
   아직 분류되지 않은 내부 모듈을 묶습니다. 서비스 단위(`InventoryModules`, `UIRoot` 등)로 그룹을 나누고, 그룹 간에는 빈 줄을 한 줄만 둡니다.

> 특정 모듈 간 의존성 때문에 로드 순서를 강제해야 한다면, 필요한 범위 안에서만 정렬 규칙을 깨고 코드 주석으로 이유를 밝혀 주세요.

## 경로와-alias-규칙

- `require` 호출에는 기본적으로 문자열 literal alias 를 전달하지만, 다른 시스템에서 건네준 `ModuleScript` 인스턴스나 미리 정의된 테이블에서 꺼낸 경로 값처럼 **정적·신뢰 가능한 참조**라면 변수를 넘길 수 있습니다. 이때도 문자열을 즉석에서 이어 붙이거나, 서비스 체인을 바로 넘기는 방식은 금지입니다.
- 예: `local moduleScript: ModuleScript = params.ModuleScript` 처럼 함수 매개변수로 받은 모듈, 혹은 `local modulePath = DefinitionPathByName[name]` 처럼 상수 테이블에서 꺼낸 문자열은 그대로 `require(moduleScript)` 또는 `require(modulePath)` 로 사용 가능합니다.
- `.luaurc` 에 alias 가 정의되어 있다면 **가장 짧은 alias** 를 사용합니다. 예: `@BakeryModules/Promise` 대신 `@Promise` 가 존재한다면 `@Promise` 로 통일합니다.
- 같은 패키지 내 하위 모듈은 `require("@Package/SubModule")` 형태로 명시하고, 현재 파일 기준 상대 경로가 더 짧으면 `require("./SubModule")` 또는 `require("../Shared/SubModule")` 를 사용합니다.

### 상대-경로

#### 아래로
패키지 내부에서 아래로 이동할 때는 `@self/` alias 를 사용합니다. 
자식·손자 모듈은 `@self/SubModule`, `@self/SubFolder/Module` 처럼 작성합니다.

#### 위로
`./`, `../` 처럼 필요한 만큼 `..` 를 연결합니다. 
이렇게 하면 `script.Parent` 체인을 직접 넘기지 않고도 동일 패키지 내 경로를 고정할 수 있습니다.

부모를 require 할 때는 마지막에 슬래시 `/` 를 붙이며
`require("../")` `require(".././")` 처럼 `..` 마다 슬래시로 나눠줍니다.

형제 모듈도 마찬가지. `./Sibling`, `../Sibling2`

Roblox Instance 체인을 따라가는 `require(game.ReplicatedStorage.Modules.Module)` 패턴, 혹은 `script.Parent.Parent` 를 직접 넘기는 패턴은 금지입니다. 
항상 문자열 alias 와 조상 변수를 조합해 경로를 고정하세요.

## 정렬-규칙

- 같은 블록 안에서는 **알파벳 순**을 기본으로 하며, 폴더 경로가 있을 경우 `Folder.Module` 전체 문자열을 기준으로 비교합니다.
- 이 규칙을 깨야 할 정도로 의존 순서가 중요한 경우, 해당 묶음에서만 순서를 바꾸고 이유를 설명하는 한 줄 주석을 붙입니다. 다른 블록에는 영향을 주지 않습니다.
- Require 문 사이에 다른 코드(조건문, 함수 호출 등)를 끼워넣지 않습니다. Require 구역을 모두 끝낸 뒤에 상수, 변수, 함수 선언을 시작합니다.

## 외부-라이브러리-별칭-블록

Require 블록이 끝나면 바로 이어서 별칭 블록을 작성합니다. 목적은 외부 패키지에서 자주 쓰는 객체를 짧게 호출하기 위함이며, 아래 규칙을 따릅니다.

1. Require 에서 등장한 모듈 순서를 그대로 따릅니다.
2. 같은 모듈에서 꺼낸 별칭끼리는 빈 줄 없이 배치하고, 모듈이 바뀔 때만 한 줄을 비웁니다.
3. 클래스를 반환하는 객체나 컴포넌트는 PascalCase 별칭을 먼저 두고, 그다음 함수나 팩토리(lowerCamelCase)를 배치합니다.
4. 별칭 블록에서는 새로운 계산을 하지 않습니다. 단순히 프로퍼티를 분해해 로컬 변수로 저장하는 용도로만 사용합니다.

## 작성-절차

1. 필요한 모든 모듈을 목록으로 적어 **외부 → 조상 → 내부** 순으로 분류합니다.
2. 각 묶음 안에서 문자열 경로를 사전식으로 정렬합니다.
3. 문자열 literal 경로인지, alias 가 가장 짧은지, 상대 경로가 맞는지 다시 확인합니다.
4. Require 블록 뒤에 즉시 별칭 블록을 작성하고, 이후 일반 지역 상수/변수를 선언합니다.
5. 새로운 모듈이 추가되면 동일한 규칙에 맞춰 위치를 결정하고, 정렬을 다시 확인합니다.
