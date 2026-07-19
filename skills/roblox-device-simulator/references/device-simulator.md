# Roblox Device Simulator Reference

## 팁

- 빠르게 첫 화면을 확인하려면 **iPhone에서 `/device-test`부터 시작**하고, 여러 디바이스를 폭넓게 확인해야 할 때 `/device-compare`로 확장하세요.
- **버그는 세로 화면에 숨어 있는 경우가 많습니다** — 대부분의 UI가 가로 화면을 먼저 기준으로 만들어집니다. `/device-orientation`을 실행해 세로 화면에서만 발생하는 문제를 찾아내세요.
- **플레이 모드에서는 실제 UI가 표시됩니다** — 많은 플레이스가 런타임에 UI를 동적으로 생성합니다. 편집 모드에서 `/device-test`를 실행했는데 거의 아무것도 보이지 않는다면 `/device-playtest`를 사용해 실제 게임 내 레이아웃을 확인하세요.

## 명령어

| 명령어 | 사용 시점 |
| --- | --- |
| `/device-test` | 하나의 디바이스에서 UI 테스트 |
| `/device-compare` | 여러 디바이스의 UI를 나란히 비교 |
| `/device-orientation` | 세로 화면과 가로 화면 비교 테스트 |
| `/device-playtest` | 플레이 모드에서 게임 내 UI 테스트 |

---

## 작동 방식

에이전트는 다음 세 가지 MCP 도구를 순서대로 사용합니다.

1. **`execute_luau`** — DeviceSimulatorService API 호출(디바이스, 화면 방향, 해상도 전환)
2. **`screen_capture`** — 스크린샷을 찍고 비전 분석으로 UI 문제 확인
3. **`get_console_output`** — 런타임 오류와 경고 확인

스크린샷은 가장 중요한 검증 수단입니다. 에이전트는 스크린샷을 직접 살펴보고 잘림, 겹침, 텍스트 잘림, 요소 누락 등을 보고합니다.

**핵심 제약:** `execute_luau`는 **편집 DataModel**에서 실행되므로 플레이 모드 중에는 `PlayerGui`나 실제 `AbsolutePosition`/`Size`에 접근할 수 없습니다. 플레이 모드 검증에는 `screen_capture`를 사용하세요.

**여러 Studio 인스턴스:** 여러 인스턴스가 열려 있다면 시작할 때 한 번 `list_roblox_studios`와 `set_active_studio`를 호출하세요.

### 0단계: 테스트할 대상 결정

StarterGui 트리를 순회하여 UI 구조를 파악하세요. 그런 다음 바로 진행할지, 사용자에게 질문할지 결정합니다.

**다음 경우에는 질문하지 말고 바로 진행합니다.**

- 사용자가 이미 테스트 대상을 지정한 경우(예: "내 HUD를 테스트해 줘", "리더보드를 확인해 줘")
- ScreenGui가 하나뿐이라 모호하지 않은 경우
- 뷰포트에 이미 UI가 보이는 경우 — 스크린샷을 찍고 분석하면 됩니다.

**다음 경우에는 사용자에게 질문합니다.**

- StarterGui가 비어 있거나 모든 UI가 `Visible=false`인 경우 — 스크린샷을 찍어도 빈 장면만 보여 쓸모가 없습니다. 다음과 같이 말하세요. "UI가 런타임에 생성되는 것 같습니다. 플레이 모드가 필요해요. 어떤 화면을 테스트할까요(HUD, 메뉴, 로비)?"
- 서로 분리된 화면이 명확히 여러 개 있는 경우(예: MenuGui + GameplayGui + ShopGui)인데 사용자가 어느 화면인지 지정하지 않고 단순히 "내 UI를 테스트해 줘"라고 한 경우

목표는 불필요한 왕복 질문을 최소화하는 것입니다. 대부분의 사용자는 현재 화면에 보이는 UI가 여러 디바이스에서 어떻게 보이는지 확인하고 싶어 하므로, 대개는 그대로 진행하면 됩니다.

### 1단계: 게임 설정 읽기

디바이스를 전환하거나 테스트하기 전에 `execute_luau`로 다음 코드를 실행하세요.

```lua
local sg = game:GetService("StarterGui")
local results = {}
table.insert(results, "game.Name: " .. game.Name)
table.insert(results, "ScreenOrientation: " .. tostring(sg.ScreenOrientation))

for _, child in sg:GetChildren() do
    if child:IsA("ScreenGui") then
        local props = {}
        for _, prop in {"IgnoreGuiInset", "ScreenInsets", "SafeAreaCompatibility", "ClipToDeviceSafeArea"} do
            local ok, v = pcall(function() return child[prop] end)
            if ok then table.insert(props, prop .. "=" .. tostring(v)) end
        end
        table.insert(results, "ScreenGui: " .. child.Name .. " [Enabled:" .. tostring(child.Enabled) .. "] " .. table.concat(props, " | "))
    end
end
return table.concat(results, "\n")
```

이 코드를 통해 에이전트는 다음 내용을 알 수 있습니다.

**게임 전체 설정:**

| 설정 | 테스트에서의 의미 |
| --- | --- |
| `ScreenOrientation = LandscapeSensor` | 가로 화면 전용 — **세로 화면 테스트 건너뛰기** |
| `ScreenOrientation = Sensor` | 모든 화면 방향 지원 — **둘 다 테스트** |
| `ScreenOrientation = Portrait` | 세로 화면 전용 — **가로 화면 테스트 건너뛰기** |

**ScreenGui별 설정:**

| 설정 | 의미 |
| --- | --- |
| `IgnoreGuiInset = true` | UI가 y=0(상단 표시줄 아래)에서 시작 — 상태 표시줄 뒤에 가려지는 요소가 있는지 확인 |
| `IgnoreGuiInset = false` | UI가 약 36px 아래로 밀림 — 정상 동작이지만 작은 디바이스에서는 사용 가능한 화면 공간이 줄어듦 |
| `ScreenInsets = DeviceSafeInsets` | 노치와 홈 인디케이터를 고려 — UI가 하드웨어 인셋 영역 아래로 들어가지 않음 |
| `ScreenInsets = CoreUISafeInsets` | 상단 표시줄 인셋만 고려 — 화면 측면이나 하단의 노치 영역 아래로 UI가 들어갈 수 있음 |
| `ScreenInsets = None` | 인셋 없이 전체 화면 사용 — UI가 노치 뒤에 가려질 수 있음 |
| `ClipToDeviceSafeArea = true` | 안전 영역을 기준으로 UI가 잘림 — 요소가 노치 아래에 렌더링되지 않음 |
| `ClipToDeviceSafeArea = false` | UI가 노치 영역 아래에도 렌더링될 수 있음 — 상호작용 요소에 실제로 접근 가능한지 확인 |

사용자가 결과의 맥락을 이해할 수 있도록 **출력에는 항상 게임 설정을 포함하세요.**

## 모호한 표현 처리 및 기본값

### 모호한 표현 → 디바이스

**디바이스 목록은 동적으로 바뀌므로 항상 `GetDeviceListAsync()`와 `GetDeviceInfoAsync()`로 최신 목록을 읽으세요.** 아래 표는 이름을 매칭할 때 사용할 보조 기준입니다. 목록에 더 최신 디바이스(예: iPhone 15 Pro)가 있다면 이전 모델보다 최신 모델을 우선하세요.

| 사용자가 말한 표현 | 선택 방법 | 예시 |
| --- | --- | --- |
| "iPhone" / "phone" / "mobile" | 가장 최신 iPhone — 이름에 포함된 세대 숫자가 가장 큰 모델 | iPhone 17 Pro > iPhone 16 Pro Max > iPhone 16 |
| "iPad" / "tablet" | 가장 최신 iPad — 이름에 포함된 세대 숫자가 가장 큰 모델 | iPad Pro M5 (13in) > iPad Air 5th Gen > iPad 10th Gen |
| "Xbox" / "console" | 이름에 "Xbox"가 포함된 항목 | Xbox One |
| "PlayStation" / "PS" | 이름에 "PS"가 포함된 항목 중 숫자가 가장 큰 모델 | PS5 > PS4 |
| "VR" / "Quest" / "headset" | 이름에 "Quest" 또는 "Meta"가 포함된 항목 중 숫자가 가장 큰 모델 | Meta Quest 3 > Meta Quest 2 |
| "laptop" / "desktop" / "PC" | 이름에 "Laptop" 또는 "Average"가 포함된 항목 | Average Laptop |
| "handheld" / "Steam Deck" | 이름에 "Handheld"가 포함된 항목 | Generic Handheld HD 720 |
| "small screen" / "worst case" | 전체 목록에서 해상도가 가장 낮은 디바이스 | (가장 오래되거나 가장 작은 디바이스) |
| "large screen" / "best case" | 전체 목록에서 해상도가 가장 높은 디바이스 | (가장 큰 디바이스) |

