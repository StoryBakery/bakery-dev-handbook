---
id: vide
sidebar_label: Vide Overview
---

# Vide Overview

Vide 런타임을 사용할 때의 최소 규칙을 정리합니다. 호출 규칙은 [vide-kit](./vide-kit.md)와 [formatting-style](../../scripting/formatting-style.md)의 지침을 그대로 따르며, videKit 컴포넌트에 특화된 구조는 [vide-kit](./vide-kit.md)를 참고하세요. 스토리 작성은 [vide-story-modules](./story-modules.md)를 참조합니다.


## 불러오기와 별칭

```lua
local vide = require("@vide")
local create = vide.create
local source = vide.source
local effect = vide.effect
local action = vide.action
local cleanup = vide.cleanup
```

- 외부 패키지 alias, require 순서는 [require-style](../../scripting/require-style.md)를 따릅니다.


## 엘리먼트 생성 규칙

- 클래스가 문자열 리터럴이고 props 가 테이블 리터럴이면 괄호를 생략합니다.

```lua
-- 선호
return create "Frame" {
    Size = UDim2.fromScale(1, 1),
}
```

- 클래스나 props 가 변수/표현식이면 괄호 호출을 사용합니다.

```lua
local klass = props.ComponentClass
local nextProps = getNextProps()
return create(klass)(nextProps)
```


## Children 구성: 숫자 인덱스 사용

- Vide 엘리먼트의 자식은 숫자 키(배열 인덱스)로 전달합니다. 속성(Property)은 문자열 키에 둡니다.
- `table.insert(props, child)` 또는 `props[#props + 1] = child` 를 사용해 자식을 추가합니다.

```lua
local props = {
    Size = UDim2.fromScale(1, 1),
}

table.insert(props, create "UIListLayout" {
    FillDirection = Enum.FillDirection.Horizontal,
})

table.insert(props, create "TextLabel" {
    Text = "Hello",
})

return create "Frame" (props)
```

- 레이아웃/패딩 같은 구조적 자식은 별도의 배열을 만든 뒤 props 와 병합해 관리할 수 있습니다. videKit에서는 `internalChildren` 패턴을 사용합니다. 병합 시에는 프로젝트 공용 유틸([TableUtil.merge])을 우선 재사용합니다.


## 상태: vide.source

- `source(initial)` 는 읽기/쓰기 가능한 상태를 생성합니다.
  - 읽기: `local v = state()`
  - 쓰기: `state(newValue)`

```lua
local hovered = source(false)

local buttonProps = {
    BackgroundTransparency = if hovered() then 0.2 else 0,
}
```


## 효과와 정리: vide.effect, vide.cleanup

- 부수효과는 `effect(function() ... end)`에서 처리합니다. 연결(Connections), Tween, 타이머 등은 반드시 정리합니다.
- 정리는 두 가지 방식 중 하나를 사용합니다.
  1) effect 반환 함수로 정리
  2) 안정적 스코프에서 `cleanup` 등록

```lua
local value = source(0)

effect(function()
    local conn = RunService.RenderStepped:Connect(function()
        value(value() + 1)
    end)

    return function()
        conn:Disconnect()
    end
end)

-- 안정적 스코프(예: 스토리 함수)라면
cleanup(function()
    print("unmounted")
end)
```

- 메모리 누수 방지 원칙
  - Effect 내부에서 생성한 리소스(이벤트 연결, Tween, Task)는 반환 함수에서 해제합니다.
  - 컴포넌트 외부로 Instance/연결 핸들을 보관하지 않습니다. 필요 시 `Maid`를 활용하거나 effect 정리 함수를 사용합니다.


## 반환 규칙

- 컴포넌트/스토리는 가장 메인이 되는 루트 인스턴스를 반환합니다.
  - 컴포넌트: `return create "Frame" (frameProps)` 또는 videKit 래퍼 호출 반환
  - 스토리: 대상 프레임의 children 으로 적용될 인스턴스를 반환하거나, `props.target`에 직접 Parent 지정 후 `nil` 반환


## 추가 참고

- 컴포넌트 설계 원칙(상속/조합): [vide-component-design](./component-design.md)
- 문서 주석 규칙: [vide-component-documentation](./component-documentation.md)
- videKit 작성 규칙: [vide-kit](../scripting/vide-kit.md)
- 스토리 모듈: [vide-story-modules](./story-modules.md)

# 속성

## 반응형 속성

### Implicit-Effects
vide 에서 속성을 함수로 주면 반응형으로 처리합니다. 예:

```lua
return create "TextLabel" {
    Text = sourceText, -- sourceText 가 vide.source 라면 값이 바뀔 때마다 Text 속성이 갱신됩니다.
    BackgroundColor3 = function()
        if isActive() then
            return Color3.new(0, 1, 0)
        else
            return Color3.new(1, 0, 0)
        end
    end,
}
```

속성 자체를 nil 로 정의하면, vide 는 해당 속성을 기본 속성으로 설정하지만
이 때 함수인데 nil 을 반환하면 vide 는 해당 속성을 기본 속성을 두는 것이 아닌, nil 로 정의하려고 하기에,
오류가 발생할 수 있습니다.

```lua
-- Bad:
return TextLabel {
    BackgroundColor3 = function()
        if isActive() then
            return Color3.new(0, 1, 0)
        else
            return nil -- 오류 발생!
        end
    end,
}

-- Good:
return TextLabel {
    BackgroundColor3 = function()
        if isActive() then
            return Color3.new(0, 1, 0)
        else
            -- 함수로 설정한다면 어떻게든 임의의 기본값을 설정해야합니다
            return Color3.new(1, 1, 1)
            
            -- 또는 컨텍스트를 사용해서 지정할 수 있습니다
            -- return theme().Background
        end
    end,
}
```
