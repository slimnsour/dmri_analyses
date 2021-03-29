FROM ubuntu:20.04

#COPY ./keyboard /etc/default/keyboard
#COPY ./timezone /etc/timezone
ARG DEBIAN_FRONTEND="noninteractive"

#RUN echo $'12\n5\n31\n1\n' >> apt_input.txt

RUN apt-get update
RUN apt-get install -y git subversion build-essential cmake cmake-curses-gui cmake-qt-gui qt5-default qtmultimedia5-dev qttools5-dev libqt5xmlpatterns5-dev libqt5svg5-dev qtwebengine5-dev qtscript5-dev qtbase5-private-dev libqt5x11extras5-dev libxt-dev 

RUN ln -fs /usr/share/zoneinfo/America/Toronto /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    ND_ENTRYPOINT="/neurodocker/startup.sh"

# Get Slicer dependencies
#RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#    git wget subversion build-essential cmake cmake-curses-gui cmake-qt-gui \
#    qt5-default qtmultimedia5-dev qttools5-dev libqt5xmlpatterns5-dev libqt5svg5-dev \
#    qtwebengine5-dev qtscript5-dev qtbase5-private-dev libqt5x11extras5-dev libxt-dev

# Set git to pull from https not git
RUN git config --global url."https://".insteadOf git://

WORKDIR /

#RUN apt-get install -y --no-install-recommends ca-certificates

# Build Slicer
RUN git clone https://github.com/Slicer/Slicer.git

RUN mkdir /Slicer-SuperBuild-Debug
WORKDIR /Slicer-SuperBuild-Debug
RUN cmake ../Slicer
RUN make

WORKDIR /

# Get conda
RUN apt-get install -y wget && \
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x  /Miniconda3-latest-Linux-x86_64.sh && \
    /Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda3/ && \
    echo "source /miniconda3/bin/activate" >> ~/.bashrc

SHELL ["/bin/bash", "-c"] 

#RUN /bin/bash -c "source ~/.bashrc"
RUN source /miniconda3/bin/activate && pip install git+https://github.com/SlicerDMRI/whitematteranalysis.git

# Get xvfb
RUN apt-get install -y --no-install-recommends xvfb

# Clean Files
WORKDIR /Slicer-SuperBuild-Debug
RUN find . -name '*.o' -delete && \
  # Remove all git directories
  find . -name .git -type d -prune -exec rm -rf "{}" \; && \
  # Remove files
  rm -f *.cmake *.txt *.applied *.updated *.in *.tcl Makefile && \
  rm -f *.tgz *.tar.gz *.zip && \
  rm -rf CMakeFiles && \
  # Remove all python-* directories except python-install
  find . -maxdepth 1 -type d  -name python-install -o -type d -name "python-*" -exec rm -rf "{}" \; && \
  rm -rf NUMPY && \
  rm -rf SimpleITK* && \
  rm -rf Python-2* && \
  # Remove all *-prefix directories
  find . -maxdepth 1 -type d  -name Slicer-prefix -o -type d -name "*-prefix"  -exec rm -rf "{}" \; && \
  # Remove uneeded source and build tree
  rm -rf \
    bzip2 bzip2-build \
    curl curl-build \
    LibArchive LibArchive-build \
    PCRE PCRE-build \
    Swig Swig-build \
    zlib zlib-build \
  && \
  # Remove ITKPython wrapping
  mkdir -p ITK-build/Wrapping && find ITK-build/Wrapping -name '*.cpp' -delete -o -name '*.xml' -delete && \
  rm -rf ITK-build/Wrapping/Generators/castxml* && \
  # Remove source files
  find CTK -name '*.cpp' -delete && \
  find DCMTK -name '*.cc' -delete && \
  find ITK -name '*.cxx' -delete -o -name '*.cpp' -delete && \
  find VTK -name '*.cxx' -delete -o -name '*.cpp' -delete && \
  rm -rf CTK-build/PythonQt/generated* && \
  rm -f /Miniconda3-latest-Linux-x86_64.sh && \
  rm -rf /Slicer

# WMA STUFF

WORKDIR /home/pnlbwh
ENV HOME=/home/pnlbwh
RUN apt-get update && apt-get install python2.7 -y
ENV LANG="en_US.UTF-8" \
    LC_ALL="C"

RUN echo "Downloading FreeSurfer" && \
    wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.1.0/freesurfer-linux-centos7_x86_64-7.1.0.tar.gz > /dev/null 2>&1 && \
    echo "Unzipping FreeSurfer tar ball" && \
    tar -xzf freesurfer-linux-centos7_x86_64-7.1.0.tar.gz && \
    rm -f freesurfer-linux-centos7_x86_64-7.1.0.tar.gz && \
    mv freesurfer freesurfer-7.1.0
    #
    # install FSL
