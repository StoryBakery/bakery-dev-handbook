---
title: 키
---

키는 번역할 텍스트를 구분하는 고유한 식별자입니다.

## 키는 목적을 설명합니다

키는 텍스트의 내용이 아닌 **목적이나 위치**를 설명합니다.
텍스트의 내용을 키로 하면, 원문 텍스트가 바뀔 때 키도 바꿔야하는 문제가 생깁니다.

**Bad**:

```csv
Key,Source,en-us
Hello,안녕하세요!,Hello!
```

**Good**:

```csv
Key,Source,en-us
Greet,안녕하세요!,Hello!
```

## 점 표기법으로 계층을 나타냅니다

점(`.`)을 사용해 키에 계층 구조를 부여합니다.
이를 통해 키가 어느 기능, 화면, 요소에 속하는지 쉽게 파악할 수 있습니다.

```csv
Key,Source,en-us
Shop.Title,상점,Shop
Shop.Buy,구매,Buy
Shop.Sell,판매,Sell
```

### 깊이는 2 - 5 단계를 권장합니다

점 표기법의 깊이는 보통 2 - 5 단계까지가 적절합니다.
과도하게 깊어지면 가독성이 떨어지므로, 번역 맥락을 구분하는 데 필요한 단계만 사용합니다.

키가 지나치게 깊어진다면, 먼저 키 구조를 다시 검토합니다.
필요한 경우에만 기능이나 문맥 단위로 로컬리제이션 테이블을 분리합니다.

**Bad**:

`UILocalization.ko-kr.csv`:

```csv
Key,Source,en-us
UI.HUD.Player.Status.Health.Label,체력,Health
```

**Good**:

`HudLocalization.ko-kr.csv`:

```csv
Key,Source,en-us
HUD.HealthLabel,체력,Health
```

## 키 케이싱은 PascalCase 를 사용합니다

각 단계의 이름은 PascalCase 를 사용합니다.

```csv
Key,Source,en-us
MainMenu.PlayButton,플레이,Play
Settings.MasterVolume,마스터 볼륨,Master Volume
```

## 같은 원문이라도 맥락이 다르면 키를 분리합니다

같은 원문 텍스트라도 서로 다른 맥락에서 쓰인다면 별도의 키를 만듭니다.
언어마다 문법이 달라서, 맥락에 따라 번역이 달라질 수 있기 때문입니다.

**Bad**:

```csv
Key,Source,en-us
Save,저장,Save
```

위 키 하나로 설정 메뉴의 "저장"과 게임플레이의 "구출" 을 모두 처리하면,
번역 시 구분이 불가능합니다.

**Good**:

```csv
Key,Source,en-us
Settings.Save,저장,Save
Gameplay.SavePerson,구출,Save
```

## 초기 개발시엔 임의의 키를 허용합니다

초기 개발 단계에서는 빠른 구현을 위해 임시 키를 사용할 수 있습니다.

임시 키는 `Temp.{Context}.{Number}` 형식을 사용합니다.

```csv
Key,Source,en-us
Temp.HUD.001,체력,Health
Temp.Inventory.001,획득,Get
```

임시 키는 최종 구조가 아니며, 기능과 문맥이 정리되면 목적이 드러나는 정식 키로 교체합니다.
번역 작업을 시작하기 전에는 임시 키를 정리합니다.

초기 개발 단계에서는 빠른 구현을 위해 임시 키를 사용할 수 있습니다.
단, 임시 키는 최종 구조가 아니며, 기능과 문맥이 정리되면 추후 목적이 드러나는 키로 정리합니다.
