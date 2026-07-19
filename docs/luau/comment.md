---
title: 주석
---

3줄 이하는 `--`, 그 이상은 `--[[ ... ]]` 을 사용합니다.

API 문서화가 필요한 경우에만 moonwave 스타일(`--[=[ ... ]=]`)을 사용합니다.
문서화가 필요하지 않은 스크립트에선 절대로 `--[=[ ... ]=]` 를 사용하지 않습니다.

## 구두점 여부

문장이면 붙이고 조각이면 안 붙입니다.

```luau
-- Retry because the API may return stale data.
fetchAgain()

-- cache key
const key = `{userId}:{date}`

-- default: 10
const limit = 10
```
