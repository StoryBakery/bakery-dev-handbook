---
title: 로블록스 패키지 테스트하기
---

이 문서는 로블록스 패키지를 만들 때의 테스트 작성법에 대해 다룹니다.

기본적인 내용은 [luau 패키지 테스트하기](../luau-package/test.md)를 따릅니다.

## 권장 구조

기본 구조는 다음과 같습니다.

```sh
Package/
  .github/
    workflows/
      ci.yml
  src/
    init.luau
    Submodule.luau
  scripts/
    runRobloxTests.luau
  tests/
    init.luau
    TestUtil.luau
    Submodule.spec.luau
  playground/
    project/
      default.project.json
      src/
  pesde.toml
  default.project.json
  test.project.json
```

생략 및 수정 가능합니다.

## tests 폴더

### 로블록스로의 빌드가 필요하다면 `test.project.json` 을 둡니다

Lute 환경으로만 테스트할 수 있다면 `rojo build` 와 `RobloxStudio.exe` 를 사용하지 않아도 됩니다.
하지만 `roblox` 환경에서 유닛 테스트 등을 한다면 `test.project.json` 을 두는 것이 좋습니다.

`*.project.json` 의 재귀 참조를 막기위해 루트의 `default.project.json` 처럼 루트에 둡니다.

만일 워크스페이스 패키지일 경우, `tests` 폴더의 상위 폴더에 둡니다

```sh
pkgs
  PackageA/
  PackageB/
    roblox_packges/
    src/
    tests/
    default.project.json
    test.project.json
    build.rbxl
pesde.toml
```

### Roblox 실행 테스트 스크립트

Roblox 안에서 테스트해야 한다면 Lute 스크립트로 빌드와 실행을 묶습니다.

```luau
-- scripts/runRobloxTests.luau:
const fs = require("@lute/fs")
const process = require("@lute/process")

const function run(args: { string })
	const result = process.run(args, { stdio = "inherit" })

	if not result.ok then
		process.exit(result.exitcode)
	end
end

const function findStudio(): string
	const versions = process.env.LOCALAPPDATA .. "/Roblox/Versions"
	local studio
	local modified

	for _, entry in fs.listdir(versions) do
		const candidate = `{versions}/{entry.name}/RobloxStudioBeta.exe`

		if fs.exists(candidate) then
			const candidateModified = fs.stat(candidate).modified

			if modified == nil or candidateModified > modified then
				studio = candidate
				modified = candidateModified
			end
		end
	end

	return assert(studio, "Roblox Studio not found")
end

run({ "rojo", "build", "test.project.json", "-o", "test.rbxl" })
run({
	findStudio(),
	"--task", "RunScript",
	"--localPlaceFile", process.cwd() .. "/test.rbxl",
	"--runScriptFile", process.cwd() .. "/tests/init.luau",
	"--quitAfterExecution",
})
```

```sh
lute run scripts/runRobloxTests.luau
```

## 수동 테스트는 playground 에서 합니다

`playground` 란 폴더에 자식 파일들이 각기 프로젝트입니다.

```sh
src/
tests/
playground/
  src/
  default.project.json
  build.rbxl
```

혹은

```sh
src/
tests/
playground/
  project-a/
  project-b/
  project-c/
  project-d/
```
