FROM openeuler/opencode:1.1.48-oe2403lts

USER root

# Install gh CLI
RUN dnf install -y curl && \
    curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo -o /etc/yum.repos.d/gh-cli.repo && \
    dnf install -y gh && \
    dnf clean all

# Remove 'USER ubuntu' to avoid the "no matching entries" error.
# The container will run as root, ensuring full access to the gh tool.
