# Nvidia driver installer for Fedora Atomic

ARG FEDORA_VERSION

FROM fedora:${FEDORA_VERSION} as kmod_builder
LABEL maintainer="Konstantinos Samaras-Tsakiris <kosamara@cern.ch>" \
      name="nvidia-driver-installer" \
      version="0.2" \
      atomic.type="system" \
      architecture="x86_64"

ARG KERNEL_VERSION
ARG NVIDIA_DRIVER_VERSION
#ARG SELinux_ENABLED

RUN dnf -y update

RUN dnf -y install curl git binutils cpp gcc koji bc make pkgconfig pciutils unzip \
      elfutils-libelf-devel openssl-devel module-init-tools && \
    dnf -y autoremove && \
    koji download-build --rpm --arch=x86_64 kernel-core-${KERNEL_VERSION} && \
    koji download-build --rpm --arch=x86_64 kernel-devel-${KERNEL_VERSION} && \
    koji download-build --rpm --arch=x86_64 kernel-modules-${KERNEL_VERSION} && \
    koji download-build --rpm --arch=x86_64 kernel-headers-${KERNEL_VERSION} && \
    dnf install -y kernel-core-${KERNEL_VERSION}.rpm \
      kernel-devel-${KERNEL_VERSION}.rpm \
      kernel-modules-${KERNEL_VERSION}.rpm \
      kernel-headers-${KERNEL_VERSION}.rpm && \
    dnf clean all

ENV NVIDIA_DRIVER_URL "http://download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run"

ENV KERNEL_PATH /usr/src/kernels
ENV NVIDIA_PATH /opt/nvidia
ENV NVIDIA_BUILD_PATH ${NVIDIA_PATH}/build
ENV NVIDIA_DL_PATH ${NVIDIA_PATH}/download

# NVIDIA driver
WORKDIR ${NVIDIA_DL_PATH}
      
RUN curl ${NVIDIA_DRIVER_URL} -o nv_driver_installer.run && \
    chmod +x nv_driver_installer.run

RUN ${NVIDIA_PATH}/download/nv_driver_installer.run \
      -z \
      --accept-license \
      --no-questions \
      --ui=none \
      --no-precompiled-interface \
      --kernel-source-path=/lib/modules/${KERNEL_VERSION}/build \
      --kernel-name=${KERNEL_VERSION} \
      --no-nvidia-modprobe \
      --no-drm \
      --x-prefix=/usr \
      --no-install-compat32-libs \
      --installer-prefix=${NVIDIA_BUILD_PATH} \
      --utility-prefix=${NVIDIA_BUILD_PATH} \
      --opengl-prefix=${NVIDIA_BUILD_PATH} && \
      mv ${NVIDIA_BUILD_PATH}/lib ${NVIDIA_BUILD_PATH}/lib64
      #--force-selinux
      # NOTE: x-prefix is set to a different location,
      #   to simply skip those components and not include them in the installation

# Copy the built nvidia kernel modules to the Nvidia build dir, to copy over to stage2
#ENV NV_KMOD_DIR="/lib/modules/${KERNEL_VERSION}/kernel/drivers/video"
#RUN mkdir -p ${NVIDIA_BUILD_PATH}/${NV_KMOD_DIR} && \
#    cp ${NV_KMOD_DIR}/nvidia.ko ${NVIDIA_BUILD_PATH}/${NV_KMOD_DIR} && \
#    cp ${NV_KMOD_DIR}/nvidia-uvm.ko ${NVIDIA_BUILD_PATH}/${NV_KMOD_DIR}
RUN mkdir -p ${NVIDIA_BUILD_PATH}/lib/modules/ && \
    cp -rf /lib/modules/${KERNEL_VERSION} ${NVIDIA_BUILD_PATH}/lib/modules/${KERNEL_VERSION}

###   DEPLOY   ###
FROM fedora:${FEDORA_VERSION}
LABEL maintainer="Konstantinos Samaras-Tsakiris <kosamara@cern.ch>" \
      name="nvidia-driver-installer" \
      version="0.2" \
      atomic.type="system" \
      architecture="x86_64" 

ARG KERNEL_VERSION
ARG NVIDIA_DRIVER_VERSION

RUN dnf -y update && \
    dnf -y install module-init-tools pciutils && \
    dnf -y autoremove && \
    dnf clean all

ENV NVIDIA_DRIVER_VERSION ${NVIDIA_DRIVER_VERSION}
ENV KERNEL_VERSION ${KERNEL_VERSION}

ENV NVIDIA_PATH /opt/nvidia
ENV NVIDIA_BIN_PATH ${NVIDIA_PATH}/bin
ENV NVIDIA_LIB_PATH ${NVIDIA_PATH}/lib
ENV NVIDIA_MODULES_PATH ${NVIDIA_LIB_PATH}/modules/${KERNEL_VERSION}/kernel/drivers/video
#ENV NV_KMOD_DIR="/lib/modules/${KERNEL_VERSION}/kernel/drivers/video"

# NOTE: we are copying too much; theoretically we only need the nvidia*.ko
#   However, without the rest of the modules, we can't run depmod and modprobe
#   and would have to manually add the kmods with insmod.
#   Optimization: examine if depmod + modprobe is needed (dependency),
#   else simplify
COPY --from=kmod_builder /opt/nvidia/build ${NVIDIA_PATH}
COPY scripts/nvidia-mkdevs ${NVIDIA_BIN_PATH}/nvidia-mkdevs

# Copy kmods back to where depmod will find them
#RUN mkdir -p ${NV_KMOD_DIR} && \
  #    cp ${NVIDIA_PATH}/${NV_KMOD_DIR}/* ${NV_KMOD_DIR}
RUN mkdir /lib/modules && \
    cp -rf ${NVIDIA_PATH}/lib/modules/${KERNEL_VERSION} /lib/modules/${KERNEL_VERSION}

ENV PATH $PATH:${NVIDIA_BIN_PATH}
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${NVIDIA_LIB_PATH}

CMD depmod -a && \
    modprobe -r nouveau && \
    #rmmod nouveau && \
    modprobe nvidia && \
    modprobe nvidia-uvm && \
    nvidia-mkdevs && \
    cp -rfn ${NVIDIA_PATH}/bin /opt/nvidia-host && \
    cp -rfn ${NVIDIA_PATH}/lib64 /opt/nvidia-host
    #cp -rfn ${NVIDIA_PATH}/lib /opt/nvidia-host
# NOTE: ^^ parameterize nvidia-host path
