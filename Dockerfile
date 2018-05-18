FROM ubuntu:14.04

# Configure environment
RUN locale-gen "en_US.UTF-8" && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
ENV LANG "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"
ENV LC_CTYPE "en_US.UTF-8"
ENV PYTHONDONTWRITEBYTECODE 1
ENV TERM xterm

# Install packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
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

# Install libcs50, astyle
RUN add-apt-repository ppa:cs50/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y astyle libcs50

# Install git-lfs
# https://packagecloud.io/github/git-lfs/install#manual
RUN echo "deb https://packagecloud.io/github/git-lfs/ubuntu/ trusty main" > /etc/apt/sources.list.d/github_git-lfs.list && \
    echo "deb-src https://packagecloud.io/github/git-lfs/ubuntu/ trusty main" >> /etc/apt/sources.list.d/github_git-lfs.list && \
    curl -L https://packagecloud.io/github/git-lfs/gpgkey | apt-key add - && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git-lfs && \
    git lfs install

# Install Python 3.6
# https://github.com/yyuu/pyenv/blob/master/README.md#installation
# https://github.com/yyuu/pyenv/wiki/Common-build-problems
ENV PYENV_ROOT /opt/pyenv
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
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
    mv /tmp/pyenv-master "$PYENV_ROOT" && \
    chmod a+x "$PYENV_ROOT"/bin/pyenv && \
    "$PYENV_ROOT"/bin/pyenv install 2.7.15 && \
    "$PYENV_ROOT"/bin/pyenv install 3.6.5 && \
    "$PYENV_ROOT"/bin/pyenv rehash #&& \
    #"$PYENV_ROOT"/bin/pyenv global 3.6.5

# Install Python packages
RUN PATH="$PYENV_ROOT"/shims:"$PYENV_ROOT"/bin:"$PATH" pip3 install --upgrade pip && \
    PATH="$PYENV_ROOT"/shims:"$PYENV_ROOT"/bin:"$PATH" pip3 install \
        cs50 \
        check50 \
        Flask \
        Flask-Session \
        style50

# Configure shell
COPY ./etc/profile.d/baseimage.sh /etc/profile.d/

# Set PATH
ENV PATH /opt/cs50/bin:/usr/local/sbin:/usr/local/bin:"$PYENV_ROOT"/shims:"$PYENV_ROOT"/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN sed -e "s|^PATH=.*$|PATH='$PATH'|g" -i /etc/environment

# Add user
RUN useradd --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
    umask 0077 && \
    mkdir -p /home/ubuntu/workspace && \
    chown -R ubuntu:ubuntu /home/ubuntu

# TEMP
#USER ubuntu
#WORKDIR /home/ubuntu/workspace

# Start with login shell
CMD ["bash", "-l"]
