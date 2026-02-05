FROM openeuler/opencode:1.1.48-oe2403lts
USER root
RUN dnf install -y gh && dnf clean all
USER ubuntu
