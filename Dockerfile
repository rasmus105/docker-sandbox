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

RUN npm install -g typescript typescript-language-server

RUN npm install -g @anthropic-ai/claude-code

RUN install -d -o agent -g agent /home/agent/.config/opencode
COPY --chown=agent:agent opencode.json /home/agent/.config/opencode/opencode.json
COPY --chown=agent:agent tui.json /home/agent/.config/opencode/tui.json

USER agent
ENV PATH="/home/agent/.cargo/bin:/home/agent/.linuxbrew/bin:${PATH}"

RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

RUN brew install zig

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
