---
title: 링크 작성 스타일
---

긴 링크는 소스 마크다운을 읽기 어렵게 만들고 80자 줄 바꿈 규칙을 깨뜨립니다. 가능한 한 링크를 짧게 하세요.

## 경로 표기

경로를 표기할 때 확장자를 포함합니다.

```md
[문서](../path/to/page.md)
```

또한 현재 문서의 자식인 경우 `./` 를 작성하며, 생략하지 않습니다.

## 외부 링크

외부 사이트는 일반 마크다운 링크를 사용합니다.

```md
[Creator Dashboard](https://create.roblox.com/dashboard/creations)
[Blender](https://www.blender.org/)
```

## 내부 문서 링크

내부 문서는 상대 경로를 사용합니다.
절대 경로는 사용하지 않습니다.

```md
[Meshes](../parts/meshes.md)
[Merch Booth](../resources/modules/merch-booth.md)
```

## 유익한 마크다운 링크 제목 사용

마크다운 링크 문법을 사용하면 링크 제목을 설정할 수 있습니다.
사용자는 보통 문서를 꼼꼼히 읽지 않고, 빠르게 훑어봅니다.

링크는 시선을 사로잡습니다. 하지만 링크의 제목을 "여기", "링크"라고 지정하거나 단순 대상 URL을 복제하는 것은 서두르는 독자에게 어떠한 정보도 주지 못하며 공간만 낭비할 뿐입니다:

```md
<!-- <!-- DO NOT DO THIS. --> -->

자세한 내용은 마크다운 가이드를 확인하세요: [링크](markdown.md), 또는 스타일 가이드를 확인하세요 [여기](style.md).

일반적인 테스트 결과를 확인해 보세요:
[https://example.com/foo/bar](https://example.com/foo/bar).
```

대신, 문장을 자연스럽게 작성한 다음 돌아가서 가장 적절한 구문을 링크로 감싸세요:

```md
자세한 내용은 [마크다운 가이드](markdown.md)를 확인하거나,
[스타일 가이드](style.md)를 확인해 보세요.

[일반적인 테스트 결과](https://example.com/foo/bar)를 확인해 보세요.
```

## 참조 링크

긴 링크나 이미지 URL의 경우, 다음과 같이 링크 사용 부분과 링크 정의 부분을 분리하는 것이 좋습니다:

```md
문서를 더 읽기 쉽게 만드는 제안 사항이 있는 [마크다운 스타일 가이드][style]를 참조하세요.

[style]: http://Markdown/corp/Markdown/docs/reference/style.md
```

단 충분히 긴 경우에만 사용해야합니다.

참조 링크는 표에서 자주 사용됩니다.
예를 들어, 다음 테이블은 인라인 링크로 인해 가독성이 악화되었습니다:

```md
<!-- DO NOT DO THIS. -->

| 사이트                                                            | 설명 |
| ---------------------------------------------------------------- | ----------------------- |
| [site 1](http://google.com/excessively/long/path/example_site_1) | 이것은 예시 사이트 1입니다. |
| [site 2](http://google.com/excessively/long/path/example_site_2) | 이것은 예시 사이트 2입니다. |
```

대신, 참조 링크를 사용하여 가로 길이를 다루기 쉽게 유지하세요:

```md
| 사이트 | 설명 |
| -------- | ----------------------- |
| [site 1] | 이것은 예시 사이트 1입니다. |
| [site 2] | 이것은 예시 사이트 2입니다. |

[site 1]: http://google.com/excessively/long/path/example_site_1
[site 2]: http://google.com/excessively/long/path/example_site_2
```

마찬가지로, 참조 링크도 유용한 제목을 사용해야 합니다.

```md
[일반적인 테스트 결과][Test Result]를 확인해 보세요.

[Test Result]: https://example.com/foo/bar
```

### 중복을 줄이기 위해 참조 링크 사용

문서 내에서 동일한 링크 대상을 여러 번 참조할 때 중복을 줄이려면 참조 링크 사용을 고려하세요.

### 처음 사용한 후에 참조 링크 정의

참조 링크 정의는 다음 헤딩 바로 앞, 해당 링크가 처음으로 사용된 섹션의 끝에 두는 것을 권장합니다.
만약 여러분의 에디터가 이 정의를 배치할 위치에 대해 자체적인 규칙을 가지고 있다면 맞춰서 바꾸려 하지 마세요. 도구가 항상 우선합니다.

두 헤딩 사이의 모든 텍스트를 "섹션"으로 정의합니다.
참조 링크를 각주처럼 생각하고, 현재 섹션을 현재 페이지처럼 생각하세요.

이러한 배치는 주변 텍스트의 흐름을 깔끔하게 유지하면서 소스 뷰에서 링크 대상을 확인하기 쉽게 만들어 줍니다.
참조 링크가 매우 많은 긴 문서에서는 파일 끄트머리에 생기는 "각주 과부하(footnote overload)"를 예방하여, 관련 링크 대상을 찾기 어려워지는 상황을 방지합니다.

이 규칙에는 한 가지 예외가 있습니다: 여러 섹션에서 공통으로 사용되는 참조 링크 정의는 문서의 끝에 위치해야 합니다.
이렇게 하면 섹션이 수정되거나 이동될 때 링크가 끊어지는 것을 방지할 수 있습니다.

```md
# 제목

[링크][link_def]가 있는 일부 텍스트.

동일한 [링크][link_def]가 있는 추가적인 텍스트.

[link_def]: http://reallyreallyreallylonglink.com

## Header 2

... 많은 텍스트 ...

## Header 3

[다른 링크][different_link_def]를 사용하는 추가적인 텍스트.

[different_link_def]: http://differentreallyreallylonglink.com
```

## 참조

- [Google Style Guides - Links](https://google.github.io/styleguide/docguide/style.html#links)
