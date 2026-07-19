---
title: 내용
---

## 매개변수

매개변수로 중괄호로 감싸 문장 사이에 문자열을 삽입할 수 있습니다.

```csv
Source,en-es
Hello {PlayerName}!,Hola {PlayerName}!
My name is {NpcName},Me llamo {NpcName}
```

스타일은 PascalCase 로 합니다.

### 지정자 사용하기

| 지정자 | 타입 | 설명 | 예시 출력 |
| --- | --- | --- | --- |
| int | number | 정수. 음수 부호 허용, 천 단위 구분자 없음. | 1234 |
| fixed | number | 소수점 이하 두 자리. 소수점 기호 포함, 음수 부호 허용, 천 단위 구분자 없음. | 1234.50 </br> 1234,50 |
| num | number | 소수점 이하 두 자리. 소수점 기호 포함, 음수 부호 허용, 천 단위 구분자 포함. | 1,234.50 </br> 1234,50 |
| HEX | number | 정수를 16진수로 변환. 음수는 64비트 2의 보수로 변환. | 3FF |
| hex | number | HEX와 동일하지만 소문자로 출력. | 3ff |
| datetime | number | UTC 타임스탬프 숫자를 범용 사용자 가독 형식으로 변환. | 2017-10-10 13:38:10 |
| iso8601 | number | UTC 타임스탬프 숫자를 ISO-8601 형식 UTC 시간으로 변환. | 2017-10-12T22:02:38Z |
| shorttime | number | UTC 타임스탬프를 로컬 "시:분" 형식으로 변환. | 1:45 PM </br> 13:45 |
| shortdatetime | number | UTC 타임스탬프를 짧은 시간 포함 일반 날짜+시간 패턴으로 변환. | 10/10/2017 1:45 PM |
| shortdate | number | UTC 타임스탬프를 짧은 날짜 패턴으로 변환. | 10/10/2017 </br> 2017-10-10 |
| translate | string | 로컬라이제이션 테이블에서 Source 문자열과 일치하는 항목을 찾아 해당 로케일 번역을 사용. | |

`translate` 지정자는 남발해서 사용하지 않습니다.
`translate` 는 `Source` 문자열 기반 매칭이므로, 키 중심 로컬라이제이션 원칙과 맞지 않습니다.
번역 참조는 주로 명시적인 `Key` 를 사용합니다.

```csv
Key,Source,en-us
Inventory.GetItem,{ItemName}을(를) {Count: int}개 획득했습니다.,You received {Count: int} {ItemName}.
```

### 문자열을 이어붙이지 않습니다

여러 키를 코드에서 이어붙여 문장을 만들지 않습니다.
언어마다 어순과 문법이 다르기 때문에, 하나의 키에 완성된 문장을 담아야 합니다.

**Bad**:

```luau
return translator:FormatByKey("Get") .. " " .. translator:FormatByKey("Apple")
```

**Good**:

```luau
const ITEM_NAME_KEY = "Item.Apple.Name"

const itemDisplayName = translator:FormatByKey(ITEM_NAME_KEY)

return translator:FormatByKey("Inventory.GetItem", {
	itemName = itemDisplayName,
})
```
