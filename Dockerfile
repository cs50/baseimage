FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive

# Avoid "delaying package configuration, since apt-utils is not installed"
RUN apt-get update && apt-get install -y apt-utils

# Configure environment
RUN apt-get update && apt-get install -y locales && \
    locale-gen "en_US.UTF-8" && dpkg-reconfigure locales
ENV LANG "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"
ENV LC_CTYPE "en_US.UTF-8"
ENV PYTHONDONTWRITEBYTECODE "1"
ENV TERM "xterm"

# Install packages
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y \
        apt-transport-https \
        clang \
        curl \
        git \
        software-properties-common `# Avoids "add-apt-repository: not found"` \
        sqlite3 \
        unzip \
        valgrind \
        wget

# Install libcs50, astyle
RUN add-apt-repository ppa:cs50/ppa && \
    apt-get install -y \
        astyle \
        libcs50

# Install git-lfs
# https://packagecloud.io/github/git-lfs/install#manual
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs

# Install Python packages
RUN apt-get update && apt-get install -y python3-pip && \
    pip3 install \
        cs50 \
        check50 \
        Flask \
        Flask-Session \
        style50
ENV FLASK_APP="application.py"

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
