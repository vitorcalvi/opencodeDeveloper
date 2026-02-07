FROM openeuler/opencode:1.1.48-oe2403lts

USER root

# Install dependencies in a single layer
RUN dnf install -y curl git && \
    curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo -o /etc/yum.repos.d/gh-cli.repo && \
    dnf install -y gh && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

# Create ubuntu user and directories
RUN id -u ubuntu &>/dev/null || useradd -m -s /bin/bash ubuntu && \
    mkdir -p /home/ubuntu/.config/opencode \
             /home/ubuntu/.local/share/opencode \
             /home/ubuntu/.cache/opencode && \
    chown -R ubuntu:ubuntu /home/ubuntu

# Copy configuration files
COPY --chown=ubuntu:ubuntu opencode.json /home/ubuntu/.config/opencode/opencode.json
COPY --chown=ubuntu:ubuntu oh-my-opencode.json /home/ubuntu/.config/opencode/oh-my-opencode.json

# Switch to non-root user
USER ubuntu

WORKDIR /home/ubuntu

EXPOSE 3000

# Enhanced healthcheck with more time for plugin installation
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1
