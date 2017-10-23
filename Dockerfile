FROM ubuntu:14.04

# environment
RUN locale-gen "en_US.UTF-8" && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
ENV LANG "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"
ENV LC_CTYPE "en_US.UTF-8"
ENV PATH /opt/cs50/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PYTHONDONTWRITEBYTECODE 1
ENV TERM xterm

# packages
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y \
        apt-transport-https \
        clang-3.8 \
        curl \
        git \
        sqlite3 \
        unzip \
        valgrind \
        wget && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.8 380 \
        --slave /usr/bin/clang++ clang++ /usr/bin/clang++-3.8 \
        --slave /usr/bin/clang-check clang-check /usr/bin/clang-check-3.8 \
        --slave /usr/bin/clang-query clang-query /usr/bin/clang-query-3.8 \
        --slave /usr/bin/clang-rename clang-rename /usr/bin/clang-rename-3.8

# install libcs50 and astyle
RUN sudo add-apt-repository ppa:cs50/ppa && \
    sudo apt-get update && \
    sudo apt-get install -y astyle libcs50

# install git-lfs
# https://packagecloud.io/github/git-lfs/install#manual
RUN echo "deb https://packagecloud.io/github/git-lfs/ubuntu/ trusty main" > /etc/apt/sources.list.d/github_git-lfs.list && \
    echo "deb-src https://packagecloud.io/github/git-lfs/ubuntu/ trusty main" >> /etc/apt/sources.list.d/github_git-lfs.list && \
    curl -L https://packagecloud.io/github/git-lfs/gpgkey | sudo apt-key add - && \
    apt-get update && \
    apt-get install -y git-lfs && \
    git lfs install

# install Python 3.6
# https://github.com/yyuu/pyenv/blob/master/README.md#installation
# https://github.com/yyuu/pyenv/wiki/Common-build-problems
ENV PYENV_ROOT /opt/pyenv
RUN apt-get install -y \
        build-essential \
        curl \
        libbz2-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        llvm \
        wget \
        xz-utils \
        zlib1g-dev && \
    wget -P /tmp https://github.com/yyuu/pyenv/archive/master.zip && \
    unzip -d /tmp /tmp/master.zip && \
    rm -f /tmp/master.zip && \
    mv /tmp/pyenv-master /opt/pyenv && \
    chmod a+x /opt/pyenv/bin/pyenv && \
    /opt/pyenv/bin/pyenv install 3.6.0 && \
    /opt/pyenv/bin/pyenv rehash && \
    /opt/pyenv/bin/pyenv global 3.6.0
ENV PATH "$PYENV_ROOT"/shims:"$PYENV_ROOT"/bin:"$PATH"

# install Python packages
RUN pip install cs50 check50 style50 submit50

COPY ./etc/profile.d/common.sh /etc/profile.d/

