FROM ubuntu:20.04

# Prerequisites
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive TZ=America/Sao_Paulo apt install -y \
        curl \
        git \
        unzip \
        xz-utils \
        zip \
        libglu1-mesa \
        wget \
        cmake \
        clang \
        ninja-build \
        pkg-config \
        libgtk-3-dev

RUN apt install -y nginx

RUN DEBIAN_FRONTEND=noninteractive apt install -y openjdk-8-jdk

# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Prepare Android directories and system variables
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT /home/developer/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

# Set up Android SDK
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses
RUN cd Android/sdk/tools/bin && ./sdkmanager "build-tools;29.0.2" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29" "cmdline-tools;latest"
ENV PATH "$PATH:/home/developer/Android/sdk/platform-tools"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/developer/flutter/bin"

# Run basic check to download Dark SDK
RUN flutter doctor

# Enable flutter web
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web
RUN flutter packages pub global activate webdev

USER root

# Install jdk after because of skdmanager error if before
RUN apt install -y openjdk-11-jdk

WORKDIR /var/www/html

EXPOSE 80

CMD nignx -g "daemon off;"