FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN \
  apt-get update && \
  apt-get -y upgrade

RUN \
  apt-get -y --no-install-recommends install git g++ wget curl zip vim pkg-config tar cmake unzip ca-certificates python3 autoconf autoconf-archive autotools-dev automake make

# Download Android NDK
RUN \
  wget https://dl.google.com/android/repository/android-ndk-r27d-linux.zip && \
  unzip android-ndk-r27d-linux.zip && \
  rm -rf android-ndk-r27d-linux.zip

ENV ANDROID_NDK_HOME=/android-ndk-r27d

RUN git clone https://github.com/microsoft/vcpkg /vcpkg
WORKDIR /vcpkg
RUN ./bootstrap-vcpkg.sh

COPY arm-android-dynamic.cmake arm64-android-dynamic.cmake x64-android-dynamic.cmake /vcpkg/triplets/

ENV PATH="/vcpkg:$PATH"
ENV VCPKG_ROOT="/vcpkg"

WORKDIR /project
