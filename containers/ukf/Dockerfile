# Use Ubuntu 20.04 LTS
FROM ubuntu:focal-20210416

ARG DEBIAN_FRONTEND=noninteractive

# Prepare environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    bzip2 \
    ca-certificates \
    cmake \
    gcc \
    curl \
    git \
    make

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

# Installing precomputed Python packages
RUN conda install -y -c anaconda -c conda-forge \
                     python=3.7.1 \
                     graphviz=2.40 \
                     git-annex \
                     libxml2=2.9.8 \
                     libxslt=1.1.32 \
                     matplotlib=2.2 \
                     mkl \
                     mkl-service \
                     nodejs \
                     numpy=1.20 \
                     pandoc=2.11 \
                     pip=20.3 \
                     scikit-learn=0.19 \
                     scipy=1.5 \
                     setuptools=51.1 \
                     traits=4.6.0 \
                     zlib; sync && \
    chmod -R a+rX /usr/local/miniconda; sync && \
    chmod +x /usr/local/miniconda/bin/*; sync && \
    conda build purge-all; sync && \
    conda clean -tipsy && sync

WORKDIR /src

# Download UKFTractography
ENV UKFPATH=/src/ukf
ENV UKFBUILDPATH=/src/ukf-build
RUN mkdir -p $UKFPATH $UKFBUILDPATH && \
    git clone https://github.com/pnlbwh/ukftractography.git $UKFPATH && \
    git config --global url."https://".insteadOf git:// && \
    cd $UKFBUILDPATH && \
    cmake $UKFPATH && \
    make && \
    make test

# set up working directory, redefine home directory, remain root user
WORKDIR /home/pnlbwh
ENV HOME=/home/pnlbwh
ENV USER="root"

# Copy command line script
COPY run_ukf.sh /src/

# WORKDIR $HOME
ENTRYPOINT ["/src/run_ukf.sh"]
