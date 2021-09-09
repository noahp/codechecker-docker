# Builds a docker image suitable for running CodeChecker commands.

# First build the codechecker package so we can copy it over to the final image
FROM ubuntu:21.04 AS builder

# Use bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential=12.8ubuntu3 \
    curl=7.74.0-1ubuntu2.1 \
    gcc-multilib=4:10.3.0-1ubuntu1 \
    git=1:2.30.2-1ubuntu1 \
    python3-dev=3.9.4-1 \
    python3-venv=3.9.4-1 \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y --no-install-recommends nodejs=12.22.6-deb-1nodesource1 \
    && rm -rf /var/lib/apt/lists/*

## Build CodeChecker
ARG CC_VERSION=3ea0f3b20ef000e2841c04545b6d01809570dbed

# Download CodeChecker release.
# Build CodeChecker. hack installing wheel, it's busted without.
WORKDIR /codechecker
RUN git clone --depth 1 https://github.com/Ericsson/CodeChecker.git /codechecker \
    && git checkout ${CC_VERSION} \
    && ACTIVATE_RUNTIME_VENV=". venv/bin/activate && pip install wheel==0.34.2" make venv \
    && . venv/bin/activate && BUILD_LOGGER_64_BIT_ONLY=YES make package

# Final image
FROM ubuntu:21.04

# Use bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential=12.8ubuntu3 \
    clang-11=1:11.0.1-2ubuntu4 \
    clang-tidy-11=1:11.0.1-2ubuntu4 \
    curl=7.74.0-1ubuntu2.1 \
    git=1:2.30.2-1ubuntu1 \
    python3-venv=3.9.4-1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /codechecker /codechecker

# CodeChecker needs these to be exact :(
RUN \
    ln -s clang-tidy-11 /usr/bin/clang-tidy \
    && ln -s clang-11 /usr/bin/clang

# Add CodeChecker wrapper script
COPY CodeChecker /usr/bin/CodeChecker

# Add CodeChecker default runner
COPY run-codechecker.sh /app/run-codechecker.sh

WORKDIR /workdir
VOLUME ["/workdir"]

ENTRYPOINT ["/app/run-codechecker.sh"]