**"최신" 디바이스 선택 방법:** 여러 디바이스가 일치할 경우(예: iPhone 5개), 이름에 포함된 **세대 숫자가 가장 큰 모델**을 고르세요(예: "17" > "16" > "14"). 디바이스 목록에는 출시일 필드가 없으므로 이것이 "가장 최신" 모델을 추정하는 가장 신뢰할 만한 기준입니다. 같은 세대의 모델이 두 개라면(예: "iPhone 16"과 "iPhone 16 Pro") "Pro" 모델을 우선하세요.

**일치하는 프리셋이 없나요?** 사용자가 정확한 해상도(예: "1440x900")를 제공했다면 `CreateDeviceAsync`로 사용자 지정 디바이스를 만드세요. 자세한 내용은 API_SPEC.md를 참고하세요. 사용자의 표현이 모호하다면 추측하지 말고 먼저 질문하세요.

### 디바이스별 UI 특성

스크린샷을 분석할 때는 각 디바이스의 물리적 특성을 고려하세요.

| 디바이스 유형 | 확인할 사항 |
| --- | --- |
| **iPhone X 이상(16 Pro, 17 Pro, XR 등)** | 가로 화면에서 왼쪽 가장자리에 노치/다이내믹 아일랜드가 있음. `ScreenInsets=CoreUISafeInsets`라면 UI가 노치 아래로 들어갈 수 있음. 하단 홈 인디케이터 때문에 실제 사용 가능한 공간이 줄어듦. |
| **저사양 휴대전화(Galaxy A06 등)** | 뷰포트가 좁음(가로 화면에서 높이 약 360px). 고정 픽셀 UI가 화면의 매우 큰 비율을 차지함. 터치 대상이 너무 작을 수 있음. |
| **iPad** | 화면 비율이 넓고 공간이 많음. 휴대전화용 UI가 지나치게 휑해 보일 수 있음. 휴대전화에서는 적절했던 텍스트가 태블릿을 팔 길이 정도 떨어뜨려 보면 너무 작게 느껴질 수 있음. |
| **Xbox / 콘솔** | TV 오버스캔 때문에 화면 가장자리의 5~10%가 잘릴 수 있음. 화면 끝에 배치한 UI 요소가 보이지 않을 수 있음. 약 3m 거리의 소파에서 읽을 수 있을 만큼 텍스트가 커야 함. |
| **PS5** | Xbox와 비슷하지만 해상도가 1920x1440(4:3에 가까움). 일반적이지 않은 화면 비율 때문에 16:9를 전제로 한 레이아웃이 깨질 수 있음. |
| **Meta Quest / VR** | 일반적이지 않은 화면 비율(688x736, 거의 정사각형). 넓은 화면용 UI가 맞지 않을 수 있음. 사용자는 화면 중앙에 집중하므로 주변부 요소를 놓칠 수 있음. |
| **노트북 / 데스크톱** | 표준적인 화면 비율. 보통 UI가 잘 작동함. 마우스 중심 UI(호버 상태, 작은 버튼)에 접근하기 쉬운지 확인할 것. |

결과를 보고할 때 이러한 특성을 활용하세요. 예: "Xbox에서 타이머 텍스트 너비가 뷰포트의 8%에 불과합니다. TV를 소파 거리에서 보면 읽기 어려울 수 있습니다."

### 기본값

- **화면 방향:** 항상 가로 화면. 사용자가 명시적으로 요청한 경우에만 세로 화면 사용.
- **디바이스 검색 순서:** 이름 정확히 일치 → 유사 이름 일치 → 해상도 일치 → `CreateDeviceAsync`로 사용자 지정 생성(최후 수단)

### 테스트 후 최종 상태

| 명령어 | 테스트 후 처리 |
| --- | --- |
| `/device-test` | `StopSimulationAsync()`로 **기본 상태로 복귀** |
| `/device-compare` | `StopSimulationAsync()`로 **기본 상태로 복귀** |
| `/device-orientation` | `SetOrientationAsync(LandscapeLeft)`로 **가로 화면으로 복귀**한 뒤 `StopSimulationAsync()` 실행 |
| `/device-playtest` | 플레이 모드를 종료한 뒤 `StopSimulationAsync()`로 **기본 상태로 복귀** |

항상 사용자에게 다음과 같이 알리세요. "Studio를 기본 뷰포트로 초기화했습니다."

### 여러 디바이스 비교에 권장되는 대표 유형

디바이스 목록에서 동적으로 선택하세요.

| 대표 유형 | 선택 방법 | 선택 이유 |
| --- | --- | --- |
| 휴대전화 | 가장 최신 `Phone`(세대 숫자가 가장 큼) | 가장 일반적인 폼 팩터이며 노치가 있을 가능성이 큼 |
| 태블릿 | 가장 최신 `Tablet`(세대 숫자가 가장 큼) | 가장 넓은 화면 비율 |
| 콘솔 | 아무 `Console` 디바이스 | TV 오버스캔과 소파 시청 거리 확인 |
| VR | 가장 최신 "Quest" 또는 "Meta" 디바이스 | 비표준 화면 비율 스트레스 테스트 |
| 저사양 | 전체 목록에서 해상도가 가장 낮은 디바이스 | 한계 조건 스트레스 테스트 |

사용자가 전수 검사를 요청하지 않는 한 약 4~5개 디바이스로 제한하세요.

---

## API 참조

**전체 API 문서는 같은 디렉터리의 `API_SPEC.md`에 있습니다.** 여기에는 디바이스 시뮬레이션의 개념, 생명주기, 모든 메서드와 예시, 열거형 값, DeviceConfiguration 표, ConfigurationChanged 이벤트, 상태 지속성, 알려진 제한 사항, 오류 처리 방법이 포함되어 있습니다.

**자주 쓰는 작업 빠른 참조:**

### 디바이스 전환

```lua
local svc = game:GetService("StudioDeviceSimulatorService")
local devices = svc:GetDeviceListAsync()
for _, id in devices do
    local info = svc:GetDeviceInfoAsync(id)
    if info.Name == "iPhone 17 Pro" then
        svc:SetDeviceAsync(id)
        task.wait(0.2)  -- 뷰포트가 갱신될 때까지 반드시 기다릴 것
        break
    end
end
```

### 화면 방향 설정

```lua
svc:SetOrientationAsync(Enum.ScreenOrientation.Portrait)  -- 전체 열거형 경로를 사용할 것
task.wait(0.2)
```

### 사용자 지정 디바이스 만들기

```lua
local id = svc:CreateDeviceAsync({
    Name = "Custom_1440x900", Width = 1440, Height = 900, PixelDensity = 96
})
svc:SetDeviceAsync(id)
task.wait(0.2)
```

### 핵심 규칙

- **항상 이름으로 검색** — 디바이스 ID는 표시 이름이 아니라 `"iphone_17_pro"` 같은 내부 문자열입니다.
- **모든 setter 호출 뒤에 항상 `task.wait(0.2)` 실행** — 뷰포트 갱신은 비동기 방식이며 0.1초는 때때로 너무 짧습니다.
- **항상 `pcall` 사용** — 모든 메서드에서 오류가 발생할 수 있습니다(활성 디바이스 없음, PlayServer 차단 등).
- **getter도 활성 디바이스가 필요함** — 활성 디바이스가 없으면 `GetResolutionAsync`, `GetPixelDensityAsync`, `GetScalingModeAsync`에서 오류가 발생합니다.

---

## UI 탐색 및 레이아웃 이해

스크린샷을 분석하기 전에 에이전트는 `execute_luau`를 사용해 **UI 구조를 먼저 탐색**해야 합니다. 이렇게 하면 UI가 어떻게 동작할지 예측하고, 특정 모습이 나타나는 이유를 설명하며, 스크린샷만으로는 확인할 수 없는 항목(비활성화된 ScreenGui, 보이지 않는 요소 등)도 찾아낼 수 있습니다.

