---
title: Attribute
---

## Attribute 는 잘게 나눕니다

한 Attribute 안에 너무 많은 데이터를 우겨 넣기보다, 여러개로 나눠 저장하는 것을 추천합니다.

### 문자열 Attribute 는 타입명이나 중간 정도 길이의 값만 저장합니다

서버 권한 모델에서는 `NextGenerationReplication` 를 활성화해야합니다.
기존 동작과 달리, Attribute 는 `string` 타입의 값이 50자를 초과한다면 에러가 발생합니다.

에딧 모드에서 문자열 값의 길이가 50자를 초과하는 Attribute 가 있다면,
`Removed invalid attribute 'AttributeName' from instance InstanceName` 을 출력하며
서버에서도 클라이언트에서도 지워버립니다.

`StringValue.Value` 는 `simulationAccess` 임과 동시에 문자 길이 제한이 없어서
서버권한 모델이 일반적이게 된 만큼 상당한 크기의 문자열을 저장해야하는 경우,
`Attribute` 보다 `StringValue` 를 따로 만들어서 저장하는 걸 추천합니다.