RUN echo "Downloading FSL installer" && \
    wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py -O fslinstaller.py > /dev/null 2>&1 && \
    echo "Installing FSL" && \
    python fslinstaller.py -V 6.0.1 -d $HOME/fsl-6.0.1 -p > /dev/null 2>&1 && \
    # setup FSL environment
    export FSLDIR=$HOME/fsl-6.0.1 && \
    source $FSLDIR/etc/fslconf/fsl.sh && \
    $FSLDIR/fslpython/bin/conda clean -y --all && \
    rm -f fslinstaller.py
    #
    # install miniconda2 and whitematteranalysis package
RUN wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -O Miniconda2-latest-Linux-x86_64.sh && \
    /bin/bash Miniconda2-latest-Linux-x86_64.sh -b -p miniconda2/ && \
    source miniconda2/bin/activate && \
    conda create -y -n wma python=2.7.13 && conda activate wma && \
    pip install git+https://github.com/SlicerDMRI/whitematteranalysis.git@fa98f26087d6cf26fcb2a1d50a7a18d73c361d93
    #
    # initialize .bashrc
RUN cp /root/.bashrc $HOME/ && \
    echo "export PY2BIN=$HOME/miniconda2/envs/wma/bin" >> ~/.bashrc && \
    rm -rf .cache/pip/* && \
    rm -f Miniconda2-latest-Linux-x86_64.sh && \
    conda clean -y --all
    

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
    git config --global url."https://".insteadOf "git://" && \
    conda activate pnlpipe3 && \
    #
    # back up incompatible libicuuc.*
    mv miniconda3/envs/pnlpipe3/lib/libicuuc.* /tmp/ && \
    cd pnlpipe && mkdir soft_dir && export PNLPIPE_SOFT=$HOME/pnlpipe/soft_dir && \
    ./pnlpipe std init && \
    ./pnlpipe std setup && \
    mv /tmp/libicuuc.* $HOME/miniconda3/envs/pnlpipe3/lib/
    #
    # clean up sources
RUN conda clean -y --all && \
    rm -f $HOME/Miniconda3-latest-Linux-x86_64.sh && \
    cd soft_dir && rm -rf BRAINSTools BRAINSTools-build ANTs ANTs-build ukftractography UKFTractography-build dcm2niix && \
    rm -rf /tmp/* /var/tmp/* && \
    #
    # set up bashrc i.e shell
    echo "export PNLPIPE_SOFT=$HOME/pnlpipe/soft_dir" >> ~/.bashrc && \
    echo "alias ls=\"ls --color\"" >> ~/.bashrc && \
    echo "source \${PNLPIPE_SOFT}/BRAINSTools-bin-81a409d/env.sh" >> ~/.bashrc && \
    echo "source \${PNLPIPE_SOFT}/ANTs-bin-ca32228/env.sh" >> ~/.bashrc && \
    echo "source \${PNLPIPE_SOFT}/UKFTractography-2c144a3/env.sh" >> ~/.bashrc && \
    echo "source \${PNLPIPE_SOFT}/dcm2niix-c0a3731/env.sh" >> ~/.bashrc && \
    echo "source \${PNLPIPE_SOFT}/tract_querier-d4a88aa/env.sh" >> ~/.bashrc && \
    echo "export FSLDIR=$HOME/fsl-6.0.1" >> ~/.bashrc && \
    echo "source \$FSLDIR/etc/fslconf/fsl.sh" >> ~/.bashrc && \
    echo "export PATH=\$FSLDIR/bin:\$PATH" >> ~/.bashrc && \
    echo "export FREESURFER_HOME=$HOME/freesurfer-7.1.0" >> ~/.bashrc && \
    echo "source \${FREESURFER_HOME}/SetUpFreeSurfer.sh" >> ~/.bashrc && \
    echo "export PATH=$HOME/pnlpipe/pnlscripts:\$PATH" >> ~/.bashrc && \
    #
    # facilitate creation of ~/matlab/startup.m
    export FREESURFER_HOME=$HOME/freesurfer-7.1.0 && \
    source ${FREESURFER_HOME}/SetUpFreeSurfer.sh && \
    #
    # change permission of startup script 
    chmod +x /startup.sh

WORKDIR /

ENV BASH_ENV "/root/.bashrc"

COPY startup.sh /

RUN chmod +x /startup.sh

RUN strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5

ENTRYPOINT ["/startup.sh"]
#ENTRYPOINT ["xvfb-run -a -s \"-screen 0 640x480x24 +iglx\""]