### StarterGui 트리 순회

편집 모드에서 `execute_luau`로 실행하세요. `AbsoluteSize`/`Position`은 0으로 나오므로 무시하고, 대신 `Size`(UDim2)를 읽으세요.

```lua
local root = game:GetService("StarterGui")
local results = {}
local function crawl(obj, depth, path)
    if not obj:IsA("GuiBase2d") and not obj:IsA("ScreenGui") then return end
    local entry = path .. " [" .. obj.ClassName .. "]"
    if obj:IsA("ScreenGui") then
        entry = entry .. " Enabled:" .. tostring(obj.Enabled)
    end
    if obj:IsA("GuiObject") then
        entry = entry .. " Size:" .. tostring(obj.Size) .. " Vis:" .. tostring(obj.Visible)
    end
    local layout = obj:FindFirstChildWhichIsA("UIListLayout")
    if layout then entry = entry .. " Layout:" .. tostring(layout.FillDirection) end
    local aspect = obj:FindFirstChildWhichIsA("UIAspectRatioConstraint")
    if aspect then entry = entry .. " Aspect:" .. tostring(aspect.AspectRatio) end
    table.insert(results, string.rep("  ", depth) .. entry)
    for _, child in obj:GetChildren() do
        crawl(child, depth + 1, path .. "." .. child.Name)
    end
end
for _, sg in root:GetChildren() do
    crawl(sg, 0, sg.Name)
end
return table.concat(results, "\n")
```

이 코드를 통해 에이전트는 다음 내용을 알 수 있습니다.

- **어떤 ScreenGui가 존재하는지**, 그리고 활성화되어 있는지
- **요소 크기가 어떻게 지정되어 있는지** — Scale(반응형)과 Offset(고정형)
- **어떤 레이아웃 제약 조건이 있는지** — UIListLayout 방향, 화면 비율 제약 조건
- **어떤 요소가 보이지 않는지** — 실제로 존재하지만 스크린샷에는 나타나지 않는 요소

### Scale과 Offset 크기 지정

`GuiObject.Size`는 `UDim2.new(xScale, xOffset, yScale, yOffset)` 형식입니다.

- **Scale**(0~1): 부모 크기의 비율 → **반응형** — 뷰포트 크기에 따라 함께 조절됨
- **Offset**(픽셀): 고정값 → **비반응형** — 작은 화면에서 넘칠 수 있음

에이전트가 `Size:{0.5, 0},{1, 0}`을 보면 → "부모 너비의 절반이며 반응형입니다."
에이전트가 `Size:{0, 200},{0, 50}`을 보면 → "항상 200×50픽셀이므로 뷰포트 너비가 200px보다 작으면 넘칩니다."

### 레이아웃 구성 요소

| 구성 요소 | 기능 | 디바이스 테스트에서 중요한 이유 |
| --- | --- | --- |
| `UIListLayout` | 자식 요소를 자동 배치 | `FillDirection`을 확인할 것 — Horizontal이면 좁은 화면에서 요소가 넘칠 수 있음 |
| `UIGridLayout` | 격자 형태로 배치 | 뷰포트가 좁아지면 다시 배치될 수 있음 |
| `UIAspectRatioConstraint` | 너비:높이 비율 고정 | 요소가 찌그러지지는 않지만 크게 축소될 수 있음 |
| `UISizeConstraint` | 최소/최대 크기 제한 | 최소 크기 아래로 줄어들지 않으므로 아주 작은 화면에서는 잘릴 수 있음 |
| `UIScale` | 스크립트 기반 크기 조정 | 뷰포트에 맞춰 요소 크기가 바뀔 수 있음 |

---

## 검증

### 에이전트가 할 수 있는 일

| 기능 | 도구 | 작동 환경 |
| --- | --- | --- |
| 디바이스 / 화면 방향 전환 | `execute_luau` | 편집 모드 |
| 실제 뷰포트 스크린샷 촬영 | `screen_capture` | 편집 + 플레이 모드 |
| 런타임 오류 확인 | `get_console_output` | 플레이 모드 |
| StarterGui 구조 읽기 | `execute_luau` | 편집 모드 |

### 에이전트가 할 수 없는 일

`execute_luau`는 **편집 DataModel**에서 실행됩니다. 플레이 모드에서는 `PlayerGui`, `LocalPlayer`, 실제 `AbsolutePosition`/`AbsoluteSize`에 접근할 수 없습니다. 실제 UI를 확인할 때는 `screen_capture`를 이용한 시각적 검증이 기본 방법입니다.

### 스크린샷 점검 목록

디바이스 또는 화면 방향을 바꿀 때마다 스크린샷에서 다음 항목을 확인하세요. **0단계의 게임 설정과 디바이스 특성 표를 함께 참고해 분석하세요.** 예를 들어 디바이스가 iPhone 17 Pro이고 `ScreenInsets=CoreUISafeInsets`라면 왼쪽 가장자리(다이내믹 아일랜드 영역)의 UI가 영향을 받는지 확인합니다.

| # | 확인 항목 | 화면에서 보이는 모습 |
| --- | --- | --- |
| 1 | **화면 밖으로 나감 / 잘림** | UI 요소가 뷰포트 가장자리에서 잘림 |
| 2 | **겹침** | 의도하지 않게 두 요소가 서로 포개짐 |
| 3 | **텍스트 잘림** | 단어 중간에서 잘리거나 "..."으로 표시됨 |
| 4 | **요소 누락** | 큰 디바이스에서는 보이지만 작은 디바이스에서는 사라짐 |
| 5 | **너무 작음** | 작은 화면에서 버튼이나 텍스트가 읽거나 누르기 어려울 정도로 작음 |
| 6 | **레이아웃 붕괴** | 나란히 있어야 할 요소가 자연스럽게 쌓이지 않고 서로 겹침 |
| 7 | **인셋 / 안전 영역 문제** | 노치가 있는 디바이스(iPhone X 이상): 화면 가장자리의 상호작용 UI가 노치 아래에 들어갈 수 있음. 콘솔: UI가 가장자리에 너무 가까워 TV 오버스캔에 잘릴 수 있음. 0단계의 `ScreenInsets` 값과 대조할 것. |

### 문제를 발견했을 때 제안할 내용

문제만 보고하지 말고 해결 방법도 함께 제안하세요.

| 발견한 문제 | 권장 해결 방법 |
| --- | --- |
| **화면 밖으로 나감 / 잘림** | Offset 기반 크기 지정을 Scale 기반으로 바꾸거나, 뷰포트에 맞는 최대값을 가진 `UISizeConstraint` 추가 |
| **텍스트 잘림** | `TextScaled = true` 사용, 텍스트 길이 줄이기, 또는 TextLabel 크기 늘리기 |
| **터치 대상이 너무 작음** | 버튼 크기를 최소 44×44로 늘리기. `MinSize`를 지정한 `UISizeConstraint` 사용도 고려 |
| **겹침** | 형제 요소를 자동 배치하도록 `UIListLayout`이 필요한지 확인하거나, 충돌하지 않도록 `Position`/`Size` 조정 |
| **작은 화면에서 요소 누락** | 스크립트가 뷰포트 크기에 따라 숨기고 있는지 확인. 의도하지 않은 동작이라면 Scale 기반 크기 사용 |
| **레이아웃 붕괴(요소가 한곳에 쌓임)** | `FillDirection`과 `Wraps`를 지정한 `UIListLayout` 추가 또는 스크립트 기반 반응형 레이아웃 사용 |

### 표현 방식

발견 사항은 **문제가 아니라 개선 기회**로 표현하세요. 친절하고 협력적인 어조를 사용합니다.

- "iPhone에서 BottomBar가 뷰포트 아래로 20px 내려갑니다 — Scale 기반 크기로 바꾸면 자동으로 맞춰집니다"라고 말하세요.
- "iPhone에서 UI가 망가졌습니다"라고 말하지 마세요.
- "Galaxy A06에서 텍스트가 잘립니다 — TextScaled를 사용하거나 라벨 문구를 줄이면 해결됩니다"라고 말하세요.
- "TextLabel이 너무 작습니다"라고만 말하지 마세요.

### 디바이스별 변화에서 경고할 것과 허용할 것

