---
title: 환경
---

## RunService 에서 현재 로블록스 환경을 구하기

| Environment | IsStudio | IsClient | IsServer | IsEdit | IsRunning | IsRunMode |
| --- | --- | --- | --- | --- | --- | --- |
| Live (Client) | false | true | false | - | true | false |
| Live (Server) | false | false | true | - | true | false |
| Edit | true | true | true | true | false | false |
| Collaborative Edit | true | true | false | true | false | false |
| Run Mode | true | false | true | - | true | true |
| Play Mode (Client) | true | true | false | - | true | false |
| Play Mode (Server) | true | false | true | - | true | false |
| Team Test (Client) | true | true | false | - | true | false |
| Team Test (Server) | true | false | true | - | true | false |
| Luau Execution | false | false | true | - | false | false |
