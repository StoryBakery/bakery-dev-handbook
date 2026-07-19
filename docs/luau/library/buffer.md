---
title: Buffer
---

바이너리 데이터를 저장하는 것에 유용한 버퍼 라이브러리입니다.

- `create(size: number): buffer`
- `fromstring(str: string): buffer`
- `tostring(b: buffer): string`
- `len(b: buffer): number`
- `readbits(b: buffer, bitOffset: number,bitCount: number): number`
- `readi8(b: buffer, offset: number): number`
- `readu8(b: buffer, offset: number): number`
- `readi16(b: buffer, offset: number): number`
- `readu16(b: buffer, offset: number): number`
- `readi32(b: buffer, offset: number): number`
- `readu32(b: buffer, offset: number): number`
- `readf32(b: buffer, offset: number): number`
- `readf64(b: buffer, offset: number): number`
- `writebits(b: buffer,bitOffset: number,bitCount: number, value: number): ()`
- `writei8(b: buffer, offset: number, value: number): ()`
- `writeu8(b: buffer, offset: number, value: number): ()`
- `writei16(b: buffer, offset: number, value: number): ()`
- `writeu16(b: buffer, offset: number, value: number): ()`
- `writei32(b: buffer, offset: number, value: number): ()`
- `writeu32(b: buffer, offset: number, value: number): ()`
- `writef32(b: buffer, offset: number, value: number): ()`
- `writef64(b: buffer, offset: number, value: number): ()`
- `readstring(b: buffer, offset: number, count: number): string`
- `writestring(b: buffer, offset: number, value: string,count: number?): ()`
- `copy(target: buffer, targetOffset: number, source: buffer, sourceOffset: number?, count: number?): ()`
- `fill(b: buffer, offset: number, value: number,count: number?): ()`-

기본 라이브러리로는 `f16`, `CFrame`, `Vector3`, 길이가 가변형인 `string` 등을 간편하게 저장할 수 없고,
길이가 가변형인 버퍼를 만드려면, 매번 복제해주고 길이를 늘려야함에 따라,
buffer 라이브러리를 감싸는 외부 라이브러리를 사용하는 것을 추천합니다.
