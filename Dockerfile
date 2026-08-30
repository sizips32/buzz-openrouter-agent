# Lean Buzz ACP + Hermes Agent for Railway.
# Uses prebuilt Linux buzz-acp from Buzz desktop deb + Hermes ACP from git.

FROM python:3.12-slim-bookworm

ARG HERMES_REF=v2026.8.27

RUN apt-get update && apt-get install -y --no-install-recommends \
        git ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# Prebuilt Linux x86_64 buzz-acp / buzz from Buzz_0.5.20_amd64.deb
COPY bin/buzz-acp /usr/local/bin/buzz-acp
COPY bin/buzz /usr/local/bin/buzz
RUN chmod +x /usr/local/bin/buzz-acp /usr/local/bin/buzz

# Hermes Agent with ACP extra
WORKDIR /opt/hermes-agent
RUN git clone --depth=1 --branch "${HERMES_REF}" https://github.com/NousResearch/hermes-agent.git . \
    && pip install --no-cache-dir -e '.[acp]'

ENV HERMES_HOME=/data/.hermes
ENV HOME=/data/.hermes
ENV PYTHONUNBUFFERED=1

ENV BUZZ_RELAY_URL=wss://blockbuzzmain-production-b082.up.railway.app
ENV BUZZ_ACP_AGENT_COMMAND=hermes
ENV BUZZ_ACP_AGENT_ARGS=acp
ENV BUZZ_ACP_RESPOND_TO=owner-only
ENV HERMES_MODEL_PROVIDER=openrouter
ENV HERMES_MODEL_DEFAULT=nvidia/nemotron-3-ultra-550b-a55b:free

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/data"]
CMD ["/entrypoint.sh"]
