#!/bin/bash
# To be run in the nvidia-system container
# Install nvidia kernel modules and runtime libs to the proper system
# path. Assumes:
# - nvidia kernel modules have been built in /tmp/kernel
# - host mounts:
#   - /etc/modprobe.d
#   - /lib/modules/`uname -r`
#   - /usr/lib
#   - /usr/lib64

function install_kmod() {
  NV_KMOD_BUILD_DIR="/tmp/kernel"
  NV_KMOD_INSTALL_DIR="/lib/modules/`uname -r`"
  mkdir $NV_KMOD_INSTALL_DIR/extra
  cp $NV_KMOD_BUILD_DIR/*.ko $NV_KMOD_INSTALL_DIR/extra
  depmod -a
}

function blacklist_nouveau() {
  echo "blacklist nouveau" >> /etc/modprobe.d/gpu.conf
  echo "options nouveau modeset=0" >> /etc/modprobe.d/gpu.conf

  # TODO would this work?
  #rpm-ostree initramfs --arg=rd.driver.blacklist=nouveau --enable
}

function install_runtimelibs() {
  dnf install -y cuda-libraries-9-2 cuda-minimal-build-9-2 \
                 xorg-x11-drv-nvidia-cuda-libs xorg-x11-drv-nvidia-libs
}

# Setup nvidia kernel module
install_kmod
blacklist_nouveau
modprobe -r nouveau
modprobe nvidia

install_runtimelibs
