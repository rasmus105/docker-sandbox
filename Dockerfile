FROM docker/sandbox-templates:shell

USER root

RUN apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        clang \
        cmake \
        fd-find \
        gdb \
        lldb \
        pkg-config \
        protobuf-compiler \
        shellcheck \
        xz-utils \
        zip \
        zlib1g-dev; \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g typescript typescript-language-server
RUN npm install -g @anthropic-ai/claude-code

RUN npm install -g opencode-ai

RUN install -d -o agent -g agent /home/agent/.config/opencode
COPY --chown=agent:agent opencode.json /home/agent/.config/opencode/opencode.json
COPY --chown=agent:agent tui.json /home/agent/.config/opencode/tui.json

USER agent
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/agent/.cargo/bin:${PATH}"

RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

RUN brew install zig

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
