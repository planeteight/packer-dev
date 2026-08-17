FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG PACKER_VERSION=1.11.2
ARG TARGETARCH=amd64

# HashiCorp APT repo (gives us packer + easy future upgrades) + AWS CLI v2
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        unzip \
        gnupg \
        software-properties-common \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
        > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends packer=${PACKER_VERSION}-* \
    && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/aws \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Lets `packer init` cache plugins in the container's home dir across rebuilds
# when combined with the volume mount in devcontainer.json.
ENV PACKER_PLUGIN_PATH=/home/vscode/.config/packer/plugins

USER vscode

CMD ["sleep", "infinity"]