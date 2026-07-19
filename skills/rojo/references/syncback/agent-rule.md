---
name: rojo-syncback Agent Rule
---

이 문서는 에이전트가 `rojo syncback`을 검토하거나 실행할 때 따라야 하는 안전 절차입니다.

## 에이전트 안전 규칙

syncback은 반드시 미리보기 우선 방식으로 다뤄야 합니다.

1. 프로젝트 파일을 읽고 의도한 `$path` 루트를 찾습니다.
1. 작업 트리에 사용자의 관련 없는 변경 사항이 있는지 확인합니다.
1. 중요한 프로젝트에서는 실행 전에 `syncbackRules`를 추가하거나 검토합니다.
1. 먼저 `rojo syncback ... --dry-run --list`를 실행합니다.
1. 모든 `Writing` 및 `Removing` 경로를 사용자 의도와 비교해 검토합니다.
1. 사용자가 명시적으로 쓰기를 요청했거나 확인한 뒤에만 실제 syncback을 실행합니다.
1. 가능하면 `rojo build`, 프로젝트 테스트, Studio 스모크 테스트로 검증합니다.

syncback을 무해한 명령처럼 취급하면 안 됩니다.
이 명령은 파일을 추가하고, 기존 파일을 다시 쓰고, 입력 Roblox 파일에 없는 기존 Rojo 트리 파일을 삭제할 수 있습니다.

## 권장 에이전트 워크플로

1. 대상이 Windows 백업 프로그램이 아니라 Roblox용 Rojo syncback인지 확인합니다.
1. 버전을 확인합니다.

```bash
rojo --version
rojo syncback --help
```

1. 프로젝트 파일을 읽습니다.

```bash
rg -n '"syncbackRules"|"tree"|"syncRules"|\$path' .
```

1. 입력 파일과 범위를 확인합니다. 저장된 `.rbxl`, `.rbxlx`, `.rbxm`, `.rbxmx`가 없으면 사용자에게 요청합니다.
1. 일반 프로젝트 트리의 범위가 적절하지 않으면 syncback 전용 프로젝트 파일을 권장하거나 추가합니다.
1. secrets, 생성 콘텐츠, 소스 코드로 관리해야 하는 스크립트, 노이즈가 많은 속성을 보호하기 위해 보수적인 `syncbackRules`를 추가합니다.
1. 미리보기를 실행합니다.

```bash
rojo syncback default.project.json --input game.rbxl --dry-run --list --color never
```

1. `Removing` 줄과 예상 밖의 `Writing` 줄을 검토합니다.

```bash
rojo syncback default.project.json --input game.rbxl --list --non-interactive --color never
```

1. 검증합니다.

```bash
rojo build default.project.json --output /tmp/rojo-syncback-check.rbxl
```

가능하면 프로젝트별 테스트나 Studio 검토도 함께 수행합니다.
