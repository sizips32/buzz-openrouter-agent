#!/bin/sh
set -eu

mkdir -p "${HERMES_HOME}"

# Seed Hermes OpenRouter config if missing or if FORCE_MODEL_BOOTSTRAP=1
if [ ! -f "${HERMES_HOME}/.env" ] || [ "${FORCE_MODEL_BOOTSTRAP:-0}" = "1" ]; then
  if [ -z "${OPENROUTER_API_KEY:-}" ]; then
    echo "[boot] OPENROUTER_API_KEY is required" >&2
    exit 1
  fi
  umask 077
  printf 'OPENROUTER_API_KEY=%s\n' "$OPENROUTER_API_KEY" > "${HERMES_HOME}/.env"
fi

MODEL_PROVIDER="${HERMES_MODEL_PROVIDER:-openrouter}"
MODEL_DEFAULT="${HERMES_MODEL_DEFAULT:-nvidia/nemotron-3-ultra-550b-a55b:free}"

if [ ! -f "${HERMES_HOME}/config.yaml" ] || [ "${FORCE_MODEL_BOOTSTRAP:-0}" = "1" ]; then
  cat > "${HERMES_HOME}/config.yaml" <<EOF
model:
  provider: ${MODEL_PROVIDER}
  default: ${MODEL_DEFAULT}
fallback_providers:
  - provider: openrouter
    model: openrouter/free
toolsets:
  - hermes-cli
EOF
fi

if [ -z "${BUZZ_PRIVATE_KEY:-}" ]; then
  echo "[boot] BUZZ_PRIVATE_KEY is required (agent Nostr secret)" >&2
  exit 1
fi

if [ -z "${BUZZ_RELAY_URL:-}" ]; then
  echo "[boot] BUZZ_RELAY_URL is required" >&2
  exit 1
fi

export BUZZ_ACP_AGENT_COMMAND="${BUZZ_ACP_AGENT_COMMAND:-hermes}"
export BUZZ_ACP_AGENT_ARGS="${BUZZ_ACP_AGENT_ARGS:-acp}"
export BUZZ_ACP_RESPOND_TO="${BUZZ_ACP_RESPOND_TO:-owner-only}"

echo "[boot] relay=${BUZZ_RELAY_URL}"
echo "[boot] agent=${BUZZ_ACP_AGENT_COMMAND} ${BUZZ_ACP_AGENT_ARGS}"
echo "[boot] model=${MODEL_PROVIDER}/${MODEL_DEFAULT}"
echo "[boot] respond_to=${BUZZ_ACP_RESPOND_TO}"

# Railway expects a process that stays up. buzz-acp is the long-running harness.
exec buzz-acp
