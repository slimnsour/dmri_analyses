# Use Ubuntu 16.04 LTS
FROM ubuntu:xenial-20210722

ARG DEBIAN_FRONTEND=noninteractive

# Prepare environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    autoconf \
                    build-essential \
                    bzip2 \
                    ca-certificates \
                    curl \
                    cython3 \
                    gcc \
                    g++ \
                    git \
                    libtool \
                    lsb-release \
                    pkg-config \
                    make && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a shared $HOME directory
RUN useradd -m -s /bin/bash -G users ukf
WORKDIR /home/ukf
ENV HOME="/home/ukf"

# Install and set up Miniconda
RUN curl -sSLO https://repo.anaconda.com/miniconda/Miniconda3-py38_4.9.2-Linux-x86_64.sh && \
    bash Miniconda3-py38_4.9.2-Linux-x86_64.sh -b -p /usr/local/miniconda && \
    rm Miniconda3-py38_4.9.2-Linux-x86_64.sh

# Set CPATH for packages relying on compiled libs
ENV PATH="/usr/local/miniconda/bin:$PATH" \
    CPATH="/usr/local/miniconda/include:$CPATH" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    PYTHONNOUSERSITE=1

# Install conversion
RUN pip install git+https://github.com/pnlbwh/conversion.git@63e4ca5b6909f3e0f860753032bba73c0f8977c6

WORKDIR /src

# Download pnlNipype
RUN git clone https://github.com/pnlbwh/pnlNipype.git /src/pnlNipype && \
    cd /src/pnlNipype && \
    git checkout e8b9033

ENV PYTHONPATH="/src/pnlNipype:$PYTHONPATH"

# Install cmake
RUN mkdir -p /src/cmake && \
    curl -sSLO https://github.com/Kitware/CMake/releases/download/v3.21.1/cmake-3.21.1-linux-x86_64.sh && \
    bash cmake-3.21.1-linux-x86_64.sh --prefix=/src/cmake --skip-license && \
    rm cmake-3.21.1-linux-x86_64.sh

ENV PATH="/src/cmake/bin:$PATH"

# Use https protocol for git clone
RUN git config --global url."https://".insteadOf git://

# Install UKFTractography
RUN git clone https://github.com/pnlbwh/ukftractography.git /src/ukf && \
    cd /src/ukf && \
    git checkout 2c859b3 && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make

ENV UKFPATH=/src/ukf/build/UKFTractography-build/UKFTractography/bin \
    PATH="$UKFPATH:$PATH"

# Copy command line script
COPY run_ukf.sh /src/

WORKDIR $HOME
ENTRYPOINT ["/src/run_wma.sh"]
