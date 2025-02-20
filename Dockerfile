FROM ubuntu:24.04

# set version of ngs-bits to build, default is master, use --build-arg NGS-BITS_VERSION=label to build a specific version
ARG NGS_BITS_VERSION=master

# Derive target architecture for multi-arch builds
ARG TARGETARCH

ENV PATH=/opt/ngs-bits/bin:/bin:$PATH LANG=C.UTF-8 LC_ALL=C.UTF-8

# update ubuntu packages and install build dependencies
RUN apt-get update && \
    apt-get install -y \
        git \
        make \
        g++ \
        qtbase5-dev \
        libqt5xmlpatterns5-dev \
        libqt5sql5-mysql \
        libqt5sql5-odbc \
        libqt5charts5-dev \
        libqt5svg5-dev \
        python3 \
        python3-matplotlib \
        libbz2-dev \
        liblzma-dev \
        libcurl4 \
        libcurl4-openssl-dev \
        zlib1g-dev \
        ca-certificates \
        wget \
        curl \
        unzip

RUN mkdir -p /opt
WORKDIR /opt
RUN git clone https://github.com/imgag/ngs-bits.git
WORKDIR /opt/ngs-bits
RUN git checkout $NGS_BITS_VERSION && git submodule update --recursive --init
RUN make build_3rdparty
RUN make build_libs_release
RUN make build_tools_release

# add AWS CLI
RUN if [ "${TARGETARCH}" = "amd64" ]; then \
        AWSARCH="x86_64"; \
    elif [ "${TARGETARCH}" = "arm64" ]; then \
    AWSARCH="aarch64"; \
    else \
        echo "Unsupported architecture: ${TARGETARCH}"; exit 1; \
    fi && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-$AWSARCH.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip

# cleanup build dependencies
WORKDIR /
RUN find /opt/ngs-bits -mindepth 1 -maxdepth 1 ! -name 'bin' -exec rm -rf {} +
RUN apt-get remove -y \
        git \
        make \
        g++ \
        qtbase5-dev \
        libqt5xmlpatterns5-dev \
        libqt5charts5-dev \
        libqt5svg5-dev \
        libbz2-dev \
        liblzma-dev \
        libcurl4 \
        zlib1g-dev \
        wget \
        curl \
        unzip
RUN apt-get install -y \
        libqt5network5 \
        libqt5xml5 \
        libqt5xmlpatterns5
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*