모든 레이아웃 변화가 버그인 것은 아닙니다. 다음 판단 기준을 사용하세요.

| 관찰 결과 | 판단 |
| --- | --- |
| 뷰포트가 좁아질 때 요소가 가로 → 세로로 재배치됨 | 부모에 `UIListLayout`이 있거나 스크립트 기반 레이아웃이라면 **예상된 동작** |
| 요소가 뷰포트에 비례해 축소됨 | Scale 기반 크기라면 **예상된 동작** |
| 모든 디바이스에서 요소의 픽셀 크기가 동일함 | Offset 전용 크기라면 **예상된 동작** — 단, **화면을 넘치면 경고** |
| 작은 화면에서 요소가 사라짐 | **의도된 동작일 수 있음**(반응형 숨김) — 사용자에게 보고하되 단정하지 말 것 |
| 이전에는 겹치지 않던 요소가 겹침 | 하나가 의도된 오버레이(더 높은 ZIndex)가 아니라면 **버그일 가능성이 큼** |
| 작은 디바이스에서 텍스트가 잘림 | **경고로 표시** — 글꼴 크기 조정 또는 줄바꿈이 필요할 수 있음 |

### 스크린샷

`screen_capture` MCP 도구로 뷰포트를 캡처하세요. 에이전트는 이미지를 비전으로 직접 보고 분석합니다. 스크린샷은 디스크에 저장되지 않으며, 에이전트의 시각적 분석이 주된 출력입니다.

### 정확한 요소 위치 얻기

**스크린샷을 눈으로만 보고 위치를 추측하지 마세요.** 항상 Luau로 실제 GUI 요소 위치를 먼저 조회하세요.

**1단계: 디바이스 전환 후 요소 위치 조회**(StarterGui 요소는 편집 모드에서 작동).

스크린샷은 `workspace.CurrentCamera.ViewportSize`가 나타내는 영역을 정확히 캡처합니다. StarterGui 요소의 `AbsolutePosition`은 이미 뷰포트 픽셀 좌표계를 사용하므로 별도의 오프셋 계산이 필요 없습니다.

```lua
local sg = game:GetService("StarterGui")
local vpSize = workspace.CurrentCamera.ViewportSize
local results = {}
table.insert(results, "VIEWPORT|" .. string.format("%.0fx%.0f", vpSize.X, vpSize.Y))

for _, screenGui in sg:GetChildren() do
    if screenGui:IsA("ScreenGui") and screenGui.Enabled then
        local function collect(obj, path)
            if obj:IsA("GuiObject") and obj.Visible then
                local p = obj.AbsolutePosition
                local s = obj.AbsoluteSize
                table.insert(results, path .. "|" .. string.format("%.0f,%.0f,%.0f,%.0f", p.X, p.Y, p.X + s.X, p.Y + s.Y))
            end
            for _, child in obj:GetChildren() do
                if child:IsA("GuiBase2d") then collect(child, path .. "." .. child.Name) end
            end
        end
        collect(screenGui, screenGui.Name)
        break
    end
end
return table.concat(results, "\n")
```

다음과 같은 줄이 반환됩니다.

```
VIEWPORT|734x372
RaceHUD.BottomBar|0,329,734,372
RaceHUD.BottomBar.BestLap|0,329,170,372
```

첫 번째 줄은 `workspace.CurrentCamera.ViewportSize`에서 가져온 뷰포트 크기입니다. 그다음 줄부터는 **뷰포트 픽셀 좌표계**의 `이름|x1,y1,x2,y2` 형식입니다.

**이 방식이 작동하는 이유:** `AbsolutePosition`은 뷰포트 원점을 기준으로 하며 스크린샷도 같은 뷰포트를 캡처합니다. 따라서 오프셋이 필요 없습니다. 좌표가 음수이거나 ViewportSize를 넘어가는 요소는 화면 밖에 있는 것이며 잘림 문제가 발생합니다.

**보고 방법:** 텍스트 출력에 정확한 초과값을 포함하세요. 예: "Rank 라벨의 오른쪽 끝이 x=754까지 뻗지만 뷰포트 너비는 748이므로 오른쪽으로 6px 넘칩니다."

**중요:** AbsolutePosition은 편집 모드의 StarterGui 요소에서만 사용할 수 있습니다. 플레이 모드에서는 `screen_capture`와 시각적 분석을 대안으로 사용하거나, 미리 배치한 검증 스크립트(고급 섹션 참고)를 사용해 콘솔 출력에서 위치를 얻으세요.

### 검증 출력 형식

```
UI 검증: <디바이스 이름>

  디바이스: <이름> (<너비>x<높이>)
  뷰포트: <뷰포트_크기>
  콘솔: 오류 없음

  관찰 결과:
  - 타이머 라벨("00:00")이 상단 중앙에 있고 완전히 보임
  - 점수 패널이 뷰포트 안에 맞음
  - 잘림이나 겹침이 감지되지 않음
```

여러 디바이스를 비교할 때는 요약 표를 포함하세요.

```
| 디바이스           | 해상도    | 뷰포트    | 문제                      |
| --- | --- | --- | --- |
| iPhone 17 Pro     | 874x402   | 750x362    | 없음                      |
| iPad Pro M5 (13in)| 1376x1032 | 1376x1012  | 없음                      |
| Xbox One          | 1920x1080 | 1920x1080  | 점수 텍스트가 약간 작음   |
```

---

## 고급: 미리 배치하는 검증 스크립트

시각적 확인만이 아니라 **프로그래밍 방식의 검증**이 필요한 테스트 플레이스에서는 이 LocalScript를 `StarterPlayerScripts`에 넣으세요. 플레이 시 실행되어 구조화된 데이터를 콘솔에 출력하며, 에이전트는 `get_console_output`으로 이를 읽습니다.

```lua
-- StarterPlayerScripts._DeviceVerifier (LocalScript)
task.wait(2)
local player = game:GetService("Players").LocalPlayer
local pg = player:WaitForChild("PlayerGui", 5)
if not pg then print("[VERIFY] ERROR: No PlayerGui") return end

local vp = workspace.CurrentCamera.ViewportSize
local issues = 0

local function check(obj, path)
    if not obj:IsA("GuiObject") or not obj.Visible then return end
    local pos = obj.AbsolutePosition
    local size = obj.AbsoluteSize
    print("[VERIFY] " .. path .. "|" .. string.format("%.0f,%.0f|%.0f,%.0f", pos.X, pos.Y, size.X, size.Y))

    if pos.X + size.X > vp.X + 2 or pos.Y + size.Y > vp.Y + 2 or pos.X < -2 or pos.Y < -2 then
        issues += 1
        print("[VERIFY] ISSUE OFF-SCREEN: " .. path)
    end
    if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and not obj.TextFits then
        issues += 1
        print("[VERIFY] ISSUE TEXT-TRUNCATED: " .. path)
    end
    if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and (size.X < 44 or size.Y < 44) then
        issues += 1
        print("[VERIFY] ISSUE SMALL-TARGET: " .. path .. " " .. tostring(size))
    end
    for _, child in obj:GetChildren() do
        check(child, path .. "." .. child.Name)
    end
end

for _, sg in pg:GetChildren() do
    if sg:IsA("ScreenGui") and sg.Enabled then
        for _, child in sg:GetChildren() do
            check(child, sg.Name .. "." .. child.Name)
        end
    end
end
print("[VERIFY] DONE vp:" .. tostring(vp) .. " issues:" .. issues)
```

에이전트는 `get_console_output`으로 결과를 읽고 `[VERIFY]`가 포함된 줄만 필터링합니다.

> 이 스크립트는 선택 사항입니다. 대부분의 검증은 스크린샷만으로도 충분합니다. 시각적 판단보다 정확한 수치(`AbsolutePosition`, `AbsoluteSize`)가 필요할 때 사용하세요.

---

---

## `/device-compare` 실행 예시

사용자: "휴대전화, 태블릿, 콘솔에서 내 UI를 비교해 줘"

에이전트 출력(Racing 템플릿):

