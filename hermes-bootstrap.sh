#!/bin/sh
set -eu

mkdir -p "${HERMES_HOME:-/home/agent/.hermes}"

if [ -z "${OPENROUTER_API_KEY:-}" ]; then
  echo "[boot] OPENROUTER_API_KEY is required" >&2
  exit 1
fi

if [ -z "${BUZZ_PRIVATE_KEY:-}" ]; then
  echo "[boot] BUZZ_PRIVATE_KEY is required" >&2
  exit 1
fi

# Keep NOSTR_PRIVATE_KEY in sync for sprig helpers.
export NOSTR_PRIVATE_KEY="${NOSTR_PRIVATE_KEY:-$BUZZ_PRIVATE_KEY}"

umask 077
printf 'OPENROUTER_API_KEY=%s\n' "$OPENROUTER_API_KEY" > "${HERMES_HOME}/.env"

MODEL_PROVIDER="${HERMES_MODEL_PROVIDER:-openrouter}"
MODEL_DEFAULT="${HERMES_MODEL_DEFAULT:-nvidia/nemotron-3-ultra-550b-a55b:free}"

if [ ! -f "${HERMES_HOME}/config.yaml" ] || [ "${FORCE_MODEL_BOOTSTRAP:-0}" = "1" ]; then
  cat > "${HERMES_HOME}/config.yaml" <<YAML
model:
  provider: ${MODEL_PROVIDER}
  default: ${MODEL_DEFAULT}
fallback_providers:
  - provider: openrouter
    model: openrouter/free
toolsets:
  - hermes-cli
YAML
fi

echo "[boot] relay=${BUZZ_RELAY_URL:-unset}"
echo "[boot] model=${MODEL_PROVIDER}/${MODEL_DEFAULT}"
echo "[boot] agent=${BUZZ_ACP_AGENT_COMMAND:-hermes} ${BUZZ_ACP_AGENT_ARGS:-acp}"

# Prefer original sprig entrypoint if present; otherwise exec buzz-acp directly.
if command -v sprig-entrypoint >/dev/null 2>&1; then
  exec sprig-entrypoint "$@"
fi
if [ -x /usr/local/bin/sprig-entrypoint ]; then
  exec /usr/local/bin/sprig-entrypoint "$@"
fi
exec buzz-acp "$@"
