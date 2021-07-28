# Use Ubuntu 20.04 LTS
FROM focal-20210416

# Prepare environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    bzip2 \
    ca-certificates \
    cmake \
    curl \
    git \
    make

# Install and set up Miniconda
 RUN curl -sSLO https://repo.anaconda.com/miniconda/Miniconda3-py38_4.9.2-Linux-x86_64.sh && \
    bash Miniconda3-py38_4.9.2-Linux-x86_64.sh -b -p /usr/local/miniconda && \
    rm Miniconda3-py38_4.9.2-Linux-x86_64.sh

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
RUN mkdir -p $UKFPATH && \
    git clone https://github.com/pnlbwh/ukftractography.git $UKFPATH && \
    cd $UKFPATH && \
    cmake && \
    make \
    make test




    # set up working directory, redefine home directory, remain root user
WORKDIR /home/pnlbwh
ENV HOME=/home/pnlbwh
ENV USER="root"


    # install required libraries
RUN yum -y groupinstall 'development tools' && \
    yum -y install wget file bzip2 which vim git make libstdc++-static mesa-libGL bc tcsh libSM && \
    yum clean all && \
    #

    # install miniconda3
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash Miniconda3-latest-Linux-x86_64.sh -b -p miniconda3/ && \
    git clone --recurse-submodules https://github.com/pnlbwh/pnlpipe.git && \
    #
    # create conda environment
    echo "source $HOME/miniconda3/bin/activate" >> ~/.bashrc && \
    source miniconda3/bin/activate && \
    conda env create -f pnlpipe/python_env/environment36.yml && \
    echo "conda activate pnlpipe3" >> ~/.bashrc && \
    conda activate pnlpipe3 && \
    #
    # back up incompatible libicuuc.*
    mv miniconda3/envs/pnlpipe3/lib/libicuuc.* /tmp/ && \
    cd pnlpipe && mkdir soft_dir && export PNLPIPE_SOFT=$HOME/pnlpipe/soft_dir && \
    ./pnlpipe std init && \
    ./pnlpipe std setup && \
    mv /tmp/libicuuc.* $HOME/miniconda3/envs/pnlpipe3/lib/ && \
    #
    # clean up sources
    conda clean -y --all && \
    rm -f $HOME/Miniconda3-latest-Linux-x86_64.sh && \
    cd soft_dir && rm -rf BRAINSTools BRAINSTools-build ANTs ANTs-build ukftractography UKFTractography-build dcm2niix && \
    rm -rf /tmp/* /var/tmp/* && \
    #
    # set up bashrc i.e shell
    echo "export PNLPIPE_SOFT=$HOME/pnlpipe/soft_dir" >> ~/.bashrc && \
    echo "source \${PNLPIPE_SOFT}/UKFTractography-2c144a3/env.sh" >> ~/.bashrc && \
    echo "export PATH=$HOME/pnlpipe/pnlscripts:\$PATH" >> ~/.bashrc && \
    #
   

ENTRYPOINT ["/startup.sh"]

