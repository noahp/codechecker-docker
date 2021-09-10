# Builds a docker image suitable for running CodeChecker commands.

FROM ubuntu:21.04

# Use bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential=12.8ubuntu3 \
    clang=1:12.0-52~exp1 \
    clang-tidy=1:12.0-52~exp1 \
    curl=7.74.0-1ubuntu2.1 \
    git=1:2.30.2-1ubuntu1 \
    python3-pip=20.3.4-1ubuntu2 \
    && rm -rf /var/lib/apt/lists/*

# Add CodeChecker
RUN pip install codechecker==6.17.0

# Add CodeChecker default runner
COPY run-codechecker.sh /app/run-codechecker.sh

WORKDIR /workdir
VOLUME ["/workdir"]

ENTRYPOINT ["/app/run-codechecker.sh"]
