FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG PACKER_VERSION=1.16.0
ARG TARGETARCH

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        unzip \
        gnupg \
        software-properties-common \
        python3 \
        python3-pip \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
        > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends packer=${PACKER_VERSION}-* \
    && AWS_ARCH=$(if [ "$TARGETARCH" = "arm64" ]; then echo "aarch64"; else echo "x86_64"; fi) \
    && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/aws \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PACKER_PLUGIN_PATH=/home/vscode/.config/packer/plugins

USER vscode

CMD ["sleep", "infinity"]