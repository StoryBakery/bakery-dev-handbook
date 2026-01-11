---
id: vide-component-documentation
sidebar_label: Component Docs
---

# Component Docs

videKit 컴포넌트 문서는 [document-based-comment](../scripting/document-based-comment.md)에 정의된 Moonwave 주석 규칙을 기반으로 하며, UI 구조 지침은 [vide-kit](./vide-kit.md)을 반드시 함께 따라야 합니다. 이 문서는 그 가운데서도 Vide 컴포넌트의 API 문서화 흐름과 `@tag vide` 선언 방법을 구체화합니다.


## 문서화 원칙

문서화가 필요없을 정도로 한두개의 모듈에서만 쓰는 경우 문서 주석보단 블록 주석으로 설명합니다.

- 모든 컴포넌트 파일은 최상단에 `--[=[ ... ]=]` 블록으로 클래스 주석을 작성하고, `@class`, `@tag vide` 를 선언합니다.
- Props, 반환 타입, 헬퍼 훅 등 외부에 노출되는 구조체는 `@interface`, `@type`, `@function` 을 사용하며, 각 주석에는 `@within <ComponentName>`을 명시해 소속을 분명히 합니다.

- 작성한 내용이 `videKit` 구조나 UI 톤을 변경한다면 [ui-style](../ui-style.md)과 [vide-kit](./vide-kit.md)의 조건도 다시 확인합니다.

- `vide` 런타임 관련 의존성은 항상 상단에 정리합니다: `vide`(런타임), `TableUtil`, `Maid`, `DynamicTween` 등.
- `local vide = require("@vide")` 로 불러온 직후, 실제 사용할 API 만 `local create = vide.create`, `local action = vide.action`, `local source = vide.source`, `local effect = vide.effect` 처럼 지역 별칭으로 정의합니다.

## 상단 클래스 주석

클래스를 설명하는 최상단 주석에는 컴포넌트 이름과 `@tag vide` 를 명시합니다. 최상단 블록에는 `@within` 을 넣지 말고, Props/헬퍼 등 하위 주석에서 `@within <ComponentName>` 을 사용해 소속을 표기합니다. 설명은 한 문단으로 끝내고, 추가 규칙은 아래 섹션에서 다루십시오.

```lua
--[=[
    @class IconButton
    @tag vide

    아이콘과 텍스트를 함께 렌더링하는 기본 버튼 컴포넌트입니다.
]=]
```


## Props와 타입 정의

외부에서 전달받는 Props, 내부에서 반환하는 객체 타입은 모두 `@interface`나 `@type` 주석으로 문서화합니다. Props의 각 키는 `.Key Type -- 설명` 형태로 정의합니다.

```lua
--[=[
    @interface IconButtonProps
    @within IconButton

    IconButton 이 요구하는 속성입니다.

    .OnClick (() -> ())? -- 클릭 시 호출되는 콜백
    .Icon string -- 표시할 아이콘 이름
    .isDisabled boolean? -- 입력을 막을 때 true
]=]
export type IconButtonProps = Types.props<{
    OnClick: (() -> ())?,
    Icon: string,
    isDisabled: boolean?,
}> & Frame.FrameProps
```

## 예시 흐름

1. 파일 최상단에서 클래스 주석을 작성하고 `@tag vide` 를 선언합니다.
2. `export type ComponentProps` 및 필요한 타입을 `@interface`로 문서화한 뒤, Props 설명을 `.Key` 레이아웃으로 작성합니다.
3. 외부에 노출되는 정적 필드나 헬퍼 함수에는 `@prop`, `@function` 주석을 추가하여 소비자가 어떤 API를 사용할 수 있는지 명확히 합니다.
4. 모든 주석은 `document-based-comment`의 순서를 그대로 따르며, 추가 규칙이 필요할 경우 해당 문서의 어드머니션 예제를 활용합니다.

위 순서를 지키면 videKit 컴포넌트는 자동으로 Vide 태그 기반 API 문서에 반영됩니다.
