---
title: 입력 표시
---

## 키보드 키코드 표시는 `GetStringForKeyCode` 을 사용해요

키보드에는 대표적으로 두 종류가 있습니다, 그 외도 많고요.

- `QWERTY` (메인)
- `AZERTY`

로블록스는 AZERTY 키보드의 키 입력을 QWERTY 위치에 맞춰 바뀝니다.
(`A` 를 누르면 `Q` 를 누른 걸로 인식)

각기 다른 키보드의 해당하는 키 이름을 얻으려면, `UserInputService:GetStringForKeyCode()` 를 사용합니다.

`[M]을 눌러 지도를 여시오.` 를 AZERTY 키보드에선 다른 문자열이기에, 바꿔야 합니다.

```csv
Key,Source
Map.Hint,[{ActionKeyCode}]을 눌러 지도를 여시오.
```

```luau
textLabel.Text = translator:FormatByKey("Map.Hint", {
    ActionKeyCode = UserInputService:GetStringForKeyCode(inputBinding.KeyCode)
})
```
