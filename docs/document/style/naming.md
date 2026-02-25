---
title: 네이밍 스타일 가이드
---

문서 자산(이미지, 비디오, 다운로드 파일)은 파일명만 보고도
의도와 문맥을 파악할 수 있어야 합니다.

## 기본 규칙

- 파일명은 `kebab-case`(소문자 + 하이픈)로 작성합니다.
- 허용 문자: 영문 소문자(`a-z`), 숫자(`0-9`), 하이픈(`-`).
- 공백, 언더스코어(`_`), 한글, 특수문자는 사용하지 않습니다.
- 확장자는 소문자로 작성합니다.
- `final`, `new`, `last`, `수정본` 같은 임시 상태 단어는 금지합니다.

```txt
good: score-points-scene-in-place.png
bad: ScorePoints_scene_final.PNG
```

## 공통 형식

다음 형식을 권장합니다.

```txt
[주제]-[설명][-<세부설명>][-<단계>][-<변형>].<ext>
```

최소 `[주제]-[설명]` 두 블록은 유지합니다.

예시:

- `score-points-scene-in-place.png`
- `fading-trap-ui-trigger-highlight.png`
- `curve-editor-convert-euler-angles.png`
- `quest-flow-diagram.svg`
- `inventory-drag-drop-demo.mp4`

## 종류별 규칙

### 이미지

- 스크린샷/튜토리얼 캡처: `png` 우선
- 사진/배경 중심 이미지: `jpg` 또는 `jpeg`
- 선명한 다이어그램/아이콘/벡터: `svg` 우선
- 파일명에 `image`, `screenshot` 같은 불필요한 일반어를 반복하지 않습니다.

### 비디오

- 기본 확장자는 `mp4`를 사용합니다.
- 파일명에는 동작/시나리오를 드러내는 단어를 포함합니다.

```txt
good: ui-slider-transparency-demo.mp4
bad: video1.mp4
```

### 다운로드 자산

- 문서에서 내려받게 하는 샘플 파일은 목적을 드러내는 접미사를 씁니다.

```txt
inventory-system-template.zip
pet-data-sample.json
```

## 접미사 규칙

### 변형 접미사

같은 자산의 변형이 있으면 마지막에 접미사를 붙입니다.

- 테마: `-light`, `-dark`
- 디바이스: `-desktop`, `-mobile`
- 비교 이미지: `-before`, `-after`

### 단계 접미사

정렬이 필요하면, 숫자 단계 접미사를 사용합니다.
주로 2자리 숫자로 매핑합니다.

```txt
*-01.png
*-02.png
*-03.png
```

## 파일 교체 규칙

- 같은 의미의 자산을 업데이트할 때는 파일명을 유지합니다.
- 문서에서 참조 중인 파일명을 불필요하게 바꾸지 않습니다.
- 내용이 완전히 다른 자산으로 교체할 때만 새 파일명을 사용합니다.

## 참조

- [GitHub Style Guide - File names for images](https://docs.github.com/en/contributing/style-guide-and-content-model/style-guide#file-names-for-images)