```
게임 설정: LandscapeSensor | ScreenInsets=CoreUISafeInsets | IgnoreGuiInset=false

UI 구조:
  RaceGui [ScreenGui] — RaceInfoFrame(랩 카운터 + 타이머), CountdownLabel,
  CheckpointFrame, FinishFrame(고정 너비 600px), LeaderboardFrame(헤더 700px)

| 디바이스            | 해상도    | 뷰포트    | 문제                                  |
| --- | --- | --- | --- |
| Samsung Galaxy A06  | 800x360   | 705x338    | HUD가 화면 너비의 약 99%를 차지함     |
| iPhone 17 Pro       | 874x402   | 750x362    | 없음                                  |
| iPad Pro M5 (13in)  | 1376x1032 | 1376x1012  | HUD 텍스트가 작아짐                   |
| Xbox One            | 1920x1080 | 1920x1080  | TV/소파 환경에서 타이머 텍스트가 작음 |

발견 사항:
  ⚠️ Galaxy A06: HUD가 거의 전체 너비를 차지함 — 작은 뷰포트에서는 크기를 줄이는 방식을 고려
  ❌ Xbox One: 소파 거리에서 타이머 라벨을 읽기 어려움 — 콘솔용 UIScale 사용을 고려
  ⚠️ CoreUISafeInsets는 노치를 처리하지 못함 — iPhone X 이상에서는 DeviceSafeInsets 사용을 고려
  ❌ FinishFrame.ImageLabel은 600px 고정 크기 — Galaxy A06(뷰포트 705px)에서 넘칠 수 있음

```

---

## StudioDeviceSimulatorService — API 명세

디바이스 시뮬레이터 Lua API와 작업 흐름의 전체 참조 문서입니다.

### 디바이스 시뮬레이션이란?

Roblox Studio에는 게임 뷰포트의 크기를 실제 디바이스 화면 해상도에 맞게 조절하는 **디바이스 시뮬레이터**가 있습니다. 실제 휴대전화에서 실행하는 것은 아니며, Studio가 뷰포트를 렌더링하는 방식을 변경해 해당 디바이스에서 게임이 어떻게 보일지 미리 볼 수 있게 합니다.

디바이스를 활성화하면(예: 874x402 해상도의 iPhone 17 Pro) Studio는 다음과 같이 동작합니다.

1. 뷰포트 크기를 해당 해상도로 변경
2. 새로운 `Camera.ViewportSize`를 기준으로 게임 UI 레이아웃을 다시 계산
3. 해당 디바이스의 플레이어가 보게 될 화면을 표시

시뮬레이션을 중지하면 뷰포트가 Studio의 기본 크기로 돌아갑니다.

### 생명주기

```
시뮬레이션 없음("default")
  │
  ├── SetDeviceAsync(id) ──→ 디바이스 활성화(뷰포트 = 디바이스 해상도)
  │                              │
  │                              ├── SetOrientationAsync() ──→ 뷰포트 회전
  │                              ├── SetResolutionAsync() ──→ 디바이스 해상도 재정의
  │                              ├── SetPixelDensityAsync() ──→ DPI 재정의
  │                              └── SetScalingModeAsync() ──→ Studio 안에서 뷰포트를 맞추는 방식 변경
  │
  ├── SetDeviceAsync("default") 또는 StopSimulationAsync() ──→ 시뮬레이션 없음으로 복귀
  │
  └── SetOrientationAsync() ──→ 저장되며 이후 디바이스가 활성화될 때 적용
```

### 디바이스 프리셋과 재정의 값

- **디바이스 프리셋** = Width, Height, PixelDensity가 고정된 이름 있는 디바이스(예: "iPhone 17 Pro" = 874x402 @ 460dpi)
- **재정의 값** = 디바이스 활성화 후 해상도와 DPI를 변경할 수 있음
- `SetDeviceAsync`는 해상도와 DPI 재정의 값을 **초기화**합니다(디바이스 기본값으로 복귀).
- `SetOrientationAsync`는 재정의 값을 초기화하지 **않습니다**.
- `SetScalingModeAsync` 값은 **계속 유지**되며 어떤 작업으로도 자동 초기화되지 않습니다.

### 일반적인 흐름

```lua
local svc = game:GetService("StudioDeviceSimulatorService")

-- 1. 사용 가능한 디바이스 목록 가져오기(ID는 동적이므로 절대 하드코딩하지 말 것)
local devices = svc:GetDeviceListAsync()

-- 2. 표시 이름으로 디바이스 찾기
for _, id in devices do
    local info = svc:GetDeviceInfoAsync(id)
    if info.Name == "iPhone 17 Pro" then

        -- 3. 디바이스 활성화(뷰포트 크기가 변경됨)
        svc:SetDeviceAsync(id)
        task.wait(0.2)  -- 뷰포트가 갱신될 때까지 반드시 기다릴 것

        -- 4. 결과 읽기
        print(workspace.CurrentCamera.ViewportSize)  -- 예: 750, 362
        break
    end
end
```

핵심 규칙:

- **항상 이름으로 검색** — 디바이스 ID는 표시 이름이 아니라 `"iphone_17_pro"` 같은 내부 문자열입니다.
- **모든 setter 호출 뒤에 항상 `task.wait(0.2)` 실행** — 뷰포트 갱신은 비동기 방식입니다.
- **`GetDeviceAsync()`로 확인** — 활성 디바이스 ID를 반환하며, 시뮬레이션 중이 아니면 `"default"`를 반환합니다.

---

### 서비스

```lua
local svc = game:GetService("StudioDeviceSimulatorService")
-- 보안: 플러그인 컨텍스트에서만 사용 가능(execute_luau MCP 도구로 호출)
```

#### 핵심 패턴: 이름으로 디바이스를 찾은 뒤 활성화

디바이스 ID는 표시 이름이 아니라 `"iphone_17_pro"` 같은 내부 문자열입니다. 항상 `Name`으로 검색하세요.

```lua
local svc = game:GetService("StudioDeviceSimulatorService")
local devices = svc:GetDeviceListAsync()
for _, id in devices do
    local info = svc:GetDeviceInfoAsync(id)
    if info.Name == "iPhone 17 Pro" then
        svc:SetDeviceAsync(id)
        task.wait(0.2)
        break
    end
end
```

#### 중요: 모든 메서드는 비동기 방식

모든 메서드는 호출한 코루틴을 양보합니다(디바이스 상태가 Lua와 다른 스레드에 존재하기 때문). 오류가 발생할 수 있는 메서드는 항상 `pcall`로 감싸세요.

```lua
local ok, err = pcall(function()
    svc:SetDeviceAsync("nonexistent_id")
end)
if not ok then warn(err) end
```

---

### 메서드

| 메서드 | 반환값 | 참고 사항 |
| --- | --- | --- |
| `GetDeviceListAsync()` | `{string}` | 디바이스 ID 문자열 배열(아래 예시 참고) |
| `GetDeviceInfoAsync(id)` | `table` | 디바이스 메타데이터(아래 예시 참고) |
| `SetDeviceAsync(id)` | — | `"default"`는 시뮬레이션을 중지함. **해상도 + DPI 재정의 값을 초기화함.** |
| `GetDeviceAsync()` | `string` | 활성 ID 또는 `"default"` |
| `StopSimulationAsync()` | — | 시뮬레이션 중지(`SetDeviceAsync("default")`보다 권장) |
| `SetOrientationAsync(ori)` | — | 아래 열거형 값 참고. 디바이스가 활성화되기 전에 호출해 미리 설정할 수 있음. |
| `GetOrientationAsync()` | `Enum.ScreenOrientation` | |
| `SetResolutionAsync(w, h)` | — | 1–7680 × 1–4320. 가로 화면 기준 형식으로 w가 더 긴 변이어야 함. **활성 디바이스 필요.** |
| `GetResolutionAsync()` | `Vector2` | **활성 디바이스 필요**(없으면 오류). |
| `SetPixelDensityAsync(dpi)` | — | 72–10000. Camera.ViewportSize가 아니라 위젯의 물리적 크기를 제어함. **활성 디바이스 필요.** |
| `GetPixelDensityAsync()` | `number` | **활성 디바이스 필요.** |
| `SetScalingModeAsync(mode)` | — | 아래 열거형 값 참고. **활성 디바이스 필요. SetDeviceAsync 이후에도 유지됨.** |
| `GetScalingModeAsync()` | `Enum.DeviceSimulatorScalingMode` | **활성 디바이스 필요.** |
| `CreateDeviceAsync(config)` | `string` | DeviceId = Name을 반환. 아래 설정 표 참고. |
| `UpdateDeviceAsync(id, config)` | — | 사용자 지정 디바이스에서만 가능. 활성 상태라면 변경 내용이 즉시 적용됨. |
| `RemoveDeviceAsync(id)` | — | 사용자 지정 디바이스에서만 가능. 활성 상태라면 먼저 자동으로 비활성화됨. |

