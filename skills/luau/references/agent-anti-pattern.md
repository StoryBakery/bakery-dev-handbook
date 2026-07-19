---
title: 에이전트 안티 패턴
---

Luau 와 로블록스 에는 쓰레기같은 관습이 많습니다,
그렇기에 Luau 와 로블록스를 분리하고 커뮤니티 전반에 펼쳐진 쓰레기 관습을 따라하지 않으려고 에이전트는 노력해야합니다.
과추론적인 에러 감싸기 보다 직관적인 코드가 100배 낫습니다.

## Luau 는 로블록스에만 국한된 언어가 아닙니다

## script 는 테이블이 아닙니다

`if type(script) == "table" then` 에서 `script` 는 인스턴스이기에 `table` 도 아닐 뿐더러 `userdata` 입니다.
다음과 같은 관습은 의미없습니다.

애초에 타겟을 확실하게 정하는 것이 좋고, 멀티타겟인 패키지의 경우에만 분기로 `if script then` 을 사용하는 것입니다.

## require 값이 이상할 수 있는 분기는 사용하지 않습니다

```luau
-- Bad:
const function getPromise()
	if promiseModule ~= nil then
		return promiseModule
	end

	if type(script) == "table" then
		const ok, result = pcall(function()
			return require("../../roblox_packages/promise")
		end)
		if ok then
			promiseModule = result
		end
	end

	if promiseModule == nil then
		promiseModule = {
			Status = {
				Resolved = "Resolved",
			},
			is = function(value: any): boolean
				return type(value) == "table" and type(value.awaitStatus) == "function"
			end,
		}
	end

	return promiseModule
end

-- Good:
const promise = require("../../roblox_packages/promise")
```
