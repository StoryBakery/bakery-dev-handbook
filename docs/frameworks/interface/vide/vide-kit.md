---
id: vide-kit
sidebar_label: Vide Kit
---

# Vide Kit

videKit 컴포넌트는 `vide` 기반 UI 레이어를 일관된 패턴으로 구성하기 위해 제공됩니다.  
여기서는 새 컴포넌트를 작성할 때 유지해야 하는 기본 구조, 문서 주석, 상태 관리 규칙을 설명합니다.  
기존 코드와 동일한 흐름을 따라야 하며, 아래 항목을 지키지 않으면 Moonwave 문서화나 런타임 동작이 깨질 수 있습니다.

설계 단계의 선택 기준(상속 vs 조합)은 [vide-component-design](./component-design.md)을 참고하십시오.

## 공통 구조

- 모듈 최상단에는 `--[=[ @class … ]=]` 형태의 문서 주석을 두고, `@tag vide` 를 반드시 선언합니다.  
  예시:
  ```lua
  --[=[
      @class Button
      @tag vide
      버튼 인터랙션을 처리하는 vide 컴포넌트입니다.
  ]=]
  ```


- Context, 다른 컴포넌트, 유틸리티는 블록을 나눠 require 하고, [require-style](../../scripting/require-style.md) 의 순서를 따릅니다.

## Props 정의

- 모든 컴포넌트는 `export type ComponentProps = { … } & BaseProps` 형태로 외부에 프로퍼티 타입을 노출합니다.
- 상위 컴포넌트의 Props 를 확장할 경우 `Frame.FrameProps` 와 같이 명시적으로 병합합니다.
- 외부에서 전달받아야 하는 이벤트(`OnClick`, `OnEnter` 등)는 콜백 시그니처를 정확히 기록합니다.
- 내부에서만 사용하는 필드는 컴포넌트 본문에서 `frameProps.SomeField = nil` 로 제거해 실제 인스턴스로 전달되지 않도록 합니다.

## 파일 및 배포 주의사항

- 새로운 컴포넌트를 추가하면 `Components/init.luau` 내에 require · export type 을 반드시 등록합니다.
- Storybook 용 `.story.luau` 파일을 추가할 경우, 컴포넌트 폴더 내부에서 `Button.story.luau` 처럼 별도 파일로 둡니다.
- Moonwave 문서화가 정상적으로 작동하려면 모든 videKit 모듈에 문서 주석과 `@tag vide` 가 포함되어 있어야 합니다.
- 변경 후에는 `lune run CheckSyntax` 와 `lune run BuildDocs` 를 순서대로 실행해 문법·문서 검사를 통과해야 합니다.