---

### 열거형 값(Luau에서 다음 정확한 경로 사용)

**화면 방향:**

```lua
Enum.ScreenOrientation.LandscapeLeft   -- 기본 가로 화면
Enum.ScreenOrientation.LandscapeRight
Enum.ScreenOrientation.Portrait
```

**크기 조절 모드:**

```lua
Enum.DeviceSimulatorScalingMode.FitToWindow        -- Studio 위젯에 맞게 뷰포트 크기 조절(기본값, 가장 일반적)
Enum.DeviceSimulatorScalingMode.ActualResolution    -- 1:1 픽셀 매핑, 위젯보다 클 수 있음
Enum.DeviceSimulatorScalingMode.ScaleToPhysicalSize -- DPI를 사용해 모니터에서의 물리적 크기 계산
```

| 모드 | 사용 시점 |
| --- | --- |
| `FitToWindow` | 기본값. Studio에 맞게 뷰포트 크기를 조절함. 대부분의 테스트에 적합. |
| `ActualResolution` | 정확한 픽셀을 확인할 때 사용. 픽셀 단위로 정밀한 UI 검사에 유용함. 고해상도 디바이스에서는 Studio 위젯을 넘칠 수 있음. |
| `ScaleToPhysicalSize` | DPI를 사용해 모니터에서 실제 디바이스의 물리적 크기를 시뮬레이션함. `SetPixelDensityAsync`가 시각적으로 영향을 주는 유일한 모드. |

**DeviceForm:**

```lua
Enum.DeviceForm.Phone    -- CreateDeviceAsync의 기본값
Enum.DeviceForm.Tablet
Enum.DeviceForm.Desktop
Enum.DeviceForm.Console
Enum.DeviceForm.VR
```

---

### 반환값 예시(검증 완료)

#### GetDeviceListAsync

표시 이름이 아니라 내부 ID 문자열 배열을 반환합니다.

```lua
{"iphone_XR", "iphone_11", "iphone_13", "iphone_16", "iphone_17_pro", "ipad_10th_generation", "ipad_pro_M4_11in", "ipad_pro_M5_13in", "samsung_galaxy_a06", "samsung_galaxy_s25_ultra", "meta_quest_3", "xbox", ...}
```

#### GetDeviceInfoAsync

```lua
{
    DeviceId = "iphone_17_pro",        -- 내부 ID(SetDeviceAsync에서 사용)
    Name = "iPhone 17 Pro",            -- 표시 이름(이름 매칭에 사용)
    Width = 874,
    Height = 402,
    PixelDensity = 460,
    ResolutionScale = 3,
    DeviceForm = Enum.DeviceForm.Phone, -- Phone, Tablet, Desktop, Console, VR
    IsCustom = false,
    PortraitKeyboardHeight = 306,
    LandscapeKeyboardHeight = 181,
}
```

> **참고:** `SafeAreaInsets`는 이 표의 필드가 아닙니다(테스트로 확인됨).

---

### DeviceConfiguration 표

`GetDeviceInfoAsync`(읽기), `CreateDeviceAsync`(생성), `UpdateDeviceAsync`(수정)에서 사용됩니다.

| 필드 | 유형 | 생성/수정 | 설명 |
| --- | --- | --- | --- |
| `DeviceId` | string | 읽기 전용 | 고유 식별자(사용자 지정 디바이스에서는 Name과 같음) |
| `Name` | string | 필수 | 표시 이름, 1~200자, `"default"`는 사용할 수 없음 |
| `Width` | number | 필수 | 화면 너비(픽셀), 1–7680 |
| `Height` | number | 필수 | 화면 높이(픽셀), 1–4320 |
| `PixelDensity` | number | 필수 | DPI, 72–10000 |
| `DeviceForm` | Enum.DeviceForm | 선택 사항(기본값: Phone) | `Phone`, `Tablet`, `Desktop`, `Console`, `VR` 중 하나 |
| `IsCustom` | boolean | 읽기 전용 | 사용자가 만든 디바이스인지 여부 |
| `ResolutionScale` | number | 선택 사항(기본값: 1.0) | 해상도 배율, 0보다 커야 하며 최대 10.0 |
| `PortraitKeyboardHeight` | number | 선택 사항(기본값: 0) | 세로 화면의 키보드 높이 |
| `LandscapeKeyboardHeight` | number | 선택 사항(기본값: 0) | 가로 화면의 키보드 높이 |

예시 — 사용자 지정 태블릿 만들기 및 수정:

```lua
local id = svc:CreateDeviceAsync({
    Name = "My Custom Tablet",
    Width = 2560,
    Height = 1600,
    PixelDensity = 300,
    DeviceForm = Enum.DeviceForm.Tablet,
})
svc:SetDeviceAsync(id)

-- 나중에 수정
svc:UpdateDeviceAsync(id, {
    Name = "My Custom Tablet",  -- 모든 필수 필드를 포함해야 함
    Width = 2732,
    Height = 2048,
    PixelDensity = 264,
    DeviceForm = Enum.DeviceForm.Tablet,
})

-- 정리
svc:StopSimulationAsync()
svc:RemoveDeviceAsync(id)
```

참고 사항:

- `"default"`는 예약어이므로 `CreateDeviceAsync`에서 오류가 발생합니다.
- 기본 제공 프리셋은 변경할 수 없습니다. `UpdateDeviceAsync`/`RemoveDeviceAsync`는 사용자 지정 디바이스에서만 작동합니다.
- 사용자 지정 디바이스는 디스크에 저장되어 Studio를 다시 시작해도 유지됩니다.

---

### ConfigurationChanged 이벤트

```lua
svc.ConfigurationChanged:Connect(function()
    -- 콜백에 전달되는 매개변수 없음
    -- 다음 작업에서 발생: SetDeviceAsync, SetOrientationAsync, SetResolutionAsync,
    --                    SetPixelDensityAsync, SetScalingModeAsync, StopSimulationAsync,
    --                    RemoveDeviceAsync(활성 디바이스인 경우),
    --                    그리고 사용자의 디바이스 시뮬레이터 UI 조작
    -- 다음 작업에서는 발생하지 않음: CreateDeviceAsync, 비활성 디바이스에 대한 UpdateDeviceAsync/RemoveDeviceAsync
    -- 참고: 핸들러 내부의 getter 호출은 비동기 방식이며 실행을 양보함
    local deviceId = svc:GetDeviceAsync()
    if deviceId ~= "default" then
        local res = svc:GetResolutionAsync()
        print(string.format("Device: %s @ %dx%d", deviceId, res.X, res.Y))
    end
end)
```

---

### 호출 순서

```
SetOrientationAsync  → 언제든 가능(사전 설정 의미이며 다음 활성화 때 적용되도록 저장됨)
SetDeviceAsync       → 언제든 가능(디바이스 활성화, 해상도 + DPI 재정의 값 초기화)
SetResolutionAsync   → 활성 디바이스 필요(없으면 오류)
SetPixelDensityAsync → 활성 디바이스 필요(없으면 오류)
SetScalingModeAsync  → 활성 디바이스 필요(독립적으로 유지되며 자동 초기화되지 않음)
```

**권장 순서:** `SetOrientationAsync` → `SetDeviceAsync` → `SetResolutionAsync`(필요한 경우)

---

### 상태 지속성

| 속성 | SetDeviceAsync로 초기화됨? | StopSimulationAsync로 초기화됨? |
| --- | --- | --- |
| 해상도 재정의 값 | 예 | 예 |
| DPI 재정의 값 | 예 | 예 |
| 화면 방향 | 아니요(유지됨) | 아니요 |
| 크기 조절 모드 | **아니요(계속 유지됨)** | **아니요** |
| 사용자 지정 디바이스 | 아니요(디스크에 저장됨) | 아니요 |

---

### 알려진 제한 사항

