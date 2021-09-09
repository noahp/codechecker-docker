# Builds a docker image suitable for running CodeChecker commands.

FROM ubuntu:21.04

ARG DEBIAN_FRONTEND=noninteractive

# Use bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential=12.8ubuntu3 \
    clang-11=1:11.0.1-2ubuntu4 \
    clang-tidy-11=1:11.0.1-2ubuntu4 \
    curl=7.74.0-1ubuntu2.1 \
    gcc-multilib=4:10.3.0-1ubuntu1 \
    git=1:2.30.2-1ubuntu1 \
    pv=1.6.6-1 \
    python3-dev=3.9.4-1 \
    python3-pip=20.3.4-1ubuntu2 \
    python3-venv=3.9.4-1 \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y --no-install-recommends nodejs=12.22.6-deb-1nodesource1 \
    && rm -rf /var/lib/apt/lists/*

# GCC-ARM compiler
ARG ARM_URL=https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.07/gcc-arm-none-eabi-10.3-2021.07-x86_64-linux.tar.bz2
RUN curl -sL --progress-meter ${ARM_URL} > /opt/gcc-arm-none-eabi.tar.bz2 && \
    echo "8c5b8de344e23cd035ca2b53bbf2075c58131ad61223cae48510641d3e556cea /opt/gcc-arm-none-eabi.tar.bz2" \
        | sha256sum -c && \
    mkdir -p /opt/gcc-arm-none-eabi && \
    pv --force /opt/gcc-arm-none-eabi.tar.bz2 | tar xj --directory /opt/gcc-arm-none-eabi --strip-components 1
ENV PATH=/opt/gcc-arm-none-eabi/bin:${PATH}

## Build CodeChecker
ARG CC_VERSION=3ea0f3b20ef000e2841c04545b6d01809570dbed

# Download CodeChecker release.
# Build CodeChecker. hack installing wheel, it's busted without.
WORKDIR /codechecker
RUN git clone --depth 1 https://github.com/Ericsson/CodeChecker.git /codechecker \
    && git checkout ${CC_VERSION} \
    && ACTIVATE_RUNTIME_VENV=". venv/bin/activate && pip install wheel==0.34.2" make venv \
    && . venv/bin/activate && BUILD_LOGGER_64_BIT_ONLY=YES make package

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
