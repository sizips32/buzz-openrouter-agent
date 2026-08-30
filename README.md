# buzz-openrouter-agent

Railway용 Buzz 헤드리스 에이전트 몸체.

- Base: `ghcr.io/block/buzz-sprig` (buzz-acp)
- Runtime: Hermes Agent ACP
- Model: OpenRouter `nvidia/nemotron-3-ultra-550b-a55b:free`

## Required Variables

- `OPENROUTER_API_KEY`
- `BUZZ_PRIVATE_KEY` (and optionally duplicate as `NOSTR_PRIVATE_KEY`)
- `BUZZ_RELAY_URL=wss://blockbuzzmain-production-b082.up.railway.app`
- `BUZZ_ACP_AGENT_OWNER=eba04c6b2ed15e175f2e947f2617999de00a2a81785fa4ec382edcbe975c7a33`

Do not enable HTTP healthchecks. This service has no public port.