1. **모든 메서드는 비동기 방식** — 모든 호출은 호출한 코루틴을 양보합니다. 디바이스 상태는 Lua와 다른 스레드에 있습니다. 호출 실패 가능성이 있다면 항상 `pcall`로 감싸세요.
2. **`"default"`는 특수 값** — `SetDeviceAsync("default")`는 시뮬레이션을 중지합니다. 절대 `GetDeviceInfoAsync("default")`를 호출하지 마세요.
3. **디바이스 ID는 동적** — 항상 `GetDeviceListAsync()`로 목록을 가져와 이름으로 검색하세요. 하드코딩하지 마세요.
4. **모든 setter 뒤에 `task.wait(0.2)` 실행** — 뷰포트 갱신은 비동기 방식입니다.
5. **getter도 활성 디바이스가 필요함** — 활성 디바이스가 없으면 `GetResolutionAsync`, `GetPixelDensityAsync`, `GetScalingModeAsync` 모두 오류가 발생합니다.
6. **PlayServer는 모든 setter를 차단함** — `SetDeviceAsync`, `StopSimulationAsync`, `SetOrientationAsync`, `SetResolutionAsync`, `SetPixelDensityAsync`, `SetScalingModeAsync`에서 모두 오류가 발생합니다. getter와 비활성 디바이스에 대한 CRUD 작업은 영향을 받지 않습니다. 편집 모드와 PlayClient에서 작업하세요.
7. **해상도 + DPI 재정의 값은 세션 단위** — 지속되지 않으며 `SetDeviceAsync` 호출 시 초기화됩니다.
8. **ScalingMode는 유지됨** — 어떤 작업으로도 자동 초기화되지 않으며 `SetDeviceAsync`도 예외가 아닙니다.
9. **기본 제공 프리셋은 변경 불가** — `UpdateDeviceAsync`/`RemoveDeviceAsync`는 사용자 지정 디바이스에서만 작동합니다.
10. **해상도는 가로 화면 기준 형식** — `SetResolutionAsync(w, h)`에서 현재 화면 방향과 관계없이 w는 더 긴 변, h는 더 짧은 변입니다.
11. **DPI는 뷰포트가 아니라 위젯 크기를 제어함** — `SetPixelDensityAsync`는 `Camera.ViewportSize`가 아니라 모니터에 표시되는 뷰포트 위젯의 물리적 크기를 바꿉니다. `ScaleToPhysicalSize` 모드에서만 시각적 차이가 나타납니다.
12. **Camera.ViewportSize ≠ GetResolutionAsync()** — ViewportSize는 화면 방향, 크기 조절 모드, 안전 영역의 영향을 받습니다. 결정적인 검증에는 `GetDeviceAsync()`를 사용하세요.

---

### 오류 처리

모든 메서드에서 오류가 발생할 수 있으므로 항상 `pcall`을 사용하세요.

```lua
local ok, err = pcall(function()
    svc:SetResolutionAsync(1920, 1080)
end)
if not ok then
    warn("SetResolutionAsync failed:", err)
end
```

| 오류 | 원인 | 해결 방법 |
| --- | --- | --- |
| "service not enabled" | API를 사용할 수 없음 | 사용자에게 Studio 빌드를 확인하라고 안내 |
| "no active device" | 디바이스를 활성화하지 않고 setter/getter 호출 | 먼저 `SetDeviceAsync` 호출 |
| 플레이 모드의 setter 오류 | PlayServer 컨텍스트에서 호출 | 플레이 진입 전에 디바이스를 설정하거나 PlayClient 탭으로 전환 |
| "default" is not a valid device | `GetDeviceInfoAsync("default")`를 호출함 | 호출 전 `GetDeviceAsync() ~= "default"`인지 확인 |

---

## 명령어별 작업 흐름

아래 섹션은 사용자가 슬래시 명령어(예: `/scene-health`, `/vi-click`)로 호출할 수 있는 작업 흐름의 예시를 설명합니다. 각 섹션은 이 스킬의 특정 사용 사례 하나를 위한 참조 자료입니다. 사용자가 해당 명령어를 호출했을 때 일치하는 섹션을 읽고, 그 외에는 배경 정보로 취급하세요. 이 스킬을 사용하는 모든 상호작용에서 반드시 따라야 하는 단계는 아닙니다.

### `/device-test`

Studio 디바이스 시뮬레이터를 사용해 특정 디바이스에서 UI를 테스트합니다.

#### 수행할 작업

1. Studio에 연결합니다. 여러 인스턴스가 열려 있다면 먼저 `list_roblox_studios`와 `set_active_studio`를 호출하세요.

2. **테스트할 대상 결정** — StarterGui 트리 순회를 실행합니다(이 문서의 "UI 탐색" 참고).
   - 사용자가 이미 대상을 지정했거나, ScreenGui가 하나뿐이거나, 뷰포트에 UI가 보이면 **바로 진행**합니다.
   - StarterGui가 비어 있거나 모든 요소가 `Visible=false`이거나, 서로 구분되는 화면이 여러 개인데 사용자가 대상을 지정하지 않았을 때만 **질문**합니다.

3. **적절한 디바이스 찾기** — 디바이스 목록을 읽고(이 문서의 "디바이스 전환" 참고) 사용자 요청에 따라 선택합니다.
   - 정확한 디바이스 이름 → 이름으로 일치시키기
   - "iPhone" / "phone" / "mobile" → 가장 최신 `Phone`(세대 숫자가 가장 큼)
   - "tablet" / "iPad" → 가장 최신 `Tablet`
   - "console" / "Xbox" → 이름에 "Xbox"가 포함된 항목
   - "VR" / "Quest" → 이름에 "Quest" 또는 "Meta"가 포함된 항목
   - 일치하는 항목이 없으면 **사용자에게 질문**

4. `execute_luau`로 **디바이스를 전환**합니다(이 문서의 코드 예시 참고). 이후 항상 `task.wait(0.2)`를 실행하세요.

5. `screen_capture` MCP 도구로 **스크린샷을 촬영**합니다. 잘림, 겹침, 텍스트 잘림, 요소 누락, 누르기에는 너무 작은 버튼이 있는지 시각적으로 분석하세요.

6. **문제를 발견했다면 정확한 위치를 확인**합니다. 이 문서의 "정확한 주석 좌표 얻기" 섹션에 있는 뷰포트 좌표 조회 코드를 사용하세요. 뷰포트를 넘는 요소의 위치를 보고합니다.

7. `get_console_output`으로 오류를 확인합니다.

8. **사용자에게 보고:**

```
디바이스: <이름> (<너비>x<높이>)
뷰포트: <뷰포트_크기>
콘솔: 오류 없음

관찰 결과:
- ...
```

문제가 있었다면 해결 제안도 포함하세요.

1. **기본 상태로 복귀** — `execute_luau`로 `StopSimulationAsync()`를 호출합니다. 사용자에게 "Studio를 기본 뷰포트로 초기화했습니다."라고 알리세요.

#### 기본값

- **화면 방향:** 사용자가 세로 화면을 명시적으로 요청하지 않는 한 항상 가로 화면
- **디바이스 선택:** 항상 디바이스 목록을 동적으로 읽고, 일치하는 DeviceForm에서 세대 숫자가 가장 큰 모델 선택
- 전체 Luau 코드 예시와 API 세부 사항은 이 문서를 참고하세요.

### `/device-compare`

각 디바이스로 차례로 전환하고 스크린샷을 촬영한 뒤 결과를 나란히 제시하여 여러 디바이스의 UI를 비교합니다.

#### 수행할 작업

1. Studio에 연결합니다. 여러 인스턴스가 열려 있다면 먼저 `list_roblox_studios`와 `set_active_studio`를 호출하세요.

2. **테스트할 대상 결정** — StarterGui 트리 순회를 실행합니다(이 문서의 "UI 탐색" 참고).
   - 사용자가 이미 대상을 지정했거나, ScreenGui가 하나뿐이거나, 뷰포트에 UI가 보이면 **바로 진행**합니다.
   - StarterGui가 비어 있거나 모든 요소가 `Visible=false`이거나, 서로 구분되는 화면이 여러 개인데 사용자가 대상을 지정하지 않았을 때만 **질문**합니다.
   - 모든 UI가 런타임에 생성된다면 대신 `/device-playtest` 작업 방식을 사용하세요.

