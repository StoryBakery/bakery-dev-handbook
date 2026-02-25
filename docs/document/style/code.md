---
title: 코드 작성 스타일
---

## 코드 블록

- 코드 블록은 펜스 코드 블록(```` ``` ````)을 사용합니다.
- 가능한 경우 언어 식별자를 명시합니다.

````md
```lua
local part = Instance.new("Part")
part.Parent = workspace
```
````

## 줄바꿈 이스케이프

대부분의 명령줄 스니펫은 터미널에 직접 복사하여 붙여넣기 위한 것이므로, 줄바꿈을 이스케이프하는 것이 가장 좋습니다.
줄 끝에 백슬래시 하나를 사용하세요:

````md
```shell
$ bazel run :target -- --flag --foo=longlonglonglonglongvalue \
  --bar=anotherlonglonglonglonglonglonglonglonglonglongvalue
```
````

## 목록 내 코드 블록

목록 내에 코드 블록이 필요한 경우, 목록이 깨지지 않도록 들여쓰기를 해야 합니다.

````md
- Bullet

  ```lua
  local part = Instance.new("Part")
  part.Parent = workspace
  ```

- Next bullet
```
