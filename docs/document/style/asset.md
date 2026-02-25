---
title: 자산 스타일
---

## 링크

자산 경로도 상대 경로를 사용합니다.
파일명 규칙은 [자산 네이밍](./naming.md)을 따릅니다.

```md
![이미지](./assets/scripting/image.png)
<video src="./assets/scripting/video.mp4" controls width="800"></video>
```

### 자산 보관 장소

- 기본값: `docs/*/assets` (문서 전용, 가장 우선)
  예시: `docs/scripting/script-editor.md`에서 `![](./assets/image.png)`

- 공용 문서 자산: `docs/assets/*` (여러 문서가 공유)
  예시: `docs/scripting/external-editor/index.md`에서 `![](../../assets/scripting/code-editor.png)`

- 사이트 전역 자산: `static/*` (favicon, logo, OG, 다운로드 파일, config 참조 자산, 번역 불필요 파일)
  문서 참조 예시: `![](../../static/img/logo.svg)`
  절대 링크로 참조하지 않습니다, 오로지 상대링크만을 사용합니다

### 이미지 기본 문법

```md
![](./assets/coding/image.png)
```

### 이미지 대체 텍스트(alt)

- 정보 전달용 이미지는 설명 alt 텍스트를 작성합니다.
- 장식용 이미지는 빈 alt(`![](...)`)를 사용합니다.

```md
![Spawn point above a grid of fading platforms, above a lava floor](./assets/tutorials/scoring-points/scene-in-place.jpg)
```

### `<img>` 사용

이미지 크기나 레이아웃 제어가 필요할 때 `<img>`를 사용합니다.

```md
<img src="./assets/animation/curve-editor/convert-euler-angles.png" width="600" alt="Convert Euler Angles dialog" />
```

### 비디오

비디오는 `<video>` 태그를 사용합니다.

```md
<video src="./assets/coding/video.mp4" controls width="800"></video>
```
