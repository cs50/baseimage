FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive

# Avoid dropping man pages
RUN sed --expression '/^\s*path-exclude=\/usr\/share\/doc\/\*\s*$/ s/^#*/#/' --in-place /etc/dpkg/dpkg.cfg.d/excludes && \
    sed --expression '/^\s*path-exclude=\/usr\/share\/man\/\*\s*$/ s/^#*/#/' --in-place /etc/dpkg/dpkg.cfg.d/excludes

# Avoid "delaying package configuration, since apt-utils is not installed"
RUN apt-get update && apt-get install -y apt-utils

# Configure environment
RUN apt-get update && apt-get install -y locales && \
    locale-gen "en_US.UTF-8" && dpkg-reconfigure locales
ENV LANG "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"
ENV LC_CTYPE "en_US.UTF-8"
ENV PYTHONDONTWRITEBYTECODE "1"

# Install packages
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y \
        apt-transport-https \
        astyle \
        clang-5.0 \
        curl \
        git \
        php \
        ruby \
        ruby-dev `# Avoid "can't find header files for ruby" for gem` \
        openjdk-11-jdk-headless `# Java 10` \
        software-properties-common `# Avoids "add-apt-repository: not found"` \
        sqlite3 \
        unzip \
        valgrind && \
        update-alternatives --install /usr/bin/clang clang $(which clang-5.0) 1

# Install CS50 packages
RUN curl --silent https://packagecloud.io/install/repositories/cs50/repo/script.deb.sh | bash && \
    apt-get install -y \
        libcs50 \
        libcs50-java \
        php-cs50

# Install git-lfs
# https://packagecloud.io/github/git-lfs/install#manual
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs

# Install Node.js 10.x
RUN curl -sL https://deb.nodesource.com/setup_10.x | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 bash - && \
    apt-get install -y nodejs && \
    npm install -g npm `# Upgrades npm to latest`

# Install Python 3.7
ARG PYENV_ROOT=/opt/pyenv
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        libbz2-dev \
        libffi-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        llvm \
        make \
        tk-dev \
        wget \
        xz-utils \
        zlib1g-dev && \
    wget -P /tmp https://github.com/pyenv/pyenv/archive/master.zip && \
    unzip -d /tmp /tmp/master.zip && \
    rm -f /tmp/master.zip && \
    mv /tmp/pyenv-master "$PYENV_ROOT" && \
    chmod a+x "$PYENV_ROOT"/bin/* && \
    "$PYENV_ROOT"/bin/pyenv install 2.7.15 && \
    "$PYENV_ROOT"/bin/pyenv install 3.7.0 && \
    "$PYENV_ROOT"/bin/pyenv rehash && \
    "$PYENV_ROOT"/bin/pyenv global 2.7.15 3.7.0 && \
    "$PYENV_ROOT"/shims/pip2 install --upgrade pip && \
    "$PYENV_ROOT"/shims/pip3 install --upgrade pip && \
    "$PYENV_ROOT"/shims/pip3 install \
        cs50 \
        check50 \
        Flask \
        Flask-Session \
        style50

# Install Composer
RUN curl --silent --show-error https://getcomposer.org/installer | \
        php -- --install-dir=/usr/local/bin --filename=composer

# Configure shell
COPY ./etc/profile.d/baseimage.sh /etc/profile.d/

# Update environment
ENV PATH=/opt/cs50/bin:/opt/bin:/usr/local/sbin:/usr/local/bin:"$PYENV_ROOT"/shims:"$PYENV_ROOT"/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN sed -i "s|^PATH=.*|PATH=$PATH|" /etc/environment

# Ready /opt
RUN mkdir -p /opt/bin /opt/cs50/bin

# Add user
RUN useradd --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
    umask 0077 && \
    mkdir -p /home/ubuntu/workspace && \
    chown -R ubuntu:ubuntu /home/ubuntu
USER ubuntu
WORKDIR /home/ubuntu/workspace

# Start with login shell
CMD ["bash", "-l"]
