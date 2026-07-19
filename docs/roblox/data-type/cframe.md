---
title: CFrame
---

`CFrame` 은 로블록스에서 회전과 위치를 나타내는 데이터입니다.
변환행렬의 일종이지만, 로블록스에선 `CFrame` 이 스케일은 다루지 않습니다.
(일부 클래스에는 먹히는 경우가 있고 그걸로 효과도 만드나 해키한 트릭이라 일반적으로 다뤄지지 않음)

## 생성자

`CFrame` 생성자는 크게 위치, 방향, 회전행렬을 직접 지정하는 방식으로 나뉩니다.

일반적인 코드에서는 다음 생성자를 주로 사용합니다.

- `CFrame.new()` — 항등 `CFrame`
- `CFrame.new(position)` — 회전 없는 위치
- `CFrame.new(x, y, z)` — 회전 없는 위치
- `CFrame.lookAt(position, target)` — 특정 위치를 바라보는 방향
- `CFrame.Angles(rx, ry, rz)` — 회전
- `CFrame.fromMatrix(...)` — 축 벡터나 회전행렬을 통한 생성

쿼터니언이나 회전행렬의 각 성분을 직접 받는 `CFrame.new` 오버로드는 저수준 작업이 아닌 이상 자주 사용하지 않습니다.

### 항등 CFrame

```luau
local identity = CFrame.new()
```

위치는 `(0, 0, 0)`이고 회전이 없는 항등 `CFrame`을 생성합니다.

다만 항등값이라는 의도를 더 명확하게 나타내려면 `CFrame.identity`를 사용하는 편이 좋습니다.

```luau
local identity = CFrame.identity
```

행렬 곱셈에서 항등값으로 동작합니다.

```luau
print((CFrame.identity * someCFrame):FuzzyEq(someCFrame)) --> true
```

### 위치로 생성

```luau
const cframe = CFrame.new(Vector3.new(10, 5, 3))
```

또는 각 위치 성분을 직접 전달할 수 있습니다.

```luau
const cframe = CFrame.new(10, 5, 3)
```

두 방식 모두 회전이 없는 `CFrame`을 생성합니다.
이미 `Vector3` 위치값이 있다면 그대로 전달하고, 개별 좌표값을 가지고 있다면 숫자 오버로드를 사용합니다.

### 특정 위치를 바라보도록 생성

과거에는 다음 생성자가 사용되었습니다.

```luau
local cframe = CFrame.new(position, target)
```

첫 번째 위치에 존재하면서 두 번째 위치를 바라보는 `CFrame`을 생성합니다.

현재는 이 오버로드보다 `CFrame.lookAt`을 사용합니다.

```luau
local cframe = CFrame.lookAt(position, target)
```

기본적으로 월드 공간의 `(0, 1, 0)`을 위쪽 방향으로 취급합니다.
다른 위쪽 방향이 필요하다면 세 번째 인자로 `up` 벡터를 전달합니다.

```luau
local cframe = CFrame.lookAt(position, target, Vector3.zAxis)
```

### 위치와 쿼터니언으로 생성

```luau
local cframe = CFrame.new(x, y, z, qx, qy, qz, qw)
```

위치와 쿼터니언을 이용해 `CFrame`을 생성합니다.

쿼터니언은 `(qx, qy, qz, qw)` 순서이며, 유효한 회전을 나타내려면 단위 길이여야 합니다.
단위 길이가 아니라면 생성 과정에서 정규화됩니다.

쿼터니언을 직접 다루는 시스템과 데이터를 주고받거나, 보간 또는 회전 수학을 직접 구현할 때 주로 사용합니다.

### 위치와 회전행렬로 생성

```luau
local cframe = CFrame.new(
	x, y, z,
	R00, R01, R02,
	R10, R11, R12,
	R20, R21, R22
)
```

위치와 3×3 회전행렬의 각 성분을 직접 전달합니다.

