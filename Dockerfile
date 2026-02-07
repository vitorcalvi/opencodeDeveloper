FROM openeuler/opencode:1.1.48-oe2403lts

USER root

# Install dependencies in a single layer
RUN dnf install -y curl git && \
    curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo -o /etc/yum.repos.d/gh-cli.repo && \
    dnf install -y gh && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

# Create ubuntu user if it doesn't exist and set up directories
RUN id -u ubuntu &>/dev/null || useradd -m -s /bin/bash ubuntu && \
    mkdir -p /home/ubuntu/.config/opencode /home/ubuntu/.local/share/opencode && \
    chown -R ubuntu:ubuntu /home/ubuntu

# Copy configuration files before switching to ubuntu user
COPY opencode.json /home/ubuntu/.config/opencode/opencode.json
COPY oh-my-opencode.json /home/ubuntu/.config/opencode/oh-my-opencode.json

# Set proper ownership of config files
RUN chown -R ubuntu:ubuntu /home/ubuntu/.config/opencode

# Switch to non-root user
USER ubuntu

WORKDIR /home/ubuntu

# Install plugins at build time (OpenCode will process config and install npm plugins)
RUN mkdir -p /home/ubuntu/.cache/opencode/node_modules

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1
