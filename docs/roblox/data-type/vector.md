---
title: 벡터
---

## 성능이 중요하다면 `Vector3` 라이브러리 대신 `vector` 네이티브 라이브러리를 사용해요

`luau` 는 이제 보다 최적화를 위해 `vector` 라이브러리를 도입했습니다.

대부분의 연산에서 `vector` 라이브러리가 `Vector3` 보다 `1x, 2x` 정도 빠릅니다.

## 안티 패턴

### `Dot` 로 `Magnitude` 의 제곱 구하기 는 성능적으로 우위가 없어요

로블록스에서는 `Magnitude` 에 최적화를 했는지,
`vector:Dot(vector)` 와 `vector.Magnitude` 에 성능적으로 큰 차이가 없습니다.

보다 가벼운 성능으로 크기를 구하기 위해 `vectorA:Dot(vectorA)` 를 사용할 필요는 없습니다.
