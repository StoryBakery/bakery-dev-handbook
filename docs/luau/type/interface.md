---
title: 인터페이스
---

luau 에는 `interface` 란 타입 명시자는 없지만 `type` 로 테이블로 정의해 인터페이스를 만들 수 있습니다.

## read 와 write

read-only 인 속성은 앞에 `read` 를 붙일 수 있으며,
write-only 인 속성은 앞에 `write` 를 붙여 구분할 수 있습니다.

쓰기만 가능한 `write` 는 드물며, 보통 외부에서 주입만 받고 읽기는 허용하지 않는 입력 속성이나,
읽기 타입과 쓰기 타입을 다르게 제한해야 하는 인터페이스에서 사용합니다.

```luau
type Interface = {
    read StartTime: number,
    read EndTime: number,

    read CurrentTarget: Instance?,
    write CurrentTarget: BasePart,
}

이를 통해 외부에서 넣을 수 있는 값과, 외부가 읽을 때 기대해야 하는 값을 분리할 수 있습니다.

예를 들어 `CurrentTarget` 은 설정할 때는 `BasePart` 만 받지만,
읽을 때는 아직 대상이 없을 수 있으므로 `Instance?` 로 다룹니다.

타입임으로 런타임 강제성이 있지 않습니다
