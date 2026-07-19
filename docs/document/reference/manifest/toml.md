---
title: toml 표기법
---

manifest 를 작성할 때 확장자로 `*.toml` 을 자주 사용합니다.
`toml` 형식의 파일을 문서로 설명할 때 어떻게 작성해야 하는지에 대한 가이드입니다.

## 섹션은 대괄호로 감싸 헤딩으로 표시합니다

`toml` 의 섹션은 대괄호를 포함한 그대로 헤딩으로 옮깁니다.

```toml
[package]
name = "Package"
version = "0.1.0"
```

```md
## [package]
```

중첩된 섹션도 동일합니다.

```toml
[target.dev.dependencies]
```

```md
## [target]

### [dev]

#### [dependencies]
```

## 섹션 아래의 키-값 쌍은 상세한 설명이 필요한 경우 헤딩, 그렇지 않은 경우 테이블로 표시합니다

키 하나에 대해 별도의 설명, 제약, 예시가 필요하다면 헤딩으로 풀어 설명합니다.

단순히 어떤 필드가 있는지만 전달하면 충분하다면 테이블로 정리합니다.

```md
## [package]

package 섹션에 대한 간략한 설명

| 이름 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `name` | `string` | - | 패키지의 이름 |
| `version` | `string` | - | 패키지의 버전 |

package 섹션에 대한 상세한 설명 및 속성에서 더 이어서 할 수 있는 상세한 설명
```

하나의 섹션 안에서 일부 키만 상세 설명이 필요하다면,
중요한 키만 헤딩으로 설명하고 나머지는 테이블로 함께 정리합니다.

```md
## [package]

package 섹션에 대한 간략한 설명

| 이름 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `enabled` | `boolean` | `false` | - 을 합니다. |
| `another` | `string` | - | - 을 합니다. |

package 섹션에 대한 상세한 설명 및 속성에서 더 이어서 할 수 있는 상세한 설명

### source

source 는 따로 뺀 만큼 더 상세한 설명을 적을 수 있습니다.

### [workspace]

package.workspace 에 대한 간략한 설명

| 이름 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| members | array<string> | - | - 을 합니다. |

#### anotherKey

anotherKey 에 대한 상세한 설명
```
