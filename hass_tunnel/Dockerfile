ARG BUILD_FROM=hassioaddons/base:8.0.1
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN apk add --no-cache tzdata jq openssh vim curl autossh

COPY run.sh /

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
