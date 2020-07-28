FROM amd64/ubuntu

RUN apt-get update && apt-get install -y git wget build-essential gcc-aarch64-linux-gnu

RUN git clone http://xenbits.xen.org/git-http/xen.git
RUN git clone https://github.com/qemu/qemu.git
RUN git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
RUN wget https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-arm64-uefi1.img
