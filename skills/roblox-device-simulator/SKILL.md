---
name: roblox-device-simulator
description: Roblox Studio에서 특정 디바이스의 UI를 테스트하거나 디바이스·화면 방향·해상도를 전환하고, 여러 디바이스의 레이아웃을 비교하거나 플레이 모드 UI를 검증할 때 사용합니다.
---

# Roblox Device Simulator

Studio 연결과 테스트 대상을 확인한 뒤 작업 전에 전체 reference를 읽고 따릅니다.
디바이스 목록은 실행 시 동적으로 조회하고, 특정 디바이스 ID나 운영체제별 Studio 설치 경로를 하드코딩하지 않습니다.
각 전환 뒤 화면을 캡처해 시각적으로 검증하고 콘솔 오류를 확인한 다음, 작업이 끝나면 기본 뷰포트로 복귀합니다.

## References

- `references/device-simulator.md`: 디바이스 선택, API 호출, UI 탐색, 화면 캡처, 플레이 테스트, 명령별 절차와 제한사항을 다룰 때 반드시 읽고 따릅니다.
