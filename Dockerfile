FROM docker/sandbox-templates:shell

LABEL com.docker.sandboxes.flavor=opencode

USER root

RUN apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        clang \
        cmake \
        fd-find \
        gdb \
        lldb \
        locales \
        pkg-config \
        protobuf-compiler \
        shellcheck \
        xz-utils \
        zip \
        zlib1g-dev; \
    locale-gen en_US.UTF-8; \
    update-locale LANG=en_US.UTF-8; \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TERM=xterm-256color

RUN npm install -g typescript typescript-language-server
RUN npm install -g @anthropic-ai/claude-code

RUN npm install -g opencode-ai

RUN install -d -o agent -g agent /home/agent/.config/opencode

USER agent
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/agent/.cargo/bin:${PATH}"

RUN git clone https://github.com/rasmus105/dotfiles-ubuntu /tmp/dotfiles && \
    cd /tmp/dotfiles && bash setup.sh && \
    rm -rf /tmp/dotfiles

COPY --chown=agent:agent opencode.json /home/agent/.config/opencode/opencode.json
COPY --chown=agent:agent tui.json /home/agent/.config/opencode/tui.json
