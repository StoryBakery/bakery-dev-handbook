---
id: scripting-guide
sidebar_label: Scripting Overview
---

# Scripting-Overview

## 개요

Story-Bakery 스크립팅 프레임워크는 그룹 전반의 코드 일관성과 유지보수성을 보장하기 위한 규칙 모음입니다. 모든 개발자는 여기서 정의한 기본 원칙을 토대로 게임 별 요구사항을 확장해야 하며, 새로운 스크립트를 작성하기 전 본 문서를 통해 세부 가이드의 목적을 먼저 파악해야 합니다.

스크립팅 가이드군은 파일 구조, 주석 방식, 네이밍, 객체지향 설계, 실행 컨텍스트 관리 등 프로젝트 전반에 적용되는 코딩 습관을 명문화합니다.

## 스타일-가이드

### 코드-작성-규칙
비대한 하나의 `code-style` 대신, 목적에 따라 세분화된 가이드를 제공합니다.

- [structure-style](./structure-style.md): 스크립트 파일 레이아웃, 코드 분리 및 모듈 구조 원칙.
- [formatting-style](./formatting-style.md): 인덴트, 공백, 줄 길이 등 시각적 포맷팅 규칙.
- [syntax-style](./syntax-style.md): Luau 언어 기능(조건문, 루프, 타입 등)의 올바른 사용법.

### 세부-가이드
- [naming-style](./naming-style.md): 클래스, 변수, 함수 등의 명명 규칙.
- [object-oriented-style](./object-oriented-style.md): 객체지향 설계 패턴 및 생명주기 관리.
- [require-style](./require-style.md): 모듈 로드 순서 및 경로 규칙. (필독)
- [document-based-comment](./document-based-comment.md): API 문서화를 위한 주석 작성법.

## 프레임워크-연동
- [vide-kit](../vide/vide-kit.md): Vide 기반 UI 컴포넌트 구조.
- [ui-style](../ui-style.md): UI 인터랙션 및 시각적 스타일 가이드.
