# The devcontainer.json file defines a build so the Dockerfile is used to build a new image.
# The base image is from Microsoft at https://mcr.microsoft.com/en-us/artifact/mar/devcontainers/javascript-node/tags.
# The name "bookworm" refers to the Debian Bookworm release, which is the base OS for this image, adding the name
# fixes the Linux release used.

FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

# Install system dependencies required for building and unpacking Ada tooling
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    jq \
    unzip \
    gnat \
    gprbuild \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy or run the script inline during the build
RUN arch_output=$(dpkg --print-architecture) \
    && alr_latest=$(curl -sL https://api.github.com/repos/alire-project/alire/releases/latest | jq -r .tag_name) \
    && if [ "$arch_output" = "arm64" ]; then \
        curl -L -o vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64" \
        && dpkg -i vscode.deb || apt-get install -y --fix-broken \
        && rm vscode.deb \
        && curl -sLO "https://github.com/alire-project/alire/releases/download/${alr_latest}/alr-${alr_latest#v}-bin-aarch64-linux.zip" \
        && unzip alr-${alr_latest#v}-bin-aarch64-linux.zip \
        && mv ./bin/alr /usr/local/bin/alr \
        && rm -rf ./bin; \
    elif [ "$arch_output" = "amd64" ]; then \
        curl -L -o vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" \
        && dpkg -i vscode.deb || apt-get install -y --fix-broken \
        && rm vscode.deb \
        && curl -sLO "https://github.com/alire-project/alire/releases/download/${alr_latest}/alr-${alr_latest#v}-bin-x86_64-linux.zip" \
        && unzip alr-${alr_latest#v}-bin-x86_64-linux.zip \
        && mv ./bin/alr /usr/local/bin/alr \
        && rm -rf ./bin; \
    else \
        echo "unsupported architecture" && exit 1; \
    fi

WORKDIR /workspace