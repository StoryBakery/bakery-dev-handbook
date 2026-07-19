---
title: LocalizationTable
---

로컬리제이션 테이블은 번역할 텍스트들을 담고 있는 csv 파일이자 테이블입니다.

## 구조

로블록스 프로젝트와의 호환을 위해, 그리고 비-로블록스 프로젝트들끼리도 번역 기능을 제공해야할 경우,
문서 파일이라면 i18n 을 사용하지만, UI 텍스트 등은 `.csv` 파일을 사용합니다.

기본적으로 다음과 같은 구조를 가집니다.

```csv
Key,Source,Example,ko-kr,ja-jp,zh-cn,zh-tw,es-es,fr-fr,de-de
Greet,Hello.,존중하는 안녕,안녕하세요.,こんにちは。,你好。,你好。,Hola.,Bonjour.,Hallo.
Farewell,Goodbye.,정중한 작별 인사,안녕히 가세요.,さようなら。,再见。,再見。,Adiós.,Au revoir.,Auf Wiedersehen.
```

csv 해석 시 필드는 생략해도 잘 파싱되지만, `Key`, `Source` 는 남겨둡니다

## Example

Example 은 번역할 텍스트가 어떤 맥락인지 알려줍니다.
Key 나 Source 만으로 번역할 텍스트의 뉘앙스나 맥락을 구분하기 어려운 경우 번역가를 위해 남기지만,
만일 필요없는 경우 생략할 수 있습니다.

```csv
Key,Source,en-us
```

## 필드 순서

다음과 같은 구조를 취합니다.

1. Key
2. Source
3. Example (생략 가능)
4. 번역 LocaleId 와 그 텍스트들

예시:

```csv
Key,Source,Example,en-us,ko-kr,ja-jp,zh-cn,zh-tw,es-es,fr-fr,de-de, ...
```

## LocaleId 필드

### LanguageCode 와 LocaleId

[로블록스 Localization 문서] 를 참고하면, **LanguageCode** 와 **LocaleId** 를 나눕니다.

LanguageCode 는 언어의 종류를 나타내고, LocaleId 는 언어 + 지역 + 문화 설정까지 포함한 개념입니다
그렇기에 번역은 각 LocaleId 를 기준으로 진행됩니다.

- LanguageCode 의 형태는 `en`, `ko`.
- LocaleId 의 형태는 `en-us`, `ko-kr` (en 은 `en-es` 로 영어-영국 이렇게 표현할 수도 있게됨, 중국어도 간체/번체로 마찬가지)

### LocaleId 순서

필드에서 LocaleId 의 순서는 다음과 같습니다

1. `en-us`: 영어 (미국)
1. `ko-kr`: 한국어 (대한민국)
1. 이후는 알파벳 순서로.

상황에 맞추어 열을 동적으로 추가해 주면 됩니다.

주로 소스언어는 `ko-kr` 로, 번역은 `en-us` 부터 진행합니다.
그래서 LocaleId 는 Key,Source,Example,en-us,그외LocaleId 들로 진행됩니다

[로블록스 Localization 문서]: https://create.roblox.com/docs/production/localization/language-codes

## 파일 이름

### 파일 이름 뒤에는 소스언어를 붙입니다

```sh
Localization.ko-kr.csv
```

만약 비어있으면 `en-us` 로 취급합니다.

```sh
Localization.csv # Localization.en-us.csv 와 같습니다
```

### 명시적인 폴더에 없을 경우 파일 이름 뒤에는 `-Localization` 을 붙입니다

다음처럼 로컬리제이션 테이블이 모였다고 알 수 있는
명시적인 이름의 폴더 안에 있다면 `-Localization` 을 붙일 필요 없습니다.

```
LocalizationTables
|- Hud.ko-kr.csv
|- Shop.ko-kr.csv
|- Dialogue.ko-kr.csv
```

하지만 이것이 아닌, 다른 파일들과 형제로서 같이 있는 경우 `-Localization` 이란 접미사를 붙여줍니다.

```
Game
|- Game.server.lua
|- GameLocalization.ko-kr.csv
|- Boss.rbxm
```
