#
# Dockerfile for running Xen Project on QEMU on ARM64 (aarch64) architecture.
#

# Start from latest Ubuntu 18.04.
FROM ubuntu:18.04

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

# Xen Project
RUN git clone http://xenbits.xen.org/git-http/xen.git
RUN cd xen/                                                                   && \
    git checkout RELEASE-4.9.4                                                && \
    make dist-xen XEN_TARGET_ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j8

RUN wget -c ftp://ftp.denx.de/pub/u-boot/u-boot-2019.01.tar.bz2 && \
    tar xf u-boot-2019.01.tar.bz2 && \
    cd u-boot-2019.01 && \
    make CROSS_COMPILE=aarch64-linux-gnu- qemu_arm64_defconfig && \
    echo -e "CONFIG_ARCH_QEMU=y\nCONFIG_TARGET_QEMU_ARM_64BIT=y" >>  .config && \
    make CROSS_COMPILE=aarch64-linux-gnu- -j4

# QEMU
RUN git clone https://github.com/qemu/qemu.git              && \
    cd qemu/                                                && \
    mkdir build                                             && \
    cd build/                                               && \
    ../configure --target-list=arm-softmmu,aarch64-softmmu  && \
    make -j8                                                && \
    cd ../../

# Linux
RUN git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git && \
    cd linux/                                                   && \
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig  && \
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j8        && \
    cd ../

# Busybox
RUN    wget -c https://busybox.net/downloads/busybox-1.30.1.tar.bz2
RUN    tar xf busybox-1.30.1.tar.bz2
#RUN    cd busybox-1.30.1/
RUN    cd busybox-1.30.1/ && make ARCH=arm CROSS_COMPILE=aarch64-linux-gnu- defconfig
RUN    cd busybox-1.30.1/ && make ARCH=arm CROSS_COMPILE=aarch64-linux-gnu- menuconfig
RUN    cd busybox-1.30.1/ && make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j8
RUN    cd busybox-1.30.1/ && make install ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
RUN    cd busybox-1.30.1/_install/ && mkdir proc sys dev etc etc/init.d
RUN    cd busybox-1.30.1/ && echo -e "#! /bin/sh\nmount -t proc none /proc\nmount -t sysfs none /sys\n/sbin/mdev -s" > _install/etc/init.d/rcS
RUN    cd busybox-1.30.1/ && chmod +x _install/etc/init.d/rcS
RUN    cd busybox-1.30.1/_install/ && find . | cpio -o --format=newc > ../rootfs.img
RUN    cd busybox-1.30.1/ && gzip -c rootfs.img > rootfs.img.gz

#cp rootfs.img.gz $BUILD_DIR/busybox_arm64/
