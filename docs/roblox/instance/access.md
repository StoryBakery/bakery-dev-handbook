---
title: 인스턴스 접근 규칙
---

인스턴스 접근은 "이 인스턴스가 반드시 있어야 하는가"를 먼저 결정하고 접근 방식을 고릅니다.
필수 구조는 직접 접근하고, 비동기적으로 늦게 생길 수 있는 구조만 기다리며,
정말로 없을 수 있는 구조만 탐색합니다.

## 필수 구조는 직접 접근합니다

프로젝트 구조상 항상 있어야 하는 자식은 `.` 접근을 사용합니다.
`FindFirstChild` 나 `WaitForChild` 로 감싸면 구조 오류가 조용히 숨겨지고,
타입도 `Instance?` 처럼 넓어져 이후 코드가 더 불안정해집니다.

```luau
-- Bad:
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Shared = ReplicatedStorage:WaitForChild("Shared")
const Remotes = Shared:WaitForChild("Remotes")
const EquipItem = Remotes:FindFirstChild("EquipItem")

-- Good:
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Shared = ReplicatedStorage.Shared
const Remotes = Shared.Remotes
const EquipItem = Remotes.EquipItem
```

필수 인스턴스가 없다면 그건 런타임에서 복구할 문제가 아니라 프로젝트 구조가 깨진 문제입니다.
이런 경우는 빠르게 실패하는 편이 원인을 찾기 쉽습니다.

## `WaitForChild` 와 `FindFirstChild` 는 최대한 사용을 자제합니다

`.` 인덱싱보다 가독성을 해치며, 성능상으로도 별로입니다.
특히 자주 돌아가는 콜백 함수일 경우 더더욱.

## `WaitForChild`

### `WaitForChild` 는 복제를 기다려야하는 상황에서만 사용해야합니다

`WaitForChild` 는 클라이언트에서 아직 복제되지 않았거나,
엔진 또는 다른 스크립트가 나중에 생성하는 인스턴스를 기다릴 때만 사용합니다.

플레이어의 복제 관련해서는 [플레이어](./../player/index.md#플레이어-자식-복제) 를 참고해주세요.
바로 복제되는 환경이라면 `WaitForChild` 가 아니라 `.` 인덱스가 훨씬 낫습니다

가장 좋은 것은 `WaitForChild` 를 쓰지 않아도 되는 것입니다.
같은 기능 단위는 인스턴스 계층을 분리하지 않고,
같은 계층에 둔다면 복제가 되는 순간 연결된 객체들도 전부 복제되기 때문입니다.

```luau
-- Bad:
const localPlayer = Players.LocalPlayer
const jumpButton = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ControlsGui"):WaitForChild("JumpButton")

-- Good:
const localPlayer = Players.LocalPlayer
const jumpButton = localPlayer.PlayerGui:WaitForChild("ControlsGui").JumpButton
```

### 타임아웃

WaitForChild 에서 timeout 을 2번째 인수로 넣을 수 있지만,
비엄격한 구조보단, 엄격한 구조를 위해 타임아웃으로 못찾았다면 에러를 내는 것이 더 좋을 수도 있습니다.

```luau
const controlsGui = playerGui:WaitForChild("ControlsGui", 10)
assert(controlsGui, "ControlsGui was not replicated")
```

가장 좋은 것은 앞서 말했다시피 계층 구조를 분리하지 않는 것.

### 계층 구조를 분리하지 않는 방법

자체 `UI`, `Script`, `InputContext` 등을 애초부터 같은 폴더/모델 아래에 두면 해결되는 것이 많습니다.

`:Clone()` 을 통해 `Player` 의 자손이나, 다른 곳에 복제해두는 것이 좋습니다.
외부에서도 감지해야할 경우, 인터페이스 모듈에서 반환하게 하거나, 태그를 사용하는 법도 좋습니다.

## `FindFirstChild`

### `FindFirstChild` 는 선택적 구조에만 사용합니다

`FindFirstChild` 는 인스턴스가 실제로 없을 수 있을 때 사용합니다.
찾은 뒤에는 반드시 `nil` 가능성과 클래스 검증을 처리합니다.

가장 좋은 것은 `FindFirstChild` 를 덜 사용할 수 있도록, 명확한 구조를 취하는 것입니다.
이 태그를 가지면 해당 객체는 무조건 있다. 라고 가정해 작업하거나

```luau
--[[
    만약 Chair 에 Seat 가 무조건 있어야한다는 조건에 가까울 경우
]]
const chairs = CollectionService:GetTagged("Chairs")

-- Bad:
for i, chair in chairs do
    -- 사용자가 Seat 를 선택하는 모델이라면 괜찮지만, 필수적인 인스턴스인 경우 잘못된 패턴
    const seat = chair:FindFirstChild("Seat")
    if seat then
        initChairSeat(seat)
    end
end

--[[
    Good 1:
    chair 에는 무조건 Seat 가 있어야한다 로
    단 에러시 다른 의자들도 끊긴다는 단점이 있습니다.
    완전 에러가 없을 확률이 높은 경우에 추천되는 패턴
]]
for i, chair in chairs do
    const seat = chair.Seat
    initChairSeat(seat)
end

--[[
    Good 2:
    1 번과 달리 task.spawn 으로 감싸서 에러는 나지만 끊기지 않습니다
    에러가 절대 없다고 확신못하는 경우에 추천되는 패턴
    개발자, 협업자의 미숙함 혹은 스트리밍 패턴을 완전하게 예측하지 못하겠는 경우 등.
]]
const function onChair(chair: Model)
    const seat =
        chair:FindFirstChild("Seat")
        or error(`Cannot find seat from Chair "{chair:GetFullName()}"`)
    initChairSeat(seat)
end

for i, chair in chairs do
    task.spawn(function()

    end)
end
```

### 여러 후보를 이어붙이지 않습니다

서로 다른 이름, 부모, 리그 구조를 전부 시도하는 코드는 계약이 없는 코드가 됩니다.
프로젝트가 기대하는 구조를 하나로 정하고, 다른 구조를 지원해야 한다면 변환 지점을 별도로 둡니다.

```luau
-- Bad:
const torso =
    character:FindFirstChild("Torso")
    or character:FindFirstChild("UpperTorso")
    or character.PrimaryPart

-- Good:
const upperTorso = character.UpperTorso
```

### 자손 전체 탐색은 피합니다

`FindFirstChild("Name", true)` 나 `GetDescendants()` 로 이름을 찾는 방식은
인스턴스의 소유 위치를 흐리게 만들고, 같은 이름의 다른 인스턴스가 추가되었을 때 쉽게 깨집니다.

```luau
-- Bad:
const prompt = workspace:FindFirstChild("DoorOpenPrompt", true)

-- Good:
const CollectionService = game:GetService("CollectionService")

const doorOpenPrompts = CollectionService:GetTagged("DoorOpenPrompt")
```

정해진 위치가 있다면 정확한 부모에서 접근하고,
동적으로 여러 개를 다뤄야 한다면 `CollectionService` 태그나 별도의 레지스트리로 관리합니다.

게임에서 유일한 특정 객체일 경우, 겹치지 않도록 특수 태그를 사용하는 것을 좋습니다.

```luau
-- SomeBossModules/DoorHandler/init.luau
const DOOR_OPEN_PROMPT_TAG = "SomeBossModules/DoorHandler/DoorOpenPrompt/1"

const doorOpenPrompt =
    CollectionService:GetTagged(DOOR_OPEN_PROMPT_TAG)[1]
    or CollectionService:GetInstanceAddedSignal(DOOR_OPEN_PROMPT_TAG):Wait()
```
