#
# Dockerfile for running Xen Project on QEMU on ARM64 (aarch64) architecture.
#

# Start from latest Ubuntu 16.04.
FROM ubuntu:xenial-20200706

ARG DEBIAN_FRONTEND=noninteractive

# Install requirements.
RUN apt-get update && apt-get install -y \
    apt-utils \
    bc \
    bison \
    build-essential \
    build-essential \
    ccache \
    flex \
    gcc-aarch64-linux-gnu \
    git \
    git-email \
    graphviz \
    gstreamer1.0-libav \
    junit4 \
    kernel-package \
    kernel-package \
    libaio-dev \
    libbluetooth-dev \
    libbrlapi-dev \
    libbz2-dev \
    libcap-dev \
    libcap-ng-dev \
    libcurl4-gnutls-dev \
    libfdt-dev \
    libglib2.0-dev \
    libgtk-3-dev \
    libibverbs-dev \
    libiscsi-dev \
    libjpeg8-dev \
    libkrb5-dev \
    liblocale-msgfmt-perl \
    liblzo2-dev \
    libncurses5-dev \
    libnfs-dev \
    libnuma-dev \
    libpixman-1-dev \
    libpython3-dev \
    librbd-dev \
    librdmacm-dev \
    libreoffice \
    libsasl2-dev \
    libsdl1.2-dev \
    libseccomp-dev \
    libsnappy-dev \
    libssh2-1-dev \
    libssl-dev \
    libssl-dev \
    libvde-dev \
    libvdeplug-dev \
    libxen-dev \
    linux-source \
    nasm \
    ncurses-dev \
    pkg-config \
    python \
    python3 \
    tzdata \
    valgrind \
    wget \
    xfslibs-dev \
    xz-utils \
    zlib1g-dev

# Comfigure Time Zone.
ENV TZ=America/New_York
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime    && \
    dpkg-reconfigure --frontend noninteractive tzdata

#
# Download all necesary repositories and files first, so if something goes wrong there is no need to download everything again.
#
RUN git clone http://xenbits.xen.org/git-http/xen.git
RUN git clone https://github.com/qemu/qemu.git
RUN git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
RUN wget https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-arm64-uefi1.img

#
# Building & Compiling
#

# QEMU
RUN cd qemu/                                                && \
    mkdir build                                             && \
    cd build/                                               && \
    ../configure --target-list=arm-softmmu,aarch64-softmmu  && \
    make -j8                                                && \
    cd ../../

# Linux
RUN cd linux/                                                   && \
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig  && \
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j8        && \
    cd ../

# Xen Project
RUN cd xen/                                                                   && \
    git checkout RELEASE-4.9.4                                                && \
    make dist-xen XEN_TARGET_ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j8