3. **디바이스 목록 읽기** — 이 문서의 "디바이스 전환" 섹션에 있는 디바이스 목록 조회 코드를 사용합니다. 약 4~5개 디바이스를 선택하세요.
   - **휴대전화:** 가장 최신 `Phone`(세대 숫자가 가장 큼)
   - **태블릿:** 가장 최신 `Tablet`(세대 숫자가 가장 큼)
   - **콘솔:** 아무 `Console` 디바이스
   - **VR:** "Quest" 또는 "Meta"와 일치하는 디바이스(있는 경우)
   - **저사양:** 전체 목록에서 해상도가 가장 낮은 디바이스
   - 사용자가 특정 디바이스를 지정했다면 해당 디바이스를 대신 사용

4. **각 디바이스에서:** `execute_luau`로 전환하고 `task.wait(0.2)`를 실행한 뒤 `screen_capture`로 캡처합니다. 화면을 시각적으로 분석하세요.

5. **문제를 발견했다면 정확한 위치를 확인**합니다. 이 문서의 "정확한 주석 좌표 얻기" 섹션에 있는 뷰포트 좌표 조회 코드를 사용하세요. 뷰포트를 넘는 요소를 정확한 픽셀 값과 함께 보고합니다.

6. **사용자에게 보고** — 요약 표:

```
| 디바이스       | 해상도    | 뷰포트    | 문제                      |
| --- | --- | --- | --- |
| <휴대전화>     | ...       | ...        | ...                       |
| <태블릿>       | ...       | ...        | ...                       |
| <콘솔>         | ...       | ...        | ...                       |
| <저사양>       | ...       | ...        | ...                       |
```

1. 발견한 각 문제를 해결 제안과 함께 설명합니다.
2. **기본 상태로 복귀** — `execute_luau`로 `StopSimulationAsync()`를 호출합니다. 사용자에게 "Studio를 기본 뷰포트로 초기화했습니다."라고 알리세요.

#### 중요

- 디바이스 목록은 동적으로 바뀌므로 항상 최신 목록을 읽고 DeviceForm + 해상도를 기준으로 선택하세요.
- `SetDeviceAsync`는 해상도/DPI 재정의 값을 초기화하지만 `SetScalingModeAsync`는 디바이스를 바꿔도 **계속 유지**됩니다.
- 모든 디바이스의 기본 화면 방향은 **가로 화면**입니다.
- 전체 작업 흐름, Luau 코드 예시, 주석 좌표 참조는 이 문서를 확인하세요.

### `/device-orientation`

하나의 디바이스에서 가로 화면과 세로 화면을 모두 테스트하고 비교용 스크린샷을 촬영합니다.

#### 수행할 작업

1. Studio에 연결합니다. 여러 인스턴스가 열려 있다면 먼저 `list_roblox_studios`와 `set_active_studio`를 호출하세요.

2. **게임이 세로 화면을 지원하는지 확인** — `StarterGui.ScreenOrientation`을 읽습니다.
   - `LandscapeSensor` / `LandscapeLeft` / `LandscapeRight` → **이 게임은 가로 화면 전용이라고 사용자에게 알립니다.** 그래도 진행할지 물어보세요.
   - `Sensor` → 두 화면 방향 모두 지원하므로 진행합니다.
   - `Portrait` → 세로 화면 전용이므로 가로 화면 테스트를 건너뜁니다.

3. 활성 디바이스가 없다면 디바이스 목록에서 가장 최신 `Phone`(세대 숫자가 가장 큼)을 선택합니다. `execute_luau`로 전환하세요.

4. **두 화면 방향 캡처:**

   a. `execute_luau`로 **가로 화면** 설정:

   ```lua
   local svc = game:GetService("StudioDeviceSimulatorService")
   svc:SetOrientationAsync(Enum.ScreenOrientation.LandscapeLeft)
   task.wait(0.2)
   return "Orientation: " .. tostring(svc:GetOrientationAsync()) .. " | Viewport: " .. tostring(workspace.CurrentCamera.ViewportSize)
   ```

   b. `screen_capture` — 가로 화면 레이아웃 분석

   c. `execute_luau`로 **세로 화면** 설정:

   ```lua
   local svc = game:GetService("StudioDeviceSimulatorService")
   svc:SetOrientationAsync(Enum.ScreenOrientation.Portrait)
   task.wait(0.2)
   return "Orientation: " .. tostring(svc:GetOrientationAsync()) .. " | Viewport: " .. tostring(workspace.CurrentCamera.ViewportSize)
   ```

   d. `screen_capture` — 세로 화면 레이아웃 분석

5. `get_console_output`으로 오류를 확인합니다.

6. **보고:**

```
화면 방향 테스트: <디바이스 이름>

| 화면 방향 | 뷰포트 | 문제 |
| --- | --- | --- |
| 가로      | WxH    | ...  |
| 세로      | WxH    | ...  |
```

1. 시각적 차이를 해결 제안과 함께 보고합니다.

2. **가로 화면으로 복귀** — `SetOrientationAsync(Enum.ScreenOrientation.LandscapeLeft)`를 호출한 뒤 `StopSimulationAsync()`를 실행합니다. 사용자에게 "화면 방향을 가로로 초기화했습니다."라고 알리세요.

#### 핵심 사실

- `SetOrientationAsync`는 해상도/DPI 재정의 값을 초기화하지 않습니다.
- 세로 화면에서는 `Camera.ViewportSize`의 축이 바뀌어 X < Y가 됩니다.
- `GetResolutionAsync()`는 항상 가로 화면 기준 값을 반환하므로 ViewportSize와 같다고 단정하지 마세요.
- 기본적으로 `LandscapeLeft`를 사용하고, 사용자가 명시적으로 요청한 경우에만 `LandscapeRight`를 사용하세요.
- 전체 API 참조는 이 문서를 확인하세요.

### `/device-playtest`

플레이 모드에서 특정 디바이스의 UI를 테스트하여 게임의 런타임 UI가 대상 디바이스 해상도에서 제대로 작동하는지 검증합니다.

#### 수행할 작업

1. Studio에 연결합니다. 여러 인스턴스가 열려 있다면 먼저 `list_roblox_studios`와 `set_active_studio`를 호출하세요.

2. **플레이 모드에 들어가기 전에 디바이스를 설정**합니다. 사용자가 디바이스를 지정했다면 해당 디바이스를 사용하세요. 그렇지 않으면 디바이스 목록에서 가장 최신 `Phone`(세대 숫자가 가장 큼)을 선택합니다. `execute_luau`로 전환하세요(이 문서의 "디바이스 전환" 참고).

3. `start_stop_play`로 플레이 모드에 들어갑니다.

4. 게임 초기화를 기다린 뒤(약 5~8초) `screen_capture`로 스크린샷을 촬영하고 시각적으로 분석합니다.

5. `get_console_output`으로 런타임 오류를 확인합니다.

6. (선택 사항) 사용자가 상호작용 테스트를 요청한 경우:
   - `user_mouse_input`으로 버튼 클릭 — **moveTo와 click 사이에 100~200ms 대기 시간 추가**
   - `user_keyboard_input`으로 입력 흐름 테스트
   - 상호작용 후 스크린샷을 한 번 더 촬영

7. `start_stop_play`로 플레이 모드를 종료합니다.

8. **기본 상태로 복귀** — `execute_luau`로 `StopSimulationAsync()`를 호출합니다. 사용자에게 "Studio를 기본 뷰포트로 초기화했습니다."라고 알리세요.

9. **보고:**

```
플레이 모드 테스트: <디바이스> (<너비>x<높이>)

  뷰포트: <뷰포트_크기>
  콘솔: 오류 없음

  관찰 결과:
  - ...
```

문제가 있었다면 해결 제안도 포함하세요.

#### 핵심 제약 사항

- **PlayServer 상태에서는 모든 setter 메서드에서 오류가 발생함** — 플레이 모드에 들어가기 전에 반드시 디바이스를 설정해야 합니다.
- getter 메서드는 모든 게임 상태에서 작동합니다.
- 플레이 모드에서는 `execute_luau`가 `PlayerGui`나 `AbsolutePosition`에 접근할 수 없으므로 시각적 검증에는 `screen_capture`를 사용하세요.
- **user_mouse_input:** 잘못된 대상을 클릭하지 않도록 moveTo와 click 사이에 대기 시간을 추가하세요.
- 전체 API 참조와 미리 배치하는 검증 스크립트는 이 문서의 고급 섹션을 확인하세요.
