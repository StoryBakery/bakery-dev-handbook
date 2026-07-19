---
title: 인스턴스 생성
---

## 부모가 설정된 인스턴스의 속성/Attribute 를 설정하는 것이 대략 2배 더 비쌉니다

부모가 설정된 인스턴스에 속성/Attribute 를 쓰는 것이 서버에서는 2배, 클라이언트에서는 1.25배 정도 더 비쌉니다.

부모가 설정되기 전에 Property 와 Attribute 를 설정하는 것이 좋습니다.

```luau
-- Bad:
const doorFolder = Instance.new("Folder", workspace)
doorFolder.Name = "Door"
doorFolder:SetAttribute("AllClosed", false)
doorFolder:SetAttribute("AllBroken", false)

-- Good:
const doorFolder = Instance.new("Folder")
doorFolder.Name = "Door"
doorFolder:SetAttribute("AllClosed", false)
doorFolder:SetAttribute("AllBroken", false)
doorFolder.Parent = workspace
```

## 복제

### Archivable

`Archivabe` 은 스튜디오 EditMode 에서 플러그인이 생성해둔 임시 객체 (미리보기 등)처럼
저장되지 말아야할 객체들, 그리고 조상이 `Clone` 될 때 자신은 복제되지 않아야하는 `boolean` 속성입니다

유용한 속성이지만, 자주 쓰이는 속성도 아닐 뿐더러 아주 특수 상황에서만 쓰입니다.

그렇기에 `:Clone` 시 `.Archivable` 매번 상시 확인은 하지 않습니다,
`Clone` 시 `Archivable` 이 `false` 일 수 있는 상황 자체가 잘못된 것입니다.

그래서 `Archivable` 를 `false` 로 설정하는 것은 다음과 같은 규칙에서 하는 것이 좋습니다

- `Plugin` 의 미리보기 전용 인스턴스가 플레이스에 저장되지 않도록 하기 위해 사용합니다.
  또한 `CoreGui`, 나 `PlayerGui` 처럼 이미 저장되지 않는 곳에 둘 수 있다면 최대한 두기로 노력합니다.
  대부분의 시각 오브젝트들은 `Adornee` 를 통해, 부모가 아닌 대상에도 표시를 띄울 수 있습니다.
  저장되지 않는 장소에 둔다면 `Archivable` 을 `false` 로 두지 않아도 됩니다.

- 런타임적으로 복제 기능을 사용할 때 자동생성 컴포넌트일지라도, `:Clone()` 이 상관없게 하거나
  절대로 직접적인 `Clone` 호출 대상이 되지 않을 대상에만 `Archivable` 을 `false` 로 설정합니다.

```luau
-- Bad:
const cloned = (function()
    if instance.Archivable then
        return instance:Clone()
    end

    instance.Archivable = true
    const cloned = instance:Clone()
    instance.Archivable = false
    return cloned
end)()

-- Good:
const cloned = instance:Clone()
```

그렇기에 `Clone` 시 너무 과도하게 분기 케이스를 생각하지마세요.

### `Instance.fromExisting`

`Instance.fromExisting(existingInstance)` 는 기존 인스턴스를 Archivable 여부와 상관없이 복제할 수 있습니다.
그러나 자식들까진 복제하지 않습니다.

`:Clone()` 보다 덜 유용해도, 적합한 상황에서는 더 빠른 성능을 내놓습니다.
