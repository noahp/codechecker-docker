# Example of extending the base codechecker image with additional tools

FROM noahpendleton/codechecker:0.3.0

# GCC-ARM compiler
ARG ARM_URL=https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.07/gcc-arm-none-eabi-10.3-2021.07-x86_64-linux.tar.bz2
RUN curl -sL --progress-meter ${ARM_URL} > /opt/gcc-arm-none-eabi.tar.bz2 && \
    echo "8c5b8de344e23cd035ca2b53bbf2075c58131ad61223cae48510641d3e556cea /opt/gcc-arm-none-eabi.tar.bz2" \
        | sha256sum -c && \
    mkdir -p /opt/gcc-arm-none-eabi && \
    pv --force /opt/gcc-arm-none-eabi.tar.bz2 | tar xj --directory /opt/gcc-arm-none-eabi --strip-components 1
ENV PATH=/opt/gcc-arm-none-eabi/bin:${PATH}
