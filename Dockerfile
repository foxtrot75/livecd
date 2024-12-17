FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y

RUN apt install --install-recommends -y linux-generic-hwe-20.04

RUN echo Y | unminimize

RUN apt install -y \
    dosfstools \
    grub-efi-amd64-bin \
    isolinux \
    live-boot \
    live-tools \
    man \
    mc \
    mtools \
    squashfs-tools \
    syslinux-common \
    xorriso

RUN echo "root:root" | chpasswd
