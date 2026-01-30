---
sidebar_label: Instance Property Style
---

## Content

로블록스에서는 `-Content` 속성이 추가되기 전엔 `-Id`처럼 `string` 값으로 경로로 어셋 속성을 설정했지만,
이는 대역폭의 증가, `Editable-` 오브젝트와의 호환성 문제 등 여러 문제가 있었습니다.

그러므로 `StoryBakery` 의 게임들은 무조건 `-Content` 속성을 이용합니다.


```lua
e(ImageLabel) ({
	ImageContent = Content.fromAssetId(12345678)
})
```

```lua
extDecal:SetProperty("ImageContent", Content.fromObject(editableImage))
```

## 속성

### 명명 규칙
[naming-style](./scripting/naming-style.md) 를 따릅니다

Property, Attribute 전부 동일.

