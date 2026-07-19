---
title: Instance Property Style
---

인스턴스의 속성을 어떻게 사용할지에 대한 문서입니다.

## Content

로블록스에서는 `-Content` 속성이 추가되기 전엔 `-Id`처럼 `string` 값으로 경로로 어셋 속성을 설정했지만,
이는 대역폭의 증가, `Editable-` 오브젝트와의 호환성 문제 등 여러 문제가 있었습니다.

그러므로 속성 사용시 무조건 `-Content` 속성을 이용합니다.

```luau
-- Bad:
imageLabel.Image = "rbxassetid://12345678"
meshPart.MeshId = "rbxassetid://87654321"

-- Good:
imageLabel.ImageContent = Content.fromAssetId(12345678)
meshPart.MeshId = Content.fromAssetId(87654321)
```

전자가 나쁜 이유는 다양합니다

- 어떤 속성은 `-Id` 와 같은 접미사를 붙여둔 이름이지만, `Image` 처럼 `-Id` 나 `-Uri` 를 붙이지 않는 속성도 많습니다.
  이를 하나하나 구분하려면 암기하는 수 밖에 없어집니다.
- 로블록스 관습상 `Id` 는 숫자, `Uri` 는 문자열로 생각합니다, 하지만 구식 관습에 따라 `-Id` 여도 문자열을 받는 경우가 많습니다.
- 어떤 부분은 `rbxassetid://{id}` 를 붙여야하고 어떤 부분은 `id` 만 주어야하는 경우가 많습니다.
- `Content` 를 사용하지 못하기에, `Editable-` 류의 데이터 객체를 사용하기 어려워집니다.

## `CFrame` 타입을 주로 사용하듯 속성도 `Vector3` 보다 `CFrame` 속성을 우선시합니다

`BasePart.CFrame` 이 아닌 `BasePart.Position`, `BasePart.Rotation`, `BasePart.Orientation` 같은 경우 `Vector3` 입니다.
`Vector3` 가 나쁘다는 것은 아니지만, 위 세 속성의 쓰기 동작은 굉장히 모호한 경우가 많습니다.
그렇기에 `CFrame` 을 조작하는 것을 기본으로 합니다.

- `Postion`, `Orientation`, `Rotation` 을 바꾸면 물리적으로 연결된 다른 객체들이 움직이지 않습니다.
- `Orientation`, `Rotation` 은 클램핑 이슈로 유연한 각도 설정이 굉장히 어려우며,
  또한 `CFrame.fromEulerAngles()`, `CFrame:ToEulerAngles()` 로 대체할 수 있습니다.

## 이름 짓기 관습

Property, Attribute 전부 객체 속성 규칙을 따릅니다.
