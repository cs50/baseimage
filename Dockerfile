FROM ubuntu:18.04
LABEL maintainer="sysadmins@cs50.harvard.edu"
ARG DEBIAN_FRONTEND=noninteractive

# Avoid "delaying package configuration, since apt-utils is not installed"
RUN apt-get update && apt-get install -y apt-utils

# Environment
RUN apt-get update && apt-get install -y locales && \
    locale-gen "en_US.UTF-8" && dpkg-reconfigure locales
ENV LANG "C.UTF-8"
ENV LC_ALL "C.UTF-8"
ENV LC_CTYPE "C.UTF-8"

# Install packages
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y \
        apt-transport-https \
        astyle \
        clang-8 \
        curl \
        git \
        lua5.3 \
        php \
        ruby \
        ruby-dev `# Avoid "can't find header files for ruby" for gem` \
        sqlite3 \
        unzip \
        valgrind \
        wget

# Install CS50 packages
RUN curl --silent https://packagecloud.io/install/repositories/cs50/repo/script.deb.sh | bash && \
    apt-get install -y \
        libcs50 \
        libcs50-java \
        php-cs50
ENV CLASSPATH ".:/usr/share/java/cs50.jar"

# Install git-lfs
# https://packagecloud.io/github/git-lfs/install#manual
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs

# Install Java 13
# http://jdk.java.net/13/
RUN cd /tmp && \
    wget https://download.java.net/java/GA/jdk13.0.1/cec27d702aa74d5a8630c65ae61e4305/9/GPL/openjdk-13.0.1_linux-x64_bin.tar.gz && \
    tar xzf openjdk-13.0.1_linux-x64_bin.tar.gz && \
    rm -f openjdk-13.0.1_linux-x64_bin.tar.gz && \
    mv jdk-13.0.1 /opt/ && \
    mkdir -p /opt/bin && \
    ln -s /opt/jdk-13.0.1/bin/* /opt/bin/ && \
    chmod a+rx /opt/bin/*
ENV JAVA_HOME "/opt/jdk-13.0.1"

# Install Node.js 13.x
# https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions-enterprise-linux-fedora-and-snap-packages
# https://github.com/nodesource/distributions/blob/master/README.md#debinstall
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm `# Upgrades npm to latest`
ENV NODE_ENV "dev"

# Install Python 3.7
# https://www.python.org/downloads/
# https://stackoverflow.com/a/44758621/5156190
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        libbz2-dev \
        libc6-dev \
        libgdbm-dev \
        liblzma-dev `# Required by pandas` \
        libncursesw5-dev \
        libreadline-gplv2-dev \
        libsqlite3-dev \
        libssl-dev \
        tk-dev \
        zlib1g-dev && \
    cd /tmp && \
    wget https://www.python.org/ftp/python/3.7.6/Python-3.7.6.tgz && \
    tar xzf Python-3.7.6.tgz && \
    rm -f Python-3.7.6.tgz && \
    cd Python-3.7.6 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf Python-3.7.6 && \
    pip3 install --upgrade pip
ENV PYTHONDONTWRITEBYTECODE "1"

# Install CS50 packages
RUN pip3 install \
        cs50 \
        check50 \
        Flask \
        Flask-Session \
        style50 \
        submit50

# Install Composer
RUN curl --silent --show-error https://getcomposer.org/installer | \
        php -- --install-dir=/usr/local/bin --filename=composer

# Install Swift 5.1
RUN cd /tmp && \
    wget https://swift.org/builds/swift-5.1.3-release/ubuntu1804/swift-5.1.3-RELEASE/swift-5.1.3-RELEASE-ubuntu18.04.tar.gz && \
    tar xzf swift-5.1.3-RELEASE-ubuntu18.04.tar.gz --strip-components=1 -C / && \
    rm -f swift-5.1.3-RELEASE-ubuntu18.04.tar.gz && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libpython2.7

# Configure clang 8 last, else 7 takes priority
RUN (update-alternatives --remove-all clang || true) && \
    update-alternatives --install /usr/bin/clang clang $(which clang-8) 1

# Configure shell
COPY ./etc/profile.d/baseimage.sh /etc/profile.d/

# Update environment
ENV PATH=/opt/cs50/bin:/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN sed -i "s|^PATH=.*|PATH=$PATH|" /etc/environment

# Ready /opt
RUN mkdir -p /opt/bin /opt/cs50/bin

# Add user
RUN useradd --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
    umask 0077 && \
    mkdir -p /home/ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu
USER ubuntu
WORKDIR /home/ubuntu


# TEMP
# Add user to sudoers
USER root
RUN apt-get install -y sudo
RUN echo "\n# CS50 CLI" >> /etc/sudoers
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "Defaults umask_override" >> /etc/sudoers
RUN echo "Defaults umask=0022" >> /etc/sudoers
RUN sed -e "s|^Defaults\tsecure_path=.*|Defaults\t!secure_path|" -i /etc/sudoers
USER ubuntu

# Start with login shell
CMD ["bash", "-l"]
