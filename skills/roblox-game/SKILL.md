---
name: roblox-game
description: StoryBakery Roblox 게임의 시뮬레이션과 네트워크 동작을 설계, 구현, 리뷰할 때 사용합니다. 고정 틱, 프레젠테이션 보간, 서버-클라이언트 복제, 서버 권한, 예측, 롤백, 재시뮬레이션 작업을 포함합니다.
---

# Roblox Game

작업할 시뮬레이션 모델과 권한 경계를 먼저 식별한 뒤 관련 reference를 읽습니다.
Roblox API와 일반 Luau 코드를 함께 변경할 때는 `roblox`와 `luau` 스킬도 적용합니다.
네트워크 지연, 정정, 재시뮬레이션이 있는 경로는 서버와 클라이언트 양쪽 동작을 검증합니다.

## References

### Simulation and replication

- `references/fixed-tick.md`: 고정 틱 이벤트, 프레임 계산, 주파수, 가변 프레임과의 역할 분리를 설계하거나 구현할 때
- `references/presentation-with-fixed-tick.md`: 고정 틱 게임의 시각 표현, 보간, 결정론적 애니메이션과 VFX를 구현할 때
- `references/server-client-replication.md`: 서버-클라이언트 복제 흐름, 복제와 정정 규칙, 서버 시간을 다룰 때

### Server authority

- `references/server-authority/index.md`: Roblox 서버 권한, 클라이언트 예측, 롤백의 기본 모델을 다룰 때
- `references/server-authority/behavior.md`: `BindToSimulation`, 예측 상태, 속성과 Attribute, `RunService.Rollback` 동작을 구현할 때
- `references/server-authority/advanced-behavior.md`: 재시뮬레이션 상태 저장, Signal, 예측 프레임 범위, 디버깅을 다룰 때
- `references/server-authority/debug.md`: Misprediction을 추적하거나 서버 권한 시뮬레이션을 디버깅할 때
- `references/server-authority/simulation-access.md`: 서버 권한 환경에서 속성과 메서드의 `simulationAccess` 가능 여부를 판단할 때
- `references/server-authority/input.md`: 서버 권한에서 플레이어 자식 `InputAction`의 동기화를 다룰 때
