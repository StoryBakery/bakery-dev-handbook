---
title: 로블록스 안티 패턴
---

로블록스의 대부분 코드들은 '스파게티 코드' 혹은 정돈하지 않고도 어떤 상황에서도
쓸 수 있게 만들어진 코드들이 많습니다

그것이 미숙한 개발자들에게 개발 경험이 좋을지라도,
과거의 관습을 과하게 사용한다거나, 하드코딩된 접근방식을 취하는 경우가 대부분입니다.

그것을 따라하려고하지말고 정돈된 개발 스타일로 사용합니다.

## 과도한 분기 패턴은 지양합니다

```luau
-- Bad:
-- character 가 r6 인지 r15 인지, HumanoidRigDescription 으로 접근가능한지
-- 그리고 미숙한 개발자를 위해 Humanoid 로도 줄 수 있음까지 가정한
-- 상당히 분기를 작성하는 코드

const torso =
    character:FindFirstChild("Torso")
    or character:WaitForChild("Torso", 1)
    or character:FindFirstChild("UpperTorso")
    or character:WaitForChild("UpperTorso", 1)
    or character.Parent:FindFirstChild("UpperTorso")
    or character.Parent:WaitForChild("UpperTorso", 1)
    or character.PrimaryPart

-- Good:
const torso = character.UpperTorso
```
