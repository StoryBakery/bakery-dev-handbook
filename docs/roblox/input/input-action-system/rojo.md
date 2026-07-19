---
title: Rojo 에서 IAS
---

주로 `*.model.json` 으로 표현합니다.

```json5
{
  "ClassName": "InputAction",
  "Children": [
    {
      "Name": "keyboardBinding",
      "ClassName": "InputBinding",
      "Properties": {
        "KeyCode": "E"
      }
    },
    {
      "Name": "gamepadBinding",
      "ClassName": "InputBinding",
      "Properties": {
        "KeyCode": "ButtonX"
      }
    },
    {
      "Name": "mouseBinding",
      "ClassName": "InputBinding",
      "Properties": {
        "KeyCode": "MouseLeftButton"
      }
    }
  ]
}
```