$$
\begin{bmatrix}
R00 & R01 & R02 \\
R10 & R11 & R12 \\
R20 & R21 & R22
\end{bmatrix}
$$

예를 들어 항등 회전행렬은 다음과 같습니다.

```luau
print(
    CFrame.new(10, 5, 3) == CFrame.new(
        10, 5, 3,
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    )
) --> true
```

세 축 벡터를 가지고 있다면 `CFrame.fromMatrix`를 사용하는 편이 좋습니다.

```luau
const cframe = CFrame.fromMatrix(
	position, xVector, yVector, zVector
)
```

로블록스의 `CFrame`에서 세 번째 축은 `LookVector`의 반대 방향인 `BackVector`에 해당합니다.

```luau
const backVector = -lookVector

const cframe = CFrame.fromMatrix(
	position,
	rightVector,
	upVector,
	backVector
)
```

회전행렬을 직접 구성할 때는 각 축이 서로 수직이고 단위 길이인 정규직교 기저가 되도록 해야 합니다.

행렬을 직접 만드는 패턴은 효율적일 때나 행렬 트릭을 적용해야할 때만
사용하는 것이 좋습니다, 크게 가독성이 좋지 않기 때문.

### 위치와 회전 조합

위치와 회전을 함께 만들 때는 각각의 생성자를 곱해 표현하는 것이 읽기 좋습니다.

```luau
const cframe = CFrame.new(10, 5, 3) * CFrame.Angles(0, math.pi / 2, 0)
```

생성 과정이 복잡해진다면 의미 있는 지역변수로 분리하는 편이 좋습니다.

```luau
local spawnPosition = CFrame.new(spawnPoint.Position)
local characterRotation = CFrame.Angles(0, spawnYaw, 0)

local characterCFrame = spawnPosition * characterRotation
```

## 수학 연산자를 최대한 활용해요

행렬 연산이라고 하지만, CFrame 의 상대적 이동(곱셈)과 절대적 이동(더하기), 역행렬 그리고 순서의 영향만 알면,
굉장히 쉬운 수학 중 하나입니다.

그렇기에 보기 좋은 코드는 수학 연산을 대신해주는 메서드가 아닌, `*` 와 `+`, `Inverse` 등을 쓰는 코드가 낫습니다.
그리고 그 결과값을 좋은 이름이나, 좋은 함수로 묶는 것이 좋아요.

굳이 사용할 필요 없는 메서드:

- `ToWorldSpace`, `ToObjectSpace`
- `VectorToWorldSpace`, `VectorToObjectSpace`
- `PointToWorldSpace`, `PointToObjectSpace`

## 행렬적 접근

`CFrame` 은 개념적으론 행렬입니다.
(진짜 4x4 행렬로 저장하는 것이 아니라 모호한 동작이 있긴 합니다, 대표적인 예시가 스케일이 대부분 안됨)

`:GetComponents()` 을 통해
`x`, `y`, `z`, `R00`, `R01`, `R02`, `R10`, `R11`, `R12`, `R20`, `R21`, `R22` 를 얻을 수 있습니다.
`:components()` 또한 동일한 값들을 내놓지만, `PascalCase` 인 `GetComponents` 사용이 더 일관적입니다.

`Orthonormalize()` 를 통해 회전행렬을 직교할 수 있습니다.
`BasePart.Size` 등과 같은 일부 속성은 엔진이 자동으로 `:Orthonormalize` 를 하며,
클라이언트에서 전송하는 게 아닌 이상, 따로 검증용으로 쓸 필요는 없습니다, 과도한 분기 생성 중 하나만 될 뿐입니다.
드문 상황에서 정상 회전행렬로 만들어야할 때 사용하는 편.

## 괄호

행렬의 덧셈과 곱셈은 결합법칙이 성립해서, 계산 순서만 묶는 괄호는 결과에 영향을 주지 않습니다.
(물론 괄호는 실제 연산에 끝자리의 소수점 차이는 발생합니다)

