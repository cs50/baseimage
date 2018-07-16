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
        clang \
        curl \
        git \
        openjdk-11-jdk-headless `# Technically JDK 10` \
        openjdk-11-jre-headless `# Technically JDK 10` \
        ruby \
        ruby-dev `# Avoid "can't find header files for ruby" for gem` \
        software-properties-common `# Avoids "add-apt-repository: not found"` \
        sqlite3 \
        unzip \
        valgrind

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
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs

# Install Python packages
RUN apt-get update && apt-get install -y python3-pip && \
    pip3 install \
        cs50 \
        check50 \
        Flask \
        Flask-Session \
        style50
ENV FLASK_APP="application.py"

# Install Composer
RUN curl --silent --show-error https://getcomposer.org/installer | \
        php -- --install-dir=/usr/local/bin --filename=composer

# Configure shell
COPY ./etc/profile.d/baseimage.sh /etc/profile.d/

# Add user
RUN useradd --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
    umask 0077 && \
    mkdir -p /home/ubuntu/workspace && \
    chown -R ubuntu:ubuntu /home/ubuntu
USER ubuntu
WORKDIR /home/ubuntu/workspace

# Start with login shell
CMD ["bash", "-l"]
