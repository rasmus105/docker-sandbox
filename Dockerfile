FROM docker/sandbox-templates:shell-docker

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
        zsh \
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

RUN chown -R agent:agent /home/agent && \
    chsh -s /usr/bin/zsh agent

RUN echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER agent
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/agent/.cargo/bin:${PATH}"

RUN git clone https://github.com/rasmus105/dotfiles-ubuntu /home/agent/.dotfiles && \
    cd /home/agent/.dotfiles && bash setup.sh
    
# open neovim to install plugins
RUN nvim --headless +qa

# overwrite opencode configs to get all permissions
COPY --chown=agent:agent opencode.json /home/agent/.config/opencode/opencode.json
COPY --chown=agent:agent tui.json /home/agent/.config/opencode/tui.json
COPY --chown=agent:agent opencode-instructions.md /home/agent/.config/opencode/opencode-instructions.md
