---
id: vide-story-modules
sidebar_label: Story Modules
---

# Story Modules

이 문서는 Vide 기반 스토리(Story) 모듈 작성 규칙을 설명합니다. 스토리는 UI 컴포넌트의 샌드박스 렌더링과 상태 조작(Controls)을 돕는 개발 도구이며, UILabs(`@Packages/ui-labs`) 유틸리티를 사용해 일관된 방식으로 작성합니다. 코딩 스타일은 [formatting-style](../../scripting/formatting-style.md), require 규칙은 [require-style](../../scripting/require-style.md), Vide 호출 규칙은 [vide-kit](./vide-kit.md)을 그대로 따릅니다.


## 기본 구조

- 스토리는 하나의 테이블(혹은 UILabs 팩토리 반환값)로 표현합니다.
- 반드시 `vide` 키를 제공해야 하며, 스토리 함수는 한 번 호출되어 결과를 렌더합니다.
- 스토리 함수는 안정적 스코프에서 호출되며 언마운트 시 파기됩니다. `Vide.effect`/`Vide.cleanup` 으로 정리 로직을 넣을 수 있습니다.

```lua
local vide = require("@vide")
local create = vide.create

return {
    vide = vide,
    story = function(props)
        -- props.target: 대상 프레임 (필요 시 사용)
        -- props.controls: UILabs 가 만든 Vide.Source 컨트롤 집합
        return create "Frame" {
            Size = UDim2.fromOffset(200, 100),
            Visible = props.controls.Visible,
        }
    end,
}
```

또는 `props.target` 를 사용해 Parent 를 직접 지정하고 `nil` 을 반환할 수 있습니다.


## Controls 사용

- Controls 정의는 일반 테이블로 기술하며, UILabs 가 동일 키의 `Vide.Source` 를 생성해 `props.controls` 로 제공합니다.

```lua
local vide = require("@vide")
local create = vide.create

local controls = {
    Visible = true,
}

return {
    vide = vide,
    controls = controls,
    story = function(props)
        return create "Frame" {
            Size = UDim2.fromOffset(200, 100),
            Visible = props.controls.Visible, -- Vide.Source<boolean>
        }
    end,
}
```


## UILabs Story Creator 사용

UILabs 유틸리티의 `CreateVideStory` 를 사용하면 동일한 규칙을 더 간결하게 적용할 수 있습니다. 패키지 경로는 `.luaurc` 의 alias 에 맞춰 `@Packages/ui-labs` 를 사용합니다.

```lua
local vide = require("@vide")
local UILabs = require("@Packages/ui-labs")

local create = vide.create

-- Controls 정의
local controls = {
    Visible = true,
}

-- 스토리 정의: CreateVideStory(info, storyFn)
return UILabs.CreateVideStory({
    vide = vide,
    controls = controls,
}, function(props)
    return create "Frame" {
        Size = UDim2.fromOffset(200, 100),
        Visible = props.controls.Visible,
    }
end)
```

컴포넌트를 조합 렌더링할 때는 [Vide 호출 스타일](./vide.md#엘리먼트-생성-규칙)의 규칙을 지켜야 합니다. 컴포넌트 함수/변수를 클래스 자리에 전달할 경우 괄호 호출을 사용합니다.

```lua
local App = require("@videKit/Components/App")

-- 클래스가 변수(함수)인 경우: 괄호 호출
return UILabs.CreateVideStory({ vide = vide }, function()
    return create(App)({})
end)
```


## 정리(Cleanup)

스토리 함수는 안정적 스코프에서 실행되므로 언마운트를 감지해 정리할 수 있습니다.

```lua
local vide = require("@vide")

return UILabs.CreateVideStory({ vide = vide }, function()
    vide.cleanup(function()
        print("Story is getting unmounted")
    end)

    -- ...
    return nil
end)
```


## 파일 배치와 네이밍

- 컴포넌트 폴더 내 `*.story.luau` 파일로 배치합니다. 예: `Components/Button/Button.story.luau`.
- Require 순서와 별칭, 빈 줄 규칙은 [require-style](../../scripting/require-style.md)을 따릅니다.
- Vide 호출, 테이블 리터럴/괄호 생략 규칙은 [vide](../vide.md) 또는 [formatting-style](../../scripting/formatting-style.md)을 따릅니다.
