---
title: Instance 생명주기
---

인스턴스의 제거와 가비지 수거에 대해 다룹니다

## `Destroying` 이 아닌 `AncestryChanged` 에 의존해주세요

`Destroying` 시그널은 오로지 `:Destroy` 를 명시적으로 호출했을 때만 발동하는 시그널입니다.
그래서 인스턴스가 `game` 모델에서 사라져도, 그리고 이후 가비지 수거되어도 `Destroying` 이 발동되지 않습니다.

사실은 사용처가 굉장히 적은 이벤트입니다!

```luau
instance.Destroying:Connect(function()
    print("Destroyed")
end)

instance.Parent = nil
-- 이후 instance 가 진짜 가비지 수거되어도 Destroying 시그널은 절대 발동되지 않음.
```

인스턴스가 정말 사라지는 경우는 다음 조건을 만족해야합니다.

1. 인스턴스에 대한 모든 참조가 사라져야합니다.
2. 인스턴스 자기 자신을 순환참조하는 콜백함수가 인스턴스에 연결되어있지 않아야합니다.
  Luau 는 C++ 환경에서 어디서 변수를 참조하는지 알 수 없어, 연결이 유지되는 동안 해당 참조를 절대 놓아주지 않습니다.
3. 인스턴스의 조상들이 위 두 조건을 만족해야합니다
4. 인스턴스의 최상위 조상은 `nil` 이어야합니다, `game` 이면 안됩니다.

`Parent = nil` 로 설정하거나 `:Remove()` 가 아닌 `:Destroy()` 를 사용해 제거하란 것은, 2번이 문제이기 때문입니다.
인스턴스 자신을 참조하는 콜백함수가 자신에 연결되어있으면 절대 수거되지 않기 때문에, 쓰레기 메모리가 됩니다.

하지만 그것에 매몰되어 `.Parent = nil` 은 나쁜 관습이고, `:Destroy` 만 사용해야한다는 상당히 잘못된 인식입니다.
로블록스의 스트리밍 아웃으로 인한 제거되는 인스턴스, `workspace.FallHeightEnabled` 로 제거되는 파트들
전부 `:Destroy()` 로 삭제되는 것이 아니기에 `Destroying` 시그널이 작동되지 않습니다.

그렇기에 `AncestryChanged` 를 사용해야합니다.

```luau
local removingConnection
do
    removingConnection = instance.AncestryChanged:Connect(function(_, newAncestor)
        if newAncestor == nil then
            -- Maid 처럼 모든 참조를 없앰
            -- 혹은 Maid 패키지를 사용 중이라면 Maid:Destroy() 를 사용할 수 있습니다.
            clearOnDestroyed(instance)
            removingConnection:Disconnect()
        end
    end)
end
```

때로는 조상만 바뀌어도 초기화되었다 인식해야할 인스턴스에 대해선
`newAncestor == nil` 조건문을 없애고 `:Once` 를 사용할 수 있습니다.
이 경우 `:Disconnect()` 를 하지 않아도 되어 코드가 보다 깔끔해집니다.

### 모든 시그널은 인스턴스가 사라지고 나서 정리하는 것이 좋습니다

모든 시그널은 `AncestryChanged` 에 정리 함수를 넘겨주거나,
`Maid` 패키지가 있다면 `Maid` 객체로 정리하는 것이 좋습니다.

엔진이 처리해 사라지는 인스턴스는 `Destroy()` 가 작동되지 않기에 `Signal` 이 끊기지 않기 때문에,
조상이 `nil` 이 되면 정리해줘야 합니다.

```luau
maid:GiveTask(instance:GetAttributeChangedSignal(attribute):Connect(callback))
```

### 조상이 `nil` 이 된다면 비활성화 인스턴스라고 간주합니다

인스턴스를 만들고 `Parent` 를 `nil` 로 뒀다가 다시 재배치하는 경우도 있으나,
이 경우에는 초기화되었다가 다시 돌아와 재초기화시킨다고 간주해야합니다.

처음 생성 당시 `nil` 이지 않은 이상 최상위 조상이 `game` 이 아니라면, 시그널을 끊고 동작하지 말아야합니다.

## 메타메소드가 `__mode = "kv"` 인 약한 참조 테이블은 진짜 인스턴스가 사라졌는지를 감지하지 못합니다

메타메서드가 `__mode = "kv"` (혹은 `"k" | "v"`) 인 테이블은 약한 참조를 하기 때문에,
참조를 한다고 해서 가비지 수거를 막지 않아, 참조 도중에 사라질 수 있는 유연한 메모리관리를 할 수 있는 테이블입니다.

그러나 인스턴스가 게임 모델에서 사라졌는지는 감지 못합니다.
왜냐하면 'Luau 환경에서만 의존되는 참조가 모두 사라진 경우' 에서만이기 때문입니다. (추정컨대)

```luau
const function forceGc()
    const gcCheck = setmetatable({}, { __mode = "v" }) :: any
    for _ = 1, 100_000 do
        const _ = table.create(500, {})
        if #gcCheck == 0 then
            return
        end
    end
    error("GC did not clear the weak table list")
end

local instance = workspace.Part

const instanceSet: {[Instance]: true} = setmetatable({}, {__mode = "k"}) :: any
instanceSet[instance] = true

instance = nil

forceGc()

print( next(instanceSet) ) --> nil

print(workspace.Part) --> Part, 실제로 파트는 살아있습니다.
```

그렇기에 만일 `instanceSet` 이 현재 Luau 환경에서만 약한 참조용인 경우가 아니라면
(또한 대부분은 그런 Luau 환경에서만의 참조만을 고려하는 약한 참조를 사용할 이유가 적음),
실제 인스턴스가 사라질 때 수거하는 접근법은 `AncestryChanged`, `DescendantRemoving`, `ChildRemoved`,
`CollectionService:GetInstanceRemovedSignal` 등으로 관리를 해야합니다.

혹은 그 시그널을 감싸는 시그널이나, 정리 콜백 함수에 연결합니다.

```luau
const instanceSet: {[Instance]: true} = {}

const function registerInstance(instance: Instance)
    instanceSet[instance] = true

    local ancestryChangedConn
    ancestryChangedConn = instance.AncestryChanged:Connect(function(_, newAncestor)
        if newAncestor == nil then
            trackedInstances[instance] = nil
            ancestryChangedConn:Disconnect()
        end
    end)
end
```
