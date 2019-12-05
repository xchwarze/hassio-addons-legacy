ARG BUILD_FROM=hassioaddons/base:5.0.2
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN apk add --no-cache tzdata jq openssh vim curl autossh

# More env params: https://www.harding.motd.ca/autossh/README.txt
ENV AUTOSSH_GATETIME=0

COPY run.sh /

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
