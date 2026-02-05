FROM openeuler/opencode:1.1.48-oe2403lts

USER root

# 1. Install curl to fetch the repo file
# 2. Add the official GitHub CLI repository
# 3. Install gh and clean up
RUN dnf install -y curl && \
    curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo -o /etc/yum.repos.d/gh-cli.repo && \
    dnf install -y gh && \
    dnf clean all

# Switch back to the application user
USER ubuntu
