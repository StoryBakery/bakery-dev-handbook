---
title: Instance 제거와 가비지 수거 상세사항
---

## 인스턴스 가비지 수거

인스턴스의 가비지 수거 동작에 대해 보다 상세한 테스트 결과 모음입니다.

### 공통 함수

```luau
const function forceGc()
	const gcCheck = setmetatable({}, { __mode = "v" }) :: any

	do
		table.insert(gcCheck, {})
	end

	assert(#gcCheck > 0, "GC validation weak table list is already empty")

	for _ = 1, 1_000_000 do
		const _ = table.create(500, {})
		if #gcCheck == 0 then
			return
		end
	end

	error("GC did not clear the weak table list")
end

local part = workspace.Part
const instanceSet = setmetatable({}, {__mode = "k"})
instanceSet[part] = true

test(part)

part = nil

task.wait()

forceGc()

print( if next(instanceSet) == nil then "Collected" else "Uncollected" )

const existing = workspace:FindFirstChild("Part")
print( if existing == nil then "Removed" else "Unremoved" )

if existing then
	existing:Destroy()
end

Instance.new("Part", workspace)
```

### 실험 결과

#### 인스턴스를 삭제하지 않고 Luau 에서 변수 참조만 없앨 경우

```luau
const function test(part: Instance)
end
```

```
Collected
Unremoved
```

#### 인스턴스를 삭제하기 위해 부모를 `nil` 로 설정한 경우

```luau
const function test(part: Instance)
    part.Parent = nil
end
```

```
Collected
Removed
```

#### 인스턴스를 순환참조하는 콜백 함수를 연결하고 부모를 `nil` 로 설정한 경우

```luau
const function test(part: Instance)
	part.Changed:Connect(function()
		print(`{part} is cyclic-referenced now.`)
	end)
	part.Parent = nil
end
```

```
Part is cyclic-referenced now.
Uncollected
Removed
```

#### 인스턴스를 순환참조하는 콜백 함수를 연결하고 `Destroy` 를 호출한 경우

```luau
const function test(part: Instance)
	part.Changed:Connect(function()
		print(`{part} is cyclic-referenced now.`)
	end)
	part:Destroy()
end
```

```
Part is cyclic-referenced now.
Collected
Removed
```

#### 인스턴스를 순환참조하는 콜백 함수를 연결하고 참조를 끊은 경우

```luau
const function test(part: Instance)
	part.Changed:Connect(function()
		print(`{part} is cyclic-referenced now.`)
	end)
	part = nil
end
```

```
Collected
Unremoved
nil is cyclic-referenced now.
```

#### 인스턴스를 순환참조하는 콜백 함수를 연결하고, `game` 에서 사라지면 콜백을 끊고 부모를 `nil` 로 설정하기

```luau
const function test(part: Instance)
	const changedConn = part.Changed:Connect(function()
		print(`{part} is cyclic-referenced now.`)
	end)
	local ancestryChangedConn
	ancestryChangedConn = part.AncestryChanged:Connect(function(_, newAncestor)
		if newAncestor == nil then
			changedConn:Disconnect()
			ancestryChangedConn:Disconnect()
		end
	end)
	part.Parent = nil
end
```

```
Collected
Removed
```
