FROM docker/sandbox-templates:opencode

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    clang \
    cmake \
    fd-find \
    gdb \
    jq \
    lldb \
    pkg-config \
    protobuf-compiler \
    ripgrep \
    shellcheck \
    unzip \
    xz-utils \
    zip \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

ARG ZIG_VERSION=0.15.2
ARG TARGETARCH
RUN case "${TARGETARCH}" in \
      amd64) zig_arch="x86_64" ;; \
      arm64) zig_arch="aarch64" ;; \
      *) echo "Unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fL "https://ziglang.org/download/${ZIG_VERSION}/zig-${zig_arch}-linux-${ZIG_VERSION}.tar.xz" \
    | tar -xJ -C /opt \
    && ln -s "/opt/zig-${zig_arch}-linux-${ZIG_VERSION}/zig" /usr/local/bin/zig

RUN npm install -g typescript typescript-language-server

RUN curl -fsSL https://claude.ai/install.sh | bash

RUN install -d -o agent -g agent /home/agent/.config/opencode
COPY --chown=agent:agent opencode.json /home/agent/.config/opencode/opencode.json
COPY --chown=agent:agent tui.json /home/agent/.config/opencode/tui.json

USER agent

ENV PATH="/home/agent/.cargo/bin:${PATH}"
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
