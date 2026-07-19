---
title: Instance Handle
---

`InstanceHandle` 로 인스턴스를 어떻게 서버와 클라이언트 사이로 통신하고,
`Attribute` 에 저장하는지 다룹니다.

- `InstanceHandle.new(instance: Instance): InstanceHandle`
- `handle:Get(): Instance?`
- `handle:Wait(timeout: number?): Instance?`

## `Attribute` 에 `InstanceHandle` 저장하기

```luau
-- 두 가지 방식 전부 가능합니다
part:SetAttribute("Target", workspace.TargetPart)
part:SetAttribute("Target", InstanceHandler.new(workspace.TargetPart))

-- 단 인스턴스를 가져올 경우 오로지 InstanceHandler 로 반환됩니다
const handle = part:GetAttribute("Target")
const target = handle:Wait()

if target then
	print("Target is", target.Name)
end
```

인스턴스가 동기화된 것이 아닌 애초부터 설정되어있지 않은 경우,
비어있는 Attribute 와 동일하게 `nil` 로 반환됩니다.

`InstanceHandler:Get()` 가 비어있는 것은 서버에선 인스턴스가 있지만 동기화가 아직 안됐다는 것이고,
`Attribute` 가 애초부터 인스턴스가 등록되지 않은 상태입니다.

## `RemoteEvent` 로 전송하기

`InstanceHandler` 는 RemoteEvent 로도 전송할 수 있습니다.
`Instance` 를 그냥 보내는 것보다 더 안정적입니다.

```luau
-- Server
remote:FireClient(player, InstanceHandle.new(workspace.Boss))

-- Client
remote.OnClientEvent:Connect(function(handle)
	local boss = handle:Wait()
	print("Boss:", boss.Name)
end)
```
