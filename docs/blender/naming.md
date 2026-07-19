---
title: 블렌더에서의 작명 스타일
---

[블렌더 스튜디오 작명 관습]를 참고해 로블록스의 관습과도 호환되게 합니다.

[블렌더 스튜디오 작명 관습]: https://studio.blender.org/tools/naming-conventions/introduction

## 구분자

구분자는 `.` 대신 `_` 를 사용합니다.

[nodot-names](https://extensions.blender.org/add-ons/nodot-names) 익스텐션을 설치해 설정할 수 있습니다.

## 네이밍

객체들은 PascalCase 로 하고, 분류가 필요한 경우 `_` 로 분류할 수 있습니다.

`Geo_Object_Subtype`

## 접두사/접미사

### 숫자 접미사

숫자 접미사 `.001` `.002` 같은 것은 `0` 이 아닌 `1` 부터 시작합니다.

### 왼쪽 오른쪽 표기

`*.L` `*.R` 로 표기합니다.

#### 로블록스에서는 `Left-` `Right-` 로 표기합니다

몸을 구성하는 파트의 경우 `LeftUpperArm` `RightUpperArm` 처럼 표기합니다.

그러나 일반 본에는 파트가 아닌, 일반 본의 경우 `.L` `.R` 접미사를 이용해 표기합니다.
