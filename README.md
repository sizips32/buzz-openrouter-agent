# Buzz OpenRouter Agent (Railway)

`joyful-encouragement`에 추가할 헤드리스 에이전트 서비스.

## 구조

```
Buzz Desktop / clients
        │
        ▼
block/buzz:main (릴레이) ──WS──► buzz-acp ──stdio──► hermes acp
                                      │
                                      ▼
                               OpenRouter
                     nvidia/nemotron-3-ultra-550b-a55b:free
```

## Railway Variables (서비스 전용)

| 변수 | 값 |
|------|-----|
| `OPENROUTER_API_KEY` | 로컬 `~/.hermes/.env`와 동일 키 |
| `BUZZ_PRIVATE_KEY` | 에이전트 Nostr 비밀키 (hex) |
| `BUZZ_RELAY_URL` | `wss://blockbuzzmain-production-b082.up.railway.app` |
| `BUZZ_ACP_AGENT_OWNER` | 릴레이 오너 pubkey `eba04c6b2ed15e175f2e947f2617999de00a2a81785fa4ec382edcbe975c7a33` |
| `BUZZ_ACP_AGENT_COMMAND` | `hermes` |
| `BUZZ_ACP_AGENT_ARGS` | `acp` |
| `BUZZ_ACP_RESPOND_TO` | `owner-only` |
| `HERMES_MODEL_PROVIDER` | `openrouter` |
| `HERMES_MODEL_DEFAULT` | `nvidia/nemotron-3-ultra-550b-a55b:free` |
| `HERMES_HOME` | `/data/.hermes` |

## 배포 전 필수

1. 릴레이에 에이전트 pubkey 멤버 등록 (`buzz-admin add-member`)
2. 채널 `My_AI_Teams`에 에이전트 초대 (Desktop)
3. Volume `/data` 마운트 (Hermes 홈 유지)

## 에이전트 pubkey

`0ec4d82217308420ea712dff61d44c126f5bccc8041c4b9194392af9bdc214b7`
