FROM fedora:latest as kmod-builder

LABEL maintainer="Konstantinos Samaras-Tsakiris <kosamara@cern.ch>" \
      name="nvidia-system-container" \
      version="0.1" \
      atomic.type="system" \
      architecture="x86_64" 

ARG KERNEL_VERSION

WORKDIR /tmp

RUN dnf update -y && \
      dnf install -y binutils cpp gcc koji make unzip wget pkgconfig && \
      koji download-build --rpm --arch=x86_64 kernel-core-${KERNEL_VERSION} && \
      koji download-build --rpm --arch=x86_64 kernel-devel-${KERNEL_VERSION} && \
      koji download-build --rpm --arch=x86_64 kernel-modules-${KERNEL_VERSION} && \
      koji download-build --rpm --arch=x86_64 kernel-headers-${KERNEL_VERSION} && \
      dnf install -y kernel-core-${KERNEL_VERSION}.rpm \
        kernel-devel-${KERNEL_VERSION}.rpm \
        kernel-modules-${KERNEL_VERSION}.rpm \
        kernel-headers-${KERNEL_VERSION}.rpm && \
      dnf clean all

RUN rpm -i "http://developer.download.nvidia.com/compute/cuda/repos/fedora27/x86_64/cuda-repo-fedora27-9.2.88-1.x86_64.rpm" && \
      dnf install -y akmod-nvidia && \
      tar cf /tmp/nvidia.tar /usr/lib/modules/${KERNEL_VERSION}/extra/nvidia

#RUN dnf install -y akmods kmodtool && \
#      rpm -i "http://developer.download.nvidia.com/compute/cuda/repos/fedora27/x86_64/cuda-nvidia-kmod-common-396.26-1.x86_64.rpm" && \
#      rpm -i "http://developer.download.nvidia.com/compute/cuda/repos/fedora27/x86_64/xorg-x11-drv-nvidia-kmodsrc-396.26-1.fc27.x86_64.rpm"
#
#RUN rpm -i "http://developer.download.nvidia.com/compute/cuda/repos/fedora27/x86_64/akmod-nvidia-396.26-1.fc27.x86_64.rpm" && \
#      rpm -i "http://developer.download.nvidia.com/compute/cuda/repos/fedora27/x86_64/xorg-x11-drv-nvidia-libs-396.26-1.fc27.x86_64.rpm"


### END BUILDER ###

FROM fedora:latest

LABEL maintainer="Konstantinos Samaras-Tsakiris <kosamara@cern.ch>" \
      name="nvidia-system-container" \
      version="0.1" \
      atomic.type="system" \
      architecture="x86_64" 

WORKDIR /tmp

RUN dnf update -y && dnf install -y kmod koji && \
      koji download-build --rpm --arch=x86_64 kernel-core-${KERNEL_VERSION} && \
      koji download-build --rpm --arch=x86_64 kernel-modules-${KERNEL_VERSION} && \
      dnf install -y kernel-core-${KERNEL_VERSION}.rpm kernel-modules-${KERNEL_VERSION}.rpm && \
      dnf clean all && rm -f /tmp/*.rpm

# Get the nvidia kernel module from builder
COPY --from=kmod-builder /tmp/nvidia.tar /tmp/nvidia.tar
RUN tar xf /tmp/nvidia.tar && mv /tmp/nvidia /usr/lib/modules/${KERNEL_VERSION}/extra/

# Get the nvidia runtime libraries
RUN dnf install -y cuda-libraries-9-2 cuda-minimal-build-9-2 xorg-x11-drv-nvidia-cuda-libs xorg-x11-drv-nvidia-libs
