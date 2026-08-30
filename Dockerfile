# syntax=docker/dockerfile:1.7
#
# Buzz agent body for Railway — buzz-sprig + Hermes Agent (OpenRouter).
# Official sprig ENTRYPOINT already execs buzz-acp as PID 1.
# Do not wrap with a shell CMD that breaks signal handling longer than needed.

FROM ghcr.io/block/buzz-sprig@sha256:5ff42f0b83e1e913dd094d0e3dc229891be3fc93041b076e2912c605a2a832e2

USER root

# Hermes needs Python. Alpine base from sprig.
RUN apk add --no-cache python3 py3-pip py3-virtualenv git ca-certificates curl \
    && python3 -m venv /opt/hermes-venv

ENV PATH="/opt/hermes-venv/bin:${PATH}"

ARG HERMES_REF=v2026.8.27
WORKDIR /opt/hermes-agent
RUN git clone --depth=1 --branch "${HERMES_REF}" https://github.com/NousResearch/hermes-agent.git . \
    && pip install --no-cache-dir -e '.[acp]' \
    && hermes --help >/dev/null \
    && printf '%s\n' '#!/bin/sh' 'exec hermes acp "$@"' > /usr/local/bin/hermes-acp \
    && chmod +x /usr/local/bin/hermes-acp \
    && chown -R agent:agent /opt/hermes-agent /opt/hermes-venv /home/agent

COPY hermes-bootstrap.sh /usr/local/bin/hermes-bootstrap.sh
RUN chmod +x /usr/local/bin/hermes-bootstrap.sh \
    && chown agent:agent /usr/local/bin/hermes-bootstrap.sh

USER agent

ENV HERMES_HOME=/home/agent/.hermes \
    HOME=/home/agent \
    BUZZ_ACP_AGENT_COMMAND=hermes \
    BUZZ_ACP_AGENT_ARGS=acp \
    BUZZ_ACP_MCP_COMMAND=buzz-dev-mcp \
    BUZZ_ACP_RESPOND_TO=owner-only \
    BUZZ_ACP_EXIT_AFTER_INACTIVITY=0 \
    HERMES_MODEL_PROVIDER=openrouter \
    HERMES_MODEL_DEFAULT=nvidia/nemotron-3-ultra-550b-a55b:free

ENTRYPOINT ["/usr/local/bin/hermes-bootstrap.sh"]
