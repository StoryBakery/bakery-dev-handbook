---
title: 게임패드
---

## 키코드

ButtonL1/R1 은 가까운 상단 버튼 (클릭형)
ButtonL2/R2 는 보다 멀리있는 상단 버튼입니다 (힘세기 감지)

L2 와 R2 는 입력이 세기에 따라 `InputObject` 에서는 `Change` 로 바뀝니다
꾹 누르면 `Begin`, 살살 때면 `Change`, 완전히 떼야 `End` 가 됩니다.
IAS 에서도 마찬가지로 세기에 따라 값이 정해집니다.

ButtonL3/R3 는 조이스틱를 아예 눌렀을 경우 발동합니다.

Thumbstick1 왼쪽 조이스틱, Thumbstick2 오른쪽 조이스틱 입니다.

## 동작 매핑

ButtonR2 는 주로 툴이나 클릭으로 쓰입니다.
특히 세기를 감지할 수 있어 총기류로 강도가 점점 세게 만드는 등 여러 조작이 가능합니다.

ButtonL1/R1 은 툴 교체에 쓰입니다, 1번 2번 3번... 툴을 선택하는 등.
여러개의 툴 지원이나 무기 교체가 없는 게임에서는 다른 동작으로 교체할 수 있습니다.

Thumstick1 은 움직임에 쓰이며, Thumbstick2 은 카메라 움직임에 사용됩니다

ButtonR3 는 카메라 축소/확대에 쓰이지만, 쉬프트락 활성키로 사용해도 괜찮습니다.

ButtonA 는 점프키로 사용되지만, 카메라를 움직이면서 누르기 어렵기에 R1 으로 교체하기도 합니다.

DpadUp/Down/Left/Right 의 키들은 따로 매핑된 동작이 없습니다.
Left/Right 를 툴 교체에 사용하거나, Up/Down 을 따로 특수동작으로 매핑하기도 합니다.

## 연결된 게임패드는 여러개 있을 수 있습니다

물론 로블록스는 게임패드를 하나만으로 가정하고 게임을 만드는 것이 일반적이기에 거의 쓰이지 않는 기능입니다.

`UserInputService:GetConnectedGamepads()` 를 통해 연결된 게임패드들을 전부 얻을 수 있습니다.

UserInputType 배열로 `{UserInputType.GamePad1, UserInputType.GamePad2}` 등으로 반환됩니다.

`GetGamepadConnected(UserInputType.Gamepad[n])` 을 통해 게임 패드가 연결되었는지 확인 가능합니다

## 입력

`UserInputService:GetGamepadState(UserInputType.Gamepad[n])` 는 해당 게임패드에서 사용가능한 모든 입력의 `InputObject` 배열을 반환합니다.

`GetImageForKeyCode` 는 현재 연결된 디바이스에 대한 키의 이미지를 반환합니다.

커스텀 이미지를 보여주려면 `GetStringForKeyCode` 으로 통해 얻은 문자열에 맞는 이미지를 보여주게해야합니다.
키코드 매핑이 다를 수 있기 때문입니다.