하지만 그런 식에서도 어떤 묶음인지는 나타낼 수 있습니다.
가장 좋은 것은 또 다른 지연변수로 묶는 것이나,
아주 마이크로 최적화가 중요한 경우나 지역변수를 만들 수 없는 경우에서, 괄호를 묶음 용도로 사용합니다.

또한 `Inverse` 와 같은 메서드 호출이 필요한 경우 괄호를 사용합니다.

## 회전

### 회전 생성자

`Angles` 를 중심적으로 사용합니다.

`fromEulerAnglesXYZ` 는 `Angles` 와 같기에 순서를 명시해야하는 목적이 아닌 이상 일반적으로 사용하지 않습니다.

`fromOrientation` 도 마찬가지로 `fromEulerAnglesYXZ` 로 순서를 강조하는 것이 더 좋습니다.

그 외의 순서를 명시해야하는 경우
`fromEulerAngles(rx: number, ry: number, rz: number, order: Enum.RotationOrder)` 을 사용합니다

### 회전 순서

`CFrame.Angles` 와 같이 `Enum.RotationOrder.XYZ` 가 기본값입니다.

로블록스의 속성창은 CFrame 속성은 `Orientation` (YXZ 순서)으로 보여주지만,
회전 순서는 상황에 맞게 하되 기본적으로 `CFrame.Angles`, XYZ 순서를 기본으로 사용합니다.

### 각도 구하기

`ToEulerAngles(order: Enum.RotationOrder): number, number, number` 부터해서,
`ToOrientation`, `ToEulerAnglesXYZ`, `ToEulerAnglesYXZ` 를 통해 구할 수 있습니다.

## 비교는 FuzzyEq 를 사용해요

`CFrame` 은 회전이나 위치에서, 실수값이 아주 많이 써지기에, 실제 비교는 `==` 가 아닌
`FuzzyEq(other: CFrame, epsilon: number?)` 메서드를 사용합니다.

```luau
-- Bad:
const isEqualAToB = someCFrame == someCFrame2

-- Good:
const isEqualAToB = someCFrame:FuzzyEq(someCFrame2)
```

## 그 외 유용한 메서드들

- `AngleBetween(other:CFrame): number`: 각도를 반환합니다.
- `ToAxisAngle(): Vector3, number`: 쿼터니언 등을 만들 때 사용

## 예시 패턴

`CFrame` 을 쓰면서 자주 사용되는 패턴의 모읍집입니다.

### 오프셋

```lua
local offsetFromCFrame1ToCFrame2InLocal = cframe1:Inverse() * cframe2 -- cframe1 기준의 오프셋
local offsetFromCFrame1ToCFrame2InWorld = cframe2 * cframe1:Inverse() -- 월드축 기준의 오프셋
```

풀이:

$$
\begin{aligned}
\texttt{offsetFromCFrame1ToCFrame2InLocal}
&:= \texttt{cframe1:Inverse()} * \texttt{cframe2}, \\[6pt]
\texttt{cframe1} * \texttt{offsetFromCFrame1ToCFrame2InLocal}
&= \texttt{cframe1} * \bigl(\texttt{cframe1:Inverse()} * \texttt{cframe2}\bigr) \\
&= \bigl(\texttt{cframe1} * \texttt{cframe1:Inverse()}\bigr) * \texttt{cframe2} \\
&= \texttt{CFrame.identity} * \texttt{cframe2} \\
&= \texttt{cframe2}.
\end{aligned}
$$

