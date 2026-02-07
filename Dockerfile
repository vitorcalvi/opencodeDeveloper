FROM openeuler/opencode:1.1.48-oe2403lts

USER root

# 1. Install dependencies + SUDO in a single layer
# Added 'sudo' to the install list
# Kept all your requested openEuler library equivalents
RUN dnf install -y \
    sudo \
    curl \
    git \
    nspr \
    nspr-devel \
    nss \
    nss-devel \
    atk \
    at-spi2-atk \
    cups-libs \
    dbus-libs \
    libdrm \
    mesa-libgbm \
    gtk3 \
    libXcomposite \
    libXdamage \
    libXfixes \
    libxkbcommon \
    libXrandr \
    alsa-lib && \
    curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo -o /etc/yum.repos.d/gh-cli.repo && \
    dnf install -y gh && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

# 2. Create ubuntu user, grant sudo access, and setup directories
# Added line to add ubuntu to sudoers
RUN id -u ubuntu &>/dev/null || useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
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

# Enhanced healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1