$$
\begin{aligned}
\texttt{offsetFromCFrame1ToCFrame2InWorld}
&:= \texttt{cframe2} * \texttt{cframe1:Inverse()}, \\[6pt]
\texttt{offsetFromCFrame1ToCFrame2InWorld} * \texttt{cframe1}
&= \bigl(\texttt{cframe2} * \texttt{cframe1:Inverse()}\bigr) * \texttt{cframe1} \\
&= \texttt{cframe2} * \bigl(\texttt{cframe1:Inverse()} * \texttt{cframe1}\bigr) \\
&= \texttt{cframe2} * \texttt{CFrame.identity} \\
&= \texttt{cframe2}.
\end{aligned}
$$

### 절대값 회전

B를 기반으로 A를 R만큼 절대 회전

```lua
local A = CFrame.new(ax, ay, az)
local B = CFrame.new(bx, by, bz)
local T = A:Inverse() * B
local R = CFrame.Angles(0, math.pi / 2, 0) -- rotate 90 degrees counterclockwise about the up vector of B
local NewCFrame = A * T * R * T:Inverse()
```

### CFrame 변화를 각속도 벡터로 변환하기

```lua
-- 월드축 기준 각속도
local deltaRotation = currentCFrame * lastCFrame:Inverse()

local axis, angle = deltaRotation:ToAxisAngle()
local angularVelocity = axis * angle / dt
```

## 오류 케이스

### NAN 출력 오류

`CFrame` 연산시 `NAN` 출력 오류가 자주 나오는 경우가 많습니다.

가장 좋은 해결책은 이런 케이스가 안나게 상황을 조정하는 것입니다,
과도한 분기를 생성해 에러를 해결하는 것은 바람직하지 않습니다.
애초에 그럴 일이 없도록 하는 것이 좋습니다.

그럼에도 필연적으로 에러가 날 수 있는 상황에서만 분기 케이스를 사용합니다.

그 중 대표적인 케이스는 다음과 같습니다

**같은 위치를 바라보는 CFrame 출력**

이 경우 위치값은 보존됩니다.

```luau
print( CFrame.new(Vector3.one, Vector3.one) )
--> 1, 1, 1, NAN, NAN, NAN, NAN, NAN, NAN, NAN, NAN, NAN

print( CFrame.lookAt(Vector3.one, Vector3.one) )
--> 1, 1, 1, NAN, NAN, NAN, NAN, NAN, NAN, NAN, NAN, NAN
```

만일 겹칠 수 있는 상황이 발생할 수 있다면:

```luau
const cframeLookAtTarget = if position ~= target
    then CFrame.lookAt(position, target)
    else CFrame.new(position)
```

:::note
`Vector3` 와 `CFrame` 은 `X` `Y` `Z` 성분은 `float32` 로 동일하기에,
겹침 에러 방지 목적으론 단순하게 성능적 우위로 `==` 나 `~=` 로 비교해도 괜찮습니다.
해당 케이스에서 무조건적으로 `FuzzyEq` 나 `offset.Magnitude` 를 사용할 필욘 없습니다.
:::

혹은 안정화를 고려한다면:

```luau
const offset = position - target

const cframeLookAtTarget = if offset.Magnitude > 1e-10
	then CFrame.lookAt(position, target)
	else CFrame.new(position)

-- 만약 CFrame을 연속해서 계속 구하는 타입의 시뮬레이션인 경우
-- previousCFrame 의 Rotation 을 따라가게해도 괜찮습니다
-- 다양한 패턴 중 하나일 뿐
const cframeLookAtTarget = if offset.Magnitude > 1e-10
	then CFrame.lookAt(position, target)
	else previousCFrame.Rotation + position
```

**잘못된 행렬에 정상 행렬을 곱하는 경우**

위치값은 보존되었다해도, 회전값은 보존되었다해도, `NAN` 이 들어가있는 `CFrame` 을 조작했다면
정상 성분도 `NAN` 이 되기도 합니다

```luau
print( CFrame.new(Vector3.one, Vector3.one) * CFrame.new(0,0,5) )
--> NAN, NAN, NAN, NAN, NAN, NAN, NAN, NAN, NAN, NAN, NAN, NAN
```
